class FinancesController < ApplicationController
  before_filter :check_user_is_admin, :except => [:date_select]
  
  # This action will show the main page for finances
  # where statistics of bills from actual month and in 
  # total are displayed together with 2 graph.
  def statistics
    @month_bills = Bill.get_stat_for(Time.now.month, session[:user_id])
    @bills_total = Bill.get_stat_total(session[:user_id])
    @pie_graph = open_flash_chart_object(500,250,'/finances/income', false, '/')
    @bar_graph = open_flash_chart_object(500,250,'/finances/bill_sum_graph', false, '/')
  end
  
  
  # This action will render pie graph on main
  # page. It gets bills from DB then sort it by
  # group and displays them in pie graph.
  def income
    data = []
    links = []
    bills_by_group = User.get_bills_by_group(session[:user_id])
    pie_names = []
    for group in Bill::Group
      sum_bills_prices = 0
      if bills_by_group[group[1]]
        pie_names << group[1]
        bills_by_group[group[1]].each{|bill|
          sum_bills_prices += bill.price #if bill.category == "in"
        }
        data << sum_bills_prices
      end
    end 
    
    g = Graph.new
    g.pie(60, '#505050', '{font-size: 10px; color: #404040;}')
    g.pie_values(data, pie_names)
    g.pie_slice_colors(%w(#d01fc3 #ffae50 #356aa0 #c79810 #f54d63 #85f570 #f5ed2b #b8f5f1))
    g.set_tool_tip("#val# CZK")
    g.title("Platby podle skupiny", '{font-size:18px; color: #d01f3c}')
    render :text => g.render
  end
  
  # Action will render first graph where will be displayed
  # sum of bills according to day in month.
  def bill_sum_graph
    bar = BarOutline.new(50, '#9933CC', '#8010A0')
    bar.key(LocalizeHelper::get_string(:Bills_sum), 10)
    y_axis_max = 0
    MyDate::Month[Time.now.month][:days].times do |day_number|
      sum_for_day = Bill.sum_for_day(Time.utc(Time.now.year, Time.now.month, day_number + 1),session[:user_id])
      y_axis_max = sum_for_day if sum_for_day > y_axis_max
      bar.data << sum_for_day
    end
  
    g = Graph.new
    g.title(LocalizeHelper::get_string(:Month), '{font-size:18px; color: #d01f3c}')
  
    g.data_sets << bar
    g.set_x_labels((Date.civil(Time.now.year,Time.now.month,1)..Date.civil(Time.now.year,Time.now.month,MyDate::Month[Time.now.month][:days])).map(&:to_s))
  
    g.set_x_label_style(10, '#9933CC', 2)
    g.set_x_axis_steps(1)
    g.set_y_max(y_axis_max + 1000)
    g.set_y_label_steps(10)
    g.set_y_legend(LocalizeHelper::get_string(:Price), 12, "#736AFF") #LocalizeHelper::get_string(:Bill_sum)
    render :text => g.render

  end
  
  # If adding a bill, penalty or autopay this action
  # will display errors if any occurs when trying 
  # to save bill, penalty or autopay
  def show_errors
  end
  
  # This action will display form for adding new bill.
  def show_bill_form
    @penalties = User.get_penalties(session[:user_id])
  end
  
  # This action shows bills management page to user
  # It displays bills according to users settings on
  # page
  def pending
    settings_from_page = Bill.settings_for_bills(params[:settings])
    settings_from_page[:bills_type] = params[:show] if !settings_from_page[:bills_type]
    bills = get_bills_info(params[:bills_for])
    
    AutoPay.generate(session[:user_id])
    case settings_from_page[:bills_type]
    when "all"
      @bills_to_show = Bill.get_all_bills_for(bills[:owner], 
                                              bills[:owner_id],
                                              settings_from_page,
                                              params[:page])
    when "paid"
      @bills_to_show = Bill.get_paid_bills_for(bills[:owner],
                                               bills[:owner_id],
                                               settings_from_page,
                                               params[:page])      
    else 
      @bills_to_show = Bill.get_pending_bills_for(bills[:owner],
                                                  bills[:owner_id],
                                                  settings_from_page,
                                                  params[:page])
    end
    if params[:search]
      @bills_to_show = Bill.search_for(settings_from_page[:search_phrase], @bills_to_show)      
    end
    session[:bills] = Bill.get_ids_from_bills(@bills_to_show)
    session[:order_by] = settings_from_page[:order_by]
    session[:order_direction] = settings_from_page[:order_direction]
    
    if request.xhr?
      render :update do |page|
        page[:bills_table].replace_html :partial => '/finances/pending_bills_table'
        page[:pages].replace_html :partial => '/finances/page_select'
      end
    else
      render :action => bills[:action]
    end
  end
  
  # This action will pay bills which user has
  # marked as paid on the page in finances section.
  def pay_bills
    paid_bills = Bill.pay_bills(params[:late], params[:wait], params[:date], params[:partial_prices], params[:penalty], params[:notes])
    paid_bills.each{|bill_id| session[:bills].delete(bill_id)}
    @bills_to_show = Bill.paginate(session[:bills], :order => "#{session[:order_by]} #{session[:order_direction]}", :page => params[:page])
    session[:bills] = Bill.get_ids_from_bills(@bills_to_show)
    render :partial => '/finances/pending_bills_table/'
  end
  
  # This action will create an autopay for a rent so
  # the aplication can then generates bills for renter
  # for his rent.
  def create_autopay_rent
    renter = Renter.find(params[:id])
    if renter.belongs_to_user(session[:user_id])
      if ((renter.actual_rent)&&(!renter.actual_rent.has_autopay))
        if renter.create_autopay_rent(params[:autopay], params[:penalty_list])
          flash[:notice] = LocalizeHelper::get_string(:Autopay_succesfully_saved)
        else
          flash[:error] = LocalizeHelper::get_string(:Error_saving_autopay)
        end
          redirect_to :controller => 'manage_renter', :action => 'renter', :id => renter.id
      end
    else
      logout
    end
  rescue
    redirect_to :controller => 'manage_renter', :action => 'index' 
  end
  
  # Action will create new penalty and save it in DB.
  def add_penalty
    @penalty = Penalty.new(params[:penalty])
    @penalty.percent = params[:penalty]['percent']
    @penalty.user_id = session[:user_id]
    if @penalty.save
      flash[:notice] = "Penále úspěšně vytvořeno"
      redirect_to :action => 'penalties'
    else
      flash[:notice] = "Penále se nepodařilo vytvořit"
      render :action => 'show_errors'
    end
  end
  
  # This action will get information from page
  # and then creates new bill in DB.
  def add_bill
    bill_is_paid = params[:bill_paid] == "1"
    @penalties = User.get_penalties(session[:user_id]) #in case of error we need penalties when rendering show_error
    if bill_is_paid
      day = params[:pay_date]["(3i)"].to_i
      month = params[:pay_date]["(2i)"].to_i
      year = params[:pay_date]["(1i)"].to_i
      if MyDate.verify(year,month,day)
        params[:bill][:paid] = Time.utc(year,month,day).to_i
      else
        render :action => show
      end
    else
      params[:bill][:paid] = 0
    end
    day = params[:deadline]["(3i)"].to_i
    month = params[:deadline]["(2i)"].to_i
    year = params[:deadline]["(1i)"].to_i
    if MyDate::verify(year,month,day)
      deadline = Time.utc(year,month,day).to_i
      case params[:owner]
        when 'renter'
          renter = Renter.find(params[:bill][:renter_id].to_i)
          params[:bill][:property_id] = renter.property_id
        when 'property'
          params[:bill][:renter_id] = 0
      end
      @bill = Bill.new(params[:bill])
      @bill.added = Time.utc(Time.now.year, Time.now.mon, Time.now.day).to_i
      @bill.deadline = deadline
      if @bill.save
        flash[:notice] = "Payment succesfully saved"
        if params[:penalties] == "on"
          for penalty in params[:penalty_list] do
            @bill.add_penalty(penalty)
          end
        end
        if params[:nemovitost]!=''
          redirect_to :controller => 'nemovitosti', :action => 'finances', :id => params[:nemovitost]
        else
          redirect_to :action => 'show_bill_form'
        end
      else
        flash[:notice] = "nepodarilo sa ulozit do db"
        render :action => 'show_errors'
      end
    else
      flash[:notice] = "Špatné datum"
      render :action => 'show_errors'
    end
  end
  
  def delete_bill
    @bill = Bill.find(params[:id])
    if @bill.belongs_to_user(session[:user_id])
      @bill.destroy
      session[:bills].delete(@bill.id)
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
  # This action will display form for editing bill
  # and when bill is edited this action is called
  # again and will update bill. For displayin form
  # an AJAX request from page is used. For updating
  # a nonAJAX request from controller is used.
  def edit_bill
    @bill = Bill.find(params[:id])
    if @bill.belongs_to_user(session[:user_id])
      @penalties = User.get_penalties(session[:user_id])
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
    if (params[:bill] && !params[:bill].empty?)
      params[:bill].delete_if{|key, value| key == 0}
      params[:bill][:deadline] = MyDate::date_from_date_select(params[:deadline],:date).to_i
      @bill.update_attrs_penalties(params[:bill], params[:penalty_ids])
    end
    render :layout => false
  end
  
  # This action is calles from form for editing bill
  # to update bill with nonAJAX request. 
  def update_bill
    @bill = Bill.find(params[:id])
    if @bill.belongs_to_user(session[:user_id])
      edit_bill
    else
      render :text => 'ERROR'
    end
  end
  
  # Creates and saves new autopay in DB.
  def add_auto_pay
    params_for = {}
    params_for[:auto_pay] = AutoPay.get_params_from(params, session[:user_id])
    @auto_pay = AutoPay.new(params_for[:auto_pay])
    if @auto_pay.save
      @auto_pay.generate_first_bill
      flash[:notice] = LocalizeHelper::get_string(:Autopay_succesfully_created)
      @autopays = User.get_autopays(session[:user_id])
      redirect_to :action => 'autopays'
    else
      flash[:notice] = LocalizeHelper::get_string(:Error_occured)
      render :action => 'show_errors'
    end
  end
  
  # Displays table od defined autopays in aplication.
  def autopays
    @autopays = User.get_autopays(session[:user_id])
  end
  
  # Displays table od defined penalties in aplication.
  def penalties
    @penalties = User.get_penalties(session[:user_id])
  end
  
  # Displays attributes of autopay.
  def auto_detail
    @auto = AutoPay.find_by_id(params[:id])
    element_id = "detail_#{params[:id]}"
    render :update do |page|
      page[element_id.to_sym].replace_html :partial => 'auto_detail'
      page[element_id.to_sym].show
    end
  end
  
  def edit_autopay
    @auto_pay = AutoPay.find(params[:id])
    if !@auto_pay.belongs_to_user(session[:user_id])
      render :text => LocalizeHelper::get_string(:Invalid_autopay_id)
    elsif params[:edit]
      params[:auto_pay][:end_pay]   = MyDate::date_from_date_select(params[:end], "")
      params[:auto_pay][:last_pay] = MyDate::date_from_date_select(params[:first], "")
      @auto_pay.update_attributes(params[:auto_pay])
    end
    if !request.xhr?
      @autopays = User.get_autopays(session[:user_id])
      @penalties = User.get_penalties(session[:user_id])
      redirect_to :action => 'autopays'
    end
  end
  
  def edit_penalty
    @penalty = Penalty.find(params[:id])
    if @penalty.belongs_to_user(session[:user_id])
      if params[:edit]
        @penalty.update_attributes(params[:penalty])
      end
      if !request.xhr?
        @penalties = User.get_penalties(session[:user_id])
        redirect_to :action => 'penalties'
      end
    else
      logout
    end
  end
  
  def destroy_autopay
    autopay = AutoPay.find(params[:id])
    if autopay.belongs_to_user(session[:user_id])
      autopay.destroy
    end
    @autopays = User.get_autopays(session[:user_id])
    redirect_to :action => 'autopays', :form => 'auto' 
#  rescue
#    redirect_to :action => 'autopays'
  end
  
  def destroy_penalty
    penalty = Penalty.find(params[:id])
    if penalty.belongs_to_user(session[:user_id])
      penalty.destroy
      redirect_to :action => 'penalties'
    else
      logout
    end
  end
  
  # In bill management this action is called by AJAX
  # and it will display history of added penalties of
  # selected bill.
  def show_penalty_history
    @bill = Bill.find(params[:id])
    render :partial => 'penalty_history_table'
  end
  
  # In bill management this action is called by AJAX
  # and will display information from renter which marked 
  # bill as paid.
  def show_temp_bills
    @bill = Bill.find(params[:id])
    render :partial => 'temp_bill_table'
  end
  
  # In bill management this action is called by AJAX
  # and will display form for marking bill as paid
  def date_select
    @bill = Bill.find(params[:id])
    @added_penalty = @bill.calculate_penalties if (@bill.deadline < MyDate.today)
    render :layout => false
  end
  
  # This method is called when user will change rent
  # for rener and renter has defined an autopay for it.
  # When changing rent this metho will delete bills which
  # are in future and have old rent price and arent paid.
  def delete_bills
    renter = Renter.find(params[:id])
    if renter.belongs_to_user(session[:user_id])
      for bill_id in params[:delete] do
        bill = Bill.find(bill_id)
        if bill.belongs_to_user(session[:user_id])
          bill.destroy
          session[:bills].delete(bill.id)
        else
          next
        end
      end
      redirect_to :controller => '/manage_renter', :action => 'rent_info', :id => renter.id
    else
      redirect_to :controller => '/login', :action => 'logout'
    end
  end
  
  private
  
  # This action will gather options for displaying
  # bill table.
  def get_bills_info(bills_for)
    bills_info = {}
    false_id = false
    case bills_for
      when "renter"
        @renter = Renter.find(params[:id])
        if @renter.property.belongs_to_user(session[:user_id])
          bills_info[:owner] = :renter
          bills_info[:owner_id] = params[:id]
          bills_info[:action] = 'renter'
          @autopays = @renter.get_autopays
        else
          false_id = true
        end
      when "property"
        @property = Property.find(params[:id])
        if @property.belongs_to_user(session[:user_id])
          bills_info[:owner] = :property
          bills_info[:owner_id] = params[:id]
          bills_info[:action] = 'property'
          @penalties = User.get_penalties(session[:user_id])
          @autopays = @property.get_active_autopays
        else
          false_id = true
        end
    end
    
    if (false_id || !bills_for)
        bills_info[:owner] = :user
        bills_info[:owner_id] = session[:user_id]
        bills_info[:action] = 'pending'
    end
    
    return bills_info
  end
  
end
