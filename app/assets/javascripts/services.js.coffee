$ ->
  check_url_mask = ->
    s = $('#service_url').val()
    if /\{query\}/.test(s)
      $('p.warning').css('display', 'none')
    else
      $('p.warning').css('display', 'block')

  $('#service_url').keydown check_url_mask
  $('#service_url').keyup check_url_mask
  $('#service_url').change check_url_mask
  check_url_mask()
