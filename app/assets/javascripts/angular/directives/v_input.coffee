@escrit.directive 'vInput', ->
  restrict: 'E'
  scope:
    name: '@'
    errors: '='
    object: '='
    label: '@'
    type: '@'
  templateUrl: 'inputs/vinput.html'

@escrit.directive 'vTextarea', ->
  restrict: 'E'
  scope:
    name: '@'
    errors: '='
    object: '='
    label: '@'
  templateUrl: 'inputs/vtextarea.html'
