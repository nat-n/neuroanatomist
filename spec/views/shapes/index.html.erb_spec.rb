require 'spec_helper'

describe "shapes/index" do
  before(:each) do
    assign(:shapes, [
      stub_model(Shape,
        :volume_id => 1,
        :label => "Label"
      ),
      stub_model(Shape,
        :volume_id => 1,
        :label => "Label"
      )
    ])
  end

  it "renders a list of shapes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Label".to_s, :count => 2
  end
end
