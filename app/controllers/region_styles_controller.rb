class RegionStylesController < ApplicationController
  # GET /region_styles
  # GET /region_styles.json
  def index
    @region_styles = RegionStyle.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @region_styles }
    end
  end

  # GET /region_styles/1
  # GET /region_styles/1.json
  def show
    @region_style = RegionStyle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @region_style }
    end
  end

  # GET /region_styles/new
  # GET /region_styles/new.json
  def new
    @region_style = RegionStyle.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @region_style }
    end
  end

  # GET /region_styles/1/edit
  def edit
    @region_style = RegionStyle.find(params[:id])
  end

  # POST /region_styles
  # POST /region_styles.json
  def create
    @region_style = RegionStyle.new(params[:region_style])

    respond_to do |format|
      if @region_style.save
        format.html { redirect_to @region_style, notice: 'Region style was successfully created.' }
        format.json { render json: @region_style, status: :created, location: @region_style }
      else
        format.html { render action: "new" }
        format.json { render json: @region_style.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /region_styles/1
  # PUT /region_styles/1.json
  def update
    @region_style = RegionStyle.find(params[:id])

    respond_to do |format|
      if @region_style.update_attributes(params[:region_style])
        format.html { redirect_to @region_style, notice: 'Region style was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @region_style.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /region_styles/1
  # DELETE /region_styles/1.json
  def destroy
    @region_style = RegionStyle.find(params[:id])
    @region_style.destroy

    respond_to do |format|
      format.html { redirect_to region_styles_url }
      format.json { head :ok }
    end
  end
end
