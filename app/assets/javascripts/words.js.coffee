# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	$('#language_words').change ->
		selected = $('#language_words option').filter(':selected').text()
		if selected is $('#language_words option').filter(':first').text()
			window.location.href = "/words"
		else
			window.location.href = "/words/" + selected.toLowerCase()
