module TextsHelper
  include WordsHelper

  def language_options filter_unused = false
    options = []
    if filter_unused
      #options = Language.order(:name).select { |l| l.texts.count > 0 }.map { |l| [l.name, l.id] }
      my_texts = Text.where user_id: current_user.id
      languages = {}
      my_texts.each { |t|
        languages[t.language.name] = t.language.id
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

  def selected_language
    if params[:language]
      Language.where("lower(name) LIKE ?", params[:language])[0]
    end
  end

  def process_text split_words, words
    processed = ''
    split_words.each do |wstr|
      wstrlow = wstr.mb_chars.downcase.to_s
      if words.keys.include? wstrlow and not /https?:\/\/[\S]+/.match wstrlow
        w = words[wstrlow]
        processed += '<span class="word s' + w.rating.to_s + '">' + wstr + '</span>'
      elsif /https?:\/\/[\S]+/.match wstrlow and (wstrlow[-4..-1] == '.jpg' or wstrlow[-4..-1] == '.png')
        processed += '<div style="text-align: center;"><a href="' + wstrlow + '" data-lightbox="images" class="image-link"><img src="' + wstrlow + '" /></a></div>'
      else
        processed += wstr
      end
    end
    processed = processed.gsub /\r/, ''
    paragraphs = processed.split /[\n]{2,}/
    paragraphs = paragraphs.map { |p|
      p.sub /^#[ \t]*(.*)[\n]*/, '<h5>\1</h5>'
    }
    if paragraphs.count > 1
      processed = ("<p>" + paragraphs.join("</p><p>") + "</p>")
    else
      processed = paragraphs[0]
    end
    processed = processed.gsub /\n/, "<br />"
    processed.html_safe
  end
end
