class AdditionalController < ApplicationController
  before_filter :check_user_is_admin
  
  # This action will add new additional information to
  # property or renter.
  def add_additional
    additional = Additional.new(params[:additional])
    additional.type_id = params[:id]
    additional.owner = params[:owner]
    if params[:owner] == 'property'
      property = Property.find(params[:id])
      redirect_to :controller => 'nemovitosti', :action => 'index' if property.user_id != session[:user_id]
    else
      renter = Renter.find(params[:id])
      redirect_to :controller => 'manage_renter', :action => 'index' if renter.property.user_id != session[:user_id]
    end
    if additional.save
      flash[:notice] = 'Additional record succesfully added'
      if params[:owner] == 'renter'
        redirect_to :controller => 'manage_renter', :action => 'renter', :id => params[:id]
      else
        redirect_to :controller => 'nemovitosti', :action => 'fittings', :id => params[:id]
      end
    else
      flash[:notice] = 'Error saving additional record'
    end
  rescue
    redirect_to :controller => 'login', :action => 'index'
  end
  
  def update_additional
    additional = Additional.find(params[:id])
    if additional.belongs_to_user?(session[:user_id])
      if (params[:additional][:name]=='' && params[:additional][:content]=='')
        additional.destroy
      else
        additional.update_attributes(params[:additional])
      end
     
      if additional.owner == :property
        redirect_to :controller => 'nemovitosti', :action => 'fittings', :id => params[:owner_id]
      else
        redirect_to :controller => 'manage_renter', :action => 'renter', :id => params[:owner_id]
      end
    else
      redirect_to :index
    end    
  end
  
  def edit_additional
    @additional = Additional.find(params[:id])
    if !@additional.belongs_to_user?(session[:user_id])
      redirect_to :action => 'index'
    end
  end
  
  def delete_additional
    additional = Additional.find(params[:id])
    if additional.belongs_to_user?(session[:user_id])
      if additional.owner == :property
        controller = 'nemovitosti'
        action = 'fittings'
      else
        controller = 'manage_renter'
        action = 'renter'
      end
      id = additional.type_id
      additional.destroy
      redirect_to :controller => controller, :action => action, :id => id
    else
      redirect_to :controller => 'login', :action => 'logout'
    end
  end
  
end
