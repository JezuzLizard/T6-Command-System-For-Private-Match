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
	level.bot_command_system_unittest_func = ::bot_unittest_func;
	level.tcs_additional_help_prints_func = ::zm_help_prints;
	while ( !is_true( level.command_init_done ) )
	{
		wait 0.05;
	}
	cmd_addcommand( "spectator", false, "spec", "spectator <name|guid|clientnum|self>", ::CMD_SPECTATOR_f, "cheat", 1, false );
	cmd_addcommand( "togglerespawn", false, "togresp", "togglerespawn <name|guid|clientnum|self>", ::CMD_TOGGLERESPAWN_f, "cheat", 1, false );
	cmd_addcommand( "killactors", false, "ka", "killactors", ::CMD_KILLACTORS_f, "cheat", 0, false );
	cmd_addcommand( "respawnspectators", false, "respspec", "respawnspectators", ::CMD_RESPAWNSPECTATORS_f, "cheat", 0, false );
	cmd_addcommand( "pause", false, "pa", "pause [minutes]", ::CMD_PAUSE_f, "cheat", 0, false );
	cmd_addcommand( "unpause", false, "up", "unpause", ::CMD_UNPAUSE_f, "cheat", 0, false );
	cmd_addcommand( "giveperk", false, "gp", "giveperk <name|guid|clientnum|self> <perk|all>", ::CMD_GIVEPERK_f, "cheat", 2, true );
	cmd_addcommand( "takeperk", false, "tp", "takeperk <name|guid|clientnum|self> <perk|all>", ::cmd_takeperk_f, "cheat", 2, true );
	cmd_addcommand( "givepermaperk", false, "gpp", "givepermaperk <name|guid|clientnum|self> <perk|all>", ::CMD_GIVEPERMAPERK_f, "cheat", 2, true );
	cmd_addcommand( "givepoints", false, "gpts", "givepoints <name|guid|clientnum|self> <amount>", ::CMD_GIVEPOINTS_f, "cheat", 2, false );
	cmd_addcommand( "givepowerup", false, "gpow", "givepowerup <name|guid|clientnum|self> <powerup>", ::CMD_GIVEPOWERUP_f, "cheat", 2, false );
	cmd_addcommand( "giveweapon", false, "gwep", "giveweapon <name|guid|clientnum|self> <weapon>", ::CMD_GIVEWEAPON_f, "cheat", 2, true );
	cmd_addcommand( "toggleperssystemforplayer", false, "tpsfp", "toggleperssystemforplayer <name|guid|clientnum|self>", ::CMD_TOGGLEPERSSYSTEMFORPLAYER_f, "cheat", 1, false );
	cmd_addcommand( "toggleoutofplayableareamonitor", false, "togoopam", "toggleoutofplayableareamonitor", ::CMD_TOGGLEOUTOFPLAYABLEAREAMONITOR_f, "cheat", 0, false );
	cmd_addcommand( "weaponlist", false, "wlist", "weaponlist", ::cmd_weaponlist_f, "none", 0, false );
	cmd_addcommand( "openalldoors", false, "openall", "openalldoors", ::cmd_openalldoors_f, "cheat", 0, false );
	cmd_addcommand( "poweruplist", false, "powlist", "poweruplist", ::cmd_poweruplist_f, "none", 0, false );
	cmd_addcommand( "perklist", false, "plist", "perklist", ::cmd_perklist_f, "none", 0, false );
	cmd_addcommand( "setround", false, "sr", "setround <round_number>", ::cmd_setround_f, "cheat", 1, false );
	cmd_addcommand( "nextround", false, "nr", "nextround", ::cmd_nextround_f, "cheat", 0, false );
	cmd_addcommand( "prevround", false, undefined, "prevround", ::cmd_prevround_f, "cheat", 0, false );

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

	cmd_addcommand( "perk", true, undefined, "perk <perk|all>", ::CMD_PERK_f, "cheat", 1, true );
	cmd_addcommand( "perkremove", true, "pr", "perk <perk|all>", ::cmd_perkremove_f, "cheat", 1, true );
	cmd_addcommand( "permaperk", true, "pp", "permaperk <perk|all>", ::CMD_PERMAPERK_f, "cheat", 1, true );
	cmd_addcommand( "points", true, "pts", "points <amount>", ::CMD_POINTS_f, "cheat", 1, false );
	cmd_addcommand( "powerup", true, "pow", "powerup <powerup>", ::CMD_POWERUP_f, "cheat", 1, false );
	cmd_addcommand( "weapon", true, "wep", "weapon <weapon>", ::CMD_WEAPON_f, "cheat", 1, true );
	cmd_addcommand( "toggleperssystem", true, "tps", "toggleperssystem", ::CMD_TOGGLEPERSSYSTEM_f, "cheat", 0, false );

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
	level thread check_for_command_alias_collisions();
	level.zm_command_init_done = true;
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

