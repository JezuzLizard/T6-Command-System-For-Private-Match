#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\cmd\sv\core\_utility;

// autoexec
#include scripts\zm\cmd\sv\zm_debug_helpers;

#include scripts\zm\cmd\sv\_zm_utility;

add_zm_debug_cmds()
{
	level._debug_zombie_spawn_loc_draw_enabled = false;
	level._debug_zombie_spawn_loc_show_only_active_spawns = false;
	level._debug_zombie_spawn_loc_draw_aitypes = "";
	level._debug_zombie_spawn_loc_draw_text = false;

	cmd_block_set_module_group( "debug_zm" );
	cmd_block_set_rank_group( "cheat" );
	setdoground_cmd = cmd_add( "setdoground", ::cmd_setdoground_f, "setdoground [round]" );
	setdoground_cmd arg_add_optional( 1, "next_dog_round", "int", "Number to set the next dog round to" );

	spawnzombie_cmd = cmd_add( "spawnzombie", ::cmd_spawnzombie_f, "spawnzombie <aitype> [count]" );
	spawnzombie_cmd arg_add_required( 1, "aitype", "string", "Type of AI to spawn" );
	spawnzombie_cmd arg_add_optional_with_default( 2, "count", "int", "Amount of AI to spawn", 1 );

	drawzombiespawnlocations_cmd = cmd_add( "drawzombiespawnlocations", ::cmd_drawzombiespawnlocations_f, "drawzombiespawnlocations <show> [only_active_spawns] [aitypes] [draw_text]" );
	drawzombiespawnlocations_cmd arg_add_required( 1, "show", "boolean", "Toggle displaying zombie spawns" );
	drawzombiespawnlocations_cmd arg_add_optional_with_default( 2, "only_active_spawns", "boolean", "Toggle showing only active spawns(in zones)", true );
	drawzombiespawnlocations_cmd arg_add_optional_with_default( 3, "aitypes", "string", "Aitypes to display spawn locations for", "all" );
	drawzombiespawnlocations_cmd arg_add_optional_with_default( 4, "draw_text", "boolean", "Toggle the additional text info drawn on spawns", true );

	drawzones_cmd = cmd_add( "drawzones", ::cmd_drawzones_f, "drawzones" );

	toggleflag_cmd = cmd_add( "toggleflag", ::cmd_toggleflag_f, "toggleflag <flagname> " );
	toggleflag_cmd arg_add_required( 1, "flagname", "string", "The name of the flag() to toggle" );

	selectdebugzombie_cmd = cmd_add( "selectdebugzombie", ::cmd_selectdebugzombie_f, "selectdebugzombie {actor}" );
	selectdebugzombie_cmd target_add_optional( 1, "zombie", "actor", "Manual actor selector" );

	debugzombie_cmd = cmd_add( "debugzombie", ::cmd_debugzombie_f, "debugzombie [options]" );
	debugzombie_cmd arg_add_required( 1, "info_types", "string", "Types of info to print/render" );

	drawzombietotal_cmd = cmd_add( "drawzombietotal", ::cmd_drawzombietotal_f, "drawzombietotal" );
	drawzombiecurrent_cmd = cmd_add( "drawzombiecurrent", ::cmd_drawzombiecurrent_f, "drawzombiecurrent" );
	drawsph_cmd = cmd_add( "drawsph", ::cmd_drawsph_f, "drawsph" );

	setzombiesanimrate_cmd = cmd_add( "setzombieanimrate", ::cmd_setzombieanimrate_f, "setzombieanimrate <value>" );
}

private cmd_setdoground_f( param )
{
	new_round = _DEFAULT( param.a[ 0 ], level.round_number + 1 );
	level.next_dog_round = new_round;

	param add_executor_cmdinfo( "Next dog round is: " + level.next_dog_round );
}

private cmd_spawnzombie_f( param )
{
	aitype = param.a[ 0 ];
	count = _DEFAULT( param.a[ 1 ], 1 );
	count = _CLAMP( count, 1, 16 );

	for ( i = 0; i < count; i++ )
	{
		if ( aitype == "mechz" )
		{
			level.mechz_left_to_spawn = 1;
			level notify( "spawn_mechz" );
		}
		else if ( aitype == "brutus" )
		{
			level notify( "spawn_brutus", 1 );
		}
	}
}

