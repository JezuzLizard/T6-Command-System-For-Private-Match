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
	spectator_cmd target_add_required( 1, "player", "player", "Player to force into spectate state" );
	
	togglerespawn_cmd = cmd_add( "togglerespawn", ::cmd_togglerespawn_f, "togglerespawn {player}" );
	togglerespawn_cmd target_add_optional( 1, "player", "player", "Player to disable respawning for" );

	killactors_cmd = cmd_add( "killactors", ::cmd_killactors_f, "killactors {actor_targets}" );
	killactors_cmd target_add_optional( 1, "actor_targets", "actor", "Actors to kill" );

	respawnspectators_cmd = cmd_add( "spawnspectator", ::cmd_spawnspectator_f, "spawnspectator {player}" );
	respawnspectators_cmd target_add_optional( 1, "player", "player", "Spectators to respawn" );

	pause_cmd = cmd_add( "pause", ::cmd_pause_f, "pause [minutes]" );
	pause_cmd arg_add_optional( 1, "minutes", "natural_int", "Duration minutes until the pause automatically expires" );

	unpause_cmd = cmd_add( "unpause", ::cmd_unpause_f );

	giveperk_cmd = cmd_add( "perk", ::cmd_perk_f, "perk <perk|all>" );
	giveperk_cmd arg_add_required( 1, "perk", "perk", "Perk to give; can be literal 'all'" );
	giveperk_cmd executor_obj_add_cmd( "Player to give a perk to" );

	takeperk_cmd = cmd_add( "takeperk", ::cmd_takeperk_f, "takeperk <perk|all>" );
	takeperk_cmd arg_add_required( 1, "perk", "perk", "Perk to take; can be literal 'all'" );
	takeperk_cmd executor_obj_add_cmd( "Player to take a perk from" );

	givepermaperk_cmd = cmd_add( "permaperk", ::cmd_permaperk_f, "permaperk <permaperk|all>" );
	givepermaperk_cmd arg_add_required( 1, "permaperk", "permaperk", "Permaperk to give; can be literal 'all'" );
	givepermaperk_cmd executor_obj_add_cmd( "Player to give a perma perk to" );

	givepoints_cmd = cmd_add( "points", ::cmd_points_f, "points <amount>" );
	givepoints_cmd arg_add_required( 1, "amount", "int", "Points to give" );
	givepoints_cmd executor_obj_add_cmd( "Player to give points to" );

	givepowerup_cmd = cmd_add( "powerup", ::cmd_powerup_f, "powerup <powerup>" );
	givepowerup_cmd arg_add_required( 1, "powerup", "powerup", "Powerup to spawn" );
	givepowerup_cmd executor_obj_add_cmd( "Player to give a powerup to" );

	giveweapon_cmd = cmd_add( "weapon", ::cmd_weapon_f, "weapon <weapon>" );
	giveweapon_cmd arg_add_required( 1, "weapon", "weapon", "Weapon to give" );
	giveweapon_cmd executor_obj_add_cmd( "Player to give a weapon to" );

	toggleperssystemforplayer_cmd = cmd_add( "toggleperssystemforplayer", ::cmd_toggleperssystemforplayer_f, "toggleperssystemforplayer" );
	toggleperssystemforplayer_cmd executor_obj_add_cmd( "Player to toggle the perma perks system for" );

	toggleoutofplayableareamonitor_cmd = cmd_add( "toggleoutofplayableareamonitor", ::cmd_toggleoutofplayableareamonitor_f );

	openalldoors_cmd = cmd_add( "openalldoors", ::cmd_openalldoors_f );

	setround_cmd = cmd_add( "setround", ::cmd_setround_f, "setround <round_number>" );
	setround_cmd arg_add_required( 1, "round_number", "positive_int", "Force change round to <round_number>" );

	nextround_cmd = cmd_add( "nextround", ::cmd_nextround_f );

	prevround_cmd = cmd_add( "prevround", ::cmd_prevround_f );

	setglobalzombiestat_cmd = cmd_add( "setglobalzombiestat", ::cmd_setglobalzombiestat_f, "setglobalzombiestat <statname> <value>" );
	setglobalzombiestat_cmd arg_add_required( 1, "statname", "string", "Statname to change" );
	setglobalzombiestat_cmd arg_add_required( 2, "value", "string", "Value to assign to" );

	listglobalzombiestats_cmd = cmd_add( "listglobalzombiestats", ::cmd_listglobalzombiestats_f );

	setallphysparams_cmd = cmd_add( "setallphysparams", ::cmd_setallphysparams_f, "setallphysparams {actor} <vector>" );
	setallphysparams_cmd arg_add_required( 1, "physparams", "vector", "Vector {actor} target will use for phyparams" );
	setallphysparams_cmd target_add_optional( 1, "actor", "actor", "Actor to modify phys params for" );

	cmd_block_set_rank_group( "none" );
	weaponlist_cmd = cmd_add( "weaponlist", ::cmd_weaponlist_f );

	poweruplist_cmd = cmd_add( "poweruplist", ::cmd_poweruplist_f );

	perklist_cmd = cmd_add( "perklist", ::cmd_perklist_f );
}

