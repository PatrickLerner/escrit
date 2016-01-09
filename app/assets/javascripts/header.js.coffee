$ ->
  if $('body').attr('data-controller') == 'welcome' || ($('body').attr('data-controller') == 'texts' && $('body').attr('data-action') == 'show')
    return
  $('header').click ->
    head = $(this)
    if head.hasClass 'large'
      head.animate({
        'padding-top': '15rem',
        'padding-bottom': '13rem'
      }, 2000);
      $('.image', head).animate({
        'opacity': 1
      }, 2000);
      head.removeClass 'large'
      head.addClass 'x-large'
    else if head.hasClass 'x-large'
      head.animate({
        'padding-top': '6rem',
        'padding-bottom': '4rem'
      }, 2000);
      $('.image', head).animate({
        'opacity': 0.4
      }, 2000);
      head.removeClass 'x-large'
    else
      head.animate({
        'padding-top': '12rem',
        'padding-bottom': '10rem'
      }, 2000);
      $('.image', head).animate({
        'opacity': 0.4
      }, 2000);
      head.addClass 'large'
