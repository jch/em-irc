require File.expand_path '../../lib/em-irc', __FILE__
require 'logger'

client = EventMachine::IRC::Client.new do
  host   '127.0.0.1'
  port   '6667'

  on :connect do
    puts 'client connected'
    nick 'em-irc'
    join "#general"
  end

  on :raw do |m|
    puts "raw message: #{m.inspect}"
  end
end

client.run!