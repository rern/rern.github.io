( function ( $ ) {

$.fn.sortable = function ( options ) {
//*****************************************************************************
var settings = $.extend( {   // #### defaults:
	divBeforeTable: ''       // 
	, divAfterTable: ''      // 
	, initialSort: ''        // 
	, initialSortDesc: false //
	, locale: 'en'           // 
	, negativeSort: []       // column with negative value
	, timeout: 400           // try higher if 'thead2' misaligned
	, shortViewportH: 414    // max height to apply fixed 'thead2'
	, tableArray : []        // raw data array to skip extraction
}, options );

var $window = $( window );
var $table = this;
var $thead = $table.find( 'thead' );
var $thtr = $thead.find( 'tr' );
var $thtd = $thtr.children(); // either 'th' or 'td'
var $tbody = $table.find( 'tbody' );
var $tbtr = $tbody.find( 'tr' );
var $tbtd = $tbtr.find( 'td' );

// use table array directly if provided
if ( settings.tableArray.length ) {
	var tableArray = settings.tableArray;
} else {
	// convert 'tbody' to value-only array [ [i, 'a', 'b', 'c', ...], [i, 'd', 'e', 'f', ...] ]
	var tableArray = [];
	$tbtr.each( function ( i ) {
		var row = [ i ];
		$( this ).find( 'td' ).each( function ( j ) {
			if ( settings.negativeSort.indexOf( j+1 ) === -1 ) { // '+1' - make 1st column = 1, not 0
				var cell = $( this ).text();
			} else { // get minus value in alphanumeric column
				var cell = $( this ).text().replace( /[^0-9\.\-]/g, '' ); // get only '0-9', '.' and '-'
			}
			row.push( $thtd.eq( j ).text() == '' ? '' : cell ); // blank header not sortable
		} );
		tableArray.push( row );
	} );
}

var divBeforeH = 0;
var divAfterH = 0;
if ( settings.divBeforeTable ) {
	divBeforeH = $( settings.divBeforeTable ).outerHeight();
	$( settings.divBeforeTable ).addClass( 'divbefore' );
}
if ( settings.divAfterTable ) {
	divAfterH = $( settings.divAfterTable ).outerHeight();
	$( settings.divAfterTable ).addClass( 'divafter' );
}

// dynamic css - for divBeforeH, divAfterH and thead2
var tableID = this[ 0 ].id;
var tableParent = '#sortable'+ tableID;
var trH = $tbtr.height();
$table.wrap( '<div id="sortable'+ tableID +'" class="tableParent"></div>' );
$table.addClass( 'sortable' );

$( 'head' ).append( '<style>'
	+'.tableParent::before {'
		+'content: "";'
		+'display: block;'
		+'height: '+ divBeforeH +'px;'
		+'width: 100%;'
	+'}\n'
	+'.sortableth2 {top: '+ divBeforeH +'px;}\n'
	+'#trlast {height: '+ ( divAfterH + trH ) +'px;}\n'
	+'@media(max-height: '+ settings.shortViewportH +'px) {\n'
		+'.divbefore {position: absolute;}'
		+'.divafter {position: relative;}'
		+'.sortableth2 {top: 0;}'
		+'.sortable thead {visibility: visible;}'
		+'#trlast {height: '+ trH +'px;}'
	+'}'
	+'</style>'
//	+'<meta name="viewport" content="width=device-width, initial-scale=1.0">'
);

// #### add l/r padding 'td' to keep table center
var $tabletmp = $table.detach(); // avoid many dom traversings
// change 'th' to 'td' for consistent selection
$thtd.prop( 'tagName' ) == 'TH' &&
	$thtr.html( $thtr.html().replace( /th/g, 'td' ) );
// add 'tdpad'
$thtr.add( $tbtr )
	.prepend( '<td class="tdpad"></td>' )
	.append( '<td class="tdpad"></td>' )
;
$( tableParent ).append( $tabletmp );
// refresh cache after add 'tdpad'
$thtd = $thtr.find( 'td' );
$tbtd = $tbtr.find( 'td' );

// #### add fixed 'thead2'
var thead2html = '<a></a>';
$thtd.each( function ( i ) {
	if ( i > 0 && i < ( $thtd.length - 1 ) ) {
		thead2html += '<a style="text-align: '+ $( this ).css( 'text-align' ) +';">'
				+ $( this ).text()
			+'</a>'
		;
	}
} );
$( 'body' ).prepend(
	'<div id="'+ tableID +'th2" class="sortableth2" style="display: none">'+
		thead2html
	+'</div>'
);
var $thead2 = $( '#'+ tableID +'th2' );
var $thead2a = $thead2.find( 'a' );
// delegate click to 'thead'
$thead2a.click( function () {
	$thtd.eq( $( this ).index() ).click();
} );

// #### add empty 'tr' to bottom
$tbody.append(
	$tbody.find( 'tr:last' )
		.clone()
		.empty()
		.prop( 'id', 'trlast' )
);

// #### allocate width for sort icon and align 'thead2a'
function thead2align() {
	$thead2a.show();
	$thtd
		.addClass( 'asctmp' )
			.each( function ( i ) {
				( i > 0 && i < ( $thtd.length - 1 ) ) &&
					$( this ).css( 'min-width', $( this ).outerWidth() +'px' ); // include 'td' padding
				$thead2a.eq( i ).css( 'width', $( this ).outerWidth() +'px' );
				$( this ).is(':hidden') &&
					$thead2a.eq( i ).hide(); // set hidden header
			} )
				.removeClass( 'asctmp' )
	;
	$thead2a.eq( 0 ) // set 'td' min-width then get 'tdpad' width
		.css( 'width', $thtd.eq( 0 ).outerWidth() )
			.parent()
				.show()
	;
}

// #### initial align 'thead2a' and sort column
setTimeout( function () {
	thead2align()
	settings.initialSort &&
		$thtd.eq( settings.initialSort ).trigger( 'click', settings.initialSortDesc );
}, settings.timeout );

// #### click 'thead' to sort
$thtd.click( function ( event, initdesc ) {
	var i = $( this ).index();
	var order = ( $( this ).hasClass( 'asc' ) || initdesc ) ? 'desc' : 'asc';
	// sort value-only array, not table tr
	var sorted = tableArray.sort( function ( a, b ) {
		var ab = ( order == 'desc' ) ? [ a, b ] : [ b, a ];
		if ( settings.negativeSort.indexOf( i ) === -1 ) {
			return ab[ 0 ][ i ].localeCompare( ab[ 1 ][ i ], settings.locale, { numeric: true } );
		} else {
			return ab[ 0 ][ i ] - ab[ 1 ][ i ];
		}
	} );
	// sort 'tbody' in-place by each 'array[ 0 ]'
	$tbodytmp = $tbody.detach();
	$thead2a.add( $thtd ).add( $tbtd )
		.removeClass( 'asc desc sorted' );
	$.each( sorted, function () {
		$tbodytmp.prepend( $tbtr.eq( $( this )[ 0 ] ) );
	} );
	// switch sort icon and highlight sorted column
	$thead2a.eq( i ).add( this )
		.addClass( order )
			.add( $tbody.find( 'td:nth-child('+ ( i+1 ) +')' ) )
				.addClass( 'sorted' )
	;
	$table.append( $tbodytmp );
} );

// #### maintain scroll position on rotate
// get scroll position
var positionTop = 0;
var scrollTimeout;
function getScrollTop() {
	$window.scroll( function () {
		// cancel previous 'scroll' within 'settings.timeout'
		clearTimeout( scrollTimeout );
		scrollTimeout = setTimeout( function () {
			positionTop = $window.scrollTop();
		}, settings.timeout );
	} );
};
getScrollTop();

// reference for scrolling calculation
var fromShortViewport = ( $window.height() <= settings.shortViewportH ) ? 1 : 0;
var positionCurrent = 0;
// 'orientationchange' always followed by 'resize'
window.addEventListener( 'orientationchange', function () {
	$window.off( 'scroll' ); // suppress new 'scroll'
	$thead2.hide(); // suppress 'thead2' unaligned flash
	// maintain scroll (get 'scrollTop()' here works only on ios)
	if ( $thead.css( 'visibility' ) == 'visible' ) {
		positionCurrent = positionTop + divBeforeH;
		fromShortViewport = 1;
	} else {
		// omit 'divBeforeTable' if H to V from short viewport
		positionCurrent = positionTop - ( fromShortViewport ? divBeforeH : 0 );
		fromShortViewport = 0;
	}
	positionTop = positionCurrent; // update to new value
	setTimeout( function () {
		$window.scrollTop( positionCurrent );
	}, settings.timeout );
} );

// #### realign 'thead2' on rotate / resize
var resizeTimeout;
window.addEventListener( 'resize', function () {
	$window.off( 'scroll' ); // suppress new 'scroll'
	// cancel previous 'resize' within 'timeout'
	clearTimeout( resizeTimeout );
	resizeTimeout = setTimeout( function () {
		thead2align(); // realign thead2
		getScrollTop(); // re-enable 'scroll'
	}, settings.timeout );
} );
//*****************************************************************************
}

} ( jQuery ) );

