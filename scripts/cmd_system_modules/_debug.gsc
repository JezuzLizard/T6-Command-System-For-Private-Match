/*generic_obj*/ check_script_error( obj, expected_type, force_error = false )
{
	if ( !isdefined( obj ) )
	{
		obj = generic_obj_t_new( "void" );
		obj.msg = "Attempted to set cmd parse error for an undefined object";
		obj.errored = true;
	}

	if ( obj.type != expected_type )
	{
		obj.msg = "Attempted to set obj type of '" + expected_type + "' for '" + obj.type + "'";
		obj.errored = true;
	}

	if ( ( obj.errored || force_error ) && getdvarint( "cmd_debug_debugbreak" ) )
	{
		// print state info
		// block further execution with waited loop?
		assert( false );
		com_printerror( obj.msg );
		for ( ;; )
		{
			should_continue = getdvarint( "cmd_debug_continue" );

			if ( should_continue )
			{
				setdvar( "cmd_debug_continue", 0 );
				break;
			}

			wait 0.05;
		}
	}
}

script_breakpoint( display_callstack = true, should_print = true )
{
	if ( !isdefined( level.script_breakpoints ) )
	{
		level.script_breakpoints = [];
	}

	if ( display_callstack )
	{
		assert( false );
	}

	if ( should_print )
	{
		self print_obj();
	}

	level.script_breakpoints[ self.name ].enabled = true;
	while ( isdefined( level.script_breakpoints[ self.name ] ) && is_true( level.script_breakpoints[ self.name ].enabled ) )
	{
		evt = self waittill_any_return( "debug_continue", "debug_abort" );

		if ( evt == "debug_continue" )
		{
			break;
		}
		else if ( evt == "debug_abort" )
		{
			self notify( self.name + "_" + self.id + "_abort" );
			break;
		}
	}
}

print_obj()
{
	if ( !isdefined( self ) || !isdefined( self.obj_type ) )
	{
		str = 5;
		str *= undefined;
		return;
	}
	// print relevant data

	print_entity = self.owner;
	// common fields
	print_entity com_printinfo( "Printing " + self.obj_type + " fields: " );
	print_entity com_printinfo( self.obj_type );
	print_entity com_printinfo( self.warning );
	print_entity com_printinfo( self.errored );
	print_entity com_printinfo( self.msg );

	if ( self.obj_type == "cmd_execute" )
	{
		print_entity com_printinfo( self.owner.name );
		print_entity com_printinfo( self.id );
		if ( isdefined( self.objects ) )
		{
			foreach ( key, object in self.objects )
			{
				print_entity com_printinfo( "Printing child fields: " + key );
				object print_obj();
			}
		}
	}
	else if ( self.obj_type == "cmd_parse_array" )
	{
		foreach ( key, object in self.cmds )
		{
			print_entity com_printinfo( "Printing cmd fields: " + key );
			object print_obj();
		}
	}
	else if ( self.obj_type == "cmd_parse" )
	{
		print_entity com_printinfo( self.cmd_name );
		print_entity com_printinfo( self.start_pos );
		print_entity com_printinfo( self.end_pos );
		foreach ( key, object in self.args )
		{
			print_entity com_printinfo( "Printing arg fields: " + key );
			object print_obj();
		}
	}
	else if ( self.obj_type == "arg_parse" )
	{
		print_entity com_printinfo( self.arg );
	}
	else if ( self.obj_type == "directive_parse" )
	{
		print_entity com_printinfo( self.directive_type );
		self.directive_value print_obj();
	}
	else if ( self.obj_type == "token_parse" )
	{
		print_entity com_printinfo( self.token_type );
		foreach ( key, value in self.token_values )
		{
			print_entity com_printinfo( value );
		}
	}
	else if ( self.obj_type == "player" )
	{
		print_entity com_printinfo( self.name );
		print_entity com_printinfo( self.clientnum );
		print_entity com_printinfo( self.guid );
		print_entity com_printinfo( self.origin );
		print_entity com_printinfo( self.angles );
	}
}

com_printcmd( cmd_object )
{
	channels = self com_get_cmd_feedback_channel();
	level com_printf( channels, "notitle", "cmd_name: " + cmd_object.cmd_name, self );
	level com_printf( channels, "notitle", "usage: " + cmd_object.usage, self );
	level com_printf( channels, "notitle", "func: " + getfunctionname( cmd_object.func ), self );
	level com_printf( channels, "notitle", "aliases: " + repackage_args( cmd_object.aliases ), self );
	level com_printf( channels, "notitle", "power: " + cmd_object.power, self );
	level com_printf( channels, "notitle", "min_args: " + cmd_object.min_args, self );
	level com_printf( channels, "notitle", "max_args: " + cmd_object.max_args, self );
	level com_printf( channels, "notitle", "arg_types: " + repackage_args( cmd_object.arg_types ), self );
	level com_printf( channels, "notitle", "rank_group: " + cmd_object.rank_group, self );
}