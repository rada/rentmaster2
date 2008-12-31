class AccommodationHistory < ActiveRecord::Base
  belongs_to :renter
  belongs_to :property
end
