class DataMailer < ActionMailer::Base
  default from: "mailer@neuroanatomist.org"
  
  def feedback(subject,msg,user=nil,reply_to=nil)
    @user = user
    @subject = subject
    @msg = msg
    reply_to ||= (@user ? @user.email : nil)
    mail(:to => ENV['feedback_address'], :reply_to => reply_to, :subject => "#{subject}")
  end
  
  def data(data,data_id="")
    mail( :to => ENV['data_address'], :subject => "data:#{data_id}") { render :text => JSON.dump(data) }
  end
  
end
