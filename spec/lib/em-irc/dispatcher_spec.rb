require 'spec_helper'

shared_examples_for 'dispatcher' do
  it 'should delegate connection methods to parent' do
    module TestServer
      def post_init
        send_data "message"
      end
    end

    parent = Class.new do
      attr_accessor :conn
      def receive_data(data)
        EventMachine::stop_event_loop
        raise "Didn't get expected message" unless data == 'message'
      end
    end.new
    parent.should_receive(:ready)
    parent.should_receive(:unbind)
    EventMachine.run {
      EventMachine::start_server('127.0.0.1', '198511', TestServer)
      EventMachine::connect('127.0.0.1', '198511', EventMachine::IRC::Dispatcher, parent: parent, ssl: ssl)
      EventMachine::add_timer(3) {
        EventMachine::stop_event_loop
        raise "Never reached receive_data or took too long"
      }
    }
  end
end

describe EventMachine::IRC::Dispatcher do
  context 'ssl integration' do
    it "how to test ssl?"
    # it_behaves_like "dispatcher" do
    #   let(:ssl) {true}
    # end
  end

  context 'non-ssl integration' do
    it_behaves_like "dispatcher" do
      let(:ssl) {false}
    end
  end
end