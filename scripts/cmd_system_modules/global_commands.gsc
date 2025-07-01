#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_perms;

cmd_server_dvar_f( target_obj, args )
{
	dvarname = args[ 0 ];
	dvarvalue = args[ 1 ];
	setDvar( dvarname, dvarvalue );

	return result_cmdinfo( "Successfully set " + dvarname + " to " + dvarvalue );
}

cmd_cvarall_f( target_obj, args )
{
	dvarname = args[ 0 ];
	dvarvalue = args[ 1 ];
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] setClientDvar( dvarname, dvarvalue );
	}
	new_dvar = [];
	new_dvar[ "name" ] = dvarname;
	new_dvar[ "value" ] = dvarvalue; 
	level.clientdvars[ level.clientdvars.size ] = new_dvar;

	return result_cmdinfo( "Successfully set " + dvarname + " to " + dvarvalue + " for all players" );
}

cmd_setcvar_f( target_obj, args )
{
	target = args[ 0 ];
	dvarname = args[ 1 ];
	dvarvalue = args[ 2 ];
	target setClientDvar( dvarname, dvarvalue );

	return result_cmdinfo( "Successfully set " + target.name + "'s " + dvarname + " to " + dvarvalue );
}

cmd_givegod_f( target_obj, args )
{
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

	return result_cmdinfo( "Toggled god for " + target.name );
}

cmd_givenotarget_f( target_obj, args )
{
	target = args[ 0 ];
	target.ignoreme = !target.ignoreme;

	return result_cmdinfo( "Toggled notarget for " + target.name );
}

cmd_giveinvisible_f( target_obj, args )
{
	target = args[ 0 ];
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

	return result_cmdinfo( "Toggled invisibility for " + target.name );
}

cmd_setrank_f( target_obj, args )
{
	target = args[ 0 ];
	if ( !is_true( self.is_server ) && self.cmdpower < target.cmdpower )
	{
		return result_cmderror( "Insufficient cmdpower to set " + target.name + "'s rank" );
	}
	new_rank = args[ 1 ];
	if ( !is_true( self.is_server ) && ( level.tcs_perms.ranks[ new_rank ].cmdpower >= self.cmdpower ) && self.cmdpower < level.tcs_perms.ranks[ "host" ].cmdpower )
	{
		return result_cmderror( "You cannot set " + target.name + " to a rank higher than or equal to your own" );
	}

	target.tcs_rank = new_rank;
	target.cmdpower = level.tcs_perms.ranks[ new_rank ].cmdpower;
	add_player_perms_entry( target );
	target com_printinfo( "Your new rank is " + new_rank );

	return result_cmdinfo( "Target's new rank is " + new_rank );
}

/*
	Executes a client cmd on all players in the server. 
*/
cmd_execonallplayers_f( target_obj, args )
{
	cmd = args[ 0 ];
	cmd_find_result = scripts\cmd_system_modules\_cmd_arg::get_cmd_from_alias( cmd );
	if ( cmd_find_result.errored )
	{
		return result_cmderror( cmd_find_result.msg );
	}

	cmd_object = cmd_find_result.value;
	var_args = [];
	for ( i = 1; i < args.size; i++ )
	{
		var_args[ i - 1 ] = args[ i ];
	}
	if ( !self scripts\cmd_system_modules\_cmd_arg::test_cmd_is_valid( cmd_object, var_args ) )
	{
		return result_cmderror( "!self test_cmd_is_valid" );
	}
	players = getPlayers();
	if ( players.size == 0 )
	{
		return result_cmderror( "There are no players in the server" );
	}
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread scripts\cmd_system_modules\_cmd_execute::cmd_execute_internal( cmd_object, var_args, false, false );
	}

	return result_cmdinfo( "Executed " + cmd_object.cmd_name + " on all players" );
}

