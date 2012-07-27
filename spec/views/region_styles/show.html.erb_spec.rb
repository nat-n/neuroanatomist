require 'spec_helper'

describe "region_styles/show" do
  before(:each) do
    @region_style = assign(:region_style, stub_model(RegionStyle,
      :colour => "Colour",
      :transparency => 1.5,
      :label => "",
      :orphaned => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Colour/)
    rendered.should match(/1.5/)
    rendered.should match(//)
    rendered.should match(//)
  end
end
