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
		if ( !is_true( level.command_system_unittest_first_run ) )
		{
			level.command_system_unittest_first_run = true;
			add_unittest_cmd_exclusions();
		}
		required_bots = isDefined( arg_list[ 0 ] ) ? arg_list[ 0 ] : 1;
		if ( isDefined( arg_list[ 1 ] ) )
			level thread end_unittest_after_time( arg_list[ 1 ] );
		setDvar( "tcs_unittest", required_bots );
		level.unittest_total_commands_used = 0;
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
	if ( isDefined( level.custom_unittest_bot_manager_func ) )
	{
		level thread [[ level.custom_unittest_bot_manager_func ]]();
		return;
	}
	while ( true )
	{
		required_bots = getDvarInt( "tcs_unittest" );
		if ( required_bots == 0 )
		{
			break;
		}
		manage_unittest_bots( required_bots );
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

manage_unittest_bots( required_bots, cmdname )
{
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
		bot = undefined;
		//Need to do this in T6 because the bots can fail to be added for no reason sometimes
		while ( !isdefined( bot ) && ( getNumConnectedPlayers() < getDvarInt( "sv_maxclients" ) ) )
		{
			bot = addtestclient();
		}
		if ( !isDefined( bot ) )
		{
			return;
		}
		bot.pers[ "isBot" ] = true;
		if ( isDefined( level.bot_command_system_unittest_func ) )
		{
			bot thread [[ level.bot_command_system_unittest_func ]]();
		}
		if ( isDefined( cmdname ) )
		{
			bot.specific_cmd = cmdname;
		}
	}
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
		self construct_chat_message_for_unittest();
		wait level.unittest_command_rate;
	}
}

