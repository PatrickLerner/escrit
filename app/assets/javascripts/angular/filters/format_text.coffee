@escrit.filter 'formatText', ['$sce', ($sce) ->
  parseYoutube = (input) ->
    return input unless input.match(/^https?:\/\/(www\.)?youtube.com\/watch/)?
    id = input.split('v=')[1].replace(/&.*/, '')
    "<div class='videoWrapper'><div class='video'>" +
      "<iframe id='ytplayer' type='text/html'" +
      " src='https://www.youtube.com/embed/#{id}'" +
      " frameborder='0'></iframe></div></div>"

  parseAudio = (input) ->
    return input unless input.trim().match(/^https?:\/\/.*\.(m4a|mp3)$/)?
    "<audio src='#{input.trim()}' preload='none'></audio>"

  parseImages = (input) ->
    return input unless input.trim().match(/^https?:\/\/.*\.(jpg|png|gif)$/)?
    "<img src='#{input.trim()}' />"

  parseImagesWithBorder = (input) ->
    return input unless input.trim().match(/^@https?:\/\/.*\.(jpg|png|gif)$/)?
    "<img src='#{input.substr(1).trim()}' class='border' />"

  parseMedia = (input) ->
    input = parseYoutube(input)
    input = parseAudio(input)
    input = parseImages(input)
    input = parseImagesWithBorder(input)
    input

  parseHeaders = (input) ->
    return input unless input.trim().match(/^#/)?
    input.replace /^([#]+)(.*)/, (match, level, title) ->
      level = level.length + 1
      level = Math.min(level, 6)
      "<h#{level}>#{title}</h#{level}>"

  parseBold = (input) ->
    input.replace /\*\*(.+?)\*\*/, (_, text) => "<strong>#{text}</strong>"

  parseItalic = (input) ->
    input.replace /__(.+?)__/, (_, text) => "<em>#{text}</em>"

  parseUnderline = (input) ->
    input.replace /_(.+?)_/, (_, text) => "<u>#{text}</u>"

  replacementQuoteCharacter = '_@>'
  parseQuotes = (input) ->
    exp = "(^(#{replacementQuoteCharacter}.+\\n?)+)|" +
          "(\\n(#{replacementQuoteCharacter}.+\\n?)+)"
    input = input.replace new RegExp(exp, 'g'), (text) ->
      text = text.replace(new RegExp(replacementQuoteCharacter, 'g'), '')
      "<blockquote>#{text}</blockquote>"
    input = input.replace(new RegExp(replacementQuoteCharacter, 'g'), '>')

  parseTypography = (input) ->
    input = parseHeaders(input)
    input = parseBold(input)
    input = parseItalic(input)
    input = parseUnderline(input)
    input

  parseNewLines = (input) ->
    input = parseQuotes(input)
    lines = input.split("\n")
    lines = lines.map((input) => parseMedia(input))
    lines = lines.map((input) => parseTypography(input))
    lines.join('<br />')

  parseParagraphs = (paragraphs) ->
    "<p>#{paragraphs.map((paragraph) ->
      parseNewLines(paragraph)
    ).join('</p><p>')}</p>"

  parseLines = (input) ->
    paragraphs = input.split("\n\n")
    if paragraphs.length == 1
      parseNewLines(paragraphs[0])
    else
      parseParagraphs(paragraphs)

  escapeRegExp = (str) ->
    str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

  formatWord = (str) ->
    str.replace(/^(.+?)\|\|.+?$/, "$1")

  regex = unicode_hack(/[\p{L}][\p{L}\-\|\.:\/\?=0-9%_]+[\p{L}0-9]|[\p{L}]+/g)

  tokenize = (input, split_tokens) ->
    input.replace regex, (word) ->
      token = split_tokens[word]
      return word unless token?
      capitalized = word.isCapitalized()
      "<span ng-click='showWord(\"#{token}\", #{capitalized})'" +
        " class='word'" +
        " ng-class='{ unknown: unknownWords[\"#{token}\"] }'" +
        ">" +
          "#{formatWord(word)}" +
      "</span>"

  return (input, split_tokens) ->
    return unless input?
    res = input.replace(new RegExp('\r', 'g'), '')
    # needed to differenciate quoted text from tags later inserted
    res = res.replace(new RegExp('>', 'g'), replacementQuoteCharacter)
    res = tokenize(res, split_tokens)
    res = parseLines(res)
    $sce.trustAsHtml(res)
]
