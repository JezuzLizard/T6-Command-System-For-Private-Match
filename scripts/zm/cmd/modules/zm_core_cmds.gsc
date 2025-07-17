#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\cmd\core\_utility;

#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weapons;

// autoexec
#include scripts\zm\cmd\modules\_zm_consts;
#include scripts\zm\cmd\modules\zm_core_helpers;


#include scripts\zm\cmd\modules\_utility;

autoexec add_cmds()
{
	waittillframeend;
	cmd_block_set_module_group( "core_zm" );
	cmd_block_set_rank_group( "cheat" );
	spectator_cmd = cmd_add( "spectator", ::cmd_spectator_f, "spectator {player}" );
	spectator_cmd target_type_add_cmd( "player", true, "Player to force into spectate state" );
	
	togglerespawn_cmd = cmd_add( "togglerespawn", ::cmd_togglerespawn_f, "togglerespawn {player}" );
	togglerespawn_cmd target_type_add_cmd( "player", false, "Player to disable respawning for" );

	killactors_cmd = cmd_add( "killactors", ::cmd_killactors_f, "killactors {actor_targets}" );
	killactors_cmd target_type_add_cmd( "actor", false, "Actor to kill" );

	respawnspectators_cmd = cmd_add( "spawnspectator", ::cmd_spawnspectator_f, "spawnspectator {player}" );
	respawnspectators_cmd target_type_add_cmd( "player", false, "Spectators to respawn" );

	pause_cmd = cmd_add( "pause", ::cmd_pause_f, "pause [minutes]" );
	pause_cmd arg_obj_add_cmd( "natural_int", 0, 1 );

	unpause_cmd = cmd_add( "unpause", ::cmd_unpause_f );
	unpause_cmd arg_obj_add_cmd( "", 0, 0 );

	giveperk_cmd = cmd_add( "perk", ::cmd_perk_f, "perk <perk|all>" );
	giveperk_cmd arg_obj_add_cmd( "perk", 1, 1 );
	giveperk_cmd executor_obj_add_cmd( "Player to give a perk to" );

	takeperk_cmd = cmd_add( "takeperk", ::cmd_takeperk_f, "takeperk <perk|all>" );
	takeperk_cmd arg_obj_add_cmd( "perk", 1, 1 );
	takeperk_cmd executor_obj_add_cmd( "Player to take a perk from" );

	givepermaperk_cmd = cmd_add( "permaperk", ::cmd_permaperk_f, "permaperk <permaperk|all>" );
	givepermaperk_cmd arg_obj_add_cmd( "permaperk", 1, 1 );
	givepermaperk_cmd executor_obj_add_cmd( "Player to give a perma perk to" );

	givepoints_cmd = cmd_add( "points", ::cmd_points_f, "points <amount>" );
	givepoints_cmd arg_obj_add_cmd( "int", 1, 1 );
	givepoints_cmd executor_obj_add_cmd( "Player to give points to" );

	givepowerup_cmd = cmd_add( "powerup", ::cmd_powerup_f, "powerup <powerup>" );
	givepowerup_cmd arg_obj_add_cmd( "powerup", 1, 1 );
	givepowerup_cmd executor_obj_add_cmd( "Player to give a powerup to" );

	giveweapon_cmd = cmd_add( "weapon", ::cmd_weapon_f, "weapon <weapon>" );
	giveweapon_cmd arg_obj_add_cmd( "weapon", 1, 1 );
	giveweapon_cmd executor_obj_add_cmd( "Player to give a weapon to" );

	toggleperssystemforplayer_cmd = cmd_add( "toggleperssystemforplayer", ::cmd_toggleperssystemforplayer_f, "toggleperssystemforplayer" );
	toggleperssystemforplayer_cmd executor_obj_add_cmd( "Player to toggle the perma perks system for" );

	toggleoutofplayableareamonitor_cmd = cmd_add( "toggleoutofplayableareamonitor", ::cmd_toggleoutofplayableareamonitor_f );

	openalldoors_cmd = cmd_add( "openalldoors", ::cmd_openalldoors_f );

	setround_cmd = cmd_add( "setround", ::cmd_setround_f, "setround <round_number>" );
	setround_cmd arg_obj_add_cmd( "positive_int", 1, 1 );

	nextround_cmd = cmd_add( "nextround", ::cmd_nextround_f );

	prevround_cmd = cmd_add( "prevround", ::cmd_prevround_f );

	setglobalzombiestat_cmd = cmd_add( "setglobalzombiestat", ::cmd_setglobalzombiestat_f, "setglobalzombiestat <statname> <value>" );
	setglobalzombiestat_cmd arg_obj_add_cmd( "string string", 2, 2 );

	listglobalzombiestats_cmd = cmd_add( "listglobalzombiestats", ::cmd_listglobalzombiestats_f );

	setallphysparams_cmd = cmd_add( "setallphysparams", ::cmd_setallphysparams_f, "setallphysparams {actor} <vector>" );
	setallphysparams_cmd arg_obj_add_cmd( "vector", 1, 1 );
	setallphysparams_cmd target_type_add_cmd( "actor", false, "Actor to modify phys params for" );

	cmd_block_set_rank_group( "none" );
	weaponlist_cmd = cmd_add( "weaponlist", ::cmd_weaponlist_f );

	poweruplist_cmd = cmd_add( "poweruplist", ::cmd_poweruplist_f );

	perklist_cmd = cmd_add( "perklist", ::cmd_perklist_f );
}

