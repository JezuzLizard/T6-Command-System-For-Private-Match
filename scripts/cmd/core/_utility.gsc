#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_com;

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

script_breakpoint( generic_obj, msg = "", display_callstack = true, should_print = true )
{
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
		if ( msg != "" )
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
		for ( i = 0; i < self.args.size; i++ )
		{
			ordinal = ( i + 1 );
			com_printdebugwarning( "arg" + ordinal + ": " + self.args[ i ] );
		}

		keys = getarraykeys( self.directive_kvps );
		for ( i = 0; i < keys.size; i++ )
		{
			for ( j = 0; j < self.directive_kvps[ keys[ i ] ].size; j++ )
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
	self com_printnotitle( "power: " + cmd_object.power );
	self com_printnotitle( "min_args: " + cmd_object.min_args );
	self com_printnotitle( "max_args: " + cmd_object.max_args );
	self com_printnotitle( "arg_types: " + repackage_args( cmd_object.arg_types ) );
	self com_printnotitle( "rank_group: " + cmd_object.rank_group );
	self com_printnotitle( "module_group: " + cmd_object.module_group );
}

com_printcmd_help( cmd_object )
{
	self com_printnotitle( "Name: " + cmd_object.cmd_name );
	self com_printnotitle( "Usage: " + cmd_object.usage );
	self com_printnotitle( "Min Args: " + cmd_object.min_args );
	self com_printnotitle( "Max Args: " + cmd_object.max_args );
	self com_printnotitle( "Arg Types: " + repackage_args( cmd_object.arg_types ) );
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
		for ( i = 0; i < level.tcs_perms.ranks[ self.tcs_rank ].disallowed_cmds.size; i++ )
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
		for ( i = 0; i < level.tcs_perms.ranks[ self.tcs_rank ].allowed_cmds.size; i++ )
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

cast_contents_to_str( contents_int, noprint = false )
{
	result_obj = result_obj_new( "contents", "string", noprint );

	contents_str = "";
	keys = getarraykeys( level.tcs_contents );
	for ( i = 0; i < keys.size; i++ )
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

cast_str_to_contents( contents_str, noprint = false )
{
	result_obj = result_obj_new( "contents", "int", noprint );

	contents_int = level.tcs_contents[ "NONE" ];
	keys = strtok( contents_str, "|" );
	for ( i = 0; i < keys.size; i++ )
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

/*entity_obj_t*/ entity_obj_t_new( etype, entnum = 1023 )
{
	entity_obj = generic_obj_t_new( "entity" );
	entity_obj.etype = etype;
	entity_obj.entnum = entnum;
	entity_obj.ent = undefined;

	return entity_obj;
}

set_ent_cast_success( entity_obj, ent, msg )
{
	entity_obj.ent = entity_obj;
	entity_obj.entnum = ent getentitynumber();
	return set_cast_success( entity_obj, undefined, msg );
}

set_ent_cast_error( entity_obj, msg )
{
	return set_cast_error( entity_obj, msg );
}

/*entity_obj_t*/ cast_str_to_entity( str, etype, allow_null_ent = false, allow_world_ent = false, finder_func = undefined, finder_arg1 = undefined, finder_arg2 = undefined )
{
	entity_obj = entity_obj_t_new( etype );
	if ( !isDefined( str ) || str == "" )
	{
		return set_ent_cast_error( entity_obj, "Missing value to find entity" );
	}

	if ( !isdefined( etype ) || !isdefined( level._entity_type_funcs[ etype ] ) && !isdefined( level._entity_custom_getter_funcs[ etype ] ) )
	{
		return set_ent_cast_error( entity_obj, "Unsupported etype" );
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
		return set_ent_cast_error( entity_obj, "No entities found for etype: " + etype );
	}

	cast_number_obj = cast_str_to_number( str, "positive_int" );

	if ( !cast_number_obj.errored )
	{
		entnum = cast_number_obj.casted_value;
		if ( entnum > 1023 )
		{
			return set_ent_cast_error( entity_obj, "Entity number cannot be greater than 1023" );
		}

		if ( entnum == 1023 )
		{
			if ( allow_null_ent )
			{
				return set_ent_cast_success( entity_obj, undefined, "ent==allow_null_ent" );
			}
			else
			{
				return set_ent_cast_error( entity_obj, "ent!=allow_null_ent" );
			}
		}
		else if ( entnum == 1022 )
		{
			if ( allow_world_ent )
			{
				return set_ent_cast_success( entity_obj, getentbynum( 1022 ), "ent==allow_world_ent" );
			}
			else
			{
				return set_ent_cast_error( entity_obj, "ent!=allow_world_ent" );
			}
		}

		for ( i = 0; i < entities.size; i++ )
		{
			ent = entities[ i ];

			if ( ent getentitynumber() == entnum )
			{
				return set_ent_cast_success( entity_obj, ent, "ent==entnum" );
			}

			if ( etype == "player" && !ent istestclient() )
			{
				if ( ent getGUID() == entnum )
				{
					return set_ent_cast_success( entity_obj, ent, "ent==GUID" );
				}
			}
		}

		return set_ent_cast_error( entity_obj, "Could not cast numeric value: '" + entnum + "' to etype: '" + etype + "'" );
	}

	for ( i = 0; i < entities.size; i++ )
	{
		ent = entities[ i ];

		if ( !isdefined( ent ) )
		{
			continue;
		}

		if ( isdefined( finder_func ) && ent [[ finder_func ]]( str, etype, finder_arg1, finder_arg2 ) )
		{
			return set_ent_cast_success( entity_obj, ent, "ent==finder_func" );
		}

		if ( etype == "player" )
		{
			target_playername = tolower( ent.name );
			if ( issubstr( target_playername, str ) )
			{
				return set_ent_cast_success( entity_obj, ent, "player==name" );
			}
		}
	}

	return set_ent_cast_error( entity_obj, "Couldn't find entity of etype: '" + etype + "' from input: " + str );
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

/*str_cast_obj_t*/ str_cast_obj_t_new( type = "undefined", str_value = "" )
{
	str_cast_obj = generic_obj_t_new( "str_cast" );
	str_cast_obj.number_type = type;
	str_cast_obj.casted_value = undefined;
	str_cast_obj.str_value = str_value;

	if ( !isdefined( level._number_strings[ type ] ) )
	{
		assert( false );
		return set_cast_error( str_cast_obj, "Unknown type: " + type );
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
	for ( i = start_index; i < str.size; i++ )
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
	result_obj = result_obj_new( "vector", "vector" );
	float_strs = strTok( str, "," );
	if ( float_strs.size != 3 )
	{
		return set_cast_error( result_obj, "expected vector in format of x,x,x" );
	}

	casted_floats = [];
	for ( i = 0; i < float_strs.size; i++ )
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
	result_obj = result_obj_new( "boolean", "boolean" );
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
	result_obj = result_obj_new( "cmdobject", "struct" );
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

is_alpha( chr )
{
	for ( i = 0; i < chr.size; i++ )
	{
		if ( !isdefined( level._alphabet_array[ chr[ i ] ] ) )
		{
			return false;
		}
	}

	return true;
}

is_alpha_numeric( chr, check_underscore = false )
{
	for ( i = 0; i < chr.size; i++ )
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

is_numeric( chr )
{
	for ( i = 0; i < chr.size; i++ )
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
	waittillframeend;
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
	result.executor_msg_array = [];
	result.player_msg_array = [];
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

add_result_executor_msg( result, additional_executor_msg )
{
	result.executor_msg_array[ result.executor_msg_array.size ] = additional_executor_msg;
}

add_result_player_msg( result, player, additional_player_msg )
{
	result.player_msg_array[ result.player_msg_array.size ] = spawnstruct();
	result.player_msg_array[ result.player_msg_array.size - 1 ].player = player;
	result.player_msg_array[ result.player_msg_array.size - 1 ].msg = additional_player_msg;
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

	module_group = level.tcs_cmd_register_module_group;
	if ( !isdefined( module_group ) )
	{
		level com_printf( "con|g_log", "cmderror", "Failed to register cmd " + cmd_name + ", attempted to use an unregistered module_group!" );
		return;
	}

	level.tcs_cmds[ cmd_name ] = spawnstruct();
	level.tcs_cmds[ cmd_name ].cmd_name = cmd_name;
	level.tcs_cmds[ cmd_name ].usage = cmd_usage;
	level.tcs_cmds[ cmd_name ].func = cmdfunc;
	level.tcs_cmds[ cmd_name ].is_cmd_object = true;
	level.tcs_cmds[ cmd_name ].requires_player_executor = false;
	level.tcs_cmds[ cmd_name ].min_args = 0;
	level.tcs_cmds[ cmd_name ].max_args = 0;
	level.tcs_cmds[ cmd_name ].arg_types = [];
	level.tcs_cmds[ cmd_name ].target_types = [];
	level.tcs_cmds[ cmd_name ].rank_group = rank_group;
	level.tcs_cmds[ cmd_name ].module_group = module_group;
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

cmd_block_set_module_group( module_group )
{
	level.tcs_cmd_register_module_group = module_group;
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

	for ( i = 0; i < self.arg_types.size; i++ )
	{
		arg_type = self.arg_types[ i ];
		if ( !isdefined( level.tcs_arg_type_handlers[ arg_type ] ) )
		{
			assert( false );
			com_printdebugerror( "Unknown arg type: '" + arg_type + "' being registered for cmd: '" + self.cmd_name + "' at index '" + i + "'" );
		}
	}
}

target_type_add_cmd( target_type_name, is_required_target, doc_string, max_targets = 1024 )
{
	if ( !is_true( self.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	if ( !isdefined( target_type_name ) || target_type_name == "" )
	{
		return;
	}

	target_type = spawnstruct();
	target_type.etype = target_type_name;
	target_type.is_required = is_required_target;
	target_type.max_targets = max_targets;
	target_type.doc_string = doc_string;
	self.target_types[ self.target_types.size ] = target_type;

	if ( !isdefined( level._entity_type_funcs[ target_type_name ] ) )
	{
		assert( false );
		com_printdebugerror( "Unknown entity type: '" + target_type_name + "' registered for command: '" + self.cmd_name + "'" );
	}
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

/*noreturn*/ throw_exception( error_msg, generic_obj = undefined, print = true )
{
	generic_obj = _DEFAULT( generic_obj, generic_obj_t_new( "cmd_exception" ) );
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

get_possible_array_values_msg( arg, array, type, key_indexed = true )
{
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