@escrit.directive 'vInput', ->
  restrict: 'E'
  scope:
    name: '@'
    errors: '='
    object: '='
    label: '@'
    type: '@'
  templateUrl: 'inputs/vinput.html'
