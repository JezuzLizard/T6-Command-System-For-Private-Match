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
	is_clientcmd = true;
	if ( cmdname == "" )
	{
		cmdname = get_server_cmd_from_alias( cmdalias );
		is_clientcmd = false;
	}
	if ( cmdname == "" )
	{
		return;
	}
	cmdargs = create_random_valid_args( cmdname, is_clientcmd );
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

get_cmdargs_types( cmdname, is_clientcmd )
{
	if ( is_clientcmd )
	{
		return level.client_commands[ cmdname ].argtypes;
	}
	else 
	{
		return level.server_commands[ cmdname ].argtypes;
	}
}

create_random_valid_args( cmdname, is_clientcmd )
{
	args = [];
	types = get_cmdargs_types( cmdname, is_clientcmd );
	
	if ( !isDefined( types ) )
	{
		return args;
	}
	for ( i = 0; i < types.size; i++ )
	{
		args[ i ] = generate_args_from_type( types[ i ] );
	}
	
	return args;
}

generate_args_from_type( type )
{
	if ( isDefined( level.tcs_arg_type_handlers[ type ] ) )
	{
		return [[ level.tcs_arg_type_handlers[ type ].rand_gen_func ]]() + "";
	}
	return "";
}

get_random_cmdalias()
{
	server_command_keys = getArrayKeys( level.server_commands );
	client_command_keys = getArrayKeys( level.client_commands );
	aliases = [];
	blacklisted_cmds_client = array( "cvar", "permaperk" );
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
		if ( cmd_is_blacklisted )
		{
			continue;
		}
		for ( j = 0; j < level.client_commands[ client_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.client_commands[ client_command_keys[ i ] ].aliases[ j ];
		}
	}
	blacklisted_cmds_server = array( "rotate", "restart", "changemap", "unittest", "setcvar", "dvar", "cvarall", "givepermaperk", "toggleoutofplayableareamonitor", "spectator", "execonteam", "execonallplayers" );
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