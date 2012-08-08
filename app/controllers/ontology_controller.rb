class OntologyController < ApplicationController
  before_filter :root_types
  
  def index
    respond_to do |format|
      format.html # new.html.erb
      format.json { export }
    end
  end
  
  def export
    send_data render_to_string("export.json")
  end
    
  private
    def root_types # there should be only one
      @root_types = Type.where "id = supertype_id"
    end
end
