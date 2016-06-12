@escrit.filter 'formatText', ['$sce', ($sce) ->
  parseYoutube = (input) ->
    return input unless input.match(/^https?:\/\/(www\.)?youtube.com\/watch/)?
    id = input.split('v=')[1].replace(/&.*/, '')
    return "<div class='videoWrapper'><div class='video'>" +
           "<iframe id='ytplayer' type='text/html'" +
           " src='https://www.youtube.com/embed/#{id}'" +
           " frameborder='0'></iframe></div></div>"

  parseImages = (input) ->
    return input unless input.trim().match(/^https?:\/\/.*\.(jpg|png|gif)$/)?
    return "<img src='#{input.trim()}' />"

  parseImagesWithBorder = (input) ->
    return input unless input.trim().match(/^@https?:\/\/.*\.(jpg|png|gif)$/)?
    return "<img src='#{input.substr(1).trim()}' class='border' />"

  parseMedia = (input) ->
    input = parseYoutube(input)
    input = parseImages(input)
    input = parseImagesWithBorder(input)
    input

  parseNewLines = (input) ->
    lines = input.split("\n")
    lines.map((input) => parseMedia(input)).join('<br />')

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
    res = tokenize(input, split_tokens)
    res = parseLines(res)
    $sce.trustAsHtml(res)
]
