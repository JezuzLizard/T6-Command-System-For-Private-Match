#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_cmd_util;

cmd_buffer()
{
	while ( true )
	{
		level waittill( "say", message, user, is_hidden, is_team_chat );
		if ( !isdefined( user.exception_obj ) )
		{
			user.exception_obj = generic_obj_t_new();
			user.exception_obj thread handle_parse_exception_feedback( user );
		}
		user thread cmd_execute( message, user, is_hidden, is_team_chat ); // the default caller of a non threaded function is the caller of the parent thread
	}
}

handle_parse_exception_feedback( user )
{
	if ( isplayer( user ) )
	{
		user endon( "disconnect" );
	}
	for ( ;; )
	{
		user waittill( "cmd_parse_exception", generic_parse_obj );
		user.in_command_frame = false;
		if ( !generic_parse_obj.do_print )
		{
			continue;
		}
		user com_printerror( generic_parse_obj.msg );
	}
}

/*noreturn*/ throw_execute_exception( error_msg, print = true, generic_obj = undefined )
{
	generic_obj = _DEFAULT( generic_obj, generic_obj_t_new() );
	generic_obj.errored = true;
	generic_obj.msg = error_msg;
	generic_obj.do_print = print;

	if ( getdvarint( "script_breakpoint" ) )
	{
		generic_obj script_breakpoint();
	}

	self notify( "cmd_parse_exception", generic_obj );
	return;
}

/*generic_obj_t*/ set_execute_success( generic_obj, success_msg )
{
	generic_obj.msg = success_msg;

	return generic_obj;
}

check_command_syntax_used( message, is_hidden )
{
	if ( !level.tcs_glob.bhidden_cmds && is_hidden )
	{
		self throw_execute_exception( "Hidden cmds are not allowed" );
	}
	else if ( !is_hidden && !is_cmd_token( message[ 0 ] ) )
	{
		self throw_execute_exception( "User was not using a command", false );
	}
}

check_command_cooldown()
{
	if ( isDefined( self.cmd_cooldown ) && self.cmd_cooldown > 0 )
	{
		self throw_execute_exception( "You cannot use another cmd for " + self.cmd_cooldown + " seconds" );
	}
}

check_multi_commands( cmd_parse_obj )
{
	if ( cmd_parse_obj.cmds.size > 1 && !self scripts\cmd_system_modules\_perms::can_use_multi_cmds() )
	{
		self throw_execute_exception( "You do not have permission to use multi cmds" );
	}
}

// just in case the thread would end before reseting it
reset_in_command()
{
	wait 0.05;
	self.in_command_frame = false;
}

cmd_execute( message, initiator, is_hidden, is_team_chat, from_rcon )
{
	if ( !isdefined( initiator.cmd_execute_id ) )
	{
		initiator.cmd_execute_id = 0;
	}
	if ( isplayer( initiator ) )
	{
		initiator endon( "disconnect" );
	}

	initiator endon( "cmd_parse_exception" );

	// ensure a one command a frame per user limit
	if ( initiator.in_command_frame )
	{
		return;
	}
	initiator.in_command_frame = true;
	initiator thread reset_in_command();

	unrestricted_access = ( initiator == level.server || initiator == level.host );
	from_rcon = message[ 0 ] == "~";
	has_all_perms = unrestricted_access;
	message = getsubstr( message, 1 ); // remove '~' character which indicates rcon

	if ( !has_all_perms )
	{
		initiator check_command_syntax_used( message, is_hidden );
		initiator check_command_cooldown();
	}

	message = tolower( message );
	cmd_parse_obj = parse_cmd_message( message );
	//add_obj_ref( cmd_execute_thread, cmd_parse_obj );

	if ( !has_all_perms )
	{
		initiator check_multi_commands( cmd_parse_obj );
	}

	foreach ( cmd_obj, key in cmd_parse_obj.cmds )
	{
		executor_directive_type = cmd_obj.directive_kvps[ "executor" ].directive_type;
		executors = get_executors( executor_directive_type.token_type, executor_directive_type.token_values );

		for ( executor_index = 0; executor_index < executors.size; executor_index++ )
		{
			executor = executors[ executor_index ];

			if ( !has_all_perms )
			{
				if ( executor != initiator && !initiator scripts\cmd_system_modules\_perms::has_permission_for_executor_syntax() )
				{
					initiator throw_execute_exception( "You do not have permission to specify executors" );
				}

				if ( !initiator scripts\cmd_system_modules\_perms::has_permission_for_cmd( cmd_obj.cmd_name ) )
				{
					initiator throw_execute_exception( "You do not have permission to use " + cmd_obj.cmd_name + " cmd" );
				}
			}

			initiator.tcs_silent_cmds = getdvarintdefault( "tcs_silent_cmds", 0 );
			initiator.tcs_logprint_cmd_usage = getdvarintdefault( "tcs_logprint_cmd_usage", 1 );
			initiator.tcs_feedback_mode = 2; // 0 == executor receives cmd feedback, 1 == initiator receives cmd feedback, 2 == initiator and executor receives cmd feedback
			executor cmd_execute_internal( initiator, cmd_obj );
		}
	}

	if ( !has_all_perms )
	{
		initiator thread cmd_cooldown();
	}
}

