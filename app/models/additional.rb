class Additional < ActiveRecord::Base
  
  validates_presence_of :name
  
  def belongs_to_user?(user_id)
    if self.owner == :renter
      renter = Renter.find(self.type_id)
      return true if renter.belongs_to_user(user_id)
    elsif self.owner == :property
      property = Property.find(self.type_id)
      return true if property.belongs_to_user(user_id)
    end
    return false
  end
  
  
end
