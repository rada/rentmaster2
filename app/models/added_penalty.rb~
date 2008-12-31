class AddedPenalty < ActiveRecord::Base
  
  belongs_to :bill             
  belongs_to :penalty
  
  # Method will count days which passed since last
  # time a penalty was added to bill and if passed 
  # days are more than days after which a penalty
  # should be added then it will increment penalty
  # count for bill.
  def generate_count
    today = MyDate.today
    last_generated_count = self.count_generated_at
    days_passed = MyDate.seconds_to_days(today - last_generated_count)
    
    add_to_count = days_passed/self.penalty.after
    add_to_count -= 1 if days_passed % self.penalty.after == 0
    self.count += add_to_count
    self.count_generated_at = today
    self.save
  end
  
  # When adding a penalty for late pay this method
  # will make a record in DB so the user can see
  # when was which penalty added
  def add_to_history(late_day_number, old_penalty_sum, sum_to_add, action_performed = self.penalty.name)
    date_added = (Time.at(self.bill.deadline) + late_day_number.days).to_i
    history_event = PenaltyHistory.new({:bill_id => self.bill.id,
                                        :date_added => date_added,
                                        :old_penalty_sum => old_penalty_sum,
                                        :new_penalty_sum => (old_penalty_sum + sum_to_add),
                                        :action_performed => action_performed})
    history_event.save
  end
  
end
