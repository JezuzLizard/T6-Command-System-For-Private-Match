#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;

_DEFAULT( value, default_value )
{
	if ( !isdefined( value ) )
	{
		return default_value;
	}

	return value;
}

array_validate( array )
{
	return isdefined( array ) && isarray( array ) && array.size > 0;
}

server_safe_notify_thread( notify_name, index )
{
	wait( ( 0.05 * index ) + 0.05 );
	level notify( notify_name );
}

/*generic_obj_t*/ generic_obj_t_new( obj_type )
{
	generic_obj = spawnstruct();
	generic_obj.warning = false;
	generic_obj.errored = false;
	generic_obj.msg = "";
	generic_obj.obj_type = obj_type;
	generic_obj.objects = []; // kvp array of obj_type to easily add references to other obj types for debugging
	return generic_obj;
}

/*void*/ add_obj_ref( parent_obj, child_obj )
{
	if ( isdefined( parent_obj.objects[ child_obj.obj_type ] ) || isdefined( child_obj.objects[ parent_obj.obj_type ] ) )
	{
		// force a script error which prints a callstack, regardless of dev script
		str = 5;
		str *= undefined;
		return;
	}

	parent_obj.objects[ child_obj.obj_type ] = child_obj;
}

/*void*/ remove_obj_ref( parent_obj, obj_type )
{
	if ( !isdefined( parent_obj.objects[ obj_type ] ) )
	{
		// force a script error which prints a callstack, regardless of dev script
		str = 5;
		str *= undefined;
		return;
	}

	parent_obj.objects[ obj_type ] = undefined;
}

/*result_t*/ result_new( msg, filter, channels = "" )
{
	result = generic_obj_t_new( "result" );
	result.msg = msg;
	result.filter = filter;
	result.channels = channels;

	return result;
}

/*result_t*/ result_copy( result )
{
	copy_result = generic_obj_t_new( "result" );
	copy_result.msg = result.msg;
	copy_result.filter = result.filter;
	copy_result.channels = result.channels;
	copy_result.errored = result.errored;

	return copy_result;
}

/*result_t*/ result_cmdinfo( msg )
{
	result = result_new( msg, "cmdinfo" );

	return result;
}

/*result_t*/ result_cmderror( msg )
{
	result = result_new( msg, "cmderror" );
	result.errored = true;

	return result;
}

/*result_obj_t*/ result_obj_new( expected_value_type, underlying_type, noprint = true )
{
	result_obj = generic_obj_t_new( "result_obj" );
	result_obj.noprint = noprint;
	result_obj.value = undefined;
	result_obj.type = expected_value_type;
	result_obj.underlying_type = underlying_type;

	return result_obj;
}

/*result_obj_t*/ result_obj_copy( result_obj )
{
	copy_result_obj = generic_obj_t_new( "result_obj" );
	copy_result_obj.errored = result_obj.errored;
	copy_result_obj.noprint = result_obj.noprint;
	copy_result_obj.value = result_obj.value;
	copy_result_obj.type = result_obj.type;
	copy_result_obj.underlying_type = result_obj.underlying_type;
	copy_result_obj.msg = result_obj.msg;

	return copy_result_obj;
}

/*result_obj_t*/ set_cast_error( result_obj, error_msg, expected_value_type = undefined )
{
	result_obj.errored = true;
	result_obj.value = undefined;
	if ( isdefined( expected_value_type ) )
	{
		result_obj.type = expected_value_type;
	}
	result_obj.msg = error_msg;

	return result_obj;
}

/*result_obj_t*/ set_cast_success( result_obj, new_value, success_msg, expected_value_type = undefined )
{
	result_obj.value = new_value;
	result_obj.msg = success_msg;
	if ( isdefined( expected_value_type ) )
	{
		result_obj.type = expected_value_type;
	}

	return result_obj;
}

/*target_obj_t*/ target_obj_new( expected_value_type, underlying_type, max_targets = 64, error_if_not_found = true )
{
	target_obj = generic_obj_t_new( "target_obj" );
	target_obj.error_if_not_found = error_if_not_found;
	target_obj.targets = [];
	target_obj.max_targets = max_targets;
	target_obj.type = expected_value_type;
	target_obj.underlying_type = underlying_type;

	return target_obj;
}

/*target_obj_t*/ set_targets_error( target_obj, error_msg, expected_value_type = undefined )
{
	target_obj.errored = true;
	if ( isdefined( expected_value_type ) )
	{
		target_obj.type = expected_value_type;
	}
	target_obj.msg = error_msg;

	return target_obj;
}

/*bool*/ add_target( target_obj, /*entity*/ new_target )
{
	if ( target_obj.targets.size >= target_obj.max_targets )
	{
		return false;
	}

	target_obj.targets = add_to_array( target_obj.targets, new_target, false );

	return true;
}

