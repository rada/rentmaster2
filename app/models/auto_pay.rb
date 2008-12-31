class AutoPay < ActiveRecord::Base
  
  validates_presence_of :object, :category, :price, :repeat, :property
  validates_numericality_of :price, :repeat

  belongs_to :property
  belongs_to :renter
  has_many   :precepts
  has_many   :rents
  
  # MEthod will fetch all autopays defined by user
  # and for each one will generate bills for the next
  # month
  def self.generate(user_id, generation_end_date = nil) 
    autopays_to_generate_from = User.get_autopays(user_id)
    if ((!generation_end_date) || (!generation_end_date.is_a?(Integer)))
      last_day_of_actual_month = MyDate::Month[Time.now.mon][:days]
      generation_end_date = Time.utc(Time.now.year, Time.now.mon, last_day_of_actual_month)
    else
      generation_end_date = Time.at(generation_end_date)
    end
    generated_bills = []
    for autopay in autopays_to_generate_from do
      generated_bills += autopay.generate_bills(generation_end_date)
    end
    
    return generated_bills
  end
  
  # MEthod for generating bills from one spefific
  # autopay
  def generate_bills(generation_end_date)
    if generation_end_date.is_a?(Integer)
      generation_end_date = Time.at(generation_end_date)
    end
    if generation_end_date.is_a?(Time)
      generated_bills = []
      last_pay = Time.at(self.last_pay)
        while (((last_pay + self.repeat.days) <= generation_end_date) && 
               ((last_pay + self.repeat.days) <= self.get_end_date)) do
          last_pay += self.repeat.days
          bill = self.to_bill
          bill.deadline = last_pay
          generated_bills << bill if bill.save        
          if (self.is_for_rent && self.get_actual_rent.has_penalty)
            bill.add_penalty(self.get_actual_rent.penalty.id)
          end
        end
      self.update_attributes(:last_pay => last_pay)
      
      return generated_bills
    else
      return []
    end
  end
  
  # Method is used to generate first bill
  def generate_first_bill(penalty_id = nil)
    if self.last_pay <= MyDate.today
      first_autopay_bill = self.to_bill
      first_autopay_bill.deadline = self.last_pay
      first_autopay_bill.save
      first_autopay_bill.add_penalty(penalty_id) if penalty_id
    end
  end
  
  # This method will set date after which autopay should
  # stop generating bills.
  def stop_generating(date)
    self.update_attributes({:end_pay => date})
  end
  
  # This method checks if given autopay
  # is generating bills for rent
  def is_for_rent
    if self.rents.size > 0
      return true
    else
      return false
    end
  end
  
  # When autopay is for generating rent this method
  # will return the actual rent. Autopay can have 
  # mulitiple rents because user can change it and
  # autopay is updated.
  def get_actual_rent
    return self.rents.last
  end
  
  # Creates AutoPay for rent when logged user creates new renter and wants to
  # immediately creates AutoPay but not all required fields for autopay
  # are displayed. This method fills them with default values according
  # to actual date and new renter.
  def self.rent_for_new_renter(params, renter)
    autopay = AutoPay.new({:renter_id =>    renter.id,
                           :property_id =>  renter.property_id,
                           :object =>       params[:auto_pay][:object],
                           :price =>        params[:rent][:price],
                           :category =>     "in",
                           :groupp =>       "najem",
                           :last_pay =>     MyDate::date_from_date_select(params[:first], ""),
                           :end_pay =>      nil,
                           :repeat =>       params[:times].to_i * params[:period].to_i,
                           :added =>        Time.now.to_i})
    return autopay
  end
  
  # Returns date after which autopay should stop
  # generating bills.
  def get_end_date
    if ((!self.end_pay) || (self.end_pay == 0))
      return Time.at(MyDate::MAX_DATE)
    else
      return Time.at(self.end_pay)
    end
  end
  
  # This method get and parse attributes frin form 
  # for creating new autopay.
  def self.get_params_from(params, logged_admin_id)
    return false if !params
    pay_date = {}
    for date in ['first', 'end'] do
      day = params[date]["(3i)"]
      month = params[date]["(2i)"]
      year = params[date]["(1i)"]
      pay_date[date] = Time.utc(year,month,day).to_i
    end
    params[:auto_pay][:last_pay] = pay_date['first']
    params[:auto_pay][:end_pay] = pay_date['end']
    params[:auto_pay][:repeat] = params[:times].to_i * params[:period].to_i
    params[:auto_pay][:added] = Time.now.to_i
    if params[:auto_pay][:renter_id] != ''
      renter = Renter.find(params[:auto_pay][:renter_id])
      if renter.property.belongs_to_user(logged_admin_id)
        params[:auto_pay][:property_id] = renter.property.id
        return params[:auto_pay]
      end
    elsif params[:auto_pay][:property_id] != ''
      params[:auto_pay][:renter_id] = 0
      return params[:auto_pay]
    end
  end
  
  # MEthod will get all bills which were generated from
  # given autopay
  def get_generated_bills(from_date = 0)
    return Bill.find(:all, :conditions => ["object =? AND deadline >= ?", self.object, from_date], :order => "deadline ASC")
  end
  
  # Returns either name of property or renter according to
  # which it was assgined. Autopay generated bills either
  # for renter or property.
  def assigned_to
    if ((self.renter_id) && (self.renter_id != 0))
      return "#{self.renter.full_name}(#{self.property.name})"
    else
      return self.property.name
    end
  end
  
  def belongs_to_user(user_id)
    if self.property.user_id == user_id
      return true
    else
      return false
    end
  end
  
  # Deletes given autopay
  def destroy
    autopay_is_for_rent = self.rents.size > 0
    if autopay_is_for_rent
      self.rents.each{|rent| rent.update_attributes({:auto_pay_id => 0})}
    end
    super
  end
  
  # MEthod generates one bill from autopay
  def to_bill
    attrs = self.attributes
    attrs.delete('end_pay')
    attrs['deadline'] = (Time.at(attrs['last_pay']) + attrs['repeat'].days).to_i
    attrs['paid'] = 0
    attrs.delete('id')
    attrs.delete('last_pay')
    attrs['added'] = Time.now.to_i
    bill = Bill.new(attrs)
    return bill
  end
  
  # This method will return if given autopay is still
  # generating bills or it has already reached date
  # when the generation ended
  def is_active
    todays_end_time = Time.utc(Time.now.year, Time.now.month, Time.now.day, 23, 59, 59).to_i
    if (!self.end_pay || (self.end_pay > todays_end_time) || (self.end_pay == 0))
      return true
    else
      return false
    end
  end
  
end
