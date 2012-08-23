class Admin::BaseController < ApplicationController
  before_filter :authorize_admin!
  
  layout 'admin_areas'
  
  def index
    
  end
end