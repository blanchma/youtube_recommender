class Event < ActiveRecord::Base
  set_inheritance_column 'event_type'
  attr_accessor :message
  
  belongs_to :from, :class_name => 'User', :foreign_key => 'from_mtv_id'
  belongs_to :to, :class_name => 'User', :foreign_key => 'to_mtv_id'

  def as_json(options={})
    extra_methods = [
    :message ]
    json_object = super
    extra_methods.each {|m| json_object[m] = send(m)}

    json_object
  end
  
  after_save :do_something
  
  def do_something
      if self.new_record?
          puts "new record"
      else
          puts "not so new"
      end
      
  end
end

