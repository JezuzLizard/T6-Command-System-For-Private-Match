#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_perms;

CMD_SERVER_DVAR_f( arg_list )
{
	result = [];
	dvar_name = arg_list[ 0 ];
	dvar_value = arg_list[ 1 ];
	setDvar( dvar_name, dvar_value );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + dvar_name + " to " + dvar_value;
	return result;
}

CMD_CVARALL_f( arg_list )
{
	result = [];
	dvar_name = arg_list[ 0 ];
	dvar_value = arg_list[ 1 ];
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] setClientDvar( dvar_name, dvar_value );
	}
	new_dvar = [];
	new_dvar[ "name" ] = dvar_name;
	new_dvar[ "value" ] = dvar_value; 
	level.clientdvars[ level.clientdvars.size ] = new_dvar;
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + dvar_name + " to " + dvar_value + " for all players";
	return result;
}

CMD_SETCVAR_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
	dvar_name = arg_list[ 1 ];
	dvar_value = arg_list[ 2 ];
	target setClientDvar( dvar_name, dvar_value );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + target.name + "'s " + dvar_name + " to " + dvar_value;
	return result;
}

CMD_GIVEGOD_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
	if ( !is_true( target.tcs_is_invulnerable ) )
	{
		target enableInvulnerability();
		target.tcs_is_invulnerable = true;
	}
	else 
	{
		target disableInvulnerability();
		target.tcs_is_invulnerable = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled god for " + target.name;
	return result;
}

CMD_GIVENOTARGET_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
	target.ignoreme = !target.ignoreme;
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled notarget for " + target.name;
	return result;
}

CMD_GIVEINVISIBLE_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled invisibility for " + target.name;
	if ( !is_true( target.tcs_is_invisible ) )
	{
		target hide();
		target.tcs_is_invisible = true;
	}
	else 
	{
		target show();
		target.tcs_is_invisible = false;
	}
	return result;
}

CMD_SETRANK_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
	if ( self.cmdpower < target.cmdpower )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Insufficient cmdpower to set " + target.name + "'s rank";
		return result;
	}
	if ( !isDefined( level.tcs_ranks[ arg_list[ 1 ] ] ) )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Invalid rank " + arg_list[ 1 ];
		return result;
	}
	new_rank = arg_list[ 1 ];
	if ( ( level.tcs_ranks[ new_rank ].cmdpower >= self.cmdpower ) && self.cmdpower < level.CMD_POWER_HOST )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "You cannot set " + target.name + " to a rank higher than or equal to your own";
		return result;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Target's new rank is " + new_rank;
	target.tcs_rank = new_rank;
	target.new_cmdpower = new_cmdpower;
	add_player_perms_entry( target );
	level com_printf( target com_get_cmd_feedback_channel(), "cmdinfo", "Your new rank is " + new_rank, target );
	return result;
}

/*
	Executes a client command on all players in the server. 
*/
CMD_EXECONALLPLAYERS_f( arg_list )
{
	result = [];
	cmd_to_execute = get_client_cmd_from_alias( arg_list[ 0 ] );
	if ( cmd_to_execute == "" )
	{
		cmd_to_execute = get_server_cmd_from_alias( arg_list[ 0 ] );
		if ( cmd_to_execute == "" )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Cmd alias " + arg_list[ 0 ] + " does not reference any cmd";
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "You cannot call a server cmd with execonallplayers";
		}
		return result;
	}
	var_args = [];
	for ( i = 1; i < arg_list.size; i++ )
	{
		var_args[ i - 1 ] = arg_list[ i ];
	}
	is_valid = self test_cmd_is_valid( cmd_to_execute, var_args, true );
	if ( !is_valid )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Insufficient num args sent to " + cmd_to_execute + " from execonallplayers";
		return result;
	}
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread cmd_execute( cmd_to_execute, var_args, true, level.tcs_use_silent_commands, true );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Executed " + cmd_to_execute + " on all players";			
	return result;
}

