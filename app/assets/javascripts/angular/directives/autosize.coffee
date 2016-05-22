@escrit.directive 'autosize', () ->
  (scope, element, attrs) ->
    autosize(element)

    # we need to watch the scope model and issue a call to autosize
    # if the value of the textarea gets updated
    scope.$watch attrs.ngModel, () ->
      evt = document.createEvent('Event')
      evt.initEvent('autosize:update', true, false)
      element[0].dispatchEvent(evt)
