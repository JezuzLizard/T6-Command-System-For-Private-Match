#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_com;

script_breakpoint( generic_obj, msg, display_callstack, should_print )
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

		generic_obj print_obj();
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

print_obj()
{
	if ( !isdefined( self ) || !isdefined( self.obj_type ) )
	{
		assert( false );
		return;
	}
	// print relevant data

	// common fields
	com_printdebugwarning( "Printing " + self.obj_type + " fields: " );
	com_printdebugwarning( "obj_type: " + self.obj_type );
	com_printdebugwarning( "warning: " + self.warning );
	com_printdebugwarning( "errored: " + self.errored );
	com_printdebugwarning( "msg: " + self.msg );

	if ( self.obj_type == "cmd_execute" )
	{
		com_printdebugwarning( self.id );
		if ( isdefined( self.objects ) )
		{
			foreach ( key, object in self.objects )
			{
				com_printdebugwarning( "Printing child fields: " + key );
				object print_obj();
			}
		}
	}
	else if ( self.obj_type == "cmd_parse_array" )
	{
		foreach ( key, object in self.cmds )
		{
			com_printdebugwarning( "Printing cmd fields: " + key );
			object print_obj();
		}
	}
	else if ( self.obj_type == "cmd_parse" )
	{
		print_entity = isdefined( level.host ) ? level.host : level.server;
		print_entity com_printcmd( self.cmd_data_source );
		com_printdebugwarning( "start_pos: " + self.start_pos );
		com_printdebugwarning( "end_pos: " + self.end_pos );
		for ( i = 0; i < _SIZE( self.args.size ); i++ )
		{
			ordinal = ( i + 1 );
			com_printdebugwarning( "arg" + ordinal + ": " + self.args[ i ] );
		}

		keys = getarraykeys( self.directive_kvps );
		for ( i = 0; i < _SIZE( keys.size ); i++ )
		{
			for ( j = 0; j < _SIZE( self.directive_kvps[ keys[ i ] ].size ); j++ )
			{
				self.directive_kvps[ keys[ i ] ][ j ] print_obj();
			}
		}
	}
	else if ( self.obj_type == "directive_parse" )
	{
		com_printdebugwarning( self.directive_type );
		self.directive_value print_obj();
	}
	else if ( self.obj_type == "token_parse" )
	{
		com_printdebugwarning( self.token_type );
		foreach ( key, value in self.token_values )
		{
			com_printdebugwarning( value );
		}
	}
	else if ( self.obj_type == "player" )
	{
		com_printdebugwarning( self.name );
		com_printdebugwarning( self.clientnum );
		com_printdebugwarning( self.guid );
		com_printdebugwarning( self.origin );
		com_printdebugwarning( self.angles );
	}
}

com_printcmd( cmd_object )
{
	self com_printnotitle( "cmd_name: " + cmd_object.cmd_name );
	self com_printnotitle( "usage: " + cmd_object.usage );
	self com_printnotitle( "func: " + getfunctionname( cmd_object.func ) );
	self com_printnotitle( "min_args: " + cmd_object get_min_args() );
	self com_printnotitle( "max_args: " + cmd_object get_max_args() );
	//self com_printnotitle( "arg_types: " + repackage_args( cmd_object.arg_types ) ); // TODO
	self com_printnotitle( "rank_group: " + cmd_object.rank_group );
	self com_printnotitle( "module_group: " + cmd_object.module_group );
}

com_printcmd_help( cmd_object )
{
	self com_printnotitle( "Name: " + cmd_object.cmd_name );
	self com_printnotitle( "Usage: " + cmd_object.usage );
	self com_printnotitle( "Min Args: " + cmd_object get_min_args() );
	self com_printnotitle( "Max Args: " + cmd_object get_max_args() );
	//self com_printnotitle( "Arg Types: " + repackage_args( cmd_object.arg_types ) ); // TODO
	self com_printnotitle( "Rank: " + cmd_object.rank_group );
	self com_printnotitle( "Module: " + cmd_object.module_group );
}

com_printannouncment( message, players )
{
	level com_printf_internal( "iprintbold", "notitle", message, players );
}

com_printf( channels, filter, message, players )
{
	level com_printf_internal( channels, filter, message, players );
}

com_printinfo( message )
{
	channels = self com_get_cmd_feedback_channel_internal();
	level com_printf_internal( channels, "cmdinfo", message, self );
}