/*target_obj_t*/ set_targets_success( target_obj, success_msg, expected_value_type = undefined )
{
	target_obj.msg = success_msg;
	if ( isdefined( expected_value_type ) )
	{
		target_obj.type = expected_value_type;
	}

	return target_obj;
}

repackage_args( args )
{
	args_string = "";
	if ( !isdefined( args ) )
	{
		return args_string;
	}
	for ( i = 0; i < args.size; i++ )
	{
		if ( i == ( args.size - 1 ) )
		{
			args_string = args_string + args[ i ];
			continue;
		}
		args_string = args_string + args[ i ] + " ";
	}
	return args_string;
}

cmd_add( cmd_name, cmdfunc, cmd_usage )
{
	cmd_usage = _DEFAULT( cmd_usage, cmd_name );
	if ( !isdefined( level.tcs_cmds ) )
	{
		level.tcs_cmds = [];
	}

	rank_group = level.tcs_cmd_register_rank_group;
	if ( !isdefined( rank_group ) || !isdefined( level.tcs_perms.ranks[ rank_group ] ) )
	{
		level com_printf( "con|g_log", "cmderror", "Failed to register cmd " + cmd_name + ", attempted to use an unregistered rank_group!" );
		return;
	}

	aliases = [];
	aliases[ 0 ] = cmd_name;

	level.tcs_cmds[ cmd_name ] = spawnstruct();
	level.tcs_cmds[ cmd_name ].cmd_name = cmd_name;
	level.tcs_cmds[ cmd_name ].usage = cmd_usage;
	level.tcs_cmds[ cmd_name ].func = cmdfunc;
	level.tcs_cmds[ cmd_name ].aliases = aliases;
	level.tcs_cmds[ cmd_name ].power = level.tcs_perms.ranks[ rank_group ].cmdpower;
	level.tcs_cmds[ cmd_name ].is_cmd_object = true;
	level.tcs_cmds[ cmd_name ].min_args = 0;
	level.tcs_cmds[ cmd_name ].max_args = 0;
	level.tcs_cmds[ cmd_name ].arg_types = [];
	level.tcs_cmds[ cmd_name ].target_types = [];
	level.tcs_cmds[ cmd_name ].rank_group = rank_group;
	level.tcs_glob.icmd_total++;
	if ( !isdefined( level.cmd_groups ) )
	{
		level.cmd_groups = [];
	}
	if ( !isdefined( level.cmd_groups[ rank_group ] ) )
	{
		level.cmd_groups[ rank_group ] = [];
	}
	level.cmd_groups[ rank_group ][ cmd_name ] = true;

	return level.tcs_cmds[ cmd_name ];
}

cmd_remove( cmd )
{
	new_cmd_array = [];
	cmd_keys = getarraykeys( level.tcs_cmds );
	found_cmd = false;
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		cmd_k = cmd_keys[ i ];
		if ( cmd != cmd_k )
		{
			new_cmd_array[ cmd_k ] = spawnstruct();
			new_cmd_array[ cmd_k ].usage = level.tcs_cmds[ cmd_k ].usage;
			new_cmd_array[ cmd_k ].func = level.tcs_cmds[ cmd_k ].func;
			new_cmd_array[ cmd_k ].aliases = level.tcs_cmds[ cmd_k ].aliases;
			new_cmd_array[ cmd_k ].power = level.tcs_cmds[ cmd_k ].power;
			new_cmd_array[ cmd_k ].min_args = level.tcs_cmds[ cmd_k ].min_args;
			new_cmd_array[ cmd_k ].max_args = level.tcs_cmds[ cmd_k ].max_args;
			new_cmd_array[ cmd_k ].arg_types = level.tcs_cmds[ cmd_k ].arg_types;
			new_cmd_array[ cmd_k ].user_valid_check_func = level.tcs_cmds[ cmd_k ].user_valid_check_func;
		}
		else 
		{
			found_cmd = true;
			rank_groups = getarraykeys( level.cmd_groups );
			for ( j = 0; j < rank_groups.size; j++ )
			{
				if ( isdefined( level.cmd_groups[ rank_groups[ i ] ][ cmd_k ] ) )
				{
					level.cmd_groups[ rank_groups[ i ] ][ cmd_k ] = undefined;
					break;
				}
			}
		}
	}
	if ( found_cmd )
	{
		level.tcs_glob.icmd_total--;
	}
	level.tcs_cmds = new_cmd_array;
}

cmd_remove_by_group( rank_group )
{
	if ( !isdefined( level.cmd_groups[ rank_group ] ) )
	{
		return;
	}
	cmds = getarraykeys( level.cmd_groups[ rank_group ] );
	for ( i = 0; i < cmds.size; i++ )
	{
		cmd_remove( cmds[ i ] );
	}
}

cmd_set_power( power )
{
	if ( is_true( self.is_cmd_object ) )
	{
		self.power = power;
	}
}

