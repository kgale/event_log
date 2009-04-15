#!/usr/bin/ruby

require '/Users/kgale/workfeed/vendor/gems/event_log/lib/event_log.rb'
require 'pp'
RAILS_ROOT = '/Users/kgale/workfeed'
require "#{RAILS_ROOT}/config/environment.rb"
require 'ar-extensions/import'

def buffered_insert(event, data)
  @buffer ||= {}
  @buffer[event] ||= []
  @buffer[event] << data
  flush(event) if @buffer[event].size >= 100
end

def flush_buffers
  @buffer.keys.each do |event|
    flush(event)
  end
end

def flush(event)
  puts "Flushing #{event} to db [size: #{@buffer[event].size}]"
  EventLog::Events[event].import_hashes(@buffer[event])
  @buffer[event] = []
end

def connection
  @db ||= ActiveRecord::Base.connection
end

EventLog::Events
File.open('../samples/poll.log') do |file|

  while line = file.gets
    line.chomp!
    data = Hash[*line.split('|').collect { |pair| k, v = pair.split(':', 2); [  k, v ] }.flatten]
    next unless event = data.delete('event').to_sym
    buffered_insert(event, data)
  end

  flush_buffers

end

