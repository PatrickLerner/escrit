$ ->
  $('#user_audio_rate').on 'input', ->
    val = $('#user_audio_rate').val()
    $('#audio_rate').html "#{val}%"
  $('#test_audio').click ->
    val = $('#user_audio_rate').val()
    if val > 0
      responsiveVoice.speak 'Hello!', 'UK English Male', { rate: 0.75*(val/100) }
