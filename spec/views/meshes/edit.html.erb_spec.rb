require 'spec_helper'

describe "meshes/edit" do
  before(:each) do
    @mesh = assign(:mesh, stub_model(Mesh))
  end

  it "renders the edit mesh form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => meshes_path(@mesh), :method => "post" do
    end
  end
end
