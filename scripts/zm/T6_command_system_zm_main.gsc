#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weapons;

#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_perms;
#include scripts\zm\cmd_system_modules_zm\_overrides;
#include scripts\zm\cmd_system_modules_zm\_zm_cmd_util;

main()
{
	replaceFunc( maps\mp\zombies\_zm_pers_upgrades_system::pers_upgrades_monitor, ::pers_upgrades_monitor_override );
	replaceFunc( maps\mp\zombies\_zm_utility::wait_network_frame, ::wait_network_frame_override );
	replaceFunc( maps\mp\zombies\_zm::check_end_game_intermission_delay, ::check_end_game_intermission_delay_override );
	replaceFunc( maps\mp\_visionset_mgr::monitor, ::monitor_stub );
	level.bot_cmd_system_unittest_func = ::bot_unittest_func;
	level.tcs_additional_help_prints_func = ::zm_help_prints;
	while ( !is_true( level.cmd_init_done ) )
	{
		wait 0.05;
	}

	register_modifiable_zombie_stat( "health_increase_flat", "wholenum", 100, ::zombie_recalculate_health );
	register_modifiable_zombie_stat( "health_increase_multiplier", "wholefloat", 0.1, ::zombie_recalculate_health );
	register_modifiable_zombie_stat( "health_start", "wholenum", 150, ::zombie_recalculate_health );
	register_modifiable_zombie_stat( "spawn_delay", "wholefloat", 2.0, ::zombie_recalculate_spawn_delay );
	register_modifiable_zombie_stat( "move_speed_multiplier", "wholenum", 8, ::zombie_recalculate_move_speed );
	register_modifiable_zombie_stat( "move_speed_multiplier_easy", "wholenum", 2, ::zombie_recalculate_move_speed );
	register_modifiable_zombie_stat( "max_ai", "wholenum", 24, ::zombie_recalculate_total );
	register_modifiable_zombie_stat( "ai_per_player", "wholenum", 6, ::zombie_recalculate_total );
	register_modifiable_zombie_stat( "ai_limit", "wholenum", 24 );

	cmd_add( "spectator", false, "spec", "spectator <name|guid|clientnum|self>", ::cmd_spectator_f, "cheat", 1, false );
	cmd_add( "togglerespawn", false, "togresp", "togglerespawn <name|guid|clientnum|self>", ::cmd_togglerespawn_f, "cheat", 1, false );
	cmd_add( "killactors", false, "ka", "killactors", ::cmd_killactors_f, "cheat", 0, false );
	cmd_add( "respawnspectators", false, "respspec", "respawnspectators", ::cmd_respawnspectators_f, "cheat", 0, false );
	cmd_add( "pause", false, "pa", "pause [minutes]", ::cmd_pause_f, "cheat", 0, false );
	cmd_add( "unpause", false, "up", "unpause", ::cmd_unpause_f, "cheat", 0, false );
	cmd_add( "giveperk", false, "gp", "giveperk <name|guid|clientnum|self> <perk|all>", ::cmd_giveperk_f, "cheat", 2, true );
	cmd_add( "takeperk", false, "tp", "takeperk <name|guid|clientnum|self> <perk|all>", ::cmd_takeperk_f, "cheat", 2, true );
	cmd_add( "givepermaperk", false, "gpp", "givepermaperk <name|guid|clientnum|self> <perk|all>", ::cmd_givepermaperk_f, "cheat", 2, true );
	cmd_add( "givepoints", false, "gpts", "givepoints <name|guid|clientnum|self> <amount>", ::cmd_givepoints_f, "cheat", 2, false );
	cmd_add( "givepowerup", false, "gpow", "givepowerup <name|guid|clientnum|self> <powerup>", ::cmd_givepowerup_f, "cheat", 2, false );
	cmd_add( "giveweapon", false, "gwep", "giveweapon <name|guid|clientnum|self> <weapon>", ::cmd_giveweapon_f, "cheat", 2, true );
	cmd_add( "toggleperssystemforplayer", false, "tpsfp", "toggleperssystemforplayer <name|guid|clientnum|self>", ::cmd_toggleperssystemforplayer_f, "cheat", 1, false );
	cmd_add( "toggleoutofplayableareamonitor", false, "togoopam", "toggleoutofplayableareamonitor", ::cmd_toggleoutofplayableareamonitor_f, "cheat", 0, false );
	cmd_add( "weaponlist", false, "wlist", "weaponlist", ::cmd_weaponlist_f, "none", 0, false );
	cmd_add( "openalldoors", false, "openall", "openalldoors", ::cmd_openalldoors_f, "cheat", 0, false );
	cmd_add( "poweruplist", false, "powlist", "poweruplist", ::cmd_poweruplist_f, "none", 0, false );
	cmd_add( "perklist", false, "plist", "perklist", ::cmd_perklist_f, "none", 0, false );
	cmd_add( "setround", false, "sr", "setround <round_number>", ::cmd_setround_f, "cheat", 1, false );
	cmd_add( "nextround", false, "nr", "nextround", ::cmd_nextround_f, "cheat", 0, false );
	cmd_add( "prevround", false, undefined, "prevround", ::cmd_prevround_f, "cheat", 0, false );
	cmd_add( "setglobalzombiestat", false, undefined, "setglobalzombiestat <statname> <value>", ::cmd_setglobalzombiestat_f, "cheat", 2, false );
	cmd_add( "listglobalzombiestats", false, undefined, "listglobalzombiestats", ::cmd_listglobalzombiestats_f, "cheat", 0, false );
	cmd_add( "setallphysparams", false, undefined, "setallphysparams <vector>", ::cmd_setallphysparams_f, "cheat", 1, false );

	cmd_register_arg_types_for_cmd( "spectator", "player" );
	cmd_register_arg_types_for_cmd( "togglerespawn", "player" );
	cmd_register_arg_types_for_cmd( "pause", "wholenum" );
	cmd_register_arg_types_for_cmd( "giveperk", "player perk" );
	cmd_register_arg_types_for_cmd( "takeperk", "player perk" );
	//cmd_register_arg_types_for_cmd( "givepermaperk", "player permaperk" );
	cmd_register_arg_types_for_cmd( "givepoints", "player int" );
	cmd_register_arg_types_for_cmd( "givepowerup", "player powerup" );
	cmd_register_arg_types_for_cmd( "giveweapon", "player weapon" );
	cmd_register_arg_types_for_cmd( "toggleperssystemforplayer", "player" );
	cmd_register_arg_types_for_cmd( "setround", "round" );
	cmd_register_arg_types_for_cmd( "setallphysparams", "vector" );

	cmd_add( "perk", true, undefined, "perk <perk|all>", ::cmd_perk_f, "cheat", 1, true );
	cmd_add( "perkremove", true, "pr", "perk <perk|all>", ::cmd_perkremove_f, "cheat", 1, true );
	cmd_add( "permaperk", true, "pp", "permaperk <perk|all>", ::cmd_permaperk_f, "cheat", 1, true );
	cmd_add( "points", true, "pts", "points <amount>", ::cmd_points_f, "cheat", 1, false );
	cmd_add( "powerup", true, "pow", "powerup <powerup>", ::cmd_powerup_f, "cheat", 1, false );
	cmd_add( "weapon", true, "wep", "weapon <weapon>", ::cmd_weapon_f, "cheat", 1, true );
	cmd_add( "toggleperssystem", true, "tps", "toggleperssystem", ::cmd_toggleperssystem_f, "cheat", 0, false );

	cmd_register_arg_types_for_cmd( "perk", "perk" );
	cmd_register_arg_types_for_cmd( "perkremove", "perk" );
	//cmd_register_arg_types_for_cmd( "permaperk", "permaperk" );
	cmd_register_arg_types_for_cmd( "points", "int" );
	cmd_register_arg_types_for_cmd( "powerup", "powerup" );
	cmd_register_arg_types_for_cmd( "weapon", "weapon" );

	cmd_register_arg_type_handlers( "weapon", ::arg_weapon_handler, ::arg_generate_rand_weapon, undefined, "not a valid weapon" );
	cmd_register_arg_type_handlers( "perk", ::arg_perk_handler, ::arg_generate_rand_perk, undefined, "not a valid perk" );
	cmd_register_arg_type_handlers( "powerup", ::arg_powerup_handler, ::arg_generate_rand_powerup, undefined, "not a valid powerup" );
	cmd_register_arg_type_handlers( "round", ::arg_round_handler, ::arg_generate_rand_round, ::arg_cast_to_int, "not a valid round" );

	level thread on_unittest();
	level thread check_for_cmd_alias_collisions();
	level.zm_cmd_init_done = true;
}

