#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;
#include scripts\cmd\sv\core\_api_hud;
#include scripts\cmd\sv\core\_utility_hud;

init_path_helpers()
{
	level._debug_draw_custom_pathnodes_enabled = false;
	level._debug_draw_custom_pathnodes_draw_text = false;
	level._debug_draw_custom_pathnodes_filters = "";
}

get_custom_pathnode_by_id( id )
{
	return level._mapents[ "path_nodes" ][ id ];
}

private draw_node_box( origin, color, vec )
{
	vec = _DEFAULT( vec, ( 20, 20, 20 ) );
	box( origin + ( 0, 0, 20 ), vec * -1, vec, 0, color, 1.0 );
}

private draw_print3d_vertical_list( node, start_offset, decrement )
{
	keys = getarraykeys( node.keys );
	z_offset = start_offset;
	origin = node.keys[ "origin" ];
	for ( i = 0; i < _SIZE( keys.size ); i++ )
	{
		key_name = toupper( keys[ i ] );
		value = node.keys[ keys[ i ] ];
		print3d( origin + z_offset, key_name + ": " + value );
		z_offset -= decrement;
	}
}

private draw_node_info( node )
{
	if ( !level.players[ 0 ] is_player_looking_at( node.origin, 0.9, false ) )
	{
		return;
	}

	draw_print3d_vertical_list( node, ( 0, 0, 49 ), ( 0, 0, 13 ) );
}

draw_custom_pathnodes()
{
	level notify( "stop_drawing_nodes" );
	level endon( "stop_drawing_nodes" );

	for ( ;; )
	{
		wait 0.05;

		if ( !level._debug_draw_custom_pathnodes_enabled )
		{
			continue;
		}

		for ( i = 0; i < _SIZE( level._mapents[ "path_nodes" ].size ); i++ )
		{
			node = level._mapents[ "path_nodes" ][ i ];
			if ( !isdefined( node ) || !isdefined( node.keys[ "origin" ] ) )
			{
				continue;
			}

			color = _DEFAULT( node.keys[ "color" ], ( 1, 1, 1 ) );
			if ( node == self._selected_pathnode )
			{
				color = ( 0.6, 0.8, 0.2 );
			}
			
			origin = self._selected_pathnode.origin;
			draw_node_box( origin, color );
			if ( level._debug_draw_custom_pathnodes_draw_text )
			{
				draw_node_info( node );
			}
		}
	}
}

generate_pathnode_for_mapents( keys )
{
	pathnode = new_mapent_struct();
	pathnode.keys = keys;
	add_mapent_entity( pathnode, "path_nodes", pathnode.keys[ "id" ] );
}