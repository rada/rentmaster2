class MessagesController < ApplicationController
  
  # Show from for creatind and sending new message
  def new
    @user = User.find(session[:user_id])
    if @user.typ == :admin
      @renters = User.get_renters(session[:user_id])
      @renters = @renters.sort{|renter1, renter2| renter1.full_name <=> renter2.full_name}
    end
    if request.xhr?
      render :layout => false
    end
  end
  
  # Show from for forwarding a message
  def forward
    @renters = User.get_renters(session[:user_id])
    @renters = @renters.sort{|renter1, renter2| renter1.full_name <=> renter2.full_name}
    @message = Message.find(params[:id])
    if @message.is_from_user(session[:user_id])
      render :layout => false
    else
      render :text => "FALSE"
    end
  end
  
  # Action will render table of incoming and outgoing messages
  def list
    @incoming_messages = Message.find(:all, :conditions => ["to_id = ?", session[:user_id]], :order => "sent_at DESC")
    @outgoing_messages = Message.find(:all, :conditions => ["from_id = ?", session[:user_id]], :order => "sent_at DESC")
    @new_messages = []
    @incoming_messages.each{|message| @new_messages << message if message.new}
    @new_messages = @new_messages.sort{|message1, message2| message2.sent_at <=> message1.sent_at}
    logged_user = User.find(session[:user_id])
    if logged_user.typ == :renter
#      render :controller => 'renters/renter', :action => 'messages'
      @renter = logged_user.renter
      render :layout => 'renter'
    end
  end
  
  # Shows content of selected message
  def show
    @message = Message.find(params[:id])
    if @message.belongs_to_user(session[:user_id])
      @message.update_attributes({:read => Time.now.to_i, :new => false})
      render :partial => 'message'
    elsif @message.is_from_user(session[:user_id])
      render :partial => 'message'
    else
      redirect_to :controller => '/login', :action => 'logout'
    end
  end
  
  # Creates(="sends") new message and store it in DB
  def create
    logged_user = User.find(session[:user_id])
    message = Message.new(params[:message])
    if logged_user.typ == :admin
      renter = Renter.find(params[:renter])
      message_for = renter.user_id
    else
      renter = logged_user.renter
      message_for = logged_user.admin_id
    end
    if renter.property.belongs_to_user(logged_user.admin_id)
      message.from_id    = logged_user.id
      message.to_id      = message_for
      message.sent_at = Time.now.to_i
      if message.save
        flash[:notice] = 'Message sent'
      else
        flash[:notice] = 'ERROR'
      end
      redirect_to :action => 'new'
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
  def show_reply_form
    @message = Message.find(params[:id])
    if @message.belongs_to_user(session[:user_id])
      render :partial => 'reply_message'
    else
      redirect_to :controller => '/login', :action => 'logout'
    end
  end
  
  # Creates(="sends") message as a reply to other message
  def reply
    original_message = Message.find(params[:id])
    if original_message.belongs_to_user(session[:user_id])
      reply_message = Message.new({ :from_id => session[:user_id],
                                    :to_id => original_message.from_id,
                                    :replied_to => original_message.id,
                                    :subject => params[:message][:subject],
                                    :content => params[:message][:content],
                                    :sent_at => Time.now.to_i,
                                    :read => 0})
      if reply_message.save
        flash[:notice] = 'Zpráva byla poslaná'
      else
        flash[:notice] = 'ERROR'
      end
    else
      redirect_to :controller => '/login', :action => 'logout'
    end
  end
  
  # Action deletes message
  def delete
    message = Message.find(params[:id])
    message.destroy
    redirect_to :action => 'list'
  end
  
end
