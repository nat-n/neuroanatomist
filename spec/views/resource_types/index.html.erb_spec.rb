require 'spec_helper'

describe "resource_types/index" do
  before(:each) do
    assign(:resource_types, [
      stub_model(ResourceType,
        :name => "Name",
        :required_fields => "Required Fields"
      ),
      stub_model(ResourceType,
        :name => "Name",
        :required_fields => "Required Fields"
      )
    ])
  end

  it "renders a list of resource_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Required Fields".to_s, :count => 2
  end
end
