class RegionsController < ApplicationController
  before_filter :find_region, :only => [:show, :edit, :update, :destroy]
  
  def index
    @regions = Region.all
  end
  
  def new
    @region = Region.new
  end
  
  def create
    @region = Region.new(params[:region])
    
    if @region.save
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
    if @region.update_attributes(params[:region])
      flash[:notice] = 'Region was successfully updated.'
      redirect_to :action => 'show', :id => @region
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    Region.region_definitions.each { |definition| definition.update_attribute :orphaned, true }
    Region.find(params[:id]).destroy
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
  
end
