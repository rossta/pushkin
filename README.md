# Pushkin

Pushkin aims to provide Rails 3.1+ applications with publish/subscribe functionality through [Faye](http://faye.jcoglan.com/).

This gem is based on [Private Pub](https://github.com/ryanb/private_pub) as featured in [RailsCasts Episode 316](http://railscasts.com/episodes/316-private-pub).

[![Build Status](https://secure.travis-ci.org/rossta/pushkin.png)](http://travis-ci.org/rossta/pushkin)

##

Add the gem to your Gemfile and run the `bundle` command to install it.

```ruby
gem "pushkin"
```

Run the generator to create the initial files.

```
rails g pushkin:install
```

Next, start up Faye using the rackup file that was generated.

```
rackup pushkin.ru -s thin -E production
```

**In Rails 3.1** add the JavaScript file to your application.js file manifest.

```javascript
//= require pushkin
```
