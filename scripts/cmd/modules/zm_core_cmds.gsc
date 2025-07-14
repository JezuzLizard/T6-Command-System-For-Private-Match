#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include scripts\cmd\core\_utility;

// autoexec
#include scripts\cmd\modules\_zm_consts;
#include scripts\cmd\modules\zm_core_helpers;

autoexec add_cmds()
{
	cmd_block_set_module_group( "core_zm" );
	cmd_block_set_rank_group( "cheat" );
	spectator_cmd = cmd_add( "spectator", ::cmd_spectator_f, "spectator {player}" );
	spectator_cmd target_obj_add_cmd( "player" );
	
	togglerespawn_cmd = cmd_add( "togglerespawn", ::cmd_togglerespawn_f, "togglerespawn {player}" );
	togglerespawn_cmd target_obj_add_cmd( "player" );

	killactors_cmd = cmd_add( "killactors", ::cmd_killactors_f, "killactors {actor}" );
	killactors_cmd target_obj_add_cmd( "player" );

	respawnspectators_cmd = cmd_add( "respawnspectators", ::cmd_respawnspectators_f, "respawnspectators {player}" );
	respawnspectators_cmd target_obj_add_cmd( "player" );

	pause_cmd = cmd_add( "pause", ::cmd_pause_f, "pause [minutes]" );
	pause_cmd arg_obj_add_cmd( "natural_int", 0, 1 );

	unpause_cmd = cmd_add( "unpause", ::cmd_unpause_f );
	unpause_cmd arg_obj_add_cmd( "", 0, 0 );

	giveperk_cmd = cmd_add( "giveperk", ::cmd_giveperk_f, "giveperk {player} <perk|all>" );
	giveperk_cmd arg_obj_add_cmd( "player perk", 1, 2 );
	giveperk_cmd target_obj_add_cmd( "player" );

	takeperk_cmd = cmd_add( "takeperk", ::cmd_takeperk_f, "takeperk {player} <perk|all>" );
	takeperk_cmd arg_obj_add_cmd( "player perk", 1, 2 );
	takeperk_cmd target_obj_add_cmd( "player" );

	givepermaperk_cmd = cmd_add( "givepermaperk", ::cmd_givepermaperk_f, "givepermaperk {player} <permaperk|all>" );
	givepermaperk_cmd arg_obj_add_cmd( "player permaperk", 1, 2 );
	givepermaperk_cmd target_obj_add_cmd( "player" );

	givepoints_cmd = cmd_add( "points", ::cmd_givepoints_f, "points {player} <amount>" );
	givepoints_cmd arg_obj_add_cmd( "player int", 1, 2 );
	givepoints_cmd target_obj_add_cmd( "player" );

	givepowerup_cmd = cmd_add( "powerup", ::cmd_givepowerup_f, "powerup {player} <powerup>" );
	givepowerup_cmd arg_obj_add_cmd( "player powerup", 1, 2 );
	givepowerup_cmd target_obj_add_cmd( "player" );

	giveweapon_cmd = cmd_add( "weapon", ::cmd_giveweapon_f, "weapon {player} <weapon>" );
	giveweapon_cmd arg_obj_add_cmd( "player weapon", 1, 2 );
	giveweapon_cmd target_obj_add_cmd( "player" );

	toggleperssystemforplayer_cmd = cmd_add( "toggleperssystemforplayer", ::cmd_toggleperssystemforplayer_f, "toggleperssystemforplayer {player}" );
	toggleperssystemforplayer_cmd target_obj_add_cmd( "player" );

	toggleoutofplayableareamonitor_cmd = cmd_add( "toggleoutofplayableareamonitor", ::cmd_toggleoutofplayableareamonitor_f );

	openalldoors_cmd = cmd_add( "openalldoors", ::cmd_openalldoors_f );

	setround_cmd = cmd_add( "setround", ::cmd_setround_f, "setround <round_number>" );
	setround_cmd arg_obj_add_cmd( "round", 1, 1 );

	nextround_cmd = cmd_add( "nextround", ::cmd_nextround_f );

	prevround_cmd = cmd_add( "prevround", ::cmd_prevround_f );

	setglobalzombiestat_cmd = cmd_add( "setglobalzombiestat", ::cmd_setglobalzombiestat_f, "setglobalzombiestat <statname> <value>" );
	setglobalzombiestat_cmd arg_obj_add_cmd( "string string", 2, 2 );

	listglobalzombiestats_cmd = cmd_add( "listglobalzombiestats", ::cmd_listglobalzombiestats_f );

	setallphysparams_cmd = cmd_add( "setallphysparams", ::cmd_setallphysparams_f, "setallphysparams {actor} <vector>" );
	setallphysparams_cmd arg_obj_add_cmd( "actor vector", 1, 2 );

	cmd_block_set_rank_group( "none" );
	weaponlist_cmd = cmd_add( "weaponlist", ::cmd_weaponlist_f );

	poweruplist_cmd = cmd_add( "poweruplist", ::cmd_poweruplist_f );

	perklist_cmd = cmd_add( "perklist", ::cmd_perklist_f );
}

