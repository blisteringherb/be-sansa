$ ->
  ws = new WebSocket("ws://10.3.6.27:58877")
  ws.onmessage = (evt) ->
    if $("#chat tbody tr:first").length > 0
      $("#chat tbody tr:first").before "<tr><td>" + evt.data + "</td></tr>"
    else
      $("#chat tbody").append "<tr><td>" + evt.data + "</td></tr>"

  ws.onclose = ->
    ws.send "Leaves the chat"

  ws.onopen = ->
    ws.send "Join the chat"

  $("form").submit (e) ->
    if $("#msg").val().length > 0
      ws.send $("#msg").val()
      $("#msg").val ""
    false

  $("#clear").click ->
    $("#chat tbody tr").remove()