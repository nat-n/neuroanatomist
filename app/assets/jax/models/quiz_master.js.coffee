Jax.getGlobal()['QuizMaster'] = Jax.Model.create
  after_initialize: ->
    @quiz =
      list: []
      active: false
      times: []
      answers: []
      correct: 0
      mode: null
      timer: (()-> 
        init_time   = null
        timeout     = null
        timeout_cb  = null
        to          = null
        return {
          set_timeout: (t,cb) ->
            timeout = t
            timeout_cb = cb
          reset: () ->
            to = setTimeout((()->cb()), timeout) if timeout
            init_time = Date.now
          read: () ->
            clearTimeout(to)
            Date.now-init_time
        }
      )()
  
  start: (list) ->
    console.log list
    # mode is either search, or match
    # list should be an array of arrays of ids of regions which count as correct answers for this question
    return false if !(regions = context.s3[context.current_controller.active_shape_set].regions) or !list.length or this.is_active()
    @quiz.list = []
    missing_regions = []
    for i in list
      if i of regions then @quiz.list.push regions[i]
      else missing_regions.push i
    @quiz.list = @quiz.list.sort () -> 0.5 - Math.random()
    @quiz.active = -1
    @quiz.times.push Date.now
    this.proceed()
  
  pass: () ->
    this.proceed() if this.is_active()
  
  proceed: () ->
    @quiz.active += 1
    return this.terminate(true) unless @quiz.list[@quiz.active]
    this.update_status("Find the "+this.current().name, "neutral")
    @quiz.timer.reset()
  
  terminate: (complete=false) -> 
    @quiz.times.push Date.now
    if complete
      this.update_status("Quiz Complete! you scored "+@quiz.correct+"/"+@quiz.list.length+"<br>Click to Start another Quiz!", "neutral")
    else
      this.update_status("Quiz Canceled! you scored "+@quiz.correct+"/"+@quiz.active+" : "+(@quiz.list.length-@quiz.active)+" questions left.<br>Click to Start another Quiz!", "neutral")
    @quiz.active = false
  
  user_select: (id) -> 
    return null unless this.is_active()
    @quiz.times.push @quiz.timer.read()
    if id is this.current().id
      this.correct(this.current().object)
    else
      this.incorrect(this.current().object)
    
  correct: (region) ->
    this.update_status "Correct!", "positive"
    region.mesh.setColor([0,1,0,1])
    context.current_controller.show_hover = false
    setTimeout (()=>this.proceed();region.mesh.setColor([1,1,1,1]);context.current_controller.show_hover=true;), 2000
    @quiz.correct +=1
  
  incorrect: (region) ->
    this.update_status "Incorrect!", "negative"
    region.mesh.setColor([1,0,0,1])
    context.current_controller.show_hover = false
    setTimeout (()=>this.proceed();region.mesh.setColor([1,1,1,1]);context.current_controller.show_hover=true;), 2000
  
  current: () -> @quiz.list[@quiz.active]
  
  is_active: () -> @quiz.active or @quiz.active == 0
  
  update_status: (msg, mood) ->
    mood = "neutral" unless mood is "negative" or mood is "positive"
    $('#quiz_status').removeClass().addClass(mood)
    $('#quiz_status p').html(msg)  
