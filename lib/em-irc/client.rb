module EventMachine
  module IRC
    class Client
      # EventMachine::Connection object to IRC server
      # @private
      attr_accessor :conn

      # IRC server to connect to. Defaults to 127.0.0.1:6667
      attr_accessor :host, :port

      attr_accessor :nick
      attr_accessor :realname
      attr_accessor :ssl

      # Custom logger
      attr_accessor :logger

      # Set of channels that this client is connected to
      # @private
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
      # @option options [String] :nick
      # @option options [String] :realname
      #
      # @yield [client] new instance for decoration
      def initialize(options = {}, &blk)
        options.symbolize_keys!
        options = {
          host:     '127.0.0.1',
          port:     '6667',
          ssl:      false,
          realname: 'Anonymous Annie',
          nick:     "guest-#{Time.now.to_i % 1000}"
        }.merge!(options)

        @host      = options[:host]
        @port      = options[:port]
        @ssl       = options[:ssl]
        @realname  = options[:realname]
        @nick      = options[:nick]
        @channels  = Set.new
        @callbacks = Hash.new
        @connected = false
        yield self if block_given?
      end

      # Creates a Eventmachine TCP connection with :host and :port. It should be called
      # after callbacks are registered.
      # @see #on
      # @return [EventMachine::Connection]
      def connect
        self.conn ||= EventMachine::connect(@host, @port, Dispatcher, parent: self)
      end

      # @return [Boolean]
      def connected?
        @connected
      end

      # Callbacks

      # Register a callback with :name as one of the following, and
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
      def trigger(name, *args)
        # TODO: should this be instance_eval(&blk)? prevents it from non-dsl style
        (@callbacks[name.to_sym] || []).each {|blk| blk.call(*args)}
      end

      # Sends raw message to IRC server. Assumes message is correctly formatted
      # TODO: what if connect fails? or disconnects?
      def send_data(message)
        return false unless connected?
        message = message + "\r\n"
        log Logger::DEBUG, message
        self.conn.send_data(message)
      end

      # Client commands
      # See [RFC 2812](http://tools.ietf.org/html/rfc2812)
      def renick(nick)
        send_data("NICK #{nick}")
      end

      def user(username, mode, realname)
        send_data("USER #{username} #{mode} * :#{realname}")
      end

      def join(channel_name, channel_key = nil)
        send_data("JOIN #{channel_name} #{channel_key}".strip)
      end

      def pong(servername)
        send_data("PONG :#{servername}")
      end

      # @param target [String] nick or channel name
      # @param message [String]
      def privmsg(target, message)
        send_data("PRIVMSG #{target} :#{message}")
      end
      alias_method :message, :privmsg

      def quit(message = 'leaving')
        send_data("QUIT :#{message}")
      end

      # @return [Hash] h
      # @option h [String] :prefix
      # @option h [String] :command
      # @option h [Array] :params
      # @private
      def parse_message(message)
        # TODO: error handling
        result = {}
        parts = message.split(' ')
        result[:prefix] = parts.shift.gsub(/^:/, '') if parts[0] =~ /^:/
        result[:command] = parts[0]  # cleanup?
        result[:params] = parts.slice(1..-1).map {|s| s.gsub(/^:/, '')}
        result
      end

      def handle_parsed_message(m)
        case m[:command]
        when '001' # welcome message
        when 'PING'
          pong(m[:params].first)
          trigger(:ping, *m[:params])
        when 'PRIVMSG'
          trigger(:message, m[:prefix], m[:params].first, m[:params].slice(1..-1).join(' '))
        when 'QUIT'
        when 'JOIN'
          trigger(:join, m[:prefix], m[:params].first)
        else
          # noop
          # {:prefix=>"irc.the.net", :command=>"433", :params=>["*", "one", "Nickname", "already", "in", "use", "irc.the.net", "451", "*", "Connection", "not", "registered"]}
          # {:prefix=>"irc.the.net", :command=>"432", :params=>["*", "one_1328243723", "Erroneous", "nickname"]}
        end
        trigger(:raw, m)
      end

      # EventMachine Callbacks
      def receive_data(data)
        data.split("\r\n").each do |message|
          parsed = parse_message(message)
          handle_parsed_message(parsed)
        end
      end

      # @private
      def ready
        @connected = true
        renick(@nick)
        user(@nick, '0', @realname)
        trigger(:connect)
      end

      # @private
      def unbind
        trigger(:disconnect)
      end

      def log(*args)
        @logger.log(*args) if @logger
      end

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
    end
  end
end