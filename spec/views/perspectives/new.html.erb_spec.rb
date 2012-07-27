require 'spec_helper'

describe "perspectives/new" do
  before(:each) do
    assign(:perspective, stub_model(Perspective,
      :height => 1.5,
      :angle => 1.5,
      :distance => 1.5
    ).as_new_record)
  end

  it "renders new perspective form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => perspectives_path, :method => "post" do
      assert_select "input#perspective_height", :name => "perspective[height]"
      assert_select "input#perspective_angle", :name => "perspective[angle]"
      assert_select "input#perspective_distance", :name => "perspective[distance]"
    end
  end
end
