@escrit.filter 'formatText', ($sce) ->
  parseNewLines = (input) ->
    lines = input.split("\n")
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

  tokenize = (input, split_tokens) ->
    # we do not want to replace partial matches again, so we replace with a
    # placeholder first
    i = 0
    for word in Object.keys(split_tokens)
      input = input.replace new RegExp(word, 'g'), "___#{i}___"
      i += 1

    i = 0
    for word in Object.keys(split_tokens)
      input = input.replace new RegExp("___#{i}___", 'g'), (m) ->
        "<span ng-click='showWord(\"#{split_tokens[word]}\")'" +
          " class='word'" +
        ">" +
          "#{word}" +
        "</span>"
      i += 1

    input

  return (input, split_tokens) ->
    return unless input?
    res = parseLines(input)
    res = tokenize(res, split_tokens)
    $sce.trustAsHtml(res)
