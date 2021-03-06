function compiledHtml($compile, $parse) {
  return {
    restrict: 'E',
    link: function(scope, element, attr) {
      scope.$watch(attr.content, function() {
        element.html($parse(attr.content)(scope));
        return $compile(element.contents())(scope);
      }, true);
    }
  };
}


compiledHtml.$inject = ['$compile', '$parse'];
escrit.directive('compiledHtml', compiledHtml);
