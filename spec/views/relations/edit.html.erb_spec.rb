require 'spec_helper'

describe "relations/edit" do
  before(:each) do
    @relation = assign(:relation, stub_model(Relation,
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit relation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => relations_path(@relation), :method => "post" do
      assert_select "input#relation_name", :name => "relation[name]"
      assert_select "input#relation_description", :name => "relation[description]"
    end
  end
end
