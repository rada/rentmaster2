require 'MyDate'

class Bill < ActiveRecord::Base
  
  belongs_to :renter
  belongs_to :property
  has_many :temp_bills
  has_many :penalty_histories, :dependent => :destroy
  has_many :added_penalties, :dependent => :destroy, :uniq => true
  has_many :penalties, :through => :added_penalties, :uniq => true
  
  validates_presence_of :renter_id, :property_id, :object, :deadline, :added, :price, :category
  validates_numericality_of :price

  Group = [
          #Displayed    Stored in db
          ["Nájem",       "najem"],
          ["Penále",     "penale"],
          ["Oprava",     "oprava"],
          ["Poplatky", "poplatky"],
          ["Záloha",     "zaloha"],
          ["Depozit",   "depozit"],
          ["Extra",       "extra"],
          ["Jiné",         "jine"]
          ]
  
  
  # Method will calculate income either for user, property
  # or renter according to parameter <code>subject</code>.
  # This method is used by statistics controller for 
  # calculating income.
  def self.calculate_income_for(subject, month_number, year, subjects_id)
    first_day_in_month = Time.utc(year, month_number, 1).to_i
    last_day_in_month = Time.utc(year, month_number, MyDate::Month[month_number][:days]).to_i
    
    bill_order = {:order_by => "deadline",
                  :order_direction => "ASC",
                  :date => {:from => first_day_in_month,
                            :to => last_day_in_month,
                            :type => 'deadline'},
                 }
    bills = Bill.get_all_bills_for(subject, subjects_id, bill_order, :all)
    real_income = 0
    expected_income = 0
    outcome = 0
    real_bill_ids = []
    expected_bill_ids = []
    bills.each{|bill|
      bill_was_paid_this_month = ((bill.paid > 0)&&(Time.at(bill.paid).mon == month_number))
      bill_is_income = (bill.category == "in")
      bill_is_outcome = (bill.category == "out")
      if (bill_is_income && bill_was_paid_this_month) 
        real_income += bill.price
        real_bill_ids << bill.id
        if bill.deadline_in(month_number)
          expected_bill_ids << bill.id
          expected_income += bill.price
        end
      elsif (bill_is_income && (bill.deadline_in(month_number)))
        expected_income += bill.price
        expected_bill_ids << bill.id
      elsif (bill_is_outcome && bill_was_paid_this_month)
        outcome += bill.price
#                  real_bill_ids << bill.id
      end
    }
    income = {}
    income[:real] = real_income
    income[:real_bills_ids] = real_bill_ids
    income[:expected] = expected_income
    income[:expected_bills_ids] = expected_bill_ids
    income[:net] = (real_income - outcome)
    
    return income
  end

  # Method will calculate outcome either for user, property
  # or renter according to parameter <code>subject</code>.
  # This method is used by statistics controller for 
  # calculating outcome.
  def self.calculate_outcome_for(subject, month_number, year, subjects_id)
    first_day_in_month = Time.utc(year, month_number, 1).to_i
    last_day_in_month = Time.utc(year, month_number, MyDate::Month[month_number][:days]).to_i
    
    bill_order = {:order_by => "deadline",
                  :order_direction => "ASC",
                  :date => {:from => first_day_in_month,
                            :to => last_day_in_month,
                            :type => 'deadline'},
                 }
    bills = Bill.get_all_bills_for(subject, subjects_id, bill_order, :all)
