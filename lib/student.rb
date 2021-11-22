require_relative "../config/environment.rb"
require 'interactive_record.rb'

class Student < InteractiveRecord


    self.column_names.each do |col_name|
        attr_accessor col_name.to_sym
      end
end
