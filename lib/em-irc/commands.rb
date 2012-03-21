module EventMachine
  module IRC
    # Client commands
    # See [RFC 2812](http://tools.ietf.org/html/rfc2812)
    module Commands
      # 3.1.1 Password message
      #
      # The PASS command is used to set a ’connection password’.  The
      # optional password can and MUST be set before any attempt to register
      # the connection is made.  Currently this requires that user send a
      # PASS command before sending the NICK/USER combination.
      def pass(password)
        send_data("PASS #{password}")
      end

      # @return [String] nick if no param
      # @return nil otherwise
      def nick(nick = nil)
        if nick
          send_data("NICK #{nick}")
        else
          @nick
        end
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
    end
  end
end