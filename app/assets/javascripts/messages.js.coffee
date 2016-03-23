source = new EventSource("/messages/events")
source.addEventListener "message", (e) ->
  console.log(e.data)
  message = $.parseJSON(e.data)
  $("#chat").append($("<li>").text("#{message.name}: #{message.content}"))
