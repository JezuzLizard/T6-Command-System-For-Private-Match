#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;

#include scripts\cmd\sv\core\_api_hud;
#include scripts\cmd\sv\core\_utility_hud;

init_debug_helpers()
{
	addcallback( "on_player_connect", ::debug_connect );
}

draw_nodes( draw_text )
{
	level endon( "draw_nodes_stop" );
	flag_wait_until_set_once( "initial_blackscreen_passed" );

	for ( ;; )
	{
		if ( !level._debug_draw_nodes_enabled )
		{
			wait 0.05;
			continue;
		}

		throttle_at = 400;
		throttle_count = 0;
		nodes = getallnodes();
		for ( i = 0; i < _SIZE( nodes.size ); i++ )
		{
			node = nodes[ i ];
			color = ( 0, 0, 0 );
			type = node.type;

			switch ( node.type )
			{
				case "Begin":
					color = ( 0, 0, 0.8 );
					break;
				case "End":
					color = ( 0, 0.8, 0 );
					break;
				case "Path":
					color = ( 0.8, 0, 0 );
					break;
			}

			if ( throttle_count == throttle_at )
			{
				//wait 0.05;
				throttle_count = 0;
			}

			draw_node_data( draw_text, node, color, type );
			throttle_count++;
		}
		wait 0.05;
	}
}

draw_triggers( draw_text )
{
	level endon( "draw_triggers_stop" );
	while ( !isDefined( level.zones ) )
	{
		wait 1;
	}

	flag_wait_until_set_once( "initial_blackscreen_passed" );

	for ( ;; )
	{
		wait 0.05;

		if ( !level._debug_draw_triggers_enabled )
		{
			continue;
		}

		for ( i = 0; i < _SIZE( level._debug_draw_triggers_types.size ); i++ )
		{
			type = level._debug_draw_triggers_types[ i ];
			if ( type == "all" || type == "radius" )
			{
				ents = getentarray( "trigger_radius", "classname" );

				for ( j = 0; j < ents.size; j++ )
				{
					maxs = ents[ j ] getmaxs();
					draw_trigger_radius_info( draw_text, ents[ j ].origin, maxs[ 0 ], maxs[ 2 ], ents[ j ].angles, "trigger_radius", ents[ j ] getentitynumber() );
					draw_trigger_radius( ents[ j ].origin, maxs[ 0 ], maxs[ 2 ], ents[ j ].angles, 16, ( 0.8, 0.8, 0.8 ) );
				}
			}

			if ( type == "all" || type == "radius_use" )
			{
				ents = getentarray( "trigger_radius_use", "classname" );

				for ( j = 0; j < ents.size; j++ )
				{
					maxs = ents[ j ] getmaxs();
					draw_trigger_radius_info( draw_text, ents[ j ].origin, maxs[ 0 ], maxs[ 2 ], ents[ j ].angles, "trigger_radius_use", ents[ j ] getentitynumber() );
					draw_trigger_radius( ents[ j ].origin, maxs[ 0 ], maxs[ 2 ], ents[ j ].angles, 16, ( 0.8, 0, 0.8 ) );
				}
			}

			if ( type == "all" || type == "box" )
			{
				ents = getentarray( "trigger_box", "classname" );

				for ( j = 0; j < ents.size; j++ )
				{
					maxs = ents[ j ] getmaxs();
					mins = ents[ j ] getmins();
					draw_trigger_box_info( draw_text, ents[ j ].origin, mins, maxs, ents[ j ].angles, "trigger_box", ents[ j ] getentitynumber() );
					draw_trigger_box( ents[ j ].origin, mins, maxs, ents[ j ].angles, ( 0.8, 0.8, 0 ) );
				}
			}

			if ( type == "all" || type == "box_use" )
			{
				ents = getentarray( "trigger_box_use", "classname" );

				for ( j = 0; j < ents.size; j++ )
				{
					maxs = ents[ j ] getmaxs();
					mins = ents[ j ] getmins();
					draw_trigger_box_info( draw_text, ents[ j ].origin, mins, maxs, ents[ j ].angles, "trigger_box", ents[ j ] getentitynumber() );
					draw_trigger_box( ents[ j ].origin, mins, maxs, ents[ j ].angles, ( 0, 0.8, 0.8 ) );
				}
			}

			if ( type == "all" || type == "damage" )
			{
				ents = getentarray( "trigger_damage", "classname" );

				for ( j = 0; j < ents.size; j++ )
				{
					maxs = ents[ j ] getmaxs();
					draw_trigger_radius_info( draw_text, ents[ j ].origin, maxs[ 0 ], maxs[ 2 ], ents[ j ].angles, "trigger_damage", ents[ j ] getentitynumber() );
					draw_trigger_radius( ents[ j ].origin, maxs[ 0 ], maxs[ 2 ], ents[ j ].angles, 16, ( 0.3, 0.8, 0.8 ) );
				}
			}
		}
	}
}

