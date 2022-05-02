#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_score;

#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;
#include scripts/cmd_system_modules/_text_parser;
#include scripts/cmd_system_modules/_vote;
#include scripts/cmd_system_modules/_listener;
#include scripts/cmd_system_modules/_perms;

#include common_scripts/utility;
#include maps/mp/_utility;

main()
{
	flag_wait( "tcs_init_done" );
	CMD_ADDSERVERCOMMAND( "spectator", "spectator spec", "spectator <name|guid|clientnum|self>", ::CMD_SPECTATOR_f, level.CMD_POWER_ADMIN );
	CMD_ADDSERVERCOMMAND( "togglerespawn", "togglerespawn togresp", "togglerespawn <name|guid|clientnum|self>", ::CMD_TOGGLERESPAWN_f, level.CMD_POWER_ADMIN );
	CMD_ADDSERVERCOMMAND( "killactors", "killactors ka", "killactors", ::CMD_KILLACTORS_f, level.CMD_POWER_ADMIN );
	CMD_ADDSERVERCOMMAND( "respawnspectators", "respawnspectators respspec", "respawnspectators", ::CMD_RESPAWNSPECTATORS_f, level.CMD_POWER_ADMIN );
	CMD_ADDSERVERCOMMAND( "pause", "pause pa", "pause [minutes]", ::CMD_PAUSE_f, level.CMD_POWER_ADMIN );
	CMD_ADDSERVERCOMMAND( "unpause", "unpause up", "unpause", ::CMD_UNPAUSE_f, level.CMD_POWER_ADMIN );
	CMD_ADDSERVERCOMMAND( "giveperk", "giveperk gp", "giveperk <name|guid|clientnum|self> <perkname> ...", ::CMD_GIVEPERK_f, level.CMD_POWER_ADMIN );
	CMD_ADDSERVERCOMMAND( "givepermaperk", "givepermaperk gpp", "givepermaperk <name|guid|clientnum|self> <perkname> ...", ::CMD_GIVEPERMAPERK_f, level.CMD_POWER_ADMIN );
	CMD_ADDSERVERCOMMAND( "givepoints", "givepoints gpts", "givepoints <name|guid|clientnum|self> <amount>", ::CMD_GIVEPOINTS_f, level.CMD_POWER_ADMIN );
	CMD_ADDSERVERCOMMAND( "givepowerup", "givepowerup gpow", "givepowerup <name|guid|clientnum|self> <powerupname>", ::CMD_GIVEPOWERUP_f, level.CMD_POWER_ADMIN );
}

CMD_GIVEPOWERUP_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "giveperk: Could not find player";
		}
		else 
		{
			powerup_name = get_powerup_from_alias_zm( arg_list[ 1 ] );
			valid_powerup_list = powerup_list_zm();
			powerup_is_available = isInArray( valid_powerup_list, powerup_name );
			if ( !powerup_is_available )
			{
				result[ "filter" ] = "cmderror";
				result[ "message" ] = "givepowerup: Powerup " + powerup_name + " is not available on this map";	
			}
			else 
			{
				target give_powerup_zm( powerup_name );
				result[ "filter" ] = "cmdinfo";
				result[ "message" ] = "givepowerup: Gave perk " + powerup_name + " to " + target.name;	
			}
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "givepowerup: Usage givepowerup <name|guid|clientnum|self> <powerupname>";
	}
	return result;
}

give_powerup_zm( powerup_name )
{
	direction = self getplayerangles();
	direction_vec = anglestoforward( direction );
	eye = self geteye();
	scale = 8000;
	direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
	trace = bullettrace( eye, eye + direction_vec, 0, undefined );
	level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop( powerup_name, trace["position"] );
}

CMD_KILLACTORS_f( arg_list )
{
	result = [];
	maps\mp\zombies\_zm_game_module::kill_all_zombies();
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "killactors: Killed all zombies";
	return result;
}

