describe "LabelRing", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new LabelRing()
      
  
  it "should instantiate without errors", ->
    expect(-> new LabelRing()).not.toThrow()
  