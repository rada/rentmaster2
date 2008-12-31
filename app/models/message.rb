class Message < ActiveRecord::Base
  belongs_to :renter, :foreign_key => 'from_id'
  
  DEFAULT = {:new_reported_renter => LocalizeHelper::get_string(:Message_about_new_reported_renter)}
  
  def self.send_message(from, to, subject, content)
    message = Message.new({:from_id    => from,
                           :to_id      => to,
                           :subject => subject,
                           :content => content,
                           :sent_at => Time.now})
    message.save
  end
  
  # This method creates new message for property user
  # when one of his renters will report new renter
  # for property.
  def self.new_renter(from_id)
    reported_by = User.find(from_id).renter
    new_reported = reported_by.get_reported_renters.last
    if (reported_by.is_a?(Renter) && new_reported.is_a?(Renter)) 
      message = "#{LocalizeHelper::get_string(:Renter)} 
                 #{reported_by.full_name} 
                 #{LocalizeHelper::get_string(:Reported_new_renter)}: 
                 #{new_reported.full_name}."
      Message.send_message(from_id, reported_by.user.admin_id, LocalizeHelper::get_string(:New_reported_renter), message)
    end
  end
  
  # Checks if message is for specified user
  def belongs_to_user(user_id)
    if self.to_id == user_id
      return true
    else
      return false
    end
  end
  
  # MEthod returns user from who was this message
  # sent
  def from
    user = User.find(self.from_id)
    if user.typ == :renter
      return user.renter.full_name2
    else
      return LocalizeHelper::get_string(:property_admin)
    end
  end
  
  # MEthod returns user to who was this message
  # sent
  def to
    user = User.find(self.to_id)
    if user.typ == :renter
      return user.renter.full_name2
    else
      return 'property_admin'
    end
  end

  # Checks if message is from specified user
  def is_from_user(user_id)
    if user_id == from_id
      return true
    else
      return false
    end
  end

  # Checks if message is new and therefore unread
  def is_new(return_text_new ,return_text_read)
    if self.new
      if return_text_new
        return return_text_new
      else
        return true
      end
    else
      if return_text_read
        return return_text_read
      else
        return false
      end
    end
  end
  
end
