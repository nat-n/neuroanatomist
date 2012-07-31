class PerspectivesController < ApplicationController
  before_filter :find_perspective, :only => [:show, :edit, :update, :destroy]
  #before_filter :update_region_styles, :only => [:create, :update]
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
      format.json { render json: @perspective }
    end
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
    @perspective = Perspective.new(params[:perspective])
    
    respond_to do |format|
      if @perspective.save
        update_region_styles
        format.html { redirect_to @perspective, notice: 'Perspective was successfully created.' }
        format.json { render json: @perspective, status: :created, location: @perspective }
      else
        format.html { render action: "new" }
        format.json { render json: @perspective.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    update_region_styles
    
    respond_to do |format|
      if @perspective.update_attributes(params[:perspective])
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
      # should create, update and disown region styles as required
      params[:regions].each do |rstr, inclusion|
        region_id = rstr.split("_").last.to_i
        region = Region.find(region_id)
        if inclusion == "1"
          @perspective.update_or_create_region_style :colour        => params[:colour][rstr],
                                                     :transparency  => params[:transparency][rstr],
                                                     :label         => params[:label][rstr] == "1",
                                                     :region        => region
        else
          @perspective.disown_region_if_styled region
        end
      end
    end

end
