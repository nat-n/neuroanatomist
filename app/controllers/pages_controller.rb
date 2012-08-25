class PagesController < ApplicationController
    
  def home
    render :debug and return if params.has_key? "debug"
  end
  
  def about
    
  end
  
  def contact
    
  end
  
end
