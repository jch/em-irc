require 'spec_helper'

describe EventMachine::IRC::Commands do
  subject {EventMachine::IRC::Client.new}

  context "nick" do
    it 'should set nick' do
      subject.should_receive(:send_data).with("NICK jch")
      subject.nick('jch')
    end

    it 'should get nick' do
      subject.instance_eval {@nick = 'jch'}
      subject.nick.should == 'jch'
    end
  end

  context "join" do
    it 'should join single channel' do
      subject.should_receive(:send_data).with("JOIN #general")
      subject.join("#general")
    end

    it 'should join multiple channels' do
      subject.should_receive(:send_data).with("JOIN #general,#foo")
      subject.join('#general', '#foo')
    end

    it 'should join channels with keys' do
      subject.should_receive(:send_data).with("JOIN #foo,&bar fubar,bazly")
      subject.join(['#foo', 'fubar'], ['&bar', 'bazly'])
    end

    it 'should join channels with and without keys' do
      subject.should_receive(:send_data).with("JOIN #foo,#cat,&bar fubar,dog")
      subject.join(['#foo', 'fubar'], '&bar', ["#cat", "dog"])
    end

    it 'should leave all currently joined channels' do
      subject.should_receive(:join).with('0')
      subject.join('0')
    end
  end

  context "part_all" do
    it 'should leave all currently joined channels' do
      subject.should_receive(:join).with('0')
      subject.part_all
    end
  end

  context "part" do
    it 'should part single' do
      subject.should_receive(:send_data).with('PART #general :Leaving...')
      subject.part('#general')
    end

    it 'should part single with custom message' do
      subject.should_receive(:send_data).with('PART #general :Goodbye everybody!')
      subject.part('#general', 'Goodbye everybody!')
    end

    it 'should part multiple' do
      subject.should_receive(:send_data).with('PART #general,#foo :Leaving...')
      subject.part('#general', '#foo')
    end

    it 'should part multiple with custom message' do
      subject.should_receive(:send_data).with('PART #general,#foo :Goodbye everybody!')
      subject.part('#general', '#foo', 'Goodbye everybody!')
    end
  end

  context "topic" do
    it 'should get topic' do
      subject.should_receive(:send_data).with("TOPIC #foo")
      subject.topic('#foo')
    end

    it 'should set topic' do
      subject.should_receive(:send_data).with("TOPIC #foo :awesome channel")
      subject.topic('#foo', "awesome channel")
    end

    it 'should unset topic' do
      subject.should_receive(:send_data).with("TOPIC #foo :")
      subject.topic('#foo', '')
    end
  end
end