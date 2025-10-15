#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;

// RULE 1: 'self' is always a hudelem

HAS_CHILD_HUDS()
{
	return array_validate( self.members );
}

set_alignment( alignx, aligny, horzalign, vertalign )
{
	self set_hud_field( "alignx", alignx );
	self set_hud_field( "aligny", aligny );
	self set_hud_field( "horzalign", horzalign );
	self set_hud_field( "vertalign", vertalign );
}

set_position2d( x, y )
{
	self set_hud_field( "setx", x );
	self set_hud_field( "sety", y );
}

set_position3d( x, y, z )
{
	self set_hud_field( "setx", x );
	self set_hud_field( "sety", y );
	self set_hud_field( "setz", z );
}

add_position2d( x, y )
{
	self set_hud_field( "addx", x );
	self set_hud_field( "addy", y );
}

add_position3d( x, y, z )
{
	self set_hud_field( "addx", x );
	self set_hud_field( "addy", y );
	self set_hud_field( "addz", z );
}

set_alpha( val )
{
	self set_hud_field( "alpha", val );
}

set_hide_in_menu_flag( val )
{
	self set_hud_field( "hidewheninmenu", val );
}

apply_offset( x, y )
{
	self set_hud_field( "addx", x );
	self set_hud_field( "addy", y );
}

set_hud_field( field_name, val )
{
	do_relative = getsubstr( field_name, 0, 3 ) == "add";
	do_assign = getsubstr( field_name, 0, 3 ) == "set";

	if ( do_assign )
	{
		switch ( field_name )
		{
			case "setalignx":
				self.alignx = val;
				break;
			case "setaligny":
				self.aligny = val;
				break;
			case "sethorzalign":
				self.horzalign = val;
				break;
			case "setvertalign":
				self.vertalign = val;
				break;
			case "setcolor":
				if ( !is_true( self.is_root ) )
				{
					self.color = val;
				}
				else
				{
					self.parent_color = val;
				}
				break;
			case "setalpha":
				if ( !is_true( self.is_root ) )
				{
					self.alpha = val;
				}
				else
				{
					self.parent_alpha = val;
				}
				break;
			case "setglowcolor":
				if ( !is_true( self.is_root ) )
				{
					self.glowcolor = val;
				}
				else
				{
					self.parent_glowcolor = val;
				}
				break;
			case "setglowalpha":
				if ( !is_true( self.is_root ) )
				{
					self.glowalpha = val;
				}
				else
				{
					self.parent_glowalpha = val;
				}
				break;
			case "sethidewheninmenu":
				self.hidewheninmenu = val;
				break;
			case "sethidewhendead":
				self.hidewhendead = val;
				break;
			case "sethidewheninkillcam":
				self.hidewheninkillcam = val;
				break;
			case "sethidewhenindemo":
				self.hidewhenindemo = val;
				break;
			case "setimmunetodemogamehudsettings":
				self.immunetodemogamehudsettings = val;
				break;
			case "sethidewhileremotecontrolling":
				self.hidewhileremotecontrolling = val;
				break;
			case "sethidewheninscope":
				self.hidewheninscope = val;
				break;
			case "setfadewhentargeted":
				self.fadewhentargeted = val;
				break;
			case "setfontstyle3d":
				self.fontstyle3d = val;
				break;
			case "setfont3duseglowcolor":
				self.font3duseglowcolor = val;
				break;
			case "setforeground":
				self.foreground = val;
				break;
			case "setarchived":
				self.archived = val;
				break;
			case "setx":
				self.x = val;
				break;
			case "sety":
				self.y = val;
				break;
			case "setz":
				self.z = val;
				break;
			case "setfontscale":
				self.fontscale = val;
				break;
			case "setfont":
				self.font = val;
				break;
			case "setsort":
				self.sort = val;
				break;
			case "setui3dwindow":
				self.ui3dwindow = val;
				break;
			case "setshowplayerteamhudelemtospectator":
				self.showplayerteamhudelemtospectator = val;
				break;
			default:
				return;
		}
	}

	if ( do_relative )
	{
		switch ( field_name )
		{
			case "addcolor":
				if ( !is_true( self.is_root ) )
				{
					self.color += val;
				}
				else
				{
					self.parent_color += val;
				}
				break;
			case "addalpha":
				if ( !is_true( self.is_root ) )
				{
					self.alpha += val;
				}
				else
				{
					self.parent_alpha += val;
				}
				break;
			case "addglowcolor":
				if ( !is_true( self.is_root ) )
				{
					self.glowcolor += val;
				}
				else
				{
					self.parent_glowcolor += val;
				}
				break;
			case "addglowalpha":
				if ( !is_true( self.is_root ) )
				{
					self.glowalpha += val;
				}
				else
				{
					self.parent_glowalpha += val;
				}
				break;
			case "addx":
				self.x += val;
				break;
			case "addy":
				self.y += val;
				break;
			case "addz":
				self.z += val;
				break;
			case "addfontscale":
				self.fontscale += val;
				break;
			case "addsort":
				self.sort += val;
				break;
			default:
				return;
		}
	}
	
	if ( !self HAS_CHILD_HUDS() )
	{
		return;
	}

	for ( i = 0; i < _SIZE( self.children.size ); i++ )
	{
		child = self.children[ i ];

		child set_hud_field( field_name, val );
	}
}

