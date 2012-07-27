require "spec_helper"

describe RelationsController do
  describe "routing" do

    it "routes to #index" do
      get("/relations").should route_to("relations#index")
    end

    it "routes to #new" do
      get("/relations/new").should route_to("relations#new")
    end

    it "routes to #show" do
      get("/relations/1").should route_to("relations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/relations/1/edit").should route_to("relations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/relations").should route_to("relations#create")
    end

    it "routes to #update" do
      put("/relations/1").should route_to("relations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/relations/1").should route_to("relations#destroy", :id => "1")
    end

  end
end