private debug_connect()
{
	self._debug_draw_location_enabled = false;
	self thread location_hud();
}

private location_hud()
{
	self endon( "disconnect" );

	x = 5;
	y = -20;

	loc_hud = [];
	for ( i = 0; i < 3; i++ )
	{
		loc_hud[ i ] = self new_debug_hud( x, y, i );
		x += 55;
	}

	loc_hud[ 0 ].label = &"x:";
	loc_hud[ 1 ].label = &"y:";
	loc_hud[ 2 ].label = &"z:";

	flag_wait_until_set_once( "initial_blackscreen_passed" );

	for (;;)
	{
		while ( !self._debug_draw_location_enabled )
		{
			for ( i = 0; i < 3; i++ )
			{
				loc_hud[ i ].alpha = 0;
			}
			wait 1;
		}
		for ( i = 0; i < 3; i++ )
		{
			loc_hud[ i ].alpha = 1;
			loc_hud[ i ] setValue( self.origin[ i ] );
		}
		wait 0.05;
	}
}

private draw_node_box( origin, color, vec )
{
	vec = _DEFAULT( vec, ( 20, 20, 20 ) );
	box( origin + ( 0, 0, 20 ), vec * -1, vec, 0, color, 1.0 );
}

private draw_node( origin, color, type )
{
	draw_node_box( origin, color );
}

