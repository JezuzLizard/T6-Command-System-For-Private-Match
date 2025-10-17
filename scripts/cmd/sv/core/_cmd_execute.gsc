#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;

start_cmd_buffer_thread()
{
	level thread scr_dvar_cmd_watcher();
	for ( ;; )
	{
		level waittill( "say", message, user, is_hidden, is_team_chat );
		user thread cmd_execute_internal( message, user, is_hidden, is_team_chat );
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
		self throw_exception( undefined, "Hidden cmds are not allowed" );
	}
	if ( !is_hidden && !is_cmd_token( message[ 0 ] ) )
	{
		self throw_exception( undefined, "User was not using a command", false );
	}
}

private check_command_cooldown()
{
	if ( isDefined( self.cmd_cooldown ) && self.cmd_cooldown > 0 )
	{
		self throw_exception( undefined, "You cannot use another cmd for '{}' seconds", self.cmd_cooldown );
	}
}

private check_multi_commands( cmd_parse_obj )
{
	if ( cmd_parse_obj.cmds.size > 1 && !self can_use_multi_cmds() )
	{
		self throw_exception( undefined, "You do not have permission to use multi cmds" );
	}
}

// just in case the thread would end before reseting it
private reset_in_command()
{
	wait 0.05;
	self.in_command_frame = false;
}

private debug_print_execute( index, cmd_obj )
{
	self com_printdebuginfo( "Printing info for cmd index '" + index + "'" );
	self com_printdebuginfo( "cmd_name: '" + cmd_obj.cmd_data_source.cmd_name + "'" );
	self com_printdebuginfo( "cmd_string: '" + cmd_obj.cmd_string + "'" );
	for ( i = 0; i < _SIZE( cmd_obj.args.size ); i++ )
	{
		self com_printdebuginfo( "args[ '" + i + "' ]: " + cmd_obj.args[ i ] );
	}

	foreach ( key, value in cmd_obj.kvps )
	{
		self com_printdebuginfo( "kvps[ '" + key + "' ]:" );
		self com_printdebuginfo( "base_key: " + value.base_key );
		self com_printdebuginfo( "type: " + value.type );
		for ( i = 0; i < _SIZE( value.v.size ); i++ )
		{
			self com_printdebuginfo( "v[ '" + i + "' ]: " + value.v[ i ] );
		}
	}
}

cmd_execute_internal( message, initiator, is_hidden, is_team_chat )
{
	if ( !isdefined( initiator.exception_obj ) )
	{
		initiator.exception_obj = generic_obj_t_new();
		initiator.exception_obj thread handle_parse_exception_feedback( initiator );
	}
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
	cmd_parse_obj = parse_cmd_message( message );
	initiator add_cmd_history( message );

	if ( !has_all_perms )
	{
		initiator check_multi_commands( cmd_parse_obj );
	}

	i = 0;
	foreach ( key, cmd_obj in cmd_parse_obj.cmds )
	{
		executor_directive = cmd_obj.kvps[ "executor" ];
		executors = initiator get_executors( executor_directive );
		debug_print_execute( i, cmd_obj );

		if ( is_true( cmd_obj.cmd_data_source.immune_to_lastcmd ) && is_true( initiator.in_lastcmd_execution_block ) )
		{
			continue;
		}

		for ( executor_index = 0; executor_index < _SIZE( executors.size ); executor_index++ )
		{
			executor = executors[ executor_index ];

			if ( !has_all_perms )
			{
				if ( executor != initiator && !initiator has_permission_for_executor_syntax() )
				{
					initiator throw_exception( cmd_obj, "You do not have permission to specify executors " );
				}

				if ( !initiator has_permission_for_cmd( cmd_obj.cmd_data_source ) )
				{
					initiator throw_exception( cmd_obj, "You do not have permission to use '{}' cmd", cmd_obj.cmd_data_source.cmd_name );
				}
			}

			initiator.tcs_silent_cmds = getdvarintdefault( "tcs_silent_cmds", 0 );
			initiator.tcs_logprint_cmd_usage = getdvarintdefault( "tcs_logprint_cmd_usage", 1 );
			initiator.tcs_feedback_mode = getdvarintdefault( "tcs_feedback_mode", 1 ); // 0 == executor receives cmd feedback, 1 == initiator receives cmd feedback, 2 == initiator and executor receives cmd feedback, 3 == same as 2 but also print the additional msgs to the initiator/executor
			executor cmd_execute_internal1( initiator, cmd_obj );
		}

		i++;
	}

	if ( !has_all_perms )
	{
		initiator thread cmd_cooldown();
	}
}