private cmd_spectator_f( param )
{
	targets = param.t[ 0 ];

	for ( i = 0; i < _SIZE( targets.size ); i++ )
	{
		target = targets[ i ];
		target spawnspectator();
		if ( !isDefined( target.tcs_original_respawn ) )
		{
			target.tcs_original_respawn = target.spectator_respawn;
		}
		target.spectator_respawn = undefined;

		param add_executor_cmdinfo( "Successfully made " + target.name + " a spectator" );
		param add_player_msg( target, "You are now a spectator" );
	}

	param add_executor_cmdinfo( "Made '" + targets.size + "' players into spectators" );
}

private cmd_togglerespawn_f( param )
{
	targets = param.t[ 0 ];

	for ( i = 0; i < _SIZE( targets.size ); i++ )
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

		param add_executor_cmdinfo( target.name + " has their respawn toggled" );
		param add_player_msg( target, "You will no longer respawn" );
	}

	param add_executor_cmdinfo( "Disabled respawning for '" + targets.size + "' players" );
}

private cmd_killactors_f( param )
{
	targets = param.t[ 0 ];
	if ( !array_validate( targets ) )
	{
		targets = getaiarray( level.zombie_team );
	}
	for ( i = 0; i < _SIZE( targets.size ); i++ )
	{
		zombie = targets[ i ];
		if ( isdefined( zombie ) )
		{
			zombie dodamage( zombie.health + 666, zombie.origin );
		}
	}

	return param add_executor_cmdinfo( "Killed all zombies" );
}

private cmd_spawnspectator_f( param )
{
	targets = _DEFAULT( param.t[ 0 ], level.players );

	respawn_count = 0;
	for ( i = 0; i < _SIZE( targets.size ); i++ )
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
			param add_executor_cmdinfo( "Respawned '" + player.name + "'" );
			param add_player_msg( player, "You have been respawned" );
		}
	}

	param add_executor_cmdinfo( "Successfully respawned '" + respawn_count + "' players" );
}

// TODO: stop the zombies from dying due to g_ai preventing movement
private cmd_pause_f( param )
{
	duration = _DEFAULT( param.a[ 0 ], -1 );
	if ( duration > 0 )
	{
		level thread scripts\zm\cmd\modules\zm_core_helpers::game_pause( duration );
		return param add_executor_cmdinfo( "Game paused for " + duration + " minutes" );
	}
	else 
	{
		level thread scripts\zm\cmd\modules\zm_core_helpers::game_pause( -1 );
		return param add_executor_cmdinfo( "Game paused indefinitely use unpause to end the pause" );
	}
}

private cmd_unpause_f( param )
{
	scripts\zm\cmd\modules\zm_core_helpers::game_unpause();

	return param add_executor_cmdinfo( "Game unpaused" );
}

private cmd_perk_f( param )
{
	perk_name = param.a[ 0 ];
	if ( perk_name != "all" )
	{
		self scripts\zm\cmd\modules\zm_core_helpers::give_perk_zm( perk_name );
		return param add_executor_cmdinfo( "Gave perk " + perk_name + " to you" );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			self scripts\zm\cmd\modules\zm_core_helpers::give_perk_zm( perk );
		}

		return param add_executor_cmdinfo( "Gave you all perks" );
	}
}

private cmd_takeperk_f( param )
{
	perk_name = param.a[ 0 ];
	if ( perk_name != "all" )
	{
		self notify( perk_name + "_stop" );
		return param add_executor_cmdinfo( "Took perk " + perk_name + " from you" );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			self notify( perk + "_stop" );
		}

		return param add_executor_cmdinfo( "Took all perks from you" );
	}
}

private cmd_permaperk_f( param )
{
	perma_perk_name = param.a[ 0 ];
	if ( perma_perk_name != "all" )
	{
		self scripts\zm\cmd\modules\zm_core_helpers::give_perma_perk( perma_perk_name );
		return param add_executor_cmdinfo( "Gave you " + perma_perk_name );
	}
	else
	{
		self scripts\zm\cmd\modules\zm_core_helpers::give_all_perma_perks();
		return param add_executor_cmdinfo( "Gave you all perma perks" );
	}
}

private cmd_points_f( param )
{
	points = param.a[ 0 ];
	self add_to_player_score( points );

	return param add_executor_cmdinfo( "Gave you '" + points + "' points" );
}

