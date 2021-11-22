require_relative "../config/environment.rb"

class InteractiveRecord

  def self.table_name
    self.to_s.downcase + 's'
  end

  def self.column_names
    table_info = DB[:conn].execute("PRAGMA table_info(#{table_name})")
    columns = []
    table_info.each do |column|
        columns << column['name']
    end
    columns.compact
  end
  def initialize(options = {})
    options.each do |property, value|
        self.send("#{property}=", value)
    end

  end
  

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col|col == 'id'}.join(", ")
  end

  def values_for_insert
    values = []
    
    self.class.column_names.each do |col|
        values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)
  end

  def self.find_by(hash)
    value = hash.values.first 
    
    formatted_value = value.to_s == value.to_f.to_s ? value : "'#{value}'"
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{hash.keys.first} = #{formatted_value}")
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
end