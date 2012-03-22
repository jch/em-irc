module EventMachine
  module IRC
    # Client commands
    # See {http://tools.ietf.org/html/rfc2812 RFC 2812}
    module Commands
      # Set connection password
      # @see http://tools.ietf.org/html/rfc2812#section-3.1.1 3.1.1 Password message
      def pass(password)
        send_data("PASS #{password}")
      end

      # Set/get user nick
      # @return [String] nick if no param
      # @return nil otherwise
      # @see http://tools.ietf.org/html/rfc2812#section-3.1.2 3.1.2 Nick Message
      def nick(nick = nil)
        if nick
          send_data("NICK #{nick}")
        else
          @nick
        end
      end

      # Set username, hostname, and realname
      # @see http://tools.ietf.org/html/rfc2812#section-3.1.3 3.1.3 User Message
      def user(username, mode, realname)
        send_data("USER #{username} #{mode} * :#{realname}")
      end

      # Gain operator privledges
      # @see http://tools.ietf.org/html/rfc2812#section-3.1.4 3.1.4 Oper Message
      def oper(name, password)
        send_data("OPER #{name} #{password}")
      end

      # Set user mode
      # @see http://tools.ietf.org/html/rfc2812#section-3.1.5 3.1.5 Mode Message
      def mode(nickname, setting)
        raise NotImplementedError.new
      end

      # Register a new service
      # @see http://tools.ietf.org/html/rfc2812#section-3.1.6 3.1.6 Service Message
      def service(nickname, reserved, distribution, type)
      end

      # Terminate connection
      # @see http://tools.ietf.org/html/rfc2812#section-3.1.7 3.1.7 Quit
      def quit(message = 'leaving')
        send_data("QUIT :#{message}")
      end

      # Disconnect server links
      # @see http://tools.ietf.org/html/rfc2812#section-3.1.8 3.1.8 Squit
      def squit(server, message = "quiting")
        raise NotImplementedError.new
      end

      # Join a channel
      # @see http://tools.ietf.org/html/rfc2812#section-3.2.1 3.2.1 Join message
      # @example
      #   client.join("#general")
      #   client.join("#general", "fubar")  # join #general with fubar key
      #   client.join(['#general', 'fubar'], "#foo")  # join multiple channels
      def join(*args)
        raise ArgumentError.new("Not enough arguments") unless args.size > 0
        channels, keys = [], []
        args.map!  {|arg| arg.is_a?(Array) ? arg : [arg, '']}
        args.sort! {|a,b| b[1].length <=> a[1].length}  # key channels first
        args.each  {|arg|
          channels << arg[0]
          keys     << arg[1] if arg[1].length > 0
        }
        send_data("JOIN #{channels.join(',')} #{keys.join(',')}".strip)
      end

      # Part all channels
      def part_all
        join('0')
      end

      # Leave a channel
      # @see http://tools.ietf.org/html/rfc2812#section-3.2.2 3.2.2 Part message
      # @example
      #   client.part('#general')
      #   client.part('#general', '#foo')
      #   client.part('#general', 'Bye all!')
      #   client.part('#general', '#foo', 'Bye all!')
      def part(*args)
        raise ArgumentError.new("Not enough arguments") unless args.size > 0
        message = %(# &).include?(args.last[0]) ? "Leaving..." : args.pop
        send_data("PART #{args.join(',')} :#{message}")
      end

      # Set channel mode
      # @todo name conflict with user MODE message
      def channel_mode
        raise NotImplementedError.new
      end

      # Set/get topic
      # @param topic [Mixed] String, nil
      #   non-blank string sets the topic
      #   blank string unsets the topic
      #   nil returns the current topic (default)
      # @see http://tools.ietf.org/html/rfc2812#section-3.2.4 3.2.4 Topic message
      def topic(channel, message = nil)
        message = message.nil? ? "" : ":#{message}"
        send_data("TOPIC #{channel} #{message}".strip)
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

    end
  end
end