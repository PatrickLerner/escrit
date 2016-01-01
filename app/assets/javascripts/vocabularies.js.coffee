# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  language = $('#meta_language').html().toLowerCase()

  $('#showAnswer').click ->
    $('#answer').fadeTo 500, 1
    $('#vocabButtons #before').fadeOut 300, ->
      $('#vocabButtons #after').fadeIn(300)
  $('#correctAnswer').click ->
    wordvalue = $('#wordvalue').html().toLowerCase()
    $.ajax
      type: 'PATCH'
      url: '/words/' + wordvalue
      data:
        'word[language]': language
        #'word[rating]': rating
      async: false
    window.location.replace "/vocabulary/#{language}"
  $('#incorrectAnswer').click ->
    window.location.replace "/vocabulary/#{language}"
