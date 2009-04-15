require File.dirname(__FILE__) + '/test_helper'

class EventLogTest < Test::Unit::TestCase
  
  def setup_test
    EventLog.reset
  end

  def setup_queue
    @queue = "foo"
    class << @queue
      def enqueue(message); end
      def dequeue(message); end
    end
    EventLog.queue = @queue
  end

  test "log_event" do
    setup_test
    EventLog.log_event(:enter, { :rza => 36, :gza => 'thirty-six', :odb => :dirt })
    assert_equal EventLog.data[:event], :enter
    assert_equal EventLog.data[:rza], '36'
    assert_equal EventLog.data[:gza], 'thirty-six'
    assert_equal EventLog.data[:odb], 'dirt'
    assert       EventLog.data[:timestamp]
  end
  
  test "set_data" do
    setup_test
    EventLog.set_data( :rza => 36, :gza => 'thirty-six', :odb => :dirt )
    assert_equal EventLog.data[:rza], '36'
    assert_equal EventLog.data[:gza], 'thirty-six'
    assert_equal EventLog.data[:odb], 'dirt'
  end

  test "enqueue_event" do
    setup_test
    setup_queue 
    @queue.expects(:enqueue).returns(true).times(1)
    EventLog.log_event(:something)
  end

end
