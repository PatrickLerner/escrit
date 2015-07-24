Language.create!([
  {name: "Arabic"},
  {name: "English"},
  {name: "French"},
  {name: "German"},
  {name: "Italian"},
  {name: "Portugese"},
  {name: "Russian"},
  {name: "Spanish"},
  {name: "Other"}
])
Service.create!([
  {name: "dict.cc EN<=>DE", short_name: "dict.cc", url: "http://www.dict.cc/?s={query}", language_id: 4},
  {name: "Forvo", short_name: "forvo", url: "http://forvo.com/search/{query}/", language_id: 0},
  {name: "Google Translator", short_name: "gtans", url: "https://translate.google.com/#auto/en/{query}", language_id: 0},
  {name: "English Wiktionary", short_name: "wikt", url: "http://en.wiktionary.org/wiki/{query}", language_id: 0},
  {name: "Yandex EN<=>RU", short_name: "yandex", url: "https://translate.yandex.com/?text={query}&lang=ru-en", language_id: 7}
])
