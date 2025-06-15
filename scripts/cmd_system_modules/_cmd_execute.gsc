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
	multiple_cmds_keys = strTok( stripped_message, "|" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_args = strTok( multiple_cmds_keys[ i ], " " );
		cmd_find_result = scripts\cmd_system_modules\_cmd_arg::get_cmd_from_alias( cmd_args[ 0 ] );
		if ( !cmd_find_result.errored )
		{
			cmd_keys[ "cmd" ] = cmd_find_result.value;
			arrayremoveindex( cmd_args, 0 );
			cmd_keys[ "args" ] = [];
			cmd_keys[ "args" ] = cmd_args;
			multi_cmds[ multi_cmds.size ] = cmd_keys;
		}
	}

	return multi_cmds;
}

cmd_execute( message, player, is_hidden, from_rcon )
{
	if ( isdefined( player ) && !is_true( from_rcon ) )
	{
		if ( !level.tcs_glob.bhidden_cmds && is_hidden )
		{
			player com_printerror( "Hidden cmds are not allowed" );
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
			player = level.server;
		}
		else 
		{
			player = level.host;
		}
	}
	channel = player com_get_cmd_feedback_channel();
	if (!is_true( from_rcon ) && isDefined( player.cmd_cooldown ) && player.cmd_cooldown > 0 )
	{
		player com_printerror( "You cannot use another cmd for " + player.cmd_cooldown + " seconds" );
		return;
	}
	message = tolower( message );
	multi_cmds = parse_cmd_message( message );
	if ( multi_cmds.size < 1 )
	{
		player com_printerror( "Unknown cmd" );
		return;
	}
	if ( multi_cmds.size > 1 && !player scripts\cmd_system_modules\_perms::can_use_multi_cmds() && !is_true( from_rcon ) )
	{
		temp_array_index = multi_cmds[ 0 ];
		multi_cmds = [];
		multi_cmds[ 0 ] = temp_array_index;
		player com_printwarning( "You do not have permission to use multi cmds; only executing the first cmd" );
	}
	for ( cmd_index = 0; cmd_index < multi_cmds.size; cmd_index++ )
	{
		cmd_object = multi_cmds[ cmd_index ][ "cmd" ];
		args = multi_cmds[ cmd_index ][ "args" ];
		if ( !player scripts\cmd_system_modules\_perms::has_permission_for_cmd( cmd_object.cmd_name ) && !is_true( from_rcon ) )
		{
			player com_printerror( "You do not have permission to use " + cmd_object.cmd_name + " cmd" );
		}
		else
		{
			if ( cmd_object.is_clientcmd && is_true( player.is_server ) )
			{
				player com_printerror( "You cannot use " + cmd_object.cmd_name + " client cmd as the server" );
			}
			else 
			{
				player cmd_execute_internal( cmd_object, args, getdvarintdefault( "tcs_silent_cmds", 0 ), getdvarintdefault( "tcs_logprint_cmd_usage", 1 ) );
				player thread cmd_cooldown();
			}
		}
	}
}

cmd_execute_internal( cmd_object, args, silent, logprint )
{
	cmd_name = cmd_object.cmd_name;
	original_args = args;
	result = undefined;
	if ( !self scripts\cmd_system_modules\_cmd_arg::test_cmd_is_valid( cmd_object, args ) )
	{
		return;
	}

	// Cast the args using the cast handlers
	// Arg types without a cast handler don't get casted
	// Leaving the casting up to the cmd itself
	if ( args.size > 0 && array_validate( cmd_object.arg_types ) )
	{
		arg_types = cmd_object.arg_types;
		for ( i = 0; i < args.size; i++ )
		{
			if ( isDefined( level.tcs_arg_type_handlers[ arg_types[ i ] ] ) && isDefined( level.tcs_arg_type_handlers[ arg_types[ i ] ].cast_func ) )
			{
				cast_result = self [[ level.tcs_arg_type_handlers[ arg_types[ i ] ].cast_func ]]( args[ i ] );
				if ( cast_result.errored )
				{
					self com_printerror( cast_result.msg );
					return;
				}

				if ( isdefined( cast_result.default_value ) && !isdefined( cast_result.value ) )
				{
					args[ i ] = cast_result.default_value;
				}
				else
				{
					args[ i ] = cast_result.value;
				}
			}
		}
	}

	// Check if the cmd should execute if the target is in an invalid state
	// Could be changed to use handlers if entities or other types need to be validated
	// For not only checks players
	if ( isdefined( cmd_object.user_valid_check_func ) )
	{
		if ( isDefined( level.tcs_player_is_valid_check ) )
		{
			if ( cmd_object.is_clientcmd )
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

	result = self [[ cmd_object.func ]]( args );

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

		player = result_obj_new( "player" );
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