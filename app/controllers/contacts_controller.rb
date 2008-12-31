class ContactsController < ApplicationController
  before_filter :check_user_is_admin
  
  def list
    @contacts = Contact.find(:all, :conditions => ["user_id = ?", session[:user_id]], :order => "typ ASC")
  end
  
  def add_contact
    contact = Contact.new(params[:contact])
    contact.user_id = session[:user_id]
    if contact.save
      flash[:notice] = "Contact_succesfully_saved"
      redirect_to :action => 'list'
    else
      flash[:error] = "Error_saving_contact"
      @contacts = Contact.find(:all, :conditions => ["user_id = ?", session[:user_id]], :order => "typ ASC")
      render :action => 'list'
    end
  end
  
  def delete
    contact = Contact.find(params[:id])
    if contact.belongs_to_user(session[:user_id])
      contact.destroy
      redirect_to :action => 'list'
    else
      logout
    end
  end
  
end
