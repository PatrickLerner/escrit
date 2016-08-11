unless Rails.env.test?

Language.create! [
  { name: 'English', voice: 'UK English Male', voice_rate: '0.75', code: 'en' },
  { name: 'French', voice: 'French Female', voice_rate: '0.75', code: 'fr' },
  { name: 'German', voice: 'Deutsch Female', voice_rate: '0.75', code: 'de' },
  { name: 'Italian', voice: 'Italian Female', voice_rate: '0.75', code: 'it' },
  { name: 'Russian', voice: 'Russian Female', voice_rate: '0.75', code: 'ru' },
  { name: 'Spanish', voice: 'Spanish Female', voice_rate: '0.75', code: 'es' }
]

Compliment.create! [
  { value: 'Bon travail!', language: (Language.find_by name: 'French') },
  { value: 'Bonne réussite.', language: (Language.find_by name: 'French') },
  { value: 'Bravo!', language: (Language.find_by name: 'French') },
  { value: 'Continue comme ça.', language: (Language.find_by name: 'French') },
  { value: 'Très bien!', language: (Language.find_by name: 'French') },
  { value: 'Gut gemacht!', language: (Language.find_by name: 'German') },
  { value: 'Klasse!', language: (Language.find_by name: 'German') },
  { value: 'Mach weiter so!', language: (Language.find_by name: 'German') },
  { value: 'Nicht schlecht :)', language: (Language.find_by name: 'German') },
  { value: 'Weiter so!', language: (Language.find_by name: 'German') },
  { value: 'Очень хорошо уже.', language: (Language.find_by name: 'Russian') },
  { value: 'Так держать.', language: (Language.find_by name: 'Russian') },
  { value: 'Хорошоя работа!', language: (Language.find_by name: 'Russian') }
]

Replacement.create(
  value: 'ё', replacement: 'е', language: (Language.find_by name: 'Russian')
)

end
