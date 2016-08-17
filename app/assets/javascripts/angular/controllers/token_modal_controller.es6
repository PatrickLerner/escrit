function TokenModalController($scope, Modal, TokenModal, Token, Word, Service,
                              $rootScope, $window, Keyboard) {
  $scope.current_token = null;
  $scope.capitalized = null;
  $scope.current_language_id = null;
  $scope.current_word = null;

  $scope.$watch('current_language_id', function(language_id) {
    if (language_id === null) { return; }
    Service.findAll().then(collection =>
      $scope.services = collection.filter(
        service => service.language_id === language_id ||
                   service.language_id === 0
      )
    );
  });

  $scope.openService = function(service, token) {
    const url = service.url.replace('{query}', token);
    $window.open(url, service.short_name);
    return true;
  };

  $scope.closeModal = function(val) {
    Keyboard.clear('ESCAPE');
    Keyboard.clear('ENTER');
    if (val !== 'save')
      TokenModal.close();
    else {
      Token.save($scope.current_token).then(
        response => TokenModal.close(),
        error => Modal.reportCommunicationError()
      );
    }
  };

  $scope.closeBackground = function($event, val) {
    if ($event.target.className !== "modal-fade-screen") { return; }
    $scope.closeModal(val);
  };

  $scope.selectWord = function(word) {
    if ($scope.current_word === word)
      $scope.current_word.__editing = true;
    else {
      if ($scope.current_word !== null)
        $scope.confirmWord($scope.current_word, -1);
      $scope.current_word = word;
    }
  };

  $scope.addNote = function() {
    const notes = $scope.current_word.notes;
    const has_notes = notes.length > 0;
    const last_elem = notes[notes.length - 1];
    const last_elem_empty = last_elem.trim() === '';
    // don't add a new field if there still is one left to fill
    if (has_notes && last_elem_empty) { return; }
    $scope.current_word.notes.push('');
  };

  $scope.deleteNote = index => $scope.current_word.notes.splice(index, 1);

  $scope.addWord = function(value) {
    let pushWord = function(word) {
      $scope.current_token.words.push(word);
      $scope.current_word = word;
    };

    if ($scope.current_word !== null)
      $scope.current_word.__editing = undefined;

    const existing = $scope.current_token.words.filter(word => word.value === value && word.language_id === $scope.current_language_id);

    if (existing.length > 0) {
      value = '';
    }

    pushWord({
      value,
      to_param: value,
      language_id: $scope.current_language_id,
      notes: [''],
      __editing: true
    });

    if (existing.length === 0)
      $scope.confirmWord($scope.current_word, -1);
  };

  $scope.editWord = word => word.__editing = true;

  $scope.confirmWord = function(word, index) {
    word.value = word.value.trim().toLowerCase();
    word.__editing = undefined;
    if (word.value === '') {
      $scope.current_token.words.splice(index, 1);
      $scope.current_word = null;
      if ($scope.current_token.words.length > 0) {
        let new_index = Math.min(index, $scope.current_token.words.length - 1);
        $scope.current_word = $scope.current_token.words[new_index];
      }
    } else {
      return Word.find(word.value).then(function(response) {
        word.notes = response.notes;
        word.to_param = response.to_param;
      }, error => word.to_param = word.value);
    }
  };

  $scope.loadData = function(token) {
    let promise = Token.find(token);
    promise.then(function(response) {
      $scope.current_token = response;
      $scope.capitalized = TokenModal.capitalized;
      $scope.current_language_id = TokenModal.current_language_id;
      $scope.current_word = response.words[0];
    }, function(error) {
      $scope.closeModal();
      Modal.reportCommunicationError();
    });
    return promise;
  };

  $scope.onKeyEnter = function(event) {
    if (event.metaKey || event.shiftKey)
      $scope.closeModal('save');
  };

  $scope.onKeyEscape = () => $scope.closeModal('close');

  $scope.initializeKeyboard = function() {
    Keyboard.on('ESCAPE', $scope.onKeyEscape);
    Keyboard.on('ENTER', $scope.onKeyEnter);
  };

  $rootScope.$on('token_modal:open', function() {
    $scope.loadData(TokenModal.current_token).then(function() {
      $scope.initializeKeyboard();
      $rootScope.$broadcast('token_modal:opened');
    });
  });

  return $rootScope.$on('token_modal:close', function() {
    $scope.current_token = null;
    return $rootScope.$broadcast('token_modal:closed');
  });
}


TokenModalController.$inject = ['$scope', 'Modal', 'TokenModal', 'Token',
                                'Word', 'Service', '$rootScope', '$window',
                                'Keyboard'];
escrit.controller('TokenModalController', TokenModalController);
