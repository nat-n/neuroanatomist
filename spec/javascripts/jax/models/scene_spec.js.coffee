describe "Scene", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new Scene()
      
  
  it "should instantiate without errors", ->
    expect(-> new Scene()).not.toThrow()
  