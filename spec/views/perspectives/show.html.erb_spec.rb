require 'spec_helper'

describe "perspectives/show" do
  before(:each) do
    @perspective = assign(:perspective, stub_model(Perspective,
      :height => 1.5,
      :angle => 1.5,
      :distance => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
  end
end
