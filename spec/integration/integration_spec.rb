require 'spec_helper'

# add a raw message queue for debugging, might be a good normal feature
class TestClient < EventMachine::IRC::Client
  def initialize(options = {})
    super(options)
    @received_messages = []
  end

  def receive_data(data)
    @received_messages << data
    super(data)
  end

  def history
    "\n" + @received_messages.join("\n") + "\n"
  end
end

shared_examples_for "integration" do
  it 'should work' do
    dan = client
    bob = client
    ace = client

    dan.on(:connect) {dan.nick('dan')}
    bob.on(:connect) {bob.nick('bob')}
    ace.on(:connect) {ace.nick('bob')}

    dan.on(:nick) {dan.join('#americano-test')}
    bob.on(:nick) {bob.join('#americano-test')}

    bob.on(:join) do |who, channel|
      bob.message(channel, "dan: hello bob")
      # bob.quit
      # dan.quit
    end

    dan.on(:message) do |who, channel, message|
      @who     = who
      @channel = channel
      @message = message
    end

    EM.run {
      dan.connect
      bob.connect
      ace.connect
      EM::add_timer(2) {EM::stop}
    }

    # TODO: matchers for commands
    dan.nick.should == 'dan'
    dan.history.should =~ /Welcome/
    dan.history.should =~ /JOIN :#americano-test/

    @who.should == "bob"
    @channel.should == "#americano-test"
    @message.should == "dan: hello bob"

    bob.nick.should == 'bob'
    bob.history.should =~ /Welcome/
    bob.history.should =~ /JOIN :#americano-test/

    ace.nick.should == nil
    ace.history.should =~ /Nickname already in use/
  end
end

# Assumes there is an IRC server running at localhost 6667
describe EventMachine::IRC::Client, :integration => true do
  let(:options) do
    {
      host: '127.0.0.1',
      port: '16667'
    }.merge(@options || {})
  end

  def client(opts = {})
    TestClient.new(options.merge(opts))
  end

  context 'non-ssl' do
    before :all do
      raise "unencrypted ircd not on :16667" unless `lsof -i :16667`.chomp.size > 1
    end
    it_behaves_like "integration"
  end

  context 'ssl' do
    before :all do
      raise "encrypted ircd not on :16697" unless `lsof -i :16697`.chomp.size > 1
      @options = {
        port: '16697',
        ssl: true
      }
    end
    it_behaves_like "integration"
  end
end