private cmd_powerup_f( param )
{
	powerup_name = param.a[ 0 ];
	success = self scripts\zm\cmd\modules\zm_core_helpers::give_powerup_zm( powerup_name );
	if ( !success )
	{
		return param add_executor_cmderror( "Could not spawn powerup: '" + powerup_name + "'" );
	}

	return param add_executor_cmdinfo( "Spawned '" + powerup_name + "' for you" );
}

private cmd_weapon_f( param )
{
	weapon = param.a[ 0 ];
	self thread scripts\zm\cmd\modules\zm_core_helpers::weapon_give_custom( weapon, weapon_is_upgrade( weapon ), true );

	param add_executor_cmdinfo( "Gave you '" + weapon + "'" );
}

private cmd_toggleperssystemforplayer_f( param )
{
	on_off = cast_bool_to_str( is_true( self.tcs_disable_pers_system ), "on off" );
	self.tcs_disable_pers_system = !is_true( self.tcs_disable_pers_system );

	param add_executor_cmdinfo( "Toggled pers system for " + self.name + " " + on_off );
}

private cmd_toggleoutofplayableareamonitor_f( param )
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

	param add_executor_cmdinfo( "Out of playable area monitor " + on_off );
}

private cmd_openalldoors_f( param )
{
	if ( is_true( level.tcs_doors_all_opened ) )
	{
		return param add_executor_cmdinfo( "All doors are already open" );
	}
	level thread scripts\zm\cmd\modules\zm_core_helpers::open_seseme();

	param add_executor_cmdinfo( "All doors are now open" );
}

private cmd_setround_f( param )
{
	round_number = param.a[ 0 ];

	level.round_number = round_number;
	scripts\zm\cmd\modules\zm_core_helpers::change_round( round_number );

	param add_executor_cmdinfo( "Round set to " + round_number );
}

private cmd_nextround_f( param )
{
	level.round_number++;
	scripts\zm\cmd\modules\zm_core_helpers::change_round( level.round_number );

	param add_executor_cmdinfo( "Round set to " + level.round_number );
}

private cmd_prevround_f( param )
{
	level.round_number--;
	scripts\zm\cmd\modules\zm_core_helpers::change_round( level.round_number );

	param add_executor_cmdinfo( "Round set to " + level.round_number );
}

private cmd_setglobalzombiestat_f( param )
{
	stat_name = param.a[ 0 ];
	stat = level.tcs_modifiable_zombie_stats[ stat_name ];
	if ( !isDefined( stat ) )
	{
		return param add_executor_cmderror( "1Invalid zombie stat " + stat_name + ", use listglobalzombiestats to see modifiable stats" );
	}

	value = param.a[ 1 ];
	
	if ( value == "reset" )
	{
		if ( !scripts\zm\cmd\modules\zm_core_helpers::set_global_zombie_stat( stat, stat_name, stat.reset_value ) )
		{
			return param add_executor_cmderror( "2Invalid zombie stat " + stat_name + " , use listglobalzombiestats to see modifiable stats" );
		}
		return param add_executor_cmdinfo( "Successfully reset " + stat_name + " to its original value" );
	}

	if ( isDefined( level.tcs_arg_type_handlers[ stat.type ] ) )
	{
		casted_value = self [[ level.tcs_arg_type_handlers[ stat.type ].cast_func ]]( value );

		if ( !scripts\zm\cmd\modules\zm_core_helpers::set_global_zombie_stat( stat, stat_name, casted_value ) )
		{
			return param add_executor_cmderror( "3Invalid zombie stat " + stat_name + " , use listglobalzombiestats to see modifiable stats" );
		}

		return param add_executor_cmdinfo( "Successfully set " + stat_name + " to " + value );
	}

	return param add_executor_cmderror( "Expected positive_int or positive_float, got: " + value );
}

private cmd_listglobalzombiestats_f( param )
{
	self thread scripts\zm\cmd\modules\zm_core_helpers::list_zombie_stats_throttled();
	return param add_executor_cmderror( "" );
}

private cmd_setallphysparams_f( param )
{
	phys_params = param.a[ 0 ];
	zombies = param.t[ 0 ];

	if ( !array_validate( zombies ) )
	{
		zombies = get_round_enemy_array();
	}

	foreach ( zombie in zombies )
	{
		zombie setphysparams( phys_params[ 0 ], phys_params[ 1 ], phys_params[ 2 ] );
	}

	param add_executor_cmdinfo( "Set all zombies phys params to " + phys_params );
}

private cmd_weaponlist_f( param )
{
	self thread scripts\zm\cmd\modules\zm_core_helpers::list_weapons_throttled();
}

private cmd_poweruplist_f( param )
{
	self thread scripts\zm\cmd\modules\zm_core_helpers::list_powerups_throttled();
}

private cmd_perklist_f( param )
{
	self thread scripts\zm\cmd\modules\zm_core_helpers::list_perks_throttled();
}