zm_help_prints( channel )
{
	if ( is_true( self.is_server ) )
	{
		level com_printf( channel, "notitle", "^3To view available powerups use tcscmd poweruplist", self );
		level com_printf( channel, "notitle", "^3To view available perks use tcscmd perklist", self );
		level com_printf( channel, "notitle", "^3To view available weapons use tcscmd weaponlist", self );
	}
	else 
	{
		level com_printf( channel, "notitle", "^3To view available powerups do poweruplist prefixed with a cmd token", self );
		level com_printf( channel, "notitle", "^3To view available perks do perklist prefixed with a cmd token", self );
		level com_printf( channel, "notitle", "^3To view available weapons do weaponlist prefixed with a cmd token", self );		
	}
}

on_unittest()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "unittest_start" );
		level.no_end_game_check = true;
		level._game_module_game_end_check = ::never_end_game;
		level.player_out_of_playable_area_monitor = false;
		level.zm_disable_recording_stats = true;
		level.powerup_player_valid = ::unittest_check_player_is_valid_for_powerup;
		level.overrideplayerdamage = ::player_damage_override;
		if ( isDefined( level.player_damage_callbacks ) && isDefined( level.player_damage_callbacks[ 0 ] ) )
		{
			old_player_damage_callback = level.player_damage_callbacks[ 0 ];
			level.player_damage_callbacks[ 0 ] = ::no_player_damage_during_unittest;
		}
		else 
		{
			level.player_damage_callbacks = [];
			level.player_damage_callbacks[ 0 ] = ::no_player_damage_during_unittest;
		}
		replacefunc( maps\mp\zombies\_zm::checkforalldead, maps\mp\gametypes_zm\_callbacksetup::callbackvoid );
		replacefunc( maps\mp\zombies\_zm::player_fake_death, maps\mp\gametypes_zm\_callbacksetup::callbackvoid );
		replaceFunc( maps\mp\zombies\_zm_perks::solo_revive_buy_trigger_move_trigger, ::solo_revive_buy_trigger_move_trigger_override );
		//replaceFunc( maps\mp\_utility::setclientfield, ::setclientfield_override );
		//replaceFunc( maps\mp\_utility::setclientfieldtoplayer, ::setclientfieldtoplayer_override );
		register_player_damage_callback( ::no_player_damage_during_unittest );
	}
}