com_printwarning( message )
{
	channels = self com_get_cmd_feedback_channel_internal();
	level com_printf_internal( channels, "cmdwarning", message, self );
}

com_printerror( message )
{
	channels = self com_get_cmd_feedback_channel_internal();
	level com_printf_internal( channels, "cmderror", message, self );
}

com_printnotitle( message )
{
	channels = self com_get_cmd_feedback_channel_internal();
	level com_printf_internal( channels, "notitle", message, self );
}

com_printconsoleprintlore()
{
	if ( !is_true( self.is_server ) )
	{
		self com_printnotitle( "Use 'shift' + '`' and then 'ctrl' + 'end' to see the full list" );
	}
}

com_printdebuginfo( message )
{
	if ( level._developer )
	{
		if ( isdefined( level.host ) )
		{
			level.host com_printinfo( message );
		}
		else if ( isdefined( level.server ) )
		{
			level.server com_printinfo( message );
		}
	}
}

com_printdebugwarning( message )
{
	if ( level._developer )
	{
		if ( isdefined( level.host ) )
		{
			level.host com_printwarning( message );
		}
		else if ( isdefined( level.server ) )
		{
			level.server com_printwarning( message );
		}
	}
}

com_printdebugerror( message )
{
	if ( level._developer )
	{
		if ( isdefined( level.host ) )
		{
			level.host com_printerror( message );
		}
		else if ( isdefined( level.server ) )
		{
			level.server com_printerror( message );
		}
	}
}

com_get_cmd_feedback_channel()
{
	return self com_get_cmd_feedback_channel_internal();
}

com_filter_add( filter, default_value )
{
	if ( !isDefined( level.com_filters ) )
	{
		level.com_filters = [];
	}
	if ( !isDefined( level.com_filters[ filter ] ) )
	{
		level.com_filters[ filter ] = getDvarIntDefault( "com_script_filter_" + filter, default_value );
	}
}

com_channel_add( channel, func )
{
	if ( !isDefined( level.com_channels ) )
	{
		level.com_channels = [];
	}
	if ( !isDefined( level.com_channels[ channel ] ) )
	{
		level.com_channels[ channel ] = func;
	}
}

cmd_cooldown()
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return;
	}
	if ( self has_all_perms() )
	{
		return;
	}
	self.cmd_cooldown = level.custom_cmds_cooldown_time;
	while ( self.cmd_cooldown > 0 )
	{
		self.cmd_cooldown--;
		wait 1;
	}
}

can_use_multi_cmds()
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return true;
	}
	if ( self has_all_perms() )
	{
		return true;
	}
	return false;
}

has_permission_for_cmd( cmd )
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return true;
	}
	if ( self has_all_perms() )
	{
		return true;
	}
	if ( isDefined( level.tcs_perms.ranks[ self.tcs_rank ] ) && isDefined( level.tcs_perms.ranks[ self.tcs_rank ].disallowed_cmds ) )
	{
		for ( i = 0; i < _SIZE( level.tcs_perms.ranks[ self.tcs_rank ].disallowed_cmds.size ); i++ )
		{
			disallowed_cmd = level.tcs_perms.ranks[ self.tcs_rank ].disallowed_cmds[ i ];
			if ( disallowed_cmd == "all_cmds" )
			{
				return false;
			}
			if ( cmd == disallowed_cmd )
			{
				return false;
			}
			// In this case the token must be a rank name
			else if ( isDefined( level.cmd_groups[ disallowed_cmd ] ) && isDefined( level.cmd_groups[ disallowed_cmd ][ cmd ] ) )
			{
				return false;
			}
		}
	}
	if ( isDefined( level.tcs_perms.ranks[ self.tcs_rank ] ) && isDefined( level.tcs_perms.ranks[ self.tcs_rank ].allowed_cmds ) )
	{
		for ( i = 0; i < _SIZE( level.tcs_perms.ranks[ self.tcs_rank ].allowed_cmds.size ); i++ )
		{
			allowed_cmd = level.tcs_perms.ranks[ self.tcs_rank ].allowed_cmds[ i ];
			if ( allowed_cmd == "all_cmds" )
			{
				return true;
			}
			if ( cmd == allowed_cmd )
			{
				return true;
			}
			// In this case the token must be a rank name
			else if ( isDefined( level.cmd_groups[ allowed_cmd ] ) && isDefined( level.cmd_groups[ allowed_cmd ][ cmd ] ) )
			{
				return true;
			}
		}
	}

	return false;
}

