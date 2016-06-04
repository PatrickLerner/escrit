@escrit.controller 'TokenModalController', ($scope, Modal, TokenModal,
  Token, $rootScope) ->
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
        $scope.reportError()

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
    word =
      value: prompt('Word', '')
      language_id: $scope.current_language_id
      notes: []
    word.to_param = word.value
    return if word.value == ''
    $scope.current_token.words.push(word)
    $scope.current_word = word

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
      $scope.reportError()

  $scope.reportError = () ->
      Modal.addModal
        title: "Error communicating with server"
        content: "It looks like there was a problem connecting and " +
                 "communicating with the server. You might try again later " +
                 "or get in contact with the administration of the site to " +
                 "resolve the problem. Sorry for the inconvenience.",
        buttons:
          confirm: ['danger', 'close', 'Close']

  $rootScope.$on 'token_modal:open', ->
    $scope.loadData(TokenModal.current_token())

  $rootScope.$on 'token_modal:close', ->
    $scope.current_token = null
