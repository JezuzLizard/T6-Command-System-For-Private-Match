#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

autoexec start_unittest()
{
	addcallback( "on_player_connect", ::unittest_connect );

	cmd_block_set_module_group( "unittest" );
	cmd_block_set_rank_group( "cheat" );
	unittest_cmd = cmd_add( "unittest", ::cmd_unittest_validargs_f, "unittest [botcount] [duration] [rate]" );
	unittest_cmd arg_obj_add_cmd( "positive_int positive_int positive_float", 0, 3 );
	unittest_cmd make_cmd_immune_to_unittest();

	testcmd_cmd = cmd_add( "testcmd", ::cmd_testcmd_f, "testcmd <cmdalias> [threadcount] [duration]" );
	testcmd_cmd arg_obj_add_cmd( "cmdalias positive_int positive_int", 1, 3 );
	testcmd_cmd make_cmd_immune_to_unittest();
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

private cmd_unittest_validargs_f( param )
{
	required_bots = _DEFAULT( param.a[ 0 ], 1 );
	duration = _DEFAULT( param.a[ 1 ], 0 );
	rate = _DEFAULT( param.a[ 2 ], 0.5 );
	level.doing_cmd_system_unittest = !is_true( level.doing_cmd_system_unittest );
	if ( level.doing_cmd_system_unittest )
	{
		if ( !is_true( level.cmd_system_unittest_first_run ) )
		{
			level.cmd_system_unittest_first_run = true;
		}
		
		if ( duration > 0 )
		{
			level thread end_unittest_after_time( duration );
		}
			
		setDvar( "tcs_unittest", required_bots );
		level.unittest_total_cmds_used = 0;
		level thread set_cmd_rate( rate );
		level thread do_unit_test();
		level notify( "unittest_start" );
	}
	else 
	{
		setDvar( "tcs_unittest", 0 );
	}

	return result_cmdinfo( "Cmd system unit test activated" );
}

private cmd_testcmd_f( param )
{
	cmd = param.a[ 0 ];
	threadcount = _DEFAULT( param.a[ 1 ], 1 );
	duration = _DEFAULT( param.a[ 2 ], 0 );
	level.doing_cmd_system_unittest = !is_true( level.doing_cmd_system_unittest );
	level.doing_cmd_system_testcmd = !is_true( level.doing_cmd_system_testcmd );
	if ( level.doing_cmd_system_testcmd )
	{
		level.unittest_total_cmds_used = 0;
		level thread test_cmd_for_time( cmd, threadcount, duration );
		level thread test_cmd_kick_bots_at_end();
	}
	else 
	{
		level notify( "stop_testcmd" );
	}

	return result_cmdinfo( "Testcmd " + cast_bool_to_str( level.doing_cmd_system_testcmd, "activated deactivated" ) + " for cmd " + cmd );
}

private set_cmd_rate( rate )
{
	level.unittest_cmd_rate = rate;
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

	if ( !isdefined( level._unittest_host ) )
	{
		if ( isdefined( level.host ) )
		{
			level._unittest_host = level.host;
		}
		else
		{
			level._unittest_host = level.server;
		}

		level._unittest_host.default_executors = [];

		if ( level._unittest_host == level.host )
		{
			//level._unittest_host.default_executors[ 0 ] = level.host;
		}
	}

	level._unittest_host.default_executors[ level._unittest_host.default_executors.size ] = self;
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

private create_random_valid_targets( cmd )
{
	targets = "";
	types = cmd.target_types;

	if ( types.size <= 0 )
	{
		return "";
	}
	for ( i = 0; i < types.size; i++ )
	{
		ordinal = ( i + 1 );
		if ( !types[ i ].is_required && cointoss() )
		{
			continue;
		}

		if ( targets != "" && i > 0 && ( i + 1 ) < types.size )
		{
			targets += ",";
		}

		if ( !isdefined( level._entity_type_funcs[ types[ i ].etype ] ) )
		{
			assert( false );
			com_printdebugerror( "Unknown entity type: '" + types[ i ].etype + "' registered for command: '" + cmd.cmd_name + "'" );
			return "";
		}

		if ( targets == "" )
		{
			targets += "@{";
		}

		targets += "target" + ordinal;
		targets += self [[ level._target_obj_generate ]]( types[ i ].etype );
	}

	if ( targets != "" )
	{
		targets += "}";
	}

	return targets;
}

private construct_chat_message_for_unittest()
{
	cmd_find_result = level [[ level.tcs_arg_type_handlers[ "cmdalias" ].rand_gen_func ]]();
	if ( cmd_find_result.errored )
	{
		com_printdebugerror( cmd_find_result.msg );
		return;
	}

	cmd_object = cmd_find_result.value;
	if ( is_true( cmd_object.immune_to_unittest ) )
	{
		return;
	}
	cmdargs = self create_random_valid_args2( cmd_object );
	targets = self create_random_valid_targets( cmd_object );

	message = cmd_object.cmd_name;
	if ( targets != "" )
	{
		message += " " + targets;
	}
	if ( cmdargs.size > 0 )
	{
		message += " " + repackage_args( cmdargs );
	}

	if ( cmdargs.size < cmd_object.min_args )
	{
		return; // this only happens on unimplemented arg types
	}

	cmd_log = self.name + " executed " + message + " count " + level.unittest_total_cmds_used;
	com_printdebuginfo( cmd_log );
	level notify( "say", message, level._unittest_host, true, false );
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
		arg = self generate_args_from_type( types[ i ] );
		if ( arg.errored || is_true( arg.rand_gen_unimplemented ) )
		{
			return [];
		}

		args[ i ] = arg.str_value;
	}

	for ( i = min_args; i < cmd_object.max_args; i++ )
	{
		if ( cointoss() )
		{
			break;
		}

		if ( !isdefined( types[ i ] ) || types[ i ] == "..." )
		{
			break;
		}

		arg = self generate_args_from_type( types[ i ] );
		if ( arg.errored || is_true( arg.rand_gen_unimplemented ) )
		{
			return [];
		}

		args[ i ] = arg.str_value;
	}

	return args;
}

private generate_args_from_type( type )
{
	rand_obj = generic_obj_t_new();
	if ( isDefined( level.tcs_arg_type_handlers[ type ] ) )
	{
		com_printdebugwarning( "generate_args_from_type: '" + type + "'" );
		rand_obj = self [[ level.tcs_arg_type_handlers[ type ].rand_gen_func ]]();
		if ( rand_obj.errored )
		{
			com_printdebugerror( "Error that should have never happen has happened: '" + type + "' msg: " + rand_obj.msg );
			assert( false ); // should never happen
			return rand_obj;
		}
		else if ( is_true( rand_obj.rand_gen_unimplemented ) )
		{
			com_printdebugerror( "generate_args_from_type: Tried to generate args for type: '" + type + "' but generation was unimplemented" );
			return rand_obj;
		}

		return rand_obj;
	}

	rand_obj.errored = true;
	com_printdebugerror( "Tried to generate args for '" + type + "' but no rand_gen_func handler exists for it" );
	return rand_obj;
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

private test_cmd_for_time( cmd, threadcount, duration )
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
		wait level.unittest_cmd_rate;
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
		wait level.unittest_cmd_rate;
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