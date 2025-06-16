#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_cmd_util;

cmd_buffer()
{
	level endon( "end_cmds" );
	while ( true )
	{
		level waittill( "say", message, player, is_hidden, from_rcon );
		cmd_execute( message, player, is_hidden, from_rcon );
	}
}

// Special target syntax for players/entities:
// @{*} - if the argument expects a player/entity, execute on all of them
// @{playername1,playername2} - execute only on these players
// certain reserved syntaxes also apply:
// @{*[team=allies&classname=player]} - only execute on <team> AND <classname>
// @{*[team=axis|classname=player]} - execute on <team> OR <classname>
// @{*[target=self]} - manually set the target to an entity in this case self or the executor, default behavior; if server is executing they must specify the target
// @{$39} - pick random targets up to $<x> from possible pool of targets, <x> defaults to 1
// @{$[team=allies&classname=player]} - pick one random target matching the criteria
// %{player} - forces this player to be the executor of the command as if they typed the command in the chat
// @{(some_func(arg1,arg2,arg3))} - execute a script function to retrieve targets

// TLDR;
// @{} - by itself represents targets of the command
// %{} - represents executors of the command
//{*} - all possible targets
//{$<x>} - of all possible targets randomly pick them up to <x>
// you can specify both the executor and targets syntax since they have different enough syntax
parse_cmd_message( message )
{
	if ( message == "" )
	{
		return [];
	}

	//Strip cmd tokens.
	stripped_message = message;
	if ( is_cmd_token( message[ 0 ] ) )
	{
		stripped_message = "";
		for ( i = 1; i < message.size; i++ )
		{
			stripped_message += message[ i ];
		}
	}

	multi_cmds = [];
	cmd_keys = [];
	multiple_cmds_keys = strtok( stripped_message, "!" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_args = strtok( multiple_cmds_keys[ i ], " " );
		cmd_find_result = scripts\cmd_system_modules\_cmd_arg::get_cmd_from_alias( cmd_args[ 0 ] );
		if ( !cmd_find_result.errored )
		{
			cmd_keys[ "cmd" ] = cmd_find_result.value;
			arrayremoveindex( cmd_args, 0 );
			for ( j = 0; j < cmd_args.size; j++ )
			{
				switch ( cmd_args[ j ][ 0 ] )
				{
					case "%":
						if ( cmd_args[ j ][ 1 ] != "{" )
						{
							//fail
						}

						brace_count = 1;
						even_number_of_braces = brace_count == 0;
						for ( k = 2; k < cmd_args[ j ].size; k++ )
						{
							switch ( cmd_args[ j ][ k ] )
							{
								case "}":
									brace_count--;
									break;
								case "{":
									brace_count++;
									break;
							}
						}

						if ( brace_count != 0 )
						{
							//fail
						}

						cmd_keys[ "executor_string" ] = add_to_array( cmd_keys[ "executor_string" ], cmd_args[ j ], true );
						break;
					case "@":
						if ( cmd_args[ j ][ 1 ] != "{" )
						{
							//fail
						}
						brace_count = 1;
						even_number_of_braces = brace_count == 0;
						for ( k = 2; k < cmd_args[ j ].size; k++ )
						{
							switch ( cmd_args[ j ][ k ] )
							{
								case "}":
									brace_count--;
									break;
								case "{":
									brace_count++;
									break;
							}
						}

						if ( brace_count != 0 )
						{
							//fail
						}

						cmd_keys[ "target_string" ] = add_to_array( cmd_keys[ "target_string" ], cmd_args[ j ], true );
						break;
					default:
						cmd_keys[ "args" ] = add_to_array( cmd_keys[ "args" ], cmd_args[ j ], true );
						break;
				}
			}
			
			multi_cmds[ multi_cmds.size ] = cmd_keys;
		}
	}

	return multi_cmds;
}

cmd_execute( message, initiator, is_hidden, from_rcon )
{
	if ( isdefined( initiator ) && !is_true( from_rcon ) )
	{
		if ( !level.tcs_glob.bhidden_cmds && is_hidden )
		{
			initiator com_printerror( "Hidden cmds are not allowed" );
			return;
		}
		else if ( !is_hidden && !is_cmd_token( message[ 0 ] ) )
		{
			return;
		}
	}
	else
	{
		if ( isdedicated() )
		{
			initiator = level.server;
		}
		else 
		{
			initiator = level.host;
		}
	}
	channel = initiator com_get_cmd_feedback_channel();
	if ( !is_true( from_rcon ) && isDefined( initiator.cmd_cooldown ) && initiator.cmd_cooldown > 0 )
	{
		initiator com_printerror( "You cannot use another cmd for " + initiator.cmd_cooldown + " seconds" );
		return;
	}
	message = tolower( message );
	multi_cmds = parse_cmd_message( message );
	if ( multi_cmds.size < 1 )
	{
		initiator com_printerror( "Unknown cmd" );
		return;
	}
	if ( multi_cmds.size > 1 && !initiator scripts\cmd_system_modules\_perms::can_use_multi_cmds() && !is_true( from_rcon ) )
	{
		temp_array_index = multi_cmds[ 0 ];
		multi_cmds = [];
		multi_cmds[ 0 ] = temp_array_index;
		initiator com_printwarning( "You do not have permission to use multi cmds; only executing the first cmd" );
	}
	for ( cmd_index = 0; cmd_index < multi_cmds.size; cmd_index++ )
	{
		cmd_obj = multi_cmds[ cmd_index ][ "cmd_obj" ]; // The command definition
		arg_obj = multi_cmds[ cmd_index ][ "args_obj" ]; // Plain arguments
		target_obj = multi_cmds[ cmd_index ][ "target_obj" ]; // Potentially multi-dimensional array of targets to execute the command on
		executor_obj = multi_cmds[ cmd_index ][ "executor_obj" ]; // Single dimension array of players/level.server to execute the command from

		if ( !array_validate( executor_obj.executors ) )
		{
			executor_obj.executors[ executor_obj.executors.size ] = initiator.default_executor;
		}

		if ( !array_validate( target_obj.targets ) )
		{
			target_obj.targets[ target_obj.targets.size ] = initiator.default_target;
		}

		for ( executor_index = 0; executor_index < executor_obj.executors.size; excutor_index++ )
		{
			executor = executor_obj.executors[ executor_index ];

			if ( executor != initiator && !initiator scripts\cmd_system_modules\_perms::has_permission_for_executor_syntax() && !is_true( from_rcon ) )
			{
				initiator com_printerror( "You do not have permission to use executor syntax!" );
				break;
			}

			if ( !initiator scripts\cmd_system_modules\_perms::has_permission_for_cmd( cmd_obj.cmd_name ) && !is_true( from_rcon ) )
			{
				initiator com_printerror( "You do not have permission to use " + cmd_obj.cmd_name + " cmd" );
				break;
			}

			initiator.tcs_silent_cmds = getdvarintdefault( "tcs_silent_cmds", 0 );
			initiator.tcs_logprint_cmd_usage = getdvarintdefault( "tcs_logprint_cmd_usage", 1 );
			executor cmd_execute_internal( initiator, cmd_obj, arg_obj, target_obj );
		}
	}

	initiator thread cmd_cooldown();
}

