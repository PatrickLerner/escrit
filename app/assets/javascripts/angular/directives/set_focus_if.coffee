@escrit.directive 'setFocusIf', ->
  resrict: 'A'
  link: (scope, element, attrs) ->
    scope.$watch ->
      scope.$eval(attrs.setFocusIf)
    , (newValue) ->
      if newValue == true
        element[0].focus()
