require 'spec_helper'

describe "things/edit" do
  before(:each) do
    @thing = assign(:thing, stub_model(Thing,
      :name => "MyString",
      :description => "MyString",
      :synonyms => "MyString",
      :neurolex_category => "MyString",
      :dbpedia_resource => "MyString",
      :wikipedia_title => "MyString"
    ))
  end

  it "renders the edit thing form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => things_path(@thing), :method => "post" do
      assert_select "input#thing_name", :name => "thing[name]"
      assert_select "input#thing_description", :name => "thing[description]"
      assert_select "input#thing_synonyms", :name => "thing[synonyms]"
      assert_select "input#thing_neurolex_category", :name => "thing[neurolex_category]"
      assert_select "input#thing_dbpedia_resource", :name => "thing[dbpedia_resource]"
      assert_select "input#thing_wikipedia_title", :name => "thing[wikipedia_title]"
    end
  end
end
