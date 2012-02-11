require 'spec_helper'

shared_examples_for 'dispatcher' do
  it 'should delegate connection methods to parent' do
    parent = Class.new do
      attr_accessor :conn
      def ssl
        $ssl
      end

      def receive_data(data)
        EventMachine::stop_event_loop
        raise "Didn't get expected message" unless data == 'message'
      end
    end.new
    parent.should_receive(:ready)
    parent.should_receive(:unbind)
    EventMachine.run {
      EventMachine::start_server('127.0.0.1', '198511', described_class, parent: parent)
      EventMachine::connect('127.0.0.1', '198511') do |conn|
        conn.send_data("message")
      end
      EventMachine::add_timer(2) {
        EventMachine::stop_event_loop
        raise "Never reached receive_data or took too long"
      }
    }
  end
end

describe EventMachine::IRC::Dispatcher do
  context 'ssl integration' do
    before {$ssl = true}
    it 'behaves like dispatcher' do
      pending "not sure how to test ssl"
    end
    # it_behaves_like "dispatcher"
  end

  context 'non-ssl integration' do
    before {$ssl = false}
    it_behaves_like "dispatcher"
  end
end