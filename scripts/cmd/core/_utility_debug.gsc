#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

#include scripts\cmd\core\_api_cmd;

com_printdebuginfo_internal( format, a, b, c, d, e, f, g, h, i, j, k )
{
	if ( getdvarint( "tcs_developer" ) )
	{
		_GET_SERVER_ENTITY() com_printinfo( format, a, b, c, d, e, f, g, h, i, j, k );
	}
}

com_printdebugwarning_internal( format, a, b, c, d, e, f, g, h, i, j, k )
{
	if ( getdvarint( "tcs_developer" ) )
	{
		_GET_SERVER_ENTITY() com_printwarning( format, a, b, c, d, e, f, g, h, i, j, k );
	}
}

com_printdebugerror_internal( format, a, b, c, d, e, f, g, h, i, j, k )
{
	if ( getdvarint( "tcs_developer" ) )
	{
		_GET_SERVER_ENTITY() com_printerror( format, a, b, c, d, e, f, g, h, i, j, k );
	}
}

print_obj_internal()
{
	if ( !isdefined( self ) || !isdefined( self.obj_type ) )
	{
		_ASSERT_MSG( false );
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

	generic_obj = generic_obj_t_new( "debug_exception" );
	generic_obj.callstack = true;
	generic_obj.debugbox = true;
	throw_exception( "debug", generic_obj, fmt, a, b, c, d, e, f, g, h, i, j, k );

	return true;
}