CMD_EXECONTEAM_f( arg_list )
{
	result = [];
	team = arg_list[ 0 ];
	cmd = arg_list[ 1 ];
	if ( !isDefined( level.teams[ team ] ) )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Team " + team + " is invalid";
		return result;
	}
	cmd_to_execute = get_client_cmd_from_alias( cmd );
	if ( cmd_to_execute == "" )
	{
		cmd_to_execute = get_server_cmd_from_alias( arg_list[ 0 ] );
		if ( cmd_to_execute == "" )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Cmd alias " + arg_list[ 0 ] + " does not reference any cmd";
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "You cannot call a server cmd with execonteam";
		}
		return result;
	}
	var_args = [];
	for ( i = 2; i < arg_list.size; i++ )
	{
		var_args[ i - 2 ] = arg_list[ i ];
	}
	is_valid = self test_cmd_is_valid( cmd_to_execute, var_args, true );
	if ( !is_valid )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Insufficient num args sent to " + cmd_to_execute + " from execonallplayers";
		return result;
	}
	players = getPlayers( team );
	foreach ( player in players )
	{
		player thread CMD_EXECUTE( cmd_to_execute, var_args, true, level.tcs_use_silent_commands, true );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Executed " + cmd_to_execute + " on team " + team;
	return result;	
}

CMD_PLAYERLIST_f( arg_list )
{
	channel = self com_get_cmd_feedback_channel();
	if ( channel != "con" )
	{
		channel = "iprint";
	}
	players = getPlayers();
	if ( players.size == 0 )
	{
		level com_printf( channel, "notitle", "There are no players in the server", self );
		return;
	}
	for ( i = 0; i < players.size; i++ )
	{
		if ( self.cmdpower >= level.CMD_POWER_MODERATOR )
		{
			message = "^3" + players[ i ].name + " " + players[ i ] getGUID() + " " + players[ i ] getEntityNumber();
		}
		else 
		{
			message = "^3" + players[ i ].name + " " + players[ i ] getEntityNumber();
		}
		level com_printf( channel, "notitle", message, self );
	}
	if ( !is_true( self.is_server ) )
	{
		level com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

CMD_CMDLIST_f( arg_list )
{
	channel = self com_get_cmd_feedback_channel();
	if ( channel != "con" )
	{
		channel = "iprint";
	}
	cmdnames = getArrayKeys( level.server_commands );
	for ( i = 0; i < cmdnames.size; i++ )
	{
		if ( self has_permission_for_cmd( cmdnames[ i ], false ) )
		{
			message = "^3" + level.server_commands[ cmdnames[ i ] ].usage;
			level com_printf( channel, "notitle", message, self );
		}
	}
	if ( is_true( self.is_server ) )
	{
		return;
	}
	cmdnames = getArrayKeys( level.client_commands );
	for ( i = 0; i < cmdnames.size; i++ )
	{
		if ( self has_permission_for_cmd( cmdnames[ i ], true ) )
		{
			message = "^3" + level.client_commands[ cmdnames[ i ] ].usage;
			level com_printf( channel, "notitle", message, self );
		}
	}

	level com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
}

cmd_help_f( arg_list )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	if ( channel != "con" )
	{
		channel = "iprint";
	}
	if ( is_true( self.is_server ) )
	{
		if ( isDefined( arg_list[ 0 ] ) )
		{
			cmdalias = arg_list[ 0 ];
			cmd = get_client_cmd_from_alias( cmdalias );
			if ( cmd == "" )
			{
				cmd = get_server_cmd_from_alias( cmdalias );
				if ( cmd == "" )
				{
					level com_printf( channel, "cmderror", "Cmd alias " + cmdalias + " doesn't reference any cmd", self );
					return result;
				}
			}
			if ( isDefined( level.server_commands[ cmd ] ) )
			{
				message = "^3" + level.server_commands[ cmd ].usage;
				level com_printf( channel, "notitle", message, self );
			}
			else if ( isDefined( level.client_commands[ cmd ] ) )
			{
				message = "^3" + level.client_commands[ cmd ].usage;
				level com_printf( channel, "notitle", message, self );
			}
		}
		else 
		{
			level com_printf( channel, "notitle", "^3To view cmds you can use do tcscmd cmdlist in the console", self );
			level com_printf( channel, "notitle", "^3To view players in the server do tcscmd playerlist in the console", self );
			level com_printf( channel, "notitle", "^3To view the usage of a specific cmd do tcscmd help <cmdalias>", self );
		}
	}
	else 
	{
		if ( isDefined( arg_list[ 0 ] ) )
		{
			cmdalias = arg_list[ 0 ];
			cmd = get_client_cmd_from_alias( cmdalias );
			if ( cmd == "" )
			{
				cmd = get_server_cmd_from_alias( cmdalias );
				if ( cmd == "" )
				{
					level com_printf( channel, "cmderror", "Cmd alias " + cmdalias + " doesn't reference any cmd", self );
					return result;
				}
			}
			if ( isDefined( level.server_commands[ cmd ] ) )
			{
				if ( self scripts\sp\csm\_perms::has_permission_for_cmd( cmd, false ) )
				{
					message = "^3" + level.server_commands[ cmd ].usage;
					level com_printf( channel, "notitle", message, self );
				}
				else 
				{
					level com_printf( channel, "cmderror", "You do not have permission for cmd " + cmd, self );
				}
			}
			else if ( isDefined( level.client_commands[ cmd ] ) )
			{
				if ( self scripts\sp\csm\_perms::has_permission_for_cmd( cmd, true ) )
				{
					message = "^3" + level.client_commands[ cmd ].usage;
					level com_printf( channel, "notitle", message, self );
				}
				else 
				{
					level com_printf( channel, "cmderror", "You do not have permission for cmd " + cmd, self );
				}
			}
		}
		else 
		{	
			level com_printf( channel, "notitle", "^3To view cmds you can use do /cmdlist in the chat", self );
			level com_printf( channel, "notitle", "^3To view players in the server do /playerlist in the chat", self );
			level com_printf( channel, "notitle", "^3To view the usage of a specific cmd do /help <cmdalias>", self );
			level com_printf( channel, "cmdinfo", "^3Use shift + ` and scroll to the bottom to view the full list", self );
		}
	}
	return result;
}

cmd_unittest_f( arg_list )
{
	result = [];
	level.doing_command_system_unittest = !is_true( level.doing_command_system_unittest );

	if ( level.doing_command_system_unittest )
	{
		level.no_end_game_check = true;
		required_bots = isDefined( arg_list[ 1 ] ) ? arg_list[ 1 ] : 1;
		setDvar( "tcs_unittest", required_bots );
		level thread do_unit_test();
	}
	else 
	{
		level.no_end_game_check = false;
		setDvar( "tcs_unittest", 0 );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Command system unit test " + cast_bool_to_str( level.doing_command_system_unittest, "activated deactivated" );
	return result;
}

do_unit_test()
{
	required_bots = getDvarInt( "tcs_unittest" );
	while ( required_bots > 0 )
	{
		required_bots = getDvarInt( "tcs_unittest" );
		bot_count = 0;
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[ i ] isTestClient() )
			{
				bot_count++;
			}
		}
		if ( bot_count < required_bots )
		{
			bot = addTestClient();
			while ( !isDefined( bot ) )
			{
				bot = addTestClient();
				wait 1;
			}
			bot thread activate_random_cmds();
		}

		wait 1;
	}
	for ( i = 0; i < level.players.size; i++ )
	{
		if ( level.players[ i ] isTestClient() )
		{
			kick( level.players[ i ] getEntityNumber() );
		}
	}
	level.doing_command_system_unittest = false;
}

