class Renters::FinancesController < ApplicationController
  
  layout 'renter'
  
  # This action shows bills management page to user
  # It displays bills according to users settings on
  # from page
  def bills
    @autopays = AutoPay.find(:all, :conditions => ["renter_id = ?", @renter.id ])
    @bills_to_show = Bill.find(:all, :conditions => ["renter_id = ?", @renter.id])
    settings_from_page = Bill.settings_for_bills(params[:settings])    
    settings_from_page[:bills_type] = params[:show] if !settings_from_page[:bills_type]
                                    # v params[:show] je parameter na zobrazenie plateb, pokud 
                                    # prichazime na stranku cez html odkaz a nie cez Ajax
    case settings_from_page[:bills_type]
    when 'debit'
      @bills_to_show = @renter.get_pending_bills(settings_from_page, params[:page])
    when 'month'
      @bills_to_show = @renter.get_bills_for_month(settings_from_page, params[:page])
    when 'all'
      @bills_to_show = @renter.get_all_bills(settings_from_page, params[:page])
    when 'pending'
      @bills_to_show = @renter.get_pending_bills(settings_from_page, params[:page])
    when 'paid'
      @bills_to_show = @renter.get_paid_bills(settings_from_page, params[:page])
    end
    # vygenerovat autoplatby!!!!
    if (params["search"])
      @bills_to_show = Bill.search_for(settings_from_page[:search_phrase], @bills_to_show)
    end
    session[:bills] = Bill.get_ids_from_bills(@bills_to_show)    
    
    if request.xhr?
      render :update do |page|
        page[:bills_table].replace_html :partial => 'pending_bills_table'
        page[:pages].replace_html :partial => '/finances/page_select'
      end
    end
  end
  
  # This action will pay bills which user has
  # marked as paid on the page in finances section.
  def process_bills
    TempBill.pay_bills(params[:late], 
                       params[:wait], 
                       params[:date], 
                       params[:partial_prices], 
                       params[:penalty], 
                       params[:notes])
    @bills_to_show = Bill.paginate(session[:bills], :page => 1)
    @bills_to_show = Bill.remove_paid_bills_from(@bills_to_show)
    session[:bills] = Bill.get_ids_from_bills(@bills_to_show)
    render :partial => 'pending_bills_table'
  end
  
  # Action will display info about bill which was already
  # paid. It will display time when it was paid and also price
  def show_temp_bills
    @bill = Bill.find(params[:id])
    if @bill.property.renters.include?(@renter)
      render :partial => 'temp_bill'
    else
      render :text => '.'
    end
  end
  
  # Deletes temp_bill from database
  def delete_temp_bill
    @bill = Bill.find(params[:id])
    if @bill.belongs_to_renter(@renter.id)
      @bill.delete_temp_bills
    else
      logout
    end
  end
  
  # Displays infromation about users rent in
  # property
  def rent_info
    
  end
  
end