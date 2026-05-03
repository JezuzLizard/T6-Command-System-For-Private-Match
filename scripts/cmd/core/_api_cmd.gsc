#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;

cmd_add( cmd_name, cmdfunc, cmd_usage, description )
{
	cmd_usage = _DEFAULT( cmd_usage, cmd_name );
	description = _DEFAULT( description, "No description defined" );
	if ( !isdefined( level.tcs_cmds ) )
	{
		level.tcs_cmds = [];
	}

	level.tcs_cmd_register_working_cmd = undefined;

	rank_group = level.tcs_cmd_register_rank_group;
	if ( !isdefined( rank_group ) || !isdefined( level.tcs_perms.ranks[ rank_group ] ) )
	{
		level com_printf( "con|g_log", "cmderror", "Failed to register cmd " + cmd_name + ", attempted to use an unregistered rank_group!" );
		return;
	}

	module_group = level.tcs_cmd_register_module_group;
	if ( !isdefined( module_group ) )
	{
		level com_printf( "con|g_log", "cmderror", "Failed to register cmd " + cmd_name + ", attempted to use an unregistered module_group!" );
		return;
	}

	new_cmd = spawnstruct();
	new_cmd.cmd_name = cmd_name;
	new_cmd.usage = cmd_usage;
	new_cmd.desc = description;
	new_cmd.long_description = "";
	new_cmd.example = "";
	new_cmd.func = cmdfunc;
	new_cmd.is_cmd_object = true;
	new_cmd.arg_types = [];
	new_cmd.target_types = [];
	new_cmd.has_required_target = false;
	new_cmd.rank_group = rank_group;
	new_cmd.module_group = module_group;
	level.tcs_cmds[ cmd_name ] = new_cmd;
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

	if ( !isdefined( level._cmd_modules ) )
	{
		level._cmd_modules = [];
	}

	if ( !isdefined( level._cmd_modules[ module_group ] ) )
	{
		level._cmd_modules[ module_group ] = [];
	}

	level._cmd_modules[ module_group ][ level._cmd_modules[ module_group ].size ] = new_cmd;
	level.tcs_cmd_register_working_cmd = new_cmd;
}

