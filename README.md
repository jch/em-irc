# EventMachine IRC Client

[CI Build Status](https://secure.travis-ci.org/jch/em-irc.png?branch=master)

em-irc is an IRC client that uses EventMachine to handle connections to servers.

## Basic Usage

````ruby
require 'em-irc'

client = EventMachine::IRC::Client.new do |c|
  c.host = 'irc.freenode.net'
  c.port = '6667'
  c.nick = 'jch'

  c.on(:connect) do
    nick('jch')
  end

  c.on(:nick) do
    join('#general')
    join('#private', 'key')
  end

  c.on(:join) do |channel|  # called after joining a channel
    message(channel, "howdy all")
  end

  c.on(:message) do |source, target, message|  # called when being messaged
    puts "<#{source}> -> <#{target}>: #{message}"
  end

  # callback for all messages sent from IRC server
  c.on(:raw) do |hash|
    puts "#{hash[:prefix]} #{hash[:command]} #{hash[:params].join(' ')}"
  end
end

client.run!  # start EventMachine loop
````

## Examples

In the examples folder, there are runnable examples.

* cli.rb - takes input from keyboard, outputs to stdout
* websocket.rb - 
* echo.rb - bot that echos everything
* callback.rb - demonstrate how callbacks work

## References

* [RFC 1459 - Internet Relay Chat Protocol](http://tools.ietf.org/html/rfc1459) overview of IRC architecture
* [RFC 2812 - Internet Relay Chat: Client Protocol](http://tools.ietf.org/html/rfc2812) specifics of client protocol
* [RFC 2813 - Internet Relay Chat: Server Protocol](http://tools.ietf.org/html/rfc2813) specifics of server protocol

## Development

To run integration specs, you'll need to run a ssl and a non-ssl irc server locally.
On OSX, you can install a server via [Homebrew](http://mxcl.github.com/homebrew/) with:

```
bundle
brew install ngircd
ngircd -f spec/config/ngircd-unencrypted.conf
ngircd -f spec/config/ngircd-encrypted-openssl.conf
bundle exec rake  # or guard
```

If the server is not starting up correctly, make sure you're ngircd is
compiled with openssl support rather than gnutls. You can see the server
boot output by passing the '-n' flag. Also not that travis-ci builds
are executed with gnutls.

## <a name="license"></a>License

Copyright (c) 2012 Jerry Cheung.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## TODO

* can we skip using Dispatcher connection handler class?
* extract :on, :trigger callback gem that works on instances. [hook](https://github.com/apotonick/hooks), but works with instances
* would prefer the interface to look synchronous, but work async
* ssl dispatcher testing
* speed up integration specs