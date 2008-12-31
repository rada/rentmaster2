class RoomArea < ActiveRecord::Base
  
  validates_numericality_of :total, :chargable, :UT, :TUV, :room_id
  
  belongs_to :property
  belongs_to :room
  
  def belongs_to_user(logged_user_id)
    if self.property.belongs_to_user(logged_user_id)
      return true
    else
      return false
    end
  end
end
