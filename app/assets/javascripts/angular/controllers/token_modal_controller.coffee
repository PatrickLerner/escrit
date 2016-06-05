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
      $scope.current_word.__editing = undefined
      $scope.current_word = word

  $scope.addNote = () ->
    $scope.current_word.notes.push('')

  $scope.deleteNote = (index) ->
    $scope.current_word.notes.splice(index, 1)

  $scope.addWord = () ->
    value = prompt('Word', $scope.current_token.value)
    return if value == ''

    pushWord = (word) ->
      $scope.current_token.words.push(word)
      $scope.current_word = word

    Word.find(value).then (response) ->
      pushWord(response)
    , (error) ->
      pushWord
        value: value
        to_param: value
        language_id: $scope.current_language_id
        notes: ['']

  $scope.editWord = (word) ->
    word.__editing = true

  $scope.confirmWord = (word, index) ->
    word.value = word.value.trim()
    word.__editing = undefined
    if word.value == ''
      $scope.current_token.words.splice(index, 1)
      $scope.current_word = null
      if $scope.current_token.words.length > 0
        $scope.current_word = $scope.current_token.words[0]

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
