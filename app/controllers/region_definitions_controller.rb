class RegionDefinitionsController < ApplicationController
  before_filter :find_region_definition, :only => [:show, :edit, :update, :destroy]
  before_filter :validate_region_and_shape_set, :only => [:create]
  
  layout 'admin_areas'
  
  def index
    redirect_to @region_definition.region rescue
    redirect_to RegionDefinition.find(params[:id]) rescue
    redirect_to @region rescue
    redirect_to regions_path
  end
  
  def new
    # must be provided with a shape_set and region
    begin
      @shape_set = ShapeSet.find(params[:shape_set])
    rescue 
      flash[:alert] = "Valid shape set required to create a region definition"
      redirect_to :back rescue redirect_to region_definitions_path
      return
    end
    begin
      @region = Region.find(params[:region])
    rescue
      flash[:alert] = "Valid region required to create a region definition"
      redirect_to :back rescue redirect_to region_definitions_path
      return
    end
    
    @region_definition = RegionDefinition.new
  end
  
  def create
    @region_definition = RegionDefinition.new(params[:region_definition])
    
    params[:shapes].each do |shape_id, inclusion|
      next unless inclusion == "1" and (shape_id = shape_id.split("_").last.to_i) > 0
      @region_definition.shapes << Shape.find(shape_id)
    end
    
    if @region_definition.save
      flash[:notice] = "Region definition has been created."
      redirect_to @region_definition
    else
      flash[:alert] = "Region definition has not been created, It may have already existed"
      redirect_to @region rescue redirect_to @region_definition.region rescue redirect_to @region_definition
    end
  end
  
  def show
    if (params["format"] == "obj" rescue false)
      @mesh = RegionDefinition.find params[:id]
      render :text => @mesh.to_obj, :layout  => nil
      return true
    end
  end
  
  def edit
    @region = @region_definition.region
    @shape_set = @region_definition.shape_set
    @shape_ids = @region_definition.shapes.map { |x| x.id }
  end
  
  def update
    params[:region_definition].delete :region
    params[:region_definition].delete :shape_set
    if @region_definition.update_attributes(params[:region_definition])
      @region_definition.shapes.clear
      params[:shapes].each do |shape_id, inclusion|
        next unless inclusion == "1" and (shape_id = shape_id.split("_").last.to_i) > 0
        @region_definition.shapes << Shape.find(shape_id)
      end
      flash[:notice] = 'Region Definition was successfully updated.'
      redirect_to :action => 'show', :id => @region_definition
    else
      @region = @region_definition.region
      @shape_set = @region_definition.shape_set
      render :action => 'edit'
    end
  end
  
  def destroy
    flash[:notice] = "Region Definition has been deleted."
    redirect_to @region_definition.region
    @region_definition.destroy
  end
  
  
  private
    def find_region_definition
      @region_definition = RegionDefinition.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The Region Definition you were looking for could not be found."
      redirect_to region_definitions_path
    end
    
    def validate_region_and_shape_set
      begin
        params[:region_definition][:region] = Region.find(params[:region_definition][:region].to_i)
      rescue
        flash[:alert] = "No valid region was found"
        redirect_to :back
        return false
      end
      begin
        params[:region_definition][:shape_set] = ShapeSet.find(params[:region_definition][:shape_set].to_i)
      rescue
        flash[:alert] = "No valid shape set was found"
        redirect_to :back
        return false
      end
    end
    
end
