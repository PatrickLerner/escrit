class LanguagesController < ReadScaffoldController
  resource Language

  protected

  def collection
    @collection ||= resource.all
  end
end
