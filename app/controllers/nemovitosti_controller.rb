require 'mydate'

class NemovitostiController < ApplicationController
  
  before_filter :check_user_is_admin
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  verify :params => 'id', :only => :detail,
         :redirect_to => {:action => :index}
         
  # Displays index page for properties
  def index
    @properties = User.get_properties(session[:user_id])
    @renters = User.get_renters(session[:user_id])    
    render :layout => 'application'
  end

  # Renders page with properties table
  def list
    @properties = User.get_properties(session[:user_id])
  end

  # Add contact to given property
  def add_contacts
    property = Property.find(params[:id])
    if property.belongs_to_user(session[:user_id])
      if params[:contacts]
        contacts = Contact.find(params[:contacts])
        contacts.each{|contact|
          if @user.contacts.include?(contact)
            property.contacts << contact
          end
        }
      end
      redirect_to :action => 'fittings', :id => params[:id]
    else
      logout
    end
  end
  
  # Displays form for creating new rent
  def new
    @administrators = User.get_administrators(session[:user_id])
    @property = Property.new
  end
  
  # Displays information about given property, address, name,
  # renters etc.
  def detail
    @property = Property.find(params[:id])
    if @property.belongs_to_user(session[:user_id])
      @todos = Todo.return_todos(@property)
    else
      logout
    end
  end
  
  # Displays form for editing property's infromation
  def edit
    @property = Property.find(params[:id])
    if @property.belongs_to_user(session[:user_id])
      @administrators = Contact.find(:all, :conditions => ["typ = ?", :administrator])
    else
      logout
    end
  end
  
  # This action displays informations about nummber
  # of rooms in property and list of accommodated
  # renters. It is called remote by Ajax when moving
  # renter to new property
  def property_info
    @property = Property.find(params[:id])
    if @property.belongs_to_user(session[:user_id])
      render :layout => false
    else
      logout
    end
  end
  
  # This action shows user information about property's
  # renters and autopays and allows him to decide what to
  # do with them(delete autopays, move renters etc.)
  # before closing property
  def close_settings
    @property = Property.find(params[:id])
    if @property.belongs_to_user(session[:user_id])
      @autopays = @property.auto_pays
    else
      logout
    end
  end
  
  def accommodation_history
  end
  
  # This action closes property which means, that user
  # won't be able to accomodate rentes in it but can
  # change its attributes. Before closing property this
  # action will take care of its renters and autopays
  # according to settings from user on webpage.
  def close_property
    property = Property.find(params[:id])
    if property.belongs_to_user(session[:user_id])
      property.process_renters(params[:renter_action], params[:property_id], session[:user_id])
      property.stop_autopays(params[:autopays], session[:user_id])
      property.close(Time.now)
      flash[:notice] = LocalizeHelper::get_string(:Property_has_been_succesfully_closed)
      redirect_to :action => 'detail', :id => property
    else
      logout
    end
  end
  
  # This action will marke given closed property
  # as open and user will be able to accommodate
  # renters in it
  def open
    property = Property.find(params[:id])
    if (property.belongs_to_user(session[:user_id]) &&
        property.is_closed)
      property.update_attribute({:closed => 0})
    else
      logout
    end
  end
  
  # Displays history of accommodated renters
  # in property and also actully accommodated
  # renters
  def accommodation_history
    @property = Property.find(params[:id])
    if !@property.belongs_to_user(session[:user_id])
      logout
    end
  end
  
  # Renders evidence list for property
  def evidence_list
    @property = Property.find(params[:id])
    if !@property.belongs_to_user(session[:user_id])
      logout
    end
  rescue
    redirect_to :action => 'list'
  end
  
  # This action will display information about property's
  # fittings, accessories, rooms and additional infos. Also
  # multiple form for adding room, accessory, service, contact
  # or additional info is displayed
  def fittings
    @property = Property.find(params[:id])
    if @property.belongs_to_user(session[:user_id])
      @additionals = @property.get_additionals
      @properties = User.get_properties(session[:user_id])
    else
      logout
    end
  end
  
  # Adds accessory to property
  def add_accessory
    property = Property.find(params[:id])
    if property.belongs_to_user(session[:user_id])
      accessory = Accessory.new(params[:accessory])
      accessory.property_id = property.id
      if accessory.save
        flash[:notice] = LocalizeHelper::get_string(:Item_succesfully_saved)
      else
        flash[:notice] = "Error"
      end
      redirect_to :action => 'fittings', :id => property.id      
    else
      logout
    end
  end
  
  def delete_accessory
    accessory = Accessory.find(params[:id])
    if accessory.belongs_to_user(session[:user_id])
      property_id = accessory.property.id
      if accessory.destroy
        flash[:notice] = LocalizeHelper::get_string(:Item_succesfully_deleted)
      else
        flash[:notice] = LocalizeHelper::get_string(:Error_deleting_item)
      end
      redirect_to :action => 'fittings', :id => property_id
    end
  end
  
  def edit_accessory
    @accessory = Accessory.find(params[:id])
    @property = @accessory.property
    if @accessory.belongs_to_user(session[:user_id])
      if params[:edit]
        @accessory.update_attributes(params[:accessory])
        redirect_to :action => 'fittings', :id => @property
      end
    else
      logout
    end
  end
  
