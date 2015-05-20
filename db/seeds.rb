# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Language.create(name: 'Arabic')
Language.create(name: 'English')
Language.create(name: 'French')
Language.create(name: 'German')
Language.create(name: 'Italian')
Language.create(name: 'Portugese')
Language.create(name: 'Russian')
Language.create(name: 'Spanish')
Language.create(name: 'Other')

Service.create("name"=>"English Wiktionary", "short_name"=>"wikt", "url"=>"http://en.wiktionary.org/wiki/query", "language_id"=>0)
Service.create("name"=>"Forvo", "short_name"=>"forvo", "url"=>"http://forvo.com/search/query/", "language_id"=>0)
Service.create("name"=>"Google Translator", "short_name"=>"gtans", "url"=>"https://translate.google.com/#auto/en/query", "language_id"=>0)
Service.create("name"=>"dict.cc EN<=>DE", "short_name"=>"dict.cc", "url"=>"http://www.dict.cc/?s=query", "language_id"=>4)