activate_random_cmds()
{
	self endon( "disconnect" );
	while ( true )
	{
		
		wait 0.05;
	}
}

construct_chat_message( cmdname )
{

}

get_random_player_data()
{
	randomint = randomInt( 3 );
	players = getPlayers();
	random_player = players[ randomInt( players.size ) ];
	switch ( randomint )
	{
		case 0:
			return random_player getEntityNumber();
		case 1:
			return random_player getGuid();
		case 2:
			return random_player.name;
	}
}

get_random_servercmd()
{
	blacklisted_cmds = array( "rotate", "restart", "changemap", "unittest" );
	while ( !found_valid_cmd )
	{
		random_servercmd = random( level.server_commands );
		for ( i = 0; i < blacklisted_cmds.size; i++ )
		{
			if ( random_servercmd == blacklisted_cmds[ i ] )
			{
				random_servercmd = random( level.server_commands );
				break;
			}
			if ( i == blacklisted_cmds.size )
			{
				found_valid_cmd = true;
			}
		}
	}
	return random_servercmd;
}

get_random_clientcmd()
{
	return random( level.client_commands );
}

get_cmdargs_types( cmdname )
{
	switch ( cmdname )
	{
		case "cmdlist":
		case "togglehud":
		case "god":
		case "notarget":
		case "invisible":
		case "printorigin":
		case "printangles":
		case "bottomlessclip":
		case "killactors":
		case "respawnspectators":
		case "unpause":
		case "toggleoutofplayableareamonitor":
		case "toggleperssystem":
			return "";
		
		case "givegod":
		case "givenotarget":
		case "giveinvisible":
		case "teleport":
		case "spectator":
		case "togglerespawn":
		case "toggleperssystemforplayer":
			return "player";
		//case "execonallplayers":
		//case "execonteam":
			//return;
		case "playerlist":
			return "none|team";
		case "help":
			return "none|cmdalias";
		case "pause":
			return "none|int";
		case "points":
			return "int";
		case "giveweapon":
			return "player weapon";
		case "givepowerup":
			return "player powerup";
		case "givepoints":
			return "player points";
		case "giveperk":
			return "player perk";
		case "powerup":
			return "powerup";
		case "weapon":
			return "weapon";
		case "perk":
			return "perk";
	}
}

