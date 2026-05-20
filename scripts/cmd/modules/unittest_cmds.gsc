#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_api_cmd;

#include scripts\cmd\core\_utility;

#include scripts\cmd\modules\unittest_helpers;

add_unittest_cmds()
{
	cmd_block_set_module_group( "unittest" );
	cmd_block_set_rank_group( "cheat" );

	cmd_add( "testmodule", ::cmd_testmodule_f, "testmodule <cmdmodule> [sequential] [duration] [rate]" );
	arg_add_required( 1, "cmdmodule", "cmdmodule", "Module to test" );
	arg_add_optional_with_default( 2, "sequential", "boolean", "Test each command in sequential order as defined by the module", true );
	arg_add_optional_with_default( 3, "duration", "positive_int", "Duration of automated testing", 0 );
	arg_add_optional_with_default( 4, "rate", "positive_float", "Rate of command execution", 0.5 );
	make_cmd_immune_to_unittest();
}

private cmd_testmodule_f( param )
{
	module = param.a[ 0 ];
	sequential = _DEFAULT( param.a[ 1 ], true );
	duration = _DEFAULT( param.a[ 2 ], 0 );
	rate = _DEFAULT( param.a[ 3 ], 0.5 );

	level.doing_cmd_system_unittest = !is_true( level.doing_cmd_system_unittest );
	if ( level.doing_cmd_system_unittest )
	{
		level thread do_module_test( module, sequential, duration, rate );
		level notify( "unittest_start" );
	}
	else
	{
		level notify( "unittest_stop" );
	}

	on_off = cast_boolean_to_str( level.doing_cmd_system_unittest, "activated deactivated" );

	param add_executor_cmdinfo( "Cmd system unit test for '{}' module '{}'", module, on_off );
}