String::displayCase = (capitalize) ->
  if capitalize
    "#{this[0].charAt(0).toUpperCase()}#{this.substr(1).toLowerCase()}"
  else
    this.toString()

String::isCapitalized = ->
  this[0].toUpperCase() == this[0]