private cmd_drawzombiespawnlocations_f( param )
{
	was_on = level._debug_zombie_spawn_loc_draw_enabled;
	level._debug_zombie_spawn_loc_draw_enabled = param.a[ 0 ];
	level._debug_zombie_spawn_loc_show_only_active_spawns = _DEFAULT( param.a[ 1 ], true );
	level._debug_zombie_spawn_loc_draw_aitypes = _DEFAULT( param.a[ 2 ], "all" );
	level._debug_zombie_spawn_loc_draw_text = _DEFAULT( param.a[ 3 ], true );

	if ( was_on && !level._debug_zombie_spawn_loc_draw_enabled )
	{
		level._debug_zombie_spawn_loc_draw_enabled = false;
		level notify( "draw_zombie_spawn_locations_stop" );

		return param add_executor_cmdinfo( "Stopped drawing zombie locations" );
	}

	if ( !was_on && level._debug_zombie_spawn_loc_draw_enabled )
	{
		level thread draw_zombie_spawn_locations();
		return param add_executor_cmdinfo( "Started drawing zombie locations" );
	}
}

private cmd_drawzones_f( param )
{
	self._debug_draw[ "zones" ] = !is_true( self._debug_draw[ "zones" ] );

	on_off = cast_bool_to_str( self._debug_draw[ "zones" ], "Started Stopped" );
	return param add_executor_cmdinfo( on_off + " drawing your active zone" );
}

private cmd_toggleflag_f( param )
{
	flagname = param.a[ 0 ];

	exists = level flag_exists( flagname );
	if ( !exists )
	{
		return param add_executor_cmderror( "Flagname '" + flagname + "' does not exist" );
	}

	level flag_toggle( flagname );
	on_off = cast_bool_to_str( flag( flagname ), "on off" );
	param add_executor_cmdinfo( "Successfully toggled '" + flagname + "' '" + on_off + "'" );
}

private cmd_selectdebugzombie_f( param )
{
	entity = param.t[ 0 ][ 0 ];
	if ( !isdefined( entity ) )
	{
		trace = self cast_entity_raycast_from_player_eye();
		entity = trace[ "entity" ];
		if ( !isdefined( entity ) )
		{
			return param add_executor_cmderror( "Not looking at an entity!" );
		}
	}

	if ( !isdefined( self._debug_zombie ) )
	{
		self._debug_zombie = undefined;
	}
	else
	{
		level notify( "draw_debug_zombie_info_stop" );
	}

	self._debug_zombie = entity;
	self thread draw_debug_zombie_info();
}

private cmd_debugzombie_f( param )
{
	types = param.a[ 0 ];
	if ( !isdefined( self._debug_zombie ) )
	{
		return param add_executor_cmderror( "You must execute selectdebugzombie first before using this command!" );
	}

	types_array = strtok( types, "|" );

	target = self._debug_zombie;
	for ( i = 0; i < _SIZE( types_array.size ); i++ )
	{
		type = types_array[ i ];
		switch ( type )
		{
			case "attack_anim":
				target._draw_attack_anim_info = !is_true( target._draw_attack_anim_info );
				break;
			case "move_anim":
				target._draw_move_anim_info = !is_true( target._draw_move_anim_info );
				break;
			case "health":
				target._draw_health_info = !is_true( target._draw_health_info );
				break;
			case "target":
				target._draw_target_info = !is_true( target._draw_target_info );
				break;
			case "attack_range":
				target._draw_attack_range_info = !is_true( target._draw_attack_range_info );
				break;
			case "melee_damage":
				target._draw_melee_damage_info = !is_true( target._draw_melee_damage_info );
				break;
			case "aitype":
				target._draw_aitype_info = !is_true( target._draw_aitype_info );
				break;
			case "print_anim_timings":
				target._print_anim_timings = !is_true( target._print_anim_timings );
				break;
		}
	}
}

private cmd_drawzombietotal_f( param )
{

}

private cmd_drawzombiecurrent_f( param )
{

}

private cmd_drawsph_f( param )
{

}

private cmd_setzombieanimrate_f( param )
{

}