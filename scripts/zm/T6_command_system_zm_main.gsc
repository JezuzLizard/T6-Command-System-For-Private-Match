#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weapons;

#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_text_parser;
#include scripts\cmd_system_modules\_listener;
#include scripts\cmd_system_modules\_perms;
#include scripts\zm\cmd_system_modules_zm\_overrides;
#include scripts\zm\cmd_system_modules_zm\_zm_cmd_util;

#include common_scripts\utility;
#include maps\mp\_utility;

main()
{
	replaceFunc( maps\mp\zombies\_zm_pers_upgrades_system::pers_upgrades_monitor, ::pers_upgrades_monitor_override );
	while ( !is_true( level.command_init_done ) )
	{
		wait 0.05;
	}
	CMD_ADDSERVERCOMMAND( "spectator", "spectator spec", "spectator <name|guid|clientnum|self>", ::CMD_SPECTATOR_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "togglerespawn", "togglerespawn togresp", "togglerespawn <name|guid|clientnum|self>", ::CMD_TOGGLERESPAWN_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "killactors", "killactors ka", "killactors", ::CMD_KILLACTORS_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "respawnspectators", "respawnspectators respspec", "respawnspectators", ::CMD_RESPAWNSPECTATORS_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "pause", "pause pa", "pause [minutes]", ::CMD_PAUSE_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "unpause", "unpause up", "unpause", ::CMD_UNPAUSE_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "giveperk", "giveperk gp", "giveperk <name|guid|clientnum|self> <perkname> ...", ::CMD_GIVEPERK_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "givepermaperk", "givepermaperk gpp", "givepermaperk <name|guid|clientnum|self> <perkname> ...", ::CMD_GIVEPERMAPERK_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "givepoints", "givepoints gpts", "givepoints <name|guid|clientnum|self> <amount>", ::CMD_GIVEPOINTS_f, level.CMD_POWER_CHEAT );
	//CMD_ADDSERVERCOMMAND( "givepowerup", "givepowerup gpow", "givepowerup <name|guid|clientnum|self> <powerupname>", ::CMD_GIVEPOWERUP_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "giveweapon", "giveweapon gwep", "giveweapon <name|guid|clientnum|self> <weapon> ...", ::CMD_GIVEWEAPON_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "toggleperssystemforplayer", "toggleperssystemforplayer tpsfp", "toggleperssystemforplayer <name|guid|clientnum|self>", ::CMD_TOGGLEPERSSYSTEMFORPLAYER_f, level.CMD_POWER_CHEAT );

	CMD_ADDCLIENTCOMMAND( "perk", "perk pk", "perk <perkname> ...", ::CMD_PERK_f, level.CMD_POWER_CHEAT );
	CMD_ADDCLIENTCOMMAND( "permaperk", "permaperk pp", "permaperk <perkname> ...", ::CMD_PERMAPERK_f, level.CMD_POWER_CHEAT );
	CMD_ADDCLIENTCOMMAND( "points", "points pts", "points <amount>", ::CMD_POINTS_f, level.CMD_POWER_CHEAT );
	//CMD_ADDCLIENTCOMMAND( "powerup", "powerup pow", "powerup <powerupname>", ::CMD_POWERUP_f, level.CMD_POWER_CHEAT );
	CMD_ADDCLIENTCOMMAND( "weapon", "weapon wep", "weapon <weaponname> ...", ::CMD_WEAPON_f, level.CMD_POWER_CHEAT );
	CMD_ADDCLIENTCOMMAND( "toggleperssystem", "toggleperssystem tps", "toggleperssystem", ::CMD_TOGGLEPERSSYSTEM_f, level.CMD_POWER_CHEAT );
	level.zm_command_init_done = true;
}

CMD_GIVEPOWERUP_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			powerup_name = get_powerup_from_alias_zm( arg_list[ 1 ] );
			valid_powerup_list = powerup_list_zm();
			powerup_is_available = isInArray( valid_powerup_list, powerup_name );
			if ( !powerup_is_available )
			{
				result[ "filter" ] = "cmderror";
				result[ "message" ] = "Powerup " + powerup_name + " is not available on this map";	
			}
			else 
			{
				target give_powerup_zm( powerup_name );
				result[ "filter" ] = "cmdinfo";
				result[ "message" ] = "Spawned " + powerup_name + " for " + target.name;	
			}
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage givepowerup <name|guid|clientnum|self> <powerupname>";
	}
	return result;
}