cmd_givepowerup_f( args )
{
	result = [];
	target = args[ 0 ];
	powerup_name = args[ 1 ];
	success = target give_powerup_zm( powerup_name );
	if ( success )
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Spawned " + powerup_name + " for " + target.name;	
	}
	return result;
}

give_powerup_zm( powerup_name )
{
	channel = self com_get_cmd_feedback_channel();
	can_spawn = true;
	if ( self.origin[ 0 ] > 16384 || self.origin[ 0 ] < -16384 )
	{
		can_spawn = false;
	}
	else if ( self.origin[ 1 ] > 16384 || self.origin[ 1 ] < -16384 )
	{
		can_spawn = false;
	}
	else if ( self.origin[ 2 ] > 32768 || self.origin[ 2 ] < -32768 )
	{
		can_spawn = false;
	}
	if ( !can_spawn )
	{
		level com_printf( channel, "cmderror", "Cannot spawn a powerup this far from the map center", self );
		return false;
	}
	powerup_loc = self.origin + anglesToForward( self.angles ) * 64 + anglesToRight( self.angles ) * 64;
	powerup = maps\mp\zombies\_zm_powerups::specific_powerup_drop( powerup_name, powerup_loc );
	if ( powerup_name == "teller_withdrawl" )
	{
		powerup.value = 1000;
	}
	return true;
}

cmd_killactors_f( args )
{
	result = [];
	ai = getaiarray( level.zombie_team );
	for ( i = 0; i < ai.size; i++ )
	{
		zombie = ai[ i ];
		if ( isdefined( zombie ) )
		{
			zombie dodamage( zombie.health + 666, zombie.origin );
		}
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Killed all zombies";
	return result;
}

cmd_giveperk_f( args )
{
	result = [];
	target = args[ 0 ];
	perk_name = args[ 1 ];
	if ( perk_name != "all" )
	{
		target give_perk_zm( perk_name );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave perk " + perk_name + " to " + target.name;	
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			target give_perk_zm( perk );
		}
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave all perks to " + target.name;
	}
	return result;
}

