$ ->
  loadCategory = (name) ->
    if name != ''
      $.ajax({
        url: '?c=' + name
      }).done (data) ->
        $('#text-list').html(data);

  $('.category_link').click ->
    loadCategory($(this).attr('data-name'))
  
  name = window.location.hash
  name = name.substr(1, name.length)  
  loadCategory(name)
