require 'support/dsl_accessor'

module EventMachine
  module IRC
    class Client
      include DslAccessor
      include IRC::Commands
      include IRC::Responses

      # EventMachine::Connection object to IRC server
      # @private
      attr_accessor :conn

      # @macro dsl_accessor
      #   Accessor for `$1`
      # Defaults to '127.0.0.1'
      dsl_accessor :host

      # @macro dsl_accessor
      # Defaults to '6667'
      dsl_accessor :port

      # @macro dsl_accessor
      dsl_accessor :realname

      # @macro dsl_accessor
      dsl_accessor :ssl

      # @macro dsl_accessor
      dsl_accessor :logger

      # Set of channels that this client is connected to
      attr_reader :channels

      # Hash of callbacks on events. key is symbol event name.
      # value is array of procs to call
      # @private
      attr_reader :callbacks

      # Build a new unconnected IRC client
      #
      # @param [Hash] options
      # @option options [String] :host
      # @option options [String] :port
      # @option options [Boolean] :ssl
      # @option options [String] :realname
      #
      # @yield [client] new instance for decoration
      def initialize(options = {}, &blk)
        options.symbolize_keys!
        options = {
          :host =>     '127.0.0.1',
          :port =>     '6667',
          :ssl =>      false,
          :realname => 'Anonymous Annie'
        }.merge!(options)

        @host      = options[:host]
        @port      = options[:port]
        @ssl       = options[:ssl]
        @realname  = options[:realname]
        @channels  = Set.new
        @callbacks = Hash.new
        @connected = false

        if block_given?
          if blk.arity == 1
            yield self
          else
            instance_eval(&blk)
          end
        end
      end

      # Creates a Eventmachine TCP connection with :host and :port. It should be called
      # after callbacks are registered.
      # @see #on
      # @return [EventMachine::Connection]
      def connect
        self.conn ||= EventMachine::connect(@host, @port, Dispatcher, :parent => self, :ssl => @ssl)
      end

      # @return [Boolean]
      def connected?
        @connected
      end

      # Start running the client
      def run!
        EM.epoll
        EventMachine.run do
          trap("TERM") { EM::stop }
          trap("INT")  { EM::stop }
          connect
          log Logger::INFO, "Starting IRC client..."
        end
        log Logger::INFO, "Stopping IRC client"
        @logger.close if @logger
      end

      # === Callbacks

      # Register a callback with `:name` as one of the following, and
      # a block with the same number of params.
      #
      # @example
      #   on(:join) {|channel| puts channel}
      #  
      #   :connect - called after connection to server established
      #  
      #   :join
      #     @param who [String]
      #     @param channel [String]
      #     @param names [Array]
      #  
      #   :message, :privmsg - called on channel message or nick message
      #     @param source [String]
      #     @param target [String]
      #     @param message [String]
      #  
      #   :raw - called for all messages from server
      #     @param raw_hash [Hash] same format as return of #parse_message
      def on(name, &blk)
        # TODO: I thought Hash.new([]) would work, but it gets empted out
        # TODO: normalize aliases :privmsg, :message, etc
        (@callbacks[name.to_sym] ||= []) << blk
      end

      # Trigger a named callback
      # @private
      def trigger(name, *args)
        # TODO: should this be instance_eval(&blk)? prevents it from non-dsl style
        (@callbacks[name.to_sym] || []).each {|blk| blk.call(*args)}
      end

      # @private
      def log(*args)
        @logger.log(*args) if @logger
      end

      # Sends raw message to IRC server. Assumes message is correctly formatted
      # TODO: what if connect fails? or disconnects?
      # @private
      def send_data(message)
        return false unless connected?
        message = message + "\r\n"
        log Logger::DEBUG, message
        self.conn.send_data(message)
      end

      # === EventMachine Callbacks
      # @private
      def receive_data(data)
        data.split("\r\n").each do |message|
          parsed = parse_message(message)
          handle_parsed_message(parsed)
          trigger(:raw, parsed)
        end
      end

      # @private
      def ready
        @connected = true
        user('guest', '0', @realname)
        trigger(:connect)
      end

      # @private
      def unbind
        trigger(:disconnect)
      end
    end
  end
end