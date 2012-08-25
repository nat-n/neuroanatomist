class Admin::BaseController < ApplicationController
  before_filter :authorize_admin!
  before_filter :use_admin_layout
  
  
  #layout 'admin_areas'
  
  def index
    
  end
  
  private
    def use_admin_layout
      @admin_layout = true
    end
end