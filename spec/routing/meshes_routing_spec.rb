require "spec_helper"

describe MeshesController do
  describe "routing" do

    it "routes to #index" do
      get("/meshes").should route_to("meshes#index")
    end

    it "routes to #new" do
      get("/meshes/new").should route_to("meshes#new")
    end

    it "routes to #show" do
      get("/meshes/1").should route_to("meshes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/meshes/1/edit").should route_to("meshes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/meshes").should route_to("meshes#create")
    end

    it "routes to #update" do
      put("/meshes/1").should route_to("meshes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/meshes/1").should route_to("meshes#destroy", :id => "1")
    end

  end
end