cmd_execute_internal( initiator, cmd_obj )
{
	cmd_data_obj = level.tcs_cmds[ cmd_obj.cmd_name ];

	!initiator scripts\cmd_system_modules\_cmd_arg::test_cmd_is_valid( cmd_data_obj, cmd_obj.args );

	// Cast the args using the cast handlers
	// Arg types without a cast handler don't get casted
	// Leaving the casting up to the cmd itself
	if ( array_validate( cmd_obj.args ) && array_validate( cmd_data_obj.arg_types ) )
	{
		for ( i = 0; i < cmd_obj.args.size; i++ )
		{
			arg = cmd_obj.args[ i ];
			arg_type = cmd_data_obj.arg_types[ i ];
			cast_result = initiator arg_cast( arg_type, arg, i );
			if ( cast_result.errored )
			{
				initiator throw_execute_exception( cast_result.msg );
			}
			else
			{
				cmd_obj.casted_args[ i ] = cast_result.value;
			}
		}
	}

	targets = cmd_obj.directive_kvps[ "target" ]; // always contains at least the default target
	cmd_obj.casted_targets = [];
	if ( array_validate( cmd_data_obj.target_types ) )
	{
		for ( i = 0; i < targets.size; i++ )
		{
			target = targets[ i ];
			target_type = cmd_data_obj.target_types[ i ];
			cast_result = initiator target_cast( target_type.etype, target.directive_value.token_type, target.directive_value.token_value );
			if ( cast_result.errored )
			{
				if ( !target_type.is_required )
				{
					continue;
				}

				initiator throw_execute_exception( cast_result.msg );
			}
			else
			{
				cmd_obj.casted_targets[ i ] = cast_result.value;
			}
		}
	}

	result = self [[ cmd_obj.func ]]( cmd_obj.casted_targets, cmd_obj.casted_args );

	self handle_result_feedback( initiator, result, cmd_obj.cmd_name, arg_obj );
}

handle_result_feedback( initiator, result, cmd_name, arg_obj )
{
	if ( is_true( initiator.tcs_logprint_cmd_usage ) && !is_true( level.doing_cmd_system_unittest ) )
	{
		cmd_log = "";
		if ( self != initiator )
		{
			cmd_log = initiator.name + " executed " + cmd_name + " on behalf of " + self.name + " with args " + repackage_args( arg_obj.str_args );
		}
		else
		{
			cmd_log = initiator.name + " executed " + cmd_name + " with args " + repackage_args( arg_obj.str_args );
		}
		
		level com_printf( "g_log", "cmdinfo", cmd_log );
	}
	if ( !isDefined( result ) || is_true( initiator.tcs_silent_cmds ) )
	{
		return;
	}
	if ( !isDefined( result.filter ) || result.filter == "" )
	{
		level com_printf( "con|g_log", "screrror", "Attempted to print feedback for " + cmd_name + " but no filter exists in the result" );
		return;
	}
	if ( !isDefined( result.msg ) )
	{
		level com_printf( "con|g_log", "screrror", "Attempted to print feedback for " + cmd_name + " but no message exists in the result" );
		return;
	}
	if ( result.msg == "" )
	{
		return;
	}

	executor_channel = self com_get_cmd_feedback_channel();
	if ( result.channels != "" )
	{
		executor_channel = result.channels;
	}

	initiator_channel = initiator com_get_cmd_feedback_channel();
	if ( result.channels != "" )
	{
		initiator_channel = result.channels;
	}

	if ( initiator.tcs_feedback_mode == 2 )
	{
		if ( initiator != self )
		{
			level com_printf( initiator_channel, result.filter, result.msg, initiator );
		}
		
		level com_printf( executor_channel, result.filter, result.msg, self );
	}
	else if ( intiator.tcs_feedback_mode == 1 )
	{
		level com_printf( initiator_channel, result.filter, result.msg, initiator );
	}
	else if ( initiator.tcs_feedback_mode == 0 )
	{
		level com_printf( executor_channel, result.filter, result.msg, self );
	}
}

scr_dvar_cmd_watcher()
{
	setDvar( "tcscmd", "" );
	while ( true )
	{
		parse_cmd_dvar();
		wait 0.05;
	}
}

parse_cmd_dvar()
{
	dvar_value = getdvar( "tcscmd" );
	if ( dvar_value != "" )
	{
		setDvar( "tcscmd", "" );
		dvar_value = "~" + dvar_value; // special token to indicate that it's from the dvar
		waittillframeend; // prevents notifies from being dropped if they happen in the same frame
		if ( isdedicated() )
		{
			// there is no local client, so the server will always need to specify an executor/target, unless they specify the default_target and default_executor
			level notify( "say", dvar_value, level.server, true, false );
		}
		else
		{
			level notify( "say", dvar_value, level.host, true, false );
		}
	}
}