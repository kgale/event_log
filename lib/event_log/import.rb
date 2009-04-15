class EventLog::Import

  FLUSH_INTERVAL = 300
  FLUSH_ITEMS    = 5000

  attr_accessor :ignore_flush_interval

  def initialize
    @buffer = {}
    @last_flush = Time.now
  end

  def buffered_insert(data)
    return unless event = data.delete(:event)
    event = event.to_sym
    @buffer[event] ||= []
    @buffer[event] << data

    if (
      ( @buffer[event].size >= FLUSH_ITEMS ) ||
      ( !@ignore_flush_interval && Time.now - @last_flush >= FLUSH_INTERVAL )
    )
      flush_buffers
    end
  end
  
  def flush_buffers
    @last_flush = Time.now
    @buffer.keys.each do |event|
      flush(event)
    end
  end
  
  def flush(event)
    m = event_model(event) or return false
    m.import_hashes(@buffer[event])
    @buffer[event] = []
  end

  def event_model(event)
    EventLog::Events[event]
  end
  
  def connection
    @db ||= ActiveRecord::Base.connection
  end
  
  def import_from_queue(queue)
    while true do
      buffered_insert(queue.dequeue)
    end
  end
  
  def import_from_file(file)
    if file.is_a?(String)
      file = File.open(file)
    end
  
    while line = file.gets
      line.chomp!
      next unless line.match(/\A\s*EventLog \[[^\]]*\] (.*)/)
      line = $1
      data = Hash[*line.split('|').collect { |pair| k, v = pair.split(':', 2); [  k.to_sym, v ] }.flatten]
      buffered_insert(data)
    end

    flush_buffers
  end
  
end
