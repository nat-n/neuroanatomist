require 'spec_helper'

describe "resources/index" do
  before(:each) do
    assign(:resources, [
      stub_model(Resource,
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
      ),
      stub_model(Resource,
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
      )
    ])
  end

  it "renders a list of resources" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Authors".to_s, :count => 2
    assert_select "tr>td", :text => "Journal".to_s, :count => 2
    assert_select "tr>td", :text => "Publication Date".to_s, :count => 2
    assert_select "tr>td", :text => "Volume".to_s, :count => 2
    assert_select "tr>td", :text => "Issue".to_s, :count => 2
    assert_select "tr>td", :text => "Pages".to_s, :count => 2
    assert_select "tr>td", :text => "Doi".to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => "Abstract".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
