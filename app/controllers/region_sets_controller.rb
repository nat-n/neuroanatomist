class RegionSetsController < ApplicationController
  before_filter :find_region_set, :only => [:show, :edit, :update, :destroy]
  before_filter :all_regions, :only => [:new, :edit]
  
  def index
    @region_sets = RegionSet.all
  end
  
  def new
    @region_set = RegionSet.new
  end
  
  def create
    @region_set = RegionSet.new(params[:region_set])
    update_regions
    
    if @region_set.save
      flash[:notice] = "Region Set has been created."
      redirect_to @region_set
    else
      flash[:alert] = "Region set has not been created, It may have already existed"
      render :action => "new"
    end
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    if @region_set.update_attributes(params[:region_set])
      update_regions
      flash[:notice] = 'Region Set was successfully updated.'
      redirect_to :action => 'show', :id => @region_set
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    RegionSet.find(params[:id]).destroy
    flash[:notice] = "Region Set has been deleted."
    redirect_to region_sets_path
  end


  private
    def find_region_set
      @region_set = RegionSet.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The Region Set you were looking for could not be found."
      redirect_to region_sets_path
    end
    
    def all_regions
      @regions = Region.all
    end
    
    def update_regions
      @region_set.regions.clear
      params[:regions].each do |region_id, inclusion|
        next unless inclusion == "1" and (region_id = region_id.split("_").last.to_i) > 0
        @region_set.regions << Region.find(region_id)
      end
    end
    
end
