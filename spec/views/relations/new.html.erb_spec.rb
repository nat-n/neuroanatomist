require 'spec_helper'

describe "relations/new" do
  before(:each) do
    assign(:relation, stub_model(Relation,
      :name => "MyString",
      :description => "MyString"
    ).as_new_record)
  end

  it "renders new relation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => relations_path, :method => "post" do
      assert_select "input#relation_name", :name => "relation[name]"
      assert_select "input#relation_description", :name => "relation[description]"
    end
  end
end
