class TempBill < ActiveRecord::Base
  belongs_to :bill
   
  def self.pay_bills(late_bills_ids, waiting_bills_ids, bills_paydates, bills_partial_prices, bills_penalties, bills_notes)
    bills_partial_prices = {} unless bills_partial_prices
    default_time = MyDate::date_from_date_select(bills_paydates,'default').to_i
    if (late_bills_ids && waiting_bills_ids)
      bills_to_process = late_bills_ids + waiting_bills_ids
    else
      bills_to_process = late_bills_ids if late_bills_ids
      bills_to_process = waiting_bills_ids if waiting_bills_ids
    end
    
    if bills_to_process
      for bill_id in bills_to_process do
        if bills_partial_prices[bill_id]
          TempBill.set_paid_date_and_price(bill_id,
                                           bills_paydates,
                                           bill_id,default_time, 
                                           bills_partial_prices[bill_id].to_i,
                                           bills_penalties[bill_id].to_i,
                                           bills_notes[bill_id])
        end
      end
    end
  end
  
  def self.set_paid_date_and_price(id,bill_date,name_date, default_time, bill_price_paid, penalty, note)
    return unless Bill.find(id)
    return if bill_price_paid <= 0
    penalty = 0 if penalty < 0
#    bill = Bill.find(id)
    if bill_date
      bill_paid = MyDate::date_from_date_select(bill_date,name_date).to_i
    else
      bill_paid = default_time
    end
      temp_bill = TempBill.new({:bill_id => id, 
                                :note => note,
                                :price => bill_price_paid,
                                :penalty => penalty,
                                :paid => bill_paid})
      temp_bill.save
  end
end
