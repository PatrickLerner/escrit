escrit.filter('inLanguage', function() {
  return function(input, language_ids) {
    if (input === null) { return; }
    if (language_ids.length === 0) { return input; }
    return input.filter(e => language_ids.indexOf(e.language_id) >= 0);
  };
});