#    bills = Bill.select_bills_deadline_or_paid_between(first_day_in_month, last_day_in_month, bills)
    
    outcome = {}
    outcome[:expected] = 0
    outcome[:real] = 0
    outcome[:expected_count] = 0
    outcome[:real_count] = 0
    outcome[:real_bills_ids] = []
    outcome[:expected_bills_ids] = []
    bills.each{|bill|
                bill_is_outcome = bill.category == "out"
                bill_was_paid_this_month = ((bill.paid > 0) && (Time.at(bill.paid).mon == month_number))
                if (bill_is_outcome && bill_was_paid_this_month)
                  outcome[:real] += bill.price
                  outcome[:real_count] += 1
                  outcome[:real_bills_ids] << bill.id
                  if (bill_is_outcome && bill.deadline_in(month_number))
                    outcome[:expected] += bill.price
                    outcome[:expected_count] += 1
                    outcome[:expected_bills_ids] << bill.id
                  end
                end
                }
  return outcome
  end
  
  # This method calculates statistics of bills for actual month
  # and is used to display info about it by finances
  # controller on the main page.
  def self.get_stat_for(month_number, logged_user_id)
    month_bills = {}
    month_bills[:pending_bills] = Bill.get_bills_for_month(month_number, Time.now.year, logged_user_id, 'pending')
    month_bills[:pending_value] = Bill.get_value_of(month_bills[:pending_bills])
    month_bills[:bills_total] = Bill.get_bills_for_month(month_number, Time.now.year, logged_user_id, 'all')
    month_bills[:value_total] = Bill.get_value_of(month_bills[:bills_total])
    return month_bills
  end
  
  # This method calculates total statistics of bills
  # and is used to display info about it by finances
  # controller on the main page.
  def self.get_stat_total(logged_user_id)
    total_bills = {}
    total_bills[:pending_bills] = User.get_pending_bills(logged_user_id)
    total_bills[:pending_value] = Bill.get_value_of(total_bills[:pending_bills])
    total_bills[:bills_total] = User.get_bills(logged_user_id)
    total_bills[:value_total] = Bill.get_value_of(total_bills[:bills_total])
    return total_bills
  end
  
  # This method will calculates total amount of
  # bills prices for given day.
  def self.sum_for_day(day_start, logged_user_id)
    day_end = day_start + (60 * 60 * 23 + 59 *60 + 59)
    bills = User.get_bills(logged_user_id, day_start.to_i, day_end.to_i)
#    bills = Bill.find(:all, :conditions => ["deadline >= ? AND deadline <= ?", day_start.to_i, day_end.to_i])
#    sum = Bill.get_value_of(bills)
    return Bill.get_value_of(bills)
  end
  
  # This method will calculate sum of bills
  # given as array of bills
  def self.get_value_of(bills)
    if bills.is_a?(Array)
      value = 0
      bills.each{|bill| value += bill.price}
      return value
    else
      return 0
    end
  end
  
  # This method will get information for graph. It returns
  # bills sum and tip so when user moves mouse over graph
  # of income, in graph will be shown bill sum for the day
  # and tips in which will be shown object of bills.
  def self.get_values_for_graph(bill_array, date_at, odd_outcome = false)
    values_for_graph = {}
    bill_array.each{|bill|
                      day_paid = Time.at(bill.paid).day if (date_at == :paid)
                      day_paid = Time.at(bill.deadline).day if (date_at == :deadline)
                      if !values_for_graph[day_paid]
                        values_for_graph[day_paid] = {} 
                        values_for_graph[day_paid][:sum] = 0
                        values_for_graph[day_paid][:tip] = ''
                      end
                      if (bill.category == "in")
                        values_for_graph[day_paid][:sum] += bill.price
                        values_for_graph[day_paid][:tip] += "#{bill.price}\t\t#{bill.object}\n"
                      else
                        if odd_outcome
                          values_for_graph[day_paid][:sum] -= bill.price
                          values_for_graph[day_paid][:tip] += "-#{bill.price}\t\t#{bill.object}\n"
                        end
                      end
                    }
  (0..31).each{|index|
                if !values_for_graph[index]
                  values_for_graph[index]={}
                  values_for_graph[index][:sum] = 0
                  values_for_graph[index][:tip] = ''
                end
              }
  return values_for_graph
  end
  
  # MEthod will return all bills with deadline in specified
  # month. According to <code>type</code> parameter bills
  # will be either those which are already paid, or still
  # pending or both.
  def self.get_bills_for_month(month, year, user_id, type)
    settings = {:date => {:from => Time.utc(year, month, 1).to_i,
                          :to   => Time.utc(year, month, MyDate::Month[month][:days], 23, 59, 59).to_i,
                          :type => 'deadline'},
                :order_by => 'deadline',
                :order_direction => 'ASC',
                :per_page => 1000}
    case type
    when 'paid'
      bills = Bill.get_paid_bills_for(:user, user_id, settings, 1)
    when 'pending'
      bills = Bill.get_pending_bills_for(:user, user_id, settings, 1)
    when 'all'
      bills = Bill.get_all_bills_for(:user, user_id, settings, :all )
    else
      return []
    end
