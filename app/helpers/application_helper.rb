module ApplicationHelper
  def page_title(separator = " – ")
    [content_for(:title), 'escrit'].compact.join(separator)
  end
  
  def utf8downcase(text)
    text.mb_chars.downcase.to_s
  end
end
