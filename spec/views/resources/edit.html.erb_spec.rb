require 'spec_helper'

describe "resources/edit" do
  before(:each) do
    @resource = assign(:resource, stub_model(Resource,
      :title => "MyString",
      :authors => "MyString",
      :journal => "MyString",
      :publication_date => "MyString",
      :volume => "MyString",
      :issue => "MyString",
      :pages => "MyString",
      :doi => "MyString",
      :url => "MyString",
      :abstract => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit resource form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => resources_path(@resource), :method => "post" do
      assert_select "input#resource_title", :name => "resource[title]"
      assert_select "input#resource_authors", :name => "resource[authors]"
      assert_select "input#resource_journal", :name => "resource[journal]"
      assert_select "input#resource_publication_date", :name => "resource[publication_date]"
      assert_select "input#resource_volume", :name => "resource[volume]"
      assert_select "input#resource_issue", :name => "resource[issue]"
      assert_select "input#resource_pages", :name => "resource[pages]"
      assert_select "input#resource_doi", :name => "resource[doi]"
      assert_select "input#resource_url", :name => "resource[url]"
      assert_select "input#resource_abstract", :name => "resource[abstract]"
      assert_select "input#resource_description", :name => "resource[description]"
    end
  end
end