#    bills = Bill.remove_outcome_bills(bills)
    return bills
  end
   
  # This method will remove bills from given array of
  # bills which are outcome
  def self.remove_outcome_bills(bill_array)
    income_bills = []
    bill_array.each{|bill| income_bills << bill if bill.category == 'in' }
    return income_bills
  end
  
  # This method is used by finances controller in action
  # pending and its used for parsing options for bills
  # which are to be displayed for the user. USer will use
  # from on page to set constraints for bills.
  def self.settings_for_bills(settings_from_params)
    settings = {}
    settings[:date] = {}
    if settings_from_params
      settings[:order_by]        = Bill.set_value(settings_from_params["sort_by"], "deadline")
      settings[:order_direction] = Bill.set_value(settings_from_params["sort"].to_sym, :ASC)
      settings[:bills_type]      = Bill.set_value(settings_from_params["bills_type"], "all")
      settings[:search_phrase]   = settings_from_params["search_field"]
      settings[:date][:type]     = Bill.set_value(settings_from_params["date_type"], "deadline")
      settings[:per_page]        = Bill.set_value(settings_from_params["per_page"], 10)
      settings[:notes]           = settings_from_params["notes"]
      if settings_from_params["include_date"]
        settings[:date][:from]      = MyDate::date_from_date_select(settings_from_params,"date_from").to_i
        settings[:date][:to]        = MyDate::date_from_date_select(settings_from_params,"date_to").to_i + 22.hours + 59.minutes + 59.seconds
      else
        settings[:date][:from] = 0
        settings[:date][:to]   = MyDate::MAX_DATE
      end
    else
      settings[:order_by] = "deadline"
      settings[:order_direction] = :ASC
      settings[:date][:from] = settings[:paid_from] = 0
      settings[:date][:to]   = settings[:paid_to]   = MyDate::MAX_DATE
      settings[:date][:type] = "deadline"
    end
    return settings
  end

  # According to bills parameter <code>show_attribute</code>
  # this method will return its value
  def attribute(show_attribute)
    case show_attribute
    when 'deadline'
      return self.deadline
    when 'renter_id'
      return self.renter.surname if self.renter_id > 0
    when 'property_id'
      return self.property.name if self.property_id > 0
    when 'object'
      return self.object.downcase
    when 'price'
      return self.price
    when 'category'
      return self.category
    when 'groupp'
      return self.groupp
    when 'paid'
      return self.paid
    else 
      return ''
    end
  end
  
  # This method is used to get ids from bills.
  # It is used by finance controller when user
  # marks bill as paid. When he marks them AJAX 
  # is used to update elements on page and
  # it get infromation also from array of ids.
  def self.get_ids_from_bills(bill_array)
    ids = []
    bill_array.each{|bill| ids << bill.id}
    return ids
  end
  
  # Method will odd bill whichs deadline or paydate
  # is not in selected date interval
  def self.select_bills_between(start_date, end_date, date_type, bills)
    start_date = 0 if !start_date
    end_date = MyDate::MAX_DATE if !end_date
    reduced_bills = []
    case date_type
    when "deadline"
      bills.each{|bill| reduced_bills << bill if ((bill.deadline >= start_date.to_i) && (bill.deadline <= end_date.to_i)) }
    when "paid"
      bills.each{|bill| reduced_bills << bill if ((bill.paid >= start_date.to_i) && (bill.paid <= end_date.to_i)) }
    else
      return bills
    end
    return reduced_bills
  end
  
  def self.select_bills_deadline_or_paid_between(start_date, end_date, bills_array)
    reduced_bills = []
    bills_array.each{|bill| 
                deadline_between_dates = (bill.deadline >= start_date.to_i) && (bill.deadline <= end_date.to_i)
                paid_between_dates = (bill.paid >= start_date.to_i) && (bill.paid <= end_date.to_i)
                reduced_bills << bill if (deadline_between_dates || paid_between_dates) }
    return reduced_bills
  end
  
  def self.remove_paid_bills_from(bill_array)
    paid_bills = []
    bill_array.each{|bill| if bill.paid > 0
                             paid_bills << bill
                           end  }
    for bill in paid_bills
      bill_array.delete(bill)
    end
    return bill_array
  end
  
  # This method will add penalty to bill
  # so when bill isnt paid till deadline
  # autopay will generate penalties.
  def add_penalty(penalty_id)
    bill_is_paid = self.paid > 0
    last_generated_count = self.deadline
    added_penalty = AddedPenalty.new({:bill_id => self.id,
                                       :penalty_id => penalty_id,
                                       :count => 0,
                                       :count_generated_at => last_generated_count,
                                       :bill_is_paid => bill_is_paid})
    added_penalty.save
  end
  
  # If bill has penalties for late pay this method
  # will generate total penalty sum for the bill and
  # also creates history of added penalties so user
  # can check when and what penalty was added.
  def calculate_penalties
    return if self.added_penalties == []
    min_repeat = 10000 
    penalty_with_min_repeat = nil
    self.added_penalties.each{|added_penalty| 
                              if added_penalty.penalty.after < min_repeat
                                penalty_with_min_repeat = added_penalty
                                min_repeat = added_penalty.penalty.after
                              end}
    # days from deadline to date when penalty with min repeat was added to total penalties sum
    days_from_deadline_to_last_added = MyDate::seconds_to_days(penalty_with_min_repeat.count_generated_at - self.deadline)
    days_from_deadline_to_last_added = 1 if days_from_deadline_to_last_added == 0
    # days from date, when penalty with min repeat was added to total sum, to now(today)
    days_from_last_added_to_now = MyDate::seconds_to_days(MyDate::today - penalty_with_min_repeat.count_generated_at)
    days_from_last_added_to_now += days_from_deadline_to_last_added
    # sort added penalties by repeat days DESCendant
    sorted_added_penalties = self.added_penalties.sort{|added_penalty1, added_penalty2| added_penalty2.penalty.after <=> added_penalty1.penalty.after}
    
    penalties_total = penalty_with_min_repeat.sum
    days_from_deadline_to_last_added.upto(days_from_last_added_to_now) do |actual_late_day|
      for added_penalty in sorted_added_penalties 
        if ((added_penalty.count_generated_at < MyDate::today)&&(!added_penalty.bill_is_paid))
          apply_penalty = (((actual_late_day % added_penalty.penalty.after) == 0) && actual_late_day != days_from_last_added_to_now)
          penalty_is_percentual = added_penalty.penalty.percent
          if apply_penalty
            if penalty_is_percentual
              penalty_to_add = (added_penalty.bill.price + penalties_total) * (added_penalty.penalty.price.to_f/100)
              added_penalty.add_to_history(actual_late_day,penalties_total,penalty_to_add)
              penalties_total += penalty_to_add
            else
              added_penalty.add_to_history(actual_late_day,penalties_total,added_penalty.penalty.price)
              penalties_total += added_penalty.penalty.price
            end
            added_penalty.update_attribute("count", added_penalty.count + 1) if AddedPenalty.exists?(added_penalty)
          end
        end
      end
    end
    self.added_penalties.each{|added_penalty| 
      added_penalty.update_attributes({:count_generated_at => MyDate::today,
                                       :sum => penalties_total }) if AddedPenalty.exists?(added_penalty.id)}
  end
  
  # This method will return total amount of added penalty
  def penalty_total
    self.added_penalties.each{|added_penalty| self.calculate_penalties if added_penalty.count_generated_at < MyDate::today}
    if self.added_penalties == []
      return
    elsif self.added_penalties[0].sum == 0
      return
    else
      self.added_penalties[0].sum
    end
  end
  
  # This method will add a note to bill. This method
  # is used when paying for bill.
  def new_note(content)
    note = Note.new({:type_id => self.id,
                     :owner => 'bill',
                     :content => content})
    note.save
  end
  
  # This method will return all bills for either property,
  # renter or both. IT uses plugin for paginating bills
  # so when displaying table od bills there are only
  # number of bills equal to <code>per_page</code> parameter.
  def self.get_all_bills_for(bills_for, id, from_page, page_number, per_page = nil)#date, sort_by, sort_direction)
    page_number = 1 unless page_number
    from_page = Bill.settings_for_bills(from_page) unless from_page
    from_page[:per_page] = per_page unless from_page[:per_page]
    case bills_for
      when :property
        owner = 'property'
      when :renter
        owner = 'renter'
      when :user 
        if page_number != :all
          bills = User.get_paginated_bills(id, from_page, page_number)
        else
          page_number == :all ? bills = User.get_bills(id, from_page[:date][:from], from_page[:date][:to]) : bills = []
          return bills
        end
    end
    if page_number == :all
      bills = Bill.find(:all, 
                        :conditions => ["#{owner}_id = ? AND
                                         #{from_page[:date][:type]} >= ? AND
                                         #{from_page[:date][:type]} <= ?", id, from_page[:date][:from],from_page[:date][:to]],
                        :order => "#{from_page[:order_by]} #{from_page[:order_direction]}")
    else
      bills = Bill.paginate(:all, 
                            :conditions => ["#{owner}_id = ? AND
                                             #{from_page[:date][:type]} >= ? AND
                                             #{from_page[:date][:type]} <= ?", id, from_page[:date][:from],from_page[:date][:to]],
                            :order => "#{from_page[:order_by]} #{from_page[:order_direction]}",
                            :page => page_number, :per_page => from_page[:per_page]) unless bills
    end
   return bills
  end
  
  def self.get_paid_bills_for_user_between(date, sort_by, sort_direction, user_id)
    date[:from]  = 1 if ((!date[:from])||(date[:from] == 0))
    date[:to]    = MyDate::MAX_DATE if !date[:to]
    bill_date = "bill.paid" if date[:type] == "paid"
    bill_date = "bill.deadline" if date[:type] == "deadline"
    bills_properties = Bill.find_by_sql(["SELECT bill.* 
                                          FROM bills AS bill, properties AS property 
                                          WHERE 
                                            bill.property_id = property.id AND 
                                            property.user_id = ? AND 
                                            bill.paid > ? AND
                                            #{bill_date} >= ? AND
                                            #{bill_date} <= ?",
                                          user_id, 0, date[:from], date[:to]])
    bills = Bill.sort(bills_properties, sort_by, sort_direction)
    return bills
  end
  
  def self.get_paid_bills_for(bills_for, id, from_page, page_number)
    from_page[:date][:from]  = 1 if ((!from_page[:date][:from])||(from_page[:date][:from] == 0))
    from_page[:date][:to]    = MyDate::MAX_DATE if !from_page[:date][:to]
    bill_date = "paid" if from_page[:date][:type] == "paid"
    bill_date = "deadline" if from_page[:date][:type] == "deadline"
    case bills_for
    when :renter
      bills = Bill.paginate(:all,
                            :conditions => ["#{bill_date} >= ? AND 
                                             #{bill_date} <= ? AND 
                                             renter_id = ? AND
                                             paid > ?", from_page[:date][:from], from_page[:date][:to], id, 0],
                            :order => "#{from_page[:order_by]} #{from_page[:order_direction]}",
                            :page => page_number, :per_page => from_page[:per_page])
    when :property
      bills = Bill.paginate(:all, 
                            :conditions => ["property_id = ? AND 
                                              paid > ? AND
                                              #{bill_date} >= ? AND
                                              #{bill_date} <= ?", 
                                              id, 0, from_page[:date][:from], from_page[:date][:to]],
                            :order => "#{from_page[:order_by]} #{from_page[:order_direction]}",
                            :page => page_number, :per_page => from_page[:per_page])
    when :user
      bills_properties = Bill.paginate_by_sql(["SELECT bill.* 
                                          FROM bills AS bill, properties AS property 
                                          WHERE 
                                            bill.property_id = property.id AND 
                                            property.user_id = ? AND 
                                            bill.paid > ? AND
                                            bill.#{bill_date} >= ? AND
                                            bill.#{bill_date} <= ?
                                          ORDER BY bill.#{from_page[:order_by]} #{from_page[:order_direction]}",
                                          id, 0, from_page[:date][:from], from_page[:date][:to]], :page => page_number, :per_page => from_page[:per_page])
      bills = bills_properties
    else
      return []
    end

    return bills
  end
  
  def self.get_pending_bills_for(bills_for, id, from_page, page_number)
    if !from_page
      from_page = Bill.settings_for_bills(from_page)
    else
      return [] if from_page[:date][:from] > from_page[:date][:to]
      if ((from_page[:date][:from] == 0)&&(from_page[:date][:to] == 0))
        from_page[:date][:from] = Time.at(0).to_i
        from_page[:date][:to] = Time.at(MyDate::MAX_DATE).to_i
      end
    end
    case bills_for
    when :renter
      bills = Bill.paginate(:all,
                            :conditions => ["deadline > ? AND 
                                             deadline < ? AND 
                                             renter_id = ? AND
                                             paid = ?", from_page[:date][:from], from_page[:date][:to], id, 0],
                            :order => "#{from_page[:order_by]} #{from_page[:order_direction]}",
                            :page => page_number, :per_page => from_page[:per_page])
    when :property
      bills = Bill.paginate(:all, 
                            :conditions => ["property_id = ? AND 
                                             paid = ? AND
                                             deadline >= ? AND
                                             deadline <= ?", id, 0, from_page[:date][:from], from_page[:date][:to]],
                            :order => "#{from_page[:order_by]} #{from_page[:order_direction]}",
                            :page => page_number, :per_page => from_page[:per_page])
    when :user
      bills_properties = Bill.paginate_by_sql(["SELECT DISTINCT bill.* 
                                                FROM bills AS bill, renters AS renter, properties AS property
                                                WHERE 
                                                (property.user_id = ?) AND 
                                                 ((bill.renter_id = renter.id AND
                                                   renter.property_id = property.id) OR
                                                  (bill.property_id = property.id)) AND
                                                  bill.paid = ? AND
                                                  bill.deadline >= ? AND
                                                  bill.deadline <= ? 
                                                  ORDER BY #{from_page[:order_by]} #{from_page[:order_direction]}",
                                                  id, 0, from_page[:date][:from], from_page[:date][:to]],
                                                  :page => page_number, :per_page => from_page[:per_page])
      bills = bills_properties
    else
      return []
    end
    return bills
  end
  
  # This method is used to mark selected bills as paid.
  def self.pay_bills(late_bills_ids, waiting_bills_ids, bills_paydates, bills_partial_prices, bills_penalties, bills_notes)
    bills_partial_prices = {} unless bills_partial_prices
    default_time = MyDate::date_from_date_select(bills_paydates,'default').to_i
   
    if (late_bills_ids && waiting_bills_ids)
      bills_to_process = late_bills_ids + waiting_bills_ids
    else
      bills_to_process = late_bills_ids if late_bills_ids
      bills_to_process = waiting_bills_ids if waiting_bills_ids
    end
    paid_bills = []
    if bills_to_process
      for bill_id in bills_to_process do
        if bills_partial_prices[bill_id]
          paid_bills << Bill.set_paid_date_and_price(bill_id,
                                                     bills_paydates,
                                                     bill_id,default_time, 
                                                     bills_partial_prices[bill_id].to_i,
                                                     bills_penalties[bill_id].to_i,
                                                     bills_notes[bill_id])
        else
          Bill.pay_full_price(bill_id)
        end
      end
    end
    return paid_bills
  end
  
  # This method is used to pay for bills which were
  # paid with full price and therefore have no partial
  # pays.
  def self.pay_full_price(bill_id)
    bill = Bill.find(bill_id)
    if bill.penalty_total
      bill.price += bill.penalty_total
      bill.new_note("Přičteno penále #{bill.penalty_total},- CZK")
    end
    for penalty in bill.added_penalties do
      penalty.bill_is_paid = true
      penalty.save
    end
    bill.paid = Time.now.to_i
    bill.save
  end
  
  # This method is used to mark bill as paid and
  # it can creates new bills which are partial pays
  # of given bill.
  def self.set_paid_date_and_price(id,bill_date,name_date, default_time, bill_price_paid, penalty, bill_note)
    return unless Bill.find(id)
    return if bill_price_paid <= 0
    penalty = 0 if penalty < 0
    bill = Bill.find(id)
    if bill_date
      bill_paid = MyDate::date_from_date_select(bill_date,name_date).to_i
    else
      bill_paid = default_time
    end
    if bill.price > bill_price_paid
      bill.price -= bill_price_paid
      bill.save
      bill.new_note("#{LocalizeHelper::get_string(:Partially_paid)} #{bill_price_paid.to_s} #{Settings.get_money_unit} #{LocalizeHelper::get_string(:on)} #{MyDate::date_at(bill_paid)}")
      
      bill2 = bill.clone
      bill2.paid = bill_paid
      bill2.added = Time.now.to_i
      bill2.price = bill_price_paid
      bill2.save
      bill2.new_note(LocalizeHelper::get_string(:Partial_payment))
      if (bill_note && (bill_note!=''))
        bill2.new_note(bill_note)
      end
    else
      bill.price += penalty
      bill.new_note("#{LocalizeHelper::get_string(:Added_penalty)} #{penalty},- #{Settings.get_money_unit}") if penalty > 0
      bill.paid = bill_paid
      for penalty in bill.added_penalties do
        penalty.bill_is_paid = true
        penalty.save
      end
      bill.save
      if (bill_note && (bill_note!=''))
        bill.new_note(bill_note)
      end
      return bill.id
    end
  end

  
  def self.update_paid_date(id,checkbox_date,name_date, default_time)
    return unless Bill.find(id)
    bill = Bill.find(id)
    if checkbox_date
      bill_paid = MyDate::date_from_date_select(checkbox_date,name_date).to_i
    else
      bill_paid = default_time
    end
    bill.paid = bill_paid
    bill.update_attribute('paid',bill_paid)
  end
  
  # This method updates bill's attributes when user
  # edit it in finance section. If price or deadline
  # is updated action recalculates penalties for bills
  # if any exists. Also regenerates penalty histories.
  def update_attrs_penalties(params, penalties)
    old_deadline = self.deadline
    old_price = self.price
    self.update_attributes(params)
    recalculate_penalties = ((old_deadline != self.deadline) || 
                             (old_price != self.price) ||
                              self.update_penalties(penalties))
    self.reload
    if (recalculate_penalties && !self.added_penalties.empty? )
      self.added_penalties.each{|added_penalty|
        PenaltyHistory.delete_all(["bill_id = ?", self.id])
        self.penalty_histories.each{|history| history.destroy}
        added_penalty.update_attributes({:count_generated_at => self.deadline,
                                         :sum => 0}) if AddedPenalty.exists?(added_penalty.id)
      }
    end
  end
  
  # When editing bill this method will update
  # its penalties. It either deletes, adds new
  # or doesnt update them. If there were deleted
  # or aded some penalties method with return
  # true meaning that there is need to recalculate
  # penalties and penalty histories.
  def update_penalties(penalties)
    bill_has_penalties = self.penalties.size > 0
    if (bill_has_penalties && !penalties)
      self.added_penalties.each{|added_penalty| added_penalty.destroy}
    elsif (bill_has_penalties && penalties)
      self.added_penalties.each{|added_penalty|
        if !penalties.include?(added_penalty.penalty_id.to_s)
          added_penalty.destroy
          calculate_new_penalties = true
#          self.penalty_histories.each{|history| history.destroy if history.penalty_id ==}
        else
          penalties.delete(added_penalty.penalty_id.to_s)
        end
      }
    end
    calculate_new_penalties = false
    if penalties
      for penalty_id in penalties
        self.add_penalty(penalty_id)
      end
      calculate_new_penalties = true
    end
    return calculate_new_penalties
  end
  
  # Method returns true if given bill has deadline
  # in specified month. Otherwise it will return false
  def deadline_in(month_number)
    month = Time.at(self.deadline).mon
    if (month == month_number)
      return true
    else
      return false
    end
  end
  
  # MEthod check if bill is pending or has been
  # paid. This method is used to set CSS class
  # in HTML view.
  def late_or_wait?
    return 'paid' if self.paid > 0
    return 'late' if self.deadline < MyDate.today
    return 'wait' if self.deadline >= MyDate.today
  end
  
  # This method is used to colorize bills in table
  # so user can see right from the beginign which
  # bills are late, pending and paid. (This method
  # belongs to helper module)
  def check_status(diacritics = true)
    if (self.paid == 0)
      if (self.deadline >= Time.utc(Time.now.year, Time.now.month, Time.now.day + 1).to_i)
        return "<td style='color: orange'>#{LocalizeHelper::get_string(:pending)}</td>" if diacritics
        return "wait"
      else
        return "<td style='color: red'>#{LocalizeHelper::get_string(:late)}</td>" if diacritics
        return "late"
      end
    else
      if (self.deadline < self.paid)
        return "<td style='color: green'>zaplaceno(pozdě)</td>" if diacritics
        return "ok_late"
      else
        return "<td style='color: green'>zaplaceno(O.K.)</td>" if diacritics
        return "ok"
      end
    end
  end
  
  # Checks if given bill is owned by logged user
  # and therefore has the right to manage it.
  def belongs_to_user(logged_user_id)
    if self.property_id != 0
      if self.property.belongs_to_user(logged_user_id)
        return true
      else
        return false
      end
    elsif self.renter_id != 0
      if self.renter.belongs_to_user(logged_user_id)
        return true
      else
        return false
      end
    end
  end
  
  def belongs_to_renter(logged_renter_id)
    if ((self.renter_id) && (self.renter_id != 0))
      if self.renter_id == logged_renter_id
        return true
      else
        return false
      end
    end
  end
  
  # REturns name of the owner. Either the name of
  # property or renter.
  def belongs_to
    return self.property.name if self.renter_id == 0
    return self.renter.full_name2 if (self.renter_id != 0)    
  end
  
  def klass
    return "class='#{self.category}'"
  end
  
  def for_rent(renter, property, object)
    self.renter_id = renter.id
    self.property_id = property.id
    self.object = object
    self.price = renter.rent
    self.deadline = Time.utc(Time.now.year,Time.now.mon,25).to_i
    self.groupp = "najem"
    self.repeat = 1
    self.added = Time.now.to_i
  end
  
  # This method is used to return residual price
  # to renters when they paid partial price for bill
  def residual_price
    temp_bills = TempBill.find(:all, :conditions => ["bill_id = ?", self.id])
    residuum = 0
    temp_bills.each{|temp_bill| residuum += temp_bill.price}
    
    return (self.price - residuum)
  end
  
  # If user mark bill as paid and bill has
  # temp_bills from renters this method will
  # delete them.
  def delete_temp_bills
    for temp_bill in self.temp_bills do
      self.temp_bills.delete(temp_bill)
      temp_bill.destroy
    end
  end
  
  def temp_bills_sum
    temp_bills = TempBill.find(:all, :conditions => ["bill_id = ?", self.id])
    sum = 0
    temp_bills.each{|temp_bill| sum += temp_bill.price}
    
    return sum
  end
  
  #
  def notes(return_text = false)
    bills_notes = Note.find(:all, :conditions => ["owner = ? AND type_id = ?", "bill", self.id])
    notes_content = []
    bills_notes.each{|note| notes_content << note.content }
    if return_text
      return notes_content
    else
      return bills_notes
    end
  end
  
  private
  
  # MEthod is used when parsing attributes for
  # bills from page. It will return <code>value</code>
  # or <code>default_value</code> if <code>value</code>
  # is not given.
  def self.set_value(value, default_value)
    if value
      return value
    else
      return default_value
    end
  end
  
  def self.sort(bill_array, sort_by, sort_direction)
    return bill_array unless bill_array.is_a?(Array)
    return bill_array unless bill_array[0].is_a?(Bill)
    sorted_bills = bill_array.sort{|bill1, bill2|
                           if (sort_direction == :ASC)
                             bill1.attribute(sort_by) <=> bill2.attribute(sort_by)
                           else
                             bill2.attribute(sort_by) <=> bill1.attribute(sort_by)
                           end
                               }
    return sorted_bills
  end
end
