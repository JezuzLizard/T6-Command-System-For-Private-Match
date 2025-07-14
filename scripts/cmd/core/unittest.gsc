#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd\core\_utility;

autoexec start_unittest()
{
	do_it = getdvarint( "tcs_unittest_enabled" );

	if ( !do_it )
	{
		return;
	}

	addcallback( "on_player_connect", ::unittest_connect );

	unittest_cmd = cmd_add( "unittest", ::cmd_unittest_validargs_f, "unittest [botcount] [duration]" );
	unittest_cmd arg_obj_add_cmd( "positive_int positive_int", 0, 2 );

	testcmd_cmd = cmd_add( "testcmd", ::cmd_testcmd_f, "testcmd <cmdalias> [threadcount] [duration]" );
	testcmd_cmd arg_obj_add_cmd( "cmdalias positive_int positive_int", 1, 3 );
}

private unittest_connect()
{
	if ( self istestclient() )
	{
		if ( is_true( level.doing_cmd_system_testcmd ) )
		{
			if ( isdefined( self.specific_cmd ) )
			{
				self thread activate_specific_cmd();
			}
		}
		else if ( is_true( level.doing_cmd_system_unittest ) )
		{
			self thread activate_random_cmds();
		}
	}
}

private cmd_unittest_validargs_f( args )
{
	result = [];
	level.doing_cmd_system_unittest = !is_true( level.doing_cmd_system_unittest );
	if ( level.doing_cmd_system_unittest )
	{
		if ( !is_true( level.cmd_system_unittest_first_run ) )
		{
			level.cmd_system_unittest_first_run = true;
		}
		required_bots = isDefined( args[ 0 ] ) ? args[ 0 ] : 1;
		if ( isDefined( args[ 1 ] ) )
			level thread end_unittest_after_time( args[ 1 ] );
		setDvar( "tcs_unittest", required_bots );
		level.unittest_total_cmds_used = 0;
		level thread set_cmd_rate();
		level thread do_unit_test();
		level notify( "unittest_start" );
	}
	else 
	{
		setDvar( "tcs_unittest", 0 );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Cmd system unit test activated";
	return result;
}

private cmd_testcmd_f( args )
{
	result = [];
	level.doing_cmd_system_unittest = !is_true( level.doing_cmd_system_unittest );
	level.doing_cmd_system_testcmd = !is_true( level.doing_cmd_system_testcmd );
	if ( level.doing_cmd_system_testcmd )
	{
		level.unittest_total_cmds_used = 0;
		level thread test_cmd_for_time( args[ 0 ], args[ 1 ], args[ 2 ] );
		level thread test_cmd_kick_bots_at_end();
	}
	else 
	{
		level notify( "stop_testcmd" );
	}

	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Testcmd " + scripts\cmd_system_modules\_cmd_arg::cast_bool_to_str( level.doing_cmd_system_testcmd, "activated deactivated" ) + " for cmd " + args[ 0 ];
	return result;
}

private set_cmd_rate()
{
	level.unittest_cmd_rate = 0.05;
	while ( true )
	{
		if ( level.players.size > 12 )
		{
			level.unittest_cmd_rate = 0.1;
		}
		else 
		{
			level.unittest_cmd_rate = 0.05;
		}
		wait 1;
	}
}

private do_unit_test()
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
	level.doing_cmd_system_unittest = false;
}

private manage_unittest_bots( required_bots, cmd )
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
		bot maps\mp\zombies\_zm::reset_rampage_bookmark_kill_times();
		if ( isDefined( cmd ) )
		{
			bot.specific_cmd = cmd;
		}
	}
}

private activate_random_cmds()
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
		wait level.unittest_cmd_rate;
	}
}

private construct_chat_message_for_unittest()
{
	cmdalias = arg_obj_cmdalias_generate();
	cmd_find_result = scripts\cmd_system_modules\_cmd_arg::cast_str_to_cmd( cmdalias );
	if ( cmd_find_result.errored )
	{
		return;
	}

	cmd_object = cmd_find_result.value;
	cmdargs = self create_random_valid_args2( cmd_find_result.value );
	if ( cmdargs.size == 0 )
	{
		message = cmd_object.cmd_name;
	}
	else 
	{
		arg_str = repackage_args( cmdargs );
		message = cmd_object.cmd_name + " " + arg_str;
	}
	cmd_log = self.name + " executed " + message + " count " + level.unittest_total_cmds_used;
	level com_printf( "con", "notitle", cmd_log );
	level com_printf( "g_log", "cmdinfo", cmd_log );
	level notify( "say", message, self, true );
	level.unittest_total_cmds_used++;
}

private create_random_valid_args2( cmd_object )
{
	args = [];
	types = cmd_object.arg_types;

	if ( !isDefined( types ) )
	{
		return args;
	}
	min_args = cmd_object.min_args;
	for ( i = 0; i < min_args; i++ )
	{
		args[ i ] = self generate_args_from_type( types[ i ] );
	}

	max_optional_args = randomInt( types.size );

	for ( i = min_args; i < max_optional_args; i++ )
	{
		args[ i ] = self generate_args_from_type( types[ i ] );
	}
	return args;
}

private generate_args_from_type( type )
{
	if ( isDefined( level.tcs_arg_type_handlers[ type ] ) )
	{
		return self [[ level.tcs_arg_type_handlers[ type ].rand_gen_func ]]() + "";
	}
	level com_printf( "con|g_log", "cmderror", "Tried to generate args for " + type + " but no rand_gen_func handler exists for it" );
	return "";
}

private end_unittest_after_time( time_in_minutes )
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

private test_cmd_for_time( cmd, threadcount = 1, duration )
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
		cmd_object = level.tcs_cmds[ cmd ];
		if ( level.players.size < getDvarInt( "sv_maxclients" ) )
		{
			break;
		}
		//manage_unittest_bots( 1, cmd_object.cmd_name );
		level thread testcmd_thread_server( cmd_object.cmd_name );
	}
}

private end_testcmd_after_time( time_in_minutes )
{
	level endon( "stop_testcmd" );
	for ( i = 0; i < ( time_in_minutes * 60 ); i++ )
	{
		wait 1;
	}
	level notify( "stop_testcmd" );
}

private testcmd_thread_server( cmd )
{
	level endon( "stop_testcmd" );
	while ( true )
	{
		level.server construct_chat_message_for_testcmd( cmd );
		wait 0.05;
	}
}

private construct_chat_message_for_testcmd( cmd )
{
	cmdargs = self create_random_valid_args2( cmd );
	if ( cmdargs.size == 0 )
	{
		message = cmd;
	}
	else 
	{
		arg_str = repackage_args( cmdargs );
		message = cmd + " " + arg_str;
	}
	cmd_log = self.name + " executed " + message + " count " + level.unittest_total_cmds_used;
	level com_printf( "con", "notitle", cmd_log );
	level com_printf( "g_log", "cmdinfo", cmd_log );
	level notify( "say", message, self, true );
	level.unittest_total_cmds_used++;
}

private activate_specific_cmd()
{
	level endon( "stop_testcmd" );
	self endon( "disconnect" );
	while ( true )
	{
		self construct_chat_message_for_testcmd( self.specific_cmd );
		wait 0.05;
	}
}

private test_cmd_kick_bots_at_end()
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