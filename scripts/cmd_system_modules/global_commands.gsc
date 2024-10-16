#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_perms;

cmd_server_dvar_f( args )
{
	result = [];
	dvar_name = args[ 0 ];
	dvar_value = args[ 1 ];
	setDvar( dvar_name, dvar_value );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + dvar_name + " to " + dvar_value;
	return result;
}

cmd_cvarall_f( args )
{
	result = [];
	dvar_name = args[ 0 ];
	dvar_value = args[ 1 ];
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

cmd_setcvar_f( args )
{
	result = [];
	target = args[ 0 ];
	dvar_name = args[ 1 ];
	dvar_value = args[ 2 ];
	target setClientDvar( dvar_name, dvar_value );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + target.name + "'s " + dvar_name + " to " + dvar_value;
	return result;
}

cmd_givegod_f( args )
{
	result = [];
	target = args[ 0 ];
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

cmd_givenotarget_f( args )
{
	result = [];
	target = args[ 0 ];
	target.ignoreme = !target.ignoreme;
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled notarget for " + target.name;
	return result;
}

cmd_giveinvisible_f( args )
{
	result = [];
	target = args[ 0 ];
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

cmd_setrank_f( args )
{
	result = [];
	target = args[ 0 ];
	if ( !is_true( self.is_server ) && self.cmdpower < target.cmdpower )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Insufficient cmdpower to set " + target.name + "'s rank";
		return result;
	}
	new_rank = args[ 1 ];
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
	Executes a client cmd on all players in the server. 
*/
cmd_execonallplayers_f( args )
{
	result = [];
	cmd = args[ 0 ];
	cmd_to_execute = get_cmd_from_alias( cmd );
	if ( !level.tcs_cmds[ cmd_to_execute ].is_clientcmd )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "You cannot call a server cmd with execonallplayers";
		return result;
	}
	var_args = [];
	for ( i = 1; i < args.size; i++ )
	{
		var_args[ i - 1 ] = args[ i ];
	}
	if ( !self test_cmd_is_valid( cmd_to_execute, var_args ) )
	{
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
		players[ i ] thread cmd_execute_internal( cmd_to_execute, var_args, false, false );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Executed " + cmd_to_execute + " on all players";			
	return result;
}

cmd_execonteam_f( args )
{
	result = [];
	team = args[ 0 ];
	cmd = args[ 1 ];
	cmd_to_execute = get_cmd_from_alias( cmd );
	if ( !level.tcs_cmds[ cmd_to_execute ].is_clientcmd )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "You cannot call a server cmd with execonteam";
		return result;
	}
	var_args = [];
	for ( i = 2; i < args.size; i++ )
	{
		var_args[ i - 2 ] = args[ i ];
	}
	if ( !self test_cmd_is_valid( cmd_to_execute, var_args ) )
	{
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
		players[ i ] thread cmd_execute_internal( cmd_to_execute, var_args, false, false );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Executed " + cmd_to_execute + " on team " + team;
	return result;	
}

cmd_playerlist_f( args )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	players = getPlayers();
	if ( players.size == 0 )
	{
		level com_printf( channel, "notitle", "There are no players in the server", self );
		return;
	}
	self thread list_players_throttled( channel, players );
	return result;
}

list_players_throttled( channel, players )
{
	self notify( "listing_players" );
	self endon( "listing_players" );
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
		wait 0.1;
	}
	if ( !is_true( self.is_server ) )
	{
		level com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

cmd_cmdlist_f( args )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	self thread list_cmds_throttled( channel );
	return result;
}

list_cmds_throttled( channel )
{
	self notify( "listing_cmds" );
	self endon( "listing_cmds" );
	cmds = getArrayKeys( level.tcs_cmds );
	for ( i = 0; i < cmds.size; i++ )
	{
		if ( self has_permission_for_cmd( cmds[ i ] ) )
		{
			message = level.tcs_cmds[ cmds[ i ] ].usage;
			
			level com_printf( channel, "notitle", message, self );
			wait 0.1;
		}
	}
	if ( !is_true( self.is_server ) )
	{
		level com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

cmd_help_f( args )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	if ( is_true( self.is_server ) )
	{
		level com_printf( channel, "notitle", "^3To view cmds you can use tcscmd cmdlist in the console", self );
		level com_printf( channel, "notitle", "^3To view players in the server do tcscmd playerlist in the console", self );
		level com_printf( channel, "notitle", "^3To view the usage of a specific cmd do tcscmd help <cmdalias>", self );
		if ( isDefined( level.tcs_additional_help_prints_func ) )
		{
			self [[ level.tcs_additional_help_prints_func ]]( channel );
		}
	}
	else 
	{
		valid_cmd_tokens = getDvar( "tcs_cmd_tokens" );
		if ( level.tcs_allow_hidden_cmds )
		{
			level com_printf( channel, "notitle", "^3Valid cmd tokens are / " + valid_cmd_tokens, self );
		}
		else 
		{
			level com_printf( channel, "notitle", "^3Valid cmd tokens are " + valid_cmd_tokens, self );
		}
		level com_printf( channel, "notitle", "^3To view cmds you can use cmdlist prefixed with the cmd token", self );
		level com_printf( channel, "notitle", "^3To view players in the server do playerlist prefixed with the cmd token", self );
		level com_printf( channel, "notitle", "^3To view the usage of a specific cmd do help <cmdalias> prefixed with the cmd token", self );
		if ( isDefined( level.tcs_additional_help_prints_func ) )
		{
			self [[ level.tcs_additional_help_prints_func ]]( channel );
		}
		level com_printf( channel, "cmdinfo", "^3Use shift + ` and scroll to the bottom to view the full list", self );
	}
	return result;
}

cmd_dodamage_f( args )
{
	result = [];
	target = args[ 0 ];
	damage = args[ 1 ];
	pos = args[ 2 ];
	attacker = args[ 3 ];
	inflictor = args[ 4 ];
	hitloc = args[ 5 ];
	mod = args[ 6 ];
	idflags = args[ 7 ];
	weapon = args[ 8 ];
	switch ( args.size )
	{
		case 3:
			target dodamage( damage, pos );
			break;
		case 4:
			target dodamage( damage, pos, attacker );
			break;
		case 5:
			target dodamage( damage, pos, attacker, inflictor );
			break;
		case 6:
			target dodamage( damage, pos, attacker, inflictor, hitloc );
			break;
		case 7:
			target dodamage( damage, pos, attacker, inflictor, hitloc, mod );
			break;
		case 8:
			target dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags );
			break;
		case 9:
			target dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags, weapon );
			break;
		default:
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Too many parameters sent to cmd dodamage max is 9";
			return result;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Executed dodamage on target";
	return result;
}

cmd_entitylist_f( args )
{
	result = [];
	channel = self com_get_cmd_feedback_channel();
	entities = getEntArray();
	if ( entities.size <= 0 )
	{
		level com_printf( channel, "notitle", "There are no entities in the server", self );
		return result;
	}
	self thread list_entities_throttled( channel, args[ 0 ], entities );
	return result;	
}

list_entities_throttled( channel, str, entities )
{
	self notify( "listing_entities" );
	self endon( "listing_entities" );
	if ( isDefined( str ) )
	{
		for ( i = 0; i < entities.size; i++ )
		{
			ent = entities[ i ];
			if ( !is_entity_valid( ent ) )
			{
				continue;
			}
			if ( isDefined( ent.targetname ) && ent.targetname == str )
			{
				if ( isDefined( ent.classname ) )
				{
					if ( isDefined( ent.script_notetworthy ) )
					{
						level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " targetname " + ent.targetname + " script_noteworthy " + ent.script_noteworthy + " origin " + ent.origin, self );
					}
					else 
					{
						level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " targetname " + ent.targetname + " origin " + ent.origin, self );
					}
				}
				else 
				{
					level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " targetname " + ent.targetname + " origin " + ent.origin, self );
				}
				wait 0.1;
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
			if ( isDefined( ent.classname ) )
			{
				if ( isDefined( ent.targetname ) )
				{
					if ( isDefined( ent.script_noteworthy ) )
					{
						level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " targetname " + ent.targetname + " script_noteworthy " + ent.script_noteworthy + " origin " + ent.origin, self );
					}
					else 
					{
						level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " targetname " + ent.targetname + " origin " + ent.origin, self );
					}
				}
				else 
				{
					level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " origin " + ent.origin, self );
				}
			}
			else 
			{
				level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " origin " + ent.origin, self );
			}
			wait 0.1;
		}
	}
	if ( !is_true( self.is_server ) )
	{
		level com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

cmd_teleportplayer_f( args )
{
	result = [];
	target1 = args[ 0 ];
	target2 = args[ 1 ];
	if ( target1 == self && target2 == self )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "You cannot teleport to yourself";
		return result;
	}
	target1 setOrigin( target2.origin + anglesToForward( target2.angles ) * 64 + anglesToRight( target2.angles ) * 64 );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully teleported " + target1.name + " to " + target2.name + "'s position";
	return result;	
}

//Unimplemented
cmd_execonrandomplayers( args )
{
	//count = args[ 0 ];
	//cmd = args[ 1 ];
	
}

//Unimplemented
cmd_printentitiesinradius_f( args )
{
	/*
	result = [];
	radius = 1000.0;
	if ( isDefined( args[ 0 ] ) )
	{
		radius = args[ 0 ];
	}
	entity_search_name = "";
	if ( isDefined( args[ 1 ] ) )
	{
		entity_search_name = args[ 1 ];
	}
	*/
}