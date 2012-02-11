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
    dan = client(nick: 'dan')
    bob = client(nick: 'bob')

    dan.on(:connect) {dan.join('#americano-test')}
    bob.on(:connect) {bob.join('#americano-test')}

    bob.on(:join) do |who, channel|
      bob.message(channel, "dan: hello bob")
      # bob.quit
      # dan.quit
    end

    EM.run {
      dan.connect
      EM::add_timer(2) {bob.connect}
      EM::add_timer(5) {EM::stop}
    }

    # TODO: matchers for commands
    dan.history.should =~ /Welcome/
    dan.history.should =~ /JOIN :#americano-test/
    dan.history.should =~ /dan: hello bob/

    bob.history.should =~ /Welcome/
    bob.history.should =~ /JOIN :#americano-test/
  end
end

# Assumes there is an IRC server running at localhost 6667
describe EventMachine::IRC::Client, :integration => true do
  let(:options) do
    {
      host: '127.0.0.1',
      port: '6667'
    }.merge(@options || {})
  end

  def client(opts = {})
    TestClient.new(options.merge(opts))
  end

  context 'non-ssl' do
    before do
      unless `lsof -i :6667 | grep LISTEN`.chomp.size > 1
        fail "No IRC server running to test integration. See README.md for details"
      end
    end
    it_behaves_like "integration"
  end

  context 'ssl' do
    before do
      @options = {
        port: '6697',
        ssl: true
      }
      unless `lsof -i :6697 | grep LISTEN`.chomp.size > 1
        fail "No IRC server running to test integration. See README.md for details"
      end
    end
    it_behaves_like "integration"
  end
end