cast_contents_to_str( contents_int )
{
	result_obj = generic_obj_t_new( "contents" );

	contents_str = "";
	keys = getarraykeys( level.tcs_contents );
	for ( i = 0; i < _SIZE( keys.size ); i++ )
	{
		if ( ( contents_int & level.tcs_contents[ keys[ i ] ] ) != 0 )
		{
			if ( contents_str != "" )
			{
				contents_str += "|";
			}

			contents_str += keys[ i ];
		}
	}

	return set_cast_success( result_obj, contents_str, "contents==" + contents_str );
}

cast_str_to_contents( contents_str )
{
	result_obj = generic_obj_t_new( "contents" );

	contents_int = level.tcs_contents[ "NONE" ];
	keys = strtok( contents_str, "|" );
	for ( i = 0; i < _SIZE( keys.size ); i++ )
	{
		if ( isdefined( level.tcs_contents[ keys[ i ] ] ) )
		{
			contents_int |= level.tcs_contents[ keys[ i ] ];
		}
	}

	return set_cast_success( result_obj, contents_int, "contents==" + contents_int );
}

cast_classname_to_ent_array( result_obj, key_value )
{
	result_obj.type = "entarray";
	result_obj.value = getentarray( key_value, "classname" );
	result_obj.msg = "entarray==classname";
}

cast_script_noteworthy_to_ent_array( result_obj, key_value )
{
	result_obj.type = "entarray";
	result_obj.value = getentarray( key_value, "script_noteworthy" );
	result_obj.msg = "entarray==script_noteworthy";
}

cast_targetname_to_ent_array( result_obj, key_value )
{
	result_obj.type = "entarray";
	result_obj.value = getentarray( key_value, "targetname" );
	result_obj.msg = "entarray==targetname";
}

cast_origin_to_ent_array( result_obj, origin, maxdist, max )
{
	result_obj.type = "entarray";
	ents = getentarray();
	result_obj.value = get_array_of_closest( origin, ents, undefined, max, maxdist );
	result_obj.msg = "entarray==origin";
}

/*boolean*/ is_player_valid( player, checkignoremeflag, ignore_laststand_players )
{
	if ( !isdefined( player ) )
	{
		return false;
	}

	if ( !isalive( player ) )
	{
		return false;
	}

	if ( !isplayer( player ) )
	{
		return false;
	}

	if ( isdefined( player.is_zombie ) && player.is_zombie == 1 )
	{
		return false;
	}

	if ( player.sessionstate == "spectator" )
	{
		return false;
	}

	if ( player.sessionstate == "intermission" )
	{
		return false;
	}

	if ( isdefined( self.intermission ) && self.intermission )
	{
		return false;
	}

	if ( !( isdefined( ignore_laststand_players ) && ignore_laststand_players ) )
	{
		if ( isDefined( player.revivetrigger ) || is_true( player.lastand ) )
		{
			return false;
		}
	}

	if ( isdefined( checkignoremeflag ) && checkignoremeflag && player.ignoreme )
	{
		return false;
	}

	if ( isdefined( level.is_player_valid_override ) )
	{
		return [[ level.is_player_valid_override ]]( player );
	}

	return true;
}