give_powerup_zm( powerup_name )
{
	direction = self getplayerangles();
	direction_vec = anglestoforward( direction );
	scale = 20;
	direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
	trace = bullettrace( direction_vec, direction_vec, 0, undefined );
	powerup = maps\mp\zombies\_zm_powerups::specific_powerup_drop( powerup_name, trace["position"] );
	if ( powerup_name == "teller_withdrawl" )
	{
		powerup.value = 1000;
	}
}

CMD_KILLACTORS_f( arg_list )
{
	result = [];
	maps\mp\zombies\_zm_game_module::kill_all_zombies();
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Killed all zombies";
	return result;
}

CMD_GIVEPERK_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size > 1 )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			for ( i = 1; i < arg_list.size; i++ )
			{
				perk_name = get_perk_from_alias_zm( arg_list[ i ] );
				if ( perk_name != "all" )
				{
					valid_perk_list = perk_list_zm();
					perk_is_available = isInArray( valid_perk_list, perk_name );
					if ( !perk_is_available )
					{
						result[ "filter" ] = "cmderror";
						result[ "message" ] = "Perk " + perk_name + " is not available on this map";	
					}
					else 
					{
						target give_perk_zm( perk_name );
						result[ "filter" ] = "cmdinfo";
						result[ "message" ] = "Gave perk " + perk_name + " to " + target.name;	
					}
				}
				else 
				{
					valid_perk_list = perk_list_zm();
					foreach ( perk in valid_perk_list )
					{
						target give_perk_zm( perk );
					}
					result[ "filter" ] = "cmdinfo";
					result[ "message" ] = "Gave perk all perks to " + target.name;
					break;
				}
			}
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage giveperk <name|guid|clientnum|self> <perkname> ...";
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
		duration = int( arg_list[ 0 ] );
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
		player.target.tcs_is_invulnerable = true;
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
		player.target.tcs_is_invulnerable = false;
	}
}

CMD_GIVEPERMAPERK_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size > 1 )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			for ( i = 1; i < arg_list.size; i++ )
			{
				perma_perk_name = get_perma_perk_from_alias( arg_list[ i ] );
				if ( perma_perk_name != arg_list[ i ] && perma_perk_name != "all" )
				{
					target give_perma_perk( perma_perk_name );
				}
				else if ( perma_perk_name == "all" )
				{
					target give_all_perma_perks();
					result[ "filter" ] = "cmdinfo";
					result[ "message" ] = "Gave all perma perks to " + target.name;
					break;
				}
			}
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage givepermaperk <name|guid|clientnum|self> <perkname> ...";
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
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			points = int( arg_list[ 1 ] );
			target add_to_player_score( points );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Gave " + target.name + " " + points + " points";
		}
		else 
		{

			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage givepoints <name|guid|clientnum|self> <amount>";
	}
	return result;
}

CMD_SPECTATOR_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Successfully made " + target.name + " a spectator";
		}
		else 
		{

			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	if ( isDefined( target ) )
	{
		target spawnspectator();
		if ( !isDefined( target.tcs_original_respawn ) )
		{
			target.tcs_original_respawn = target.spectator_respawn;
		}
		target.spectator_respawn = undefined;
	}
	return result;
}

CMD_TOGGLERESPAWN_f( arg_list )
{
	result = [];
	should_respawn = arg_list[ 1 ];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = target.name + " has their respawn toggled";
		}
		else 
		{

			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	if ( isDefined( target ) )
	{
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
	}
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
	if ( array_validate( arg_list ) && arg_list.size > 1 )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			if ( arg_list.size > 2 )
			{
				target notify( "stop_player_too_many_weapons_monitor" );
				level.get_player_weapon_limit = ::unlimited_weapons;
			}
			for ( i = 1; i < arg_list.size; i++ )
			{
				weapon = arg_list[ i ];
				weapon_can_be_given = weapon_is_available( weapon );
				if ( weapon_can_be_given )
				{
					target thread weapon_give_custom_thread( weapon, weapon_is_upgrade( weapon ), false, i );
					result[ "filter" ] = "cmdinfo";
					result[ "message" ] = "Gave " + weapon + " to " + target.name;
				}
				else 
				{
					result[ "filter" ] = "cmderror";
					result[ "message" ] = weapon + " is not available on this map";
				}
			}
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage giveweapon <name|guid|clientnum|self> <weapon> ...";
	}
	return result;
}

