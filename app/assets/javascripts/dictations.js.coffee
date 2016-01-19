current_word = {}
meta_language_voice = false
meta_language_voice_rate = false
meta_audio_rate = false
disabledLinks = true

shake = (div) ->
  interval = 50
  distance = 10
  times = 4
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
  $('#vocabButtons #after').fadeOut 300, ->
    $('#vocabButtons #before').fadeIn 300
  $('#buttons').fadeTo 0, 0
  language = $('#meta_language').html().toLowerCase()
  changed = false
  $.getJSON "/dictation/#{language}.json", (data) ->
    current_word = data
    enableButtons()

speak = (text, slow) ->
  meta_language_voice = $('#meta_language_voice').html()
  meta_language_voice_rate = $('#meta_language_voice_rate').html()
  meta_audio_rate = $('#meta_audio_rate').html()
  if meta_language_voice != '' and text != '' and meta_audio_rate > 0
    rate = parseFloat(meta_language_voice_rate * (meta_audio_rate/100))
    rate *= 0.5 if slow
    responsiveVoice.speak text, meta_language_voice, { rate: rate }

$ ->
  if ($('body').attr('data-controller') != 'dictations') || ($('body').attr('data-action') != 'index')
    return
  $('#word').focus()
  language = $('#meta_language').html().toLowerCase()
  refreshWord()

  $('#checkAnswer').click ->
    return if disabledLinks
    #disableButtons()
    val = $('#word').val()
    if val.toLowerCase() != current_word['value'].toLowerCase()
      shake $('#word')
    else
      refreshWord()
    $('#word').focus()

  $('#play').click ->
    return if disabledLinks
    speak current_word['value'], false
    $('#word').focus()

  $('#playSlow').click ->
    return if disabledLinks
    speak current_word['value'], true
    $('#word').focus()
