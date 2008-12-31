module NemovitostiHelper
      
  def photo_h(foto)
    if (foto == nil)or(foto == '') 
      return "img_properties/default.jpg"
      else return "img_properties/" + foto
    end
  end
  
  def address_brief_h(property)
    @property = Property.find(property)
    
    return "<b>" + @property.name + "</b> <br />" +
           @property.address.gsub(/\n/,"<br />") +
           "<br />" +
           @property.city +
           "<br />"            
  end
  
  def address_h
    return "<b>" + @property.name + "</b> <br />" +
           @property.address.gsub(/\n/,"<br>") +
           "<br />" +
           @property.city + " - " + @property.locality +
           "<br />" +
           @property.psc.to_s  
    end
  
  def najem_h
    return number_to_currency(@property.rent, :unit => "CZK", :separator => ",", :delimiter => " ")
  end
  
  def fees_h
    return number_to_currency(@property.fees, :unit => "CZK", :separator => ",", :delimiter => " ")
  end
  
#  def note_h
#    if @property.note
#      return @property.note.gsub(/\n/,"<br/>")
#    end
#  end
  
  def warning(renters)
    return "Nemovitost nema evidovane najemniky" if renters == []
    return "Součet nájmů jednotlivých nájemníků je menší než požadovaný nájem pro nemovitost"
  end
  
  def show_warnings(property_id)
    property = Property.find(property_id)
    output = ""
    # kontrola, ktore udaje nie si vyplnene pre danu nemovitost
    if @property.renters == []
      output += "<div class='warning'>
                  <b>Nemovitost <i>#{property.name}</i> nemá evidované nájemníky</b>
                </div>"
    end
    if @property.renters_rent < @property.rent
      output += "<div class='warning'>
                  <b>Součet nájmů jednotlivých nájemníků je menší než požadovaný nájem pro nemovitost</b>
                </div>"
    end
    
    missing_data_count = 0
    excluded_columns = ["Photo", "Locality", "Closed", "Show fittings"]
    columns = []
    for column in Property.content_columns
      if (!property.send(column.name) || property.send(column.name) == "")
        excluded_columns.include?(column.human_name) ? next : columns << get_string(column.human_name.to_sym)
        missing_data_count += 1
      else
        next
      end  
    end
    if @property.owner_id == 0
      missing_data_count += 1
      columns << get_string(:Owner)
    end
    if @property.administrator_id == 0
      missing_data_count += 1
      columns << get_string(:Administrator)
    end
    if missing_data_count > 0
      output += "<div class='warning'>
                  <b>Nemovitosti <i>#{ property.name }</i> chybí <a href='#' onclick=\"$('missing').toggle()\">#{missing_data_count} údajů</a>:<br/>
                  <div id='missing' style=\"display: none\">
                  <ul><li>#{columns.join("</li><li>")}</li>
                  </b>
                  <a href='/nemovitosti/edit/#{property_id}'>Doplnit údaje</a></div>
                </div>"
    end
    return output
  end
  
end























