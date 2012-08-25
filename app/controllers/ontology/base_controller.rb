class Ontology::BaseController < ApplicationController
  before_filter :authorize_admin!, :only => [:new, :edit, :create, :update]
  before_filter :enable_admin_layout
  before_filter :enable_ontology_layout
  
  private
    def enable_admin_layout
      @admin_layout = true
    end
    def enable_ontology_layout
      @ontology_layout = true
    end
  
end
