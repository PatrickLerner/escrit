function formatText($sce) {
  function parseYoutube(input) {
    if (input.match(/^https?:\/\/(www\.)?youtube.com\/watch/) === null)
      return input;
    let id = input.split('v=')[1].replace(/&.*/, '');
    return "<div class='videoWrapper'><div class='video'>" +
      "<iframe id='ytplayer' type='text/html'" +
      ` src='https://www.youtube.com/embed/${id}'` +
      " frameborder='0'></iframe></div></div>";
  }

  function parseAudio(input) {
    if (input.trim().match(/^https?:\/\/.*\.(m4a|mp3)$/) === null)
      return input;
    return `<audio src='${input.trim()}' preload='none'></audio>`;
  }

  function parseImages(input) {
    if (input.trim().match(/^https?:\/\/.*\.(jpg|png|gif)$/) === null)
      return input;
    return `<img src='${input.trim()}' />`;
  }

  function parseImagesWithBorder(input) {
    if (input.trim().match(/^@https?:\/\/.*\.(jpg|png|gif)$/) === null)
      return input;
    return `<img src='${input.substr(1).trim()}' class='border' />`;
  }

  function parseMedia(input) {
    input = parseYoutube(input);
    input = parseAudio(input);
    input = parseImages(input);
    input = parseImagesWithBorder(input);
    return input;
  }

  function parseHeaders(input) {
    if (input.trim().match(/^#/) === null)
      return input;
    return input.replace(/^([#]+)(.*)/, function(match, level, title) {
      level = level.length + 1;
      level = Math.min(level, 6);
      return `<h${level}>${title}</h${level}>`;
    });
  }

  let parseBold = input =>
    input.replace(/\*\*(.+?)\*\*/, (_, text) => `<strong>${text}</strong>`);

  let parseItalic = input =>
    input.replace(/__(.+?)__/, (_, text) => `<em>${text}</em>`);

  let parseUnderline = input =>
    input.replace(/_(.+?)_/, (_, text) => `<u>${text}</u>`);

  const replacementQuoteCharacter = '_@>';
  function parseQuotes(input) {
    let exp = `(^(${replacementQuoteCharacter}.+\\n?)+)|` +
              `(\\n(${replacementQuoteCharacter}.+\\n?)+)`;
    input = input.replace(new RegExp(exp, 'g'), function(text) {
      text = text.replace(new RegExp(replacementQuoteCharacter, 'g'), '');
      return `<blockquote>${text}</blockquote>`;
    });
    return input.replace(new RegExp(replacementQuoteCharacter, 'g'), '>');
  }

  function parseTypography(input) {
    input = parseHeaders(input);
    input = parseBold(input);
    input = parseItalic(input);
    input = parseUnderline(input);
    return input;
  }

  function parseNewLines(input) {
    input = parseQuotes(input);
    let lines = input.split("\n");
    lines = lines.map(input => parseMedia(input));
    lines = lines.map(input => parseTypography(input));
    return lines.join('<br />');
  }

  function parseParagraphs(paragraphs) {
    let res = paragraphs.map(paragraph => parseNewLines(paragraph));
    return `<p>${res.join('</p><p>')}</p>`;
  }

  function parseLines(input) {
    let paragraphs = input.split("\n\n");
    if (paragraphs.length === 1) {
      return parseNewLines(paragraphs[0]);
    } else {
      return parseParagraphs(paragraphs);
    }
  }

  let escapeRegExp = str =>
    str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");

  let formatWord = str => str.replace(/^(.+?)\|\|.+?$/, "$1");

  const regex = unicode_hack(
    /[\p{L}][\p{L}\-\|\.:\/\?=0-9%_]+[\p{L}0-9]|[\p{L}]+/g
  );

  function tokenize(input, split_tokens) {
    return input.replace(regex, function(word) {
      let token = split_tokens[word];
      if (token === undefined) { return word; }
      let capitalized = word.isCapitalized();
      return `<span ng-click='showWord("${token}${`\", ${capitalized})'`}` +
        " class='word'" +
        ` ng-class='{ unknown: unknownWords["${token}"] }'` +
        ">" +
          formatWord(word) +
      "</span>";
    });
  }

  return function(input, split_tokens) {
    if (input === null) { return; }
    let res = input.replace(new RegExp('\r', 'g'), '');
    // needed to differenciate quoted text from tags later inserted
    res = res.replace(new RegExp('>', 'g'), replacementQuoteCharacter);
    res = tokenize(res, split_tokens);
    res = parseLines(res);
    return $sce.trustAsHtml(res);
  };
}


formatText.$inject = ['$sce'];
escrit.filter('formatText', formatText);
