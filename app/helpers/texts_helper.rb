module TextsHelper
  include WordsHelper

  # returns list of languages as an array where each language is an array [name, id]
  # if filter_unused is set, only returns languages the current user has added texts in.
  def language_options filter_unused = false
    options = []
    if filter_unused
      options = current_user.languages.map { |l| [l.name, l.id] }.sort
    else
      options = Language.order(:name).map { |l| [l.name, l.id] }
    end
    options = [] if options == nil
    options
  end

  def process_text input, notes, language, disabled_words = false
    processed = input
    # tag words
    processed = processed.gsub(Text::WORD_REGEX) { |word|
      if word.include? '||'
        split = word.split '||'
        word = split[0]
        word_value = utf8downcase split[1..-1].join('||')
      else
        word_value = utf8downcase word
      end

      word_lower = utf8downcase word
      word_value = Word.determine_replacement_value word_value, language
      rating = notes[word_value].rating if notes[word_value]

      # image with @ prefix
      if /@https?:\/\/[\S]+/.match word_lower and (word_lower[-4..-1] == '.jpg' or word_lower[-4..-1] == '.png')
        '<div class="u-centered"><a href="' + word.mb_chars[1..-1] + '" data-lightbox="images" class="image-link"><img class="border" src="' + word.mb_chars[1..-1] + '" /></a></div>'

      # image with no prefix
      elsif /https?:\/\/[\S]+/.match word_lower and (word_lower[-4..-1] == '.jpg' or word_lower[-4..-1] == '.png')
        '<div class="u-centered"><a href="' + word.mb_chars + '" data-lightbox="images" class="image-link"><img src="' + word.mb_chars + '" /></a></div>'

      # mp3 files
      elsif /https?:\/\/[\S]+/.match word_lower and (word_lower[-4..-1] == '.mp3')
        '<div><audio src="' + word.mb_chars + '" preload="none"></audio></div>'

      # youtube videos
      elsif /https?:\/\/www\.youtube\.com\/watch\?v=[A-Za-z0-9]+/.match word_lower
        youtube_id = word.mb_chars.split("=").last
        '<div class="embed-container"><iframe src="//www.youtube.com/embed/' + youtube_id + '"></iframe></div>'

      # normal words
      elsif not disabled_words
        "<span class='w word s#{rating}' title='#{word}' value='#{word_value}'>#{word}</span>"
      else
        "<span class='w s#{rating}' title='#{word}' value='#{word_value}'>#{word}</span>"
      end
    }
    # convert headers
    processed = processed.gsub(/^([#]+)[ \t]*(.*)[\n]*/, "\\1 \\2\n\n")
    processed = processed.gsub(/\r/, '')
    paragraphs = processed.split(/[\n]{2,}/)
    paragraphs = paragraphs.map { |p| p.strip }
    processed = if paragraphs.count > 1
      paragraphs.map { |p|
        if p[0] == '#'
          p = p.gsub(/^###[ \t]*(.*)[\n]*/, '<h5>\1</h5>')
          p = p.gsub(/^##[ \t]*(.*)[\n]*/, '<h4>\1</h4>')
          p = p.gsub(/^#[ \t]*(.*)[\n]*/, '<h3>\1</h3>')
        elsif p[0] == '>'
          p = p.gsub(/^>[ \t]*(.*)[\n]*/, '<blockquote>\1</blockquote>')
        elsif not (/<div/.match p)
          '<p>' + p + '</p>'
        else
          p
        end
      }.join
    else
      paragraphs.join
    end
    processed = processed.gsub(/\n/, "<br />")
    processed = processed.gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
    processed = processed.gsub(/__(.*?)__/, '<em>\1</em>')
    processed = processed.gsub(/\-\-\-[\-]*[\n]*/, '<hr />')
    processed = processed.gsub(/==[=]*[\n]*/, '<hr />')
    processed = processed.gsub(/\(\((.*?)\)\)/, '<span class="hint">(\1)</span>')
    processed.html_safe
  end
end
