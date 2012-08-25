class Admin::BaseController < ApplicationController
  before_filter :authorize_admin!
  before_filter :enable_admin_layout
  
  def index
    
  end
  
  private
    def enable_admin_layout
      @admin_layout = true
    end
end