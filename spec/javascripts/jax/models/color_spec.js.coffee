describe "Color", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new Color()
      
  
  it "should instantiate without errors", ->
    expect(-> new Color()).not.toThrow()
  