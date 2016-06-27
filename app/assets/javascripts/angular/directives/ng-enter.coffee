@escrit.directive 'ngEnter', ['$keyCodes', (keyCodes) ->
  (scope, element, attrs) ->
    element.bind 'keydown keypress', (event) ->
      if event.which == keyCodes['ENTER'] && !(event.metaKey || event.shiftKey)
        scope.$apply ->
          scope.$eval attrs.ngEnter
        event.preventDefault()
]
