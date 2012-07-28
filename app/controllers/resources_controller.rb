class ResourcesController < ApplicationController
  before_filter :parse_tags, :only => [:create, :update]
  before_filter :find_resource_type, :only => [:create, :update]
  before_filter :find_resource, :only => [:show, :edit, :update, :destroy]
  before_filter :find_tags, :only => [:show, :edit]
  
  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resources }
    end
  end

  # GET /resources/1
  # GET /resources/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/new
  # GET /resources/new.json
  def new
    @resource = Resource.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(params[:resource])
    respond_to do |format|
      if @resource.save
        format.html { redirect_to @resource, notice: 'Resource was successfully created.' }
        format.json { render json: @resource, status: :created, location: @resource }
      else
        format.html { render action: "new" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resources/1
  # PUT /resources/1.json
  def update
    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        format.html { redirect_to @resource, notice: 'Resource was successfully updated.' }
        #throw  [params[:resource],@resource]
        
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :ok }
    end
  end
  
  private
    def find_resource
      @resource = Resource.find(params[:id])
    end
    def find_resource_type
      params[:resource][:resource_type] = ResourceType.where(:name => params[:resource].delete(:resource_type) ).first
    end
    def find_tags
      @tags = @resource.tags
    end
    def parse_tags
      params[:resource][:tags] = params[:resource][:tags].split(/\s/).map { |tag_string| Tag.find_or_create tag_string }
    end
    
end
