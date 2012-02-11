require File.expand_path '../../lib/em-irc', __FILE__
require 'logger'

client = EventMachine::IRC::Client.new do
  host   '127.0.0.1'
  port   '6667'
  # logger Logger.new(STDOUT)

  on :connect do
    puts 'client connected'
    join("#general")
  end

  on :message do |source, target, message|
    puts "#{target} <#{source}> #{message}"
  end

  # on :raw do |m|
  #   # puts "raw message: #{m.inspect}"
  # end
end

# puts client.callbacks
client.run!