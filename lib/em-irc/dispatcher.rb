module EventMachine
  module IRC
    # EventMachine connection handler class that dispatches connections back to another object.
    class Dispatcher < EventMachine::Connection
      extend Forwardable
      def_delegators :@parent, :receive_data, :unbind

      def initialize(options)
        raise ArgumentError.new(":parent parameter is required for EM#connect") unless options[:parent]
        # TODO: if parent doesn't respond to a above methods, do a no-op
        @parent = options[:parent]
      end

      # @parent.conn is set back to nil when this is created
      def post_init
        @parent.conn = self
        @parent.ready unless @parent.ssl
      end

      def connection_completed
        if @parent.ssl
          start_tls
        else
          @parent.ready
        end
      end

      def ssl_handshake_completed
        @parent.ready if @parent.ssl
      end
    end
  end
end