/*entity_obj_t*/ cast_str_to_entity( str, etype, allow_null_ent, allow_world_ent, finder_func, finder_arg1, finder_arg2 )
{
	allow_null_ent = _DEFAULT( allow_null_ent, false );
	allow_world_ent = _DEFAULT( allow_world_ent, false );
	finder_func = _DEFAULT( finder_func, undefined );
	finder_arg1 = _DEFAULT( finder_arg1, undefined );
	finder_arg2 = _DEFAULT( finder_arg2, undefined );

	entity_obj = generic_obj_t_new( "entity" );
	entity_obj.etype = etype;
	if ( !isDefined( str ) || str == "" )
	{
		return set_cast_error( entity_obj, "Missing value to find entity" );
	}

	if ( !isdefined( etype ) || !isdefined( level._entity_type_funcs[ etype ] ) && !isdefined( level._entity_custom_getter_funcs[ etype ] ) )
	{
		return set_cast_error( entity_obj, "Unsupported etype" );
	}

	entities = [];
	if ( isdefined( level._entity_type_funcs[ etype ] ) )
	{
		entities = self [[ level._entity_type_funcs[ etype ].getter ]]();
	}
	else if ( isdefined( level._entity_custom_getter_funcs[ etype ] ) )
	{
		entities = self [[ level._entity_custom_getter_funcs[ etype ].getter ]]();
	}

	if ( entities.size <= 0 )
	{
		return set_cast_error( entity_obj, "No entities found for etype: " + etype );
	}

	cast_number_obj = cast_str_to_number( str, "positive_int" );

	if ( !cast_number_obj.errored )
	{
		entnum = cast_number_obj.value;
		if ( entnum > 1023 )
		{
			return set_cast_error( entity_obj, "Entity number cannot be greater than 1023" );
		}

		if ( entnum == 1023 )
		{
			if ( allow_null_ent )
			{
				return set_cast_success( entity_obj, undefined, "ent==allow_null_ent" );
			}
			else
			{
				return set_cast_error( entity_obj, "ent!=allow_null_ent" );
			}
		}
		else if ( entnum == 1022 )
		{
			if ( allow_world_ent )
			{
				return set_cast_success( entity_obj, getentbynum( 1022 ), "ent==allow_world_ent" );
			}
			else
			{
				return set_cast_error( entity_obj, "ent!=allow_world_ent" );
			}
		}

		for ( i = 0; i < _SIZE( entities.size ); i++ )
		{
			ent = entities[ i ];

			if ( ent getentitynumber() == entnum )
			{
				return set_cast_success( entity_obj, ent, "ent==entnum" );
			}

			if ( etype == "player" && !ent istestclient() )
			{
				if ( ent getGUID() == entnum )
				{
					return set_cast_success( entity_obj, ent, "ent==GUID" );
				}
			}
		}

		return set_cast_error( entity_obj, "Could not cast numeric value: '" + entnum + "' to etype: '" + etype + "'" );
	}

	for ( i = 0; i < _SIZE( entities.size ); i++ )
	{
		ent = entities[ i ];

		if ( !isdefined( ent ) )
		{
			continue;
		}

		if ( isdefined( finder_func ) && ent [[ finder_func ]]( str, etype, finder_arg1, finder_arg2 ) )
		{
			return set_cast_success( entity_obj, ent, "ent==finder_func" );
		}

		if ( etype == "player" )
		{
			target_playername = tolower( ent.name );
			if ( issubstr( target_playername, str ) )
			{
				return set_cast_success( entity_obj, ent, "player==name" );
			}
		}
	}

	return set_cast_error( entity_obj, "Couldn't find entity of etype: '" + etype + "' from input: " + str );
}

is_str_int( str )
{
	cast_obj = cast_str_to_number( str, "int" );
	return !cast_obj.errored;
}

is_str_natural_int( str )
{
	cast_obj = cast_str_to_number( str, "natural_int" );
	return !cast_obj.errored;
}

is_str_positive_int( str )
{
	cast_obj = cast_str_to_number( str, "positive_int" );
	return !cast_obj.errored;
}

is_str_float( str )
{
	cast_obj = cast_str_to_number( str, "float" );
	return !cast_obj.errored;
}

is_str_positive_float( str )
{
	cast_obj = cast_str_to_number( str, "positive_float" );
	return !cast_obj.errored;
}

/*str_cast_obj_t*/ str_cast_obj_t_new( type, str_value )
{
	str_cast_obj = generic_obj_t_new( "str_cast" );
	str_cast_obj.number_type = type;
	str_cast_obj.str_value = str_value;

	if ( !isdefined( type ) || !isdefined( level._number_strings[ type ] ) )
	{
		assert( false );
		return set_cast_error( str_cast_obj, "Unknown type: " + type );
	}
	if ( !isdefined( str_value ) || str_value == "" )
	{
		assert( false );
		return set_cast_error( str_cast_obj, "Unknown str_value" );
	}
	return str_cast_obj;
}

