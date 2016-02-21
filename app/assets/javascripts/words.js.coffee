# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('.toggleVocabulary').click (event) ->
    language = $('#meta_language').html()
    obj = $(event.target)
    word = obj.attr 'value'
    if obj.hasClass 'fa-minus'
      obj.addClass 'fa-check'
      obj.removeClass 'fa-minus'
      $.ajax
        type: 'get'
        url: "/#{language}/words/#{word}/set"
        async: true
    else
      obj.addClass 'fa-minus'
      obj.removeClass 'fa-check'
      $.ajax
        type: 'get'
        url: "/#{language}/words/#{word}/unset"
        async: true
