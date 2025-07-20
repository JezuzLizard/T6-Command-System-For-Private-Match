#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

autoexec cmd_buffer()
{
	level thread scr_dvar_cmd_watcher();
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

private handle_parse_exception_feedback( user )
{
	if ( isplayer( user ) )
	{
		user endon( "disconnect" );
	}
	for ( ;; )
	{
		user waittill( "cmd_exception", generic_parse_obj );
		user.in_command_frame = false;
		if ( !generic_parse_obj.do_print )
		{
			continue;
		}
		user com_printerror( generic_parse_obj.msg );
	}
}

private check_command_syntax_used( message, is_hidden )
{
	if ( !level.tcs_glob.bhidden_cmds && is_hidden )
	{
		self throw_exception( "Hidden cmds are not allowed" );
	}
	else if ( !is_hidden && !is_cmd_token( message[ 0 ] ) )
	{
		self throw_exception( "User was not using a command", false );
	}
}

private check_command_cooldown()
{
	if ( isDefined( self.cmd_cooldown ) && self.cmd_cooldown > 0 )
	{
		self throw_exception( "You cannot use another cmd for " + self.cmd_cooldown + " seconds" );
	}
}

private check_multi_commands( cmd_parse_obj )
{
	if ( cmd_parse_obj.cmds.size > 1 && !self can_use_multi_cmds() )
	{
		self throw_exception( "You do not have permission to use multi cmds" );
	}
}

// just in case the thread would end before reseting it
private reset_in_command()
{
	wait 0.05;
	self.in_command_frame = false;
}

private cmd_execute( message, initiator, is_hidden, is_team_chat, from_rcon )
{
	if ( !isdefined( initiator.cmd_execute_id ) )
	{
		initiator.cmd_execute_id = 0;
	}
	if ( isplayer( initiator ) )
	{
		initiator endon( "disconnect" );
	}

	initiator endon( "cmd_exception" );

	if ( !isdefined( initiator.in_command_frame ) )
	{
		initiator.in_command_frame = false;
	}

	unrestricted_access = has_all_perms();
	from_rcon = unrestricted_access && message[ 0 ] == "~";
	has_all_perms = unrestricted_access;
	if ( from_rcon || is_cmd_token( message[ 0 ] ) )
	{
		message = getsubstr( message, 1 ); // remove '~' character which indicates rcon, as well as any cmd tokens
	}

	// ensure a one command a frame per user limit
	if ( !has_all_perms && initiator.in_command_frame )
	{
		return;
	}
	initiator.in_command_frame = true;
	initiator thread reset_in_command();

	if ( !has_all_perms )
	{
		initiator check_command_syntax_used( message, is_hidden );
		initiator check_command_cooldown();
	}

	message = tolower( message );
	cmd_parse_obj = scripts\cmd\core\_cmd_parse2::parse_cmd_message( message );
	//add_obj_ref( cmd_execute_thread, cmd_parse_obj );

	if ( !has_all_perms )
	{
		initiator check_multi_commands( cmd_parse_obj );
	}

	foreach ( key, cmd_obj in cmd_parse_obj.cmds )
	{
		executor_directive = cmd_obj.kvps[ "executor" ].directive_value;
		executors = get_executors( executor_directive.token_type, executor_directive.token_values );

		for ( executor_index = 0; executor_index < executors.size; executor_index++ )
		{
			executor = executors[ executor_index ];

			if ( !has_all_perms )
			{
				if ( executor != initiator && !initiator has_permission_for_executor_syntax() )
				{
					initiator throw_exception( "You do not have permission to specify executors", cmd_obj );
				}

				if ( !initiator has_permission_for_cmd( cmd_obj.cmd_data_source ) )
				{
					initiator throw_exception( "You do not have permission to use " + cmd_obj.cmd_data_source.cmd_name + " cmd", cmd_obj );
				}
			}

			initiator.tcs_silent_cmds = getdvarintdefault( "tcs_silent_cmds", 0 );
			initiator.tcs_logprint_cmd_usage = getdvarintdefault( "tcs_logprint_cmd_usage", 1 );
			initiator.tcs_feedback_mode = getdvarintdefault( "tcs_feedback_mode", 1 ); // 0 == executor receives cmd feedback, 1 == initiator receives cmd feedback, 2 == initiator and executor receives cmd feedback
			executor cmd_execute_internal( initiator, cmd_obj );
		}
	}

	if ( !has_all_perms )
	{
		initiator thread cmd_cooldown();
	}
}

private test_cmd_is_valid( cmd_object, args )
{
	//self com_printcmd( cmd_object );
	if ( args.size < cmd_object.min_args )
	{
		self throw_exception( "Too few args: usage: " + cmd_object.usage );
	}
	if ( args.size > cmd_object.max_args )
	{
		self throw_exception( "Too many args: usage: " + cmd_object.usage );
	}

	return true;
}

private arg_cast( arg_type, arg, arg_index )
{
	cast_result = result_obj_new( "argtype", "struct" );
	if ( isDefined( level.tcs_arg_type_handlers[ arg_type ] ) && isDefined( level.tcs_arg_type_handlers[ arg_type ].cast_func ) )
	{
		cast_result = self [[ level.tcs_arg_type_handlers[ arg_type ].cast_func ]]( arg );
			
		return cast_result;
	}

	return set_cast_success( cast_result, arg, "no argtype defined" );
}

private target_cast( etype, directive_value )
{
	obj = generic_obj_t_new( "target_cast" );

	obj.value = self get_entity_targets( etype, directive_value.token_type, directive_value.token_values );
	if ( !isdefined( obj.value ) || obj.value.size == 0 )
	{
		obj.errored = true;
		obj.msg = "Failed to find any compatible entities";
	}

	return obj;
}

private cast_to_array( item )
{
	new_array = [];
	new_array[ new_array.size ] = item;
	return new_array;
}

private get_random_limited_array( array, limit )
{
	new_array = [];
	array = array_randomize( array );
	for ( i = 0; i < limit; i++ )
	{
		new_array[ new_array.size ] = array[ i ];
	}

	return new_array;
}

private get_executors( executor_type, directive_args )
{
	executors = [];
	switch ( executor_type )
	{
		case "all":
			executors = level.players;
			return executors;
		case "undefined": // error
			return [];
		case "random":
			limit = 1;
			if ( isdefined( directive_args[ 0 ] ) )
			{
				limit = int( directive_args[ 0 ] );
			}
			
			return get_random_limited_array( level.players, limit );
		case "array":
			players = [];
			foreach ( presumed_player in directive_args )
			{
				players[ players.size ] = cast_str_to_entity( presumed_player, "player" );
			}

			return players;
		case "array_random":
			players = [];
			foreach ( presumed_player in directive_args )
			{
				players[ players.size ] = cast_str_to_entity( presumed_player, "player" );
			}

			return add_to_array( undefined, random( players ) );
		case "self":
			return add_to_array( undefined, self );
		case "default":
			return self.default_executors;
	}

	return [];
}

private get_entity_targets( etype, directive_type, directive_args )
{
	getter_func = undefined;
	if ( isdefined( level._entity_type_funcs[ etype ] ) )
	{
		getter_func = level._entity_type_funcs[ etype ].getter;
	}
	else if ( isdefined( level._entity_custom_getter_funcs[ etype ] ) )
	{
		getter_func = level._entity_custom_getter_funcs[ etype ].getter;
	}
	else
	{
		assert( false );
		return [];
	}

	ents = undefined;
	switch ( directive_type )
	{
		case "all":
			ents = [[ getter_func ]]();
			return ents;
		case "undefined":
			return [];
		case "random":
			ents = [[ getter_func ]]();
			limit = 1;
			if ( isdefined( directive_args[ 0 ] ) )
			{
				limit = int( directive_args[ 0 ] );
			}
			
			return get_random_limited_array( ents, limit );
		case "array":
		case "array_random":
			ents = [];
			foreach ( presumed_ent in directive_args )
			{
				ents[ ents.size ] = cast_str_to_entity( presumed_ent, etype );
			}

			if ( directive_type == "array" )
			{
				return ents;
			}
			else
			{
				return add_to_array( undefined, random_val( ents ) );
			}
			
		case "self":
			return add_to_array( undefined, self );
		case "default":
			if ( self.default_targets.size == 0 )
			{
				return self.default_executors;
			}
			
			return self.default_targets;
		case "function":
			// TODO: basically we need to use getfunction, which requires both a function name and a filename, and then pass the arguments to it appropriately casted
			return [];
	}

	return [];
}

private cmd_execute_internal( initiator, cmd_obj )
{
	cmd_data_source = cmd_obj.cmd_data_source;

	initiator test_cmd_is_valid( cmd_data_source, cmd_obj.args );

	if ( self == level.server && cmd_data_source.requires_player_executor )
	{
		initiator throw_exception( "Command '" + cmd_data_source.cmd_name + "' expects the executor to be a player; but executor is level.server, use setdefaultcmdexecutor on a player to execute this command", cmd_obj );
	}

	param = generic_obj_t_new( "param" );
	param.t = []; // targets
	param.a = cmd_obj.args; // arguments

	// Cast the args using the cast handlers
	// Arg types without a cast handler don't get casted
	// Leaving the casting up to the cmd itself
	if ( array_validate( cmd_obj.args ) && array_validate( cmd_data_source.arg_types ) )
	{
		for ( i = 0; i < cmd_obj.args.size; i++ )
		{
			arg = cmd_obj.args[ i ];
			arg_type = cmd_data_source.arg_types[ i ];
			if ( arg_type == "..." )
			{
				// consume rest of arguments
				for ( j = i; j < cmd_obj.args.size; j++ )
				{
					param.a[ j ] = cmd_obj.args[ j ];
				}

				break;
			}
			cast_result = initiator arg_cast( arg_type, arg, i );
			if ( cast_result.errored )
			{
				initiator throw_exception( cast_result.msg, cmd_obj );
			}
			else
			{
				param.a[ i ] = cast_result.value;
			}
		}
	}

	targets = cmd_obj.directive_kvps[ "target" ]; // always contains at least the default target
	cmd_obj.casted_targets = [];
	if ( array_validate( cmd_data_source.target_types ) )
	{
		for ( i = 0; i < targets.size; i++ )
		{
			target = targets[ i ];
			target_type = cmd_data_source.target_types[ i ];
			cast_result = initiator target_cast( target_type.etype, target.directive_value );
			if ( cast_result.errored )
			{
				if ( !target_type.is_required )
				{
					continue;
				}

				initiator throw_exception( cast_result.msg, cmd_obj );
			}
			else
			{
				if ( cast_result.value.size > target_type.max_targets )
				{
					initiator throw_exception( "Command '" + cmd_obj.cmd_name + "' expects a maximum of '" + target_type.max_targets + "' got '" + cast_result.value.size + "' instead" , cmd_obj );
				}
				param.t[ i ] = cast_result.value;
			}
		}
	}

	result = self [[ cmd_data_source.func ]]( param );

	self handle_result_feedback( initiator, result, cmd_obj.cmd_name, cmd_obj.cmd_string );
}

private handle_result_feedback( initiator, result, cmd_name, cmd_string )
{
	if ( is_true( initiator.tcs_logprint_cmd_usage ) && !is_true( level.doing_cmd_system_unittest ) )
	{
		cmd_log = "";
		if ( self != initiator )
		{
			cmd_log = initiator.name + " executed '" + cmd_string + "' on behalf of " + self.name;
		}
		else
		{
			cmd_log = initiator.name + " executed '" + cmd_string + "'";
		}
		
		com_printinfo( cmd_log );
	}
	if ( !isDefined( result ) || is_true( initiator.tcs_silent_cmds ) )
	{
		return;
	}
	if ( !isDefined( result.filter ) || result.filter == "" )
	{
		com_printerror( "Attempted to print feedback for " + cmd_name + " but no filter exists in the result" );
		return;
	}
	if ( !isDefined( result.msg ) )
	{
		com_printerror( "Attempted to print feedback for " + cmd_name + " but no message exists in the result" );
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

	for ( i = 0; i < result.player_msg_array.size; i++ )
	{
		result.player_msg_array[ i ].player com_printinfo( result.player_msg_array[ i ].msg );
	}

	if ( initiator.tcs_feedback_mode == 2 )
	{
		if ( initiator != self )
		{
			for ( i = 0; i < result.executor_msg_array.size; i++ )
			{
				level com_printf( initiator_channel, result.filter, result.msg, initiator );
			}
			level com_printf( initiator_channel, result.filter, result.msg, initiator );
		}
		
		for ( i = 0; i < result.executor_msg_array.size; i++ )
		{
			level com_printf( executor_channel, result.filter, result.msg, initiator );
		}
		level com_printf( executor_channel, result.filter, result.msg, self );
	}
	else if ( initiator.tcs_feedback_mode == 1 )
	{
		for ( i = 0; i < result.executor_msg_array.size; i++ )
		{
			level com_printf( initiator_channel, result.filter, result.msg, initiator );
		}
		level com_printf( initiator_channel, result.filter, result.msg, initiator );
	}
	else if ( initiator.tcs_feedback_mode == 0 )
	{
		for ( i = 0; i < result.executor_msg_array.size; i++ )
		{
			level com_printf( executor_channel, result.filter, result.msg, initiator );
		}
		level com_printf( executor_channel, result.filter, result.msg, self );
	}
}

private scr_dvar_cmd_watcher()
{
	setDvar( "tcscmd", "" );
	while ( true )
	{
		parse_cmd_dvar();
		wait 0.05;
	}
}

private parse_cmd_dvar()
{
	dvar_value = getdvar( "tcscmd" );
	if ( dvar_value != "" )
	{
		setDvar( "tcscmd", "" );
		dvar_value = "~" + dvar_value; // special token to indicate that it's from the dvar
		waittillframeend; // prevents notifies from being dropped if they happen in the same frame
		if ( isdedicated() )
		{
			// there is no local client, so the server will always need to specify an executor/target, unless they specify the default_targets and default_executors
			level notify( "say", dvar_value, level.server, true, false );
		}
		else
		{
			level notify( "say", dvar_value, level.host, true, false );
		}
	}
}

/*generic_obj_t*/ private set_execute_success( generic_obj, success_msg )
{
	generic_obj.msg = success_msg;

	return generic_obj;
}