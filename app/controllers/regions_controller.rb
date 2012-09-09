class RegionsController < Admin::BaseController
  before_filter :find_region, :only => [:show, :edit, :update, :destroy]
  before_filter :find_thing, :only => [:update, :create]
  
  def index
    @regions = Region.all
  end
  
  def new
    @region = Region.new
  end
  
  def create
    @region = Region.new(params[:region])
    
    if @region.save
      Version.init_for @region, {}
      flash[:notice] = "Region has been created."
      redirect_to @region
    else
      flash[:alert] = "Region has not been created."
      render :action => "new"
    end
  end
  
  def show
    @free_shape_sets = ShapeSet.all.reject {|shape_set| shape_set.regions.include? @region }
  end
  
  def edit
  end
  
  def update
    changes = []
    changes << :description and @region.aggr_update :tiny if params[:region][:description] and params[:region][:description] != @region.description
    changes << :name and @region.aggr_update (params[:update_size] or :major) if params[:region][:name] and params[:region][:name] != @region.name
    changes << :thing and @region.aggr_update :major if params[:region][:thing]  and params[:region][:thing] != @region.thing
    changes << :default_perspective and @region.aggr_update :tiny if params[:region][:default_perspective_id]
    
    if @region.update_attributes(params[:region])
      @region.do_versioning changes.to_s, current_user
      flash[:notice] = 'Region was successfully updated.'
      redirect_to :action => 'show', :id => @region
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    # because I decalred a decompositions method for Region
    @region.decompositions.each {|d| d.destroy }
    
    @region.destroy
    flash[:notice] = "Region has been deleted."
    redirect_to regions_path
  end
  
  
  private
    def find_region
      @region = Region.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The Region you were looking for could not be found."
      redirect_to regions_path
    end
    def find_thing
      return false unless params[:region][:thing]
      region_name =  params[:region][:thing].strip.gsub(/\s/,"_")
      params[:region][:thing] = Thing.where("name = ?",region_name).first
    end
  
end
