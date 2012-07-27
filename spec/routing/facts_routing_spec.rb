require "spec_helper"

describe FactsController do
  describe "routing" do

    it "routes to #index" do
      get("/facts").should route_to("facts#index")
    end

    it "routes to #new" do
      get("/facts/new").should route_to("facts#new")
    end

    it "routes to #show" do
      get("/facts/1").should route_to("facts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/facts/1/edit").should route_to("facts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/facts").should route_to("facts#create")
    end

    it "routes to #update" do
      put("/facts/1").should route_to("facts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/facts/1").should route_to("facts#destroy", :id => "1")
    end

  end
end
