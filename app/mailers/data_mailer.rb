class DataMailer < ActionMailer::Base
  default from: "mailer@neuroanatomist.org"
  self.async = true
  
  def feedback(subject,msg,user=nil)
    @user = user
    @subject = subject
    @msg = msg
    reply_to = (@user ? @user.email : nil)
    mail(:to => ENV['feedback_address'], :subject => "#{subject}")
  end
  
  def data(data,data_id="")
    mail( :to => ENV['data_address'], :subject => "#{data_id}") { render :text => JSON.dump data }
  end
  
end
