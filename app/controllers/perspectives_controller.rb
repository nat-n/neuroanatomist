class PerspectivesController  < Admin::BaseController
  before_filter :find_perspective, :only => [:show, :edit, :update, :destroy]
  before_filter :find_regions, :only => [:new, :edit]

  def index
    @perspectives = Perspective.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @perspectives }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { export }
    end
  end
  
  def export
    send_data JSON.dump( Hash[ type: "perspective",
                               version: 0.1,
                               timestamp: Time.now,
                               perspective: @perspective.description_hash ]),
              :filename => "perspective_#{@perspective.name}.json"
  end
  
  def new
    @perspective = Perspective.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @perspective }
    end
  end

  def edit
  end

  def create
    if params.has_key? "perspective_file"
      contents = JSON.load params["perspective_file"].read
      unless contents["type"] == "perspective"
        redirect_to "index", notice: 'Invalid perspective file'
        return
      end
      Perspective.create_from_description contents["perspective"]
      @perspectives = Perspective.all
      render action: "index"
      return true
    end
    
    @perspective = Perspective.new(params[:perspective])
    
    respond_to do |format|
      if @perspective.save
        update_region_styles
        Version.init_for @perspective, {}
        format.html { redirect_to @perspective, notice: 'Perspective was successfully created.' }
        format.json { render json: @perspective, status: :created, location: @perspective }
      else
        format.html { render action: "new" }
        format.json { render json: @perspective.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @changes = []
    (@changes << :description and @perspective.aggr_update :tiny ) if params[:perspective][:description]    != @perspective.description
    (@changes << :name        and @perspective.aggr_update :tiny ) if params[:perspective][:name]           != @perspective.name
    (@changes << :params      and @perspective.aggr_update :major) if params[:perspective][:height].to_f    != @perspective.height or
                                                                    params[:perspective][:angle].to_f     != @perspective.angle or
                                                                    params[:perspective][:distance].to_f  != @perspective.distance
    update_region_styles
        
    respond_to do |format|
      if @perspective.update_attributes(params[:perspective])
        @perspective.do_versioning @changes.to_s, current_user 
        
        format.html { redirect_to @perspective, notice: 'Perspective was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @perspective.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @perspective.destroy

    respond_to do |format|
      format.html { redirect_to perspectives_url }
      format.json { head :ok }
    end
  end
    
  private
    def find_perspective
      @perspective = Perspective.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The Perspective you were looking for could not be found."
      redirect_to perspectives_path
    end
    def find_regions
      @regions = Region.all      
    end
    def update_region_styles
      # should create, update and disown region styles as required, unless inheritance set
      
      @changes << :inheritance and @perspective.aggr_update :major if params[:inherit_style_set].to_i != (@perspective.style_set.id rescue 0)
      
      if params[:inherit_style_set] != 0 and (style_set_id = params[:inherit_style_set].to_i)>0
        @perspective.use_external_styles Perspective.find(style_set_id)
        params[:regions].each do |rstr, inclusion|
          @perspective.disown_region_if_styled Region.find(rstr.split("_").last.to_i)
        end
      else
        params[:regions].each do |rstr, inclusion|
          region_id = rstr.split("_").last.to_i
          region = Region.find(region_id)
          
          
          
          if (inclusion == "1" and (!@perspective.style_for(region) or (@perspective.style_for(region) and @perspective.style_for(region).orphaned == true))) or
              (inclusion == "0" and @perspective.style_for(region) and @perspective.style_for(region).orphaned == false)
            @changes << :region and @perspective.aggr_update :major
          end
          
          if inclusion == "1" and
            @perspective.update_or_create_region_style :colour       => params[:colour][rstr],
                                                       :transparency => params[:transparency][rstr],
                                                       :label        => params[:label][rstr] == "1",
                                                       :region       => region
          else
            @perspective.disown_region_if_styled region
          end
        end
      end
    end
    
end
