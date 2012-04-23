require 'spec_helper'

describe "meshes/index" do
  before(:each) do
    assign(:meshes, [
      stub_model(Mesh),
      stub_model(Mesh)
    ])
  end

  it "renders a list of meshes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
