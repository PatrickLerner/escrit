var last_word;
var text_language;
var description = [
	"Never seen it before.",
	"Looked it up once.",
	"This time I'll remember it.",
	"I'm getting it now.",
	"Seems easy at this point.",
	"Know it in my sleep.",
	"(Ignore Word)"
];

function refreshCurrentWordRating(rating) {
	$('.word').each(function(i) {
		if (this.innerHTML.toLowerCase() == last_word.toLowerCase()) {
			for (i = 0; i <= 6; i++)
				$(this).removeClass('s' + i);
			$(this).addClass("s" + rating);
		}
	});
	for (i = 0; i <= 6; i++)
		$('#buttons .s' + i).css('opacity', '0.4');
	$('#buttons .s' + rating).css('opacity', '1.0');
	$('#description').html(description[rating]);
	$('.lookup #links a').each(function(i) {
		var t_href = $(this).attr('t_href');
		$(this).attr('href', t_href.replace('{query}', encodeURIComponent(last_word)));
	});
	updateCounter();
}

var old_nl = -1;

function onlyUnique(value, index, self) { 
    return self.indexOf(value) === index;
}

function updateCounter() {
	var nl = $('.s0.word').map (function () { return this.innerHTML }).get().filter(onlyUnique).length;

	if (old_nl == -1 || (old_nl == 0 && nl != 0) || (old_nl != 0 && nl == 0))
		$.ajax({
			type: 'PATCH',
			url: document.URL,
			data: {
				'text[completed]': nl == 0
			},
			async: false
		});
	old_nl = nl;

	$('#stats').html();
	var sum = 0;
	for (i = 1; i <= 5; i++)
		sum += i * $('.s' + i + '.word').map (function () { return this.innerHTML }).get().filter(onlyUnique).length;
	var count = $('.word').map (function () { return this.innerHTML }).get().filter(onlyUnique).length;
	var rating = (sum / count).toFixed(1);
	$('#stats').html('<b>Unrated Words:</b> ' + nl + ' – <b>Rating:</b> ' + rating);
}

function onRatingsButton(rating) {
	if (last_word) {
		$.ajax({
			type: 'PATCH',
			url: '/words/' + last_word,
			data: {
				'word[note]': $('#lword').val(),
				'word[language]': text_language,
				'word[rating]': rating
			},
			async: true
		});
		refreshCurrentWordRating(rating);
	}
}

$(document).ready(function() {
	$('.word').click(function (event) {
		last_word = event.target.innerHTML;
		$.getJSON("/words/" + text_language + '/' + last_word, function(data) {
			$('.lookup').fadeIn(400);
			$('.lookup #rword').html(last_word);
			$('.lookup #lword').val(data["note"]);
			refreshCurrentWordRating(data["rating"]);
			$('.lookup #lword').focus();
		});
	});

	$('#buttons span').click(function (event) {
		var rating = event.target.innerHTML;
		if (rating == '/')
			rating = 6;
		onRatingsButton(rating);
		$('.lookup #lword').focus();
	});

	$(".lookup #lword").keyup(function(event) {
		if(event.keyCode == 13 && last_word)
			$.ajax({
				type: 'PATCH',
				url: '/words/' + last_word,
				data: {
					'word[note]': $('#lword').val(),
					'word[language]': text_language
				},
				async: true
			});
		if (event.keyCode == 48 && event.ctrlKey) {
			onRatingsButton(0);
			event.preventDefault();
		}
		if (event.keyCode == 49 && event.ctrlKey) {
			onRatingsButton(1);
			event.preventDefault();
		}
		if (event.keyCode == 50 && event.ctrlKey) {
			onRatingsButton(2);
			event.preventDefault();
		}
		if (event.keyCode == 51 && event.ctrlKey) {
			onRatingsButton(3);
			event.preventDefault();
		}
		if (event.keyCode == 52 && event.ctrlKey) {
			onRatingsButton(4);
			event.preventDefault();
		}
		if (event.keyCode == 53 && event.ctrlKey) {
			onRatingsButton(5);
			event.preventDefault();
		}
		if (event.keyCode == 54 && event.ctrlKey) {
			onRatingsButton(6);
			event.preventDefault();
		}
	});

	$('body').bind('click', function (evt) {
		if(evt.target == $('body')[0])
			$('.lookup').fadeOut(400);
	});
});
