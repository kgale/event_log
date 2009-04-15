require File.dirname(__FILE__) + '/test_helper'
require 'pp'

class EventLog::Event
  class Dummy
    def import_hashes(*args)
      return true
    end
  end
end

class EventLogImportTest < Test::Unit::TestCase
  
  def setup_test

    @dummy    = EventLog::Event::Dummy.new
    @importer = EventLog::Import.new
    @importer.stubs(:event_model).with(:foo).returns(@dummy)
  end

  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  test "buffered insert" do
    setup_test
    buffer = @importer.instance_variable_get(:@buffer)
    @importer.buffered_insert(:event => "foo", :thing => "one")
    @importer.buffered_insert(:event => "foo", :thing => "two")
    @importer.buffered_insert(:event => "foo", :thing => "three")
    assert_equal 3,       buffer[:foo].size
    assert_equal "one",   buffer[:foo][0][:thing]
    assert_equal "three", buffer[:foo][2][:thing] 
  end

  test "flush buffers" do
    setup_test
    @dummy.expects(:import_hashes).once
    @importer.buffered_insert(:event => "foo", :thing => "one")
    @importer.flush_buffers
  end

  test "flush buffers after n entries" do
    setup_test
    @dummy.expects(:import_hashes).once
    EventLog::Import::FLUSH_ITEMS.times do |num|
      @importer.buffered_insert(:event => "foo", :thing => num.to_s)
    end
  end

  test "flush buffers after n seconds" do
    setup_test
    @dummy.expects(:import_hashes).once
    silence_warnings do
      EventLog::Import::FLUSH_INTERVAL = 2
    end
    @importer.buffered_insert(:event => "foo", :thing => "one")
    sleep EventLog::Import::FLUSH_INTERVAL
    @importer.buffered_insert(:event => "foo", :thing => "two")
  end
  
end
