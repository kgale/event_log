class EventLog::Events
  class << self
    @@event_models = {}
    def [](event)
      @@event_models[event]
    end
  end

  require 'ar-extensions'
  ActiveRecord::Base.connection.tables.each do |table|
    next unless table.match(/\Alogged_(.*)/)
    event = $1.singularize
    klass = Class.new(ActiveRecord::Base)
    klass.class_eval do
      acts_as_reportable
      set_table_name table
      def self.import_hashes(items)
        fields = self.columns.collect(&:name).reject { |c| c == 'id' }
        data   = []
        items.each do |item|
          data << fields.collect { |f| item[f.to_sym] }
        end
        self.import(fields, data)
      end
    end
    @@event_models[event.to_sym] = klass
  end

end

