#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;

cmd_unittest_validargs_f( arg_list )
{
	result = [];
	level.doing_command_system_unittest = !is_true( level.doing_command_system_unittest );
	if ( level.doing_command_system_unittest )
	{
		required_bots = isDefined( arg_list[ 0 ] ) ? arg_list[ 0 ] : 1;
		setDvar( "tcs_unittest", required_bots );
		level.unittest_total_commands_used = 1;
		level thread set_command_rate();
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

set_command_rate()
{
	level.unittest_command_rate = 0.05;
	while ( true )
	{
		if ( !sessionModeIsZombiesGame() && level.players.size > 12 )
		{
			level.unittest_command_rate = 0.1;
		}
		else 
		{
			level.unittest_command_rate = 0.05;
		}
		wait 1;
	}
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
			if ( is_true( level.players[ i ].pers["isBot"] ) )
			{
				bot_count++;
			}
		}
		if ( bot_count < required_bots )
		{
			// the first test client spawned might be 
			bot = undefined;
    		while (!isdefined(bot))
    		{
	    		bot = addtestclient();
    		}

			bot.pers["isBot"] = true;
			if ( isDefined( level.bot_command_system_unittest_func ) )
			{
				bot [[ level.bot_command_system_unittest_func ]]();
			}
		}

		wait 1;
	}
	for ( i = 0; i < level.players.size; i++ )
	{
		if ( is_true( level.players[ i ].pers["isBot"] ) )
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
	if ( sessionModeIsZombiesGame() )
	{	
		flag_clear( "solo_game" );
	}
	while ( !isDefined( self._connected ) )
	{
		wait 1;
	}

	while ( true )
	{
		self construct_chat_message();
		wait level.unittest_command_rate;
	}
}

construct_chat_message()
{
	cmdalias = arg_generate_rand_cmdalias();
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
	cmdargs = create_random_valid_args2( cmdname, is_clientcmd );
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

create_random_valid_args2( cmdname, is_clientcmd )
{
	args = [];
	types = get_cmdargs_types( cmdname, is_clientcmd );

	if ( !isDefined( types ) )
	{
		return args;
	}
	if ( is_clientcmd )
	{
		minargs = level.client_commands[ cmdname ].minargs;
	}
	else 
	{
		minargs = level.server_commands[ cmdname ].minargs;
	}

	for ( i = 0; i < minargs; i++ )
	{
		args[ i ] = generate_args_from_type( types[ i ] );
	}

	if ( cointoss() ) // 50% chance we don't add optional args
	{
		return args;
	}

	max_optional_args = randomInt( types.size );

	for ( i = minargs; i < max_optional_args; i++ )
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

cmd_unittest_invalidargs_f( arg_list )
{
	result = [];
	return result;
}