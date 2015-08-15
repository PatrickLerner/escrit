# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	$('#language_text').change ->
		selected = $('#language_text option').filter(':selected').text()
		if selected is $('#language_text option').filter(':first').text()
			window.location.href = "/texts"
		else
			window.location.href = "/texts/" + selected.toLowerCase()
	audiojs.events.ready ->
    	audiojs.createAll()
