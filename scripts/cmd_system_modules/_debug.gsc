#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;

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
	else 
	{
		setDvar( "tcs_unittest", 0 );
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
	if ( cmdname == "" )
	{
		cmdname = get_server_cmd_from_alias( cmdalias );
	}
	if ( cmdname == "" )
	{
		return;
	}
	cmdargs = create_random_valid_args( cmdname );
	
	if ( cmdargs.size == 0 )
	{
		message = cmdname;
	}
	else 
	{
		arg_str = repackage_args( cmdargs );
		message = cmdname + " " + arg_str;
	}
	cmd_log = self.name + " executed " + message + " count " + level.unittest_total_commands_used;
	level com_printf( "con", "notitle", cmd_log );
	level com_printf( "g_log", "cmdinfo", cmd_log );
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
			return "self";
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
			return "none";
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
			return "none|wholenum";
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
		case "execonallplayers":
			return "cmdalias";
		case "execonteam":	
			return "team cmdalias";
		default:
			return "";
	}
}

create_random_valid_args( cmdname )
{
	args = [];
	types_str = get_cmdargs_types( cmdname );
	if ( types_str == "none" )
	{
		return args;
	}
	optional_types = strTok( types_str, "|" );
	if ( optional_types.size > 1 )
	{
		args[ args.size ] = generate_args_from_type( optional_types[ randomInt( optional_types.size ) ] );
		return args;
	}
	types = strTok( types_str, " " );
	for ( i = 0; i < types.size; i++ )
	{
		if ( types[ i ] == "cmdalias" )
		{
			subcmdname = get_client_cmd_from_alias( types[ i ] );
			if ( subcmdname == "" )
			{
				return args;
			}
			subcmdargs = [];
			subcmdargs = create_random_valid_args( subcmdname );
			subtypes = get_cmdargs_types( subcmdname );
			finalargs = args;
			for ( j = 0; j < subtypes.size; j++ )
			{
				finalargs[ finalargs.size ] = generate_args_from_type( subtypes[ j ], "execonallplayers execonteam" );
			}
			return finalargs;
		}
		args[ i ] = generate_args_from_type( types[ i ] );
	}
	
	return args;
}

generate_args_from_type( type, exclusions = "none" )
{
	switch ( type )
	{
		case "player":
			return get_random_player_data();
		case "wholenum":
			return randomint( 1000000 );
		case "int":
			return cointoss() ? randomint( 1000000 ) : randomint( 1000000 ) * -1;
		case "team":
			return random( level.teams );
		case "cmdalias":
			return get_random_cmdalias( exclusions );
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

get_random_cmdalias( exclusions )
{
	server_command_keys = getArrayKeys( level.server_commands );
	client_command_keys = getArrayKeys( level.client_commands );
	aliases = [];
	blacklisted_cmds_client = array( "cvar", "permaperk" );
	exclusions_array = strTok( exclusions, " " );
	for ( i = 0; i < client_command_keys.size; i++ )
	{
		cmd_is_blacklisted = false;
		for ( j = 0; j < blacklisted_cmds_client.size; j++ )
		{
			if ( client_command_keys[ i ] == blacklisted_cmds_client[ j ] )
			{
				cmd_is_blacklisted = true;
				break;
			}
		}
		/*
		for ( j = 0; j < exclusions_array.size; j++ )
		{
			if ( client_command_keys[ i ] == exclusions_array[ j ] )
			{
				cmd_is_blacklisted = true;
				break;
			}
		}
		*/
		if ( cmd_is_blacklisted )
		{
			continue;
		}
		for ( j = 0; j < level.client_commands[ client_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.client_commands[ client_command_keys[ i ] ].aliases[ j ];
		}
	}
	blacklisted_cmds_server = array( "rotate", "restart", "changemap", "unittest", "setcvar", "dvar", "cvarall", "givepermaperk", "toggleoutofplayableareamonitor", "spectator" );
	for ( i = 0; i < server_command_keys.size; i++ )
	{
		cmd_is_blacklisted = false;
		for ( k = 0; k < blacklisted_cmds_server.size; k++ )
		{
			if ( server_command_keys[ i ] == blacklisted_cmds_server[ k ] )
			{
				cmd_is_blacklisted = true;
				break;
			}
		}
		/*
		for ( j = 0; j < exclusions_array.size; j++ )
		{
			if ( client_command_keys[ i ] == exclusions_array[ j ] )
			{
				cmd_is_blacklisted = true;
				break;
			}
		}
		*/
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