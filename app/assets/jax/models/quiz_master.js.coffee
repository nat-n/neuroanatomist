extend_name = (name) ->
  if name.substring(0,3) is "L. "
    name.replace("L. ","Left ")
  else
    name.replace("R. ","Right ")

abrv_name = (name) ->
  if name.substring(0,5) is "Left "
    name.replace("Left ", "L. ")
  else
    name.replace("Right ","R. ") 

Jax.getGlobal()['QuizMaster'] = Jax.Model.create
  after_initialize: ->
    @ready = false
    @temp_region = null
    @quiz =
      list: []
      active: false
      times: []
      correct: 0
      mode: null
      choices: 4
      stats: {}
      new_stats: {}
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
    @active_shape_set = context.current_controller.active_shape_set
    @quiz.list = []
    missing_regions = []
    for i in list when typeof(i) is 'number'
      if i of regions then @quiz.list.push regions[i]
      else missing_regions.push i
    if missing_regions.length
      this.update_status("Loading quiz data...")
      context.current_controller.loader.fetch_regions @active_shape_set, missing_regions, () =>
        @quiz.list = @quiz.list.sort () -> 0.5 - Math.random()
        @quiz.active = -1
        @quiz.times.push Date.now()
        $('#quiz_controls').slideDown(500)
        $('#quiz_setup').slideUp(500)
        this.proceed()
    else
      @quiz.list = @quiz.list.sort () -> 0.5 - Math.random()
      @quiz.active = -1
      @quiz.times.push Date.now()
      $('#quiz_controls').slideDown(500)
      $('#quiz_setup').slideUp(500)
      this.proceed()
    logger.log_quiz type: 'quiz_start', mode: @quiz.mode, length: @quiz.list.length
  
  pass: () ->
    logger.log_quiz type: 'quiz_pass'
    this.current().object.mesh.setColor([1,1,1,1]) if this.current().object
    this.proceed() if this.is_active()
  
  proceed: () ->
    @quiz.active += 1
    return this.terminate(true) unless @quiz.list[@quiz.active]
    if @quiz.mode is "search"
      this.update_status("Find the "+extend_name(this.current().name), "neutral")
    else if @quiz.mode is "mcq"
      this.update_status("Name the coloured area", "neutral")
      this.update_MCQs()
      context.current_controller.load_perspective(this.current().default_perspective, false, true)
      this.current().object.mesh.setColor([0,0.6,1,1])
    $('#quiz_progress').html("Question "+(@quiz.active+1)+" of "+@quiz.list.length+" ")
    @quiz.timer.reset()
  
  terminate: (complete=false) ->
    logger.log_quiz type: 'quiz_end', complete: complete
    @quiz.times.push Date.now
    this.current().object.mesh.setColor([1,1,1,1]) if this.current() and this.current().object
    context.current_controller.undo_all()
    if complete
      this.update_status("Quiz Complete! you scored "+@quiz.correct+"/"+@quiz.list.length+"<br>Click to Start another Quiz!", "neutral")
    else
      this.update_status("Quiz Canceled! you scored "+@quiz.correct+"/"+@quiz.active+" : "+(@quiz.list.length-@quiz.active)+" questions left.<br>Click to Start another Quiz!", "neutral")
    @quiz.active = false
    $('#mcq_widgets').hide()
    $('#quiz_controls').slideUp(500)
    $('#quiz_setup').slideDown(500)
    this.update_stats_view()
  
  user_select: (id) ->
    return null unless this.is_active()
    @quiz.times.push @quiz.timer.read()
    unless this.current().object and this.current().object.id of context.current_controller.world.objects
      context.current_controller.show_region(context.current_controller.scene.new_region(@active_shape_set, this.current().id, [1,1,1,1]), false)
      @temp_region = this.current().object.id
    correct = parseInt(id) is this.current().id
    this.log_result id, correct
    if correct
      this.correct(this.current().object)
    else
      this.incorrect(this.current().object)
    setTimeout (()=>
      this.current().object.mesh.setColor([1,1,1,1]) if this.current() and this.current().object
      context.current_controller.show_hover=true
      if @temp_region
        context.current_controller.hide_region @temp_region
        @temp_region = 0
      this.proceed() if this.is_active()), 1200
    
  correct: (region) ->
    this.update_status "Correct!", "positive"
    region.mesh.setColor([0,1,0,1])
    context.current_controller.show_hover = false
    @quiz.correct +=1
  
  incorrect: (region) ->
    this.update_status "Incorrect!", "negative"
    region.mesh.setColor([1,0,0,1])
    context.current_controller.show_hover = false
  
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
      options.push [r.id,extend_name(r.name)]
      options = options.uniqBy(0)
    $('#mcq_widgets').slideDown(500)
    $('#mcq_answers').html("")
    options.sort(()->0.5-Math.random())
    for option in options
      $('#mcq_answers').append $("<li><input type='radio', id='answer_"+option[0]+"' name='mcq_answers'><label for='answer_"+option[0]+"'>"+option[1]+"</label></li>")
    
  log_result: (answer,correct) ->
    @quiz.new_stats[this.current().name] ?= {}
    @quiz.new_stats[this.current().name][@quiz.mode] ?= [0,0]
    @quiz.new_stats[this.current().name][@quiz.mode][0] += 1 if correct
    @quiz.new_stats[this.current().name][@quiz.mode][1] += 1
    logger.log_quiz
      type: 'quiz_response'
      m:@quiz.mode
      n:@quiz.active
      s:@quiz.list.length
      q:this.current().name
      a_rid:answer
      c:correct
    
  update_stats_view: () ->
    context.current_controller.update_quiz_mode()
    
    
    
    
  