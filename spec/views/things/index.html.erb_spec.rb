require 'spec_helper'

describe "things/index" do
  before(:each) do
    assign(:things, [
      stub_model(Thing,
        :name => "Name",
        :description => "Description",
        :synonyms => "Synonyms",
        :neurolex_category => "Neurolex Category",
        :dbpedia_resource => "Dbpedia Resource",
        :wikipedia_title => "Wikipedia Title"
      ),
      stub_model(Thing,
        :name => "Name",
        :description => "Description",
        :synonyms => "Synonyms",
        :neurolex_category => "Neurolex Category",
        :dbpedia_resource => "Dbpedia Resource",
        :wikipedia_title => "Wikipedia Title"
      )
    ])
  end

  it "renders a list of things" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Synonyms".to_s, :count => 2
    assert_select "tr>td", :text => "Neurolex Category".to_s, :count => 2
    assert_select "tr>td", :text => "Dbpedia Resource".to_s, :count => 2
    assert_select "tr>td", :text => "Wikipedia Title".to_s, :count => 2
  end
end
