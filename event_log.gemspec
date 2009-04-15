Gem::Specification.new do |spec|
  spec.name         = "event_log"
  spec.version      = "1.0.0"
  spec.summary      = "Flexible event logging.  Uses a message queue for asynchronous database inserts."
  spec.author       = "Kris Gale"
  spec.email        = "kgale@yammer-inc.com"
  spec.has_rdoc     = false
  spec.homepage     = "http://github.com/kgale/event_log"
  spec.require_path = "lib"
  spec.files        = [ 
    "lib/event_log",    "lib/event_log/events.rb", "lib/event_log/import.rb",
    "lib/event_log.rb", "script/import.rb",        "test/test_event_log.rb",
    "test/test_event_log_import.rb",               "test/test_helper.rb"
  ]
end