CMD_GIVEPERK_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size > 1 )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "giveperk: Could not find player";
		}
		else 
		{
			perk_name = get_perk_from_alias_zm( arg_list[ 1 ] );
			if ( perk_name != "all" )
			{
				valid_perk_list = perk_list_zm();
				perk_is_available = isInArray( valid_perk_list, perk_name );
				if ( !perk_is_available )
				{
					result[ "filter" ] = "cmderror";
					result[ "message" ] = "giveperk: Perk " + perk_name + " is not available on this map";	
				}
				else 
				{
					target give_perk_zm( perk_name );
					result[ "filter" ] = "cmdinfo";
					result[ "message" ] = "giveperk: Gave perk " + perk_name + " to " + target.name;	
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
				result[ "message" ] = "giveperk: Gave perk all perks to " + target.name;
			}
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "giveperk: Usage giveperk <name|guid|clientnum|self> <perkname>";
	}
	return result;
}

give_perk_zm( perkname )
{
	self give_perk( perkname, true );
}

CMD_PAUSE_f( arg_list )
{
	result = [];
	if ( isDefined( arg_list[ 0 ] ) )
	{
		duration = int( arg_list[ 0 ] );
		level thread game_pause( duration );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "pause: Game paused for " + duration + " minutes";
	}
	else 
	{
		level thread game_pause( -1 );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "pause: Game paused indefinitely use unpause to end the pause";
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
	result[ "message" ] = "unpause: Game unpaused";
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
	}
}

CMD_GIVEPERMAPERK_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size > 1 )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "givepermaperk: Could not find player";
		}
		else 
		{
			if ( arg_list.size > 2 )
			{
				for ( i = 1; i < arg_list.size; i++ )
				{
					perma_perk_name = get_perma_perk_from_alias( arg_list[ i ] );
					if ( perma_perk_name != arg_list[ i ] && perma_perk_name != "all" )
					{
						target give_perma_perk( perma_perk_name );
					}
				}
				number = arg_list.size - 1;
				result[ "filter" ] = "cmdinfo";
				result[ "message" ] = "givepermaperk: Gave " + number + " perma perks to " + target.name;
			}
			else 
			{
				perma_perk_name = get_perma_perk_from_alias( arg_list[ i ] );
				if ( perma_perk_name != arg_list[ i ] && perma_perk_name != "all" )
				{
					target give_perma_perk( perma_perk_name );
					result[ "filter" ] = "cmdinfo";
					result[ "message" ] = "givepermaperk: Gave perma perk" + perma_perk_name + " to " + target.name;
				}
				else if ( perma_perk_name == "all" )
				{
					target give_all_perma_perks();
					result[ "filter" ] = "cmdinfo";
					result[ "message" ] = "givepermaperk: Gave all perma perks to " + target.name;
				}
				else
				{
					result[ "filter" ] = "cmderror";
					result[ "message" ] = "givepermaperk: Perk " + perma_perk_name + " is not a valid perma perk";	
				}
			}
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "givepermaperk: Usage givepermaperk <name|guid|clientnum|self> <perkname>";
	}
	return result;
}

give_perma_perk( perk_name )
{
	self maps\mp\zombies\_zm_stats::increment_client_stat( perk_name, 0 );
}

give_all_perma_perks()
{
	perk_keys = level.pers_upgrades_keys;
	foreach ( key in perk_keys )
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
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "givepoints: Could not find player";
		}
		else 
		{
			points = int( arg_list[ 1 ] );
			target add_to_player_score( points );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "givepoints: Gave " + target.name + " " + points + " points";
		}
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "givepoints: Usage givepoints <name|guid|clientnum|self> <amount>";
	}
	return result;
}

CMD_SPECTATOR_f( arg_list )
{
	result = [];
	should_respawn = arg_list[ 1 ];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "spectator: Could not find player";
		}
		else 
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "spectator: Successfully made " + target.name + " a spectator";
		}
	}
	if ( isDefined( target ) )
	{
		target spawnspectator();
		target.tcs_original_respawn = target.spectator_respawn;
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
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "togglerespawn: Could not find player";
		}
		else 
		{
			currently_respawning = isDefined( target.spectator_respawn );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = ( currently_respawning ? "togglerespawn: " + target.name + " will no longer respawn" : "togglerespawn: " + target.name + " will respawn again" );
		}
	}
	if ( isDefined( target ) )
	{
		currently_respawning = isDefined( target.spectator_respawn );
		target.tcs_original_respawn = target.spectator_respawn;
		target.spectator_respawn = currently_respawning ? undefined : target.tcs_original_respawn;
	}
	return result;
}

CMD_RESPAWNSPECTATORS_f( arg_list )
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
}