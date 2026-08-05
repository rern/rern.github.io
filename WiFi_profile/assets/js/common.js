// info ----------------------------------------------------------------------
function ico( cls, id ) {
	return '<i '+ ( id ? 'id="'+ id +'" ' : '' ) +'class="i-'+ cls +'"></i>'
}
function local( delay ) {
	V.local = true;
	setTimeout( () => V.local = false, delay || 300 );
}

I = { active: false }

function info( json ) {
	local();
	I = json;
	if ( 'keyvalue' in I ) $.each( I.keyvalue, ( k, v ) => I[ k ] = v );
	if ( 'values' in I ) {
		if ( ! Array.isArray( I.values ) ) {
			if ( typeof I.values === 'object' ) { // json
				I.keys   = Object.keys( I.values );
				I.values = Object.values( I.values );
			} else {
				I.values = [ I.values ];
			}
		}
	} else {
		I.values = false;
	}
	// fix: narrow screen scroll
	if ( V.wW < 768 ) $( 'body' ).css( 'overflow-y', 'auto' );
	
	$( '#infoOverlay' ).html( `
<div id="infoBox">
	<div id="infoTopBg">
		<div id="infoTop"><i id="infoIcon"></i><a id="infoTitle"></a></div>${ ico( 'close', 'infoX' ) }
	</div>
	<div id="infoList"></div>
	<div id="infoButton"></div>
</div>
` );
	// title
	if ( I.width ) $( '#infoBox' ).css( 'width', I.width );
	if ( I.height ) $( '#infoList' ).css( 'height', I.height );
	if ( I.icon ) {
		I.icon.charAt( 0 ) !== '<' ? $( '#infoIcon' ).addClass( 'i-'+ I.icon ) : $( '#infoIcon' ).html( I.icon );
	} else {
		$( '#infoIcon' ).addClass( 'i-help' );
	}
	var title = I.title || 'Information';
	$( '#infoTitle' ).html( title );
	// buttons
	var htmlbutton = '';
	if ( I.button ) {
		[ 'button', 'buttonlabel', 'buttoncolor' ].forEach( k => infoKey2array( k ) );
		I.button.forEach( ( fn, i ) => {
			htmlbutton += I.buttoncolor ? '<a style="background-color:'+ I.buttoncolor[ i ] +'"' : '<a';
			htmlbutton += ' class="infobtn extrabtn infobtn-primary">'+ I.buttonlabel[ i ] +'</a>';
		} );
	}
	if ( I.cancelshow || I.cancellabel || I.cancelcolor ) {
		var color   = I.cancelcolor ? ' style="background-color:'+ I.cancelcolor +'"' : '';
		htmlbutton += '<a id="infoCancel"'+ color +' class="infobtn infobtn-default">'+ ( I.cancellabel || 'Cancel' ) +'</a>';
	}
	if ( ! I.okno ) {
		var color = I.okcolor ? ' style="background-color:'+ I.okcolor +'"' : '';
		htmlbutton += '<a id="infoOk"'+ color +' class="infobtn infobtn-primary">'+ ( I.oklabel || 'OK' ) +'</a>';
	}
	if ( htmlbutton ) {
		$( '#infoButton' )
			.html( htmlbutton )
			.removeClass( 'hide' );
	} else {
		$( '#infoButton' ).remove();
	}
	if ( I.button ) {
		$( '#infoButton' ).on( 'click', '.extrabtn', function() {
			var buttonfn = I.button[ $( this ).index( '.extrabtn' ) ];
			infoButtonCommand( buttonfn );
		} );
	}
	$( '#infoX, #infoCancel' ).on( 'click', function() {
		infoButtonCommand( I.cancel, 'cancel' );
	} );
	$( '#infoOk' ).on( 'click', function() {
		if ( V.press || $( this ).hasClass( 'disabled' ) ) return
		
		infoButtonCommand( I.ok );
	} );
	if ( I.file ) {
		var htmlfile = '<div id="infoFilename"><c>(select file)</c></div>'
					  +'<input type="file" class="hide" id="infoFileBox"'+ ( I.file.type ? ' accept="'+ I.file.type +'">' : '>' )
					  +'<a id="infoFileLabel" class="infobtn file infobtn-primary">'
					  + ( I.file.label || ico( 'folder-open' ) +' File' ) +'</a>';
		$( '#infoButton' ).prepend( htmlfile )
		$( '#infoOk' )
			.html( I.file.oklabel )
			.addClass( 'hide' );
		$( '#infoFileLabel' ).on( 'click', function() {
			$( '#infoFileBox' ).trigger( 'click' );
		} );
		$( '#infoFileBox' ).on( 'change', function() {
			if ( ! this.files.length ) return
			
			I.infofile    = this.files[ 0 ];
			var filename  = I.infofile.name;
			var typeimage = I.infofile.type.slice( 0, 5 ) === 'image';
			I.filechecked = true;
			if ( I.file.type ) {
				if ( I.file.type === 'image/*' ) {
					I.filechecked = typeimage;
				} else {
					var ext = filename.includes( '.' ) ? filename.split( '.' ).pop() : 'none';
					I.filechecked = I.file.type.includes( ext );
				}
			}
			if ( ! I.filechecked ) {
				var htmlprev = $( '#infoList' ).html();
				$( '#infoFilename, #infoFileLabel' ).addClass( 'hide' );
				$( '#infoList' ).html( '<table><tr><td>Selected file :</td><td><c>'+ filename +'</c></td></tr>'
										 +'<tr><td>File not :</td><td><c>'+ I.file.type +'</c></td></tr></table>' );
				$( '#infoOk' ).addClass( 'hide' );
				$( '.infobtn.file' ).addClass( 'infobtn-primary' )
				$( '#infoButton' ).prepend( '<a class="btntemp infobtn infobtn-primary">OK</a>' );
				$( '#infoButton' ).one( 'click', '.btntemp', function() {
					$( '#infoList' ).html( htmlprev );
					infoSetValues();
					$( this ).remove();
					$( '#infoFileLabel' ).removeClass( 'hide' );
					$( '.infoimgnew, .infoimgwh' ).remove();
					$( '.infoimgname' ).removeClass( 'hide' );
				} );
			} else {
				$( '#infoFilename' ).text( filename );
				$( '#infoFilename, #infoOk' ).removeClass( 'hide' );
				$( '.extrabtn' ).addClass( 'hide' );
				$( '.infobtn.file' ).removeClass( 'infobtn-primary' )
				if ( typeimage ) infoFileImage();
			}
		} );
	}
	if ( I.tab ) {
		var htmltab = '';
		I.tablabel.forEach( ( lbl, i ) => {
			htmltab += '<a '+ ( I.tab[ i ] ? '' : 'class="active"' ) +'>'+ lbl +'</a>';
		} );
		$( '#infoTopBg' ).after( '<div id="infoTab">'+ htmltab +'</div>' );
		$( '#infoTab a' ).on( 'click', function() {
			if ( ! $( this ).hasClass( 'active' ) ) I.tab[ $( this ).index() ]();
		} );
	}
	if ( I.prompt ) {
		I.oknoreset = true;
		$( '#infoList' ).after( '<div class="infoprompt gr hide">'+ I.prompt +'</div>' );
	}
	var htmls = {};
	[ 'header', 'message', 'footer' ].forEach( k => {
		if ( I[ k ] ) {
			var kalign = k +'align'
			var align = I[ kalign ] ? ' style="text-align:'+ I[ kalign ] +'"' : '';
			htmls[ k ] = '<div class="info'+ k +'" '+ align +'>'+ I[ k ] +'</div>';
		} else {
			htmls[ k ] = '';
		}
	} );
	if ( ! I.list ) {
		I.active = true;
		$( '#infoList' ).html( Object.values( htmls ).join( '' ) );
		if ( I.beforeshow ) I.beforeshow();
		$( '#infoOverlay' ).removeClass( 'hide' );
		$( '#infoBox' ).css( 'margin-top', $( window ).scrollTop() );
		infoButtonWidth();
		$( '#infoOverlay' ).focus();
		return
	}
	
	[ 'range', 'updn' ].forEach( k => I[ k ] = [] );
	if ( typeof I.list === 'string' ) {
		htmls.list = I.list;
	} else {
		htmls.list = '';
		if ( typeof I.list[ 0 ] !== 'object' ) I.list = [ I.list ];
		I.checkboxonly = ! I.list.some( l => l[ 1 ] !== 'checkbox' );
		var td0   = I.checkboxonly ? '<tr><td>' : '<tr><td></td><td colspan="2">'; // no label <td></td>
		var label, type;
		var i     = 0; // for radio name
		I.list.forEach( l => {
			label = l[ 0 ];
			type  = l[ 1 ];
/*			if ( [ 'radio', 'select' ].includes( type ) ) {
				var option = l[ 2 ];
				var attr = l[ 3 ] || false;
			} else {
				var attr = l[ 2 ] || false;
			}
			var col = tdtr = unit = updn = width = '';
			if ( attr ) {
				tdtr  = attr.tdtr || '';
				unit  = attr.unit || '';
				updn  = attr.updn || '';
				col   = attr.col ? ' colspan="'+ attr.col +'"' : '';
				width = attr.width ? ' style="width: '+  +'"' : '';
			}*/
			switch ( type ) {
				case 'checkbox':
					htmls.list += htmls.list.slice( -3 ) === 'tr>' ? td0 : '<td>';
					break;
				case 'hidden':
					htmls.list += '<tr class="hide"><td></td><td>';
					break;
				case 'radio':
					htmls.list += '<tr><td>'+ label +'</td><td colspan="2">';
					break;
				case 'range':
					htmls.list += '<tr><td>';
					break;
				default:
					htmls.list += htmls.list.slice( -3 ) === 'td>' ? '' : '<tr><td>'+ label +'</td>';
					htmls.list += l[ 4 ] ? '<td colspan="'+ l[ 4 ] +'">' : '<td>';
			}
			switch ( type ) {
				case 'checkbox':
					htmls.list += '<label><input type="checkbox">'+ label +'</label></td>';
					htmls.list += l[ 2 ] === 'td' ? '' : '</tr>'; // same line || 1:1 line
					break;
				case 'hidden':
				case 'number':
				case 'text':
					var unit = typeof l[ 2 ] === 'object' ? false : l[ 2 ];
					var updn = unit ? false : l[ 2 ];
					htmls.list += '<input type="'+ type +'"'+ ( updn ? ' disabled' : '' ) +'>';
					if ( unit ) {
						htmls.list += l[ 3 ] === 'td' ? '' : '<td>&nbsp;<gr>'+ unit +'</gr>';
					} else if ( updn ) {
						I.updn.push( updn );
						htmls.list += '<td>'+ ico( 'remove updn dn' ) + ico( 'plus-circle updn up' );
					}
					htmls.list += l[ 3 ] === 'td' ? '</td>' : '</tr>';
					break;
				case 'password':
					htmls.list += '<input type="password"></td><td>'+ ico( 'eye' ) +'</td></tr>';
					break;
				case 'radio':
					var isarray = $.isArray( l[ 2 ] );
					var tr      = false;
					$.each( l[ 2 ], ( k, v ) => {
						var k = isarray ? v : k;
						if ( tr ) htmls.list += '<tr><td></td><td colspan="2">';
						htmls.list += '<label><input type="radio" name="inforadio'+ i +'" value="'+ v +'">'+ k +'</label>';
						if ( l[ 3 ] === 'tr' ) {
							tr          = true;
							htmls.list += '</td></tr>'; // 1:1 line
						} else {
							htmls.list += '&emsp;'; // same line
						}
					} );
					htmls.list += tr ? '' : '</td></tr>';
					i++;
					break;
				case 'range':
					I.range = true;
					htmls.list += '<div class="inforange">'
								+'<div class="name">'+ label +'</div>'
								+'<div class="value gr"></div>'
								+ ico( 'minus dn' ) +'<input type="range" min="0" max="100">'+ ico( 'plus up' )
								+'</div></td></tr>';
					break
				case 'select':
					htmls.list += '<select>'+ htmlOption( l[ 2 ] ) +'</select>';
					if ( l[ 3 ] ) {
						htmls.list += l[ 3 ] === 'td' ? '</td>' : '<td>&nbsp;<gr>'+ l[ 3 ] +'</gr></td></tr>'; // unit
					} else {
						htmls.list += '</tr>';
					}
					break;
				case 'textarea':
					htmls.list += '<textarea></textarea></td></tr>';
					break;
				default: // generic string
					htmls.list += l[ 2 ];
					htmls.list += l[ 3 ] === 'td' ? '</td>' : '</td></tr>';
			}
		} );
		if ( type !== 'range' ) htmls.list = '<table>'+ htmls.list +'</table>';
	}
	
	// populate layout //////////////////////////////////////////////////////////////////////////////
	var content = '';
	[ 'header', 'message', 'list', 'footer' ].forEach( k => content += htmls[ k ] );
	$( '#infoList' ).html( content ).promise().done( function() {
		$( '#infoList input:text' ).prop( 'spellcheck', false );
		// get all input fields
		$inputbox = $( '#infoList' ).find( 'input:text, input[type=number], input:password, textarea' );
		$input    = $( '#infoList' ).find( 'input, select, textarea' );
		var name, nameprev;
		$input    = $input.filter( ( i, el ) => { // filter each radio per group ( multiple inputs with same name )
			name = el.name;
			if ( ! name ) {
				return true
			} else if (	name !== nameprev ) {
				nameprev = name;
				return true
			}
		} );
		// assign values
		infoSetValues();
		// set height shorter if checkbox / radio only
		$( '#infoList tr' ).each( ( i, el ) => {
			var $this = $( el );
			if ( $this.find( 'input:checkbox, input:radio' ).length ) $this.css( 'height', '36px' );
		} );
		// show
		$( '#infoOverlay' ).removeClass( 'hide' );
		// set at current scroll position
		$( '#infoBox' ).css( 'margin-top', $( window ).scrollTop() );
		I.active = true;
		'focus' in I ? $inputbox.eq( I.focus ).focus() : $( '#infoOverlay' ).focus();
		if ( $( '#infoBox' ).height() > window.innerHeight - 10 ) $( '#infoBox' ).css( { top: '5px', transform: 'translateY( 0 )' } );
		// check inputs: blank / length / change
		if ( I.checkblank ) {
			if ( I.checkblank === true ) I.checkblank = [ ...Array( $inputbox.length ).keys() ];
			infoKey2array( 'checkblank' );
			infoCheckBlank();
		} else {
			I.blank = false;
		}
		if ( I.checkip ) {
			infoKey2array( 'checkip' );
			infoCheckIP();
		} else {
			I.notip = false;
		}
		I.checklength  ? infoCheckLength() : I.short = false;
		I.nochange = I.values && I.checkchanged ? true : false;
		$( '#infoOk' ).toggleClass( 'disabled', I.blank || I.notip || I.short || I.nochange ); // initial check
		infoCheckSet();
		// custom function before show
		if ( I.beforeshow ) I.beforeshow();
	} );
	$( '#infoList .i-eye' ).on( 'click', function() {
		var $this = $( this );
		var $pwd  = $this.parent().prev().find( 'input' );
		if ( $pwd.prop( 'type' ) === 'text' ) {
			$this.removeClass( 'bl' );
			$pwd.prop( 'type', 'password' );
		} else {
			$this.addClass( 'bl' );
			$pwd.prop( 'type', 'text' );
		}
	} );
}

