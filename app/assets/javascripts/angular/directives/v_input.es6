escrit.directive('vInput', () =>
  ({
    restrict: 'E',
    scope: {
      name: '@',
      errors: '=',
      object: '=',
      label: '@',
      type: '@'
    },
    templateUrl: 'inputs/vinput.html'
  })
);

escrit.directive('vTextarea', () =>
  ({
    restrict: 'E',
    scope: {
      name: '@',
      errors: '=',
      object: '=',
      label: '@'
    },
    templateUrl: 'inputs/vtextarea.html'
  })
);

escrit.directive('vLanguageSelect', () =>
  ({
    restrict: 'E',
    scope: {
      errors: '=',
      object: '=',
      label: '@',
      allowAll: '@'
    },
    templateUrl: 'inputs/vlanguage_select.html'
  })
);
