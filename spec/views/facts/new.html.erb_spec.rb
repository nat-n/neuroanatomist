require 'spec_helper'

describe "facts/new" do
  before(:each) do
    assign(:fact, stub_model(Fact).as_new_record)
  end

  it "renders new fact form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => facts_path, :method => "post" do
    end
  end
end
