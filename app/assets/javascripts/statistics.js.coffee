# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	$('#language_statistics').change ->
		selected = $('#language_statistics option').filter(':selected').text()
		if selected is $('#language_statistics option').filter(':first').text()
			window.location.href = "/statistics"
		else
			window.location.href = "/statistics/" + selected.toLowerCase()
