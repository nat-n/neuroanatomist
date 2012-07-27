require 'spec_helper'

describe "facts/edit" do
  before(:each) do
    @fact = assign(:fact, stub_model(Fact))
  end

  it "renders the edit fact form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => facts_path(@fact), :method => "post" do
    end
  end
end
