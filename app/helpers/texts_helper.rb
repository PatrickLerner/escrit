module TextsHelper
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
end
