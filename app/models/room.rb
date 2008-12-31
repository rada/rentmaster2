class Room < ActiveRecord::Base  
  
  has_many :room_areas
  has_many :properties, :through => :room_areas
  
  validates_uniqueness_of :name
  
end
