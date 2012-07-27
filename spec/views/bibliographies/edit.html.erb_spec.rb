require 'spec_helper'

describe "bibliographies/edit" do
  before(:each) do
    @bibliography = assign(:bibliography, stub_model(Bibliography,
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit bibliography form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bibliographies_path(@bibliography), :method => "post" do
      assert_select "input#bibliography_name", :name => "bibliography[name]"
      assert_select "input#bibliography_description", :name => "bibliography[description]"
    end
  end
end
