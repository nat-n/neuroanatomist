class UserController < ApplicationController

  def index
    if request.method == "GET"
      user_page
    else
      submit_usage_data
    end
  end
  
  def user_page
    
  end
  
  def submit_log_data
    params[:logs]
  end
  
end