cmd_block_set_rank_group( rank_group )
{
	level.tcs_cmd_register_rank_group = rank_group;
}

arg_obj_add_cmd( arg_types, min_args, max_args )
{
	if ( !is_true( self.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	self.min_args = min_args;
	self.max_args = max_args;

	if ( !isdefined( arg_types ) || arg_types == "" )
	{
		return;
	}
	self.arg_types = strTok( arg_types, " " );
}

alias_obj_add_cmd( cmd_aliases )
{
	if ( isdefined( cmd_aliases ) && cmd_aliases != "" )
	{
		cmd_aliases_tokens = strTok( cmd_aliases, " " );
		for ( i = 1; i <= cmd_aliases_tokens.size; i++ )
		{
			self.aliases[ i ] = cmd_aliases_tokens[ i - 1 ];
		}
	}
}

arg_obj_register( argtype, checker_func, rand_gen_func, cast_func, error_message, is_targetable = false )
{
	if ( !isDefined( level.tcs_arg_type_handlers ) )
	{
		level.tcs_arg_type_handlers = [];
	}
	if ( !isDefined( argtype ) || argtype == "" )
	{
		return;
	}
	level.tcs_arg_type_handlers[ argtype ] = spawnStruct();
	level.tcs_arg_type_handlers[ argtype ].checker_func = checker_func;
	level.tcs_arg_type_handlers[ argtype ].rand_gen_func = rand_gen_func;
	level.tcs_arg_type_handlers[ argtype ].cast_func = cast_func;
	level.tcs_arg_type_handlers[ argtype ].error_message = error_message;
	level.tcs_arg_type_handlers[ argtype ].is_targetable = is_targetable;
}

cmd_add_unittest_exclusion( cmd )
{
	if ( !isDefined( level.cmd_system_unittest_cmd_exclusions ) )
	{
		level.cmd_system_unittest_cmd_exclusions = [];
	}
	level.cmd_system_unittest_cmd_exclusions[ cmd ] = true;
}

//If we have a lot of clientdvars in the pool delay setting them to prevent client cmd overflow error.
set_client_dvar_thread( dvar, value, index )
{
	wait( index * 0.25 );
	self setClientDvar( dvar, value );
}

check_for_cmd_alias_collisions()
{
	wait 5;
	cmd_keys = getArrayKeys( level.tcs_cmds );
	aliases = [];
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		for ( j = 0; j < level.tcs_cmds[ cmd_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.tcs_cmds[ cmd_keys[ i ] ].aliases[ j ];
		}
	}
	for ( i = 0; i < aliases.size; i++ )
	{
		for ( j = i + 1; j < aliases.size; j++ )
		{
			if ( i != j && aliases[ i ] == aliases[ j ] )
			{
				level com_printf( "con|g_log", "cmderror", "Cmd alias collision detected alias " + aliases[ i ] + " is duplicated" );
				break;
			}
		}
	}
}

getDvarStringDefault( dvarname, default_value )
{
	cur_dvar_value = getDvar( dvarname );
	if ( isDefined( cur_dvar_value ) && cur_dvar_value != "" )
	{
		return cur_dvar_value;
	}
	else 
	{
		setDvar( dvarname, default_value );
		return default_value;
	}
}

is_cmd_token( char )
{
	if ( isdefined( level.custom_cmds_tokens ) && isdefined( level.custom_cmds_tokens[ char ] ) )
	{
		return true;
	}
	return false;
}

notify_callback_thread( notify_name, func, ent = undefined )
{
	if ( !isdefined( ent ) )
	{
		ent = level;
	}

	ent notify( notify_name + "_death" );
	ent endon( notify_name + "_death" );

	for ( ;; )
	{
		ent waittill( notify_name, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 );
		ent thread [[ func ]]( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 );
	}
}

add_notify_callback( notify_name, func, ent = undefined )
{
	if ( !isdefined( ent ) )
	{
		ent = level;
	}

	if ( !isdefined( ent._notify_callbacks ) || !isdefined( ent._notify_callbacks[ notify_name ] ) )
	{
		ent._notify_callbacks[ notify_name ] = [];
	}

	level thread notify_callback_thread( notify_name, func, ent );
}

remove_notify_callback( notify_name, ent = undefined )
{
	if ( !isdefined( ent ) )
	{
		ent = level;
	}

	if ( !isdefined( ent._notify_callbacks ) || !isdefined( ent._notify_callbacks[ notify_name ] ) )
	{
		return;
	}

	ent notify( notify_name + "_death" );
	ent._notify_callbacks[ notify_name ] = undefined;
}

pop( arr_obj, index )
{
	arrayremoveindex( arr_obj.array, index );
}

pop_front( arr_obj )
{
	pop( arr_obj, 0 );
}

pop_back( arr_obj )
{
	pop( arr_obj, ( arr_obj.array.size - 1 ) );
}
