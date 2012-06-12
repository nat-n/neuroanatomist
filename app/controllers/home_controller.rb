class HomeController < ApplicationController
  
  def index
    render :debug and return if params.has_key? "debug"
  end
  
end