create_random_valid_args( cmdname )
{
	types_str = get_cmdargs_types( cmdname );
	if ( types_str == "" )
	{
		return "";
	}
	optional_types = strTok( types_str )
	types = strTok( types_str, " " );
	for ( i = 0; i < types.size; i++ )
	{

	}
	switch ( )
}

create_random_invalid_args( cmdname )
{

}

	CMD_ADDSERVERCOMMAND( "setcvar", "scv", "setcvar <name|guid|clientnum|self> <cvarname> <newval>", ::CMD_SETCVAR_f, "cheat", 3 );
	CMD_ADDSERVERCOMMAND( "dvar", "dv", "dvar <dvarname> <newval>", ::CMD_SERVER_DVAR_f, "cheat", 2 );
	CMD_ADDSERVERCOMMAND( "cvarall", "cva", "cvarall <cvarname> <newval>", ::CMD_CVARALL_f, "cheat", 2 );
	CMD_ADDSERVERCOMMAND( "givegod", "ggd", "givegod <name|guid|clientnum|self>", ::CMD_GIVEGOD_f, "cheat", 1 );
	CMD_ADDSERVERCOMMAND( "givenotarget", "gnt", "givenotarget <name|guid|clientnum|self>", ::CMD_GIVENOTARGET_f, "cheat", 1 );
	CMD_ADDSERVERCOMMAND( "giveinvisible", "ginv", "giveinvisible <name|guid|clientnum|self>", ::CMD_GIVEINVISIBLE_f, "cheat", 1 );
	CMD_ADDSERVERCOMMAND( "setrank", "sr", "setrank <name|guid|clientnum|self> <rank>", ::CMD_SETRANK_f, "cheat", 2 );

	CMD_ADDSERVERCOMMAND( "execonallplayers", "execonall exall", "execonallplayers <cmdname> [cmdargs] ...", ::CMD_EXECONALLPLAYERS_f, "host", 1 );
	CMD_ADDSERVERCOMMAND( "execonteam", "execteam exteam", "execonteam <team> <cmdname> [cmdargs] ...", ::CMD_EXECONTEAM_f, "host", 2 );

	CMD_ADDSERVERCOMMAND( "cmdlist", "cl", "cmdlist", ::CMD_CMDLIST_f, "none", 0, true );
	CMD_ADDSERVERCOMMAND( "playerlist", "plist", "playerlist [team]", ::CMD_PLAYERLIST_f, "none", 0, true );

	cmd_addservercommand( "help", undefined, "help [cmdalias]", ::cmd_help_f, "none", 0 );

	cmd_addservercommand( "unittest", undefined, "unittest [botcount]", ::cmd_unittest_f, "host", 0 );

	level.client_commands = [];
	CMD_ADDCLIENTCOMMAND( "togglehud", "toghud", "togglehud", ::CMD_TOGGLEHUD_f, "none", 0 );
	CMD_ADDCLIENTCOMMAND( "god", undefined, "god", ::CMD_GOD_f, "cheat", 0 );
	CMD_ADDCLIENTCOMMAND( "notarget", "nt", "notarget", ::CMD_NOTARGET_f, "cheat", 0 );
	CMD_ADDCLIENTCOMMAND( "invisible", "invis", "invisible", ::CMD_INVISIBLE_f, "cheat", 0 );
	CMD_ADDCLIENTCOMMAND( "printorigin", "printorg por", "printorigin", ::CMD_PRINTORIGIN_f, "none", 0 );
	CMD_ADDCLIENTCOMMAND( "printangles", "printang pan", "printangles", ::CMD_PRINTANGLES_f, "none", 0 );
	CMD_ADDCLIENTCOMMAND( "bottomlessclip", "botclip bcl", "bottomlessclip", ::CMD_BOTTOMLESSCLIP_f, "cheat", 0 );
	CMD_ADDCLIENTCOMMAND( "teleport", "tele", "teleport <name|guid|clientnum|origin>", ::CMD_TELEPORT_f, "cheat", 1 );
	CMD_ADDCLIENTCOMMAND( "cvar", "cv", "cvar <cvarname> <newval>", ::CMD_CVAR_f, "cheat", 2 );

	CMD_ADDSERVERCOMMAND( "spectator", "spec", "spectator <name|guid|clientnum|self>", ::CMD_SPECTATOR_f, "cheat", 1 );
	CMD_ADDSERVERCOMMAND( "togglerespawn", "togresp", "togglerespawn <name|guid|clientnum|self>", ::CMD_TOGGLERESPAWN_f, "cheat", 1 );
	CMD_ADDSERVERCOMMAND( "killactors", "ka", "killactors", ::CMD_KILLACTORS_f, "cheat", 0 );
	CMD_ADDSERVERCOMMAND( "respawnspectators", "respspec", "respawnspectators", ::CMD_RESPAWNSPECTATORS_f, "cheat", 0 );
	CMD_ADDSERVERCOMMAND( "pause", "pa", "pause [minutes]", ::CMD_PAUSE_f, "cheat", 0 );
	CMD_ADDSERVERCOMMAND( "unpause", "up", "unpause", ::CMD_UNPAUSE_f, "cheat", 0 );
	CMD_ADDSERVERCOMMAND( "giveperk", "gp", "giveperk <name|guid|clientnum|self> <perkname> ...", ::CMD_GIVEPERK_f, "cheat", 2 );
	CMD_ADDSERVERCOMMAND( "givepermaperk", "gpp", "givepermaperk <name|guid|clientnum|self> <perkname> ...", ::CMD_GIVEPERMAPERK_f, "cheat", 2 );
	CMD_ADDSERVERCOMMAND( "givepoints", "gpts", "givepoints <name|guid|clientnum|self> <amount>", ::CMD_GIVEPOINTS_f, "cheat", 2 );
	CMD_ADDSERVERCOMMAND( "givepowerup", "gpow", "givepowerup <name|guid|clientnum|self> <powerupname>", ::CMD_GIVEPOWERUP_f, "cheat", 2 );
	CMD_ADDSERVERCOMMAND( "giveweapon", "gwep", "giveweapon <name|guid|clientnum|self> <weapon> ...", ::CMD_GIVEWEAPON_f, "cheat", 2 );
	CMD_ADDSERVERCOMMAND( "toggleperssystemforplayer", "tpsfp", "toggleperssystemforplayer <name|guid|clientnum|self>", ::CMD_TOGGLEPERSSYSTEMFORPLAYER_f, "cheat", 1 );
	CMD_ADDSERVERCOMMAND( "toggleoutofplayableareamonitor", "togoopam", "toggleoutofplayableareamonitor", ::CMD_TOGGLEOUTOFPLAYABLEAREAMONITOR_f, "cheat", 0 );
	CMD_ADDCLIENTCOMMAND( "perk", undefined, "perk <perkname> ...", ::CMD_PERK_f, "cheat", 1 );
	CMD_ADDCLIENTCOMMAND( "permaperk", "pp", "permaperk <perkname> ...", ::CMD_PERMAPERK_f, "cheat", 1 );
	CMD_ADDCLIENTCOMMAND( "points", "pts", "points <amount>", ::CMD_POINTS_f, "cheat", 1 );
	CMD_ADDCLIENTCOMMAND( "powerup", "pow", "powerup <powerupname>", ::CMD_POWERUP_f, "cheat", 1 );
	CMD_ADDCLIENTCOMMAND( "weapon", "wep", "weapon <weaponname> ...", ::CMD_WEAPON_f, "cheat", 1 );
	CMD_ADDCLIENTCOMMAND( "toggleperssystem", "tps", "toggleperssystem", ::CMD_TOGGLEPERSSYSTEM_f, "cheat", 0 );