cmd_add_detailed_desc( long_description )
{
	working_cmd = level.tcs_cmd_register_working_cmd;
	if ( !is_true( working_cmd.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	working_cmd.long_description = long_description;
}

cmd_block_set_rank_group( rank_group )
{
	level.tcs_cmd_register_rank_group = rank_group;
}

cmd_block_set_module_group( module_group )
{
	level.tcs_cmd_register_working_cmd = undefined; // this will allow for detecting unintended usage of arg/target registration

	level.tcs_cmd_register_module_group = module_group;
}

get_min_args()
{
	if ( !is_true( self.is_cmd_object ) )
	{
		assert( false );
		return 0;
	}

	count = 0;
	for ( i = 0; i < _SIZE( self.arg_types.size ); i++ )
	{
		ordinal = _MAKE_ORDINAL_KEY( ( i + 1 ) );
		if ( isdefined( self.arg_types[ ordinal ] ) && self.arg_types[ ordinal ].is_required )
		{
			count++;
		}
	}

	return count; 
}

get_max_args()
{
	if ( !is_true( self.is_cmd_object ) )
	{
		assert( false );
		return 0;
	}

	return self.arg_types.size; 
}

arg_add_required( ordinal, name, arg_type, desc )
{
	level.tcs_cmd_register_working_cmd arg_add( ordinal, name, arg_type, true, desc, undefined );
}

arg_add_optional( ordinal, name, arg_type, desc )
{
	level.tcs_cmd_register_working_cmd arg_add( ordinal, name, arg_type, false, desc );
}

arg_add_optional_with_default(  ordinal, name, arg_type, desc, default_value )
{
	level.tcs_cmd_register_working_cmd arg_add( ordinal, name, arg_type, false, desc, default_value );
}

target_add_required( ordinal, name, target_type, desc, max_targets )
{
	level.tcs_cmd_register_working_cmd target_add( ordinal, name, target_type, true, desc, max_targets );
}

target_add_optional( ordinal, name, target_type, desc, max_targets )
{
	level.tcs_cmd_register_working_cmd target_add( ordinal, name, target_type, false, desc, max_targets );
}

target_set_default_target( ordinal, default_value )
{
	working_cmd = level.tcs_cmd_register_working_cmd;
	if ( !isdefined( working_cmd ) || !is_true( working_cmd.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	switch ( default_value )
	{
		case "self":
			break;
		default:
			assert( false );
			return;
	}

	working_cmd.target_types[ _MAKE_ORDINAL_KEY( ordinal ) ].default_value = default_value;
}

make_cmd_immune_to_unittest()
{
	working_cmd = level.tcs_cmd_register_working_cmd;
	if ( !is_true( working_cmd.is_cmd_object ) || is_true( working_cmd.immune_to_unittest ) )
	{
		assert( false );
		return;
	}

	working_cmd.immune_to_unittest = true;
}

make_cmd_immune_to_lastcmd()
{
	working_cmd = level.tcs_cmd_register_working_cmd;
	if ( !is_true( working_cmd.is_cmd_object ) || is_true( working_cmd.immune_to_lastcmd ) )
	{
		assert( false );
		return;
	}

	working_cmd.immune_to_lastcmd = true;
}

com_printcmd( cmd_object )
{
	self com_printnotitle( "cmd_name: " + cmd_object.cmd_name );
	self com_printnotitle( "usage: " + cmd_object.usage );
	self com_printnotitle( "func: " + getfunctionname( cmd_object.func ) );
	self com_printnotitle( "min_args: " + cmd_object get_min_args() );
	self com_printnotitle( "max_args: " + cmd_object get_max_args() );
	self com_printnotitle( "rank_group: " + cmd_object.rank_group );
	self com_printnotitle( "module_group: " + cmd_object.module_group );
	self com_printnotitle( "desc: " + cmd_object.desc );
	self com_printnotitle( "example: " + cmd_object.example );
}

com_printcmd_help( cmd_object )
{
	self com_printnotitle( "Name: '{}'", cmd_object.cmd_name );
	self com_printnotitle( "Usage: '{}'", cmd_object.usage );
	self com_printnotitle( "Min Args: '{}'", cmd_object get_min_args() );
	self com_printnotitle( "Max Args: '{}'", cmd_object get_max_args() );
	self com_printnotitle( "Rank: '{}'", cmd_object.rank_group );
	self com_printnotitle( "Module: '{}'", cmd_object.module_group );
	self com_printnotitle( "Desc: '{}'", cmd_object.desc );
	self com_printnotitle( "Example: '{}'", cmd_object.example );

	arg_types = cmd_object.arg_types;
	if ( _ARRAY_VALIDATE( arg_types ) )
	{
		for ( i = 0; i < _SIZE( arg_types.size ); i++ )
		{
			arg_ordinal = _MAKE_ORDINAL_KEY( ( i + 1 ) );
			arg_name = arg_types[ arg_ordinal ].name;
			arg_desc = arg_types[ arg_ordinal ].desc;
			arg_is_required = arg_types[ arg_ordinal ].is_required;
			self com_printnotitle( "Arg Name: {}", arg_name );
			self com_printnotitle( "Arg Desc: '{}'", arg_desc );
			if ( arg_is_required )
			{
				self com_printnotitle( "[Optional Argument]" );
			}
			else
			{
				self com_printnotitle( "<Required Argument>" );
			}
			self com_printnotitle( "Arg Ordinal: '{}'", arg_ordinal );
		}
	}
	else
	{
		self com_printnotitle( "<Does not use args>" );
	}

	target_types = cmd_object.target_types;
	if ( _ARRAY_VALIDATE( target_types ) )
	{
		for ( i = 0; i < _SIZE( target_types.size ); i++ )
		{
			targ_ordinal = _MAKE_ORDINAL_KEY( ( i + 1 ) );
			target_typenames = getarraykeys( target_types[ targ_ordinal ].overloads );
			_ASSERT_MSG( target_typenames.size == 1, "com_printcmd_help: Target overloading is not yet implemented!" );
			target_name = target_types[ targ_ordinal ].name;
			target_desc = target_types[ targ_ordinal ].desc;
			target_is_required = target_types[ targ_ordinal ].is_required;
			overload = target_types[ targ_ordinal ].overloads[ target_typenames[ 0 ] ]; // overloading isn't implemented yet
			target_etype = overload.etype;
			target_max_targets = overload.max_targets;

			self com_printnotitle( "Target Name: '{}'", target_name );
			self com_printnotitle( "Target Desc: '{}'", target_desc );
			if ( target_is_required )
			{
				self com_printnotitle( "[Optional Target]" );
			}
			else
			{
				self com_printnotitle( "<Required Target>" );
			}
			self com_printnotitle( "Arg Ordinal: '{}'", targ_ordinal );
			self com_printnotitle( "Target EType: '{}'", target_etype );

			if ( target_max_targets != 1024 )
			{
				self com_printnotitle( "Target Max Targets: '{}'", target_max_targets );
			}
		}
	}
	else
	{
		self com_printnotitle( "<Does not use targets>" );
	}
}

// ordinal would allow argument overloading
private arg_add( ordinal, name, arg_type, is_required, desc, default_value )
{
	desc = _DEFAULT( desc, "No description" );
	default_value = _DEFAULT( default_value, undefined );
	ordinal = _MAKE_ORDINAL_KEY( ordinal ); // best to be a string

	working_cmd = level.tcs_cmd_register_working_cmd;

	if ( !isdefined( working_cmd ) || !is_true( working_cmd.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	if ( !isdefined( working_cmd.arg_types[ ordinal ] ) )
	{
		new_arg = spawnstruct();
		new_arg.name = name;
		new_arg.is_required = is_required;
		new_arg.ordinal = ordinal;
		new_arg.desc = desc;
		if ( !is_required )
		{
			new_arg.default_value = default_value;
		}
		new_arg.overloads = [];
		new_arg.overloads[ arg_type ] = true;

		working_cmd.arg_types[ ordinal ] = new_arg;
	}
	else if ( !isdefined( working_cmd.arg_types[ ordinal ].overloads[ arg_type ] ) )
	{
		working_cmd.arg_types[ ordinal ].overloads[ arg_type ] = true;
	}
	else
	{
		_ASSERT_MSG_ONLY( "Cannot overload argument ordinal: '{}' for command: '{}' with type: '{}' as it is already overloaded with that type", ordinal, working_cmd.cmd_name, arg_type );
	}

	if ( !isdefined( level.tcs_arg_type_handlers[ arg_type ] ) )
	{
		_ASSERT_MSG_ONLY( "Unknown arg type: '{}' being registered for cmd: '{}' at ordinal '{}", arg_type, working_cmd.cmd_name, ordinal );
	}
}

private target_add( ordinal, name, target_type, is_required, desc, max_targets )
{
	max_targets = _DEFAULT( max_targets, 1024 );
	desc = _DEFAULT( desc, "No description" );
	ordinal = _MAKE_ORDINAL_KEY( ordinal ); // best to be a string

	working_cmd = level.tcs_cmd_register_working_cmd;
	if ( !isdefined( working_cmd ) || !is_true( working_cmd.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	if ( !isdefined( working_cmd.target_types[ ordinal ] ) )
	{
		new_target = spawnstruct();
		new_target.name = name;
		new_target.is_required = is_required;
		new_target.ordinal = ordinal;
		new_target.desc = desc;
		new_target.default_value = "";
		new_target.overloads = [];

		new_overload = spawnstruct();
		new_overload.etype = target_type;
		new_overload.max_targets = max_targets;
		new_target.overloads[ target_type ] = new_overload;

		working_cmd.target_types[ ordinal ] = new_target;
	}
	else if ( !isdefined( working_cmd.target_types[ ordinal ].overloads[ target_type ] ) )
	{
		new_overload = spawnstruct();
		new_overload.etype = target_type;
		new_overload.max_targets = max_targets;
		working_cmd.target_types[ ordinal ].overloads[ target_type ] = new_overload;
	}
	else
	{
		_ASSERT_MSG_ONLY( "Cannot overload target ordinal: '{}' for command: '{}' with type: '{}' as it is already overloaded with that type", ordinal, working_cmd.cmd_name, target_type );
		return;
	}

	working_cmd.has_required_target = working_cmd.has_required_target || is_required;

	if ( !isdefined( level._entity_type_funcs[ target_type ] ) )
	{
		_ASSERT_MSG_ONLY( "Unknown entity type: '{}' registered for command: '{}'", target_type, working_cmd.cmd_name );
	}
}