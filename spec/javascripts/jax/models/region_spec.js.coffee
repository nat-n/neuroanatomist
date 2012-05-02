describe "Region", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new Region()
      
  
  it "should instantiate without errors", ->
    expect(-> new Region()).not.toThrow()
  