#  def update_accessories
#    @property = Property.find(params[:id])
#    if @property.belongs_to_user(session[:user_id])
#      @accessories = @property.accessories
#      for accessory in @property.accessories
#        accessory.update_attributes(params[accessory.id.to_s])
#      end
#    else
#      logout
#    end
#    redirect_to(:action => 'fittings', :id => params[:id])
#  end
  
  # Creates new room and ads it to property. 
  def add_room
    property = Property.find(params[:id])
    if property.belongs_to_user(session[:user_id])
      room_area = RoomArea.new(params[:room_area])
      room_area.property_id = property.id
      if room_area.save
        redirect_to :action => 'fittings', :id => property.id
      else
        flash[:notice] = "Error saving room"
        redirect_to :action => 'fittings', :id => property.id
      end
    else
      logout
    end
  end
  
  # This action updates infromation about room areas in
  # given room or rooms.
  def update_rooms
    @property = Property.find(params[:id])
    if @property.belongs_to_user(session[:user_id])
      @room_areas = @property.room_areas
      for room_area in @property.room_areas
        room_area.update_attributes(params[room_area.id.to_s])
      end
    else
      redirect_to :action => 'list'
    end
    redirect_to(:action => 'fittings', :id => params[:id])
  end
  
  def delete_room
    room_area = RoomArea.find(params[:id])
    property_id = room_area.property.id
    if room_area.belongs_to_user(session[:user_id])
      room_area.destroy
      redirect_to :action => 'fittings', :id => property_id
    end
  end
  
  def add_fitting
    @fitting = Fitting.new(params[:fitting])
    if @fitting.save
      flash[:notice] = 'Fitting succesfully added'
      redirect_to(:action => 'fittings', :id => @fitting.property_id)
    else
      @property = Property.find(params[:id])
      @additionals = @property.get_additionals
      @properties = Property.find(:all, :conditions => ["user_id = ?", session[:user_id]])
      render :action => 'fittings'
    end
  end
  
  # This action is called from AJAX and displays
  # attributes about given fitting.
  def fitting_detail
    @fitting = Fitting.find(params[:id])
    render :update do |page|
      page[params[:id].to_sym].replace_html :partial => 'fit_detail'
      page[params[:id].to_sym].visual_effect :appear
    end
  end
  
  def show_fitting_edit_form
    @fitting = Fitting.find(params[:id])
    if @fitting.belongs_to_user(session[:user_id])
      @properties = User.get_properties(session[:user_id])
      @property = @fitting.property
      render :partial => 'edit_fitting'
    else
      logout
    end
  end
  
  def edit_fitting
    @fitting = Fitting.find(params[:id])
    if @fitting.belongs_to_user(session[:user_id])
#      property = fitting.property
      @fitting.update_attributes(params[:fitting])
      render :update do |page|
        page["fitting#{@fitting.id}"].replace_html :partial => "fitting_brief"
        page["fitting#{@fitting.id}"].visual_effect :highlight
      end
    else
      logout
    end
  end
  
  def destroy_fitting
    fitting = Fitting.find(params[:id])
    property = fitting.property.id
    fitting.destroy
    redirect_to :action => 'fittings', :id => property
  end
  
  # This action creates new property
  def create
    @property = Property.new(params[:property])
    @property.user_id = session[:user_id]
    if @property.save
      @property.create_rooms(params[:rooms])
      flash[:notice] = LocalizeHelper::get_string(:Property_was_successfully_created)
      redirect_to(:action => 'detail', :id => @property)
    else
      @administrators = User.get_administrators(session[:user_id])
      render :action => 'new'
    end
  end  
  
  # Updates property's attributes
  def update
    @property = Property.find(params[:id])
    if @property.user_id != session[:user_id]
      redirect_to :action => 'list' 
    else
      if @property.update_attributes(params[:property])
        if params[:rooms]  
          for room_id in params[:rooms]
            room = Room.find(room_id)
            @property.rooms << room if !@property.rooms.include?(room)
          end
        end
        @property.save
        flash[:notice] = 'Property was successfully updated.'
        redirect_to :action => 'detail', :id => @property
      else
        render :action => 'edit'
      end
    end
  end
  
  # Creates a note and adds it to property
  def add_note
    note = Note.new(:type_id => params[:id],:content => params[:note][:content])
    note.owner = :property
    if note.save
      flash[:notice] = "Note succesfully added"
    else
      flash[:notice] = "Note save failed"
    end  
      redirect_to :action => 'detail', :id => params[:id]
  end
  
  def logout
    redirect_to :controller => 'login', :action => 'logout'
  end
  
  # Deletes given property. Also with all its asociated
  # fittings, accessories, renters, bills etc.
  def delete
    @property = Property.find(params[:id])
    if @property.belongs_to_user(session[:user_id])
      if (params[:commit] != "" && params[:data])
        @property.delete_data(params[:data])
        @property.destroy
        redirect_to :action => 'list'
      end
    else
      logout
    end
  end
  
  # When deleting property this method will show
  # what else what is asociated with property 
  # can and will be deleted.
  def show_data
    @property = Property.find(params[:id])
    case params[:data]
      when "todos"
        @todos = @property.todos
        render :partial => 'list_todo'
      when "fittings"
        render :partial => 'fittings_list'
      when "services"
        render :partial => 'accessories_table', :locals => {:typ => :service}
      when "accessories"
        render :partial => 'accessories_table', :locals => {:typ => :accessory}
      else
        render :text => LocalizeHelper::get_string(:No_data_selected)
      end
  end
  
end