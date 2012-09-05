describe "QuizController", ->
  controller = null
  
  beforeEach ->
    SPEC_CONTEXT.redirectTo "quiz/index"
    controller = SPEC_CONTEXT.current_controller
  
  it "should do something", ->
    expect(controller).toBeKindOf(Jax.Controller)