function infoButtonCommand( fn, cancel ) {
	if ( typeof fn === 'function' ) fn();
	if ( cancel ) delete I.oknoreset;
	if ( V.local || V.press || I.oknoreset ) return // consecutive info / no reset
	
	I = { active: false }
	infoReset();
}
function infoButtonWidth() {
	if ( I.buttonfit ) return
	
	var $buttonhide = $( '#infoButton a.hide' );
	$buttonhide.removeClass( 'hide' );
	var widest = 0;
	$( '#infoButton a' ).each( ( i, el ) => {
		var w = $( el ).outerWidth();
		if ( w > widest ) widest = w;
	} );
	$buttonhide.addClass( 'hide' );
	if ( widest > 70 ) $( '.infobtn, .filebtn' ).css( 'min-width', widest );
}
function infoCheckBlank() {
	if ( ! I.checkblank ) return // suppress error on repeating
	
	I.blank = I.checkblank.some( i => $inputbox.eq( i ).val().trim() === '' );
}
function infoCheckIP() {
	var regex = /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$/; // https://stackoverflow.com/a/36760050
	I.notip = I.checkip.some( i => {
		return ! regex.test( $inputbox.eq( i ).val() );
	} );
}
function infoCheckLength() {
	I.short = false;
	$.each( I.checklength, ( k, v ) => {
		if ( ! Array.isArray( v ) ) {
			var L    = v
			var cond = 'equal';
		} else {
			var L    = v[ 0 ];
			var cond = v[ 1 ];
		}
		var diff = $input.eq( k ).val().trim().length - L;
		if ( ( cond === 'equal' && diff !== 0 ) || ( cond === 'min' && diff < 0 ) || ( cond === 'max' && diff > 0 ) ) {
			I.short = true;
			return false
		}
	} );
}
function infoCheckSet() {
	if ( I.checkchanged || I.checkblank || I.checkip || I.checklength ) {
		$( '#infoList' ).find( 'input, select, textarea' ).on( 'input', function() {
			if ( I.checkchanged ) I.nochange = I.values.join( '' ) === infoVal( 'array' ).join( '' );
			if ( I.checkblank ) setTimeout( infoCheckBlank, 0 ); // ios: wait for value
			if ( I.checklength ) setTimeout( infoCheckLength, 25 );
			if ( I.checkip ) setTimeout( infoCheckIP, 50 );
			setTimeout( () => {
				$( '#infoOk' ).toggleClass( 'disabled', I.nochange || I.blank || I.notip || I.short )
			}, 75 ); // ios: force after infoCheckLength
		} );
	}
}
function infoFileImage() {
	delete I.infofilegif;
	I.timeoutfile = setTimeout( () => banner( 'refresh blink', 'Change Image', 'Load ...', -1 ), 1000 );
	I.rotate      = 0;
	$( '.infoimgname' ).addClass( 'hide' );
	$( '.infoimgnew, .infoimgwh' ).remove();
	if ( I.infofile.name.slice( -3 ) !== 'gif' ) {
		infoFileImageLoad();
	} else { // animated gif or not
		var formdata = new FormData();
		formdata.append( 'cmd', 'giftype' );
		formdata.append( 'file', I.infofile );
		fetch( 'cmd.php', { method: 'POST', body: formdata } )
			.then( response => response.json() ) // set response data as json > animated
			.then( animated => { // 0 / 1
				if ( animated ) {
					I.infofilegif = '/srv/http/data/shm/local/tmp.gif';
					var img    = new Image();
					img.src    = URL.createObjectURL( I.infofile );
					img.onload = function() {
						var imgW   = img.width;
						var imgH   = img.height;
						var resize = infoFileImageResize( 'gif', imgW, imgH );
						infoFileImageRender( img.src, imgW +' x '+ imgH, resize ? resize.wxh : '' );
						clearTimeout( I.timeoutfile );
						bannerHide();
					}
				} else {
					infoFileImageLoad();
				}
			} );
	}
}
function infoFileImageLoad() {
	V.pica ? infoFileImageReader() : $.getScript( '/assets/js/plugin/'+ jfiles.pica, infoFileImageReader );
}
function infoFileImageReader() {
	var maxsize   = ( V.library && ! V.librarylist ) ? 200 : 1000;
	var reader    = new FileReader();
	reader.onload = function( e ) {
		var img    = new Image();
		img.src    = e.target.result;
		img.onload = function() {
			var imgW          = img.width;
			var imgH          = img.height;
			var filecanvas    = document.createElement( 'canvas' );
			var ctx           = filecanvas.getContext( '2d' );
			filecanvas.width  = imgW;
			filecanvas.height = imgH;
			ctx.drawImage( img, 0, 0 );
			var resize = infoFileImageResize( 'jpg', imgW, imgH );
			if ( resize ) {
				var canvas    = document.createElement( 'canvas' );
				canvas.width  = resize.w;
				canvas.height = resize.h;
				V.pica = pica.resize( filecanvas, canvas, picaOption ).then( function() {
					infoFileImageRender( canvas.toDataURL( 'image/jpeg' ), imgW +' x '+ imgH, resize.wxh );
				} );
			} else {
				infoFileImageRender( filecanvas.toDataURL( 'image/jpeg' ), imgW +' x '+ imgH );
			}
			clearTimeout( I.timeoutfile );
			bannerHide();
		}
	}
	reader.readAsDataURL( I.infofile );
	$( '#infoList' )
		.off( 'click', '.infoimgnew' )
		.on( 'click', '.infoimgnew', function() {
		if ( ! $( '.infomessage .rotate' ).length ) return
		
		I.rotate     += 90;
		if ( I.rotate === 360 ) I.rotate = 0;
		var canvas    = document.createElement( 'canvas' );
		var ctx       = canvas.getContext( '2d' );
		var image     = $( this )[ 0 ];
		var img       = new Image();
		img.src       = image.src;
		img.onload    = function() {
			ctx.drawImage( image, 0, 0 );
		}
		var w         = img.width;
		var h         = img.height;
		var cw        = Math.round( w / 2 );
		var ch        = Math.round( h / 2 );
		canvas.width  = h;
		canvas.height = w;
		ctx.translate( ch, cw );
		ctx.rotate( Math.PI / 2 );
		ctx.drawImage( img, -cw, -ch );
		image.src     = canvas.toDataURL( 'image/jpeg' );
	} );
}
function infoFileImageRender( src, original, resize ) {
	$( '.infomessage .imgnew' ).remove();
	$( '.infomessage' ).append(
		 '<span class="imgnew">'
			+'<img class="infoimgnew" src="'+ src +'">'
			+'<div class="infoimgwh">'
			+ ( resize ? resize : '' )
			+ ( original ? '<br>original: '+ original : '' )
			+'</div>'
			+ ( src.slice( 0, 4 ) === 'blob' ? '' : '<br>'+ ico( 'redo rotate' ) +'&ensp;Tap to rotate' )
		+'</span>'
	);
}
function infoFileImageResize( ext, imgW, imgH ) {
	var maxsize = ( V.library && ! V.librarylist ) ? 200 : ( ext === 'gif' ? 600 : 1000 );
	if ( imgW > maxsize || imgH > maxsize ) {
		var w = imgW > imgH ? maxsize : Math.round( imgW / imgH * maxsize );
		var h = imgW > imgH ? Math.round( imgH / imgW * maxsize ) : maxsize;
		return {
			  w   : w
			, h   : h
			, wxh : w +' x '+ h
		}
	}
}
function infoKey2array( key ) {
	if ( ! Array.isArray( I[ key ] ) ) I[ key ] = [ I[ key ] ];
}
function infoPrompt( message ) {
	var $toggle = $( '#infoX, #infoTab, .infoheader, #infoList, .infofooter, .infoprompt' );
	$( '.infoprompt' ).html( message );
	$toggle.toggleClass( 'hide' );
	$( '#infoOk' ).off( 'click' ).on( 'click', function() {
		$toggle.toggleClass( 'hide' );
		$( '#infoOk' ).off( 'click' ).on( 'click', I.ok );
	} );
}
function infoReset() {
	$( '#infoOverlay' )
		.addClass( 'hide' )
		.removeAttr( 'style' )
		.empty();
	$( 'body' ).css( 'overflow-y', '' );
}
function infoSetValues() {
	var $this, type, val;
	$input.each( ( i, el ) => {
		$this = $( el );
		type  = $this.prop( 'type' );
		val   = I.values[ i ];
		if ( type === 'radio' ) { // reselect radio by name
			if ( val ) {
				$( '#infoList input:radio[name='+ el.name +']' ).val( [ val ] );
			} else {
				$( '#infoList input:radio' ).eq( 0 ).prop( 'checked', true );
			}
		} else if ( type === 'checkbox' ) {
			$this.prop( 'checked',  val );
		} else if ( $this.is( 'select' ) ) {
			val ? $this.val( val ) : el.selectedIndex = 0;
		} else {
			$this.val( val );
			if ( type === 'range' ) $('.inforange .value' ).text( val );
		}
	} );
}
function infoVal( array ) {
	var $this, type, name, val;
	var values = [];
	$input.each( ( i, el ) => {
		$this = $( el );
		type  = $this.prop( 'type' );
		switch ( type ) {
			case 'checkbox':
				val = $this.prop( 'checked' );
				if ( val && $this.attr( 'value' ) ) val = $this.val(); // if value defined
				break;
			case 'number':
			case 'range':
				val = +$this.val();
				break;
			case 'password':
				val = $this.val().trim().replace( /(["&()\\])/g, '\$1' ); // escape extra characters
				break;
			case 'radio': // radio has only single checked - skip unchecked inputs
				val = $( '#infoList input:radio[name='+ el.name +']:checked' ).val();
				if ( val === 'true' ) {
					val = true;
				} else if ( val === 'false' ) {
					val = false;
				}
				break;
			case 'text':
				val = $this.val().trim();
				break;
			case 'textarea':
				val = $this.val().trim().replace( /\n/g, '\\n' );
				break;
			default: // hidden, select
				val = $this.val();
		}
		if ( typeof val !== 'string'                    // boolean
			|| val === ''                               // empty
			|| isNaN( val )                             // Not a Number 
			|| ( val[ 0 ] === '0' && val[ 1 ] !== '.' ) // '0123' not 0.123
		) {
			values.push( val );
		} else {
			values.push( parseFloat( val ) );
		}
	} );
	if ( array ) return values                                      // array
	
	if ( ! I.keys ) return values.length > 1 ? values : values[ 0 ] // array or single value as string
	
	var v = {}
	I.keys.forEach( ( k, i ) => v[ k ] = values[ i ] );
	return v                                                        // json
}
