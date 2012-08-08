class NodesController < ApplicationController
  before_filter :find_or_create_tag, :only => [:create, :update]
  before_filter :find_node, :only => [:show, :edit, :update, :destroy]

  def index
    # can request nodes by Thing with this action
    if params["thing"].to_i > 0
      params[:id] = Thing.find(params["thing"].to_i).node.id
      find_node
      return render :action => :show, :layout => "embedded"
    end
    @nodes = Node.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @nodes }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @node }
    end
  end

  def new
    @node = Node.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @node }
    end
  end

  def edit
  end

  def create
    @node = Node.new(params[:node])
    
    respond_to do |format|
      if @node.save
        format.html { redirect_to @node, notice: 'Node was successfully created.' }
        format.json { render json: @node, status: :created, location: @node }
      else
        format.html { render action: "new" }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @node.update_attributes(params[:node])
        format.html { redirect_to @node, notice: 'Node was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @node.destroy

    respond_to do |format|
      format.html { redirect_to nodes_url }
      format.json { head :ok }
    end
  end

  private
    def find_node
      @node = Node.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The Node you were looking for could not be found."
      redirect_to nodes_path
    end
    def find_or_create_tag
      if not params[:node][:tag] or params[:node][:tag] = "auto-assign"
        params[:node][:tag] = Tag.find_or_create params[:node][:name]
      else
        params[:node][:tag] = Tag.find_by_name params[:node][:tag]
      end
    end
end
