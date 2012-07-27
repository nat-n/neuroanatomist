require 'spec_helper'

describe "ratings/show" do
  before(:each) do
    @rating = assign(:rating, stub_model(Rating,
      :value => 1.5,
      :comment => "Comment"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1.5/)
    rendered.should match(/Comment/)
  end
end
