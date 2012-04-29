require 'spec_helper'

describe "shapes/show" do
  before(:each) do
    @shape = assign(:shape, stub_model(Shape,
      :volume_id => 1,
      :label => "Label"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Label/)
  end
end
