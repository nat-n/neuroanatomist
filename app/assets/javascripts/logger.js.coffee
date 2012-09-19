window.Logger = class Logger
  log: []
  most_recent = 0
  quizzed = false
  constructor: () ->
      
  log_input: (event, props={}) ->
    props.type = event.type
    
    this.log_event(props)

  log_mouse: (event, props={}) ->
    props.type = event.type
    props.target = (event.target.localName+'.'+event.target.id)
    props.scrnX = event.screenX
    props.scrnY = event.screenY
    props.x = event.x
    props.y = event.y
    props.dx = event.diffx
    props.dy = event.diffy
    props.wd = event.wheelDelta
    this.log_event(props)
  
  log_quiz: (props) ->
    quizzed = true
    @log.push props
  
  log_event: (props) -> # e.g. change in url/state/view
    props['ts'] = Date.now()
    props['u'] = page_data.user
    props['a'] = page_data.action
    @log.push props
    
  store_logs: () ->
    # attempt to post the logs to the server, on fail save them to indexedDB
    upload_times = (time for time of @log)
    $.ajax
      type: 'POST'
      url:  '/user'
      data: {logs: (@log[time] for time in upload_times)}
      success: (response) ->
        # clear log of uploaded times
        if response = "logs saved"
          delete @log[time] for time in upload_times
      error: () ->
        # dump log in indexedDB
        

window.logger = new Logger()

window.onresize = (e) ->
  logger.log_input e,
    window_w: window.innerWidth
    window_h: window.innerWidth

window.onscroll = (e) ->
  logger.log_input e,
    scroll: $(window).scrollTop()

window.onbeforeunload = (e) ->
  logger.log_input e
  logger.store_logs()

window.oncontextmenu = (e) ->
  logger.log_mouse e