cast_str_to_number( str, type )
{
	str_cast_obj = str_cast_obj_t_new( type, str );

	if ( str_cast_obj.errored )
	{
		return str_cast_obj;
	}

	if ( str[ 0 ] == "-" )
	{
		if ( type != "float" && type != "int" )
		{
			return set_cast_error( str_cast_obj, "Unexpected negative sign" );
		}
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}

	syntax = level._number_strings[ type ];

	period_allowed = false;
	if ( type == "float" || type == "positive_float" )
	{
		period_allowed = true;
	}
	
	periods_found = 0;
	if ( str[ str.size - 1 ] == "." )
	{
		return set_cast_error( str_cast_obj, "Trailing decimal point is not allowed" );
	}
	for ( i = start_index; i < _SIZE( str.size ); i++ )
	{
		if ( period_allowed && str[ i ] == "." )
		{
			periods_found++;
			if ( periods_found > 1 )
			{
				return set_cast_error( str_cast_obj, "Cannot have more than one decimal point" );
			}
			continue;
		}
		if ( str[ i ] == "-" )
		{
			return set_cast_error( str_cast_obj, "Succeeding or multiple negative signs are not allowed" );
		}
		if ( !is_numeric( str[ i ] ) )
		{
			return set_cast_error( str_cast_obj, "Invalid character for type '" + type + "': '" + str[ i ] + "'" );
		}
	}

	value = 0;
	switch ( type )
	{
		case "natural_int":
		case "positive_int":
		case "int":
			value = int( str );
			break;
		case "positive_float":
		case "float":
			value = float( str );
			break;
	}

	return set_cast_success( str_cast_obj, value, type + "==" + str );
}

cast_str_to_vector( str )
{
	result_obj = generic_obj_t_new( "vector" );
	float_strs = strTok( str, "," );
	if ( float_strs.size != 3 )
	{
		return set_cast_error( result_obj, "expected vector in format of x,x,x" );
	}

	casted_floats = [];
	for ( i = 0; i < _SIZE( float_strs.size ); i++ )
	{
		casted_floats[ i ] = cast_str_to_number( float_strs[ i ], "float" );
		if ( casted_floats[ i ].errored )
		{
			return set_cast_error( result_obj, "Error at vector component '" + i + "': " + casted_floats[ i ].msg );
		}
	}

	new_vector = ( casted_floats[ 0 ].value, casted_floats[ 1 ].value, casted_floats[ 2 ].value );
	return set_cast_success( result_obj, new_vector, "vector==" + new_vector );
}

cast_bool_to_str( bool, binary_string_options )
{
	options = strTok( binary_string_options, " " );
	if ( options.size == 2 )
	{
		if ( bool )
		{
			return options[ 0 ];
		}
		else 
		{
			return options[ 1 ];
		}
	}
	return bool + "";
}

cast_str_to_bool( str )
{
	lower_str = tolower( str );
	result_obj = generic_obj_t_new( "boolean" );
	if ( lower_str == "true" || lower_str == "1" )
	{
		return set_cast_success( result_obj, true, lower_str == "true" ? "boolean==true" : "boolean==1" );
	}
	else if ( lower_str == "false" || lower_str == "0" )
	{
		return set_cast_success( result_obj, false, lower_str == "false" ? "boolean==false" : "boolean==0" );
	}

	return set_cast_error( result_obj, "boolean!=boolean" );
}

cast_str_to_cmd( alias )
{
	result_obj = generic_obj_t_new( "cmdobj" );
	if ( alias == "" )
	{
		return set_cast_error( result_obj, "No alias provided" );
	}

	if ( !isdefined( level.tcs_cmds[ alias ] ) )
	{
		return set_cast_error( result_obj, "Unknown cmd: '" + alias + "'" );
	}

	return set_cast_success( result_obj, level.tcs_cmds[ alias ], "cmd==" + alias );
}

is_alpha( chr, start, end )
{
	start = _DEFAULT( start, 0 );
	end = _DEFAULT( end, chr.size );
	if ( end > chr.size )
	{
		end = chr.size;
	}
	for ( i = start; i < _SIZE( end ); i++ )
	{
		if ( !isdefined( level._alphabet_array[ chr[ i ] ] ) )
		{
			return false;
		}
	}

	return true;
}

is_alpha_numeric( chr, check_underscore, start, end )
{
	check_underscore = _DEFAULT( check_underscore, false );
	start = _DEFAULT( start, 0 );
	end = _DEFAULT( end, chr.size );
	if ( end > chr.size )
	{
		end = chr.size;
	}
	for ( i = start; i < _SIZE( end ); i++ )
	{
		if ( !isdefined( level._alphabet_array[ tolower( chr[ i ] ) ] ) && !isdefined( level._numeric_array[ chr[ i ] ] ) )
		{
			if ( !check_underscore )
			{
				return false;
			}
			else if ( chr[ i ] != "_" )
			{
				return false;
			}
		}
	}

	return true;
}

