describe "SVGTooltip", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new SVGTooltip()
      
  
  it "should instantiate without errors", ->
    expect(-> new SVGTooltip()).not.toThrow()
  