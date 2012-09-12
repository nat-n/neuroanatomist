Jax.getGlobal()['Logger'] = Jax.Model.create
  after_initialize: ->
    @log = window.context.log = {} # timestamp as key
    @most_recent = 0
    
  log_input_event: () ->
    # 
  
  log_app_event: () -> # e.g. change in url/state/view
    # {type, content}
    
  store_logs: () ->
    # attempt to post the logs to the server, on fail save them to indexedDB
    upload_times = (time for time of @log)
    $.ajax
      type: 'POST'
      url:  '/user'
      data: {logs: (@log[time] for time in upload_times)}
      success: (response) ->
        # clear log of uploaded times
        delete @log[time] for time in upload_times) if response = "logs saved"
      error: () ->
        # dump log in indexedDB