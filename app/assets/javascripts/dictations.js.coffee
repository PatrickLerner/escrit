current_word = {}
meta_language_voice = false
meta_language_voice_rate = false
meta_audio_rate = false
disabledLinks = true

disableButtons = ->
  disabledLinks = true

enableButtons = ->
  disabledLinks = false

refreshWord = ->
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
  language = $('#meta_language').html().toLowerCase()
  refreshWord()

  $('#showAnswer').click ->
    return if disabledLinks
    disableButtons()

  $('#play').click ->
    return if disabledLinks
    speak current_word['value'], false

  $('#playSlow').click ->
    return if disabledLinks
    speak current_word['value'], true