cmd_spectator_f( param )
{
	result = result_cmdinfo( "" );
	targets = param.t[ 0 ];

	for ( i = 0; i < targets.size; i++ )
	{
		target = targets[ i ];
		target spawnspectator();
		if ( !isDefined( target.tcs_original_respawn ) )
		{
			target.tcs_original_respawn = target.spectator_respawn;
		}
		target.spectator_respawn = undefined;

		add_result_executor_msg( result, "Successfully made " + target.name + " a spectator" );
		add_result_player_msg( result, target, "You are now a spectator" );
	}

	result.msg = "Made '" + targets.size + "' players into spectators";

	return result;
}

cmd_togglerespawn_f( param )
{
	result = result_cmdinfo( "" );
	targets = param.t[ 0 ];

	for ( i = 0; i < targets.size; i++ )
	{
		target = targets[ i ];
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

		add_result_executor_msg( result, target.name + " has their respawn toggled" );
		add_result_player_msg( result, target, "You will no longer respawn" );
	}

	result.msg = "Disable respawning for '" + targets.size + "' players";

	return result;
}

cmd_killactors_f( param )
{
	targets = param.t[ 0 ];
	if ( !isdefined( targets ) )
	{
		targets = getaiarray( level.zombie_team );
	}
	for ( i = 0; i < targets.size; i++ )
	{
		zombie = targets[ i ];
		if ( isdefined( zombie ) )
		{
			zombie dodamage( zombie.health + 666, zombie.origin );
		}
	}

	return result_cmdinfo( "Killed all zombies" );
}

cmd_spawnspectator_f( param )
{
	result = result_cmdinfo( "" );
	targets = param.t[ 0 ];

	if ( !isdefined( targets ) )
	{
		targets = level.players;
	}

	respawn_count = 0;
	for ( i = 0; i < targets.size; i++ )
	{
		player = targets[ i ];
		if ( player.sessionstate == "spectator" && isDefined( player.spectator_respawn ) )
		{
			player [[ level.spawnplayer ]]();
			thread refresh_player_navcard_hud();

			if ( isDefined( level.script ) && level.round_number > 6 && player.score < 1500 )
			{
				player.old_score = player.score;

				if ( isDefined( level.spectator_respawn_custom_score ) )
					player [[ level.spectator_respawn_custom_score ]]();

				player.score = 1500;
			}

			respawn_count++;
			add_result_executor_msg( result, "Respawned '" + player.name + "'" );
			add_result_player_msg( result, player, "You have been respawned" );
		}
	}

	result.msg = "Successfully respawned '" + respawn_count + "' players";

	return result;
}

// TODO: stop the zombies from dying due to g_ai preventing movement
cmd_pause_f( param )
{
	duration = _DEFAULT( param.a[ 0 ], -1 );
	if ( duration > 0 )
	{
		level thread game_pause( duration );
		return result_cmdinfo( "Game paused for " + duration + " minutes" );
	}
	else 
	{
		level thread game_pause( -1 );
		return result_cmdinfo( "Game paused indefinitely use unpause to end the pause" );
	}
}

cmd_unpause_f( param )
{
	game_unpause();

	return result_cmdinfo( "Game unpaused" );
}

