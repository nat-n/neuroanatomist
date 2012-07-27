require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe BibliographiesController do

  # This should return the minimal set of attributes required to create a valid
  # Bibliography. As you add validations to Bibliography, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BibliographiesController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all bibliographies as @bibliographies" do
      bibliography = Bibliography.create! valid_attributes
      get :index, {}, valid_session
      assigns(:bibliographies).should eq([bibliography])
    end
  end

  describe "GET show" do
    it "assigns the requested bibliography as @bibliography" do
      bibliography = Bibliography.create! valid_attributes
      get :show, {:id => bibliography.to_param}, valid_session
      assigns(:bibliography).should eq(bibliography)
    end
  end

  describe "GET new" do
    it "assigns a new bibliography as @bibliography" do
      get :new, {}, valid_session
      assigns(:bibliography).should be_a_new(Bibliography)
    end
  end

  describe "GET edit" do
    it "assigns the requested bibliography as @bibliography" do
      bibliography = Bibliography.create! valid_attributes
      get :edit, {:id => bibliography.to_param}, valid_session
      assigns(:bibliography).should eq(bibliography)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Bibliography" do
        expect {
          post :create, {:bibliography => valid_attributes}, valid_session
        }.to change(Bibliography, :count).by(1)
      end

      it "assigns a newly created bibliography as @bibliography" do
        post :create, {:bibliography => valid_attributes}, valid_session
        assigns(:bibliography).should be_a(Bibliography)
        assigns(:bibliography).should be_persisted
      end

      it "redirects to the created bibliography" do
        post :create, {:bibliography => valid_attributes}, valid_session
        response.should redirect_to(Bibliography.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved bibliography as @bibliography" do
        # Trigger the behavior that occurs when invalid params are submitted
        Bibliography.any_instance.stub(:save).and_return(false)
        post :create, {:bibliography => {}}, valid_session
        assigns(:bibliography).should be_a_new(Bibliography)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Bibliography.any_instance.stub(:save).and_return(false)
        post :create, {:bibliography => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested bibliography" do
        bibliography = Bibliography.create! valid_attributes
        # Assuming there are no other bibliographies in the database, this
        # specifies that the Bibliography created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Bibliography.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => bibliography.to_param, :bibliography => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested bibliography as @bibliography" do
        bibliography = Bibliography.create! valid_attributes
        put :update, {:id => bibliography.to_param, :bibliography => valid_attributes}, valid_session
        assigns(:bibliography).should eq(bibliography)
      end

      it "redirects to the bibliography" do
        bibliography = Bibliography.create! valid_attributes
        put :update, {:id => bibliography.to_param, :bibliography => valid_attributes}, valid_session
        response.should redirect_to(bibliography)
      end
    end

    describe "with invalid params" do
      it "assigns the bibliography as @bibliography" do
        bibliography = Bibliography.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Bibliography.any_instance.stub(:save).and_return(false)
        put :update, {:id => bibliography.to_param, :bibliography => {}}, valid_session
        assigns(:bibliography).should eq(bibliography)
      end

      it "re-renders the 'edit' template" do
        bibliography = Bibliography.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Bibliography.any_instance.stub(:save).and_return(false)
        put :update, {:id => bibliography.to_param, :bibliography => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested bibliography" do
      bibliography = Bibliography.create! valid_attributes
      expect {
        delete :destroy, {:id => bibliography.to_param}, valid_session
      }.to change(Bibliography, :count).by(-1)
    end

    it "redirects to the bibliographies list" do
      bibliography = Bibliography.create! valid_attributes
      delete :destroy, {:id => bibliography.to_param}, valid_session
      response.should redirect_to(bibliographies_url)
    end
  end

end
