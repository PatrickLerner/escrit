# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

vocabulary_words = []
current_word = {}

refreshVocabulary = ->
  language = $('#meta_language').html().toLowerCase()
  $.getJSON "/vocabulary/#{language}.json", (data) ->
    vocabulary_words = data
    if vocabulary_words.length == 0
      $('#no-vocab').show();
      $('#vocab').hide();
    else
      $('#vocab').show();
      $('#no-vocab').hide();
      $('#vocabButtons #before').show()
      $('#vocabButtons #after').hide()
      # if we still have more than one word, lets not do the last word again
      if vocabulary_words.length > 1
        index = vocabulary_words.indexOf(current_word.value)
        vocabulary_words.splice(index, 1)
      p = vocabulary_words[Math.floor(Math.random() * vocabulary_words.length)]
      $.getJSON "/words/#{language}/#{p}", (data) ->
        current_word = data
        console.log vocabulary_words
        $('#wordvalue').html current_word['value']
        $('#word').html current_word['value']
        $('#note').html current_word['note']

$ ->
  refreshVocabulary()

  $('#showAnswer').click ->
    $('#note').fadeTo 500, 1
    $('#vocabButtons #before').fadeOut 300, ->
      $('#vocabButtons #after').fadeIn(300)
  $('#correctAnswer').click ->
    language = $('#meta_language').html().toLowerCase()
    wordvalue = $('#wordvalue').html().toLowerCase()
    $.ajax
      type: 'PATCH'
      url: '/words/' + wordvalue
      data:
        'word[language]': language
        #'word[rating]': rating
      async: true
    refreshVocabulary()
  $('#incorrectAnswer').click ->
    refreshVocabulary()
