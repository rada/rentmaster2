class Note < ActiveRecord::Base
  validates_presence_of :type_id, :type, :content
  
end
