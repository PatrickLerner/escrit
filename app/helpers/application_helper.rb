module ApplicationHelper
  # Create the page title based on the information supplied by the view template
  def page_title(separator = " – ")
    [content_for(:title), 'escrit.еu'].compact.join(separator)
  end
  
  # converts a utf8 string into lower case
  # (probably depricated)
  def utf8downcase(text)
    text.mb_chars.downcase.to_s
  end

  # Returns a url to a user's profile picture
  # (utilizes Gravatar as the backend)
  def avatar_url(user, size = 256)
    # in case the user has no gravatar account, use a fallback / default image

    if Rails.env.production?
      # in production app use a locally hosted default image
      default_url = root_url + image_path("default-profile.png")
    else
      # for testing environments use a publically hosted one
      default_url = "http://i.imgur.com/Sp2eIpR.png"
    end
    # generate id
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    
    # return full url
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=#{CGI.escape(default_url)}"
  end

  # Returns the currently selected language as an object (or nil if none
  # is selected)
  def current_language
    if params[:language] != Rails.cache.fetch('selected_language')
      Rails.cache.delete('selected_language')
      Rails.cache.delete('selected_language_value')
    end
    Rails.cache.fetch('selected_language') do
      if @text
        @text.category.language.short_code
      else
        params[:language]
      end
    end
    Rails.cache.fetch('selected_language_value') do
      if params[:language]
        Language.where("lower(short_code) = ?", params[:language].downcase)[0]
      elsif @text
        @text.category.language
      end
    end
  end

  def language_icon language
    "sidebar/#{language.downcase}.png"
  end
end
