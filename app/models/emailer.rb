class Emailer < ActionMailer::Base

  def info(renter)
    @subject    = 'Testovaci info mail'
    @body["renter"] = renter
    @recipients = 'rada3@azet.sk'
    @from       = 'rada13@gmail.com'
    @sent_on    = Time.now
  end

  def sent(sent_at = Time.now)
    @subject    = 'Emailer#sent'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end
end
