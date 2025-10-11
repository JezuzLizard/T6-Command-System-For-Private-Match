#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\game_shared\sv\core\_utility;
#include scripts\cmd\game_shared\sv\modules\debug_helpers;

add_debug_cmds()
{
	level.linelist = [];
	level.linelist[ "cube" ] = array( (0, 0, 0), (1, 0, 0), (1, 1, 0), (0, 1, 0), (0, 0, 0), 
									  (0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1), (0, 0, 1), 
									  (1, 0, 1), (1, 0, 0), (1, 1, 0), (1, 1, 1), (0, 1, 1), 
									  (0, 1, 0) );

	level.linelist[ "tetrahedron" ] = array( (0, 0, 0), (1, 0, 0), (0.5, 0.866, 0), (0.5, 0.2887, 0.816), 
											 (0, 0, 0), (0.5, 0.866, 0), (0.5, 0.2887, 0.816), (1, 0, 0) );

	level.linelist[ "pyramid" ] = array( (0, 0, 0), (1, 0, 0), (1, 1, 0), (0, 1, 0), (0, 0, 0), 
										 (0.5, 0.5, 1), (1, 0, 0), (0.5, 0.5, 1), (1, 1, 0), 
										 (0.5, 0.5, 1), (0, 1, 0), (0.5, 0.5, 1) );

	level.linelist[ "octahedron" ] = array( (0, 0, 0), (1, 0, 0), (0.5, 0.866, 0), (0.5, 0.2887, 1), 
											(0, 0, 0), (0.5, 0.2887, -1), (1, 0, 0), (0.5, 0.2887, -1), 
											(0.5, 0.866, 0), (0.5, 0.2887, 1) );

	level.linelist[ "prism" ] = array( (0, 0, 0), (1, 0, 0), (0.5, 0.866, 0), (0, 0, 0), 
									   (0, 0, 1), (1, 0, 1), (0.5, 0.866, 1), (0, 0, 1), 
									   (1, 0, 1), (1, 0, 0), (0.5, 0.866, 0), (0.5, 0.866, 1) );

	level._debug_draw_triggers_enabled = false;
	level._debug_draw_trigger_types = "";

	level._debug_draw_nodes_enabled = false;
	level._debug_draw_nodes_types = "";

	level.script = getdvar( "mapname" );

	y = -119;
	if ( level.script == "zm_buried" )
	{
		y -= 25;
	}
	else if ( level.script == "zm_tomb" )
	{
		y -= 60;
	}
	level.debug_hud_y_offset = y;

	drawtriggers_cmd = cmd_add( "drawtriggers", ::cmd_drawtriggers_f, "drawtriggers <types>" );
	drawtriggers_cmd arg_add_required( 1, "types", "string", "Trigger types to draw" );

	drawnodes_cmd = cmd_add( "drawnodes", ::cmd_drawnodes_f, "drawnodes <types>" );
	drawnodes_cmd arg_add_required( 1, "types", "string", "Trigger types to draw" );

	drawlocation_cmd = cmd_add( "drawlocation", ::cmd_drawlocation_f, "drawlocation" );
}

private cmd_drawtriggers_f( param )
{
	was_on = level._debug_draw_triggers_enabled;
	level._debug_draw_trigger_types = param.a[ 0 ];
	level._debug_draw_triggers_enabled = level._debug_draw_trigger_types != "";

	if ( was_on && !level._debug_draw_triggers_enabled )
	{
		level._debug_draw_triggers_enabled = false;
		level notify( "draw_triggers_stop" );

		return param add_executor_cmdinfo( "Stopped drawing triggers" );
	}

	if ( !was_on && level._debug_draw_triggers_enabled )
	{
		level thread draw_triggers();
		return param add_executor_cmdinfo( "Started drawing triggers" );
	}
}

private cmd_drawnodes_f( param )
{
	was_on = level._debug_draw_nodes_enabled;
	level._debug_draw_nodes_types = param.a[ 0 ];
	level._debug_draw_nodes_enabled = level._debug_draw_nodes_types != "";

	if ( was_on && !level._debug_draw_nodes_enabled )
	{
		level._debug_draw_nodes_enabled = false;
		level notify( "draw_nodes_stop" );

		return param add_executor_cmdinfo( "Stopped drawing nodes" );
	}

	if ( !was_on && level._debug_draw_nodes_enabled )
	{
		level thread draw_nodes();
		return param add_executor_cmdinfo( "Started drawing nodes" );
	}
}

private cmd_drawlocation_f( param )
{
	self._debug_draw_location_enabled = !is_true( self._debug_draw_location_enabled );

	on_off = cast_bool_to_str( !is_true( self._debug_draw_location_enabled ), "Started Stopped" );
	return param add_executor_cmdinfo( on_off + " drawing your location" );
}