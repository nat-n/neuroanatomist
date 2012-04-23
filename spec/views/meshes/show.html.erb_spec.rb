require 'spec_helper'

describe "meshes/show" do
  before(:each) do
    @mesh = assign(:mesh, stub_model(Mesh))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
