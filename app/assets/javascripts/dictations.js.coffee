current_word = {}
meta_language_voice = false
meta_language_voice_rate = false
meta_audio_rate = false
disabledLinks = true
chance = false

shake = (div) ->
  interval = 100
  distance = 10
  times = 6
  $(div).css 'position', 'relative'
  iter = 0
  while iter < times + 1
    $(div).animate { left: if iter % 2 == 0 then distance else distance * -1 }, interval
    iter++
  $(div).animate { left: 0 }, interval
  return

disableButtons = ->
  disabledLinks = true

enableButtons = ->
  disabledLinks = false

refreshWord = ->
  $('#word').val ''
  chance = false
  $('#wordDisplay').html '&nbsp;'
  $('#wordNote').html '&nbsp;'
  $('#vocabButtons #after').fadeOut 300, ->
    $('#vocabButtons #before').fadeIn 300
  $('#buttons').fadeTo 0, 0
  language = $('#meta_language').html().toLowerCase()
  changed = false
  $.getJSON "/dictation/#{language}.json", (data) ->
    current_word = data
    if current_word['value'] == undefined
      $('#vocab').hide()
      $('#no-vocab').show()
    else
      $('#vocab').show()
      $('#no-vocab').hide()
      speak current_word['value'], false
      $('#word').focus()
    enableButtons()

speak = (text, slow) ->
  meta_language_voice = $('#meta_language_voice').html()
  meta_language_voice_rate = $('#meta_language_voice_rate').html()
  meta_audio_rate = $('#meta_audio_rate').html()
  if meta_language_voice != '' and text != '' and meta_audio_rate > 0
    rate = parseFloat(meta_language_voice_rate * (meta_audio_rate/100))
    rate *= 0.5 if slow
    responsiveVoice.speak text, meta_language_voice, { rate: rate }

reveal = ->
  $('#wordDisplay').html current_word['value']
  $('#wordNote').html current_word['note']
  speak current_word['value'], false
  $('#vocabButtons #before').fadeOut 300, ->
    $('#vocabButtons #after').fadeIn 300
    enableButtons()

$ ->
  if ($('body').attr('data-controller') != 'dictations') || ($('body').attr('data-action') != 'index')
    return
  language = $('#meta_language').html().toLowerCase()
  refreshWord()

  $('#newWord').click ->
    return if disabledLinks
    disableButtons()
    refreshWord()
    $('#vocabButtons #after').fadeOut 300, ->
      $('#vocabButtons #before').fadeIn 300
      enableButtons()

  $('#checkAnswer').click ->
    return if disabledLinks
    disableButtons()
    val = $('#word').val()
    if val.toLowerCase() != current_word['value'].toLowerCase()
      if chance == false
        shake $('#word')
        speak current_word['value'], false
        chance = true
        enableButtons()
      else
        shake $('#word')
        reveal()
    else
      reveal()
    $('#word').focus()

  $('#play').click ->
    return if disabledLinks
    speak current_word['value'], false
    $('#word').focus()

  $('#playSlow').click ->
    return if disabledLinks
    speak current_word['value'], true
    $('#word').focus()
