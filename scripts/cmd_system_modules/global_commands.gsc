#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_listener;
#include scripts\cmd_system_modules\_perms;
#include scripts\cmd_system_modules\_text_parser;

#include common_scripts\utility;
#include maps\mp\_utility;

CMD_SERVER_DVAR_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		dvar_name = arg_list[ 0 ];
		dvar_value = arg_list[ 1 ];
		setDvar( dvar_name, dvar_value );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "dvar: Successfully set " + dvar_name + " to " + dvar_value;
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "dvar: Usage dvar <dvarname> <newval>";
	}
	return result;
}

CMD_CVARALL_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		dvar_name = arg_list[ 0 ];
		dvar_value = arg_list[ 1 ];
		foreach ( player in level.players )
		{
			player setClientDvar( dvar_name, dvar_value );
		}
		new_dvar = [];
		new_dvar[ "name" ] = dvar_name;
		new_dvar[ "value" ] = dvar_value; 
		level.clientdvars[ level.clientdvars.size ] = new_dvar;
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully set " + dvar_name + " to " + dvar_value + " for all players";
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage cvarall <dvarname> <newval>";
	}
	return result;
}

CMD_SETCVAR_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 3 )
	{
		player = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( player ) )
		{
			dvar_name = arg_list[ 1 ];
			dvar_value = arg_list[ 2 ];
			player setClientDvar( dvar_name, dvar_value );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Successfully set " + player.name + "'s " + dvar_name + " to " + dvar_value;
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
		result[ "message" ] = "Usage cvar <name|guid|clientnum|self> <cvarname> <newval>";
	}
	return result;
}

CMD_GIVEGOD_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
		else 
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Toggled god for " + target.name;
		}
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage givegod <name|guid|clientnum|self>";
	}
	if ( isDefined( target ) )
	{
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
	}
	return result;
}

CMD_GIVENOTARGET_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
		else 
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Toggled notarget for " + target.name;
		}
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage givenotarget <name|guid|clientnum|self>";
	}
	if ( isDefined( target ) )
	{
		target.ignoreme = !target.ignoreme;
	}
	return result;
}

CMD_GIVEINVISIBLE_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
		else 
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Toggled invisibility for " + target.name;
		}
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage giveinvisible <name|guid|clientnum|self>";
	}
	if ( isDefined( target ) )
	{
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
	}
	return result;
}

CMD_SETRANK_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			if ( isDefined( arg_list[ 1 ] ) )
			{
				if ( self.cmdpower_server > target.cmdpower_server )
				{
					switch ( arg_list[ 1 ] )
					{
						case "none":
							new_cmdpower_server = level.CMD_POWER_NONE;
							new_cmdpower_client = level.CMD_POWER_NONE;
							new_rank = level.TCS_RANK_NONE;
							break;
						case "user":
							new_cmdpower_server = level.CMD_POWER_USER;
							new_cmdpower_client = level.CMD_POWER_USER;
							new_rank = level.TCS_RANK_USER;
							break;
						case "trs":
						case "trusted":
							new_cmdpower_server = level.CMD_POWER_TRUSTED_USER;
							new_cmdpower_client = level.CMD_POWER_TRUSTED_USER;
							new_rank = level.TCS_RANK_TRUSTED_USER;
							break;
						case "ele":
						case "elevated":
							new_cmdpower_server = level.CMD_POWER_ELEVATED_USER;
							new_cmdpower_client = level.CMD_POWER_ELEVATED_USER;
							new_rank = level.TCS_RANK_ELEVATED_USER;
							break;
						case "mod":
						case "moderator":
							new_cmdpower_server = level.CMD_POWER_MODERATOR;
							new_cmdpower_client = level.CMD_POWER_MODERATOR;
							new_rank = level.TCS_RANK_MODERATOR;
							break;
						case "cht":
						case "cheat":
							new_cmdpower_server = level.CMD_POWER_CHEAT;
							new_cmdpower_client = level.CMD_POWER_CHEAT;
							new_rank = level.TCS_RANK_CHEAT;
							break;
						case "host":
						case "owner":
							new_cmdpower_server = level.CMD_POWER_HOST;
							new_cmdpower_client = level.CMD_POWER_HOST;
							new_rank = level.TCS_RANK_HOST;
							break;
						default:
							break;
					}
					if ( isDefined( new_rank ) )
					{
						result[ "filter" ] = "cmdinfo";
						result[ "message" ] = "Target's new rank is " + new_rank;
						target.tcs_rank = new_rank;
						target.cmdpower_server = new_cmdpower_server;
						target.cmdpower_client = new_cmdpower_client;
						add_player_perms_entry( target );
						level COM_PRINTF( target COM_GET_CMD_FEEDBACK_CHANNEL(), "cmdinfo", "Your new rank is " + new_rank, target );
					}
					else 
					{
						result[ "filter" ] = "cmderror";
						result[ "message" ] = "Invalid rank " + arg_list[ 1 ];
					}
				}
				else 
				{
					result[ "filter" ] = "cmderror";
					result[ "message" ] = "Insufficient cmdpower to set " + target.name + "'s rank";
				}
			}
			else 
			{
				result[ "filter" ] = "cmderror";
				result[ "message" ] = "Usage setrank <name|guid|clientnum|self> <rank>";	
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
		result[ "message" ] = "Usage setrank <name|guid|clientnum|self> <rank>";	
	}
	return result;
}

/*
	Executes a client command on all players in the server. 
*/
CMD_EXECONALLPLAYERS_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		cmd_to_execute = get_client_cmd_from_alias( arg_list[ 0 ] );
		if ( cmd_to_execute != "" )
		{
			var_args = [];
			for ( i = 1; i < arg_list.size; i++ )
			{
				var_args[ i - 1 ] = arg_list[ i ];
			}
			foreach ( player in level.players )
			{
				player thread CMD_EXECUTE( cmd_to_execute, var_args, true, level.tcs_use_silent_commands, true );
			}
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Executed " + cmd_to_execute + " on all players";			
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			if ( isDefined( arg_list[ 0 ] ) )
			{
				result[ "message" ] = "Cmd " + arg_list[ 0 ] + " is invalid";
			}
			else 
			{
				result[ "message" ] = "Cmd is invalid";
			}
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "execonallplayers <cmdname> [cmdargs]...";
	}
	return result;
}

CMD_EXECONTEAM_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		team = arg_list[ 0 ];
		cmd = arg_list[ 1 ];
		if ( isDefined( level.teams[ team ] ) )
		{
			cmd_to_execute = get_client_cmd_from_alias( cmd );
			if ( cmd_to_execute != "" )
			{
				var_args = [];
				for ( i = 2; i < arg_list.size; i++ )
				{
					var_args[ i - 2 ] = arg_list[ i ];
				}
				players = getPlayers( team );
				foreach ( player in players )
				{
					player thread CMD_EXECUTE( cmd_to_execute, var_args, true, level.tcs_use_silent_commands, true );
				}
				result[ "filter" ] = "cmdinfo";
				result[ "message" ] = "Executed " + cmd_to_execute + " on team " + team;			
			}
			else 
			{
				result[ "filter" ] = "cmderror";
				if ( isDefined( cmd ) )
				{
					result[ "message" ] = "Cmd " + cmd + " is invalid";
				}
				else 
				{
					result[ "message" ] = "Cmd is invalid";
				}
			}
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Team " + team + " is invalid";
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "execonteam <team> <cmdname> [cmdargs]...";
	}
	return result;	
}