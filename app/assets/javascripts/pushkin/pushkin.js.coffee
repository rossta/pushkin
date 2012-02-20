class Pushkin
  constructor: (@options) ->
    @fayeClient = null
    @fayeCallbacks = []
    @subscriptions = {}
    @subscriptionCallbacks = {}

  subscribe: (channel, callback) ->
    @subscriptionCallbacks[channel] = callback

  faye: (callback) ->
    if @fayeClient
      callback(@fayeClient)
    else
      @fayeCallbacks.push(callback)
      if (@url && !@connecting)
        @connecting = true
        doc = @document()
        script = doc.createElement("script")
        script.type   = "text/javascript"
        script.src    = @url + ".js"
        script.onload = @connectToFaye
        doc.documentElement.appendChild(script)

  fayeExtension: ->
    @fayeExtensionInstance ||= new FayeExtension(@subscriptions)

  connectToFaye: =>
    @fayeClient = new Faye.Client(@url)
    @fayeClient.addExtension(@fayeExtension())
    callback(@fayeClient) for callback in @fayeCallbacks

  handleResponse: (message) ->
    eval(message.eval) if message.eval
    if (callback = @subscriptionCallbacks[message.channel])
      callback(message.data, message.channel)

  sign: (subscription) ->
    @url = subscription.url if !@url
    @subscriptions[subscription.channel] = subscription
    @faye((faye) =>
      faye.subscribe(subscription.channel, @handleResponse)
    )
    this

  document: -> window.document

  @sign: (subscription) ->
    @instance ||= new this()
    @instance.sign(subscription)

  @subscribe: (channel, callback) ->
    @instance.subscribe(channel, callback)

class FayeExtension
  constructor: (@subscriptions) ->

  outgoing: (message, callback) ->
    if (message.channel == "/meta/subscribe")
      subscription = @subscriptions[message.subscription]
      message.ext ||= {}
      message.ext.pushkin_signature = subscription.signature;
      message.ext.pushkin_timestamp = subscription.timestamp;

    callback(message)

this.Pushkin = Pushkin