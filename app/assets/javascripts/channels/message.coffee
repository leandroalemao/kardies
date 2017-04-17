$(document).on "turbolinks:load", ->
  conversation_id = $('#conversation').attr('conversation-id')

  App.message = App.cable.subscriptions.create { channel: "MessageChannel", conversation_id: conversation_id },

    connected: ->
      # Called when the subscription is ready for use on the server

    disconnected: ->
      App.cable.disconnect()

    received: (data) ->
      $('#messages').append(data['message'])
      messages_to_bottom()

    speak: (message, convo_id) ->
      @perform 'speak', message: message, conversation_id: convo_id

  if App.cable.subscriptions['subscriptions'].length > 1
    App.cable.subscriptions.remove(App.cable.subscriptions['subscriptions'][1])

  $(document).on 'keypress', '[data-behaviour~=message_speaker]', (event) ->
    if event.keyCode is 13
      messageValue = event.target.value
      unless sanitizeInput(messageValue) == ""
        App.message.speak messageValue, conversation_id
      event.target.value = ""
      event.preventDefault()

  $('#conversation-form').submit (e) ->
    e.preventDefault()
    messageValue = $('.conversation-message').val()
    unless sanitizeInput(messageValue) == ""
      App.message.speak messageValue, conversation_id
    $('.conversation-message').val("")

  sanitizeInput = (data) ->
    regex = /\<|\>/g
    trimmedData = data.replace(regex, "").trim()
    return trimmedData

  messages = $('#messages')
  if $('#messages').length > 0
    messages_to_bottom = -> messages.scrollTop(messages.prop("scrollHeight"))

    messages_to_bottom()