is_numeric( chr, start, end )
{
	start = _DEFAULT( start, 0 );
	end = _DEFAULT( end, chr.size );
	if ( end > chr.size )
	{
		end = chr.size;
	}
	for ( i = start; i < end; i++ )
	{
		if ( !isdefined( level._numeric_array[ chr[ i ] ] ) )
		{
			return false;
		}
	}

	return true;
}

// very nice builtin which allows get entities in an arbitrary abstract volume
// GetTouchingVolume( vec, vec, vec );

get_targets_by_func()
{

}

/*generic_obj_t*/ generic_obj_t_new( obj_type )
{
	generic_obj = spawnstruct();
	generic_obj.warning = false;
	generic_obj.errored = false;
	generic_obj.msg = "";
	generic_obj.obj_type = obj_type;

	return generic_obj;
}

/*result_t*/ result_new( msg, filter, channels )
{
	result = generic_obj_t_new( "result" );
	result.msg = msg;
	result.filter = filter;
	result.channels = _DEFAULT( channels, undefined );

	return result;
}

// self == param
add_player_msg( player, msg, filter, channels )
{
	channels = _DEFAULT( channels, player com_get_cmd_feedback_channel() );

	if ( !isdefined( self.result_array ) )
	{
		self.result_array = [];
	}

	new_entry = result_new( msg, filter, channels );
	new_entry.player = player;

	self.result_array[ self.result_array.size ] = new_entry;
}

add_executor_cmdinfo( msg, channels )
{
	channels = _DEFAULT( channels, undefined );
	self add_player_msg( self.executor, msg, "cmdinfo", channels );
}

add_executor_cmdwarning( msg, channels )
{
	channels = _DEFAULT( channels, undefined );
	self add_player_msg( self.executor, msg, "cmdwarning", channels );
}

add_executor_cmderror( msg, channels )
{
	channels = _DEFAULT( channels, undefined );
	self add_player_msg( self.executor, msg, "cmderror", channels );
}

add_player_cmdinfo( player, msg, channels )
{
	channels = _DEFAULT( channels, undefined );
	self add_player_msg( player, msg, "cmdinfo", channels );
}

add_player_cmdwarning( player, msg, channels )
{
	channels = _DEFAULT( channels, undefined );
	self add_player_msg( player, msg, "cmdwarning", channels );
}

add_player_cmderror( player, msg, channels )
{
	channels = _DEFAULT( channels, undefined );
	self add_player_msg( player, msg, "cmderror", channels );
}

/*result_obj_t*/ set_cast_error( result_obj, error_msg, expected_value_type )
{
	result_obj.errored = true;
	result_obj.value = undefined;
	result_obj.type = _DEFAULT( expected_value_type, undefined );
	result_obj.msg = error_msg;

	return result_obj;
}

/*result_obj_t*/ set_cast_success( result_obj, new_value, success_msg, expected_value_type )
{
	result_obj.value = new_value;
	result_obj.msg = success_msg;
	result_obj.type = _DEFAULT( expected_value_type, undefined );

	return result_obj;
}

