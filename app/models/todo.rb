class Todo < ActiveRecord::Base
  belongs_to :property
  
  validates_presence_of :task, :description
  
  Priority = [
              #displayed    Stored in db
              ["Vysoka", "1"],
              ["Stredni","2"],
              ["Nizka",  "3"]
            ]
            
  
  def self.return_todos(property = {})
    find(:all,
         :conditions => "property_id = #{property.id}" )
  end
  
  def self.get_todos_with_notification(user_id)
    todos = Todo.find(:all, :conditions => ["user_id = ? AND notif > ? AND fulfilled = ?", user_id, 0, false], :order => "property_id DESC")
    
    return todos
  end
  
  def belongs_to_user(logged_user_id)
    if self.user_id == logged_user_id
      return true
    else
      return false
    end
  end
  
  def css_class
    if self.fulfilled
      return "fulfilled"
    else
      return ""
    end
  end
  
end
