describe "SVGLabeler", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new SVGLabeler()
      
  
  it "should instantiate without errors", ->
    expect(-> new SVGLabeler()).not.toThrow()
  