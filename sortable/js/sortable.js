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
$('tableid').sortable();             // without options > full page table
// or
$('tableid').sortable( {
	divBeforeTable:	   'divbeforeid' // default: (none) - div before table, enclosed in single div
	, divAfterTable:   'divafterid'  // default: (none) - div after table, enclosed in single div
	, initialSort:     'column#'     // default: (none) - start with 0
	, initialSortDesc: false         // default: false
	, locale:          'code'        // default: 'en'   - locale code
	, negativeSort:    [column#]     // default: (none) - column with negative value
	, tableArray:      []            // default: (none) - use table data array directly
} );
...

**custom css for table:**  
  edit in `sortable.css`    
*/

( function( $ ) {

$.fn.sortable = function( options ) {
//*****************************************************************************
var settings = $.extend( { // defaults
	divBeforeTable: ''
	, divAfterTable: ''
	, nitialSort: ''
	, initialSortDesc: false
	, locale: 'en'
	, negativeSort: []
	, tableArray : []
}, options );
var shortvport = 414; // max height to apply fixed thead
var timeout = 400; // try higher if table was not right

var $window = $(window);
var $table = this;
var $thead = $table.find('thead');
var $thtr = $thead.find('tr');
var $thtd = $thtr.children(); // either 'th' or 'td'
var $tbody = $table.find('tbody');
var $tbtr = $tbody.find('tr');
var $tbtd = $tbtr.find('td');

var initialsort = settings.initialSort;
var negativesort = settings.negativeSort;
// use table array directly if available
if ( settings.tableArray.length ) {
	var arr = settings.tableArray;
} else {
	// convert 'tbody' to value-only array [ [i, 'a', 'b', 'c'], [i, 'd', 'e', 'f'] ]
	var arr = [];
	$tbtr.each( function( i ) {
		var tdarr = [ i ];
		$( this ).find('td').each( function( j ) {
			if ( negativesort.indexOf( j+1 ) === -1 ) { // '+1' - make 1st column = 1, not 0
				var tdtxt = $( this ).text();
			} else { // minus value in column
				var tdtxt = $( this ).text().replace( /[^0-9\.\-]/g, '' ); // get only '0-9', '.' and '-'
			}
			tdarr.push( $thtd.eq( j ).text() == '' ? '' : tdtxt ); // blank header not sortable
		} );
		arr.push( tdarr );
	} );
}

var divbeforeH = 0;
var divafterH = 0;
if ( settings.divBeforeTable ) {
	var divbefore = '#'+ settings.divBeforeTable;
	divbeforeH = $( divbefore ).outerHeight();
	$( divbefore ).addClass('divbefore');
}
if ( settings.divAfterTable ) {
	var divafter = '#'+ settings.divAfterTable;
	divafterH = $( divafter ).outerHeight();
	$( divafter ).addClass('divafter');
}

// dynamic css - for divbeforeH underlay, divafterH and fixed thead2
var tblid = this[0].id;
var tblparent = '#sortable'+ tblid;
$table.wrap('<div id="sortable'+ tblid +'" class="tblparent"></div>');
$table.addClass('sortable');
var trH = $tbtr.height();

$('head').append('<style>'
	+'.tblparent::before {'
		+'content: "";'
		+'display: block;'
		+'height: '+ divbeforeH +'px;'
		+'width: 100%;'
	+'}\n'
	+'.sortableth2 {top: '+ divbeforeH +'px;}\n'
	+'#trlast {height: '+ ( divafterH + trH ) +'px;}\n'
	+'@media(max-height: '+ shortvport +'px) {\n'
		+'.divbefore {position: absolute;}'
		+'.divafter {position: relative;}'
		+'.sortableth2 {top: 0;}'
		+'.sortable thead {visibility: visible;}'
		+'#trlast {height: '+ trH +'px;}'
	+'}'
	+'</style>'
//	+'<meta name="viewport" content="width=device-width, initial-scale=1.0">'
);

// #1 - functions
// allocate width for sort icon and align 'sortableth2 a' width to 'thead th'
function thead2align() {
	$thead2a.show(); // reset hidden
	var thtdL = $thtd.length;
	$thtd.each( function( i ) {
		if ( i > 0 && i < ( thtdL - 1 ) ) { // allocate width for sort icon to avoid clipped header
			$( this )
				.addClass('asctmp')
				.css('min-width', $( this ).outerWidth() +'px')
				.removeClass('asctmp');
		}
		if ( $tbtd.eq( i ).is(':visible') ) {
			$thead2a.eq( i ).css('width', $( this ).outerWidth() +'px'); // include 'td' padding
		} else {
			$thead2a.eq( i ).hide(); // set hidden column
		}
	} );
	$thead2a.eq( 0 ).css( 'width', $tbtd.eq( 0 ).outerWidth() ); // fix - tdpad reset to '0'
	$thead2.show();
}

// #2 - add fixed header for short viewport
var th2html = '<a></a>'; // for 'td' click index
$thtd.each( function( i ) { // eq(i + 1) 'text-align' - compensate added tdpad
	th2html += '<a style="text-align: '+ $thtd.eq( i + 1 ).css('text-align') +';">'+ $( this ).text() +'</a>';
} );
$('body').prepend(
	'<div id="'+ tblid +'th2" class="sortableth2" style="display: none">'+ th2html +'</div>'
);
var $thead2 = $('#'+ tblid +'th2');
var $thead2a = $thead2.find('a');
// delegate click to 'thead'
$thead2a.click( function() {
	$thtd.eq( $( this ).index() )
		.click();
} );

// #3 - add l/r padding 'td' to keep table center
// 'detach' to avoid many dom traversings
var $tbl = $table.detach();
$thtr.prepend('<th class="tdpad"></th>')
	.append('<th class="tdpad"></th>');
$tbtr.prepend('<td class="tdpad"></td>')
	.append('<td class="tdpad"></td>');
$( tblparent ).append( $tbl );

$thtd = $thtr.children(); // refresh cache after added
$tbtd = $tbtr.find('td'); // refresh cache after added

// #4 - add empty 'tr' to bottom
$tbody.append(
	$tbody.find('tr:last')
		.clone()
		.empty()
		.prop('id', 'trlast')
);

// #6 - align 'sortableth2 a' and initial sort column
setTimeout( function() {
	thead2align();
	initialsort && $thtd.eq( initialsort ).trigger( 'click', settings.initialSortDesc );
//	$window.scrollTop( 0 );
}, timeout );

// #7 - click 'thead' to sort
$thtd.click( function( event, initdesc ) {
	var i = $( this ).index();
	var negsort = negativesort.indexOf( i );
	var order = ( $( this ).hasClass('asc') || initdesc ) ? 'desc' : 'asc';
	// sort value-only array (multi-dimensional)
	var sorted = arr.sort( function( a, b ) {
		if ( order == 'desc') {
			if ( negsort === -1 ) {
				return a[ i ].localeCompare( b[ i ], settings.locale, { numeric: true } );
			} else {
				return a[ i ] - b[ i ];
			}
		} else {
			if ( negsort === -1 ) {
				return b[ i ].localeCompare( a[ i ], settings.locale, { numeric: true } );
			} else {
				return b[ i ] - a[ i ];
			}
		}
	} );
	// sort 'tbody' in-place by each 'array[ 0 ]', reference i [ [i, 'a', 'b', 'c'], [i, 'd', 'e', 'f'] ]
	$.each( sorted, function() {
		$tbody.prepend( $tbtr.eq( $( this )[ 0 ]) );
	} );
	// switch sort icon and highlight sorted column
	$thead2a.add( $thtd ).add( $tbtd )
		.removeClass('asc desc sorted');
	$thead2a.eq( i ).add( this )
		.addClass( order )
			.add( $tbody.find('td:nth-child('+ ( i+1 ) +')') )
			.addClass('sorted');
} );

// #8 - scroll
// reference for scrolling calculation
var fromshortv = ( $window.height() <= shortvport ) ? 1 : 0;
// get scroll position
var scrltop = 0;
$window.scroll( function () {
	scrltop = $window.scrollTop();
} );

// #9 - screen rotate
var scrlcurrent = 0;
window.addEventListener('orientationchange', function() {
	// maintain scroll position on rotate (get 'scrollTop()' here works only on ios)
	if ( $('.sortableth2').css('top') == '0px' ) {
		scrlcurrent = scrltop + divbeforeH;
		fromshortv = 1;
	} else {
		scrlcurrent = scrltop - ( fromshortv ? divbeforeH : 0 ); // omit only H to V from short viewport
		fromshortv = 0;
	}
	$thead2.hide();
//	thead2align(); // align thead2
	
	setTimeout( function() {
		$.when(
		$window.off('scroll') // fix - android 'scrollTop()' on 'orientationchange'
			.scrollTop( scrlcurrent )
			.scroll( function () {
				setTimeout( function() {
					scrltop = $window.scrollTop();
				}, timeout);
			} )
		).then( thead2align() ); // align thead2
	}, timeout);
} );
//*****************************************************************************
}
} ( jQuery ) );
