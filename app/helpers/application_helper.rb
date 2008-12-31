# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper  
  include LocalizeHelper
  
  def photo(image, default_image)
    if (image && (image != ''))
      return image
    else
      return default_image
    end
  end
  
  def hidden_div_if(condition, attributes = {})
    if condition 
      attributes["style"] = "display: none"
    end
    
    attrs = tag_options(attributes.stringify_keys)
    return "<div #{attrs}>"
  end
  
  def selected_option_if(condition, attributes = {})
    if condition
      attributes["selected"] = "selected"
    end
    
    attrs = tag_options(attributes.stringify_keys)
    if attributes[:name]
      return "<option #{attrs}>#{attributes[:name]}</option>"
    else
      return "<option #{attrs}>#{attributes[:value]}</option>"
    end
  end
  
  def selected_option2_if(condition, attributes = {})
    if condition
      attributes["selected"] = "selected"
    end
    
    attrs = tag_options(attributes.stringify_keys)
    return "<option #{attrs}>"
  end
  
  def checked_checkbox_if(condition, attributes = {})
    if condition
      attributes["checked"] = "checked"
    end
    
    attrs = tag_options(attributes.stringify_keys)
    return "<input type=\"checkbox\" #{attrs}/>"  
  end
  
  def checked_radio_if(condition, attributes = {})
    if condition
      attributes["checked"] = "checked"
    end
    
    attrs = tag_options(attributes.stringify_keys)
    return "<input type=\"radio\" #{attrs}/>"  
  end
  
  def onclick_option_if(condition, function, attributes = {})
    if condition
      attributes[:onclick] = function
    end
   
    attrs = tag_options(attributes.stringify_keys)
    if attributes[:name]
      return "<option #{attrs}>#{attributes[:name].to_s}</option>"
    else
      return "<option #{attrs}>#{attributes[:value].to_s}</option>"
    end
  end
  
  def najem_h(property)
    return number_to_currency(property.rent, :unit => "CZK", :separator => ",", :delimiter => " ")
  end
  
  def search_settings_for_bills(settings_from_params)
    settings = {}
    if settings_from_params
      settings[:sort_by]        = settings_from_params[:settings]["sort_by"]
      settings[:sort_direction] = settings_from_params[:settings]["sort"].to_sym
      settings[:date_from]      = settings_from_params[:settings]["date_from"]
      settings[:date_to]        = settings_from_params[:settings]["date_to"]
      settings[:bills_type]     = settings_from_params[:settings]["bills"]
      settings[:get_by_date]    = true if settings_from_params[:settings]["include_date"]
    else
      settings[:sort_by] = "deadline"
      settings[:sort_direction] = :ASC
      settings[:date_from] = settings[:date_to] = Time.now
    end
  end
  
  def title(title_text)
    content_for(:title){ title_text }
  end
  
  def submenu(menu_path)
    content_for(:submenu){ render menu_path}
  end
  
  def paginated_entries_info(collection, options={})
    entry_name = options[:entry_name] ||
        (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))
      
    if collection.total_pages < 2
      case collection.size
      when 0; "#{get_string(:None)} #{entry_name.pluralize} #{get_string(:found)}"
      when 1; "#{get_string(:Displaying)} <b>1</b> #{entry_name}"
      else;   "#{get_string(:Displaying)} <b>#{get_string(:all)} #{collection.size}</b> #{entry_name.pluralize}"
      end
    else
      %{#{get_string(:Displaying)} <b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b> #{get_string(:in_total)}} % [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ]
    end
  end
end