unlimited_weapons( player )
{
	return 10;
}

CMD_POWERUP_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		powerup_name = get_powerup_from_alias_zm( arg_list[ 0 ] );
		valid_powerup_list = powerup_list_zm();
		powerup_is_available = isInArray( valid_powerup_list, powerup_name );
		if ( !powerup_is_available )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Powerup " + powerup_name + " is not available on this map";	
		}
		else 
		{
			self give_powerup_zm( powerup_name );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Spawned " + powerup_name + " for you";	
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage powerup <powerupname>";
	}
	return result;
}

CMD_PERK_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		for ( i = 0; i < arg_list.size; i++ )
		{
			perk_name = get_perk_from_alias_zm( arg_list[ i ] );
			if ( perk_name != "all" )
			{
				valid_perk_list = perk_list_zm();
				perk_is_available = isInArray( valid_perk_list, perk_name );
				if ( !perk_is_available )
				{
					result[ "filter" ] = "cmderror";
					result[ "message" ] = "Perk " + perk_name + " is not available on this map";	
				}
				else 
				{
					self give_perk_zm( perk_name );
					result[ "filter" ] = "cmdinfo";
					result[ "message" ] = "Gave you " + perk_name ;	
				}
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
				break;
			}
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage perk <perkname> ...";
	}
	return result;
}

CMD_POINTS_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		points = int( arg_list[ 0 ] );
		self add_to_player_score( points );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave you " + points + " points";
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage points <amount>";
	}
	return result;
}

CMD_PERMAPERK_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		for ( i = 0; i < arg_list.size; i++ )
		{
			perma_perk_name = get_perma_perk_from_alias( arg_list[ i ] );
			if ( perma_perk_name != arg_list[ i ] && perma_perk_name != "all" )
			{
				self give_perma_perk( perma_perk_name );
				result[ "filter" ] = "cmdinfo";
				result[ "message" ] = "Gave you " + perma_perk_name;
			}
			else if ( perma_perk_name == "all" )
			{
				self give_all_perma_perks();
				result[ "filter" ] = "cmdinfo";
				result[ "message" ] = "Gave you all perma perks";
				break;
			}
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage permaperk <perkname> ...";
	}
	return result;
}

CMD_WEAPON_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		if ( arg_list.size > 2 )
		{
			self notify( "stop_player_too_many_weapons_monitor" );
			level.get_player_weapon_limit = ::unlimited_weapons;
		}
		for ( i = 0; i < arg_list.size; i++ )
		{
			weapon = arg_list[ i ];
			weapon_can_be_given = weapon_is_available( weapon );
			if ( weapon_can_be_given )
			{
				self thread weapon_give_custom_thread( weapon, weapon_is_upgrade( weapon ), true, i );
				result[ "filter" ] = "cmdinfo";
				result[ "message" ] = "Gave you " + weapon;
			}
			else 
			{
				result[ "filter" ] = "cmderror";
				result[ "message" ] = weapon + " is not available on this map";
			}
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage weapon <weapon> ...";
	}
	return result;
}

weapon_give_custom_thread( weapon, is_upgraded, should_switch_weapon, index )
{
	wait( 0.05 * index );
	self weapon_give_custom( weapon, is_upgraded, should_switch_weapon );
}

CMD_TOGGLEPERSSYSTEMFORPLAYER_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			on_off = cast_bool_to_str( is_true( target.tcs_disable_pers_system ), "on off" );
			target.tcs_disable_pers_system = !is_true( target.tcs_disable_pers_system );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Toggled pers system for " + target.name + " " + on_off;
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage toggleperssystemforplayer <name|guid|clientnum|self>";
	}
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