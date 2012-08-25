class RegistrationsController < Devise::RegistrationsController
  before_filter :authorize_admin!, :only => [:new, :create, :cancel]
  
  layout 'admin_areas'
  
end
