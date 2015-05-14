module ApplicationHelper
  def page_title(separator = " – ")
    [content_for(:title), 'escrit'].compact.join(separator)
  end
end
