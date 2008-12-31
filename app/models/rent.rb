class Rent < ActiveRecord::Base
  belongs_to :renter
  belongs_to :property
  belongs_to :auto_pay
  belongs_to :penalty
  validates_presence_of :price
  validates_numericality_of :price
  
  # Checks if rent has an autopay
  def has_autopay
    if ((self.auto_pay) && (self.auto_pay_id > 0) && self.auto_pay.is_active)
      return true
    else
      return false
    end
  end
  
  # # Checks if rent has penalty for late pay
  def has_penalty
    if self.penalty
      return true
    else
      return false
    end
  end
  
  # MEthod adds penalty to rent. When generating bills
  # by autopay, autopay will check rent for penalty and
  # if there will be defined than it will be added to
  # generated bills.
  def add_penalty(penalty_id)
    self.penalty_id = penalty_id
  end
  
end
