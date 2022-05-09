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
		result[ "message" ] = "cvarall: Successfully set " + dvar_name + " to " + dvar_value + " for all players";
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "cvarall: Usage cvarall <dvarname> <newval>";
	}
	return result;
}

CMD_CVAR_f( arg_list )
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
			result[ "message" ] = "cvar: Successfully set " + player.name + " " + dvar_name + " to " + dvar_value;
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "cvar: Could not find player";
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "cvar: Usage cvar <name|guid|clientnum|self> <cvarname> <newval>";
	}
	return result;
}

CMD_GOD_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "god: Could not find player";
		}
		else 
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "god: Toggled god for " + target.name;
		}
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "god: Usage god <name|guid|clientnum|self>";
	}
	if ( isDefined( target ) )
	{
		if ( !is_true( target.is_invulnerable ) )
		{
			target enableInvulnerability();
			target.is_invulnerable = true;
		}
		else 
		{
			target disableInvulnerability();
			target.is_invulnerable = false;
		}
	}
	return result;
}

CMD_NOTARGET_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "notarget: Could not find player";
		}
		else 
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "notarget: Toggled notarget for " + target.name;
		}
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "notarget: Usage notarget <name|guid|clientnum|self>";
	}
	if ( isDefined( target ) )
	{
		if ( !is_true( target.is_notarget ) )
		{
			target.ignoreme = true;
			target.is_notarget = true;
		}
		else 
		{
			target.ignoreme = false;
			target.is_notarget = false;
		}
	}
	return result;
}

CMD_INVISIBLE_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "invisible: Could not find player";
		}
		else 
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "invisible: Toggled invisibility for " + target.name;
		}
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "invisible: Usage invisible <name|guid|clientnum|self>";
	}
	if ( isDefined( target ) )
	{
		if ( !is_true( target.is_invisible ) )
		{
			target hide();
			target.is_invisible = true;
		}
		else 
		{
			target show();
			target.is_invisible = false;
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
						result[ "message" ] = "setrank: Target's new rank is " + new_rank;
						target.tcs_rank = new_rank;
						target.cmdpower_server = new_cmdpower_server;
						target.cmdpower_client = new_cmdpower_client;
						add_player_perms_entry( target );
						level COM_PRINTF( COM_GET_CMD_FEEDBACK_CHANNEL(), "cmdinfo", "Your new rank is " + new_rank, target );
					}
					else 
					{
						result[ "filter" ] = "cmderror";
						result[ "message" ] = "setrank: Invalid rank " + arg_list[ 1 ];
					}
				}
				else 
				{
					result[ "filter" ] = "cmderror";
					result[ "message" ] = "setrank: Insufficient cmdpower to set " + target.name + "'s rank";
				}
			}
			else 
			{
				result[ "filter" ] = "cmderror";
				result[ "message" ] = "setrank: Usage setrank <name|guid|clientnum|self> <rank>";	
			}
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "setrank: Could not find player";	
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "setrank: Usage setrank <name|guid|clientnum|self> <rank>";	
	}
	return result;
}