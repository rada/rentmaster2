class Fitting < ActiveRecord::Base
  belongs_to :property
  
  validates_presence_of :name, :price
  
  def belongs_to_user(logged_user_id)
    if self.property.belongs_to_user(logged_user_id)
      return true
    else
      return false
    end
  end
end
