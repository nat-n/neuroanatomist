require 'spec_helper'

describe "facts/index" do
  before(:each) do
    assign(:facts, [
      stub_model(Fact),
      stub_model(Fact)
    ])
  end

  it "renders a list of facts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