cmd_spectator_f( target_obj, args )
{
	target = args[ 0 ];
	target spawnspectator();
	if ( !isDefined( target.tcs_original_respawn ) )
	{
		target.tcs_original_respawn = target.spectator_respawn;
	}
	target.spectator_respawn = undefined;

	return result_cmdinfo( "Successfully made " + target.name + " a spectator" );
}

cmd_togglerespawn_f( target_obj, args )
{
	target = args[ 0 ];
	should_respawn = args[ 1 ];
	currently_respawning = isDefined( target.spectator_respawn );
	if ( !isDefined( target.tcs_original_respawn ) )
	{
		target.tcs_original_respawn = target.spectator_respawn;
	}
	if ( currently_respawning )
	{
		target.spectator_respawn = undefined;
	}
	else 
	{
		target.spectator_respawn = target.tcs_original_respawn;
	}

	return result_cmdinfo( target.name + " has their respawn toggled" );
}

cmd_killactors_f( target_obj, args )
{
	ai = getaiarray( level.zombie_team );
	for ( i = 0; i < ai.size; i++ )
	{
		zombie = ai[ i ];
		if ( isdefined( zombie ) )
		{
			zombie dodamage( zombie.health + 666, zombie.origin );
		}
	}

	return result_cmdinfo( "Killed all zombies" );
}

cmd_respawnspectators_f( target_obj, args )
{
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ].sessionstate == "spectator" && isDefined( players[ i ].spectator_respawn ) )
		{
			players[ i ] [[ level.spawnplayer ]]();
			thread refresh_player_navcard_hud();

			if ( isDefined( level.script ) && level.round_number > 6 && players[ i ].score < 1500 )
			{
				players[ i ].old_score = players[ i ].score;

				if ( isDefined( level.spectator_respawn_custom_score ) )
					players[ i ] [[ level.spectator_respawn_custom_score ]]();

				players[ i ].score = 1500;
			}
		}
	}

	return result_cmdinfo( "Successfully respawned all spectators" );
}

// TODO: stop the zombies from dying due to g_ai preventing movement
cmd_pause_f( target_obj, args )
{
	if ( isDefined( args[ 0 ] ) )
	{
		duration = args[ 0 ];
		level thread game_pause( duration );
		return result_cmdinfo( "Game paused for " + duration + " minutes" );
	}
	else 
	{
		level thread game_pause( -1 );
		return result_cmdinfo( "Game paused indefinitely use unpause to end the pause" );
	}
}

cmd_unpause_f( target_obj, args )
{
	game_unpause();

	return result_cmdinfo( "Game unpaused" );
}

cmd_giveperk_f( target_obj, args )
{
	target = arg_list[ 0 ];
	perk_name = arg_list[ 1 ];
	if ( perk_name != "all" )
	{
		target give_perk_zm( perk_name );
		return result_cmdinfo( "Gave perk " + perk_name + " to " + target.name );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			target give_perk_zm( perk );
		}

		return result_cmdinfo( "Gave all perks to " + target.name );
	}
}

cmd_takeperk_f( target_obj, args )
{
	target = arg_list[ 0 ];
	perk_name = arg_list[ 1 ];
	if ( perk_name != "all" )
	{
		target notify( perk_name + "_stop" );
		return result_cmdinfo( "Took perk " + perk_name + " from " + target.name );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			target notify( perk + "_stop" );
		}

		return result_cmdinfo( "Took all perks from " + target.name );
	}
}

cmd_givepermaperk_f( target_obj, args )
{
	result = [];
	target = args[ 0 ];
	perma_perk_name = args[ 1 ];
	if ( perma_perk_name != "all" )
	{
		target give_perma_perk( perma_perk_name );
		return result_cmdinfo( "Gave " + target.name + " " + perma_perk_name );
	}
	else
	{
		target give_all_perma_perks();
		return result_cmdinfo( "Gave all perma perks to " + target.name );
	}
}

cmd_givepoints_f( target_obj, args )
{
	target = args[ 0 ];
	points = args[ 1 ];
	target add_to_player_score( points );

	return result_cmdinfo( "Gave " + target.name + " " + points + " points" );
}

cmd_givepowerup_f( target_obj, args )
{
	target = arg_list[ 0 ];
	powerup_name = arg_list[ 1 ];
	success = target give_powerup_zm( powerup_name );
	if ( success )
	{
		return result_cmdinfo( "Spawned " + powerup_name + " for " + target.name );
	}
}

