#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\cmd\game_shared\sv\core\_utility;

#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weapons;

#include scripts\zm\cmd\t6\sv\_zm_utility;

add_zm_core_cmds()
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
	pause_cmd arg_add_optional_with_default( 1, "minutes", "natural_int", "Duration minutes until the pause automatically expires", -1 );

	unpause_cmd = cmd_add( "unpause", ::cmd_unpause_f );

	giveperk_cmd = cmd_add( "perk", ::cmd_perk_f, "perk <perk|all> {players}" );
	giveperk_cmd arg_add_required( 1, "perk", "perk", "Perk to give; can be literal 'all'" );
	giveperk_cmd target_add_optional( 1, "player", "player", "Players to give perks to" );
	giveperk_cmd executor_obj_add_cmd( "Player to give a perk to" );

	takeperk_cmd = cmd_add( "takeperk", ::cmd_takeperk_f, "takeperk <perk|all> {players}" );
	takeperk_cmd arg_add_required( 1, "perk", "perk", "Perk to take; can be literal 'all'" );
	takeperk_cmd target_add_optional( 1, "player", "player", "Players to takes perks from" );
	takeperk_cmd executor_obj_add_cmd( "Player to take a perk from" );

	givepermaperk_cmd = cmd_add( "permaperk", ::cmd_permaperk_f, "permaperk <permaperk|all> {players}" );
	givepermaperk_cmd arg_add_required( 1, "permaperk", "permaperk", "Permaperk to give; can be literal 'all'" );
	givepermaperk_cmd target_add_optional( 1, "player", "player", "Players to give perma perks" );
	givepermaperk_cmd executor_obj_add_cmd( "Player to give a perma perk to" );

	givepoints_cmd = cmd_add( "points", ::cmd_points_f, "points <amount> {players}" );
	givepoints_cmd arg_add_required( 1, "amount", "int", "Points to give" );
	givepoints_cmd target_add_optional( 1, "player", "player", "Players to give points to" );
	givepoints_cmd executor_obj_add_cmd( "Player to give points to" );

	givepowerup_cmd = cmd_add( "powerup", ::cmd_powerup_f, "powerup <powerup> {players}" );
	givepowerup_cmd arg_add_required( 1, "powerup", "powerup", "Powerup to spawn" );
	givepowerup_cmd target_add_optional( 1, "player", "player", "Players to give powerups to" );
	givepowerup_cmd executor_obj_add_cmd( "Player to give a powerup to" );

	giveweapon_cmd = cmd_add( "weapon", ::cmd_weapon_f, "weapon <weapon> {players}" );
	giveweapon_cmd arg_add_required( 1, "weapon", "weapon", "Weapon to give" );
	giveweapon_cmd target_add_optional( 1, "player", "player", "Players to give weapons" );
	giveweapon_cmd executor_obj_add_cmd( "Player to give a weapon to" );

	toggleperssystem_cmd = cmd_add( "toggleperssystem", ::cmd_toggleperssystem_f, "toggleperssystem {players}" );
	toggleperssystem_cmd target_add_optional( 1, "player", "player", "Players to disable the perma perks system for" );
	toggleperssystem_cmd executor_obj_add_cmd( "Player to toggle the perma perks system for" );

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

	spawnperkmachine_cmd = cmd_add( "spawnperkmachine", ::cmd_spawnperkmachine_f, "spawnperkmachine <internal_name> <perk_specialty> [origin] [angles]" );
	spawnperkmachine_cmd arg_add_required( 1, "internal_name", "string", "Internal name of perk machine to get references by" );
	spawnperkmachine_cmd arg_add_required( 2, "perk_specialty", "perk", "Perk machine to spawn in" );
	spawnperkmachine_cmd arg_add_optional_with_default( 3, "origin", "vector", "Origin to spawn at", ( 0, 0, 0 ) );
	spawnperkmachine_cmd arg_add_optional_with_default( 4, "angles", "vector", "Angles to spawn at", ( 0, 0, 0 ) );

	spawnwallbuy_cmd = cmd_add( "spawnwallbuy", ::cmd_spawnwallbuy_f, "spawnwallbuy <internal_name> <targetname> <weapon_name> <origin> <angles>" );
	spawnwallbuy_cmd arg_add_required( 1, "internal_name", "string", "Internal name of wallbuy to get references by" );
	spawnwallbuy_cmd arg_add_required( 2, "targetname", "string", "Classification of wallbuy" );
	spawnwallbuy_cmd arg_add_required( 3, "weapon_name", "weapon", "Weapon to use" );
	spawnwallbuy_cmd arg_add_optional_with_default( 4, "origin", "vector", "Location of new wallbuy", ( 0, 0, 0 ) );
	spawnwallbuy_cmd arg_add_optional_with_default( 5, "angles", "vector", "Angles of new wallbuy", ( 0, 0, 0 ) );

	magicbulletshield_cmd = cmd_add( "magicbulletshield", ::cmd_magicbulletshield_f, "magicbulletshield" );
	magicbulletshield_cmd target_add_optional( 1, "player", "player", "Players to give magicbulletshield" );
	magicbulletshield_cmd executor_obj_add_cmd( "Player who will receive magicbulletshield" );

	showcustomspawns_cmd = cmd_add( "showcustomspawns", ::cmd_showcustomspawns_f, "showcustomspawns" );
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
		param add_player_cmdinfo( target, "You are now a spectator" );
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
		param add_player_cmdinfo( target, "You will no longer respawn" );
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
			param add_player_cmdinfo( player, "You have been respawned" );
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
		level thread game_pause( duration );
		return param add_executor_cmdinfo( "Game paused for " + duration + " minutes" );
	}
	else 
	{
		level thread game_pause( -1 );
		return param add_executor_cmdinfo( "Game paused indefinitely use unpause to end the pause" );
	}
}

