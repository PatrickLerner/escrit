$ ->
  if $('body').attr('data-controller') == 'welcome' || ($('body').attr('data-controller') == 'texts' && $('body').attr('data-action') == 'show')
    return
  $('header').click ->
    head = $(this)
    if head.hasClass 'large'
      head.removeClass 'large'
    else
      head.addClass 'large'
