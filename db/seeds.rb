Language.create("name"=>"English", "voice"=>"UK English Male", "voice_rate"=>"0.75")
Language.create("name"=>"French", "voice"=>"French Female", "voice_rate"=>"0.75")
Language.create("name"=>"German", "voice"=>"Deutsch Female", "voice_rate"=>"0.75")
Language.create("name"=>"Italian", "voice"=>"Italian Female", "voice_rate"=>"0.75")
Language.create("name"=>"Russian", "voice"=>"Russian Female", "voice_rate"=>"0.75")
Language.create("name"=>"Spanish", "voice"=>"Spanish Female", "voice_rate"=>"0.75")
Language.create("name"=>"Icelandic", "voice"=>"Icelandic Male", "voice_rate"=>"0.75")
Language.create("name"=>"Portuguese", "voice"=>"Portuguese Female", "voice_rate"=>"0.75")
Language.create("name"=>"Dutch", "voice"=>"Dutch Female", "voice_rate"=>"0.75")
Language.create("name"=>"Polish", "voice"=>"Polish Female", "voice_rate"=>"0.75")
Language.create("name"=>"Ukrainian", "voice"=>nil, "voice_rate"=>nil)
Language.create("name"=>"Romanian", "voice"=>"Romanian Male", "voice_rate"=>"0.75")
Language.create("name"=>"Greek", "voice"=>"Greek Female", "voice_rate"=>"0.75")
Language.create("name"=>"Hungarian", "voice"=>"Hungarian Female", "voice_rate"=>"0.75")
Language.create("name"=>"Czech", "voice"=>"Czech Female", "voice_rate"=>"0.75")
Language.create("name"=>"Norwegian", "voice"=>"Norwegian Female", "voice_rate"=>"0.75")
Language.create("name"=>"Swedish", "voice"=>"Swedish Female", "voice_rate"=>"0.75")
Language.create("name"=>"Danish", "voice"=>"Danish Female", "voice_rate"=>"0.75")
Language.create("name"=>"Latvian", "voice"=>"Latvian Male", "voice_rate"=>"0.75")
Language.create("name"=>"Albanian", "voice"=>"Albanian Male", "voice_rate"=>"0.75")
Language.create("name"=>"Estonian", "voice"=>"", "voice_rate"=>"")
Language.create("name"=>"Finish", "voice"=>"Finnish Female", "voice_rate"=>"0.75")
Language.create("name"=>"Serbian", "voice"=>"Serbo-Croatian Male", "voice_rate"=>"0.75")
Language.create("name"=>"Slovene", "voice"=>"", "voice_rate"=>"")
Language.create("name"=>"Welsh", "voice"=>"Welsh Male", "voice_rate"=>"0.75")

Compliment.create!([
  {value: "Bon travail!", language_id: (Language.find_by name: "French").id},
  {value: "Bonne réussite.", language_id: (Language.find_by name: "French").id},
  {value: "Bravo!", language_id: (Language.find_by name: "French").id},
  {value: "Continue comme ça.", language_id: (Language.find_by name: "French").id},
  {value: "Très bien!", language_id: (Language.find_by name: "French").id},
  {value: "Gut gemacht!", language_id: (Language.find_by name: "German").id},
  {value: "Klasse!", language_id: (Language.find_by name: "German").id},
  {value: "Mach weiter so!", language_id: (Language.find_by name: "German").id},
  {value: "Nicht schlecht :)", language_id: (Language.find_by name: "German").id},
  {value: "Weiter so!", language_id: (Language.find_by name: "German").id},
  {value: "Очень хорошо уже.", language_id: (Language.find_by name: "Russian").id},
  {value: "Так держать.", language_id: (Language.find_by name: "Russian").id},
  {value: "Хорошоя работа!", language_id: (Language.find_by name: "Russian").id}
])

Service.create("name"=>"bab.la", "short_name"=>"bab.la", "url"=>"http://en.bab.la/dictionary/russian-english/query", "language_id"=>7, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"dict.cc EN<=>DE", "short_name"=>"dict.cc", "url"=>"http://www.dict.cc/?s=query", "language_id"=>4, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"Forvo", "short_name"=>"forvo", "url"=>"http://forvo.com/search/query/", "language_id"=>0, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"Google Translator", "short_name"=>"gtans", "url"=>"https://translate.google.com/#auto/en/query", "language_id"=>0, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"Lingea EN<=>LV", "short_name"=>"lingea", "url"=>"http://www.dict.com/?t=lv&set=_enlv&w=query", "language_id"=>24, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"Span!shD!ct", "short_name"=>"sd!ct", "url"=>"http://www.spanishdict.com/translate/query", "language_id"=>8, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"schoLingua.com EN<=>DE", "short_name"=>"sling", "url"=>"http://www.scholingua.com/en/de/conjugation/query", "language_id"=>4, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"schoLingua.com EN<=>FR", "short_name"=>"sling", "url"=>"http://www.scholingua.com/en/fr/conjugation/query", "language_id"=>3, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"tatoeba", "short_name"=>"tatoeba", "url"=>"http://tatoeba.org/eng/sentences/search?query=%3Dquery&from=und&to=und", "language_id"=>0, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"English Wiktionary", "short_name"=>"wikt", "url"=>"http://en.wiktionary.org/wiki/query", "language_id"=>0, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"Yandex EN<=>RU", "short_name"=>"yandex", "url"=>"https://translate.yandex.com/?text=query&lang=ru-en", "language_id"=>7, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"Yandex EN<=>UA", "short_name"=>"yandex", "url"=>"https://translate.yandex.com/?text=query&lang=uk-en", "language_id"=>14, "user_id"=>0, "enabled"=>true)
Service.create("name"=>"Yandex Dictionary EN<=>RU", "short_name"=>"ydict", "url"=>"https://slovari.yandex.ru/query/en/", "language_id"=>7, "user_id"=>0, "enabled"=>true)

Replacement.create("value"=>"ё", "replacement"=>"е", "language_id"=>7)
