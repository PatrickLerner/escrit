initAudioJS = ->
  audiojs.events.ready ->
    audiojs.createAll()

updateCharCount = ->
  if $('#text_content').length != 0
    count = $('#text_content').val().length
    $('#character_count').text(count.toLocaleString('en-US'))
    if count > 15000
      $('#character_count').css('color', 'red')
    else
      $('#character_count').css('color', '')

initCategoryAutoComplete = ->
  $('#text_category').autocomplete
    source: (request, response) ->
      $.getJSON '/texts/category', {
        lang: text_language
        'term': $('#text_category').val()
      }, response
      return
    minLength: 1

initTextNewAndEdit = ->
  $('#text_content').keyup updateCharCount
  updateCharCount()
  initCategoryAutoComplete()

initToggleButton = (id, f) ->
  $('#' + id).click ->
    if $('#' + id + ' i').hasClass('fa-toggle-on')
      $('#' + id + ' i').attr 'class', 'fa fa-toggle-off'
      f(false)
    else
      $('#' + id + ' i').attr 'class', 'fa fa-toggle-on'
      f(true)
    false

archiveToggle = (newState) ->
  $('#text_hidden').prop 'checked', newState

publicToggle = (newState) ->
  $('#text_public').prop 'checked', newState

$ ->
  initAudioJS()
  initTextNewAndEdit()

  initToggleButton 'archiveToggle', archiveToggle
  initToggleButton 'publicToggle', publicToggle
