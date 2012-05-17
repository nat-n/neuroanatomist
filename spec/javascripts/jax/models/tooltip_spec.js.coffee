describe "Tooltip", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new Tooltip()
      
  
  it "should instantiate without errors", ->
    expect(-> new Tooltip()).not.toThrow()
  