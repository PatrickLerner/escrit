module ApplicationHelper
  # Create the page title based on the information supplied by the view template
  def page_title(separator = " – ")
    [content_for(:title), 'escrit.еu'].compact.join(separator)
  end

  def header
    {
      title: content_for(:header_title),
      subtitle: content_for(:header_subtitle),
      subtitle_large: content_for(:header_subtitle_large),
      image_class: content_for(:header_image_class),
      class: content_for(:header_class),
      image_style: content_for(:header_image_style)
    }
  end

  # Returns a url to a user's profile picture
  # (utilizes Gravatar as the backend)
  def avatar_url(user, size = 256)
    # in case the user has no gravatar account, use a fallback / default image

    # for testing environments use a publically hosted one
    default_url = 'http://i.imgur.com/Sp2eIpR.png'
    # in production app use a locally hosted default image
    default_url = root_url + image_path('default-profile.png') if Rails.env.production?

    # generate id
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)

    # return full url
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=#{CGI.escape(default_url)}"
  end

  # Returns the currently selected language as an object (or nil if none
  # is selected)
  def current_language
    return @text.language if @text and @text.language

    lang = params['lang'].try(:downcase)
    if lang.present?
      Rails.cache.fetch("language_#{lang}") do |key|
        Language.find_by("lower(name) = ?", lang)
      end
    end
  end

  def flag_icon_path(language)
    return "languages/#{language.to_param.downcase}/flag.png" unless Rails.env.test?
    ''
  end

  def flag_icon_tag(language, options = {})
    return image_tag flag_icon_path(language), style: "height: 16px; vertical-align: middle; #{options[:style]}" unless Rails.env.test?
    ''
  end

  def vocab_words
    if current_language
      count = Note.vocabulary.for_user(current_user)
                  .for_language(current_language).awaiting_review.count
      if count > 0
        content_tag(:span, count, class: 'highlight')
      end
    end
  end

  def current_lang_prefix
    if controller_name == 'words' and action_name == 'index'
      'words'
    elsif controller_name == 'vocabularies' and action_name == 'index'
      'vocabulary'
    elsif controller_name == 'dictations' and action_name == 'index'
      'dictation'
    elsif controller_name == 'statistics' and action_name == 'index'
      'statistics'
    elsif controller_name == 'texts' and %w[index index_hidden index_public].include? action_name
      'texts'
    elsif controller_name == 'reader' and action_name == 'index'
      'reader'
    end
  end
end
