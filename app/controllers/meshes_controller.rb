class MeshesController  < Admin::BaseController
    
  def index
    @meshes = Mesh.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @meshes }
    end
  end
  
  def show
    if (params["format"] == "obj" rescue false)
      @mesh = Mesh.find params[:id]
      render :text => @mesh.to_obj, :layout  => nil
      return true
    end
  end
end