set_safe_text_internal( text )
{
	level._text_count++;
	self.save_text = text;
	self settext( text );
}

set_safe_label_internal( text )
{
	level._text_count++;
	self.save_label = text;
	self.label = istring( text );
}

set_safe_text( text, prev_text, is_label )
{
	is_label = _DEFAULT( is_label, false );
	prev_text = _DEFAULT( prev_text, "" );

	if ( text == prev_text )
	{
		// optimization to reduce unnecessary set increments
		return;
	}

	if ( level._text_count >= level._text_limit )
	{
		// clear all strings
		level._baseline_text_hud clearalltextafterhudelem();
		for ( i = 0; i < _SIZE( level._text_huds.size ); i++ )
		{
			text_hud = level._text_huds[ i ];
			text_hud.label = &"";
			text_hud settext( "" );
		}

		level._text_count = 0;

		// restore previous text for active huds
		for ( i = 0; i < _SIZE( level._text_huds.size ); i++ )
		{
			text_hud = level._text_huds[ i ];
			if ( isdefined( level._text_huds[ i ].save_label ) )
			{
				text_hud.label = level._text_huds[ i ].save_label;
			}
			if ( isdefined( level._text_huds[ i ].save_text ) )
			{
				text_hud settext( level._text_huds[ i ].save_text );
			}
			
			level._text_count++;
		}

		com_printdebugerror( "Had to clear the text cache..." );
	}

	if ( is_label )
	{
		if ( !isdefined( self.save_label ) || self.save_label != text )
		{
			self set_safe_label_internal( text );
			return;
		}
	}
	else
	{
		if ( !isdefined( self.save_text ) || self.save_text != text )
		{
			self set_safe_text_internal( text );
			return;
		}
	}
}

