# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

updateCharCount = ->
    if $('#text_content').length != 0
        count = $('#text_content').val().length
        $('#character_count').text(count.toLocaleString('en-US'))
        if count > 10000
            $('#character_count').css('color', 'red')
        else
            $('#character_count').css('color', '')


$ ->
    $('#language_text').change ->
        selected = $('#language_text option').filter(':selected').text()
        if selected is $('#language_text option').filter(':first').text()
            window.location.href = "/texts"
        else
            window.location.href = "/texts/" + selected.toLowerCase()
    audiojs.events.ready ->
        audiojs.createAll()
    $('.showMoreText').click ->
        value = $(this).attr('value')
        $('.cat-' + value).css('display', 'table-row')
        $(this).css('display', 'none')
        return false

    $('#text_content').keyup updateCharCount
    updateCharCount()
