require 'spec_helper'

describe "resource_types/show" do
  before(:each) do
    @resource_type = assign(:resource_type, stub_model(ResourceType,
      :name => "Name",
      :required_fields => "Required Fields"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Required Fields/)
  end
end
