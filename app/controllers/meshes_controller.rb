class MeshesController < ApplicationController
  # GET /meshes
  # GET /meshes.json
  def index
    @meshes = Mesh.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @meshes }
    end
  end

  # GET /meshes/1
  # GET /meshes/1.json
  def show
    @mesh = Mesh.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json #{ render json: @mesh }
    end
  end

  # GET /meshes/new
  # GET /meshes/new.json
  def new
    @mesh = Mesh.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mesh }
    end
  end

  # GET /meshes/1/edit
  def edit
    @mesh = Mesh.find(params[:id])
  end

  # POST /meshes
  # POST /meshes.json
  def create
    @mesh = Mesh.new(params[:mesh])
    
    respond_to do |format|
      if @mesh.save
        @mesh.process_new_meshdata
        format.html { redirect_to @mesh, notice: 'Mesh was successfully created.' }
        format.json { render json: @mesh, status: :created, location: @mesh }
      else
        format.html { render action: "new" }
        format.json { render json: @mesh.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /meshes/1
  # PUT /meshes/1.json
  def update
    @mesh = Mesh.find(params[:id])

    respond_to do |format|
      if @mesh.update_attributes(params[:mesh])
        format.html { redirect_to @mesh, notice: 'Mesh was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @mesh.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meshes/1
  # DELETE /meshes/1.json
  def destroy
    @mesh = Mesh.find(params[:id])
    @mesh.destroy

    respond_to do |format|
      format.html { redirect_to meshes_url }
      format.json { head :ok }
    end
  end
  
end
