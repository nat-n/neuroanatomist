require 'spec_helper'

describe "shapes/edit" do
  before(:each) do
    @shape = assign(:shape, stub_model(Shape,
      :volume_id => 1,
      :label => "MyString"
    ))
  end

  it "renders the edit shape form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => shapes_path(@shape), :method => "post" do
      assert_select "input#shape_volume_id", :name => "shape[volume_id]"
      assert_select "input#shape_label", :name => "shape[label]"
    end
  end
end
