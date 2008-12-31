require 'MyDate'
class LoginController < ApplicationController
  before_filter :check_user_is_admin, :except => [:login, :logout, :register, :add_new_property_user, :add_user]
  
  # Creates new user in DB
  def add_user
    @user = User.new(params[:user])
    @user.last_login = 0
    session[:user_id] ? @user.admin_id = session[:user_id] : @user.admin_id = 0
    renter = Renter.find(params[:id])
    if (renter.belongs_to_user(session[:user_id]))
      @user.renter_id = renter.id
      if request.post? and @user.save
        renter.update_attributes({:user_id => @user.id})
        flash[:notice] = LocalizeHelper::get_string(:User_succesfully_created)
        @user = User.new
#        if request.xhr?
#          render :partial => 'login_created'
#        end
      end
    else
      redirect_to :action => 'logout'
    end
  end

  def add_login
    add_user
    redirect_to :action => 'management'
  rescue
    redirect_to :action => 'index'
  end
  
  # Action will display form for registering
  # a new user.
  def register
  end
  
  # This action will create and save new user
  # which want to manage properties and renters
  def add_new_property_user
    @user = User.new(params[:user])
    @user.last_login = 0
    @user.admin_id = 0
    @user.typ = :admin
    if request.post? and @user.save
      flash[:notice] = LocalizeHelper::get_string(:Account_was_created__log_in)
      redirect_to :action => 'login'
      @user = User.new
    else
      render :action => 'register'
    end
  end
  
  # This action will create new login for renter
  def create
    @renter = Renter.find(params[:id])
    if request.xhr?
      render :partial => 'new_login'
    end
    if !@renter.belongs_to_user(session[:user_id])
      redirect_to :action => 'logout'
    end
  end
  
  # This action will login after he typed in correct
  # password and login. Otherwise user cant get to any
  # other par in aplication.
  def login
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        user.last_login = Time.now.to_i
        user.save
        session[:user_id] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        AutoPay.generate(session[:user_id])
        if uri
          redirect_to uri
        else
          if user.typ == :renter
            redirect_to :controller => 'renter', :action => 'my_info'
          else
            redirect_to :action => 'index'
          end
        end
      else
        flash[:notice] = "Nesprávne uživatelské jméno nebo heslo"
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    if request.xhr?
      render :text => 'logged out'
    else
      redirect_to(:action => "login" )
    end
  end
  
  # Action will display welcome table with infos
  # for property user like debtors, rent expiry and todos.
  def index
    @todos = Todo.get_todos_with_notification(session[:user_id])
  end
  
  # This action will display login management functions
  # for property user where he can maange logins for renters
  def management
    @renters = User.get_renters(session[:user_id])
  end
  
  # Uptades specified login for renter
  def update_login
    @user = User.find_by_name(params[:user][:name])
    if @user.belongs_to_user(session[:user_id])
      if @user.update_login(params[:user], params[:old_password])
        flash[:notice] = LocalizeHelper::get_string(:Password_succesfully_changed)
      else
        flash[:error] = LocalizeHelper::get_string(:Error_changing_password)
      end
      redirect_to :action => 'management'
    else
      logout
    end
  end
  
  # Action will display form for updating login
  def edit_login
    @user = User.find(params[:id])
    if @user.belongs_to_user(session[:user_id])
      render :partial => 'edit_login'
    else
      render :text => "ERROR"
    end
  end
  
  # This action is called by AJAX and will switch
  # between tables which are displayed when user
  # logs in.
  def show_info_table
    case params[:id]
    when "debtors"
      @debit_renters = Renter.get_debit_renters(session[:user_id])
      render :partial => 'debtors_table'
    when "task"
      @todos = Todo.get_todos_with_notification(session[:user_id])
      render :partial => 'list_todo'
    when "rent_expiry"
      @renters = Renter.with_ending_rent(session[:user_id], 31)
      @renters.each{|renter| renter.calculate_debit }
      render :partial => 'rent_expiry_table'
    end
  end
  
  # Deletes users login informations
  def delete_user
    user = User.find(params[:id])
    if user.belongs_to_user(session[:user_id])
      if user.destroy
        flash[:notice] = LocalizeHelper::get_string(:User_sucesfully_deleted)
      else
        flash[:error] = LocalizeHelper::get_string(:Error_deleting_user)
      end
        redirect_to :action => 'management'
    else
      logout
    end
  end
  
end
