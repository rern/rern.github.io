$(document).ready(function() {
// document ready start********************************************************************

function buttonOnOff(pullup) {
	if (pullup == 0) { // R pulldown low > trigger signal = relay on
		$('#gpio').addClass('btn-primary');
		$('#gpio i').removeClass('fa-volume-off').addClass('fa-volume-up');
	} else {
		$('#gpio').removeClass('btn-primary');
		$('#gpio i').removeClass('fa-volume-up').addClass('fa-volume-off');
	}
}
PNotify.prototype.options.styling = 'fontawesome';

function timeout() {
	timer = '';
	var sec = 15;
	timerout = setTimeout(function() {
		PNotify.removeAll();
		new PNotify({
			icon: 'fa fa-cog fa-spin fa-lg',
			title: 'GPIO',
			text: 'IDLE Timer OFF<br>in '+ sec +' sec ...',
			delay: sec * 1000,
			addclass: 'pnotify_custom',
			confirm: {
				confirm: true,
				buttons: [{
					text: 'Timer Reset',
					click: function(notice) {
						notice.remove();
						pullup = 0;
						timeout()
					}
				}, null]
			},
			before_open: function() {
				timer = setInterval(function() {
					if (sec == 1) {
						clearInterval(timer);
						pullup = 1;
					}
					$('.ui-pnotify-text').html('IDLE Timer OFF<br>in '+ sec-- +' sec ...');
				}, 1000);
			},
			after_close: function() {
				buttonOnOff(pullup);
				if (timer) {
					clearInterval(timer);
					timer = false;
				}
			}
		});
	}, sec * 1000);
}
$('#gpio').click(function() {
	var on = $('#gpio').hasClass('btn-primary');
	pullup = (on) ? 1 : 0;
	PNotify.removeAll();
	new PNotify({
		icon: 'fa fa-cog fa-spin fa-lg',
		title: 'GPIO',
		text: on ? 'Powering OFF ...' : 'Powering ON ...',
		delay: 4000,
		addclass: 'pnotify_custom',
		after_close: function() {
			buttonOnOff(pullup);
		}
	});
	if (on) {
		if (timer) {
			clearInterval(timer);
			timer = false;
		}
		clearTimeout(timerout)
		timerout = false;
	} else {
		timeout();
	}
});

// document ready end *********************************************************************
});
