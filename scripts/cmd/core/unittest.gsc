#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

autoexec start_unittest()
{
	addcallback( "on_player_connect", ::unittest_connect );

	cmd_block_set_module_group( "unittest" );
	cmd_block_set_rank_group( "cheat" );
	unittest_cmd = cmd_add( "unittest", ::cmd_unittest_validargs_f, "unittest [botcount] [duration] [rate]" );
	unittest_cmd arg_add_optional( 1, "botcount", "positive_int", "Number of bots to spawn for spamming commands" );
	unittest_cmd arg_add_optional( 2, "duration", "positive_int", "Duration of unittest" );
	unittest_cmd arg_add_optional( 3, "rate", "positive_float", "Rate of command execution" );
	unittest_cmd make_cmd_immune_to_unittest();

	testcmd_cmd = cmd_add( "testcmd", ::cmd_testcmd_f, "testcmd <cmdalias> [threadcount] [duration]" );
	testcmd_cmd arg_add_required( 1, "cmdalias", "cmdalias", "Command to stress test" );
	testcmd_cmd arg_add_optional( 2, "threadcount", "positive_int", "Number of threads to execute the command on" );
	testcmd_cmd arg_add_optional( 3, "duration", "positive_int", "Duration of testcmd unittesting" );
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

	param add_executor_cmdinfo( "Cmd system unit test activated" );
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

	param add_executor_cmdinfo( "Testcmd " + cast_bool_to_str( level.doing_cmd_system_testcmd, "activated deactivated" ) + " for cmd " + cmd );
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
	for ( i = 0; i < _SIZE( level.players.size ); i++ )
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
	for ( i = 0; i < _SIZE( level.players.size ); i++ )
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
		
		reset_rampage_func = getfunction( "maps/mp/zombies/_zm", "reset_rampage_bookmark_kill_times" );
		if ( isdefined( reset_rampage_func ) )
		{
			bot [[ reset_rampage_func ]]();
		}
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
	target_gen_obj = generic_obj_t_new( "target_gen" );
	targets = "";
	target_gen_obj.value = targets;
	types = cmd.target_types;

	if ( types.size <= 0 )
	{
		return target_gen_obj;
	}

	foreach ( ordinal, val in types )
	{
		if ( !val.is_required && cointoss() )
		{
			continue;
		}

		random_overload = random_val( val.overloads );
		if ( !isdefined( level._entity_type_funcs[ random_overload.etype ] ) )
		{
			assert( false );
			com_printdebugerror( "Unknown entity type: '" + random_overload.etype + "' registered for command: '" + cmd.cmd_name + "'" );
			target_gen_obj.errored = true;
			return target_gen_obj;
		}

		if ( targets == "" )
		{
			targets += "@{";
		}

		if ( cointoss() )
		{
			targets += "target";
		}
		else
		{
			targets += "t";
		}

		targets += ordinal;
		targets += "=";

		target_str = self [[ level._target_obj_generate ]]( random_overload );
		if ( target_str == "" )
		{
			com_printdebugerror( "Could not generate entities of etype: '" + random_overload.etype + "' max_targets: '" + random_overload.max_targets + "'" );
			target_gen_obj.errored = true;
			return target_gen_obj;
		}
		targets += target_str;

		targets += ",";
	}

	if ( targets != "" && targets[ targets.size - 1 ] == "," )
	{
		targets = getsubstr( targets, 0, ( targets.size - 1 ) );
	}

	if ( targets != "" )
	{
		targets += "}";
	}

	target_gen_obj.value = targets;

	return target_gen_obj;
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
	arg_gen_obj = self create_random_valid_args2( cmd_object );
	if ( arg_gen_obj.errored )
	{
		return;
	}

	target_gen_obj = self create_random_valid_targets( cmd_object );
	if ( target_gen_obj.errored )
	{
		return;
	}

	message = cmd_object.cmd_name;
	if ( target_gen_obj.value != "" )
	{
		message += " " + target_gen_obj.value;
	}
	else if ( cmd_object.has_required_target )
	{
		return; // something went wrong
	}
	
	if ( arg_gen_obj.value.size > 0 )
	{
		message += " " + repackage_args( arg_gen_obj.value );
	}

	cmd_log = self.name + " executed " + message + " count " + level.unittest_total_cmds_used;
	com_printdebuginfo( cmd_log );
	level notify( "say", message, level._unittest_host, true, false );
	level.unittest_total_cmds_used++;
}

private create_random_valid_args2( cmd_object )
{
	arg_gen_obj = generic_obj_t_new( "arg_gen" );
	arg_gen_obj.value = [];
	types = cmd_object.arg_types;

	if ( !isDefined( types ) )
	{
		return arg_gen_obj;
	}

	i = 0;
	foreach ( ordinal, type in types )
	{
		if ( !type.is_required )
		{
			if ( cointoss() )
			{
				break;
			}
		}

		random_overloaded_type = random_key( type.overloads );
		arg = self generate_args_from_type( random_overloaded_type );
		if ( arg.errored || is_true( arg.rand_gen_unimplemented ) )
		{
			arg_gen_obj.errored = true;
			return arg_gen_obj;
		}

		arg_gen_obj.value[ i ] = arg.str_value;
		i++;
	}

	return arg_gen_obj;
}

private generate_args_from_type( type )
{
	rand_obj = generic_obj_t_new();
	if ( isDefined( level.tcs_arg_type_handlers[ type ] ) && isdefined( level.tcs_arg_type_handlers[ type ].rand_gen_func ) )
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
	for ( i = 0; i < _SIZE( threadcount ); i++ )
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
	for ( i = 0; i < ( _SIZE( time_in_minutes ) * 60 ); i++ )
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
	for ( i = 0; i < _SIZE( level.players.size ); i++ )
	{
		if ( is_true( level.players[ i ].pers["isBot"] ) )
		{
			kick( level.players[ i ] getEntityNumber() );
		}
	}
}