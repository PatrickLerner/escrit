class RegistrationController < Devise::RegistrationsController
  after_filter :add_account, only: :create

  protected
    def add_account
      if resource.persisted? # user is created successfuly
        Service.create!([
          {name: "dict.cc EN<=>DE", short_name: "dict.cc", url: "http://www.dict.cc/?s={query}", language_id: 4, user_id: resource.id},
          {name: "Forvo", short_name: "forvo", url: "http://forvo.com/search/{query}/", language_id: 0, user_id: resource.id},
          {name: "Google Translator", short_name: "gtans", url: "https://translate.google.com/#auto/en/{query}", language_id: 0, user_id: resource.id},
          {name: "English Wiktionary", short_name: "wikt", url: "http://en.wiktionary.org/wiki/{query}", language_id: 0, user_id: resource.id},
          {name: "Yandex EN<=>RU", short_name: "yandex", url: "https://translate.yandex.com/?text={query}&lang=ru-en", language_id: 7, user_id: resource.id}
        ])
      end
   end
end
