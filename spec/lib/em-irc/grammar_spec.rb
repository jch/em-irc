require 'spec_helper'

describe EventMachine::IRC::Grammar do
  subject {EventMachine::IRC::Grammar}

  it 'should nick' do
    subject.parse('jch', :root => :nick).should == 'jch'
    expect {subject.parse('j@ck')}.to raise_error Citrus::ParseError
    expect {subject.parse('jac!')}.to raise_error Citrus::ParseError
  end

  it 'should host' do
    subject.parse('irc.the.net', :root => :host).should == 'irc.the.net'
    expect {subject.parse('irc.the.net ')}.to raise_error Citrus::ParseError
  end

  it 'should rpl_welcome' do
    m = subject.parse 'Welcome to the Internet Relay Network jch!jch@guava', :root => :rpl_welcome
    m.nick.should == 'jch'
    m.user.should == 'jch'
    m.host.should == 'guava'
  end

  it 'should rpl_yourhost' do
    m = subject.parse "Your host is irc.the.net, running version ngircd-17.1 (i386/apple/darwin11.2.0)", :root => :rpl_yourhost
    m.host.should == 'irc.the.net'
    m.version.should == 'ngircd-17.1 (i386/apple/darwin11.2.0)'
  end

  it 'should rpl_created' do
    m = subject.parse "This server was created Sat Mar 10 2012 at 15:25:49 (EST)", :root => :rpl_created
    m.date.should == 'Sat Mar 10 2012 at 15:25:49 (EST)'
  end

  it 'should rpl_myinfo' do
    m = subject.parse "irc.the.net ngircd-17.1 aciorswx biIklmnoPstvz", :root => :rpl_myinfo
  end

  it 'should rpl_userhost' do
    m = subject.parse "jch=+~jch@localhost jch2=+~jch@localhost", :root => :rpl_userhost
  end

  # it 'should rpl_ison'

  it 'should rpl_nowaway' do
  end
end