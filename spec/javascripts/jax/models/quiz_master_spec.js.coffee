describe "QuizMaster", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new QuizMaster()
      
  
  it "should instantiate without errors", ->
    expect(-> new QuizMaster()).not.toThrow()
  