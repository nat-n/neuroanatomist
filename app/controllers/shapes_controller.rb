class ShapesController < ApplicationController
  before_filter :find_shape, :only => [:show, :edit, :update, :destroy]  
  before_filter :find_shape_set, :only => [:show, :edit, :update, :destroy]  
  
  layout 'admin_areas'
  
  def index
    redirect_to ShapeSet
  end

  def show
    @shape = Shape.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @shape }
    end
  end

  def create
    @shape = Shape.new(params[:shape])
    
    respond_to do |format|
      if @shape.save
        format.html { redirect_to @shape, notice: 'Shape was successfully created.' }
        format.json { render json: @shape, status: :created, location: @shape }
      else
        format.html { render action: "new" }
        format.json { render json: @shape.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
    def find_shape
      @shape = Shape.find(params[:id])
    end

    def find_shape_set
      @shape_set = ShapeSet.find(@shape.shape_set_id)
      #rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The Shape Set you were looking for could not be found."
    end
    
end