cmd_execute_internal( cmd_obj, args, silent, logprint )
{
	cmd_name = cmd_obj.cmd_name;
	original_args = args;
	casted_args = args;
	result = undefined;
	if ( !self scripts\cmd_system_modules\_cmd_arg::test_cmd_is_valid( cmd_obj, args ) )
	{
		return;
	}

	// Cast the args using the cast handlers
	// Arg types without a cast handler don't get casted
	// Leaving the casting up to the cmd itself
	if ( array_validate( casted_args ) && array_validate( cmd_obj.arg_types ) )
	{
		arg_types = cmd_obj.arg_types;
		for ( i = 0; i < args.size; i++ )
		{
			cast_result = self arg_cast( arg_types[ i ], args[ i ], i );
			if ( cast_result.errored )
			{
				self com_printerror( cast_result.msg );
				return;
			}
			else
			{
				casted_args[ i ] = cast_result.value;
			}
		}
	}

	// Check if the cmd should execute if the target is in an invalid state
	// Could be changed to use handlers if entities or other types need to be validated
	// For not only checks players
	if ( isdefined( cmd_obj.user_valid_check_func ) )
	{
		if ( isDefined( level.tcs_player_is_valid_check ) )
		{
			if ( cmd_obj.is_clientcmd )
			{
				message = "You are not in a valid state for " + cmd_name + " to work";
				target = self;
			}
			else 
			{
				message = "Target " + args[ 0 ].name + " is not in a valid state for " + cmd_name + " to work";
				target = args[ 0 ];
			}
			if ( ![[ level.tcs_player_is_valid_check ]]( target ) )
			{
				self com_printerror( message );
				return;
			}
		}
	}

	result = self [[ cmd_obj.func ]]( casted_args );

	self handle_result_feedback( result, cmd_name, original_args, logprint, silent );
}

handle_result_feedback( result, cmd, original_args, logprint, silent )
{
	if ( is_true( logprint ) && !is_true( level.doing_cmd_system_unittest ) )
	{
		cmd_log = self.name + " executed " + cmd + " " + repackage_args( original_args );
		level com_printf( "g_log", "cmdinfo", cmd_log );
	}
	if ( !isDefined( result ) || is_true( silent ) )
	{
		return;
	}
	if ( !isDefined( result.filter ) || result.filter == "" )
	{
		level com_printf( "con|g_log", "screrror", "Attempted to print feedback for " + cmd + " but no filter exists in the result" );
		return;
	}
	if ( !isDefined( result.msg ) )
	{
		level com_printf( "con|g_log", "screrror", "Attempted to print feedback for " + cmd + " but no message exists in the result" );
		return;
	}
	if ( result.msg == "" )
	{
		return;
	}

	channel = self com_get_cmd_feedback_channel();
	if ( result.channels != "" )
	{
		channel = result.channels;
	}

	level com_printf( channel, result.filter, result.msg, self );
}

scr_dvar_cmd_watcher()
{
	level endon( "end_cmds" );
	wait 1;
	setDvar( "tcscmd", "" );
	setDvar( "sv_tcscmd", "" );
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
		tokens = strtok( dvar_value, " " );
		new_tokens = [];
		for ( i = 1; i < tokens.size; i++ )
		{
			new_tokens[ new_tokens.size ] = tokens[ i ];
		}

		repackaged_args = repackage_args( new_tokens );

		player = result_obj_new( "player", "entity" );
		if ( tokens.size > 0 )
		{
			player = scripts\cmd_system_modules\_cmd_arg::cast_str_to_player( tokens[ 0 ] );
		}
		level notify( "say", repackaged_args, player.value, false, true );
		setDvar( "tcscmd", "" );
	}

	dvar_value = getdvar( "sv_tcscmd" );
	if ( dvar_value != "" )
	{
		level notify( "say", dvar_value, undefined, false, true );
		setDvar( "sv_tcscmd", "" );
	}
	dvar_value = undefined;
}