require 'MyDate'
class Renter < ActiveRecord::Base
  
  before_destroy  :delete_image_directory
  belongs_to      :property
  has_many        :accommodation_histories, :dependent => :destroy
  has_many        :additionals, :foreign_key => "type_id", :conditions => ["owner = ?", :renter], :dependent => :destroy
  has_one         :user, :dependent => :destroy
  has_many        :messages, :foreign_key => 'from_id', :dependent => :destroy
  has_many        :bills, :dependent => :destroy
  has_many        :auto_pays, :dependent => :destroy
  has_many        :rents, :order => "from_date", :dependent => :destroy
#  has_one         :actual_rent, :class_name => 'Rent', :order => "from_date DESC"
  
  validates_presence_of :name, :surname, :email, :telephone, :property
  validates_numericality_of :telephone
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                      :message => LocalizeHelper::get_string(:Invalid_email)
  
  attr_reader   :debit, :unpaid_bills
  
  # Deletes pisctures of renter from filssystem
  # This method is used when deleting renter
  def rmtree(directory)
    Dir.foreach(directory) do |entry|
      next if entry =~ /^\.\.?$/  # ignore . and .. as usual
      path = directory + "/" + entry
      if FileTest.directory?(path)
        rmtree(path)
      else
        File.delete(path)
      end
    end
    Dir.delete(directory)
  end
  
  def delete_image_directory
    image_dir = "#{RAILS_ROOT}/public/images/renters/#{self.id}"
    if File.exists?(image_dir)
      begin
        rmtree(image_dir)
        rescue
      end
    end
  end
  
  def calculate_debit
    @debit = {}
    @debit[:amount] = 0
    @debit[:deadline] = MyDate::MAX_DATE
    late_bills = Bill.find(:all, :conditions => ["deadline < ? AND paid = ? AND renter_id = ?", MyDate.today, 0, self.id])
    for bill in late_bills
      @debit[:amount] += bill.price
      @debit[:deadline] = bill.deadline if bill.deadline < @debit[:deadline]
    end
    @debit[:deadline] = 0 if @debit[:deadline] == MyDate::MAX_DATE
    debit_days_in_seconds = MyDate.today - @debit[:deadline]
    @debit[:days] = MyDate.seconds_to_days(debit_days_in_seconds)
  end
  
  def get_additionals
    return Additional.find(:all, :conditions => ["type_id = ? AND owner = ?", self.id, 'renter'])
  end
  
  # Return true if renter has reported renters during
  # his accommodation in property
  def has_reported_renters
    if self.get_reported_renters.size > 0
      return true
    else
      return false
    end
  end
  
  def get_reported_renters
    return Renter.find(:all, :conditions => ["reported_by IS NOT NULL AND id != reported_by"])
  end
  
  # Returns price of actual rent
  def rent
    if self.actual_rent
      return self.actual_rent.price
    else
      return 0
    end
  end
  
  # REturns instance of <code>Rent</code> class
  # representing actual rent
  def actual_rent
    self.rents.reverse.each{|rent| 
      if rent.from_date >= Time.now.to_i
        next
      else
        return rent
      end
    }
    return false
  end
  
  def create_new_rent(params, date_from)
    params[:rent][:typ] = :simple unless params[:rent][:typ]
    new_rent = Rent.new({ :renter_id    => self.id,
                          :property_id  => self.property.id,
                          :price        => params[:rent][:price],
                          :from_date    => date_from,
                          :typ          => params[:rent][:typ]})
    if (params[:penalty_id] && (params[:penalty_id] != ''))
      penalty = Penalty.find(params[:penalty_id])
      if penalty.belongs_to_user(self.property.user_id)
        new_rent.add_penalty(penalty.id)
      end
    end
    return new_rent
  end
  
  # MEthod creates new autopay which will be
  # used to generate bills for rent.
  def new_autopay_rent(price, from_date)
    new_auto_pay_rent = AutoPay.new({:renter_id   => self.id,
                                    :property_id  => self.property.id,
                                    :object       => self.actual_rent.auto_pay.object,
                                    :price        => price,
                                    :category     => "in",
                                    :groupp       => "najem",
                                    :last_pay     => from_date,
                                    :repeat       => self.actual_rent.auto_pay.repeat,
                                    :added        => Time.now.to_i}) 
    new_auto_pay_rent.save
    return new_auto_pay_rent
  end
  
  def update_rent(rent, from_date, new_autopay_rent)
    new_rent = self.actual_rent.clone
    new_rent.price = rent[:price]
    new_rent.from_date = from_date
    new_rent.note = rent[:note]
    if from_date > MyDate::today
      new_rent.auto_pay_id = new_auto_pay_rent.id
    end
    return new_rent
  end
  
  # Method moves renter to another property. It is
  # used when closing property in which renter is
  # actually accommodated.
  def move_to_property(property_id, logged_user_id)
    property = Property.find(property_id)
    if (property.belongs_to_user(logged_user_id) && 
       (self.property_id != property_id) && !property.is_closed )
      self.new_accommodation(property_id)
      self.update_autopays
    else
      return false
    end
  end
  
  # This method is used to create and report 
  # new renter in property
  def self.new_reported(params, reported_by_user, dates)
    renter = Renter.new(params)
    reported_by_renter = User.find(reported_by_user).renter
    renter.property_id = reported_by_renter.property_id
    renter.reported_by = reported_by_renter.id
    if reported_by_renter.has_autopay_rent
      renter.autopay_rent_id = reported_by_renter.get_autopay_rent.id
    end
    if renter.save
      accommodation_dates = MyDate.get_dates(dates, :start, :end)
      renter.new_accommodation(renter.property_id, accommodation_dates)
      return true
    else
      return false
    end
  end
  
  # This method is used to create record in DB
  # of renters accommodation. It is the used to
  # display history of renters accommodations.
  def new_accommodation(new_property_id, dates = nil)
    if dates
      end_date_old_property = dates[:to]
      start_day = dates[:from]
    else
      end_date_old_property = self.end_date
      self.end_date = start_day = Time.now
    end
    self.update_attributes({:property_id => new_property_id})
    accommodation = AccommodationHistory.new({:renter_id    => self.id,
                                              :property_id  => new_property_id,
                                              :from         => start_day,
                                              :to           => end_date_old_property})
    accommodation.save
  end

  # Updated autopays when renter was moved
  # to new property
  def update_autopays
    self.auto_pays.each{|autopay|
      if autopay.is_active
        autopay.update_attributes({:property_id => self.property_id})
      end
    }
  end
  
  # This method is used to update renter atrributes
  # and to create new accommodation history record
  # when renter has moved to new property
  def update_attrs(parameters, date, picture)
    self.update_attributes(parameters)
    self.actual_accommodation.update_attributes(date) if date
    if picture
      picture[:id] = self.id
      if picture[:file] != ""
        picture[:upload_status] = self.save_picture(picture)
      end
    end
    return true
  end
  
  # This method is used to return infos about attributes
  # which has renter updated. This methods return is then
  # sent as a message for property user.
  def show_updates(params)
    message_with_updates = "#{self.full_name} #{LocalizeHelper::get_string(:has_updated_his_personal_information)}:\n"
    for attribute in [:name, :surname, :email, :telephone, :address, :city, :psc] do
      if self.get_attribute(attribute).to_s != params[attribute]
        message_with_updates += "#{self.get_attribute(attribute)} \t-> #{params[attribute]}\n"
      end
    end
    return message_with_updates
  end
  
  def get_attribute(attribute_name)
    case attribute_name
    when :name
      return self.name
    when :surname
      return self.surname
    when :email
      return self.email
    when :telephone
      return self.telephone
    when :address
      return self.address
    when :city
      return self.city
    when :psc
      return self.psc
    end      
  end
  
  def save_picture(picture)
    picture = Picture.new(picture[:id], picture[:file])
    if picture.save
      return LocalizeHelper::get_string(:Picture_succesfully_uploaded)
    else
      if Renter.find(picture[:id]).image_square != nil
        return ""
      else
        if picture[:file].class == StringIO
          return LocalizeHelper::get_string(:no_picture_selected)
        else
          return LocalizeHelper::get_string(:not_a_valid_Jpeg_Gif_or_Png_file)
        end
      end
    end
  end
  
  # Returns the record of actual accmmodation
  def actual_accommodation
    return self.accommodation_histories.last
  end
  
  def close_rent
    self.auto_pays.each{|autopay| autopay.stop_generating(Time.today)}
    self.update_attributes({:rent_closed => Time.today})
    self.actual_accommodation.update_attributes({:to => Time.today })   
  end
  
  # Returns true id renter has closed rent
  def has_closed_rent
    if ((self.rent_closed) && (self.rent_closed != 0))
      if Time.at(rent_closed) <= Time.now
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  # Returns the date when renters' rent in property expires or when 
  # it started according to the <code>date_name</code> parameter.
  def date(date_name)
    case date_name
    when :start
      return self.accommodation_histories.last.from
    when :end
      return self.accommodation_histories.last.to
    else
      return 0
    end
  end
  
  def start_date
    return self.date(:start)
  end
  
  def end_date
    return self.accommodation_histories.last.to
  end
  
  def end_date=(time_in_seconds)
    self.accommodation_histories.last.update_attributes({:to => time_in_seconds})
  end
  
  # Method creates new autopay for renters rent
  def create_autopay_rent(autopay_params, penalties)
    first_pay = MyDate::date_from_date_select(autopay_params, "first_pay")
    autopay_rent = AutoPay.new({:renter_id => self.id,
                                :property_id => self.property.id,
                                :object => autopay_params["object"],
                                :price => autopay_params["price"],
                                :category => "in",
                                :groupp => "najem",
                                :last_pay => first_pay,
                                :repeat => autopay_params["repeat"],
                                :added => Time.now.to_i})
    autopay_rent.save
    if autopay_rent.save
      autopay_rent.generate_first_bill(autopay_params[:rent_penalty])
      end_of_month = Time.utc(Time.now.year,Time.now.month,MyDate::Month[Time.now.month][:days])
      autopay_rent.generate_bills(end_of_month)
      self.actual_rent.update_attributes({:auto_pay_id => autopay_rent.id,
                                          :penalty_id  => autopay_params[:rent_penalty]})
      return true
    else
      return false
    end
  end
  
  # Method checks if renter has AutoPay object for generating rent bills
  def has_autopay_rent
    if ((self.actual_rent) && (self.actual_rent.has_autopay))
      return true
    else
      return false
    end
  end
  
  def get_autopay_rent
    if self.has_autopay_rent
      return self.actual_rent.auto_pay
    end
  end
  
  def get_autopays
    return AutoPay.find(:all, :conditions => ["renter_id = ?", self.id])
  end
  
  # Class method returns renters who
  # have unpaid bills and deadline for
  # payign for them has already passed
  def self.get_debit_renters(user_id)
    renters = User.get_renters(user_id)
    debit_renters = []
    for renter in renters
      renter.calculate_debit
      debit_renters << renter if renter.debit[:amount] > 0
    end
    return debit_renters
  end
  
  # Method calculates income of renter for given month
  # It is used by the statistics controller
  def calculate_income(month_number, year, income_type = nil)
    income = Bill.calculate_income_for(:renter, month_number, year, self.id)
    case income_type
    when :expected
      return income[:expected]
    when :real
      return income[:real]
    when :net
      return income[:net]
    when nil
      return income
    else
      return "###"
    end
  end
  
  def get_total_income
    income = {}
    income[:expected] = 0
    income[:real] = 0
    self.bills.each{|bill| 
      if (bill.category == "in")
        income[:expected] += bill.price
        income[:real] += bill.price #if bill.paid > 0
      end
    }
    return income
  end
  
  def get_total_outcome
    outcome = {}
    outcome[:expected] = 0
    outcome[:real] = 0
    self.bills.each{|bill| 
      if (bill.category == "out")
        outcome[:expected] += bill.price
        outcome[:real] += bill.price if bill.paid > 0
      end
    }
    return outcome
  end
  
  def calculate_outcome(month_number, year, income_type = nil)
    outcome = Bill.calculate_outcome_for(:renter, month_number, year, self.id)
    case income_type
    when :expected
      return outcome[:expected]
    when :real
      return outcome[:real]
    when nil
      return outcome
    else
      return "###"
    end
  end
  
  def get_unpaid_bills
    @unpaid_bills = []
    self.bills.each{|bill|
      bill.paid == 0 ? @unpaid_bills << bill : next
    }
    return @unpaid_bills
  end
  
  # Returns true id renter has unpaid bills
  def has_unpaid_bills
    return self.get_unpaid_bills.size > 0
  end
  
  def get_all_bills(bills_params, page_number)
    return Bill.get_all_bills_for(:renter, self.id, bills_params, page_number)
  end
  
  def get_debit_bills
    return Bill.find(:all,
                     :conditions => ["paid = ? AND renter_id = ? AND deadline < ?", 0, self.id, MyDate.today() ],
                     :order => 'deadline')
  end
  
  def get_pending_bills(bills_params, page_number)
    return Bill.get_pending_bills_for(:renter, self.id, bills_params, page_number)
  end
  
  def get_paid_bills(bills_params, page_number)
    return Bill.get_paid_bills_for(:renter, self.id, bills_params, page_number)
  end
  
  def get_bills_for_month(bills_params, page_number)
    bills2 = Bill.get_all_bills_for(:renter, self.id, bills_params, page_number)
    return bills2
  end
  
  # Method returns renter whose rent will end in next
  # <code>days_before_rent_ends</code> days
  def self.with_ending_rent(user_id, days_before_rent_ends)
    all_renters = User.get_renters(user_id)
    date_when_rent_ends = (Time.now + days_before_rent_ends.days).to_i
    renters_with_ending_rent = []
    all_renters.each{|renter| renters_with_ending_rent << renter if (renter.end_date <= date_when_rent_ends &&
                                                                     renter.end_date != 0 &&
                                                                     !renter.has_closed_rent)}
    renters_with_ending_rent.sort{|renter1, renter2| renter1.end_date <=> renter2.end_date }
    return renters_with_ending_rent
  end
  
  def full_name
    return "#{self.surname} #{self.name}" if self.name && self.surname
  end
  
  def full_name2
    return "#{self.surname} #{self.name} (#{self.property.name})"
  end
  
  def contact_address
    return  self.address + self.psc.to_s + ", " + self.city
  end
  
  # Returns login of given renter if defined
  def get_login
    if ((self.user_id) && (self.user_id > 0))
      return self.user.name
    else
      return false
    end
  end
  
  # MEthod generates login name for renter
  def generate_login
    login_unique = false
    login = ("#{self.name}.#{self.surname}").downcase
    login_unique = User.find_by_name(login) == nil
    if !login_unique
      login = ("#{self.surname}.#{self.name}").downcase
      login_unique = User.find_by_name(login) == nil
    end
    i = 0
    while !login_unique do
      i += 1
      login = ("#{self.name}.#{self.surname}#{i}").downcase
      login_unique = User.find_by_name(login) == !nil
    end
    
    return login
    end
  
  def is_logged_in(logged_user_id)
    if self.user_id == logged_user_id
      return true
    else
      return false
    end
  end
  
  def belongs_to_user(logged_admin_id)
    return self.property.belongs_to_user(logged_admin_id)
  end
  
  def has_individual_rent
    return self.rent != 0
  end
 
end