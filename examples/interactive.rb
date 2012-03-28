require File.expand_path '../../lib/em-irc', __FILE__
require 'logger'

client = EventMachine::IRC::Client.new do
  host   '127.0.0.1'
  port   '6667'

  on :connect do
    nick 'keybot'
    join "#general"
  end

  on :raw do |m|
    puts "raw message: #{m.inspect}"
  end
end

class KeyboardHandler < EM::Connection
  include EM::Protocols::LineText2
  attr_reader :queue

  def initialize(q)
    @queue = q
  end

  def receive_line(data)
    @queue.push(data)
  end
end

EM.run {
  q = EM::Queue.new
  callback = Proc.new do |line|
    client.instance_eval line
    q.pop(&callback) # enqueue next pop
  end
  q.pop(&callback)

  client.connect
  EM.open_keyboard(KeyboardHandler, q)
}