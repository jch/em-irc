# EventMachine IRC Client

[![Build Status](https://secure.travis-ci.org/jch/em-irc.png?branch=master)](http://travis-ci.org/jch/em-irc)

em-irc is an IRC client that uses EventMachine to handle connections to servers.

## Basic Usage

````ruby
require 'em-irc'

client = EventMachine::IRC::Client.new do
  host 'irc.freenode.net'
  port '6667'

  on(:connect) do
    nick('jch')
  end

  on(:nick) do
    join('#general')
    join('#private', 'key')
  end

  on(:join) do |channel|  # called after joining a channel
    message(channel, "howdy all")
  end

  on(:message) do |source, target, message|  # called when being messaged
    puts "<#{source}> -> <#{target}>: #{message}"
  end

  # callback for all messages sent from IRC server
  on(:raw) do |hash|
    puts "#{hash[:prefix]} #{hash[:command]} #{hash[:params].join(' ')}"
  end
end

client.run!  # start EventMachine loop
````

Alternatively, if local variable access is needed, the first block variable is
the client:

````ruby
client = EventMachine::IRC::Client.new do |c|
  # c is the client instance
end
````

## References

* [API Documentation](http://rubydoc.info/gems/em-irc/0.0.1/frames)
* [RFC 1459 - Internet Relay Chat Protocol](http://tools.ietf.org/html/rfc1459) overview of IRC architecture
* [RFC 2812 - Internet Relay Chat: Client Protocol](http://tools.ietf.org/html/rfc2812) specifics of client protocol
* [RFC 2813 - Internet Relay Chat: Server Protocol](http://tools.ietf.org/html/rfc2813) specifics of server protocol

## Platforms

The following platforms are tentatively supported:

* 1.8.7
* 1.9.2
* 1.9.3
* ree
* Rubinius

I currently develop ruby 1.9.3, so it'll be the VM that gets the most support.

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