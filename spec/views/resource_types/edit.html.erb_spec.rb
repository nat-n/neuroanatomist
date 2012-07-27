require 'spec_helper'

describe "resource_types/edit" do
  before(:each) do
    @resource_type = assign(:resource_type, stub_model(ResourceType,
      :name => "MyString",
      :required_fields => "MyString"
    ))
  end

  it "renders the edit resource_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => resource_types_path(@resource_type), :method => "post" do
      assert_select "input#resource_type_name", :name => "resource_type[name]"
      assert_select "input#resource_type_required_fields", :name => "resource_type[required_fields]"
    end
  end
end
