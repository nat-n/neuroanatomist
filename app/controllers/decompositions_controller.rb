class DecompositionsController < ApplicationController
  before_filter :find_super_region, :only => [:create]
  before_filter :find_decomposition, :only => [:show, :edit, :update, :destroy]
  
  layout 'admin_areas'

  def index
    @decompositions = Decomposition.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decomposition }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @decomposition }
    end
  end

  def new
    @decomposition = Decomposition.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @decomposition }
    end
  end
  
  def edit
    @decomposition = Decomposition.find(params[:id])
  end

  def create    
    @decomposition = Decomposition.new(params[:decomposition])
    update_sub_regions
    
    respond_to do |format|
      if @decomposition.save
        format.html { redirect_to @decomposition, notice: 'Decomposition was successfully created.' }
        format.json { render json: @decomposition, status: :created, location: @decomposition }
      else
        format.html { render action: "new" }
        format.json { render json: @decomposition.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    update_sub_regions
    respond_to do |format|
      if @decomposition.update_attributes(params[:decomposition])
        format.html { redirect_to @decomposition, notice: 'Decomposition was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @decomposition.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @decomposition.destroy

    respond_to do |format|
      format.html { redirect_to decompositions_url }
      format.json { head :ok }
    end
  end
  
  private
    def find_decomposition
      @decomposition = Decomposition.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The Decomposition you were looking for could not be found."
      redirect_to decompositions_path
    end
    def find_super_region
      params[:decomposition][:super_region] = Region.where("name = ?", params[:decomposition][:super_region]).first
    end
    def update_sub_regions
      sub_regions = params[:sub_regions].map {|k,v| ( v=="1" ? Region.find(k.split("_").first.to_i) : nil ) }.compact
      @decomposition.sub_regions -= @decomposition.sub_regions - sub_regions
      @decomposition.sub_regions += sub_regions - @decomposition.sub_regions
    end
end
