class TypesController < ApplicationController
  before_filter :find_supertype, :only => [:create, :update]
  before_filter :find_type, :only => [:show, :edit, :update, :destroy]
  
  # GET /types
  # GET /types.json
  def index
    @types = Type.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @types }
    end
  end

  # GET /types/1
  # GET /types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @type }
    end
  end

  # GET /types/new
  # GET /types/new.json
  def new
    @type = Type.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @type }
    end
  end

  # GET /types/1/edit
  def edit
  end

  # POST /types
  # POST /types.json
  def create    
    @type = Type.new(params[:type])    
    respond_to do |format|
      if @type.save
        format.html { redirect_to types_path, notice: 'Type was successfully created.' }
        format.json { render json: @type, status: :created, location: @type }
      else
        format.html { render action: "new" }
        format.json { render json: @type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /types/1
  # PUT /types/1.json
  def update
    respond_to do |format|
      if @type.update_attributes(params[:type])
        format.html { redirect_to types_path, notice: 'Type was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /types/1
  # DELETE /types/1.json
  def destroy
    @type.destroy

    respond_to do |format|
      format.html { redirect_to types_url }
      format.json { head :ok }
    end
  end
  
  private
    def find_type
      @type = Type.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The Type you were looking for could not be found."
      redirect_to types_path
    end
    def find_supertype
      super_type_name = params[:type].delete(:supertype)
      #throw Type.where(:name => super_type_name).first
      params[:type][:supertype] = Type.where(:name => super_type_name).first
    end
    
end
