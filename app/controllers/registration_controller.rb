class RegistrationController < Devise::RegistrationsController
  after_filter :add_account, only: :create

  protected
    def add_account
      german = Language.find_by(name: 'German').id
      russian = Language.find_by(name: 'Russian').id
      ukrainian = Language.find_by(name: 'Ukrainian').id
      latvian = Language.find_by(name: 'Latvian').id
      spanish = Language.find_by(name: 'Spanish').id

      if resource.persisted? # user is created successfuly
        Service.create!([
          {name: "English Wiktionary", short_name: "wikt", url: "http://en.wiktionary.org/wiki/{query}", language_id: 0, user_id: resource.id, enabled: true},
          {name: "Forvo", short_name: "forvo", url: "http://forvo.com/search/{query}/", language_id: 0, user_id: resource.id, enabled: true},
          {name: "Google Translator", short_name: "gtans", url: "https://translate.google.com/#auto/en/{query}", language_id: 0, user_id: resource.id, enabled: true},
          {name: "tatoeba", short_name: "tatoeba", url: "http://tatoeba.org/eng/sentences/search?query=%3D{query}&from=und&to=und", language_id: 0, user_id: resource.id, enabled: true},
          {name: "dict.cc EN<=>DE", short_name: "dict.cc", url: "http://www.dict.cc/?s={query}", language_id: german, user_id: resource.id, enabled: true},
          {name: "schoLingua.com", short_name: "sling", url: "http://www.scholingua.com/en/de/conjugation/{query}", language_id: german, user_id: resource.id, enabled: true},
          {name: "Yandex Dictionary EN<=>RU", short_name: "ydict", url: "https://slovari.yandex.ru/{query}/en/", language_id: russian, user_id: resource.id, enabled: true},
          {name: "Yandex EN<=>RU", short_name: "yandex", url: "https://translate.yandex.com/?text={query}&lang=ru-en", language_id: russian, user_id: resource.id, enabled: true},
          {name: "bab.la", short_name: "bab.la", url: "http://en.bab.la/dictionary/russian-english/{query}", language_id: russian, user_id: resource.id, enabled: true},
          {name: "Yandex EN<=>UA", short_name: "yandex", url: "https://translate.yandex.com/?text={query}&lang=uk-en", language_id: ukrainian, user_id: resource.id, enabled: true},
          {name: "Lingea EN<=>LV", short_name: "lingea", url: "http://www.dict.com/?t=lv&set=_enlv&w={query}", language_id: latvian, user_id: resource.id, enabled: true},
          {name: "sd!ct", short_name: "Span!shD!ct", url: "http://www.spanishdict.com/translate/{query}", language_id: spanish, user_id: resource.id}
        ])
      end
    end

    def after_update_path_for(resource)
      '/u/' + resource.id.to_s
    end

  private
    def sign_up_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :native_language_id)
    end

    def account_update_params
      params.require(:user).permit(:name, :about, :email, :password, :password_confirmation, :current_password, :native_language_id)
    end
end
