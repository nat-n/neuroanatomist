require "spec_helper"

describe ShapesController do
  describe "routing" do

    it "routes to #index" do
      get("/shapes").should route_to("shapes#index")
    end

    it "routes to #new" do
      get("/shapes/new").should route_to("shapes#new")
    end

    it "routes to #show" do
      get("/shapes/1").should route_to("shapes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/shapes/1/edit").should route_to("shapes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/shapes").should route_to("shapes#create")
    end

    it "routes to #update" do
      put("/shapes/1").should route_to("shapes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/shapes/1").should route_to("shapes#destroy", :id => "1")
    end

  end
end