private cmd_unpause_f( param )
{
	game_unpause();

	return param add_executor_cmdinfo( "Game unpaused" );
}

private cmd_perk_f( param )
{
	targets = param.t[ 0 ];

	perk_name = param.a[ 0 ];
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			self give_perk_zm_wrapper_target( param, perk_name, player );
		}
	}
	else
	{
		self give_perk_zm_wrapper_executor( param, perk_name );
	}
}

private cmd_takeperk_f( param )
{
	targets = param.t[ 0 ];

	perk_name = param.a[ 0 ];
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			self take_perk_zm_wrapper_target( param, perk_name, player );
		}
	}
	else
	{
		self take_perk_zm_wrapper_executor( param, perk_name );
	}
}

private cmd_permaperk_f( param )
{
	perma_perk_name = param.a[ 0 ];
	if ( perma_perk_name != "all" )
	{
		self give_perma_perk( perma_perk_name );
		return param add_executor_cmdinfo( "Gave you " + perma_perk_name );
	}
	else
	{
		self give_all_perma_perks();
		return param add_executor_cmdinfo( "Gave you all perma perks" );
	}
}

private cmd_points_f( param )
{
	targets = param.t[ 0 ];

	points = param.a[ 0 ];
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			player add_to_player_score( points );
			param add_executor_cmdinfo( "Gave '" + player.name + "' '" + points + "' points" );
			param add_player_cmdinfo( player, "Gave you '" + points + "' points" );
		}
	}
	else
	{
		self add_to_player_score( points );
		param add_executor_cmdinfo( "Gave you '" + points + "' points" );
	}
}

private cmd_powerup_f( param )
{
	targets = param.t[ 0 ];

	powerup_name = param.a[ 0 ];
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			success = player give_powerup_zm( powerup_name );
			if ( !success )
			{
				param add_executor_cmderror( "Could not spawn powerup: '" + powerup_name + "' for '" + player.name + "'" );
				continue;
			}

			param add_executor_cmdinfo( "Spawned '" + player.name + "' '" + powerup_name + "' a powerup" );
			param add_player_cmdinfo( player, "Spawned you '" + powerup_name + "' powerup" );
		}
	}
	else
	{
		success = self give_powerup_zm( powerup_name );
		if ( !success )
		{
			return param add_executor_cmderror( "Could not spawn powerup: '" + powerup_name + "'" );
		}

		return param add_executor_cmdinfo( "Spawned '" + powerup_name + "' for you" );
	}
}

