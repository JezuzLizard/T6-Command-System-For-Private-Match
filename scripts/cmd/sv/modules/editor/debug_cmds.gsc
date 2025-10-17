#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;
#include scripts\cmd\sv\modules\editor\debug_helpers;

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
	level._debug_draw_triggers_types = [];

	level._debug_draw_nodes_enabled = false;
	level._debug_draw_nodes_types = [];

	level._debug_draw_entities_enabled = false;
	level._debug_draw_entities_types = [];

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

	cmd_add( "drawtriggers", ::cmd_drawtriggers_f, "drawtriggers <types> [draw_text]" );
	arg_add_required( 1, "trigger_type", "triggertype", "Trigger types to draw" );
	arg_add_optional_with_default( 2, "draw_text", "boolean", "Toggle the additional text info drawn on triggers", true );

	cmd_add( "drawnodes", ::cmd_drawnodes_f, "drawnodes <types> [draw_text]" );
	arg_add_required( 1, "node_type", "nodetype", "Trigger types to draw" );
	arg_add_optional_with_default( 2, "draw_text", "boolean", "Toggle the additional text info drawn on nodes", true );

	cmd_add( "drawlocation", ::cmd_drawlocation_f, "drawlocation" );

	cmd_add( "drawentities", ::cmd_drawentities_f, "drawentities {explicit_entities} [enttypes] [draw_text]" );
	arg_add_optional( 1, "ent_type", "enttype", "Types of entities to draw" );
	arg_add_optional_with_default( 2, "draw_text", "boolean", "Toggle the additional text info drawn on entities", true );
	target_add_optional( 1, "entity", "general", "Explicit entities to draw" );
}

private cmd_drawtriggers_f( param )
{
	was_on = level._debug_draw_triggers_enabled;
	level._debug_draw_triggers_types = param.a[ 0 ];
	draw_text = param.a[ 1 ];
	level._debug_draw_triggers_enabled = level._debug_draw_triggers_types[ 0 ] != "none";

	if ( was_on && !level._debug_draw_triggers_enabled )
	{
		level._debug_draw_triggers_enabled = false;
		level notify( "draw_triggers_stop" );

		return param add_executor_cmdinfo( "Stopped drawing triggers" );
	}

	if ( !was_on && level._debug_draw_triggers_enabled )
	{
		level thread draw_triggers( draw_text );
		return param add_executor_cmdinfo( "Started drawing triggers" );
	}
}

private cmd_drawnodes_f( param )
{
	was_on = level._debug_draw_nodes_enabled;
	level._debug_draw_nodes_types = param.a[ 0 ];
	draw_text = param.a[ 1 ];
	level._debug_draw_nodes_enabled = level._debug_draw_nodes_types[ 0 ] != "none";

	if ( was_on && !level._debug_draw_nodes_enabled )
	{
		level._debug_draw_nodes_enabled = false;
		level notify( "draw_nodes_stop" );

		return param add_executor_cmdinfo( "Stopped drawing nodes" );
	}

	if ( !was_on && level._debug_draw_nodes_enabled )
	{
		level thread draw_nodes( draw_text );
		return param add_executor_cmdinfo( "Started drawing nodes" );
	}
}

private cmd_drawlocation_f( param )
{
	self._debug_draw_location_enabled = !is_true( self._debug_draw_location_enabled );

	on_off = cast_bool_to_str( !is_true( self._debug_draw_location_enabled ), "Started Stopped" );
	return param add_executor_cmdinfo( on_off + " drawing your location" );
}

private cmd_drawentities_f( param )
{
	manual_targets = param.t[ 0 ];
	was_on = level._debug_draw_entities_enabled;
	level._debug_draw_entities_types = param.a[ 0 ];
	draw_text = param.a[ 1 ];
	if ( !array_validate( manual_targets ) && !array_validate( level._debug_draw_entities_types ) )
	{
		return param add_executor_cmderror( "This command requires either a target specifier or a list of enttypes" );
	}

	level._debug_draw_entities_enabled = array_validate( manual_targets ) || level._debug_draw_entities_types[ 0 ] != "none";

	if ( was_on && !level._debug_draw_entities_enabled )
	{
		level._debug_draw_entities_enabled = false;
		level notify( "draw_entities_stop" );

		return param add_executor_cmdinfo( "Stopped drawing entities" );
	}

	if ( !was_on && level._debug_draw_entities_enabled )
	{
		level thread draw_entities( manual_targets, draw_text );
		return param add_executor_cmdinfo( "Started drawing entities" );
	}
}