private get_eye()
{
	if ( isplayer( self ) )
	{
		linked_ent = self getlinkedent();

		if ( isdefined( linked_ent ) && getdvarint( #"cg_cameraUseTagCamera" ) > 0 )
		{
			camera = linked_ent gettagorigin( "tag_camera" );

			if ( isdefined( camera ) )
				return camera;
		}
	}

	pos = self geteye();
	return pos;
}

private draw_node_info( draw_text, node, type )
{
	if ( !draw_text || !level.players[ 0 ] is_player_looking_at( node.origin, 0.9, false ) )
	{
		return;
	}
	offset = ( 0, 0, 0 );
	origin = node.origin;
	print3d( origin + ( 0, 0, 49 ), "ORIGIN:" + origin );
	if ( type == "Begin" )
	{
		print3d( origin + ( 0, 0, 37 ), "ANGLES:" + node.angles );
		print3d( origin + ( 0, 0, 25 ), "ANIMSCRIPT:" + node.animscript );
		if ( isDefined( node.animation ) )
		{
			print3d( origin + ( 0, 0, 13 ), "ANIMATION:" + node.animation );
		}
		if ( isDefined( node.script_noteworthy ) )
		{
			if ( isDefined( node.animation ) )
			{
				offset = ( 0, 0, 1 );
			}
			else
			{
				offset = ( 0, 0, 13 );
			}
			print3d( origin + offset, "SCIRPT_NOTEWORTHY:" + node.script_noteworthy );
		}
	}
}

private draw_node_data( draw_text, node, color, type )
{
	draw_types = level._debug_draw_nodes_types;
	if ( draw_types.size <= 0 )
	{
		return;
	}

	found_type = false;
	for ( i = 0; i < _SIZE( draw_types.size ); i++ )
	{
		if ( draw_types[ i ] == "all" || draw_types[ i ] == tolower( type ) )
		{
			found_type = true;
			break;
		}
	}

	if ( !found_type )
	{
		return;
	}

	draw_node( node.origin, color, type );
	draw_node_info( draw_text, node, type );
}

private draw_trigger_box( origin, mins, maxs, angles, color  )
{
	boxoriented( origin, mins, maxs, angles, color, 1.0 );
}

private draw_trigger_radius( origin, radius, height, angles, segments, color )
{
	cylinder( origin, radius, height, angles, segments, color, 1.0 );
}

private draw_trigger_radius_info( draw_text, origin, radius, height, angles, type, entnum )
{
	if ( !draw_text )
	{
		return;
	}
	//print3d( origin + ( 0, 0, 97 ), "ZONE:" + zone_name );
	print3d( origin + ( 0, 0, 85 ), "ENTNUM: [" + entnum + "]" );
	print3d( origin + ( 0, 0, 73 ), "ANGLES: [" + angles + "]" );
	print3d( origin + ( 0, 0, 61 ), "HEIGHT: [" + height + "]" );
	print3d( origin + ( 0, 0, 49 ), "RADIUS: [" + radius + "]" );
	print3d( origin + ( 0, 0, 37 ), "TYPE: [" + type + "]" );
	print3d( origin + ( 0, 0, 25 ), "ORIGIN: [" + origin + "]" );
}

private draw_trigger_box_info( draw_text, origin, mins, maxs, angles, type, entnum )
{
	if ( !draw_text )
	{
		return;
	}
	//print3d( origin + ( 0, 0, 97 ), "ZONE:" + zone_name );
	print3d( origin + ( 0, 0, 85 ), "ENTNUM: [" + entnum + "]" );
	print3d( origin + ( 0, 0, 73 ), "ANGLES: [" + angles + "]" );
	print3d( origin + ( 0, 0, 61 ), "MAXS: [" + maxs + "]" );
	print3d( origin + ( 0, 0, 49 ), "MINS: [" + mins + "]" );
	print3d( origin + ( 0, 0, 37 ), "TYPE: [" + type + "]" );
	print3d( origin + ( 0, 0, 25 ), "ORIGIN: [" + origin + "]" );
}

private draw_ent_info( draw_text, ent )
{
	if ( !draw_text )
	{
		return;
	}
	//print3d( origin + ( 0, 0, 97 ), "ZONE:" + zone_name );
	print3d( ent.origin + ( 0, 0, 85 ), "ENTNUM: [" + ent getentitynumber() + "]" );
	print3d( ent.origin + ( 0, 0, 73 ), "ANGLES: [" + ent.angles + "]" );
	print3d( ent.origin + ( 0, 0, 61 ), "MAXS: [" + ent getmaxs() + "]" );
	print3d( ent.origin + ( 0, 0, 49 ), "MINS: [" + ent getmins() + "]" );
	print3d( ent.origin + ( 0, 0, 37 ), "TYPE: [" + get_entity_type_name( ent ) + "]" );
	print3d( ent.origin + ( 0, 0, 25 ), "ORIGIN: [" + ent.origin + "]" );
}

private draw_ent_box( ent, color )
{
	origin = ent.origin;
	mins = ent getmins();
	maxs = ent getmaxs();
	angles = ent.angles;
	boxoriented( origin, mins, maxs, angles, color, 1.0 );
}

draw_entities( manual_targets, draw_text )
{
	level endon( "draw_entities_stop" );
	while ( !isDefined( level.zones ) )
	{
		wait 1;
	}

	flag_wait_until_set_once( "initial_blackscreen_passed" );

	for ( ;; )
	{
		wait 0.05;

		if ( !level._debug_draw_entities_enabled )
		{
			continue;
		}

		if ( _ARRAY_VALIDATE( manual_targets ) )
		{
			for ( j = 0; j < _SIZE( manual_targets.size ); j++ )
			{
				ent = manual_targets[ j ];

				if ( !isdefined( ent ) )
				{
					continue;
				}

				draw_ent_info( draw_text, ent );
				draw_ent_box( ent, ( 0.8, 0.8, 0.8 ) );
			}
		}
		else
		{
			for ( i = 0; i < _SIZE( level._debug_draw_entities_types.size ); i++ )
			{
				type = level._debug_draw_entities_types[ i ];
				entities = [[ level._entity_type_funcs[ type ].getter ]]();

				for ( j = 0; j < _SIZE( entities.size ); j++ )
				{
					ent = entities[ j ];

					draw_ent_info( draw_text, ent );
					draw_ent_box( ent, ( 0.8, 0.8, 0.8 ) );
				}
			}
		}
	}
}

//BGScr_Line usage: line( vector<start>, vector<end>, vector[color], float[alpha], bool[depthTest], int[duration] )

// case "polygon":
// 	if ( !isdefined( args[ 2 ] ) )
// 	{
// 		player iPrintLn( "Missing third argument" );
// 		continue;
// 	}

// 	if ( !isdefined( level.linelist[ args[ 2 ] ] ) )
// 	{
// 		player iPrintLn( "Invalid third argument" );
// 		continue;
// 	}

// 	scale = 100.0;
// 	if ( isdefined( args[ 3 ] ) )
// 	{
// 		scale = float( args[ 3 ] );
// 	}

// 	player thread draw_polygon( args[ 2 ], scale );
// 	break;	

// draw_polygon( shape, scale )
// {
// 	points = level.linelist[ shape ];
// 	points_adjusted = [];
// 	foreach ( point in points )
// 	{
// 		point = ( point * scale ) + self.origin;
// 		points_adjusted[ points_adjusted.size ] = point;
// 	}

// 	self thread polygon_thread( points_adjusted );
// }

// polygon_thread( points )
// {
// 	self endon( "disconnect" );

// 	for ( ;; )
// 	{
// 		linelist( points );
// 		wait 0.05;
// 	}
// }