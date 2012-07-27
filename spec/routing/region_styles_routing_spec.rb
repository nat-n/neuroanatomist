require "spec_helper"

describe RegionStylesController do
  describe "routing" do

    it "routes to #index" do
      get("/region_styles").should route_to("region_styles#index")
    end

    it "routes to #new" do
      get("/region_styles/new").should route_to("region_styles#new")
    end

    it "routes to #show" do
      get("/region_styles/1").should route_to("region_styles#show", :id => "1")
    end

    it "routes to #edit" do
      get("/region_styles/1/edit").should route_to("region_styles#edit", :id => "1")
    end

    it "routes to #create" do
      post("/region_styles").should route_to("region_styles#create")
    end

    it "routes to #update" do
      put("/region_styles/1").should route_to("region_styles#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/region_styles/1").should route_to("region_styles#destroy", :id => "1")
    end

  end
end
