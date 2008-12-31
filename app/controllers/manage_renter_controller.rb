class ManageRenterController < ApplicationController
  before_filter :check_user_is_admin, :except =>[:show_debit_table]
  
  def index
    @renters = User.get_renters(session[:user_id])
    render :layout => 'application'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  
  # This action will display page where will be displayed
  # infromation for closing rent for renter.
  def close_rent
    @renter = Renter.find(params[:id])
    if @renter.belongs_to_user(session[:user_id])
      @autopays = @renter.auto_pays
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
  # This action will mark user as one with close rent
  # which means that his rent in property ended.
  def end_rent
    @renter = Renter.find(params[:id])
    if @renter.belongs_to_user(session[:user_id])
      if !@renter.has_unpaid_bills
        @renter.close_rent if !@renter.has_closed_rent
        flash[:notice] = LocalizeHelper::get_string(:Rent_succesfully_closed)
        redirect_to :action => 'renter', :id => @renter
      else
        flash[:error] = LocalizeHelper::get_string(:Renter_has_unpaid_bills__Cant_close_rent)
        @autopays = @renter.auto_pays
        redirect_to :action => 'close_rent', :id => @renter
      end
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
  # Action shows page with rent infromation for creating
  # a new rent for renter.
  def rent_info
    @renter = Renter.find(params[:id])
    if @renter.property.belongs_to_user(session[:user_id])
      @penalties = User.get_penalties(session[:user_id])
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
  # Shows main page in renters section about personal
  # info of given renter
  def renter
    @renter = Renter.find(params[:id])
    @additional_infos = @renter.get_additionals
    @penalties = User.get_penalties(session[:user_id])
    @renter.calculate_debit
  end
  
  # Action will display form for creating new renter
  # in property.
  def new
    @renter = Renter.new
    @properties = Property.find(:all, :conditions => ["user_id = ?", session[:user_id]])
  end
  
  # Action will render table of previous and actual
  # accommodation of given renter.
  def accommodation_history
    @renter = Renter.find(params[:id])
    if @renter.belongs_to_user(session[:user_id])
      @properties = User.get_opened_properties(session[:user_id])
      @property = @renter.property
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
  # Action will move renter to new property when closing
  # property in which he is accomodated. Action will
  # upadate info in DB about his property .
  def move_renter
    @renter = Renter.find(params[:id])
    if @renter.belongs_to_user(session[:user_id])
      if @renter.move_to_property(params[:property_id], session[:user_id])
        flash[:notice] = LocalizeHelper::get_string(:Renter_succesfully_moved)
        redirect_to :action => 'renter', :id => @renter
      else
        flash[:notice] = LocalizeHelper::get_string(:Error_moving_renter)
        redirect_to :action => 'accommodation_history', :id => @renter
      end
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
  # This action will change(update) renters rent and also autopays
  # for rent if there are any defined.
  def update_rent
    @renter = Renter.find(params[:id])
    if @renter.belongs_to_user(session[:user_id])
      new_rent_date = MyDate::date_from_date_select(params[:rent],:from_date).to_i
      if @renter.actual_rent
        if @renter.actual_rent.has_autopay
          if params[:update_autopay]
            case new_rent_date < MyDate::today
            when true
              @renter.actual_rent.auto_pay.update_attributes({:price => params[:rent][:price],
                                                              :last_pay => new_rent_date})
            when false
              @renter.actual_rent.auto_pay.update_attributes({:end_pay => new_rent_date})
              new_autopay_rent = @renter.new_autopay_rent(params[:rent], new_rent_date)
            end
          end
          @generated_bills = @renter.actual_rent.auto_pay.get_generated_bills(new_rent_date)
        end
        rent = @renter.update_rent(params[:rent], new_rent_date, new_autopay_rent)
        rent.save
        redirect_to :action => 'rent_info', :id => @renter if !@generated_bills
      else
        new_rent = @renter.create_new_rent(params, new_rent_date)
        if new_rent.save
          flash[:notice] = LocalizeHelper::get_string(:Rent_succesfully_updated)
        else
          flash[:error] = LocalizeHelper::get_string(:Error_updating_rent)
        end
        redirect_to :controller => 'manage_renter', :action => 'rent_info', :id => @renter
      end
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
  # This action will diplay form for creating new
  # rent for renter.
  def new_rent
    @renter = Renter.find(params[:id])
    if @renter.belongs_to_user(session[:user_id])
      @property = @renter.property
      @penalties = User.get_penalties(session[:user_id])
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
  # This action will create new rent for renter and autopay
  # for rente if user choosed to create one.
  def create_rent
    @renter = Renter.find(params[:id])
    if @renter.belongs_to_user(session[:user_id])
      rent = @renter.create_new_rent(params, Time.now.to_i)
      if rent.save
        flash[:notice] = LocalizeHelper::get_string(:Rent_created)
        if params[:add_autopay_rent] == "true"
          autopay_rent = AutoPay.rent_for_new_renter(params, @renter)
          if autopay_rent.save
            rent.update_attributes({:auto_pay_id => autopay_rent.id})
            flash[:notice] += LocalizeHelper::get_string(:Autopay_for_rent_succesfully_created)
          end
        end
        redirect_to :controller => 'nemovitosti', :action => 'detail', :id => @renter.property.id
      else
        @property = @renter.property
        render :action => 'new_rent'
      end
    else
      logout
    end
  end
  
  # Creates new renter in database
  def create 
    @renter = Renter.new(params[:renter])
    if @renter.save
      accommodation_dates = {}
      accommodation_dates[:from] = MyDate::date_from_date_select(params[:date], "start")
      accommodation_dates[:to] = MyDate::date_from_date_select(params[:date], "end")
      @renter.new_accommodation(@renter.property_id, accommodation_dates)
      flash[:notice] = LocalizeHelper::get_string(:Renter_was_successfully_created)
      redirect_to :controller => '/manage_renter', :action => 'new_rent', :id => @renter.id
    else
      @properties = Property.find(:all, :conditions => ["user_id = ?", session[:user_id]])
      flash[:notice] = LocalizeHelper::get_string(:Error_saving_renter)
      render :action => 'new'
    end
  end
  
  # This action will render table with bills
  # for which renter have not paid and therefore 
  # has a edbit.
  def show_debit_table
    @renter = Renter.find(params[:id])
    @debit_bills = @renter.get_debit_bills
    @renter.calculate_debit
    render :partial => 'debit_bills_table'
  end
  
  # Displays form for editing renters info
  def edit
    @renter = Renter.find(params[:id])
    @properties = Property.find(:all, :conditions => ["user_id = ?", session[:id]])
  end
  
  # Updates renters info
  def update
    @renter = Renter.find(params[:id])
    if @renter.belongs_to_user(session[:user_id])
      rent_date = MyDate::get_dates(params[:date], "start", "end")
      if @renter.update_attrs(params[:renter], rent_date, params[:picture])
        flash[:notice] = "#{LocalizeHelper::get_string(:Renter_was_successfully_updated)} #{params[:picture][:upload_status]}"
        redirect_to :action => 'renter', :id => @renter
      else
        render :action => 'edit'
      end
    else
      logout
    end
  end
  
  # Deletes renter from application.
  def delete
    renter = Renter.find(params[:id])
    if renter.belongs_to_user(session[:user_id])
      renter.destroy
    end
    redirect_to :action => 'index'
  end
  
end