private cmd_weapon_f( param )
{
	targets = param.t[ 0 ];

	weapon = param.a[ 0 ];
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			success = player weapon_give_custom( weapon, weapon_is_upgrade( weapon ), true );
			if ( !success )
			{
				param add_executor_cmderror( "Could not give: '" + weapon + "' to '" + player.name + "'" );
				continue;
			}

			param add_executor_cmdinfo( "Gave " + player.name + "'" + weapon + "' weapon" );
			param add_player_cmdinfo( player, "Gave you '" + weapon + "' weapon" );
		}
	}
	else
	{
		success = self weapon_give_custom( weapon, weapon_is_upgrade( weapon ), true );
		if ( !success )
		{
			return param add_executor_cmderror( "Could not spawn weapon: '" + weapon + "'" );
		}

		param add_executor_cmdinfo( "Gave you '" + weapon + "'" );
	}
}

private cmd_toggleperssystem_f( param )
{
	targets = param.t[ 0 ];
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			on_off = cast_bool_to_str( is_true( self.tcs_disable_pers_system ), "on off" );
			self.tcs_disable_pers_system = !is_true( self.tcs_disable_pers_system );

			param add_executor_cmdinfo( "Toggled '" + player.name + "' perma perk system '" + on_off + "'" );
			param add_player_cmdinfo( player, "Toggled your perma perk system '" + on_off + "'" );
		}
	}
	else
	{
		on_off = cast_bool_to_str( is_true( self.tcs_disable_pers_system ), "on off" );
		self.tcs_disable_pers_system = !is_true( self.tcs_disable_pers_system );
		param add_executor_cmdinfo( "Toggled the perma perk system '" + on_off + "'" );
	}
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
	level thread open_seseme();

	param add_executor_cmdinfo( "All doors are now open" );
}

private cmd_setround_f( param )
{
	round_number = param.a[ 0 ];

	level.round_number = round_number;
	change_round( round_number );

	param add_executor_cmdinfo( "Round set to " + round_number );
}

private cmd_nextround_f( param )
{
	level.round_number++;
	change_round( level.round_number );

	param add_executor_cmdinfo( "Round set to " + level.round_number );
}

private cmd_prevround_f( param )
{
	level.round_number--;
	change_round( level.round_number );

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
		if ( !set_global_zombie_stat( stat, stat_name, stat.reset_value ) )
		{
			return param add_executor_cmderror( "2Invalid zombie stat " + stat_name + " , use listglobalzombiestats to see modifiable stats" );
		}

		return param add_executor_cmdinfo( "Successfully reset " + stat_name + " to its original value" );
	}

	if ( isDefined( level.tcs_arg_type_handlers[ stat.type ] ) )
	{
		casted_value = self [[ level.tcs_arg_type_handlers[ stat.type ].cast_func ]]( value );

		if ( !set_global_zombie_stat( stat, stat_name, casted_value ) )
		{
			return param add_executor_cmderror( "3Invalid zombie stat " + stat_name + " , use listglobalzombiestats to see modifiable stats" );
		}

		return param add_executor_cmdinfo( "Successfully set " + stat_name + " to " + value );
	}

	return param add_executor_cmderror( "Expected positive_int or positive_float, got: " + value );
}

private cmd_listglobalzombiestats_f( param )
{
	self thread list_zombie_stats_throttled();
	return param add_executor_cmderror( "" );
}

private cmd_setallphysparams_f( param )
{
	phys_params = param.a[ 0 ];
	zombies = param.t[ 0 ];

	if ( phys_params[ 0 ] < 0 )
	{
		return param add_executor_cmderror( "Phys params of x cannot be less than 0" );
	}
	if ( phys_params[ 1 ] < 0 )
	{
		return param add_executor_cmderror( "Phys params of y cannot be less than 0" );
	}
	if ( phys_params[ 2 ] < 0 )
	{
		return param add_executor_cmderror( "Phys params of z cannot be less than 0" );
	}
	if ( phys_params[ 0 ] > 100 )
	{
		return param add_executor_cmderror( "Phys params of x cannot be greater than 100" );
	}
	if ( phys_params[ 1 ] > 100 )
	{
		return param add_executor_cmderror( "Phys params of y cannot be greater than 100" );
	}
	if ( phys_params[ 2 ] > 100 )
	{
		return param add_executor_cmderror( "Phys params of z cannot be greater than 100" );
	}

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
	self thread list_weapons_throttled();
}

