class Ontology::TypesController  < Ontology::BaseController
  before_filter :find_supertype, :only => [:create, :update]
  before_filter :find_type, :only => [:show, :edit, :update, :destroy]
  
  def index
    @types = Type.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @types }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @type }
    end
  end

  def new
    @type = Type.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @type }
    end
  end

  def edit
  end

  def create
    @type = Type.new(params[:type])    
    respond_to do |format|
      if @type.save
        format.html { redirect_to ontology_types_path, notice: 'Type was successfully created.' }
        format.json { render json: @type, status: :created, location: @type }
      else
        format.html { render action: "new" }
        format.json { render json: @type.errors, status: :unprocessable_entity }
      end
    end
  end

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
      params[:type][:supertype] = Type.where(:name => params[:type].delete(:supertype)).first
    end
    def render(*args)
      options = args.extract_options!
      options[:template] = "/ontology/types/#{params[:action]}"
      super(*(args << options))
    end
end
