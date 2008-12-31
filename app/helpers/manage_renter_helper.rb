module ManageRenterHelper

  def end_date(date)
    return "neni definovano" if !date
    if date == 0
      return "neurčito"
    else
      return MyDate.date_at(date)
    end
  end
  
  def show_renter_warnings(renter)
    return if renter.property.user_id != session[:user_id]
    output = ""
    # nema definovanu auto_platbu za najem
    if !renter.has_autopay_rent
      output = "<div class='warning'>
                  <b>Nájemník <i>#{ renter.full_name }</i> nemá definovanou automatickou platbu pro nájem.</b>
                </div>"
    end
    # konci mu najemni smlouva
    if ((renter.end_date > 0) && renter.end_date < (Time.now.to_i + 31) && !renter.has_closed_rent)
      days_to_end = MyDate::seconds_to_days(renter.end_date - Time.now.to_i)
      output += "<div class='warning'>
                  <b>Nájemníkovi <i>#{ renter.full_name }</i> zbýva #{days_to_end} dní do konce nájmu.</b>
                </div>"
    end
    # dluh
    if renter.debit[:amount] != 0
      output += "<div class='warning'>
                  <b>Nájemník <i>#{ renter.full_name }</i> má dluh #{number_to_currency(renter.debit[:amount], :unit => "CZK", :separator => ",", :delimiter => " ")}.</b>
                </div>"
    end
    # login
    if ((!renter.user_id) || (renter.user_id == 0))
      output += "<div class='warning'>
                  <b>Nájemník <i>#{ renter.full_name }</i> nemá vytvořené přihlašovací údaje.</b>
                </div>"
    end
    
    return output
  end
  
  def show_close_rent_warnings(renter)
    return if renter.property.user_id != session[:user_id]
    output = ""
    if renter.has_unpaid_bills
      output = "<div class='warning'>
                <b>Nájemník <i>#{ renter.full_name }</i> má nezaplacené platby. Celkem: #{renter.unpaid_bills.size}</b>
             </div>"
    end
    return output
  end
  
end
