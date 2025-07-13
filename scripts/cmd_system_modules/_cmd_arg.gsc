#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_cmd_util;

arg_cast( arg_type, arg, arg_index )
{
	cast_result = result_obj_new( "argtype", "struct" );
	if ( isDefined( level.tcs_arg_type_handlers[ arg_type ] ) && isDefined( level.tcs_arg_type_handlers[ arg_type ].cast_func ) )
	{
		cast_result = self [[ level.tcs_arg_type_handlers[ arg_type ].cast_func ]]( arg );
			
		return cast_result;
	}

	return set_cast_success( cast_result, arg, "no argtype defined" );
}

test_cmd_is_valid( cmd_object, args )
{
	//self com_printcmd( cmd_object );
	if ( args.size < cmd_object.min_args )
	{
		self throw_execute_exception( "Too few args: usage: " + cmd_object.usage );
	}
	if ( args.size > cmd_object.max_args )
	{
		self throw_execute_exception( "Too many args: usage: " + cmd_object.usage );
	}
	if ( array_validate( cmd_object.arg_types ) && args.size > 0 )
	{
		arg_types = cmd_object.arg_types;
		for ( i = 0; i < args.size; i++ )
		{
			if ( !isdefined( level.tcs_arg_type_handlers[ arg_types[ i ] ] ) )
			{
				self com_printerror( "Unhandled argtype: '" + arg_types[ i ] + "' in cmd: '" + cmd_object.cmd_name + "'!" );
				continue;
			}

			if ( !isdefined( level.tcs_arg_type_handlers[ arg_types[ i ] ].checker_func ) )
			{
				continue;
			}

			if ( !self [[ level.tcs_arg_type_handlers[ arg_types[ i ] ].checker_func ]]( args[ i ] ) )
			{
				arg_num = i;
				self throw_execute_exception( "Arg " + arg_num + " " + args[ i ] + " is " + level.tcs_arg_type_handlers[ arg_types[ i ] ].error_message );
			}
		}
	}
	return true;
}


