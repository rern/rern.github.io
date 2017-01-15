$(document).ready(function() {
// document ready start********************************************************************

if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
	$('#volume').attr({'data-width': 250, 'data-height': 250});
}
function knobchange(value) {
	var totaltime = $('#total').text().split(':');
	var totalsec = (Number(totaltime[0]) * 60) + Number(totaltime[1]);
	var currentsec = Math.round(value / 1000 * totalsec);
	var min = Math.floor(currentsec / 60);
	min = (min < 10) ? '0'+ min :  min;
	var sec = (currentsec) % 60;
	sec = (sec < 10) ? '0'+ sec : sec;
	var currenttime = min +':'+ sec;
	$('#countdown-display span').text(currenttime);
}
// playback knob
$('#time').knob({
	inline: false,
	change: function(value) {
		if (timer) {
			clearInterval(timer);
			timer = false;
		}
		knobchange(value);
	},
	release: function(value) {
		knobchange(value);
		if ($('#play').find('i').hasClass('fa-play') && $('#play').hasClass('btn-primary')) {
			clearInterval(timer);
			play();
		}
	}
})
// volume knob
var dynVolumeKnob = $('#volume').data('dynamic');
$('#volume').knob({
	inline: false,
	draw: function() {
		// "tron" case
		if (this.$.data('skin') === 'tron') {
			this.cursorExt = 0.05;
			var a = this.arc(this.cv), pa, r = 1;
			this.g.lineWidth = this.lineWidth;
			if (this.o.displayPrevious) {
				pa = this.arc(this.v);
				this.g.beginPath();
				this.g.strokeStyle = this.pColor;
				this.g.arc(this.xy, this.xy, this.radius - this.lineWidth, pa.s, pa.e, pa.d);
				this.g.stroke();
			}
			this.g.beginPath();
			this.g.strokeStyle = r ? this.o.fgColor : this.fgColor ;
			this.g.arc(this.xy, this.xy, this.radius - this.lineWidth, a.s, a.e, a.d);
			this.g.stroke();
			this.g.lineWidth = 2;
			this.g.beginPath();
			this.g.strokeStyle = this.o.fgColor;
			this.g.arc( this.xy, this.xy, this.radius - this.lineWidth + 13 + this.lineWidth, 0, 2 * Math.PI, false);
			this.g.stroke();
			return false;
		}
	}
});

var timer = false;
var song1 = ['Lynyrd Skynyrd', 'Free Bird', 'Sounds Of The Seventies - 1975', '1/3', '04:45', '1.jpg'];
var song2 = ['Gladys Knight And The Pips', 'Neither One Of Us (Wants To Be The First To Say Goodbye)', 'Sounds Of The Seventies - 1973 Take Two', '2/3', '04:22', '2.jpg'];
var song3 = ['Blondie', 'Heart Of Glass', 'Sounds Of The Seventies - 1979', '3/3', '03:26', '3.jpg'];
	
function play() {
	var currenttime = $('#countdown-display span').text().split(':');
	var currentsec = (Number(currenttime[0]) * 60) + Number(currenttime[1]);
	var totaltime = $('#total').text().split(':');
	var totalsec = (Number(totaltime[0]) * 60) + Number(totaltime[1]);
	var currentknob = Number($('#time').val());
/*	timer = setInterval(function() {
		currentsec = currentsec + 1;
		var min = Math.floor(currentsec / 60);
		min = (min < 10) ? '0'+ min :  min;
		var sec = (currentsec) % 60;
		sec = (sec < 10) ? '0'+ sec : sec;
		currenttime = min +':'+ sec;
		currentknob = Math.round(1000 * currentsec / totalsec);
		$('#countdown-display span').text(currenttime);
		$('#time').val(currentknob).trigger('change');
		if (currentsec == totalsec) {
			var list = $('#playlist-position').find('span').text();
			$('#time').val(0).trigger('change');
			$('#countdown-display span').text('00:00')
			clearInterval(timer);
			timer = false;
			if ($('#repeat').hasClass('btn-primary')) {
				if (!$('#single').hasClass('btn-primary')) {
					(list == '3/3') ? songchange(song1) : next();
				}
				play();
			} else if ($('#single').hasClass('btn-primary')) {
				$('#stop').click();
			} else if ($('#random').hasClass('btn-primary')) {
				if (list == '1/3') songchange(song3);
				if (list == '2/3') songchange(song1);
				if (list == '3/3') songchange(song2);
				play();
			} else {
				next();
				play();
			}
		}
	}, 1000);*/
	timer = setInterval(function() {
		currentsec = currentsec + 0.25;
		var min = Math.floor(currentsec / 60);
		min = (min < 10) ? '0'+ min :  min;
		var sec = (currentsec) % 60;
		sec = (sec < 10) ? '0'+ sec : sec;
		currenttime = min +':'+ sec;
		currentknob = Math.round(1000 * currentsec / totalsec);
		$('#countdown-display span').text(currenttime);
		$('#time').val(currentknob).trigger('change');
		if (currentsec == totalsec) {
			var list = $('#playlist-position').find('span').text();
			$('#time').val(0).trigger('change');
			$('#countdown-display span').text('00:00')
			clearInterval(timer);
			timer = false;
			if ($('#repeat').hasClass('btn-primary')) {
				if (!$('#single').hasClass('btn-primary')) {
					(list == '3/3') ? songchange(song1) : next();
				}
				play();
			} else if ($('#single').hasClass('btn-primary')) {
				$('#stop').click();
			} else if ($('#random').hasClass('btn-primary')) {
				if (list == '1/3') songchange(song3);
				if (list == '2/3') songchange(song1);
				if (list == '3/3') songchange(song2);
				play();
			} else {
				next();
				play();
			}
		}
	}, 250);
}
function songchange(sn) {
	$('#currentartist').text(sn[0]);
	$('#currentsong').text(sn[1]);
	$('#currentalbum').text(sn[2]);
	$('#playlist-position').find('span').text(sn[3]);
	$('#total').text(sn[4]);
	$('#cover-art').attr('src', 'assets/'+ sn[5]);
	if (timer) {
		$('#time').val(0);
		$('#countdown-display span').text('00:00')
		clearInterval(timer);
		play();
	}
// scrolling text
	$('#divartist, #divsong, #divalbum').each(function() {
		if ($(this).find('span').width() > Math.floor(window.innerWidth * 0.975)) {
			$(this).addClass('scroll-left');
		} else {
			$(this).removeClass('scroll-left');
		}
	});
}
function previous() {
	var list = $('#playlist-position').find('span').text();
	if (list == '2/3') {
		songchange(song1);
	}
	if (list == '3/3') {
		songchange(song2);
	}
}
function next() {
	var list = $('#playlist-position').find('span').text();
	if (list == '1/3') {
		songchange(song2);
	}
	if (list == '2/3') {
		songchange(song3);
	}
}
songchange(song2);
	
$('#play').click(function() {
	if ($(this).find('i').hasClass('fa-pause') || $('#stop').hasClass('btn-primary')) {
		$(this).find('i').removeClass('fa-pause').addClass('fa-play');
		play()
	} else {
		$(this).find('i').removeClass('fa-play').addClass('fa-pause');
		clearInterval(timer);
		timer = false;
	}
	$(this).addClass('btn-primary');
	$('#stop').removeClass('btn-primary')
});
$('#stop').click(function () {
	$(this).addClass('btn-primary');
	$('#play').removeClass('btn-primary').find('i').removeClass('fa-pause').addClass('fa-play');
	$('#time').val(0).trigger('change');
	$('#countdown-display span').text('00:00')
	clearInterval(timer);
	timer = false;
});
$('#play-group button, #volumemute').click(function() {
	$(this).toggleClass('btn-primary');
});
$('#previous').click(function () {
	previous();
});

$('#next').click(function () {
	next();
});
$('#overlay-playsource-open').click(function() {
	$('#overlay-playsource').css({'visibility': 'visible', 'opacity': '100'});
});
$('#overlay-social-open').click(function() {
	$('#overlay-social').css({'visibility': 'visible', 'opacity': '100'});
});
$('#overlay-playsource-close, #overlay-social-close').click(function() {
	$('.overlay-scale').css({'visibility': 'hidden', 'opacity': '0'});
});
// swipe
var hammerinfo = new Hammer(document.getElementById('info'));
hammerinfo.on('swiperight', function () {
	previous();
});
hammerinfo.on('swipeleft', function () {
	next();
});
$('#currentsong').click(function() {
	var list = $('#playlist-position').find('span').text();
	new PNotify({
		icon: 'fa fa-refresh fa-spin fa-lg',
		title: 'Lyrics',
		text: 'Fetching ...',
		addclass: 'pnotify_custom'
	});
	$.get('assets/'+ list[0], function(data) {
		PNotify.removeAll();
		// need new 'pnotify.custom.min.js' with 'button', confirm', 'callback', 'css'
			new PNotify({
			icon: false,
			title: $('#currentsong').text(),
			text: data +'\n\n&#8226;&#8226;&#8226;\n\n\n\n\n\n\n\n',
			hide: false,
			addclass: 'pnotify_lyric pnotify_custom',
			buttons: {
				closer_hover: false,
				sticker: false
			},
			before_open: function() {
				$('#lyricfade').removeClass('hide');
				$('#menu-bottom').addClass('lyric-menu-bottom');
			},
			after_close: function() {
				$('#lyricfade').addClass('hide');
				$('#menu-bottom').removeClass('lyric-menu-bottom');
				$('.ui-pnotify').remove();
			}
		});
	});
});


function topbottom() {
	if ($('#menu-top').position().top != 0) {
		$('#menu-top').css('top', 0);
		$('#menu-bottom').css('bottom', 0);
	} else {
		$('#menu-top').css('top', '-40px');
		$('#menu-bottom').css('bottom', '-40px');
	}
}
function volmargin() {
	if ($('#cover-art').is(':visible')) {
		if ($(window).width() < 500) $('#time-knob').css('margin-top', 0);
		if ($('#play-group').is(':visible')) {
			$('#share-group').show();
		} else {
			$('#divalbum').show();
		}
	} else {
		$('#time-knob').css('margin-top', '-25px'); // hidden '#cover-art' cannot be css
	}
}

$('#barleft').click( function() {
	if ($('#volume-knob').length && $(window).width() < 500) {
		if ($('#play-group').is(':visible')) {
			$('#share-group, #cover-art').slideToggle(volmargin);
		} else {
			$('#cover-art').slideToggle(volmargin);
		}
	} else {
		topbottom();
	}
});
window.addEventListener('orientationchange', function() {
//	$('#cover-art').show(volmargin);
	$('#divartist, #divsong, #divalbum').each(function() {
		if ($(this).find('span').width() > window.innerWidth) {
			$(this).addClass('scroll-left');
		} else {
			$(this).removeClass('scroll-left');
		}
	});
});

$('#barright').click( function() {
	$('#play-group, #vol-group').toggle();
	if ($('#play-group').is(':visible') && $('#cover-art').is(':visible')) {
		$('#share-group').show();
	} else {
		$('#share-group').hide();
	}
	if (window.innerHeight < 500) {
		if ($('#play-group').is(':visible')) {
			$('#divalbum, #sampling').hide();
		} else {
			$('#divalbum, #sampling').show();
		}
	}
});

$('#open-panel-sx, #open-panel-dx').click(function() {
	$('#barleft, #barright').hide();
});
$('#open-playback').click(function() {
	$('#barleft, #barright').show();
});
// playback buttons click go back to home page
$('.playback-controls').click(function() {
	if (!$('#playback').hasClass('active')) {
		$('#open-playback a').click();
		$('#open-playback a')[0].click();
	}
});
// playlist click go back to home page
$('#playlist ul').click(function(e) {
	//alert(e.target.nodeName);
	if (e.target.nodeName == 'SPAN') {
		$('#open-playback a').click();
		$('#open-playback a')[0].click();
		if ($(window).width() < 500 || $(window).height() < 500) topbottom();
	}
});
// playsource button replacement
$('#playsource').click(function() {
	$('#overlay-playsource-open').click();
});
// menus click remove lyric
$('#playsource, #menu-settings, #open-panel-sx, #open-panel-dx').click(function() {
	PNotify.removeAll();
	$('#lyricfade').addClass('hide');
	$('#menu-bottom').removeClass('lyric-menu-bottom');
});

// additional play/pause by click
$('#coverart, #countdown-display').click(function(){
	$('#play').click();
});
// lastfm search
$('#currentartist').click(function() {
	var artist = $(this).text();
	if (artist.slice(0, 3) != '[no')
		window.open('http://www.last.fm/music/'+ artist);
});

$('#currentalbum').click(function(){
	var artist = $('#currentartist').text();
	var album = $(this).text();
	if (album.slice(0, 3) != '[no')
		window.open('http://www.last.fm/music/'+ artist +'/'+ album);
});

var hammerrow = new Hammer(document.getElementById('playback-row'));
hammerrow.on('swipe', function() {
	$('#barright').click();
});

var hammerbarleft = new Hammer(document.getElementById('barleft'));
hammerbarleft.on('swipe', function() {
	$('#barleft').click();
});
hammerbarleft.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });

var hammerbarright = new Hammer(document.getElementById('barright'));
hammerbarright.on('swipe', topbottom);
hammerbarright.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });

// document ready end *********************************************************************
});
