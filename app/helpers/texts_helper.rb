module TextsHelper
  include WordsHelper

  def language_options filter_unused = false
    if filter_unused
      options = Language.order(:name).select { |l| l.texts.count > 0 }.map { |l| [l.name, l.id] }
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
        processed += '<span class="word s' + w.rating.to_s + '">' + wstr + '</span>';
      else
        processed += wstr
      end
    end
    processed = processed.gsub /\r/, ''
    paragraphs = processed.split /[\n]{2,}/
    paragraphs = paragraphs.map { |p|
      p.sub /^#[ \t]*(.*)$/, '<h5>\1</h5>'
    }
    processed = ("<p>" + paragraphs.join("</p><p>") + "</p>")
    processed = processed.gsub /\n/, "<br />"
    processed.html_safe
  end
end