call_hud_method( call_name, args )
{
	switch ( call_name )
	{
		case "fadeovertime":
			time = args[ 0 ];
			self fadeovertime( time );
			break;
		case "setshader":
			material = args[ 0 ];
			width = args[ 1 ];
			height = args[ 2 ];
			if ( isdefined( height ) )
			{
				self setshader( material, width, height );
			}
			else
			{
				self setshader( material );
			}
			break;
		case "settargetent":
			ent = args[ 0 ];
			self settargetent( ent );
			break;
		case "cleartargetent":
			self cleartargetent();
			break;
		case "settimer":
			time = args[ 0 ];
			self settimer( time );
			break;
		case "settimerup":
			time = args[ 0 ];
			self settimerup( time );
			break;
		case "settenthstimer":
			time = args[ 0 ];
			self settenthstimer( time );
			break;
		case "settenthstimerup":
			time = args[ 0 ];
			self settenthstimerup( time );
			break;
		case "setclock":
			time = args[ 0 ];
			duration = args[ 1 ];
			material = args[ 2 ];
			width = args[ 3 ];
			height = args[ 4 ];
			if ( isdefined( height ) )
			{
				self setclock( time, duration, material, width, height );
			}
			else
			{
				self setclock( time, duration, material );
			}
			break;
		case "setclockup":
			time = args[ 0 ];
			duration = args[ 1 ];
			material = args[ 2 ];
			width = args[ 3 ];
			height = args[ 4 ];
			if ( isdefined( height ) )
			{
				self setclockup( time, duration, material, width, height );
			}
			else
			{
				self setclockup( time, duration, material );
			}
			break;
		case "setvalue":
			value = args[ 0 ];
			self setvalue( value );
			break;
		case "setwaypoint":
			constant_size = args[ 0 ];
			offscreen_material = args[ 1 ];
			unk1 = args[ 2 ];
			unk2 = args[ 3 ];
			if ( isdefined( unk2 ) )
			{
				self setwaypoint( constant_size, offscreen_material, unk1, unk2 );
			}
			else if ( isdefined( unk1 ) )
			{
				self setwaypoint( constant_size, offscreen_material, unk1 );
			}
			else if ( isdefined( offscreen_material ) )
			{
				self setwaypoint( constant_size, offscreen_material );
			}
			else
			{
				self setwaypoint( constant_size );
			}
			break;
		case "scaleovertime":
			scale_time = args[ 0 ];
			scale_width = args[ 1 ];
			scale_height = args[ 2 ];
			self scaleovertime( scale_time, scale_width, scale_height );
			break;
		case "moveovertime":
			move_time = args[ 0 ];
			self moveovertime( move_time );
			break;
		case "reset":
			self reset();
			break;
		case "destroy":
			self destroy();
			break;
		case "setpulsefx":
			letter_time = args[ 0 ];
			decay_start_time = args[ 1 ];
			decay_duration = args[ 2 ];
			self setpulsefx( letter_time, decay_start_time, decay_duration );
			break;
		case "setcod7decodefx":
			letter_time = args[ 0 ];
			decay_start_time = args[ 1 ];
			decay_duration = args[ 2 ];
			self setcod7decodefx( letter_time, decay_start_time, decay_duration );
			break;
		case "setredactfx":
			decay_start_time = args[ 0 ];
			decay_duration = args[ 1 ];
			redact_decay_start_time = args[ 2 ];
			redact_decay_duration = args[ 3 ];
			self setredactfx( decay_start_time, decay_duration, redact_decay_start_time, redact_decay_duration );
			break;
		case "settypewriterfx":
			letter_time = args[ 0 ];
			decay_start_time = args[ 1 ];
			decay_duration = args[ 2 ];
			self settypewriterfx( letter_time, decay_start_time, decay_duration );
			break;
		case "setplayernamestring":
			ent = args[ 0 ];
			self setplayernamestring( ent );
			break;
		case "setmapnamestring":
			mapname = args[ 0 ];
			self setmapnamestring( mapname );
			break;
		case "setgametypestring":
			gametype = args[ 0 ];
			self setmapnamestring( gametype );
			break;
		case "changefontscaleovertime":
			scale_time = args[ 0 ];
			self changefontscaleovertime( scale_time );
			break;
		default:
			return;
	}

	if ( !self HAS_CHILD_HUDS() )
	{
		return;
	}

	for ( i = 0; i < _SIZE( self.children.size ); i++ )
	{
		child = self.children[ i ];

		child call_hud_method( call_name, args );
	}
}