cmd_giveweapon_f( target_obj, args )
{
	target = args[ 0 ];
	weapon = args[ 1 ];
	target thread weapon_give_custom( weapon, weapon_is_upgrade( weapon ), true );

	return result_cmdinfo( "Gave " + weapon + " to " + target.name );
}

cmd_toggleperssystemforplayer_f( target_obj, args )
{
	target = args[ 0 ];
	on_off = scripts\cmd_system_modules\_cmd_arg::cast_bool_to_str( is_true( target.tcs_disable_pers_system ), "on off" );
	target.tcs_disable_pers_system = !is_true( target.tcs_disable_pers_system );

	return result_cmdinfo( "Toggled pers system for " + target.name + " " + on_off );
}

cmd_toggleoutofplayableareamonitor_f( target_obj, args )
{
	on_off = scripts\cmd_system_modules\_cmd_arg::cast_bool_to_str( !is_true( level.player_out_of_playable_area_monitor ), "on off" );
	level.player_out_of_playable_area_monitor = !level.player_out_of_playable_area_monitor;
	if ( on_off == "on" )
	{
		foreach ( player in level.players )
		{
			player thread player_out_of_playable_area_monitor();
		}
	}
	else 
	{
		foreach ( player in level.players )
		{
			player notify( "stop_player_out_of_playable_area_monitor" );
		}
	}

	return result_cmdinfo( "Out of playable area monitor " + on_off );
}

cmd_openalldoors_f( target_obj, args )
{
	if ( is_true( level.tcs_doors_all_opened ) )
	{
		return result_cmdinfo( "All doors are already open" );
	}
	level thread open_seseme();

	return result_cmdinfo( "All doors are now open" );
}

cmd_setround_f( target_obj, args )
{
	if ( args[ 0 ] > 255 || args[ 0 ] < 0 )
	{
		return result_cmdinfo( "Cannot set round to a number greater than 255 or less than 0" );
	}

	level.round_number = args[ 0 ];
	change_round( args[ 0 ] );

	return result_cmdinfo( "Round set to " + args[ 0 ] );
}

cmd_nextround_f( target_obj, args )
{
	level.round_number++;
	change_round( level.round_number );

	return result_cmdinfo( "Round set to " + level.round_number );
}

cmd_prevround_f( target_obj, args )
{
	level.round_number--;
	change_round( level.round_number );

	return result_cmdinfo( "Round set to " + level.round_number );
}

cmd_setglobalzombiestat_f( target_obj, args )
{
	result = [];
	stat_name = args[ 0 ];
	stat = level.tcs_modifiable_zombie_stats[ stat_name ];
	if ( !isDefined( stat ) )
	{
		return result_cmderror( "1Invalid zombie stat " + stat_name + ", use listglobalzombiestats to see modifiable stats" );
	}

	value = args[ 1 ];
	
	if ( value == "reset" )
	{
		if ( !set_global_zombie_stat( stat, stat_name, stat.reset_value ) )
		{
			return result_cmderror( "2Invalid zombie stat " + stat_name + " , use listglobalzombiestats to see modifiable stats" );
		}
		return result_cmdinfo( "Successfully reset " + stat_name + " to its original value" );
	}

	if ( isDefined( level.tcs_arg_type_handlers[ stat.type ] ) )
	{
		casted_value = self [[ level.tcs_arg_type_handlers[ stat.type ].cast_func ]]( value );

		if ( !set_global_zombie_stat( stat, stat_name, casted_value ) )
		{
			return result_cmderror( "3Invalid zombie stat " + stat_name + " , use listglobalzombiestats to see modifiable stats" );
		}

		return result_cmdinfo( "Successfully set " + stat_name + " to " + value );
	}

	return result_cmderror( "Expected positive_int or positive_float, got: " + value );
}

cmd_listglobalzombiestats_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	self thread list_zombie_stats_throttled( channel );
	return result_cmderror( "" );
}

cmd_setallphysparams_f( target_obj, args )
{
	phys_params = args[ 0 ];

	zombies = get_round_enemy_array();

	foreach ( zombie in zombies )
	{
		zombie setphysparams( phys_params[ 0 ], phys_params[ 1 ], phys_params[ 2 ] );
	}

	return result_cmdinfo( "Set all zombies phys params to " + phys_params );
}

cmd_weaponlist_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	weapons = getArrayKeys( level.zombie_include_weapons );
	self thread list_weapons_throttled( channel, weapons );
	return result_cmdinfo( "" );
}

cmd_poweruplist_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	powerups = getarraykeys( level.zombie_include_powerups );
	self thread list_powerups_throttled( channel, powerups );

	return result_cmdinfo( "" );
}

cmd_perklist_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	perks = perk_list_zm();
	self thread list_perks_throttled( channel, perks );

	return result_cmdinfo( "" );
}