cmd_takeperk_f( args )
{
	result = [];
	target = args[ 0 ];
	perk_name = args[ 1 ];
	if ( perk_name != "all" )
	{
		target notify( perk_name + "_stop" );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Took perk " + perk_name + " from " + target.name;	
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			target notify( perk + "_stop" );
		}
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Took all perks from " + target.name;
	}
	return result;	
}

give_perk_zm( perkname, index )
{
	if ( !self hasPerk( perkname ) )
	{
		self give_perk( perkname, false );
	}
}

cmd_pause_f( args )
{
	result = [];
	if ( isDefined( args[ 0 ] ) )
	{
		duration = args[ 0 ];
		level thread game_pause( duration );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Game paused for " + duration + " minutes";
	}
	else 
	{
		level thread game_pause( -1 );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Game paused indefinitely use unpause to end the pause";
	}
	return result;
}

game_pause( duration )
{
	flag_clear( "spawn_zombies" );
	disablezombies( 1 );
	foreach ( player in level.players )
	{
		player enableInvulnerability();
		player.tcs_is_invulnerable = true;
	}
	level thread unpause_after_time( duration );
}

unpause_after_time( duration )
{
	if ( duration < 0 )
	{
		return;
	}
	level notify( "unpause_countdown" );
	level endon( "unpause_countdown" );
	level endon( "game_unpaused" );
	duration_seconds = duration * 60;
	for ( ; duration_seconds > 0; duration_seconds-- )
	{
		wait 1;
	}
	game_unpause();
}

cmd_unpause_f( args )
{
	result = [];
	game_unpause();
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Game unpaused";
	return result;
}

game_unpause()
{
	level notify( "game_unpaused" );
	flag_set( "spawn_zombies" );
	enablezombies( 1 );
	foreach ( player in level.players )
	{
		player disableInvulnerability();
		player.tcs_is_invulnerable = false;
	}
}

cmd_givepermaperk_f( args )
{
	result = [];
	target = args[ 0 ];
	perma_perk_name = args[ 1 ];
	if ( perma_perk_name != "all" )
	{
		target give_perma_perk( perma_perk_name );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave " + target.name + " " + perma_perk_name;
	}
	else
	{
		target give_all_perma_perks();
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave all perma perks to " + target.name;
	}
	return result;
}

give_perma_perk( perk_name )
{
	self maps\mp\zombies\_zm_stats::increment_client_stat( perk_name, 0 );
}

give_all_perma_perks()
{
	foreach ( key in level.pers_upgrades_keys )
	{
		self give_perma_perk( level.pers_upgrades[ key ].stat_names[ 0 ] );
	}
}

cmd_givepoints_f( args )
{
	result = [];
	target = args[ 0 ];
	points = args[ 1 ];
	target add_to_player_score( points );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave " + target.name + " " + points + " points";
	return result;
}

cmd_spectator_f( args )
{
	result = [];
	target = args[ 0 ];
	target spawnspectator();
	if ( !isDefined( target.tcs_original_respawn ) )
	{
		target.tcs_original_respawn = target.spectator_respawn;
	}
	target.spectator_respawn = undefined;
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully made " + target.name + " a spectator";
	return result;
}

cmd_togglerespawn_f( args )
{
	result = [];
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
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = target.name + " has their respawn toggled";
	return result;
}

cmd_respawnspectators_f( args )
{
	result = [];
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
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully respawned all spectators";
	return result;
}

cmd_giveweapon_f( args )
{
	result = [];
	target = args[ 0 ];
	weapon = args[ 1 ];
	target thread weapon_give_custom( weapon, weapon_is_upgrade( weapon ), true );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave " + weapon + " to " + target.name;
	return result;
}

unlimited_weapons( player )
{
	return 5;
}

cmd_powerup_f( args )
{
	result = [];
	powerup_name = args[ 0 ];
	success = self give_powerup_zm( powerup_name );
	if ( success )
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Spawned " + powerup_name + " for you";
	}	
	return result;
}

cmd_weaponlist_f( args )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	weapons = getArrayKeys( level.zombie_include_weapons );
	self thread list_weapons_throttled( channel, weapons );
	return result;
}

