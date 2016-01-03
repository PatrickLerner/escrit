# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

vocabulary_words = []
current_word = {}
changed = false
new_ratings = {}

setRating = (rating) ->
  current_word['rating'] = rating
  changed = true
  $('#word').attr 'class', ''
  $('#word').addClass "s#{current_word['rating']}"
  $('#buttons span').css('opacity', 0.5)
  $("#buttons .s#{current_word['rating']}").css('opacity', 1)

refreshVocabulary = ->
  $('#word').html '&nbsp;'
  $('#note').fadeTo 0, 0
  $('#buttons').fadeTo 0, 0
  $('#vocabButtons #before').show()
  $('#vocabButtons #after').hide()
  language = $('#meta_language').html().toLowerCase()
  changed = false
  $.getJSON "/vocabulary/#{language}.json", (data) ->
    vocabulary_words = data
    $('#count').html vocabulary_words.length
    if vocabulary_words.length == 0
      $('#no-vocab').show()
      $('#vocab').hide()
    else
      $('#vocab').show()
      $('#no-vocab').hide()
      # if we still have more than one word, lets not do the last word again
      if vocabulary_words.length > 1
        index = vocabulary_words.indexOf(current_word.value)
        vocabulary_words.splice(index, 1)

      p = vocabulary_words[Math.floor(Math.random() * vocabulary_words.length)]
      $.getJSON "/words/#{language}/#{p}", (data) ->
        current_word = data
        $('#wordvalue').html current_word['value']
        $('#word').html "<a href='/words/#{language}/#{current_word['value']}/edit' target='_blank'>#{current_word['value_clean']}</a>"
        $('#note').html current_word['note']
        if new_ratings.hasOwnProperty(current_word['value'])
          setRating new_ratings[current_word['value']]
        else
          setRating current_word['rating']

$ ->
  if ($('body').attr('data-controller') != 'vocabularies') || ($('body').attr('data-action') != 'index')
    return
  language = $('#meta_language').html().toLowerCase()
  refreshVocabulary()

  $('#vocab h1').mouseover ->
    $('#buttons').fadeTo 300, 1
  $('#showAnswer').click ->
    $('#note').fadeTo 500, 1
    $('#vocabButtons #before').fadeOut 300, ->
      $('#vocabButtons #after').fadeIn(300)
  $('#correctAnswer').click ->
    wordvalue = $('#wordvalue').html().toLowerCase()
    $.ajax
      type: 'PATCH'
      url: '/words/' + wordvalue
      data:
        'word[language]': language
        'word[rating]': current_word['rating']
        'word[note]': current_word['note']
      async: false
    refreshVocabulary()
  $('#incorrectAnswer').click ->
    if changed
      new_ratings[current_word['value']] = current_word['rating']
    refreshVocabulary()
  $('#buttons span').click ->
    rating = $(this).attr('value')
    setRating(rating)
