Language.create!([
  {name: "English"},
  {name: "French"},
  {name: "German"},
  {name: "Italian"},
  {name: "Russian"},
  {name: "Spanish"},
  {name: "Icelandic"}
])
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
