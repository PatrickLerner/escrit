last_word = ''
last_word_case = ''
needSave = false
text_language = undefined
no_patch = false
description = [
  'Never seen it before.'
  'Looked it up once.'
  'This time I\'ll remember it.'
  'I\'m getting it now.'
  'Seems easy at this point.'
  'Know it in my sleep.'
  '(Ignore Word)'
]
showColors = true
underlineColors = false
currentRating = 0
old_nl = -1
isMobile = false
lastObject = null

# detects if the user is on a mobile device
detectMobile = ->
  if /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent) or /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0, 4))
    isMobile = true

initAudioJS = ->
  audiojs.events.ready ->
    audiojs.createAll()

initTextIndex = ->
  $('.showMoreText').click ->
    value = $(this).attr('value')
    $('.cat-' + value).css('display', 'table-row')
    $(this).css('display', 'none')
    return false

updateCharCount = ->
  if $('#text_content').length != 0
    count = $('#text_content').val().length
    $('#character_count').text(count.toLocaleString('en-US'))
    if count > 10000
      $('#character_count').css('color', 'red')
    else
      $('#character_count').css('color', '')

initCategoryAutoComplete = ->
  $('#text_category').autocomplete
    source: (request, response) ->
      $.getJSON '/texts/category', {
        lang: $('#text_language_id').val()
        'term': $('#text_category').val()
      }, response
      return
    minLength: 1

initTextNewAndEdit = ->
  $('#text_content').keyup updateCharCount
  updateCharCount()
  initCategoryAutoComplete()

updateCounter = ->
  onlyUnique = (value, index, self) ->
    self.indexOf(value) == index
  nl = $('.s0.w').map(->
    @innerHTML.toLowerCase()
  ).get().filter(onlyUnique).length
  total = $('.w').map(->
    @innerHTML.toLowerCase()
  ).get().filter(onlyUnique).length
  rated = total - nl
  words = $('.word').length
  if words > 0 and !no_patch
    if old_nl == -1 or old_nl == 0 and nl != 0 or old_nl != 0 and nl == 0
      $.ajax
        type: 'PATCH'
        url: document.URL
        data: 'text[completed]': nl == 0
        async: true
    old_nl = nl
  sum = 0
  i = 1
  while i <= 5
    sum += i * $('.s' + i + '.w').map(->
      @innerHTML.toLowerCase()
    ).get().filter(onlyUnique).length
    i++
  count = $('.w').map(->
    @innerHTML.toLowerCase()
  ).get().filter(onlyUnique).length
  rating = (sum / count).toFixed(1)
  $('#unratedWords').html nl
  $('#unratedWords').attr 'title', 'In this text you have ' + nl + ' unrated words and ' + rated + ' rated words from a total of ' + total + ' unique words.'
  $('#averageRating').html rating
  $('#unratedWordsPlural').html if nl == 1 then 'word' else 'words'
  if total == 0
    $('.stat-block').html ''
  return

initLookupLinks = ->
  $('.lookup #links a').click ->
    if !isMobile
      $('.lookup #lword').focus()
    return

initTextShow = ->
  text_language = $('#meta_language').html()
  if $('#meta_no_patch')
    no_patch = $('#meta_no_patch').html() == 'true'
  updateCounter()
  initLookupLinks()

refreshWordRating = (word, word_case, rating) ->
  currentRating = rating
  $('.word').each (i) ->
    if $(this).attr('value').toLowerCase() == word.toLowerCase()
      i = 0
      while i <= 6
        $(this).removeClass 's' + i
        i++
      $(this).addClass 's' + rating
  updateCounter()
  if last_word == word
    i = 0
    while i <= 6
      $('#buttons .s' + i).css 'opacity', '0.4'
      i++
    $('#buttons .s' + rating).css 'opacity', '1.0'
    $('#description').html description[rating]
    $('.lookup #links a').each (i) ->
      t_href = $(this).attr('t_href')
      $(this).attr 'href', t_href.replace('{query}', encodeURIComponent(word_case))

onRatingsButton = (rating) ->
  currentRating = rating
  if last_word
    $.ajax
      type: 'PATCH'
      url: '/words/' + last_word
      data:
        'word[note]': $('#lword').val()
        'word[language]': text_language
        'word[rating]': rating
      async: true
    refreshWordRating last_word, last_word_case, rating
    needSave = false
  return

word_link = (event) ->
  if lastObject
    lastObject.css 'border-bottom', ''
  lastObject = $(event.target)
  lastObject.css 'border-bottom', '1px solid red'
  if last_word != '' and needSave
    $.ajax
      type: 'PATCH'
      url: '/words/' + last_word
      data:
        'word[note]': $('#lword').val()
        'word[language]': text_language
      async: true
    needSave = false
  if last_word == $(event.target).attr('value')
    $('.lookup').fadeOut 400
    last_word = ''
    lastObject.css 'border-bottom', ''
  else
    cw = $(event.target).attr('value')
    cw_case = event.target.innerHTML
    last_word = cw
    last_word_case = cw_case
    if $(event.target).attr('title')
      last_word_case = $(event.target).attr('title')
      last_word_case = last_word_case.replace('...', ' ... ')
      last_word_case = last_word_case.replace('..', ' ... ')
      last_word_case = last_word_case.replace('_', ' ')
    $.getJSON '/words/' + text_language + '/' + last_word, (data) ->
      $('.lookup').fadeIn 400
      if last_word == cw
        $('.lookup #rword').html last_word_case
        $('.lookup #lword').val data['note']
      refreshWordRating cw, cw_case, data['rating']
      if !isMobile
        $('.lookup #lword').focus()
      needSave = false
      return
  return

