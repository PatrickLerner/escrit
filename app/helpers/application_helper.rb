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
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    #end
  end
end
