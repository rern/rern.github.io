// *** sortable.js - https://github.com/rern/js/edit/master/sortable/ ***
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
$('tableid').sortable(); 		// without options > full page table
// or
$('tableid').sortable({
	divBeforeTable: 'divbeforeid',	// default: (none) - div before table, enclosed in single div
	divAfterTable: 'divafterid',	// default: (none) - div after table, enclosed in single div
	initialSort: 'column#',		// default: (none) - start with 0
	initialSortDesc: false,
	locale: 'code',			// default: 'en' - locale code
	negativeSort: [column#]		// default: (none) - column with negative value
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
	initialSortDesc: false,
	locale: 'en',
	negativeSort: []
}, options );
var initialsort = settings.initialSort;
var negativesort = settings.negativeSort;

var shortvport = 414; // max height to apply fixed thead
var initscrolltimeout = 400; // all 'setTimeout()' are crucial, less will break header and scroll position
var scrolltimeout = 500;
var thead2aligntimeout = 400;

var $window = $(window);
var $table = this;
var $thead = $table.find('thead');
var $thtr = $thead.find('tr');
var $tbody = $table.find('tbody');
var $tbtr = $tbody.find('tr');

var divbeforeH = 0;
var divafterH = 0;
if (settings.divBeforeTable) {
	var divbefore = '#'+ settings.divBeforeTable;
	var divbeforeH = $(divbefore).outerHeight();
	$(divbefore).addClass('divbefore');
}
if (settings.divAfterTable) {
	var divafter = '#'+ settings.divAfterTable;
	var divafterH = $(divafter).outerHeight();
	$(divafter).addClass('divafter');
}

// convert 'tbody' to value-only array [ [i, 'a', 'b', 'c'], [i, 'd', 'e', 'f'] ]
var arr = [];
var $thtd = $thead.children(); // without 'tdpad'
$tbtr.each(function(i) {
	var tdarr = [i];
	$(this).find('td').each(function(j) {
		if (negativesort.indexOf(j) === -1) {
			var tdtxt = $(this).text();
		} else { // minus value in column
			var tdtxt = $(this).text().replace(/[^0-9\.\-]/g, '') // get only '0-9', '.' and '-'
		}
		tdarr.push( $thtd.eq(j).text() == '' ? '' : tdtxt ); // blank header not sortable
	});
	arr.push(tdarr);
});

// #a - allocate space for sort icon with long text
// extract sort icon
$('body').append('<a id="tmp" class="asc">24</a>');
var icon = window.getComputedStyle(
	document.getElementById('tmp'),':before').content;
icon = '&#'+ icon.charCodeAt(0) +';&#'+ icon.charCodeAt(1) +';'
// add sort icon to set 'min-width'
$thead.find('th, td').prepend('<a class="tmpicon" style="opacity: 0">'+ icon +'</a>');
$thead.children().children().each(function(i) {
	$(this).css('min-width', $(this).outerWidth() +'px');
});
$thead.find('#tmp, .tmpicon').remove();

// #b dynamic css - for divbeforeH underlay, divafterH and fixed thead2
var tblid = this[0].id;
var tblparent = '#sortable'+ tblid;
$table.wrap('<div id="sortable'+ tblid +'" class="tblparent"></div>');
$table.addClass('sortable');
var trH = $tbtr.height();
$('head').append('<style>'+
	'.tblparent::before {'+
		'content: "";'+
		'display: block;'+
		'height: '+ (divbeforeH + 5) +'px;'+ // +5px offset 1st row
	'}\n'+
	'.sortableth2 {top: '+ divbeforeH +'px;}\n'+
	'.sortableth2 a {padding: '+ $table.find('td').css('padding') +';}\n'+
	'#trlast {height: '+ (divafterH + trH) +'px;}\n'+
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
		$thead2a.add( $thtd ).show(); // reset hidden
		$thtd.each(function(i) {
			if ( $tbtd.eq(i).is(':visible') ) {
				$thead2a.eq(i).css('width', $tbtd.eq(i).outerWidth() +'px'); // include 'td' padding
			} else {
				$thead2a.eq(i).add(this).hide(); // set hidden
			}
		});
		$thead2a.eq(0).css( 'width', $tbtd.eq(0).outerWidth() ); // fix - tdpad reset to '0'
		$thead2.show();
	}, thead2aligntimeout);
}

// #2 - add fixed header for short viewport
var th2html = $thtr
	.html()
	.replace(/style="min-width: .{1,7}"/g, '')
	.replace(/th|td/g, 'a');
$('body').prepend('\
	<div id="'+ tblid +'th2" class="sortableth2" style="display: none">\
		<a></a>'+ th2html +
	'</div>'
);
var $thead2 = $('#'+ tblid +'th2');
var $thead2a = $thead2.find('a');
$thead.children().children().each(function(i) {
	$thead2a.eq(i).css( 'text-align', $(this).css('text-align') ); // 'text-align' 'thead2 a' to 'thead th'
});
// delegate click to 'thead'
$thead2a.click(function() {
	$thead.children().children().eq( $(this).index() )
		.click();
});

// #3 - add l/r padding 'td' to keep table center
// 'detach' to avoid many dom traversings
var $tbl = $table.detach();
$tbl.find('tr').each(function() {
	var tdpad = '<td class="tdpad"></td>';
	$(this)
		.prepend(tdpad)
		.append(tdpad);
});
$(tblparent).append($tbl);
var $thtd = $thead.children();
var $tbtd = $tbtr.find('td');

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
var $thtd = $thtr.children(); // with 'tdpad'
setTimeout(function() {
	$window.scrollTop(0);
	initialsort && $thtd.eq(initialsort).trigger('click', settings.initialSortDesc);
}, initscrolltimeout);

// #8 - click 'thead' to sort
$thead.children().children().click(function(event, initdesc) {
	var i = $(this).index();
	var numcol = negativesort.indexOf(i - 1); // '-1' - deduct 'tdpad' column
	var order = ($(this).hasClass('asc') || initdesc) ? 'desc' : 'asc';
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
	$thead2a.add($thtd)
		.removeClass('asc desc');
	$thead2a.eq(i).add(this)
		.addClass(order);
	// highlight sorted column
	$tbtd
		.removeClass('sorted')
		.end()
			.find('td:nth-child('+ (i+1) +')')
				.addClass('sorted');
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
