class ThingsController < ApplicationController
  before_filter :find_or_create_node, :only => [:create]
  before_filter :find_type, :only => [:create, :update]
  before_filter :find_thing, :only => [:show, :edit, :update, :destroy]

  def index
    @things = Thing.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @things }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @thing }
    end
  end

  def new
    @thing = Thing.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @thing }
    end
  end
  
  def edit
    @thing = Thing.find(params[:id])
  end

  def create    
    @thing = Thing.new(params[:thing])
    
    respond_to do |format|
      if @thing.save
        format.html { redirect_to @thing, notice: 'Thing was successfully created.' }
        format.json { render json: @thing, status: :created, location: @thing }
      else
        format.html { render action: "new" }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @thing.update_attributes(params[:thing])
        format.html { redirect_to @thing, notice: 'Thing was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @thing.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @thing.destroy

    respond_to do |format|
      format.html { redirect_to things_url }
      format.json { head :ok }
    end
  end
  
  private
    def find_thing
      @thing = Thing.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The Thing you were looking for could not be found."
      redirect_to things_path
    end
    def find_type
      params[:thing][:type_id] = Type.where(:name => params[:thing].delete(:type)).first.id
    end
    def find_or_create_node
      if !params[:thing][:node] or params[:thing][:node] = "auto-assign"
        params[:thing][:node] = Node.find_or_create params[:thing][:name]
      else
        params[:thing][:node] = Node.find_by_name params[:thing][:node]
      end
    end
    def render(*args)
      options = args.extract_options!
      options[:template] = "/ontology/things/#{params[:action]}"
      super(*(args << options))
    end
end
