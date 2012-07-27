require 'spec_helper'

describe "things/show" do
  before(:each) do
    @thing = assign(:thing, stub_model(Thing,
      :name => "Name",
      :description => "Description",
      :synonyms => "Synonyms",
      :neurolex_category => "Neurolex Category",
      :dbpedia_resource => "Dbpedia Resource",
      :wikipedia_title => "Wikipedia Title"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Description/)
    rendered.should match(/Synonyms/)
    rendered.should match(/Neurolex Category/)
    rendered.should match(/Dbpedia Resource/)
    rendered.should match(/Wikipedia Title/)
  end
end
