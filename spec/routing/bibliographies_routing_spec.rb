require "spec_helper"

describe BibliographiesController do
  describe "routing" do

    it "routes to #index" do
      get("/bibliographies").should route_to("bibliographies#index")
    end

    it "routes to #new" do
      get("/bibliographies/new").should route_to("bibliographies#new")
    end

    it "routes to #show" do
      get("/bibliographies/1").should route_to("bibliographies#show", :id => "1")
    end

    it "routes to #edit" do
      get("/bibliographies/1/edit").should route_to("bibliographies#edit", :id => "1")
    end

    it "routes to #create" do
      post("/bibliographies").should route_to("bibliographies#create")
    end

    it "routes to #update" do
      put("/bibliographies/1").should route_to("bibliographies#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/bibliographies/1").should route_to("bibliographies#destroy", :id => "1")
    end

  end
end