private arg_cast( arg_type, arg )
{
	msgs = [];
	foreach ( atype, val in arg_type.overloads )
	{
		if ( !isDefined( level.tcs_arg_type_handlers[ atype ] ) || !isDefined( level.tcs_arg_type_handlers[ atype ].cast_func ) )
		{
			return arg;
		}

		cast_result = self [[ level.tcs_arg_type_handlers[ atype ].cast_func ]]( arg );

		if ( cast_result.errored )
		{
			msgs[ msgs.size ] = cast_result.msg;
			continue;
		}
			
		return cast_result.value;
	}

	self throw_exception( undefined, "Failed to cast to one of the valid overloads for arg_type, attempted casts: '{}'", repackage_args( msgs, "\n" ) );
}

private target_cast( cmd_data_source, ordinal, target_type, target_kvp, default_value )
{
	foreach ( etype, val in target_type.overloads )
	{
		value = self get_entity_targets( etype, target_kvp, default_value );

		if ( array_validate( value ) )
		{
			if ( value.size > val.max_targets )
			{
				self throw_exception( undefined, "Command '{}' expects a maximum of '{}' targets, for '{}' got '{}' instead", cmd_data_source.cmd_name, val.max_targets, target_type.name, value.size );
			}

			return value;
		}
	}

	return [];
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

private get_array_entities( directive, etype )
{
	str_no_brackets = getsubstr( directive.v[ 0 ], 1, directive.v[ 0 ].size - 1 );
	values = strtok( str_no_brackets, "," );
	ents = [];
	foreach ( presumed_ent in values )
	{
		ent_obj = cast_str_to_entity( presumed_ent, etype );
		if ( ent_obj.errored )
		{
			return [];
		}

		ents[ ents.size ] = ent_obj.value;
	}

	// no point in doing further randomization...
	if ( directive.type == "array" || ents.size == 1 )
	{
		return ents;
	}

	return add_to_array( undefined, random_val( ents ) );
}

private get_name_entities( directive, etype )
{
	ents = [];
	ent_obj = cast_str_to_entity( directive.v[ 0 ], etype );
	if ( ent_obj.errored )
	{
		return [];
	}

	ents[ 0 ] = ent_obj.value;
	return ents;
}

private get_executors( directive )
{
	if ( !isdefined( directive ) )
	{
		return self.default_executors;
	}
	switch ( directive.type )
	{
		case "all":
			return level.players;
		case "undefined": // error
			return [];
		case "random":
			limit = 1;
			if ( isdefined( directive.v[ 0 ] ) )
			{
				directive_str_trimmed = getsubstr( directive.v[ 0 ], 1 );
				limit = int( directive_str_trimmed );
			}
			
			return get_random_limited_array( level.players, limit );
		case "array":
		case "array_random":
			return get_array_entities( directive, "player" );
		case "self":
			return add_to_array( undefined, self );
		case "default":
			return self.default_executors;
		case "name":
			return get_name_entities( directive, "player" );
	}

	self throw_exception( undefined, "Unknown directive.type: '{}'", directive.type );
	return [];
}

private get_entity_targets( etype, directive, default_value )
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

	if ( directive.type == "undefined" )
	{
		switch ( default_value )
		{
			case "self":
				return add_to_array( undefined, self );
			default:
				break;
		}
	}

	switch ( directive.type )
	{
		case "all":
			return self [[ getter_func ]]();
		case "undefined":
		case "default":
			return [];
		case "random":
			ents = [[ getter_func ]]();
			limit = 1;
			if ( isdefined( directive.v[ 0 ] ) )
			{
				directive_str_trimmed = getsubstr( directive.v[ 0 ], 1 );
				limit = int( directive_str_trimmed );
			}
			
			return get_random_limited_array( ents, limit );
		case "array":
		case "array_random":
			return get_array_entities( directive, etype );
		case "self":
			return add_to_array( undefined, self );
		case "function_call":
			if ( directive.v[ 0 ] == "" )
			{
				// TODO: search paths
				return [];
			}

			func = getfunction( directive.v[ 0 ], directive.v[ 1 ] );
			if ( isdefined( func ) )
			{
				// structure of arguments:
				// 0 = caller
				// > 0 = regular arguments
				// caller must always be defined, but it can be level or '#' for default which would use the normal argument casting logic
				args = strtok( directive.v[ 2 ], "," );
				// requires casting without millions of script errors
			}
			// TODO: check entities to match the expected etype
			return [];
		case "name":
			return get_name_entities( directive, etype );
	}

	self throw_exception( undefined, "Unknown directive.type: '{}'", directive.type );
	return [];
}

