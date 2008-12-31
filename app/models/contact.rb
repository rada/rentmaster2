class Contact < ActiveRecord::Base
  validates_presence_of :name, :profesion, :address, :telephone1
  validates_numericality_of :telephone1, :telephone2
  
  has_and_belongs_to_many :properties 
  
  def name_address
    return "#{self.name} <br/>
            #{self.address} <br/>"
  end
  
  def belongs_to_user(logged_user_id)
    if self.user_id == logged_user_id
      return true
    else
      return false
    end
  end
end
