require 'spec_helper'

describe "region_styles/index" do
  before(:each) do
    assign(:region_styles, [
      stub_model(RegionStyle,
        :colour => "Colour",
        :transparency => 1.5,
        :label => "",
        :orphaned => ""
      ),
      stub_model(RegionStyle,
        :colour => "Colour",
        :transparency => 1.5,
        :label => "",
        :orphaned => ""
      )
    ])
  end

  it "renders a list of region_styles" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Colour".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
