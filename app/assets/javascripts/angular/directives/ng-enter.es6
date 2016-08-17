function ngEnter($keyCodes) {
  return function(scope, element, attrs) {
    element.bind('keydown keypress', function(event) {
      if (event.which === $keyCodes.ENTER &&
          !(event.metaKey || event.shiftKey)) {
        scope.$apply(() => scope.$eval(attrs.ngEnter));
        event.preventDefault();
      }
    });
  };
}

ngEnter.$inject = ['$keyCodes'];
escrit.directive('ngEnter', ngEnter);
