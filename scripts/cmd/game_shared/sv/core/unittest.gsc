#include common_scripts\utility;


#include scripts\cmd\game_shared\sv\core\_utility;

#include scripts\cmd\game_shared\sv\core\unittest_helpers;

add_unittest_cmds()
{
	cmd_block_set_module_group( "unittest" );
	cmd_block_set_rank_group( "cheat" );
	unittest_cmd = cmd_add( "unittest", ::cmd_unittest_validargs_f, "unittest [botcount] [duration] [rate]" );
	unittest_cmd arg_add_optional_with_default( 1, "botcount", "positive_int", "Number of bots to spawn for spamming commands", 1 );
	unittest_cmd arg_add_optional_with_default( 2, "duration", "positive_int", "Duration of unittest", 0 );
	unittest_cmd arg_add_optional_with_default( 3, "rate", "positive_float", "Rate of command execution", 0.5 );
	unittest_cmd make_cmd_immune_to_unittest();

	testcmd_cmd = cmd_add( "testcmd", ::cmd_testcmd_f, "testcmd <cmdalias> [threadcount] [duration]" );
	testcmd_cmd arg_add_required( 1, "cmdalias", "cmdalias", "Command to stress test" );
	testcmd_cmd arg_add_optional_with_default( 2, "threadcount", "positive_int", "Number of threads to execute the command on", 1 );
	testcmd_cmd arg_add_optional_with_default( 3, "duration", "positive_int", "Duration of testcmd unittesting", 0 );
	testcmd_cmd make_cmd_immune_to_unittest();
}

cmd_unittest_validargs_f( param )
{
	required_bots = _DEFAULT( param.a[ 0 ], 1 );
	duration = _DEFAULT( param.a[ 1 ], 0 );
	rate = _DEFAULT( param.a[ 2 ], 0.5 );

	level.doing_cmd_system_unittest = !is_true( level.doing_cmd_system_unittest );
	if ( level.doing_cmd_system_unittest )
	{
		level thread do_unit_test( required_bots, duration, rate );
		level notify( "unittest_start" );
	}
	else
	{
		level notify( "unittest_stop" );
	}

	on_off = cast_bool_to_str( !is_true( level.doing_cmd_system_unittest ), "activated deactivated" );

	param add_executor_cmdinfo( "Cmd system unit test '" + on_off + "'" );
}

cmd_testcmd_f( param )
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
	}
	else 
	{
		level notify( "stop_testcmd" );
	}

	param add_executor_cmdinfo( "Testcmd " + cast_bool_to_str( level.doing_cmd_system_testcmd, "activated deactivated" ) + " for cmd " + cmd );
}