class Ontology::FactsController < ApplicationController
  
  layout 'admin_areas'

  def index
    @facts = Fact.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @facts }
    end
  end

  def show
    @fact = Fact.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fact }
    end
  end

  def new
    @fact = Fact.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fact }
    end
  end

  def edit
    @fact = Fact.find(params[:id])
  end

  def create
    @fact = Fact.new(params[:fact])

    respond_to do |format|
      if @fact.save
        format.html { redirect_to @fact, notice: 'Fact was successfully created.' }
        format.json { render json: @fact, status: :created, location: @fact }
      else
        format.html { render action: "new" }
        format.json { render json: @fact.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @fact = Fact.find(params[:id])

    respond_to do |format|
      if @fact.update_attributes(params[:fact])
        format.html { redirect_to @fact, notice: 'Fact was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @fact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @fact = Fact.find(params[:id])
    @fact.destroy

    respond_to do |format|
      format.html { redirect_to facts_url }
      format.json { head :ok }
    end
  end
  
  private
    def render(*args)
      options = args.extract_options!
      options[:template] = "/ontology/facts/#{params[:action]}"
      super(*(args << options))
    end
end