cmd_execonteam_f( target_obj, args )
{
	team = args[ 0 ];
	cmd = args[ 1 ];
	cmd_find_result = scripts\cmd_system_modules\_cmd_arg::get_cmd_from_alias( cmd );
	if ( cmd_find_result.errored )
	{
		return result_cmderror( cmd_find_result.msg );
	}

	cmd_object = cmd_find_result.value;

	var_args = [];
	for ( i = 2; i < args.size; i++ )
	{
		var_args[ i - 2 ] = args[ i ];
	}
	if ( !self scripts\cmd_system_modules\_cmd_arg::test_cmd_is_valid( cmd_object, var_args ) )
	{
		return result_cmderror( "!self test_cmd_is_valid" );
	}
	players = getPlayers( team );
	if ( players.size == 0 )
	{
		return result_cmderror( "Team has no players" );
	}
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread scripts\cmd_system_modules\_cmd_execute::cmd_execute_internal( cmd_object, var_args, false, false );
	}

	return result_cmdinfo( "Executed " + cmd_object.cmd_name + " on team " + team );
}

cmd_playerlist_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	players = getPlayers();
	if ( players.size == 0 )
	{
		return result_cmderror( "There are no players in the server" );
	}
	self thread list_players_throttled( channel, players );

	return result_cmdinfo( "" );
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
		self com_printinfo( "Use shift + ` and scroll to the bottom to view the full list" );
	}
}

cmd_cmdlist_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	self thread list_cmds_throttled( channel );
	return result_cmdinfo( "" );
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
		self com_printinfo( "Use shift + ` and scroll to the bottom to view the full list" );
	}
}

cmd_help_f( target_obj, args )
{
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
		self com_printinfo( "Use shift + ` and scroll to the bottom to view the full list" );
	}

	return result_cmdinfo( "" );
}

cmd_dodamage_f( target_obj, args )
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
			return result_cmderror( "Wrong number of parameters sent to cmd dodamage max is 9 and min is 3" );
	}

	return result_cmdinfo( "Executed dodamage on target" );
}

cmd_entitylist_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	entities = getEntArray();
	if ( entities.size <= 0 )
	{
		return result_cmderror( "There are no entities in the server" );
	}
	self thread list_entities_throttled( channel, args[ 0 ], entities );

	return result_cmdinfo( "" );
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
		self com_printinfo( "Use shift + ` and scroll to the bottom to view the full list" );
	}
}

cmd_teleportplayer_f( target_obj, args )
{
	target1 = args[ 0 ];
	target2 = args[ 1 ];
	if ( target1 == self && target2 == self )
	{
		return result_cmderror( "You cannot teleport to yourself" );
	}
	target1 setOrigin( target2.origin + anglesToForward( target2.angles ) * 64 + anglesToRight( target2.angles ) * 64 );

	return result_cmdinfo( "Successfully teleported " + target1.name + " to " + target2.name + "'s position" );
}

//Unimplemented
cmd_execonrandomplayers( target_obj, args )
{
	//count = args[ 0 ];
	//cmd = args[ 1 ];
	
}

//Unimplemented
cmd_printentitiesinradius_f( target_obj, args )
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

cmd_scrnotify_f( target_obj, args )
{
	notify_ent_str = args[ 0 ];
	notify_name = args[ 1 ];

	arg_count = args.size - 2;

	notify_ent = undefined;
	if ( notify_ent_str == "level" )
	{
		notify_ent = level;
	}
	else if ( notify_ent_str == "self" )
	{
		notify_ent = self;
	}
	else
	{
		ent_find = self scripts\zm\cmd_system_modules\_cmd_arg::cast_str_to_entity( notify_ent_str );

		if ( ent_find.errored )
		{
			return result_cmderror( ent_find.msg );
		}

		notify_ent = ent_find.value;
	}

	switch ( arg_count )
	{
		case 0:
			notify_ent notify( notify_name );
			break;
		case 1:
			notify_ent notify( notify_name, args[ 2 ] );
			break;
		case 2:
			notify_ent notify( notify_name, args[ 2 ], args[ 3 ] );
			break;
		case 3:
			notify_ent notify( notify_name, args[ 2 ], args[ 3 ], args[ 4 ] );
			break;
		default:
			return result_cmderror( "Max arguments is 3!" );
	}

	return result_cmdinfo( "Successfully delivered notify " + notify_name );
}

cmd_setdefaultcmdtarget_f( target_obj, args )
{
	
}