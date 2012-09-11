Jax.getGlobal()['QuizMaster'] = Jax.Model.create
  after_initialize: ->
    @ready = false
    @quiz =
      list: []
      active: false
      times: []
      answers: []
      correct: 0
      mode: null
      choices: 4
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
    # mode is either search, or match
    # list should be an array of arrays of ids of regions which count as correct answers for this question
    return false if !@ready or !(regions = context.s3[context.current_controller.active_shape_set].regions) or !list.length or this.is_active()
    @quiz.list = []
    missing_regions = []
    for i in list
      if i of regions then @quiz.list.push regions[i]
      else missing_regions.push i
    @quiz.list = @quiz.list.sort () -> 0.5 - Math.random()
    @quiz.active = -1
    @quiz.times.push Date.now
    $('#quiz_controls').slideDown(500)
    $('#quiz_setup').slideUp(500)
    this.proceed()
  
  pass: () ->
    this.proceed() if this.is_active()
  
  proceed: () ->
    @quiz.active += 1
    return this.terminate(true) unless @quiz.list[@quiz.active]
    if @quiz.mode is "search"
      this.update_status("Find the "+this.current().name, "neutral")
    else if @quiz.mode is "mcq"
      this.update_status("Name the coloured area", "neutral")
      this.update_MCQs()
      context.current_controller.load_perspective(this.current().default_perspective, false, true)
      this.current().object.mesh.setColor([0,0.6,1,1])
    $('#quiz_progress').html("Question "+(@quiz.active+1)+" of "+@quiz.list.length+" ")
    @quiz.timer.reset()
  
  terminate: (complete=false) -> 
    @quiz.times.push Date.now
    if complete
      this.update_status("Quiz Complete! you scored "+@quiz.correct+"/"+@quiz.list.length+"<br>Click to Start another Quiz!", "neutral")
    else
      this.update_status("Quiz Canceled! you scored "+@quiz.correct+"/"+@quiz.active+" : "+(@quiz.list.length-@quiz.active)+" questions left.<br>Click to Start another Quiz!", "neutral")
    @quiz.active = false
    $('#mcq_widgets').hide()
    $('#quiz_controls').slideUp(500)
    $('#quiz_setup').slideDown(500)
  
  user_select: (id) ->
    return null unless this.is_active()
    @quiz.times.push @quiz.timer.read()
    if parseInt(id) is this.current().id
      this.correct(this.current().object)
    else
      this.incorrect(this.current().object)
    
  correct: (region) ->
    this.update_status "Correct!", "positive"
    region.mesh.setColor([0,1,0,1])
    context.current_controller.show_hover = false
    setTimeout (()=>this.proceed();region.mesh.setColor([1,1,1,1]);context.current_controller.show_hover=true;), 1500
    @quiz.correct +=1
  
  incorrect: (region) ->
    this.update_status "Incorrect!", "negative"
    region.mesh.setColor([1,0,0,1])
    context.current_controller.show_hover = false
    setTimeout (()=>this.proceed();region.mesh.setColor([1,1,1,1]);context.current_controller.show_hover=true;), 1500
  
  current: () -> @quiz.list[@quiz.active]
  
  is_active: () -> @quiz.active or @quiz.active == 0

  all_regions: () -> (context.s3[context.current_controller.active_shape_set].regions[r] for r of context.s3[context.current_controller.active_shape_set].regions)
  
  update_status: (msg, mood) ->
    mood = "neutral" unless mood is "negative" or mood is "positive"
    $('#quiz_status').removeClass().addClass(mood)
    $('#quiz_status p').html(msg)
  
  update_MCQs: () ->
    return false unless this.is_active()
    options = [[this.current().id, this.current().name]]
    options.push [r.id,r.name] for r in @quiz.list.slice(@quiz.active).sort(()->0.5-Math.random()).slice(0,Math.min(2,(@quiz.list.length-@quiz.active)/2))
    random_regions = this.all_regions().sort(()->0.5-Math.random())
    until options.length is @quiz.choices or options.length is this.all_regions().length
      r = random_regions.pop()
      options.push [r.id,(if r.name.substring(0,3) is "L. " then r.name.replace("L. ","Left ") else r.name.replace("R. ","Right "))]
      options = options.uniqBy(0)
    $('#mcq_widgets').slideDown(500)
    $('#mcq_answers').html("")
    options.sort(()->0.5-Math.random())
    for option in options
      $('#mcq_answers').append $("<li><input type='radio', id='answer_"+option[0]+"' name='mcq_answers'><label for='answer_"+option[0]+"'>"+option[1]+"</label></li>")
    
  