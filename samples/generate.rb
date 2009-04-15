#!/usr/bin/ruby -w

require '/Users/kgale/workfeed/vendor/gems/event_log/lib/event_log.rb'

1000.times do 
  EventLog.event = :poll
  
  [ :network_id, :user_id, :new_messages ].each do |id_col|
    EventLog.set_data(id_col => rand(10).to_i)
  end
  
  type = [ 'user', 'group'][rand(2).to_i]
  EventLog.set_data(:feed_key => "feed_#{type}_id#{rand(10).to_i}")
  EventLog.set_data(:feed_type => type)
  
  puts EventLog.logline
  EventLog.reset
end