repackage_args( args )
{
	args_string = "";
	if ( !isdefined( args ) )
	{
		return args_string;
	}
	for ( i = 0; i < _SIZE( args.size ); i++ )
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

cmd_add( cmd_name, cmdfunc, cmd_usage, description )
{
	cmd_usage = _DEFAULT( cmd_usage, cmd_name );
	description = _DEFAULT( description, "No description defined" );
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
	new_cmd.func = cmdfunc;
	new_cmd.is_cmd_object = true;
	new_cmd.requires_player_executor = false;
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

	return new_cmd;
}

cmd_block_set_rank_group( rank_group )
{
	level.tcs_cmd_register_rank_group = rank_group;
}

cmd_block_set_module_group( module_group )
{
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
	for ( i = 1; i < _SIZE( self.arg_types.size ); i++ )
	{
		if ( isdefined( self.arg_types[ i + "" ] ) && self.arg_types[ i + "" ].is_required )
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

// ordinal would allow argument overloading
private arg_add( ordinal, name, arg_type, is_required, desc )
{
	desc = _DEFAULT( desc, "No description" );
	ordinal = ordinal + ""; // best to be a string

	if ( !is_true( self.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	if ( !isdefined( self.arg_types[ ordinal ] ) )
	{
		new_arg = spawnstruct();
		new_arg.name = name;
		new_arg.is_required = is_required;
		new_arg.ordinal = ordinal;
		new_arg.desc = desc;
		new_arg.overloads = [];
		new_arg.overloads[ arg_type ] = true;

		self.arg_types[ ordinal ] = new_arg;
	}
	else if ( !isdefined( self.arg_types[ ordinal ].overloads[ arg_type ] ) )
	{
		self.arg_types[ ordinal ].overloads[ arg_type ] = true;
	}
	else
	{
		assert( false );
		com_printdebugerror( "Cannot overload argument ordinal: '" + ordinal + "' for command: '" + self.cmd_name + "' with type: '" + arg_type + "' as it is already overloaded with that type" );
	}

	if ( !isdefined( level.tcs_arg_type_handlers[ arg_type ] ) )
	{
		assert( false );
		com_printdebugerror( "Unknown arg type: '" + arg_type + "' being registered for cmd: '" + self.cmd_name + "' at ordinal '" + ordinal + "'" );
	}
}

arg_add_required( ordinal, name, arg_type, desc )
{
	self arg_add( ordinal, name, arg_type, true, desc );
}

arg_add_optional( ordinal, name, arg_type, desc )
{
	self arg_add( ordinal, name, arg_type, false, desc );
}

private target_add( ordinal, name, target_type, is_required, desc, max_targets )
{
	max_targets = _DEFAULT( max_targets, 1024 );
	desc = _DEFAULT( desc, "No description" );
	ordinal = ordinal + ""; // best to be a string

	if ( !is_true( self.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	if ( !isdefined( self.target_types[ ordinal ] ) )
	{
		new_target = spawnstruct();
		new_target.name = name;
		new_target.is_required = is_required;
		new_target.ordinal = ordinal;
		new_target.desc = desc;
		new_target.overloads = [];

		new_overload = spawnstruct();
		new_overload.etype = target_type;
		new_overload.max_targets = max_targets;
		new_target.overloads[ target_type ] = new_overload;

		self.target_types[ ordinal ] = new_target;
	}
	else if ( !isdefined( self.target_types[ ordinal ].overloads[ target_type ] ) )
	{
		new_overload = spawnstruct();
		new_overload.etype = target_type;
		new_overload.max_targets = max_targets;
		self.target_types[ ordinal ].overloads[ target_type ] = new_overload;
	}
	else
	{
		assert( false );
		com_printdebugerror( "Cannot overload target ordinal: '" + ordinal + "' for command: '" + self.cmd_name + "' with type: '" + target_type + "' as it is already overloaded with that type" );
		return;
	}

	self.has_required_target = self.has_required_target || is_required;

	if ( !isdefined( level._entity_type_funcs[ target_type ] ) )
	{
		assert( false );
		com_printdebugerror( "Unknown entity type: '" + target_type + "' registered for command: '" + self.cmd_name + "'" );
	}
}

target_add_required( ordinal, name, target_type, desc, max_targets )
{
	self target_add( ordinal, name, target_type, true, desc, max_targets );
}

target_add_optional( ordinal, name, target_type, desc, max_targets )
{
	self target_add( ordinal, name, target_type, false, desc, max_targets );
}

get_target_from_ordinal( cmd_data_source, ordinal )
{
	return cmd_data_source.target_types[ ordinal + "" ];
}

arg_type_register( argtype, rand_gen_func, cast_func )
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
	level.tcs_arg_type_handlers[ argtype ].rand_gen_func = rand_gen_func;
	level.tcs_arg_type_handlers[ argtype ].cast_func = cast_func;
}

has_permission_for_executor_syntax()
{
	return self ishost();
}

executor_obj_add_cmd( doc )
{
	if ( !is_true( self.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	self.requires_player_executor = true;
}

make_cmd_immune_to_unittest()
{
	if ( !is_true( self.is_cmd_object ) || is_true( self.immune_to_unittest ) )
	{
		assert( false );
		return;
	}

	self.immune_to_unittest = true;
}

//If we have a lot of clientdvars in the pool delay setting them to prevent client cmd overflow error.
set_client_dvar_thread( dvar, value, index )
{
	wait( index * 0.25 );
	self setClientDvar( dvar, value );
}

get_dvar_string_default( dvarname, default_value )
{
	cur_dvar_value = getdvar( dvarname );
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

get_dvar_int_default( dvarname, default_value )
{
	cur_dvar_value = getdvar( dvarname );
	if ( isDefined( cur_dvar_value ) && cur_dvar_value != "" )
	{
		return getdvarint( dvarname );
	}
	else 
	{
		setDvar( dvarname, default_value );
		return default_value;
	}
}

get_dvar_float_default( dvarname, default_value )
{
	cur_dvar_value = getdvar( dvarname );
	if ( isDefined( cur_dvar_value ) && cur_dvar_value != "" )
	{
		return getdvarfloat( dvarname );
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

notify_callback_thread( notify_name, func, ent )
{
	ent = _DEFAULT( ent, level );

	ent notify( notify_name + "_death" );
	ent endon( notify_name + "_death" );

	for ( ;; )
	{
		ent waittill( notify_name, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 );
		ent thread [[ func ]]( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 );
	}
}

add_notify_callback( notify_name, func, ent )
{
	ent = _DEFAULT( ent, level );

	if ( !isdefined( ent._notify_callbacks ) || !isdefined( ent._notify_callbacks[ notify_name ] ) )
	{
		ent._notify_callbacks[ notify_name ] = [];
	}

	level thread notify_callback_thread( notify_name, func, ent );
}

remove_notify_callback( notify_name, ent )
{
	ent = _DEFAULT( ent, level );

	if ( !isdefined( ent._notify_callbacks ) || !isdefined( ent._notify_callbacks[ notify_name ] ) )
	{
		return;
	}

	ent notify( notify_name + "_death" );
	ent._notify_callbacks[ notify_name ] = undefined;
}

/*noreturn*/ throw_exception( error_msg, generic_obj, print )
{
	generic_obj = _DEFAULT( generic_obj, generic_obj_t_new( "cmd_exception" ) );
	print = _DEFAULT( print, true );
	generic_obj.errored = true;
	generic_obj.msg = error_msg;
	generic_obj.do_print = print;

	if ( !self script_breakpoint( generic_obj, error_msg ) )
	{
		if ( level._developer )
		{
			assert( false );
			generic_obj print_obj();
		}
		self notify( "cmd_exception", generic_obj );
	}
	return;
}

has_all_perms()
{
	return is_true( self.is_server ) || is_true( self.is_host );
}

get_possible_array_values_msg( arg, array, type, key_indexed )
{
	key_indexed = _DEFAULT( key_indexed, true );
	type_upper = toupper( type );
	list = "";
	foreach ( key, val in array )
	{
		if ( key_indexed )
		{
			list += type_upper + ": '" + key + "'\n";
		}
		else
		{
			list += type_upper + ": '" + val + "'\n";
		}
	}

	msg = "Invalid " + type + ": '" + arg + "', valid " + type + "s are: \n" + msg;

	return msg;
}

// inlineable...
random_key( arr )
{
	keys = getarraykeys( arr );
	assert( isstring( keys[ 0 ] ) );
	return keys[ randomint( keys.size ) ];
}

random_index( arr )
{
	keys = getarraykeys( arr );
	assert( isint( keys[ 0 ] ) );
	return keys[ randomint( keys.size ) ];
}

random_val( arr )
{
	keys = getarraykeys( arr );
	return arr[ keys[ randomint( keys.size ) ] ];
}

_CLAMP( val, val_min, val_max )
{
	if ( val < val_min )
	{
		val = val_min;
	}
	else if ( val > val_max )
	{
		val = val_max;
	}

	return val;
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

_DEFAULT( value, default_value )
{
	if ( !isdefined( value ) )
	{
		return default_value;
	}

	return value;
}

_OPTIONAL( value )
{
	if ( isdefined( value ) )
	{
		return value;
	}

	return undefined;
}

// this function isn't intended to handle script errors, it just stops infinite loops from happening due to the arr being undefined so they can be caught immediately
// can't use like a method unfortunately as self may not be defined
_SIZE( arr_size )
{
	if ( !isdefined( arr_size ) )
	{
		// exits the loop as undefined is used in a truthy way
		return 0;
	}

	return arr_size;
}

array_validate( array )
{
	return isdefined( array ) && isarray( array ) && array.size > 0;
}

server_safe_notify_thread( notify_name, index )
{
	waittillframeend;
	level notify( notify_name );
}