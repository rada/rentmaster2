# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :set_language
  before_filter :authorize, :except => [:login, :register, :add_user, :add_new_property_user]
  before_filter :get_renter, :except => [:login, :register, :add_user, :add_new_property_user]
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => 'cca10c5242fbb71693935ff34c4bc6db'
  
  def set_language
    LocalizeHelper.set_language(params[:lang]) if params[:lang]
  end
    
  # Before any action this action id called to
  # ensure that user is logged in.
  def authorize
    unless User.find_by_id(session[:user_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "Prosím přihlašte se"
      redirect_to :controller => '/login', :action => 'login'
    end
  end
  
  # This action will initialze variable where 
  # will be stored instances of user which is
  # actualy logged in. 
  def get_renter
    @renter = User.find(session[:user_id]).renter
    @user = User.find(session[:user_id])
  end
  
  def logout
    redirect_to :controller => 'login', :action => 'logut'
  end
  
  def check_user_is_admin
   if @user.typ != :admin
     redirect_to :controller => 'renters/renter', :action => 'my_info'
   end
  end
  
  def check_user_is_renter
    if @user.typ != :renter
      redirect_to :controller => 'login', :action => 'index'
    end
  end
 
  
end
