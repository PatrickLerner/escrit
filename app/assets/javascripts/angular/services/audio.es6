escrit.factory('Audio', function() {
  let factory = {};

  factory.init = () =>
    audiojs.events.ready(() => setTimeout(() => audiojs.createAll(), 100));

  return factory;
});
