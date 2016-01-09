$ ->
  $('.alert, .notice').slideDown 1000

  $('.alert, .notice').click ->
    $(this).slideUp 1000

  autoHideNotice = ->
    $('.notice').slideUp 1000

  setTimeout autoHideNotice, 5000

  if $('body').attr('data-controller') == 'welcome' || ($('body').attr('data-controller') == 'texts' && $('body').attr('data-action') == 'show')
    return

  xlarge = (head) ->
    head.animate({
      'padding-top': '15rem',
      'padding-bottom': '13rem'
    }, 2000);
    $('.image', head).animate({
      'opacity': 1
    }, 2000);
    $('h1, h2', head).animate({
      'opacity': 0
    }, 2000);

  small = (head) ->
    head.animate({
      'padding-top': '6rem',
      'padding-bottom': '4rem'
    }, 2000);
    $('.image', head).animate({
      'opacity': 0.4
    }, 2000);
    $('h1, h2', head).animate({
      'opacity': 1
    }, 2000);

  large = (head) ->
    head.animate({
      'padding-top': '12rem',
      'padding-bottom': '10rem'
    }, 2000);
    $('.image', head).animate({
      'opacity': 0.4
    }, 2000);
    $('h1, h2', head).animate({
      'opacity': 1
    }, 2000);

  $('header').click ->
    head = $(this)
    if head.hasClass 'preview'
      if head.hasClass 'large'
        small(head)
        head.removeClass 'large'
      else
        large(head)
        head.addClass 'large'
    else if head.hasClass 'x-large'
      if head.hasClass 'large'
        large(head)
      else
        small(head)
      head.removeClass 'x-large'
    else
      xlarge(head)
      head.addClass 'x-large'
