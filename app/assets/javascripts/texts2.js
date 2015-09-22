var last_word = "";
var last_word_case = "";
var needSave = false;
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
var showColors = true;
var underlineColors = false;
var currentRating = 0;

var isMobile = false; //initiate as false
// device detection
if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent) 
    || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0,4))) isMobile = true;

function refreshCurrentWordRating(rating) {
	currentRating = rating;
	$('.word').each(function(i) {
		if ($(this).attr('value').toLowerCase() == last_word.toLowerCase()) {
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
		$(this).attr('href', t_href.replace('{query}', encodeURIComponent(last_word_case)));
	});
	updateCounter();
}

var old_nl = -1;

function onlyUnique(value, index, self) { 
    return self.indexOf(value) === index;
}

function updateCounter() {
	var nl = $('.s0.w').map (function () { return this.innerHTML.toLowerCase() }).get().filter(onlyUnique).length;
	var total = $('.w').map (function () { return this.innerHTML.toLowerCase() }).get().filter(onlyUnique).length;
	var rated = total - nl;

	if (old_nl == -1 || (old_nl == 0 && nl != 0) || (old_nl != 0 && nl == 0))
		$.ajax({
			type: 'PATCH',
			url: document.URL,
			data: {
				'text[completed]': nl == 0
			},
			async: true
		});
	old_nl = nl;

	var sum = 0;
	for (i = 1; i <= 5; i++)
		sum += i * $('.s' + i + '.w').map (function () { return this.innerHTML.toLowerCase() }).get().filter(onlyUnique).length;
	var count = $('.w').map (function () { return this.innerHTML.toLowerCase() }).get().filter(onlyUnique).length;
	var rating = (sum / count).toFixed(1);
	$('#unratedWords').html(nl);
	$('#unratedWords').attr('title', 'In this text you have ' + nl + ' unrated words and ' + rated + ' rated words from a total of ' + total + ' unique words.');
	$('#averageRating').html(rating);
	$('#unratedWordsPlural').html(nl == 1 ? 'word' : 'words');

	if (total == 0) {
		$('.stat-block').html('');
	}
}

function onRatingsButton(rating) {
	currentRating = rating;
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
		needSave = false;
	}
}

