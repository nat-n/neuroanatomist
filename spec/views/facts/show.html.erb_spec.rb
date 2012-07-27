require 'spec_helper'

describe "facts/show" do
  before(:each) do
    @fact = assign(:fact, stub_model(Fact))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
