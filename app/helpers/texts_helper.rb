module TextsHelper
  include WordsHelper

  # returns list of languages as an array where each language is an array [name, id]
  # if filter_unused is set, only returns languages the current user has added texts in.
  def language_options filter_unused = false
    options = []
    if filter_unused
      options = current_user.languages.map { |l| [l.name, l.id] }.sort
    else
      options = Language.order(:name).map { |l| [l.name, l.id] }
    end
    options = [] if options == nil
    options
  end
end
