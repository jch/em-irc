require 'bundler'
Bundler.setup :default

require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'
require 'active_support/callbacks'
require 'eventmachine'
require 'forwardable'
require 'set'

$:.unshift File.expand_path '..', __FILE__

module EventMachine
  module IRC
    autoload :Client,     'em-irc/client'
    autoload :Dispatcher, 'em-irc/dispatcher'
    autoload :Commands,   'em-irc/commands'
  end
end
