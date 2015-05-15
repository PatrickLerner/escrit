module TextsHelper
  def language_options
    options = Language.order(:name).map { |l| [l.name, l.id] }
    options = [] if options == nil
    options
  end
end
