module TextsHelper
  include WordsHelper

  # returns list of languages as an array where each language is an array [name, id]
  # if filter_unused is set, only returns languages the current user has added texts in.
  def language_options filter_unused = false
    options = []
    if filter_unused
      my_texts = Text.select("texts.*, languages.name as language_name, languages.id as language_id").joins(:language).where(user_id: current_user.id, public: false)
      languages = {}
      my_texts.each { |t|
        languages[t.language_name] = t.language_id
      }
      languages.sort.each { |k, v|
        options += [[k, v]]
      }
    else
      options = Language.order(:name).map { |l| [l.name, l.id] }
    end
    options = [] if options == nil
    options
  end

  def process_text input, notes, language_id, disabled_words = false
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
      word_value = Word.determine_replacement_value word_value, language_id
      rating = notes[word_value].rating

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
        "<span class='w word s#{rating}' title='#{word_value}' value='#{word_value}'>#{word}</span>"
      else
        "<span class='w s#{rating}' title='#{word_value}' value='#{word_value}'>#{word}</span>"
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
          p = p.gsub(/^##[ \t]*(.*)[\n]*/, '<h3>\1</h3>')
          p = p.gsub(/^#[ \t]*(.*)[\n]*/, '<h2>\1</h2>')
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
    processed = processed.gsub(/\(\((.*?)\)\)/, '<span class="hint">(\1)</span>')
    processed.html_safe
  end
end
