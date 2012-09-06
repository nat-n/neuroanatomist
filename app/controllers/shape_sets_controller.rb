class ShapeSetsController  < Admin::BaseController
  before_filter :find_shape_set, :only => [:show, :edit, :update, :destroy]
  before_filter :find_or_create_default_perspective, :only => [:create, :update]
  before_filter :update_descriptors, :only => [:update]
  
  include S3Helper
  
  def index
    @shape_sets = ShapeSet.all
  end
  
  def new
    @shape_set = ShapeSet.new
  end
  
  def create
    shape_data = params[:shape_set].delete(:shape_data_file)
    new_version = params[:version][:version]
    @shape_set = ShapeSet.new(params[:shape_set])
    if @shape_set.validate_and_save shape_data, new_version, current_user
      @shape_set.default_perspective= @perspective
      @shape_set.save_shape_data
      @shape_set.generate_geometric_descriptions
      @shape_set.copy_region_definitons_from @shape_set.previous_version rescue nil
      flash[:notice] = "Shape Set has been created."
      redirect_to @shape_set
    else
      flash[:alert] = "Shape Set has not been created."
      render :action => "new"
    end
  end
  
  def show
    @shapes = @shape_set.shapes
  end
  
  def edit
  end
    
  def update
    notes = params[:shape_set][:notes]
    @shape_set.default_perspective = @perspective
    if notes and @shape_set.update_attribute :notes, notes
      @shape_set.aggr_update :tiny
      flash[:notice] = "Shape Set has been updated."
      redirect_to @shape_set
    else
      flash[:alert] = "Shape Set has not been updated."
      render :action => "edit"
    end
    @shape_set.do_versioning @shape_set.notes, current_user
  end
  
  def destroy
    # delete mesh data from filesystem and the subject folder if this is the only version of this subject
    #if ShapeSet.where("subject == '#{@shape_set.subject}'").length == 1
    #  FileUtils.rm_rf @shape_set.data_path[0...-@shape_set.subject.size]
    #else
    #  FileUtils.rm_rf @shape_set.data_path
    #end
    S3Helper.destroy_dir @shape_set.data_path
    
    @shape_set.jax_data.each {|jd| jd.destroy }
    
    @shape_set.destroy
    
    flash[:notice] = "Shape Set has been deleted."
    redirect_to shape_sets_path
  end
  
  private
    def find_shape_set
      @shape_set = ShapeSet.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The shape set you were looking for could not be found."
      redirect_to shape_sets_path
    end
    
    def find_or_create_default_perspective
      @perspective = if params[:default_perspective] == "Create new empty perspective"
        Perspective.create :name => "new perspective #{Time.now.strftime("%Y%m%d%H%M%S%L")}"
      else
        Perspective.where("name = ?", params[:default_perspective]).first
      end
    end
    
    def update_descriptors
      # updates radius center_point
      return unless params[:center_point] and params[:shape_set][:radius]
      if params[:shape_set][:radius] != params[:shape_set][:radius].to_f or center_point != JSON.dump([params[:center_point][:x].to_f,params[:center_point][:y].to_f,params[:center_point][:z].to_f])
        @shape_set.aggr_update :minor
        @shape_set.update_attribute :radius, params[:shape_set][:radius].to_f
        @shape_set.update_attribute :center_point, JSON.dump([params[:center_point][:x].to_f,params[:center_point][:y].to_f,params[:center_point][:z].to_f])
      end
    end
    
end