initWordLinks = ->
  $('.word').click word_link

initToggleButton = (id, f) ->
  $('#' + id).click ->
    if $('#' + id + ' i').hasClass('fa-toggle-on')
      $('#' + id + ' i').attr 'class', 'fa fa-toggle-off'
      f(false)
    else
      $('#' + id + ' i').attr 'class', 'fa fa-toggle-on'
      f(true)
    false

colorToggle = (newState) ->
  if newState
    $('.w').css 'background', ''
    $('.w').css 'border', ''
    $('#underlineToggle').css 'display', 'block'
  else
    $('.w').css 'background', 'white'
    $('.w').css 'border', 'none'
    $('#underlineToggle').css 'display', 'none'

underlineToggle = (newState) ->
  if newState
    $('.w').addClass 'underline'
  else
    $('.w').removeClass 'underline'

archiveToggle = (newState) ->
  if newState
    $('#text_hidden').prop 'checked', true
  else
    $('#text_hidden').prop 'checked', false

publicToggle = (newState) ->
  if newState
    $('#text_public').prop 'checked', true
  else
    $('#text_public').prop 'checked', false

initWordNumbers = ->
  i = 0
  for w in $('.w')
    $(w).attr('nid', i++)


$ ->
  detectMobile()
  initAudioJS()
  initTextIndex()
  initTextNewAndEdit()
  initTextShow()
  initWordLinks()
  initWordNumbers()

  initToggleButton 'colorToggle', colorToggle
  initToggleButton 'underlineToggle', underlineToggle
  initToggleButton 'archiveToggle', archiveToggle
  initToggleButton 'publicToggle', publicToggle

  $('#buttons span').click (event) ->
    rating = event.target.innerHTML
    if rating == '/'
      rating = 6
    else
      rating = parseInt(rating)
    onRatingsButton rating
    if !isMobile
      $('.lookup #lword').focus()
    return
  $('.lookup #lword').change ->
    needSave = true
    return
  $('.lookup #lword').keyup (event) ->
    keyCode = event.keyCode or event.which
    if keyCode == 9
      event.preventDefault()
    return
  $('.lookup #lword').keypress (event) ->
    keyCode = event.keyCode or event.which
    if keyCode == 9
      event.preventDefault()
    return
  $('.lookup #lword').keydown (event) ->
    keyCode = event.keyCode or event.which
    if keyCode == 13 and last_word
      $.ajax
        type: 'PATCH'
        url: '/words/' + last_word
        data:
          'word[note]': $('#lword').val()
          'word[language]': text_language
        async: true
    # tab key incrases rating by one
    if keyCode == 9
      event.preventDefault()
      if !event.shiftKey
        currentRating += 1
      else
        currentRating -= 1
      if currentRating > 6
        currentRating = 0
      if currentRating < 0
        currentRating = 6
      onRatingsButton currentRating
    if keyCode == 40 or keyCode == 38
      orig = parseInt($(lastObject).attr('nid'))
      delta = 1
      if keyCode == 38
        delta = -1
      nid = orig + delta
      if not event.shiftKey
        while (orig != nid) and ($('span.w[nid=' + nid + ']').attr('value') == $('span.w[nid=' + orig + ']').attr('value') or $('span.w[nid=' + nid + ']').hasClass('s5') or $('span.w[nid=' + nid + ']').hasClass('s6'))
          nid += delta
          if nid == $('.w').size()
            nid = 0
          if nid == -1
            nid = $('.w').size() - 1
      if orig != nid
        $('span.w[nid=' + nid + ']').click()
      event.preventDefault()
    if keyCode == 48 and event.ctrlKey
      onRatingsButton 0
      event.preventDefault()
    if keyCode == 49 and event.ctrlKey
      onRatingsButton 1
      event.preventDefault()
    if keyCode == 50 and event.ctrlKey
      onRatingsButton 2
      event.preventDefault()
    if keyCode == 51 and event.ctrlKey
      onRatingsButton 3
      event.preventDefault()
    if keyCode == 52 and event.ctrlKey
      onRatingsButton 4
      event.preventDefault()
    if keyCode == 53 and event.ctrlKey
      onRatingsButton 5
      event.preventDefault()
    if keyCode == 54 and event.ctrlKey
      onRatingsButton 6
      event.preventDefault()
    return
  $('#close-btn').bind 'click', (evt) ->
    if last_word != '' and needSave
      $.ajax
        type: 'PATCH'
        url: '/words/' + last_word
        data:
          'word[note]': $('#lword').val()
          'word[language]': text_language
        async: true
      needSave = false
    $('.lookup').fadeOut 400
    last_word = ''
    return
  $('#preview_btn').bind 'click', (evt) ->
    text = $('#preview_text').val()
    $.post('#', text: text).done (data) ->
      $('#text').html data
      $('.word').click word_link
      initWordNumbers()
      return
    false
  return