cmd_perk_f( param )
{
	perk_name = param.a[ 0 ];
	if ( perk_name != "all" )
	{
		self give_perk_zm( perk_name );
		return result_cmdinfo( "Gave perk " + perk_name + " to you" );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			self give_perk_zm( perk );
		}

		return result_cmdinfo( "Gave you all perks" );
	}
}

cmd_takeperk_f( param )
{
	perk_name = param.a[ 0 ];
	if ( perk_name != "all" )
	{
		self notify( perk_name + "_stop" );
		return result_cmdinfo( "Took perk " + perk_name + " from you" );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			self notify( perk + "_stop" );
		}

		return result_cmdinfo( "Took all perks from you" );
	}
}

cmd_permaperk_f( param )
{
	perma_perk_name = param.a[ 0 ];
	if ( perma_perk_name != "all" )
	{
		self give_perma_perk( perma_perk_name );
		return result_cmdinfo( "Gave you " + perma_perk_name );
	}
	else
	{
		self give_all_perma_perks();
		return result_cmdinfo( "Gave you all perma perks" );
	}
}

cmd_points_f( param )
{
	points = param.a[ 0 ];
	self add_to_player_score( points );

	return result_cmdinfo( "Gave you '" + points + "' points" );
}

cmd_powerup_f( param )
{
	powerup_name = param.a[ 0 ];
	success = self give_powerup_zm( powerup_name );
	if ( success )
	{
		return result_cmdinfo( "Spawned '" + powerup_name + "' for you" );
	}
}

cmd_weapon_f( param )
{
	weapon = param.a[ 0 ];
	self thread weapon_give_custom( weapon, weapon_is_upgrade( weapon ), true );

	return result_cmdinfo( "Gave you '" + weapon + "'" );
}

cmd_toggleperssystemforplayer_f( param )
{
	on_off = cast_bool_to_str( is_true( self.tcs_disable_pers_system ), "on off" );
	self.tcs_disable_pers_system = !is_true( self.tcs_disable_pers_system );

	return result_cmdinfo( "Toggled pers system for " + self.name + " " + on_off );
}

cmd_toggleoutofplayableareamonitor_f( param )
{
	on_off = cast_bool_to_str( !is_true( level.player_out_of_playable_area_monitor ), "on off" );
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

cmd_openalldoors_f( param )
{
	if ( is_true( level.tcs_doors_all_opened ) )
	{
		return result_cmdinfo( "All doors are already open" );
	}
	level thread open_seseme();

	return result_cmdinfo( "All doors are now open" );
}

cmd_setround_f( param )
{
	round_number = param.a[ 0 ];

	level.round_number = round_number;
	change_round( round_number );

	return result_cmdinfo( "Round set to " + round_number );
}

cmd_nextround_f( param )
{
	level.round_number++;
	change_round( level.round_number );

	return result_cmdinfo( "Round set to " + level.round_number );
}

cmd_prevround_f( param )
{
	level.round_number--;
	change_round( level.round_number );

	return result_cmdinfo( "Round set to " + level.round_number );
}

cmd_setglobalzombiestat_f( param )
{
	stat_name = param.a[ 0 ];
	stat = level.tcs_modifiable_zombie_stats[ stat_name ];
	if ( !isDefined( stat ) )
	{
		return result_cmderror( "1Invalid zombie stat " + stat_name + ", use listglobalzombiestats to see modifiable stats" );
	}

	value = param.a[ 1 ];
	
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

cmd_listglobalzombiestats_f( param )
{
	self thread list_zombie_stats_throttled();
	return result_cmderror( "" );
}

cmd_setallphysparams_f( param )
{
	phys_params = param.a[ 0 ];
	zombies = param.t[ 0 ];

	if ( !isdefined( zombies ) )
	{
		zombies = get_round_enemy_array();
	}

	foreach ( zombie in zombies )
	{
		zombie setphysparams( phys_params[ 0 ], phys_params[ 1 ], phys_params[ 2 ] );
	}

	return result_cmdinfo( "Set all zombies phys params to " + phys_params );
}

cmd_weaponlist_f( param )
{
	self thread list_weapons_throttled();
	return result_cmdinfo( "" );
}

cmd_poweruplist_f( param )
{
	self thread list_powerups_throttled();

	return result_cmdinfo( "" );
}

cmd_perklist_f( param )
{
	self thread list_perks_throttled();

	return result_cmdinfo( "" );
}