module TextsHelper
  def language_options
    options = Language.order(:name).map { |l| [l.name, l.id] }
    options = [] if options == nil
    options
  end

  def selected_language
    if params[:language]
      Language.where("lower(name) LIKE ?", params[:language])[0]
    end
  end
end
