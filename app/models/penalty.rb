class Penalty < ActiveRecord::Base
  
#  has_many :auto_pays
  has_one  :user
  has_many  :rent
  has_many :added_penalties
  has_many :bills, :through => :added_penalties
  
  validates_presence_of :name, :price
  validates_numericality_of :price, :after
  
  def asociated_with(delimiter = ", ")
    names = []
    for auto in self.auto_pays
      names << auto.name
    end
    return names.join(delimiter)
  end
  
  def belongs_to_user(logged_user_id)
    if self.user_id == logged_user_id
      return true
    else
      return false
    end
  end
  
end
