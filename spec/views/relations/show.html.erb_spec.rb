require 'spec_helper'

describe "relations/show" do
  before(:each) do
    @relation = assign(:relation, stub_model(Relation,
      :name => "Name",
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Description/)
  end
end
