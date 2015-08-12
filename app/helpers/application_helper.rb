module ApplicationHelper
  def page_title(separator = " – ")
    [content_for(:title), 'escrit'].compact.join(separator)
  end
  
  def utf8downcase(text)
    text.mb_chars.downcase.to_s
  end

  def avatar_url(user, size = 256)
    #if user.avatar_url.present?
    #  user.avatar_url
    #else
      if Rails.env.production?
        default_url = root_url + image_path("default-profile.png")
      else
        default_url = "http://i.imgur.com/h7Ch3qJ.png"
      end
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=#{CGI.escape(default_url)}"
    #end
  end
end
