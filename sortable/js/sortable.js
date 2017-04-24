// *** sortable.js ***

// https://github.com/rern/tips/tree/master/js/sortable

/*
usage:
...
<link rel="stylesheet" href="/path/sortable.css">
</head>
<body>

	<div id="divbeforeid"> <!-- optional -->
		(divBeforeTable html)
	</div>

	<table id="tableid">
		<thead><tr><td></td></tr></thead>
		<tbody><tr><td></td></tr></tbody>
	</table>

	<div id="divafterid"> <!-- optional -->
		(divAfterTable html)
	</div>

<script src="/path/jquery.min.js"></script>
<script src="/path/sortable.js"></script>
<script>
...
$('tableid').sortable(); 	// without options > full page table
// or
$('tableid').sortable({
	divBeforeTable: 'divbeforeid',	// default: (none) - div before table, enclosed in single div
	divAfterTable: 'divafterid',	// default: (none) - div after table, enclosed in single div
	initialSort: 'column#',		// default: (none) - start with 0
	locale: 'code',		// default: 'en' - locale code
	minusColumn: [column#]	// default: (none) - column with 'minus' value
});
...

**custom css for table:**  
  edit in `sortable.css`    
*/

(function($) {

$.fn.sortable = function(options) {
//*****************************************************************************
var settings = $.extend({ // defaults
	divBeforeTable: '',
	divAfterTable: '',
	initialSort: '',
	locale: 'en',
	minusColumn: []
}, options );
var initialsort = settings.initialSort;
var minuscolumn = settings.minusColumn;

var shortvport = 415; // min height to apply fixed thead
var initscrolltimeout = 300; // all 'setTimeout()' are crucial, less will break header and scroll position
var scrolltimeout = 400;
var thead2aligntimeout = 300;

var $window = $(window);
var $table = this;
var $thead = $table.find('thead');
var $thtd = $thead.find('tr').children();
var $tbody = $table.find('tbody');
var $tbtr = $tbody.find('tr');

var tblid = this[0].id;
var tblparent = '#sortable'+ tblid;
if (settings.divBeforeTable) {
	var divbefore = '#'+ settings.divBeforeTable;
	var divbeforeH = settings.divBeforeTable ? $(divbefore).outerHeight() : 0;
	$(divbefore).addClass('divbefore');
}
if (settings.divAfterTable) {
	var divafter = '#'+ settings.divAfterTable;
	var divafterH = settings.divAfterTable ? $(divafter).outerHeight() : 0;
	$(divafter).addClass('divafter');
}

// convert 'tbody' to value-only array [ [i, 'a', 'b', 'c'], [i, 'd', 'e', 'f'] ]
var arr = [];
$tbtr.each(function(i) {
	var tdarr = [i];
	$(this).find('td').each(function(j) {
		if (minuscolumn.indexOf(j) === -1) {
			var tdtxt = $(this).text();
		} else { // minus value in column
			var tdtxt = $(this).text().replace(/[^0-9\.\-]/g, '') // get only '0-9', '.' and '-'
		}
		tdarr.push( $thtd.eq(j).text() == '' ? '' : tdtxt ); // blank header not sortable
		
		// add '+20' space for sort icon
		if (i === 0 && $thtd.eq(j).text() !== '') {
			$(this).css('min-width', ($(this).outerWidth() + 20) +'px'); // 'i === 0' - only 1 row needed
		}
	});
	arr.push(tdarr);
});

$table.wrap('<div id="sortable'+ tblid +'" class="tblparent"></div>');
$table.addClass('sortable');
// dynamic css - for divbeforeH underlay, divafterH and fixed thead2
var trH = $tbtr.height();
$('head').append('<style>'+
	'.tblparent::before {'+
		'content: "";'+
		'display: block;'+
		'height: '+ (divbeforeH + 5) +'px;'+ // +5px offset 1st row
	'}\n'+
	'.sortableth2 {top: '+ divbeforeH +'px;}\n'+
	'.sortableth2 a {padding: '+ $table.find('td').css('padding') +';}\n'+
	'#trlast {height: '+ (divafterH + trH) +'px;}'+
	'@media(max-height: '+ shortvport +'px) {\n'+
		'.divbefore, .divafter {position: relative;}'+
		'.tblparent::before {display: block; height: 0;}'+
		'.sortableth2 {top: 0;}'+
		'.sortable thead {visibility: visible;}'+
		'#trlast {height: '+ trH +'px;}'+
	'}'+
	'</style>'
);

// #1 - functions
// align 'sortableth2 a' width to 'thead th'
function thead2align() {
	setTimeout(function() { // wait rendering	
		$thead.children().children().each(function(i) {
			$thead2a.eq(i).css('width', $(this).outerWidth() +'px'); // include 'td' padding
		});
		$thead2.show();
	}, thead2aligntimeout);
}

// #2 - add fixed header for short viewport
var th2html = $thead.find('tr')
	.html()
	.replace(/th|td/g, 'a')
	.replace(/[\n\t]|style=".*"/g, '');
$('body').prepend('\
	<div id="'+ tblid +'th2" class="sortableth2" style="display: none">\
		<a></a>'+ th2html +
	'</div>'
);
var $thead2 = $('#'+ tblid +'th2');
var $thead2a = $thead2.find('a');
// align text to 'thead th'
$thead.children().children().each(function(i) {
	$thead2a.eq(i).css( 'text-align', $(this).css('text-align') );
});
// delegate click to 'thead'
$thead2.find('a').click(function() {
	$thead.children().children().eq( $(this).index() )
		.click();
});

// #3 - add l/r padding 'td' to keep table center
// 'detach' to avoid many dom traversings
var $tbl = $table.detach();
$tbl.find('tr').each(function() {
	$(this)
		.prepend('<td class="tdpad"></td>')
		.append('<td class="tdpad"></td>');
});
$(tblparent).append($tbl);

// #4 - add empty 'tr' to bottom
$tbody.append(
	$tbody.find('tr:last')
		.clone()
		.empty()
		.prop('id', 'trlast')
);


// #6 - align 'sortableth2 a' width to 'thead th'
thead2align();

// #7 - scroll
// reference for scrolling calculation
fromshortv = ($window.height() < shortvport) ? 1 : 0;
// get scroll position
var scrltop = 0;
$window.scroll(function () {
	scrltop = $window.scrollTop();
});

// show top part on short viewport initial load
setTimeout(function() {
	$window.scrollTop(0);
	initialsort && $thtd.eq(initialsort - 1).click();
}, initscrolltimeout);

// #8 - click 'thead' to sort
$thead.children().children().click(function() {
	var i = $(this).index();
	var numcol = minuscolumn.indexOf(i - 1); // '-1' - deduct 'tdpad' column
	var order = $(this).hasClass('asc') ? 'desc' : 'asc';
	// sort value-only array (multi-dimensional)
	var sorted = arr.sort(function(a, b) {
		if (order == 'desc') {
			if (numcol === -1) {
				return a[i].localeCompare(b[i], settings.locale, {numeric: true});
			} else {
				return a[i] - b[i];
			}
		} else {
			if (numcol === -1) {
				return b[i].localeCompare(a[i], settings.locale, {numeric: true});
			} else {
				return b[i] - a[i];
			}
		}
	});
	// sort 'tbody' in-place by each 'array[0]', reference i [ [i, 'a', 'b', 'c'], [i, 'd', 'e', 'f'] ]
	$.each(sorted, function() {
		$tbody.prepend( $tbtr.eq($(this)[0]) );
	});
	// switch sort icon
	$thead2a.add(this).siblings().addBack()
		.removeClass('asc desc');
	$thead2a.eq(i).add(this)
		.addClass(order);
	// highlight sorted column
	$tbody.find('td').removeClass('sorted');
	$tbody.find('td:nth-child('+ (i+1) +')').addClass('sorted');
});

// #9 - screen rotate
window.addEventListener('orientationchange', function() {
//		scrltop = $window.scrollTop(); // !!! detect incorrectly in fullscreen ios, chrome devtools
	// maintain scroll position on rotate
	if ($window.height() < shortvport) {
		var scrltop0 = scrltop + divbeforeH;
		fromshortv = 1;
	} else {
		var scrltop0 = scrltop - (fromshortv ? divbeforeH : 0); // calc if from short viewport
		fromshortv = 0;
	}
	$thead2.hide();
	thead2align(); // align thead2
	
	setTimeout(function() {
		$window.scrollTop(scrltop0);
	}, scrolltimeout);
});
//*****************************************************************************
}
} (jQuery));