construct_chat_message_for_unittest()
{
	cmdalias = arg_generate_rand_cmdalias();
	//logprint( "random cmdalias: " + cmdalias + "\n" );
	cmdname = get_cmd_from_alias( cmdalias );
	if ( cmdname == "" )
	{
		return;
	}
	//logprint( "random cmdname: " + cmdname + "\n" );
	cmdargs = self create_random_valid_args2( cmdname );
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

get_cmdargs_types( cmdname )
{
	return level.tcs_commands[ cmdname ].argtypes;
}

create_random_valid_args2( cmdname )
{
	//message = "cmdname: " + cmdname;
	//logprint( message + "\n" );
	args = [];
	types = get_cmdargs_types( cmdname );

	if ( !isDefined( types ) )
	{
		return args;
	}
	minargs = level.tcs_commands[ cmdname ].minargs;
	//message = "minargs: " + minargs;
	//logprint( message + "\n" );
	for ( i = 0; i < minargs; i++ )
	{
		args[ i ] = self generate_args_from_type( types[ i ] );
		//message1 = "types defined: " + isDefined( types[ i ] ) + " args defined: " + isDefined( args[ i ] );
		//logprint( message1 + "\n" );
		//message = "minargs: " + minargs +  " types[" + i + "]: " + types[ i ] + " args[" + i + "]: " + args[ i ];
		//logprint( message + "\n" );
	}

	max_optional_args = randomInt( types.size );

	//message = "max_optional_args: " + max_optional_args;
	//logprint( message + "\n" );
	for ( i = minargs; i < max_optional_args; i++ )
	{
		args[ i ] = self generate_args_from_type( types[ i ] );
		//message = "max_optional_args: " + max_optional_args + " types[" + i + "]: " + types[ i ] + " args[" + i + "]: " + args[ i ];
		//logprint( message + "\n" );
	}
	return args;
}

generate_args_from_type( type )
{
	if ( isDefined( level.tcs_arg_type_handlers[ type ] ) )
	{
		return self [[ level.tcs_arg_type_handlers[ type ].rand_gen_func ]]() + "";
	}
	level com_printf( "con|g_log", "cmderror", "Tried to generate args for " + type + " but no rand_gen_func handler exists for it" );
	return "";
}

cmd_unittest_invalidargs_f( arg_list )
{
	result = [];
	return result;
}

end_unittest_after_time( time_in_minutes )
{
	time_passed_in_seconds = 0;
	time_required_in_seconds = time_in_minutes * 60;
	while ( time_passed_in_seconds < time_required_in_seconds )
	{
		wait 1;
		time_passed_in_seconds++;
	}
	setDvar( "tcs_unittest", 0 );
}

cmd_testcmd_f( arg_list )
{
	result = [];
	level.doing_command_system_unittest = !is_true( level.doing_command_system_unittest );
	level.doing_command_system_testcmd = !is_true( level.doing_command_system_testcmd );
	if ( level.doing_command_system_testcmd )
	{
		level.unittest_total_commands_used = 0;
		level thread test_cmd_for_time( arg_list[ 0 ], arg_list[ 1 ], arg_list[ 2 ] );
		level thread test_cmd_kick_bots_at_end();
	}
	else 
	{
		level notify( "stop_testcmd" );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Testcmd " + cast_bool_to_str( level.doing_command_system_testcmd, "activated deactivated" ) + " for cmd " + arg_list[ 0 ];
}

test_cmd_for_time( cmdname, threadcount = 1, duration )
{
	if ( isDefined( duration ) )
	{
		level thread end_testcmd_after_time( duration );
	}
	// Need at least one bot because most cmds use a player as a target
	if ( !isDefined( level.players ) || level.players.size <= 0 )
	{
		manage_unittest_bots( 1 );
	}
	for ( i = 0; i < threadcount; i++ )
	{
		if ( level.tcs_commands[ cmdname ].is_clientcmd )
		{
			if ( getPlayers().size < getDvarInt( "sv_maxclients" ) )
			{
				break;
			}
			manage_unittest_bots( 1, cmdname );
		}
		else 
		{
			level thread testcmd_thread_server( cmdname );
		}
	}
}

end_testcmd_after_time( time_in_minutes )
{
	level endon( "stop_testcmd" );
	for ( i = 0; i < ( time_in_minutes * 60 ); i++ )
	{
		wait 1;
	}
	level notify( "stop_testcmd" );
}

testcmd_thread_server( cmdname )
{
	level endon( "stop_testcmd" );
	while ( true )
	{
		level.server construct_chat_message_for_testcmd( cmdname );
		wait 0.05;
	}
}

construct_chat_message_for_testcmd( cmdname )
{
	cmdargs = self create_random_valid_args2( cmdname );
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

activate_specific_cmd()
{
	level endon( "stop_testcmd" );
	self endon( "disconnect" );
	while ( true )
	{
		waittillframeend;
		self construct_chat_message_for_testcmd( self.specific_cmd );
		wait 0.05;
	}
}

test_cmd_kick_bots_at_end()
{
	level waittill( "stop_testcmd" );
	for ( i = 0; i < level.players.size; i++ )
	{
		if ( is_true( level.players[ i ].pers["isBot"] ) )
		{
			kick( level.players[ i ] getEntityNumber() );
		}
	}
}

add_unittest_cmd_exclusions()
{
	cmd_add_unittest_exclusion( "rotate" );
	cmd_add_unittest_exclusion( "restart" );
	cmd_add_unittest_exclusion( "changemap" );
	cmd_add_unittest_exclusion( "unittest" );
	cmd_add_unittest_exclusion( "unittestinvalidargs" );
	cmd_add_unittest_exclusion( "setcvar" );
	cmd_add_unittest_exclusion( "dvar" );
	cmd_add_unittest_exclusion( "cvarall" );
	cmd_add_unittest_exclusion( "givepermaperk" );
	cmd_add_unittest_exclusion( "toggleoutofplayableareamonitor" );
	cmd_add_unittest_exclusion( "spectator" );
	cmd_add_unittest_exclusion( "execonteam" );
	cmd_add_unittest_exclusion( "execonallplayers" );
	cmd_add_unittest_exclusion( "testcmd" );
	cmd_add_unittest_exclusion( "entitylist" );
	cmd_add_unittest_exclusion( "weaponlist" );
	cmd_add_unittest_exclusion( "poweruplist" );
	cmd_add_unittest_exclusion( "perklist" );
	cmd_add_unittest_exclusion( "cvar" );
	cmd_add_unittest_exclusion( "permaperk" );
	cmd_add_unittest_exclusion( "setglobalzombiestat" );
}