require 'spec_helper'

describe "bibliographies/new" do
  before(:each) do
    assign(:bibliography, stub_model(Bibliography,
      :name => "MyString",
      :description => "MyString"
    ).as_new_record)
  end

  it "renders new bibliography form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bibliographies_path, :method => "post" do
      assert_select "input#bibliography_name", :name => "bibliography[name]"
      assert_select "input#bibliography_description", :name => "bibliography[description]"
    end
  end
end
