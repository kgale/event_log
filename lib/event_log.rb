class EventLog

    require 'time'

    # event :poll,  { :new_messages => 19 }
    # event :login, { :new_messages => 19 }
    # Standard information: Timetsamp, Hostname, IP address, user ID, network ID, 

    class << self
      attr_accessor :data, :enabled, :event, :logger, :queue, :identifier

      def log_event(set_event, data={})
        @event = set_event
        set_data(data)
        do_log
      end

      def set_data(set_data={})
        @data.merge!(set_data.inject({}) { |h,(k,v)| h[k.to_sym] = v.to_s; h })
      end

      def reset
        @event   = nil
        @data    = {}
        @enabled = true
      end

      def do_log

        return unless enabled
        @logger           ||= RAILS_DEFAULT_LOGGER if defined?(RAILS_DEFAULT_LOGGER)
        @data[:timestamp] ||= Time.now.iso8601
        @data[:event    ]   = event

        if @logger
          @logger.info "EventLog [#{@identifier || event}] #{EventLog.logline}" if EventLog.event
        end

        if @queue && @queue.respond_to?(:enqueue)
          @queue.enqueue(data)
        end

      end

      def logline
        @data.collect { |k,v| [k,v].join(':') }.join('|')
      end

    end
    self.reset
end
