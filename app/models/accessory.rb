class Accessory < ActiveRecord::Base
  
  belongs_to :property
  
  # Counts total price from accessoriy's attributes
  def price_total
    if (self.count > 0)
      return self.price_with_tax * self.count
    else
      return self.price_with_tax
    end
  end
  
  def price_with_tax
    return ((self.base + self.tarif)*( 1 + (self.tax/100) ))
  end
  
  def belongs_to_user(logged_admin_id)
    if self.property.belongs_to_user(logged_admin_id)
      return true
    else
      return false
    end
  end
  
end