CMD_GIVEPOWERUP_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	powerup_name = arg_list[ 1 ];
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

CMD_KILLACTORS_f( arg_list )
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

CMD_GIVEPERK_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	perk_name = arg_list[ 1 ];
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

cmd_takeperk_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	perk_name = arg_list[ 1 ];
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

CMD_PAUSE_f( arg_list )
{
	result = [];
	if ( isDefined( arg_list[ 0 ] ) )
	{
		duration = arg_list[ 0 ];
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

CMD_UNPAUSE_f( arg_list )
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

CMD_GIVEPERMAPERK_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	perma_perk_name = arg_list[ 1 ];
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

CMD_GIVEPOINTS_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	points = arg_list[ 1 ];
	target add_to_player_score( points );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave " + target.name + " " + points + " points";
	return result;
}

CMD_SPECTATOR_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
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

CMD_TOGGLERESPAWN_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	should_respawn = arg_list[ 1 ];
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

CMD_RESPAWNSPECTATORS_f( arg_list )
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

CMD_GIVEWEAPON_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	weapon = arg_list[ 1 ];
	target thread weapon_give_custom( weapon, weapon_is_upgrade( weapon ), true );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave " + weapon + " to " + target.name;
	return result;
}

unlimited_weapons( player )
{
	return 5;
}

CMD_POWERUP_f( arg_list )
{
	result = [];
	powerup_name = arg_list[ 0 ];
	success = self give_powerup_zm( powerup_name );
	if ( success )
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Spawned " + powerup_name + " for you";
	}	
	return result;
}

cmd_weaponlist_f( arg_list )
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

CMD_PERK_f( arg_list )
{
	result = [];
	perk_name = arg_list[ 0 ];
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

cmd_perkremove_f( arg_list )
{
	result = [];
	perk_name = arg_list[ 0 ];
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

CMD_POINTS_f( arg_list )
{
	result = [];
	points = arg_list[ 0 ];
	self add_to_player_score( points );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave you " + points + " points";
	return result;
}

CMD_PERMAPERK_f( arg_list )
{
	result = [];
	perma_perk_name = arg_list[ 0 ];
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

CMD_WEAPON_f( arg_list )
{
	result = [];
	weapon = arg_list[ 0 ];
	self thread weapon_give_custom( weapon, weapon_is_upgrade( weapon ), true );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave you " + weapon;
	return result;
}


CMD_TOGGLEPERSSYSTEMFORPLAYER_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	on_off = cast_bool_to_str( is_true( target.tcs_disable_pers_system ), "on off" );
	target.tcs_disable_pers_system = !is_true( target.tcs_disable_pers_system );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled pers system for " + target.name + " " + on_off;
	return result;
}

CMD_TOGGLEPERSSYSTEM_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_disable_pers_system ), "on off" );
	self.tcs_disable_pers_system = !is_true( self.tcs_disable_pers_system );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled your pers system " + on_off;
	return result;
}

CMD_TOGGLEOUTOFPLAYABLEAREAMONITOR_f( arg_list )
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

cmd_openalldoors_f( arg_list )
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

cmd_poweruplist_f( arg_list )
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

cmd_perklist_f( arg_list )
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

cmd_setround_f( arg_list )
{
	result = [];
	if ( arg_list[ 0 ] > 255 || arg_list[ 0 ] < 0 )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Cannot set round to a number greater than 255 or less than 0";
		return result;
	}

	level.round_number = arg_list[ 0 ];
	change_round( arg_list[ 0 ] );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Round set to " + arg_list[ 0 ];
	return result;
}

cmd_nextround_f( arg_list )
{
	result = [];
	level.round_number++;
	change_round( level.round_number );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Round set to " + level.round_number;	
	return result;
}

cmd_prevround_f( arg_list )
{
	result = [];
	level.round_number--;
	change_round( level.round_number );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Round set to " + level.round_number;	
	return result;
}