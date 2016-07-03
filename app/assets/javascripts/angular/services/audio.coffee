@escrit.factory 'Audio', ->
  factory = {}

  factory.init = ->
    audiojs.events.ready ->
      setTimeout ->
        audiojs.createAll()
      , 100

  return factory
