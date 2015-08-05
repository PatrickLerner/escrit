# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	$('#service_url').keydown ->
		s = $('#service_url').val()
		$('p.warning').css('display', if /\{query\}/.test(s) then 'none' else 'block')
	$('#service_url').change ->
		s = $('#service_url').val()
		$('p.warning').css('display', if /\{query\}/.test(s) then 'none' else 'block')
