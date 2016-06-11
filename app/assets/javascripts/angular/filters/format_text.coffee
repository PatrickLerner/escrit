@escrit.filter 'formatText', ['$sce', ($sce) ->
  parseYoutube = (input) ->
    return input unless input.match(/^https?:\/\/(www\.)?youtube.com\/watch/)?
    id = input.split('v=')[1].replace(/&.*/, '')
    return "<div class='videoWrapper'><div class='video'>" +
           "<iframe id='ytplayer' type='text/html'" +
           " src='https://www.youtube.com/embed/#{id}'" +
           " frameborder='0'></iframe></div></div>"

  parseImages = (input) ->
    return input unless input.match(/^https?:\/\/.*\.(jpg|png|gif)$/)?
    return "<img src='#{input}' />"

  parseImagesWithBorder = (input) ->
    return input unless input.match(/^@https?:\/\/.*\.(jpg|png|gif)$/)?
    return "<img src='#{input.substr(1)}' class='border' />"

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

  tokenize = (input, split_tokens) ->
    # we do not want to replace partial matches again, so we replace with a
    # placeholder first
    #i = 0
    #for word in Object.keys(split_tokens)
    #  input = input.replace new RegExp(escapeRegExp(word), 'g'), "___#{i}___"
    #  i += 1

    #i = 0
    #for word in Object.keys(split_tokens)
    regex = unicode_hack(/\p{L}[\p{L}\-\|\.:\/\?=0-9%_][\p{L}0-9]|\p{L}+/g)
    input.replace regex, (word) ->
      token = split_tokens[word]
      return word unless token?
      capitalized = word.isCapitalized()
      #input = input.replace new RegExp("___#{i}___", 'g'), (m) ->
      "<span ng-click='showWord(\"#{token}\", #{capitalized})'" +
        " class='word'" +
        " ng-class='{ unknown: unknownWords[\"#{token}\"] }'" +
        ">" +
          "#{formatWord(word)}" +
      "</span>"
      #i += 1

  return (input, split_tokens) ->
    return unless input?
    res = tokenize(input, split_tokens)
    res = parseLines(res)
    $sce.trustAsHtml(res)
]
