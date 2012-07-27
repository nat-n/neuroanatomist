require 'spec_helper'

describe "perspectives/index" do
  before(:each) do
    assign(:perspectives, [
      stub_model(Perspective,
        :height => 1.5,
        :angle => 1.5,
        :distance => 1.5
      ),
      stub_model(Perspective,
        :height => 1.5,
        :angle => 1.5,
        :distance => 1.5
      )
    ])
  end

  it "renders a list of perspectives" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