$(document).ready(function() {
	$('.lookup #links a').click(function () {
		if (!isMobile)
			$('.lookup #lword').focus();
	});
	
	$('.word').click(function (event) {
		if (last_word != "" && needSave) {
			$.ajax({
				type: 'PATCH',
				url: '/words/' + last_word,
				data: {
					'word[note]': $('#lword').val(),
					'word[language]': text_language
				},
				async: true
			});
			needSave = false;
		}
		if (last_word == $(event.target).attr('value')) {
			$('.lookup').fadeOut(400);
			last_word = "";
		}
		else {
			last_word = $(event.target).attr('value');
			last_word_case = event.target.innerHTML;
			if ($(event.target).attr('title')) {
				last_word_case = $(event.target).attr('title');
				last_word_case = last_word_case.replace('...', ' ... ');
				last_word_case = last_word_case.replace('..', ' ... ');
				last_word_case = last_word_case.replace('_', ' ');
			}
			$.getJSON("/words/" + text_language + '/' + last_word, function(data) {
				$('.lookup').fadeIn(400);
				$('.lookup #rword').html(last_word_case);
				$('.lookup #lword').val(data["note"]);
				refreshCurrentWordRating(data["rating"]);
				if (!isMobile)
					$('.lookup #lword').focus();
				needSave = false;
			});
		}
	});

	$('#colorToggle').click(function () {
		showColors = !showColors;
		if (showColors) {
			$('#colorToggle').html('<i class="fa fa-toggle-on"></i> Show Colors');
			$('.s0,.s1,.s2,.s3,.s4,.s5,.s6').css('background', '');
			$('.s0,.s1,.s2,.s3,.s4,.s5,.s6').css('border', '');
			$('#underlineToggle').css('display', 'block');
		}
		else {
			$('#colorToggle').html('<i class="fa fa-toggle-off"></i> Show Colors');
			$('.s0,.s1,.s2,.s3,.s4,.s5,.s6').css('background', 'white');
			$('.s0,.s1,.s2,.s3,.s4,.s5,.s6').css('border', 'none');
			$('#underlineToggle').css('display', 'none');
		}
		return false;
	});

	$('#underlineToggle').click(function () {
		underlineColors = !underlineColors;
		if (underlineColors) {
			$('#underlineToggle').html('<i class="fa fa-toggle-on"></i> Only Underline');
			$('.s0,.s1,.s2,.s3,.s4,.s5,.s6').addClass('underline');
		}
		else {
			$('#underlineToggle').html('<i class="fa fa-toggle-off"></i> Only Underline');
			$('.s0,.s1,.s2,.s3,.s4,.s5,.s6').removeClass('underline');
		}
		return false;
	});

	$('#archiveToggle').click(function () {
		if (!$('#text_hidden').prop('checked')) {
			$('#archiveToggle').html('<i class="fa fa-toggle-on"></i> Archive this text');
			$('#text_hidden').prop('checked', true);
		}
		else {
			$('#archiveToggle').html('<i class="fa fa-toggle-off"></i> Archive this text');
			$('#text_hidden').prop('checked', false);
		}
		return false;
	});

	$('#publicToggle').click(function () {
		if (!$('#text_public').prop('checked')) {
			$('#publicToggle').html('<i class="fa fa-toggle-on"></i> Make text public');
			$('#text_public').prop('checked', true);
		}
		else {
			$('#publicToggle').html('<i class="fa fa-toggle-off"></i> Make text public');
			$('#text_public').prop('checked', false);
		}
		return false;
	});

	$('#buttons span').click(function (event) {
		var rating = event.target.innerHTML;
		if (rating == '/')
			rating = 6;
		else
			rating = parseInt(rating);
		onRatingsButton(rating);
		if (!isMobile)
			$('.lookup #lword').focus();
	});

	$(".lookup #lword").change(function () {
		needSave = true;
	});

	$(".lookup #lword").keyup(function(event) {
		var keyCode = event.keyCode || event.which;

		if (keyCode == 9)
			event.preventDefault();
	});

	$(".lookup #lword").keypress(function(event) {
		var keyCode = event.keyCode || event.which;

		if (keyCode == 9)
			event.preventDefault();
	});

	$(".lookup #lword").keydown(function(event) {
		var keyCode = event.keyCode || event.which;

		if(keyCode == 13 && last_word)
			$.ajax({
				type: 'PATCH',
				url: '/words/' + last_word,
				data: {
					'word[note]': $('#lword').val(),
					'word[language]': text_language
				},
				async: true
			});
		// tab key incrases rating by one
		if (keyCode == 9) {
			event.preventDefault();
			if (!event.shiftKey)
				currentRating += 1;
			else
				currentRating -= 1;
			if (currentRating > 6)
				currentRating = 0;
			if (currentRating < 0)
				currentRating = 6;
			onRatingsButton(currentRating);
		}
		if (keyCode == 48 && event.ctrlKey) {
			onRatingsButton(0);
			event.preventDefault();
		}
		if (keyCode == 49 && event.ctrlKey) {
			onRatingsButton(1);
			event.preventDefault();
		}
		if (keyCode == 50 && event.ctrlKey) {
			onRatingsButton(2);
			event.preventDefault();
		}
		if (keyCode == 51 && event.ctrlKey) {
			onRatingsButton(3);
			event.preventDefault();
		}
		if (keyCode == 52 && event.ctrlKey) {
			onRatingsButton(4);
			event.preventDefault();
		}
		if (keyCode == 53 && event.ctrlKey) {
			onRatingsButton(5);
			event.preventDefault();
		}
		if (keyCode == 54 && event.ctrlKey) {
			onRatingsButton(6);
			event.preventDefault();
		}
	});

	$('#close-btn').bind('click', function (evt) {
		if (last_word != "" && needSave) {
			$.ajax({
				type: 'PATCH',
				url: '/words/' + last_word,
				data: {
					'word[note]': $('#lword').val(),
					'word[language]': text_language
				},
				async: true
			});
			needSave = false;
		}
		$('.lookup').fadeOut(400);
		last_word = "";
	});
});

$(function() {
	$( "#text_category" ).autocomplete({
		source: function(request, response) {
			$.getJSON("/texts/category", { lang: $('#text_language_id').val(), 'term': $('#text_category').val() }, response);
		},
		minLength: 2
	});
});
