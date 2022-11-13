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
	if ( !is_true( self.is_server ) && self.cmdpower < target.cmdpower )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Insufficient cmdpower to set " + target.name + "'s rank";
		return result;
	}
	new_rank = arg_list[ 1 ];
	if ( !is_true( self.is_server ) && ( level.tcs_ranks[ new_rank ].cmdpower >= self.cmdpower ) && self.cmdpower < level.CMD_POWER_HOST )
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
	cmd = arg_list[ 0 ];
	cmd_to_execute = get_server_cmd_from_alias( cmd );
	if ( cmd_to_execute != "" )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "You cannot call a server cmd with execonallplayers";
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
	if ( players.size == 0 )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "There are no players in the server";
		return result;
	}
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread cmd_execute( cmd_to_execute, var_args, true, false, false );
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
	cmd_to_execute = get_server_cmd_from_alias( cmd );
	if ( cmd_to_execute != "" )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "You cannot call a server cmd with execonteam";
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
	if ( players.size == 0 )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Team has no players";
		return result;
	}
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread cmd_execute( cmd_to_execute, var_args, true, false, false );
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
		if ( is_true( self.is_server ) || self.cmdpower >= level.CMD_POWER_MODERATOR )
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

cmd_entitylist_f( arg_list )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	if ( channel != "con" )
	{
		channel = "iprint";
	}
	entities = getEntArray();
	if ( isDefined( arg_list[ 0 ] ) )
	{
		for ( i = 0; i < entities.size; i++ )
		{
			ent = entities[ i ];
			if ( !is_entity_valid( ent ) )
			{
				continue;
			}
			if ( ent.targetname == arg_list[ 0 ] )
			{
				level com_printf( channel, "notitle", "Ent classname " + ent.classname + " targetname " + ent.targetname + " script_noteworthy " + ent.script_noteworthy + " origin " + ent.origin, self );
			}
		}
	}
	else
	{
		for ( i = 0; i < entities.size; i++ )
		{
			ent = entities[ i ];
			if ( !is_entity_valid( ent ) )
			{
				continue;
			}
			level com_printf( channel, "notitle", "Ent classname " + ent.classname + " targetname " + ent.targetname + " script_noteworthy " + ent.script_noteworthy + " origin " + ent.origin, self );
		}
	}
	return result;	
}