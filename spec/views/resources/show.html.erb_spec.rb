require 'spec_helper'

describe "resources/show" do
  before(:each) do
    @resource = assign(:resource, stub_model(Resource,
      :title => "Title",
      :authors => "Authors",
      :journal => "Journal",
      :publication_date => "Publication Date",
      :volume => "Volume",
      :issue => "Issue",
      :pages => "Pages",
      :doi => "Doi",
      :url => "Url",
      :abstract => "Abstract",
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/Authors/)
    rendered.should match(/Journal/)
    rendered.should match(/Publication Date/)
    rendered.should match(/Volume/)
    rendered.should match(/Issue/)
    rendered.should match(/Pages/)
    rendered.should match(/Doi/)
    rendered.should match(/Url/)
    rendered.should match(/Abstract/)
    rendered.should match(/Description/)
  end
end