private cmd_poweruplist_f( param )
{
	self thread list_powerups_throttled();
}

private cmd_perklist_f( param )
{
	self thread list_perks_throttled();
}

private cmd_spawnperkmachine_f( param )
{
	internal_name = param.a[ 0 ];
	perk_specialty = param.a[ 1 ];
	if ( !isdefined( level._spawnable_perk_machines[ perk_specialty ] ) )
	{
		return param add_executor_cmderror( "Unknown perk specialty: '" + perk_specialty + "'" );
	}

	if ( !isdefined( level._dynamically_spawned_active_perk_machines ) )
	{
		level._dynamically_spawned_active_perk_machines = [];
	}

	if ( isdefined( level._dynamically_spawned_active_perk_machines[ internal_name ] ) )
	{
		return param add_executor_cmderror( "internal_name: '" + internal_name + "' cannot be used again because it would collide with identifying an existing perk machine"  );
	}

	model = level._spawnable_perk_machines[ perk_specialty ].assets.off_model;
	origin = _DEFAULT( param.a[ 2 ], isdefined( self.origin ) ? self.origin : ( 0, 0, 0 ) );
	angles = _DEFAULT( param.a[ 3 ], isdefined( self.angles ) ? self.angles : ( 0, 0, 0 ) );
	clip_model = undefined;

	perk_trigger = _spawn_perk_machine( internal_name, perk_specialty, model, origin, angles, undefined, clip_model );
	_power_on_machine( perk_trigger._perk_machine );
	param add_executor_cmdinfo( "Successfully spawned in '" + perk_specialty + "' perk machine" );
}

private cmd_spawnwallbuy_f( param )
{
	internal_name = param.a[ 0 ];
	targetname = param.a[ 1 ];
	weapon_name = param.a[ 2 ];
	origin = _DEFAULT( param.a[ 3 ], isdefined( self.origin ) ? self.origin + ( 0, 0, 39 ) : ( 0, 0, 39 ) );
	angles = _DEFAULT( param.a[ 4 ], isdefined( self.angles ) ? self.angles : ( 0, 0, 0 ) );

	if ( !isdefined( level._dynamically_spawned_active_wallbuys ) )
	{
		level._dynamically_spawned_active_wallbuys = [];
	}

	if ( isdefined( level._dynamically_spawned_active_wallbuys[ internal_name ] ) )
	{
		return param add_executor_cmderror( "internal_name: '" + internal_name + "' cannot be used again because it would collide with identifying an existing wallbuy"  );
	}

	wallbuy_struc = spawn_wallbuy_dynamically( internal_name, targetname, weapon_name, origin, angles );
	if ( wallbuy_struc.invalid )
	{
		return param add_executor_cmderror( wallbuy_struc.msg );
	}
}

private cmd_magicbulletshield_f( param )
{
	targets = param.t[ 0 ];

	on_off = cast_bool_to_str( !is_true( self.magic_bullet_shield ), "on off" );
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			player toggle_magicbulletshield( on_off == "on" );
			param add_executor_cmdinfo( "Successfully toggled '" + player.name + "' Magic Bullet Shield status to '" + on_off + "'" );
			param add_player_cmdinfo( player, "Your Magic Bullet Shield status was toggled '" + on_off + "'" );
		}
	}
	else
	{
		self toggle_magicbulletshield( on_off == "on" );
		param add_executor_cmdinfo( "Magic Bullet Shield " + on_off );
	}

	if ( on_off == "on" )
	{
		level notify( "unittest_start" );
	}
	else
	{
		level notify( "unittest_stop" );
	}
}

show_custom_spawns()
{

}

private cmd_showcustomspawns_f( param )
{
	on_off = cast_bool_to_str( !is_true( level._showing_custom_spawns ), "on off" );
	if ( on_off == "on" )
	{
		level thread show_custom_spawns();
	}
	else
	{
		level notify( "stop_showing_custom_spawns" );
	}

	param add_executor_cmdinfo( "Showing custom spawned entities '" + on_off + "'" );
}