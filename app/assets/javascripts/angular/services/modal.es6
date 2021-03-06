function Modal($resource, $q, $rootScope) {
  let modal_list = [];
  let factory = {};

  factory.push = function(data) {
    for (let val in data.buttons) {
      let text = data.buttons[val];
      data.buttons[val] = Array.isArray(text) ? text : [null, null, text];
    }
    modal_list.push(data);
    $rootScope.$broadcast('modal:open');
  };

  factory.pop = function(val) {
    let modal = modal_list.pop();
    modal.promise.resolve(val);
    $rootScope.$broadcast('modal:close');
  };

  factory.addModal = function(data) {
    let defer = $q.defer();
    data.promise = defer;
    factory.push(data);
    return defer.promise;
  };

  factory.reportCommunicationError = () =>
    factory.addModal({
      title: "Error communicating with server",
      content: "It looks like there was a problem connecting and " +
               "communicating with the server. You might try again later " +
               "or get in contact with the administration of the site to " +
               "resolve the problem. Sorry for the inconvenience.",
      buttons: {
        confirm: ['danger', 'close', 'Close']
      }})
  ;

  factory.getAll = () => modal_list;

  return factory;
}


Modal.$inject = ['$resource', '$q', '$rootScope'];
escrit.factory('Modal', Modal);
