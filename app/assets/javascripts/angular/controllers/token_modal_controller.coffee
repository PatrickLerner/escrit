@escrit.controller 'TokenModalController', ['$scope', 'Modal', 'TokenModal', 'Token', 'Word', 'Service', '$rootScope', '$window', 'Keyboard', ($scope, Modal, TokenModal, Token, Word, Service, $rootScope, $window, Keyboard) ->
  $scope.current_token = null
  $scope.capitalized = null
  $scope.current_language_id = null
  $scope.current_word = null

  $scope.$watch 'current_language_id', (language_id) ->
    return unless language_id?
    Service.findAll().then (collection) ->
      $scope.services = collection.filter (service) ->
        service.language_id == language_id || service.language_id == 0

  $scope.openService = (service, token) ->
    url = service.url.replace('{query}', token)
    $window.open(url, service.short_name)
    true

  $scope.closeModal = (val) ->
    Keyboard.clear('ESCAPE')
    Keyboard.clear('ENTER')
    if val != 'save'
      TokenModal.close()
    else
      Token.save($scope.current_token).then (response) ->
        TokenModal.close()
      , (error) ->
        Modal.reportCommunicationError()

  $scope.closeBackground = ($event, val) ->
    return unless $event.target.className == "modal-fade-screen"
    $scope.closeModal(val)

  $scope.selectWord = (word) ->
    if $scope.current_word == word
      $scope.current_word.__editing = true
    else
      if $scope.current_word?
        $scope.confirmWord($scope.current_word, -1)
      $scope.current_word = word

  $scope.addNote = () ->
    notes = $scope.current_word.notes
    has_notes = notes.length > 0
    last_elem = notes[notes.length - 1]
    last_elem_empty = last_elem.trim() == ''
    # don't add a new field if there still is one left to fill
    return if has_notes && last_elem_empty
    $scope.current_word.notes.push('')

  $scope.deleteNote = (index) ->
    $scope.current_word.notes.splice(index, 1)

  $scope.addWord = (value) ->
    pushWord = (word) ->
      $scope.current_token.words.push(word)
      $scope.current_word = word

    if $scope.current_word?
      $scope.current_word.__editing = undefined

    existing = $scope.current_token.words.filter (word) ->
      word.value == value && word.language_id == $scope.current_language_id

    if existing.length > 0
      value = ''

    pushWord
      value: value
      to_param: value
      language_id: $scope.current_language_id
      notes: ['']
      __editing: true

    if existing.length == 0
      $scope.confirmWord($scope.current_word, -1)

  $scope.editWord = (word) ->
    word.__editing = true

  $scope.confirmWord = (word, index) ->
    word.value = word.value.trim().toLowerCase()
    word.__editing = undefined
    if word.value == ''
      $scope.current_token.words.splice(index, 1)
      $scope.current_word = null
      if $scope.current_token.words.length > 0
        new_index = Math.min(index, $scope.current_token.words.length - 1)
        $scope.current_word = $scope.current_token.words[new_index]
    else
      Word.find(word.value).then (response) ->
        word.notes = response.notes
        word.to_param = response.to_param
      , (error) ->
        word.to_param = word.value

  $scope.loadData = (token) ->
    promise = Token.find(token)
    promise.then (response) ->
      $scope.current_token = response
      $scope.capitalized = TokenModal.capitalized
      $scope.current_language_id = TokenModal.current_language_id
      $scope.current_word = response.words[0]
    , (error) ->
      $scope.closeModal()
      Modal.reportCommunicationError()
    promise

  $scope.onKeyEnter = (event) ->
    if event.metaKey || event.shiftKey
      $scope.closeModal('save')

  $scope.onKeyEscape = => $scope.closeModal('close')

  $scope.initializeKeyboard = ->
    Keyboard.on 'ESCAPE', $scope.onKeyEscape
    Keyboard.on 'ENTER', $scope.onKeyEnter

  $rootScope.$on 'token_modal:open', ->
    $scope.loadData(TokenModal.current_token).then ->
      $scope.initializeKeyboard()
      $rootScope.$broadcast('token_modal:opened')

  $rootScope.$on 'token_modal:close', ->
    $scope.current_token = null
    $rootScope.$broadcast('token_modal:closed')
]
