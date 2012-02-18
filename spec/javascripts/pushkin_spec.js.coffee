describe "Pushkin", ->
  pushkin = null

  it "should be defined", ->
    expect(Pushkin).toEqual jasmine.any(Function)

  describe "instance functions", ->
    doc = null
    called = null

    beforeEach ->
      window.Faye = {}
      pushkin = new Pushkin
      called = false
      doc = {}

    it "adds callback to subscriptions", ->
      pushkin.subscribe("hello", "callback");
      expect(pushkin.subscriptionCallbacks["hello"]).toEqual("callback")

    it "has a fayeExtension which adds matching subscription signature and timestamp to outgoing message", ->
      message =
        channel: "/meta/subscribe"
        subscription: "hello"

      pushkin.subscriptions["hello"] = {signature: "abcd", timestamp: "1234"}
      fayeExtension = pushkin.fayeExtension()
      fayeExtension.outgoing(message, (message) ->
        expect(message.ext.pushkin_signature).toEqual "abcd"
        expect(message.ext.pushkin_timestamp).toEqual "1234"
        called = true
      )
      expect(called).toBeTruthy()

    it "evaluates javascript in message response", ->
      pushkin.handleResponse(
        eval: 'this.subscriptions.foo = "bar"'
      )
      expect(pushkin.subscriptions.foo).toEqual "bar"

    it "triggers callback matching message channel in response", ->
      pushkin.subscribe("test", (data, channel) ->
        expect(data).toEqual "abcd"
        expect(channel).toEqual "test"
        called = true
      )
      pushkin.handleResponse(
        channel: "test"
        data: "abcd"
      )
      expect(called).toBeTruthy()

    it "adds a faye subscription with response handler when signing", ->
      faye =
        subscribe: jasmine.createSpy()
      subscription =
        server: "server"
        channel: "somechannel"

      spyOn(pushkin, 'faye').andCallFake((callback) -> callback(faye))

      pushkin.sign(subscription)
      expect(faye.subscribe).toHaveBeenCalledWith "somechannel", pushkin.handleResponse
      expect(pushkin.server).toEqual "server"
      expect(pushkin.subscriptions.somechannel).toEqual subscription

    it "adds a faye subscription with response handler when signing", ->
      faye =
        subscribe: jasmine.createSpy()

      options =
        server: "server"
        channel: "somechannel"

      spyOn(pushkin, 'faye').andCallFake((callback) -> callback(faye))
      pushkin.sign(options)
      expect(faye.subscribe).toHaveBeenCalledWith "somechannel", pushkin.handleResponse
      expect(pushkin.server).toEqual "server"
      expect(pushkin.subscriptions.somechannel).toEqual options

    it "triggers faye callback function immediately when fayeClient is available", ->
      pushkin.fayeClient = "faye"
      pushkin.faye((faye) ->
        expect(faye).toEqual "faye"
        called = true
      )
      expect(called).toBeTruthy()

    it "adds fayeCallback when client and server aren't available", ->
      pushkin.faye "callback"
      expect(pushkin.fayeCallbacks[0]).toEqual "callback"

    it "adds a script tag loading faye js when the server is present", ->
      script = {}
      doc.createElement = -> return script
      doc.documentElement =
        appendChild: jasmine.createSpy()
      spyOn(pushkin, "document").andReturn doc

      pushkin.server = "path/to/faye"
      pushkin.faye("callback")
      expect(pushkin.fayeCallbacks[0]).toEqual "callback"
      expect(script.type).toEqual "text/javascript"
      expect(script.src).toEqual "path/to/faye.js"
      expect(script.onload).toEqual pushkin.connectToFaye
      expect(doc.documentElement.appendChild).toHaveBeenCalledWith script

    it "connects to faye server, adds extension, and executes callbacks", ->
      callback = jasmine.createSpy()
      client =
        addExtension: jasmine.createSpy()
      Faye.Client = (server) ->
        expect(server).toEqual("server")
        client

      pushkin.server = "server"
      pushkin.fayeCallbacks.push(callback)
      pushkin.connectToFaye()
      expect(pushkin.fayeClient).toEqual client
      expect(client.addExtension).toHaveBeenCalledWith pushkin.fayeExtension()
      expect(callback).toHaveBeenCalledWith client


this.Faye = {}