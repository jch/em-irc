require 'spec_helper'

describe EventMachine::IRC::Client do
  context 'configuration' do
    it 'defaults host to 127.0.0.1' do
      subject.host.should == '127.0.0.1'
    end

    it 'defaults realname to random generated name' do
      subject.realname.should_not be_blank
    end

    it 'defaults port to 6667' do
      subject.port.should == '6667'
    end

    it 'defaults ssl to false' do
      subject.ssl.should == false
    end

    it 'defaults channels to an empty set' do
      subject.channels.should be_empty
    end

    it 'should not be connected' do
      subject.should_not be_connected
    end

    it 'should have blank nick' do
      subject.nick.should be_blank
    end

    it 'should optionally yield self' do
      described_class.new do |c|
        c.should be_kind_of(described_class)
      end
    end

    it 'should optionally instance eval' do
      client = described_class.new do
        host 'stella.net'
      end
      client.host.should == 'stella.net'
    end

    it 'should allow a custom logger' do
      subject.logger = Logger.new(STDOUT)
      subject.logger = nil
    end
  end

  context 'connect' do
    it 'should create an EM TCP connection with host, port, handler, and ssl' do
      EventMachine.should_receive(:connect).with('irc.net', '9999', EventMachine::IRC::Dispatcher, parent: subject, ssl: subject.ssl)
      subject.host = 'irc.net'
      subject.port = '9999'
      subject.connect
    end

    it 'should be idempotent' do
      EventMachine.stub(connect: mock('Connection'))
      EventMachine.should_receive(:connect).exactly(1).times
      subject.connect
      subject.connect
    end
  end

  context 'send_data' do
    before do
      @connection = mock('Connection')
      subject.stub(conn: @connection)
      subject.stub(connected?: true)
    end

    it 'should return false if not connected' do
      subject.stub(connected?: nil)
      subject.send_data("NICK jch").should be_false
    end

    it 'should send message to irc server' do
      subject.stub(conn: @connection)
      @connection.should_receive(:send_data).with("NICK jch\r\n")
      subject.send_data("NICK jch")
    end
  end

  context 'ready' do
    before do
      subject.stub(conn: mock.as_null_object)
    end

    it 'should call :connect callback' do
      m = mock('callback')
      m.should_receive(:callback)
      subject.on(:connect) {m.callback}
      subject.ready
    end

    it 'should mark client as connected' do
      subject.ready
      subject.should be_connected
    end
  end

  context 'unbind' do
    it 'should call :disconnect callback' do
      m = mock('callback')
      m.should_receive(:callback)
      subject.on(:disconnect) {m.callback}
      subject.unbind
    end
  end

  context 'message parsing' do
    context 'prefix' do
      it 'should be optional' do
        parsed = subject.parse_message('NICK jch')
        parsed[:prefix].should be_nil
      end

      it 'should start with :' do
        parsed = subject.parse_message(':jch!host 123 :params')
        parsed[:prefix].should == 'jch!host'
      end
    end

    context 'params' do
      it 'should remove leading :' do
        parsed = subject.parse_message('PING :irc.net')
        parsed[:params] =~ ['irc.net']
      end
    end
  end

  context 'receive_data' do
    let(:data) {
      [
        ":irc.the.net 001 jessie :Welcome to the Internet Relay Network jessie!~jessie@localhost",
        ":irc.the.net 002 jessie :Your host is irc.the.net, running version ngircd-17.1 (i386/apple/darwin11.2.0)",
        ":irc.the.net 003 jessie :This server has been started Fri Feb 03 2012 at 14:42:38 (PST)"
      ].join("\r\n")
    }
    let(:parsed_message) {mock.as_null_object}

    before do
      subject.stub(:parse_message).and_return(parsed_message)
      subject.stub(:handle_parsed_message)
    end

    it 'should parse messages separated by \r\n' do
      subject.should_receive(:parse_message).exactly(3).times
      subject.receive_data(data)
    end

    it 'should handle parsed messages' do
      subject.should_receive(:handle_parsed_message).exactly(3).times
      subject.receive_data(data)
    end

    it 'should trigger :raw callbacks' do
      subject.should_receive(:trigger).with(:raw, parsed_message).exactly(3).times
      subject.receive_data(data)
    end
  end

  context 'handle_parsed_message' do
    it 'should respond to pings' do
      subject.should_receive(:pong).with("irc.net")
      subject.handle_parsed_message({prefix: 'irc.net', command: 'PING', params: ['irc.net']})
    end

    # TODO: do we want a delegate object and callbacks?
    # it 'should call optional delegate' do
    #   subject.stub(delegate: mock('Delegate'))
    #   subject.delegate.should_receive(:message)
    #   subject.handle_parsed_message({prefix: 'jessie!jessie@localhost', command: 'PRIVMSG', params: ['#general', 'hello world'])
    # end
  end

  context 'callbacks' do
    it 'should register multiple' do
      m = mock('Callback')
      subject.on(:foo) {m.callback}
      subject.on(:foo) {m.callback}
      subject.callbacks[:foo].size.should == 2
    end

    it 'should trigger with params' do
      m = mock('Callback')
      m.should_receive(:callback).with('arg')
      subject.on(:foo) {|arg| m.callback(arg)}
      subject.trigger(:foo, 'arg')
    end
  end
end
