
window.update_mode_from_url = () ->
  mode = window.location.href.split('#')[1]
  logger.log_event(type: 'update_mode_from_url', mode:mode)
  if $('.embedded_node').length
    $('#node_options')[0].toggle_option("edit", "hide")
    $('#node_options')[0].toggle_option("history", "hide")
  switch mode
    when 'editing_node'
      $('#node_options')[0].toggle_option("edit", "show")
    when 'viewing_history_node'
      $('#node_options')[0].toggle_option("history", "show")
    else
      if mode and mode[0] == '!'
        new_title = document.title
        state_object = {type:'m'}
        new_url = window.location.href.split('#')[0]
        setTimeout (()=>window.history.replaceState state_object, new_title, new_url), 10 # dirty hack i know... but it need to be async
      mode = null