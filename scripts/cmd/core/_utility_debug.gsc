#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;

#include scripts\cmd\sv\core\_api_cmd;

com_printdebuginfo_internal( format, a, b, c, d, e, f, g, h, i, j, k )
{
	if ( level._tcs_developer )
	{
		_GET_SERVER_ENTITY() com_printinfo( format, a, b, c, d, e, f, g, h, i, j, k );
	}
}

com_printdebugwarning_internal( format, a, b, c, d, e, f, g, h, i, j, k )
{
	if ( level._tcs_developer )
	{
		_GET_SERVER_ENTITY() com_printwarning( format, a, b, c, d, e, f, g, h, i, j, k );
	}
}

com_printdebugerror_internal( format, a, b, c, d, e, f, g, h, i, j, k )
{
	if ( level._tcs_developer )
	{
		_GET_SERVER_ENTITY() com_printerror( format, a, b, c, d, e, f, g, h, i, j, k );
	}
}

script_breakpoint_internal( generic_obj, msg, display_callstack, should_print )
{
	msg = _DEFAULT( msg, undefined );
	display_callstack = _DEFAULT( display_callstack, true );
	should_print = _DEFAULT( should_print, true );
	if ( !getdvarint( "script_breakpoint" ) )
	{
		return false;
	}
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
		if ( isdefined( msg ) )
		{
			self com_printerror( msg );
		}

		generic_obj print_obj_internal();
	}

	for ( ;; )
	{
		evt = self waittill_any_return( "debug_continue", "debug_abort" );

		if ( evt == "debug_continue" )
		{
			return true;
		}
		else if ( evt == "debug_abort" )
		{
			self notify( "cmd_exception", generic_obj );
			return false;
		}
	}
}

print_obj_internal()
{
	if ( !isdefined( self ) || !isdefined( self.obj_type ) )
	{
		assert( false );
		return;
	}
	// print relevant data

	// common fields
	com_printdebugwarning_internal( "Printing " + self.obj_type + " fields: " );
	com_printdebugwarning_internal( "obj_type: " + self.obj_type );
	com_printdebugwarning_internal( "warning: " + self.warning );
	com_printdebugwarning_internal( "errored: " + self.errored );
	com_printdebugwarning_internal( "msg: " + self.msg );

	if ( self.obj_type == "cmd_execute" )
	{
		com_printdebugwarning_internal( self.id );
		if ( isdefined( self.objects ) )
		{
			foreach ( key, object in self.objects )
			{
				com_printdebugwarning_internal( "Printing child fields: " + key );
				object print_obj_internal();
			}
		}
	}
	else if ( self.obj_type == "cmd_parse_array" )
	{
		foreach ( key, object in self.cmds )
		{
			com_printdebugwarning_internal( "Printing cmd fields: " + key );
			object print_obj_internal();
		}
	}
	else if ( self.obj_type == "cmd_parse" )
	{
		print_entity = _GET_SERVER_ENTITY();
		print_entity com_printcmd( self.cmd_data_source );
		com_printdebugwarning_internal( "start_pos: " + self.start_pos );
		com_printdebugwarning_internal( "end_pos: " + self.end_pos );
		for ( i = 0; i < _SIZE( self.args.size ); i++ )
		{
			ordinal = _MAKE_ORDINAL_KEY( ( i + 1 ) );
			com_printdebugwarning_internal( "arg" + ordinal + ": " + self.args[ i ] );
		}

		keys = getarraykeys( self.directive_kvps );
		for ( i = 0; i < _SIZE( keys.size ); i++ )
		{
			for ( j = 0; j < _SIZE( self.directive_kvps[ keys[ i ] ].size ); j++ )
			{
				self.directive_kvps[ keys[ i ] ][ j ] print_obj_internal();
			}
		}
	}
	else if ( self.obj_type == "directive_parse" )
	{
		com_printdebugwarning_internal( self.directive_type );
		self.directive_value print_obj_internal();
	}
	else if ( self.obj_type == "token_parse" )
	{
		com_printdebugwarning_internal( self.token_type );
		foreach ( key, value in self.token_values )
		{
			com_printdebugwarning_internal( value );
		}
	}
	else if ( self.obj_type == "player" )
	{
		com_printdebugwarning_internal( self.name );
		com_printdebugwarning_internal( self.clientnum );
		com_printdebugwarning_internal( self.guid );
		com_printdebugwarning_internal( self.origin );
		com_printdebugwarning_internal( self.angles );
	}
}

_MY_ASSERT_HANDLER( condition, fmt, a, b, c, d, e, f, g, h, i, j, k )
{
	if ( condition )
	{
		return false;
	}

	message = format( fmt, a, b, c, d, e, f, g, h, i, j, k );
	_GET_SERVER_ENTITY() com_printerror( message );

	if ( getdvarint( "do_assert_debug_box" ) )
	{
		assert( false );
		debugbox( fmt );
	}

	return true;
}