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
  
  def create
    ont_data =  JSON.load(params[:ontology_data_file].read)
    raise "Invalid input file" unless ont_data["type"] == "ontology"
    version = ont_data["version"]
    import_type ont_data["root_type"]
    render :action => :index
  end
    
  private
    def root_types # there should be only one
      @root_types = Type.where "id = supertype_id"
    end
    
    def import_type type_data, super_type=nil
      existing_type = Type.where("name = ?",type_data["name"]).first
      #if not existing_type
      #  existing_type = Type.new(:name=>"Thing", :description=>"The root type of all things.", :supertype_id=>1).save(:validate => false)
      #  existing_type.save :validate => false
      #  # should make sure this was done right!!!
      #end
      if !super_type
        @root_types.each { |rt| rt.update_attribute(:description,type_data["description"]) unless rt.description == type_data["description"] }
      elsif existing_type
        existing_type.update_attribute :description, type_data["description"] unless existing_type.description == type_data["description"]
        existing_type.update_attribute(:supertype_id, 2) unless existing_type.supertype.name == super_type["name"]
      else
        existing_type = Type.create(:name => type_data["name"], :description => type_data["description"], :supertype => super_type)
      end
      
      for thing in type_data["instances"] do
        existing_thing = Thing.where("name = ?",thing["name"]).first
        tag = (Tag.where("name = ?",thing["name"]).first or Tag.create(:name=>thing["name"]))
        node = (Node.where("name = ?",thing["name"]).first or Node.create(:name => thing["name"], :tag => tag))
        regions = thing["regions"].map {|rn| Region.where("name = ?", rn).first or Region.create(:name => rn) }.compact
        if existing_thing
          existing_thing.update_attributes(:description       => thing["description"],
                                           :synonyms          => thing["synonyms"],
                                           :neurolex_category => thing["neurolex_category"],
                                           :dbpedia_resource  => thing["dbpedia_resource"],
                                           :wikipedia_title   => thing["wikipedia_title"],
                                           :type_id           => existing_type.id)
          existing_thing.regions = regions
        else
          new_thing = Thing.create(:name              => thing["name"],
                                   :description       => thing["description"],
                                   :synonyms          => thing["synonyms"],
                                   :neurolex_category => thing["neurolex_category"],
                                   :dbpedia_resource  => thing["dbpedia_resource"],
                                   :wikipedia_title   => thing["wikipedia_title"],
                                   :type_id           => existing_type.id)
          node.update_attribute :thing_id, new_thing.id
          new_thing.regions = regions
        end
      end
      
      for subtype in type_data["subtypes"] do
        import_type subtype, existing_type
      end
    end
end
