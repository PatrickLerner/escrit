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

  # returns the currently selected language of the page (as an Object),
  # or nil if none was selected
  def selected_language
    if params[:language] != Rails.cache.fetch('selected_language')
      Rails.cache.delete('selected_language')
      Rails.cache.delete('selected_language_value')
    end
    Rails.cache.fetch('selected_language') do
      params[:language]
    end
    Rails.cache.fetch('selected_language_value') do
      if params[:language]
        Language.where("lower(name) = ?", params[:language].downcase)[0]
      end
    end
  end

  def process_text split_words, words, language_id, disabled_words = false
    processed = ''
    replacements = replacements = Replacement.where language_id: language_id
    split_words.each do |wstr|
      wstrlow = wstr.mb_chars.downcase.to_s
      wstrrep = Word.determine_replacement_value wstrlow, replacements
      if words.keys.include?(wstrrep) and not (/https?:\/\/[\S]+/.match(wstrlow))
        w = words[wstrrep]
        if disabled_words
          processed += '<span class="s' + w.rating.to_s + '" value="' + w.replacement_value(replacements) + '">' + wstr + '</span>'
        else
          processed += '<span class="word s' + w.rating.to_s + '" value="' + w.replacement_value(replacements) + '">' + wstr + '</span>'
        end
      elsif /@https?:\/\/[\S]+/.match wstrlow and (wstrlow[-4..-1] == '.jpg' or wstrlow[-4..-1] == '.png')
        processed += '<div class="centered"><a href="' + wstr.mb_chars[1..-1] + '" data-lightbox="images" class="image-link"><img class="border" src="' + wstr.mb_chars[1..-1] + '" /></a></div>'
      elsif /https?:\/\/[\S]+/.match wstrlow and (wstrlow[-4..-1] == '.jpg' or wstrlow[-4..-1] == '.png')
        processed += '<div class="centered"><a href="' + wstr.mb_chars + '" data-lightbox="images" class="image-link"><img src="' + wstr.mb_chars + '" /></a></div>'
      elsif /https?:\/\/[\S]+/.match wstrlow and (wstrlow[-4..-1] == '.mp3')
        processed += '<div><audio src="' + wstr.mb_chars + '" preload="none"></audio></div>'
      elsif /https?:\/\/www\.youtube\.com\/watch\?v=[A-Za-z0-9]+/.match wstrlow
        youtube_id = wstr.mb_chars.split("=").last
        processed += '<div class="embed-container"><iframe src="//www.youtube.com/embed/' + youtube_id + '"></iframe></div>'
      else
        processed += wstr
      end
    end
    processed = processed.gsub(/^([#]+)[ \t]*(.*)[\n]*/, "\\1 \\2\n\n")
    processed = processed.gsub(/\r/, '')
    paragraphs = processed.split(/[\n]{2,}/)
    paragraphs = paragraphs.map { |p| p.strip }
    processed = if paragraphs.count > 1
      paragraphs.map { |p|
        if p[0] == '#'
          p = p.gsub(/^##[ \t]*(.*)[\n]*/, '<h6 class="docs-header">\1</h6>')
          p = p.gsub(/^#[ \t]*(.*)[\n]*/, '<h5>\1</h5>')
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
