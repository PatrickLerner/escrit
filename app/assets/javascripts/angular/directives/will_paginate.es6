escrit.directive('willPaginate', () =>
  ({
    restrict: 'E',
    scope: {
      ngModel: '='
    },
    templateUrl: 'inputs/will_paginate.html',
    link: function(scope, element, attrs) {
      scope.showPage = scope.$parent.showPage;
    }
  })
);
