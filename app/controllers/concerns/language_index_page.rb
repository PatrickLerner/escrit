module LanguageIndexPage
  def index_language
    @languages = Language.all
  end
end
