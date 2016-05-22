@escrit.directive 'compiledHtml', ($compile, $parse) ->
  restrict: 'E',
  link: (scope, element, attr) ->
    scope.$watch attr.content, ->
      element.html($parse(attr.content)(scope))
      $compile(element.contents())(scope)
    , true
