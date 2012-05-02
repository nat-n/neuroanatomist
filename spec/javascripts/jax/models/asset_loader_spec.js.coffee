describe "AssetLoader", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new AssetLoader()
      
  
  it "should instantiate without errors", ->
    expect(-> new AssetLoader()).not.toThrow()
  