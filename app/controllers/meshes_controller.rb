class MeshesController < ApplicationController
    
  def index
    @meshes = Mesh.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @meshes }
    end
  end
  
end
