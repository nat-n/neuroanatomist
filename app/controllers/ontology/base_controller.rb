class Ontology::BaseController < ApplicationController
  before_filter :authorize_admin!, :only => [:new, :edit, :create, :update]
  
  layout 'admin_areas'
  
end
