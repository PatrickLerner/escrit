@escrit.controller 'TokenModalController', ['$scope', 'Modal', 'TokenModal', 'Token', 'Word', '$rootScope', ($scope, Modal, TokenModal, Token, Word, $rootScope) ->
  $scope.current_token = null
  $scope.current_language_id = null
  $scope.current_word = null

  $scope.closeModal = (val) ->
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
    Token.find(token).then (response) ->
      $scope.current_token = response
      $scope.current_language_id = TokenModal.current_language_id()
      $scope.current_word = response.words[0]
    , (error) ->
      $scope.closeModal()
      Modal.reportCommunicationError()

  $rootScope.$on 'token_modal:open', ->
    $scope.loadData(TokenModal.current_token())

  $rootScope.$on 'token_modal:close', ->
    $scope.current_token = null
]