private cmd_execute_internal1( initiator, cmd_obj )
{
	cmd_data_source = cmd_obj.cmd_data_source;

	if ( cmd_obj.args.size < cmd_data_source get_min_args() )
	{
		initiator throw_exception( undefined, "Too few args: usage: '{}'", cmd_data_source.usage );
	}
	if ( cmd_obj.args.size > cmd_data_source get_max_args() )
	{
		initiator throw_exception( undefined, "Too many args: usage: '{}'", cmd_data_source.usage );
	}

	param = generic_obj_t_new( "param" );
	param.t = []; // targets
	param.a = cmd_obj.args; // arguments

	// Cast the args using the cast handlers
	// Arg types without a cast handler don't get casted
	// Leaving the casting up to the cmd itself
	if ( array_validate( cmd_data_source.arg_types ) )
	{
		i = 0;
		foreach ( key, val in cmd_data_source.arg_types )
		{
			arg = cmd_obj.args[ i ];
			if ( !isdefined( arg ) && isdefined( val.default_value ) )
			{
				// arguments sent is less than max possible arguments
				param.a[ i ] = val.default_value; // assign the default value from the command definition, "default_value" is default undefined
				i++;
				continue;
			}

			if ( !isdefined( arg ) && !val.is_required )
			{
				i++;
				continue;
			}

			arg_type = val;
			if ( is_true( arg_type.overloads[ "..." ] ) )
			{
				// consume rest of arguments
				for ( j = i; j < _SIZE( cmd_obj.args.size ); j++ )
				{
					param.a[ j ] = cmd_obj.args[ j ];
				}

				break;
			}

			param.a[ i ] = initiator arg_cast( arg_type, arg );
			i++;
		}
	}

	if ( array_validate( cmd_obj.kvps ) )
	{
		if ( array_validate( cmd_data_source.target_types ) )
		{
			// find target kvps
			cmd_target_keys = getarraykeys( cmd_obj.kvps );
			foreach ( ordinal_key, target_type in cmd_data_source.target_types )
			{
				target_kvp = cmd_obj.kvps_ordinal[ ordinal_key ];
				if ( isdefined( target_kvp ) && target_kvp.base_key != "target" && target_kvp.base_key != "t" )
				{
					continue;
				}

				if ( !isdefined( target_kvp ) )
				{
					if ( target_type.is_required )
					{
						initiator throw_exception( undefined, "'target '{}' is required", ordinal_key );
					}

					continue;
				}

				ordinal = int( ordinal_key );
				index = ordinal - 1;
				target_type = get_target_type_from_ordinal( cmd_data_source, ordinal );
				param.t[ index ] = initiator target_cast( cmd_data_source, ordinal, target_type, target_kvp );

				if ( !array_validate( param.t[ index ] ) && ( target_kvp.type != "undefined" && target_kvp.type != "default" ) )
				{
					initiator throw_exception( undefined, "Failed to find any compatible entities" );
				}
			}
		}

		// forward command to extra local clients
		if ( isdefined( cmd_obj.kvps[ "cl" ] ) || isdefined( cmd_obj.kvps[ "client" ] ) )
		{
			
		}
	}

	for ( i = 0; i < _SIZE( cmd_data_source.target_types.size ); i++ )
	{
		// initialize the arrays for the targets for [ 0 ] deref in _DEFAULT to not script error
		if ( !isdefined( param.t[ i ] ) )
		{
			param.t[ i ] = [];
		}
	}

	param.executor = self;
	param.initiator = initiator;
	self [[ cmd_data_source.func ]]( param );

	self handle_feedback( initiator, cmd_obj, param );
}

private handle_feedback( initiator, cmd_obj, param )
{
	if ( is_true( initiator.tcs_logprint_cmd_usage ) && !is_true( level.doing_cmd_system_unittest ) )
	{
		cmd_log = "";
		if ( self != initiator )
		{
			cmd_log = "'" + initiator.name + " executed '" + cmd_obj.cmd_string + "', on behalf of '" + self.name + "'";
		}
		else
		{
			cmd_log = "'" + initiator.name + "' executed '" + cmd_obj.cmd_string + "'";
		}
		
		initiator com_printinfo( cmd_log );
	}
	if ( !array_validate( param.result_array ) || is_true( initiator.tcs_silent_cmds ) )
	{
		return;
	}

	for ( i = 0; i < _SIZE( param.result_array.size ); i++ )
	{
		player = param.result_array[ i ].player;
		if ( player == param.executor || player == param.initiator )
		{
			if ( initiator.tcs_feedback_mode < 3 )
			{
				continue;
			}
		}

		level com_printf( param.result_array[ i ].channels, param.result_array[ i ].filter, param.result_array[ i ].msg, player );
	}

	if ( initiator.tcs_feedback_mode == 2 )
	{
		if ( initiator != self )
		{
			initiator print_feedback( param );
		}
		
		self print_feedback( param );
	}
	else if ( initiator.tcs_feedback_mode == 1 )
	{
		initiator print_feedback( param );
	}
	else if ( initiator.tcs_feedback_mode == 0 )
	{
		self print_feedback( param );
	}
}

private print_feedback( param )
{
	for ( i = 0; i < _SIZE( param.result_array.size ); i++ )
	{
		player = param.result_array[ i ].player;
		if ( player != self )
		{
			continue;
		}

		level com_printf( param.result_array[ i ].channels, param.result_array[ i ].filter, param.result_array[ i ].msg, self );
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
		// there is no local client, so the server will always need to specify an executor, unless they specify the default_executors
		level notify( "say", dvar_value, _GET_SERVER_ENTITY(), true, false );
	}
}