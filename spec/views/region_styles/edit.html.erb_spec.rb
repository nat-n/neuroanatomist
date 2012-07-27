require 'spec_helper'

describe "region_styles/edit" do
  before(:each) do
    @region_style = assign(:region_style, stub_model(RegionStyle,
      :colour => "MyString",
      :transparency => 1.5,
      :label => "",
      :orphaned => ""
    ))
  end

  it "renders the edit region_style form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => region_styles_path(@region_style), :method => "post" do
      assert_select "input#region_style_colour", :name => "region_style[colour]"
      assert_select "input#region_style_transparency", :name => "region_style[transparency]"
      assert_select "input#region_style_label", :name => "region_style[label]"
      assert_select "input#region_style_orphaned", :name => "region_style[orphaned]"
    end
  end
end
