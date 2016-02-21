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
    return @text.language if @text.try(:language).present?

    lang = params['lang'].downcase if params['lang'].present?
    lang = params['language_id'].downcase if params['language_id'].present?
    if lang.present?
      #Rails.cache.fetch("language_#{lang}") do
        Language.find_by('lower(name) = ?', lang)
      #end
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

  def language_path_for(path_base, language)
    language = nil if controller_name == path_base.to_s
    if language.present?
      method("language_#{path_base}_path".to_sym).call(language)
    else
      method("#{path_base}_path").call
    end
  end
end
