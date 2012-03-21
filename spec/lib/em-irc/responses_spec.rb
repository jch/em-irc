require 'spec_helper'

describe EventMachine::IRC::Responses do
  subject {EventMachine::IRC::Client.new}

  def handle(raw_response)
    parsed = subject.parse_message(raw_response)
    subject.handle_parsed_message(parsed)
  end

  context 'ping' do
    it 'should respond with pong' do
      subject.should_receive(:pong).with("irc.net")
      handle ":irc.net PING irc.net"
    end
  end

  context 'privmsg' do
    it 'should trigger message' do
      subject.should_receive(:trigger).with(:message, 'sender', '#channel', 'full message')
      handle ":sender!~sender@host PRIVMSG #channel :full message"
    end
  end

  context 'join' do
    it 'should trigger join' do
      subject.should_receive(:trigger).with(:join, 'sender', '#channel')
      handle ":sender!~sender@host JOIN #channel"
    end
  end

  context 'rpl_welcome' do
    it 'should set nick' do
      subject.should_receive(:trigger).with(:nick, 'jessie')
      handle ":irc.the.net 001 jessie :Welcome to the Internet Relay Network jessie!~jessie@localhost"
    end
  end

  context 'err_nicknameinuse' do
    it 'should unset nick' do
      subject.instance_eval {@nick = 'jerry'}
      handle ":irc.the.net 433 :ERR_NICKNAMEINUSE"
      subject.nick.should be_nil
    end
  end
end