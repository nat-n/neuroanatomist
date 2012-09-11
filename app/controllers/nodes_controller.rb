class NodesController < ApplicationController
  before_filter :find_or_create_tag, :only => [:create, :update]
  before_filter :find_node, :only => [:show, :edit, :update, :destroy]
  
  include NodesHelper
  
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
    if params[:id] =~ /\d+:v\d*\-?\d*\-?\d*$/
      v = params[:id].scan(/\d*:v(\d*\-?\d*\-?\d*)/)[0][0].gsub(/\-/,".")
      v = @node.current_version.to_s if v.empty?
      contents = (@node.versions.where(:version_string => v).first.contents rescue :not_found)
      if contents != :not_found
        return render :text => (contents ? RedCloth.new(contents).to_html : "")
      else
        return head 404
      end
    elsif params[:id] =~ /\d:history/
      return render :partial => 'history'
    end
    
    return render(:text => JSON.dump(embedded_json), :content_type => "application/json") if params[:id] =~ /\d+:embed/
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
        Version.init_for @node, {:contents => ((params[:node][:introduction] and !params[:node][:introduction].empty?) ? params[:node][:introduction] : "")}
        format.html { redirect_to @node, notice: 'Node was successfully created.' }
        format.json { render json: @node, status: :created, location: @node }
      else
        format.html { render action: "new" }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def preview
    render :text => RedCloth.new(params[:textile]).to_html
  end
  
  def update
    description = nil
    if params[:revert]
      v = params[:revert].scan(/(\d*\-?\d*\-?\d*)/)[0][0].gsub(/\-/,".")
      params[:node] = {} unless params[:node]
      params[:node][:introduction] = (@node.versions.where(:version_string => v).first.contents rescue :not_found)
      description = "from:(#{v})"
      #request.format = :json
    end
    
    contents_changed = params[:node][:introduction] != @node.introduction if params[:node]
    respond_to do |format|
      if @node.update_attributes(params[:node])
        @node.version_bump(:minor, {:contents => params[:node][:introduction], :description => description}, current_user) if contents_changed
        if params[:revert]
          params[:id] += ":v"
          return show
        end
        format.html { redirect_to (params[:return] ? :back : @node), notice: 'Node was successfully updated.' }
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
      return unless params[:node] and params[:node][:name]
      if not params[:node][:tag] or params[:node][:tag] = "auto-assign"
        params[:node][:tag] = Tag.find_or_create params[:node][:name]
      else
        params[:node][:tag] = Tag.find_by_name params[:node][:tag]
      end
    end
    
end
