#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\cmd\core\_utility;

// autoexec
#include scripts\zm\cmd\modules\_zm_consts;
#include scripts\zm\cmd\modules\zm_debug_helpers;

#include scripts\zm\cmd\modules\_utility;

autoexec add_zm_debug_cmds()
{
	level._debug_zombie_spawn_loc_draw_enabled = false;
	level._debug_zombie_spawn_loc_show_only_active_spawns = false;
	level._debug_zombie_spawn_loc_draw_aitypes = "";
	level._debug_zombie_spawn_loc_draw_text = false;

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
	self._debug_draw_zones_enabled = !is_true( self._debug_draw_zones_enabled );

	on_off = cast_bool_to_str( self._debug_draw_zones_enabled, "Started Stopped" );
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