list_weapons_throttled( channel, weapons )
{
	self notify( "listing_weapons" );
	self endon( "listing_weapons" );
	for ( i = 0; i < weapons.size; i++ )
	{
		level com_printf( channel, "notitle", weapons[ i ], self );
		wait 0.1;
	}
	if ( !is_true( self.is_server ) )
	{
		level com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

cmd_perk_f( args )
{
	result = [];
	perk_name = args[ 0 ];
	if ( perk_name != "all" )
	{
		self give_perk_zm( perk_name );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave you " + perk_name ;
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			self give_perk_zm( perk );
		}
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave you all perks";
	}
	return result;
}

cmd_perkremove_f( args )
{
	result = [];
	perk_name = args[ 0 ];
	if ( perk_name != "all" )
	{
		self notify( perk_name + "_stop" );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Took perk " + perk_name + " from you";
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			self notify( perk + "_stop" );
		}
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Took all perks";
	}
	return result;
}

cmd_points_f( args )
{
	result = [];
	points = args[ 0 ];
	self add_to_player_score( points );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave you " + points + " points";
	return result;
}

cmd_permaperk_f( args )
{
	result = [];
	perma_perk_name = args[ 0 ];
	if ( perma_perk_name != "all" )
	{
		self give_perma_perk( perma_perk_name );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave you " + perma_perk_name;
	}
	else
	{
		self give_all_perma_perks();
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave you all perma perks";
	}
	return result;
}

cmd_weapon_f( args )
{
	result = [];
	weapon = args[ 0 ];
	self thread weapon_give_custom( weapon, weapon_is_upgrade( weapon ), true );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave you " + weapon;
	return result;
}


cmd_toggleperssystemforplayer_f( args )
{
	result = [];
	target = args[ 0 ];
	on_off = cast_bool_to_str( is_true( target.tcs_disable_pers_system ), "on off" );
	target.tcs_disable_pers_system = !is_true( target.tcs_disable_pers_system );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled pers system for " + target.name + " " + on_off;
	return result;
}

cmd_toggleperssystem_f( args )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_disable_pers_system ), "on off" );
	self.tcs_disable_pers_system = !is_true( self.tcs_disable_pers_system );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled your pers system " + on_off;
	return result;
}

cmd_toggleoutofplayableareamonitor_f( args )
{
	result = [];
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
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Out of playable area monitor " + on_off;
	return result;
}

cmd_openalldoors_f( args )
{
	result = [];
	
	if ( is_true( level.tcs_doors_all_opened ) )
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "All doors are already open";
		return result;
	}
	level thread open_seseme();
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "All doors are now open";
	return result;
}

open_seseme()
{
	level.tcs_doors_all_opened = !is_true( level.tcs_doors_all_opened );
	flag_wait( "initial_blackscreen_passed" );
	setdvar( "zombie_unlock_all", 1 );
	flag_set( "power_on" );
	players = getPlayers();
	zombie_doors = getentarray( "zombie_door", "targetname" );
	for ( i = 0; i < zombie_doors.size; i++ )
	{
		zombie_doors[ i ] notify( "trigger" );
		if ( is_true( zombie_doors[ i ].power_door_ignore_flag_wait ) )
		{
			zombie_doors[ i ] notify( "power_on" );
		}
		wait 0.05;
	}
	zombie_airlock_doors = getentarray( "zombie_airlock_buy", "targetname" );
	for ( i = 0; i < zombie_airlock_doors.size; i++ )
	{
		zombie_airlock_doors[ i ] notify( "trigger" );
		wait 0.05;
	}
	zombie_debris = getentarray( "zombie_debris", "targetname" );
	for ( i = 0; i < zombie_debris.size; i++ )
	{
		zombie_debris[ i ] notify( "trigger", players[ 0 ] );
		wait 0.05;
	}
	setdvar( "zombie_unlock_all", 0 );
}

cmd_poweruplist_f( args )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	powerups = powerup_list_zm();
	self thread list_powerups_throttled( channel, powerups );
	return result;
}

list_powerups_throttled( channel, powerups )
{
	self notify( "listing_powerups" );
	self endon( "listing_powerups" );
	for ( i = 0; i < powerups.size; i++ )
	{
		level com_printf( channel, "notitle", powerups[ i ], self );
		wait 0.1;
	}
}

