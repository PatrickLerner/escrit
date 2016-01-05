$ ->
  if $('body').attr('data-controller') == 'welcome'
    return
  $('header').click ->
    head = $(this)
    if head.hasClass 'large'
      head.removeClass 'large'
    else
      head.addClass 'large'
