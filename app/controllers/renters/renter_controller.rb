class Renters::RenterController < ApplicationController
  layout 'renter'
  
  def index
  end
  
  # Displays private information about logged user
  # like name, address etc. and also displays debit
  # table for logged user
  def my_info
    @renter.calculate_debit
    @new_messages = @user.get_unread_messages
  end
  
  # Displays information about price and history
  # of users rent.
  def rent_info
    
  end
  
  # Shows table od fittings which are in property
  def fittings
  end
  
  # Displaus information about given fitting.
  def fitting_detail
    @fitting = Fitting.find(params[:id])
    render :update do |page|
      page[params[:id].to_sym].replace_html :partial => '/nemovitosti/fit_detail'
      page[params[:id].to_sym].visual_effect :appear
    end
  end
  
  # Displays todos for property
  def todos
    @todos = @renter.property.todos_for_renters
  end
  
  # Displays info about property like address, renter
  # count, additional information etc.
  def my_accommodation
    @property = @renter.property
    @todos = @property.get_todos_for_renters
  end
  
  # Action will update users information. User
  # will edit his private information on page
  # and then this action updates them in DB.
  def update_renter
    @renter = Renter.find(params[:id])
    if @renter.is_logged_in(session[:user_id])
      message_with_updates = @renter.show_updates(params[:renter])
      if @renter.update_attrs(params[:renter], nil, params[:picture])
        Message.send_message(@renter.id, 
                             @renter.user.admin_id, 
                             LocalizeHelper::get_string(:User_update), 
                             message_with_updates)
        flash[:notice] = LocalizeHelper::get_string(:Update_successfull)
      else
        flash[:notice] = LocalizeHelper::get_string(:Error_updating_personal_information)
      end
      redirect_to :action => 'personal_info', :id => @renter.id
    else
      logout
    end
  end
  
  # Action displays form for updating users information.
  # Form will then call action: update_renter to update
  # renters info.
  def personal_info
    
  end
  
  # Displays form for user where he can fill info
  # about new person which will be living in property
  def report_person
    @logged_renter = @renter
    @renter = Renter.new
  end
  
  # Action will create new reported renter and save it
  # to DB.
  def report_renter
    if Renter.new_reported(params[:renter], session[:user_id], params[:date])
      flash[:notice] = LocalizeHelper::get_string(:Renter_successfully_reported_and_accommodated)
      Message.new_renter(session[:user_id])
    else
      flash[:notice] = LocalizeHelper::get_string(:Error_reporting_renter)
    end
    redirect_to :action => 'report_person'
  end
  
  
end
