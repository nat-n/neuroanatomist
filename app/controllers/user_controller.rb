class UserController < ApplicationController

  def index
    if request.method == "GET"
      user_page
    else
      submit_usage_data
    end
  end
  
  def user_page
    render :action => "user_page"
  end
  
  def submit_log_data
    params[:logs][:user] = (User.find(params[:logs][:user]).email rescue current_user.email) or current_user.email
    # update log count of this user to get the id of this log dump
    log_id = nil
    DataMailer.data(params[:logs],log_id).deliver
  end
  
end
