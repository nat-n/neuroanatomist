require 'spec_helper'

describe "Bibliographies" do
  describe "GET /bibliographies" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get bibliographies_path
      response.status.should be(200)
    end
  end
end