cmd_perklist_f( args )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	perks = perk_list_zm();
	self thread list_perks_throttled( channel, perks );
	return result;
}

list_perks_throttled( channel, perks )
{
	self notify( "listing_perks" );
	self endon( "listing_perks" );
	for ( i = 0; i < perks.size; i++ )
	{
		level com_printf( channel, "notitle", perks[ i ], self );
		wait 0.1;
	}
}

cmd_setround_f( args )
{
	result = [];
	if ( args[ 0 ] > 255 || args[ 0 ] < 0 )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Cannot set round to a number greater than 255 or less than 0";
		return result;
	}

	level.round_number = args[ 0 ];
	change_round( args[ 0 ] );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Round set to " + args[ 0 ];
	return result;
}

cmd_nextround_f( args )
{
	result = [];
	level.round_number++;
	change_round( level.round_number );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Round set to " + level.round_number;	
	return result;
}

cmd_prevround_f( args )
{
	result = [];
	level.round_number--;
	change_round( level.round_number );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Round set to " + level.round_number;	
	return result;
}

cmd_setglobalzombiestat_f( args )
{
	result = [];
	stat_name = args[ 0 ];
	stat = level.tcs_modifiable_zombie_stats[ stat_name ];
	if ( !isDefined( stat ) )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "1Invalid zombie stat " + stat_name + ", use listglobalzombiestats to see modifiable stats";
		return result;
	}

	value = args[ 1 ];
	
	if ( value == "reset" )
	{
		if ( !set_global_zombie_stat( stat, stat_name, stat.reset_value ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "2Invalid zombie stat " + stat_name + " , use listglobalzombiestats to see modifiable stats";
			return result;
		}
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully reset " + stat_name + " to its original value";
		return result;
	}

	if ( isDefined( level.tcs_arg_type_handlers[ stat.type ] ) && self [[ level.tcs_arg_type_handlers[ stat.type ].checker_func ]]( value ) )
	{
		casted_value = self [[ level.tcs_arg_type_handlers[ stat.type ].cast_func ]]( value );

		if ( !set_global_zombie_stat( stat, stat_name, casted_value ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "3Invalid zombie stat " + stat_name + " , use listglobalzombiestats to see modifiable stats";
			return result;
		}

		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully set " + stat_name + " to " + value;
		return result;
	}

	result[ "filter" ] = "cmderror";
	result[ "message" ] = "Expected wholenum or wholefloat, got: " + value;
	return result;
}

set_global_zombie_stat( stat, stat_name, stat_value )
{
	if ( isDefined( level.zombie_vars[ "zombie_" + stat_name ] ) )
	{
		level.tcs_modifiable_zombie_stats[ stat_name ].current_value = stat_value;
		level.zombie_vars[ "zombie_" + stat_name ] = stat_value;
		level [[ stat.recalculate_func ]]( stat_name, stat_value );
		return true;
	}
	switch ( stat_name )
	{
		case "ai_limit":
			level.tcs_modifiable_zombie_stats[ stat_name ].current_value = stat_value;
			level.zombie_ai_limit = stat_value;
			return true;
		default:
			return false;
	}
}

cmd_listglobalzombiestats_f( args )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	self thread list_zombie_stats_throttled( channel );
	return result;
}

list_zombie_stats_throttled( channel )
{
	self notify( "listing_zombie_stats" );
	self endon( "listing_zombie_stats" );
	stat_names = getArrayKeys( level.tcs_modifiable_zombie_stats );
	for ( i = 0; i < stat_names.size; i++ )
	{
		cur_value = level.tcs_modifiable_zombie_stats[ stat_names[ i ] ].current_value;
		reset_value = level.tcs_modifiable_zombie_stats[ stat_names[ i ] ].reset_value;

		message = stat_names[ i ] + " current: " +  cur_value + " default: " + reset_value;

		level com_printf( channel, "notitle", message, self );
		wait 0.1;
	}
	if ( !is_true( self.is_server ) )
	{
		level com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}	
}

cmd_setallphysparams_f( args )
{
	result = [];
	phys_params = args[ 0 ];

	zombies = get_round_enemy_array();

	foreach ( zombie in zombies )
	{
		zombie setphysparams( phys_params[ 0 ], phys_params[ 1 ], phys_params[ 2 ] );
	}

	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Set all zombies phys params to " + phys_params;
	return result;
}