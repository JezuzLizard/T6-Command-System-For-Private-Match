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
	target = arg_list[ 0 ];
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
	target = arg_list[ 0 ];
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
	target = arg_list[ 0 ];
	target.ignoreme = !target.ignoreme;
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled notarget for " + target.name;
	return result;
}

CMD_GIVEINVISIBLE_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
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
	target = arg_list[ 0 ];
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
	target.cmdpower = level.tcs_ranks[ new_rank ].cmdpower;
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
		players[ i ] thread cmd_execute( cmd_to_execute, var_args, true, level.tcs_use_silent_commands, false );
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
		player thread CMD_EXECUTE( cmd_to_execute, var_args, true, level.tcs_use_silent_commands, false );
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
				if ( self has_permission_for_cmd( cmd, false ) )
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
				if ( self has_permission_for_cmd( cmd, true ) )
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
		required_bots = isDefined( arg_list[ 0 ] ) ? arg_list[ 0 ] : 1;
		setDvar( "tcs_unittest", required_bots );
		level.unittest_total_commands_used = 1;
		level thread do_unit_test();
		level notify( "unittest_start" );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Command system unit test activated";
	return result;
}

do_unit_test()
{
	while ( true )
	{
		required_bots = getDvarInt( "tcs_unittest" );
		if ( required_bots == 0 )
		{
			break;
		}
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
	self.health = 2100000000;
	flag_clear( "solo_game" );
	while ( true )
	{
		self construct_chat_message();
		wait 0.05;
	}
}

construct_chat_message()
{
	cmdalias = get_random_cmdalias();
	cmdname = get_client_cmd_from_alias( cmdalias );
	cmd_is_clientcmd = true;
	if ( cmdname == "" )
	{
		cmdname = get_server_cmd_from_alias( cmdalias );
		cmd_is_clientcmd = false;
	}
	if ( cmdname == "" )
	{
		return;
	}
	cmdargs = create_random_valid_args( cmdname );
	message = cmdname + " " + cmdargs;
	print( self.name + " executed " + message + " count " + level.unittest_total_commands_used );
	level notify( "say", message, self, true );
	level.unittest_total_commands_used++;
}

get_random_player_data()
{
	randomint = randomInt( 4 );
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
		case 3:
			return self;
	}
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
			return "player int";
		case "giveperk":
			return "player perk";
		case "powerup":
			return "powerup";
		case "weapon":
			return "weapon";
		case "perk":
			return "perk";
		/*
		case "execonallplayers":
		case "execonteam":	
			return "cmdalias";
		*/
	}
}

create_random_valid_args( cmdname )
{
	types_str = get_cmdargs_types( cmdname );
	if ( types_str == "" )
	{
		return "";
	}
	args = [];
	optional_types = strTok( types_str, "|" );
	if ( optional_types.size > 1 )
	{
		args[ args.size ] = generate_args_from_type( optional_types[ randomInt( optional_types.size ) ] );
		return;
	}
	types = strTok( types_str, " " );
	for ( i = 0; i < types.size; i++ )
	{
		args[ i ] = generate_args_from_type( types[ i ] );
	}
	arg_str = repackage_args( args );
	return arg_str;
}

generate_args_from_type( type )
{
	switch ( type )
	{
		case "player":
			return get_random_player_data();
		case "int":
			return randomint( 1000000 );
		case "team":
			return random( level.teams );
		case "cmdalias":
			return get_random_cmdalias();
		case "perk":
			perks = perk_list_zm();
			return perks[ randomInt( perks.size ) ];
		case "weapon":
			weapon_keys = getArrayKeys( level.zombie_include_weapons );
			return weapon_keys[ randomInt( weapon_keys.size ) ];
		case "powerup":
			powerup_keys = getArrayKeys( level.zombie_include_powerups );
			return powerup_keys[ randomInt( powerup_keys.size ) ];
		case "none":
			return "";
		default:	
			return "";
	}
}

get_random_cmdalias()
{
	server_command_keys = getArrayKeys( level.server_commands );
	client_command_keys = getArrayKeys( level.client_commands );
	aliases = [];
	blacklisted_cmds = array( "cvar", "permaperk" );
	for ( i = 0; i < client_command_keys.size; i++ )
	{
		cmd_is_blacklisted = false;
		for ( k = 0; k < blacklisted_cmds.size; k++ )
		{
			if ( client_command_keys[ i ] == blacklisted_cmds[ k ] )
			{
				cmd_is_blacklisted = true;
				break;
			}
		}
		if ( cmd_is_blacklisted )
		{
			continue;
		}
		for ( j = 0; j < level.client_commands[ client_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.client_commands[ client_command_keys[ i ] ].aliases[ j ];
		}
	}
	blacklisted_cmds = array( "rotate", "restart", "changemap", "unittest", "setcvar", "dvar", "cvarall", "givepermaperk", "toggleoutofplayableareamonitor", "spectator", "execonallplayers", "execonteam" );
	for ( i = 0; i < server_command_keys.size; i++ )
	{
		cmd_is_blacklisted = false;
		for ( k = 0; k < blacklisted_cmds.size; k++ )
		{
			if ( server_command_keys[ i ] == blacklisted_cmds[ k ] )
			{
				cmd_is_blacklisted = true;
				break;
			}
		}
		if ( cmd_is_blacklisted )
		{
			continue;
		}
		for ( j = 0; j < level.server_commands[ server_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.server_commands[ server_command_keys[ i ] ].aliases[ j ];
		}
	}
	return aliases[ randomInt( aliases.size ) ];
}

create_random_invalid_args( cmdname )
{

}