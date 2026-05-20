#include common_scripts\utility;
#include maps\mp\_utility;

// forwarded imports
#include scripts\cmd\core\_api_cast;
#include scripts\cmd\core\_api_str;
#include scripts\cmd\core\_utility_debug;
#include scripts\cmd\core\_utility_str;

#include scripts\cmd\core\_com;
#include scripts\cmd\core\_cmd_parse2;
#include scripts\cmd\core\_cmd_execute;

_ASSERT_MSG_ONLY( fmt, a, b, c, d, e, f, g, h, i, j, k )
{
	return _GET_SERVER_ENTITY() _MY_ASSERT_HANDLER( false, fmt, a, b, c, d, e, f, g, h, i, j, k );
}

_ASSERT_MSG( condition, fmt, a, b, c, d, e, f, g, h, i, j, k )
{
	return _GET_SERVER_ENTITY() _MY_ASSERT_HANDLER( condition, fmt, a, b, c, d, e, f, g, h, i, j, k );
}

com_printdebuginfo( format, a, b, c, d, e, f, g, h, i, j, k )
{
	com_printdebuginfo_internal( format, a, b, c, d, e, f, g, h, i, j, k );
}

com_printdebugwarning( format, a, b, c, d, e, f, g, h, i, j, k )
{
	com_printdebugwarning_internal( format, a, b, c, d, e, f, g, h, i, j, k );
}

com_printdebugerror( format, a, b, c, d, e, f, g, h, i, j, k )
{
	com_printdebugerror_internal( format, a, b, c, d, e, f, g, h, i, j, k );
}

com_printannouncment( message, players )
{
	level com_printf_internal( "iprintbold", "notitle", message, players );
}

com_printf( channels, filter, message, players )
{
	level com_printf_internal( channels, filter, message, players );
}

com_printinfo( format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	channels = self com_get_cmd_feedback_channel_internal();
	level com_printf_internal( channels, "cmdinfo", message, self );
}

com_printwarning( format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	channels = self com_get_cmd_feedback_channel_internal();
	level com_printf_internal( channels, "cmdwarning", message, self );
}

com_printerror( format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	channels = self com_get_cmd_feedback_channel_internal();
	level com_printf_internal( channels, "cmderror", message, self );
}

com_printnotitle( format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
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

com_channel_exists( channel )
{
	return _ARRAY_VALIDATE( level.com_channels ) && isdefined( level.com_channels[ channel ] );
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

	return false;
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

/*entity_obj_t*/ cast_str_to_entity( str, etype )
{
	return cast_str_to_entity_internal( str, etype );
}

is_str_int( str )
{
	cast_obj = cast_str_to_type_internal( str, "int" );
	return !cast_obj.errored;
}

is_str_natural_int( str )
{
	cast_obj = cast_str_to_type_internal( str, "natural_int" );
	return !cast_obj.errored;
}

is_str_positive_int( str )
{
	cast_obj = cast_str_to_type_internal( str, "positive_int" );
	return !cast_obj.errored;
}

is_str_float( str )
{
	cast_obj = cast_str_to_type_internal( str, "float" );
	return !cast_obj.errored;
}

is_str_positive_float( str )
{
	cast_obj = cast_str_to_type_internal( str, "positive_float" );
	return !cast_obj.errored;
}

cast_str_to_int( str )
{
	return cast_str_to_type_internal( str, "int" );
}

cast_str_to_natural_int( str )
{
	return cast_str_to_type_internal( str, "natural_int" );
}

cast_str_to_positive_int( str )
{
	return cast_str_to_type_internal( str, "positive_int" );
}

cast_str_to_float( str )
{
	return cast_str_to_type_internal( str, "float" );
}

cast_str_to_positive_float( str )
{
	return cast_str_to_type_internal( str, "positive_float" );
}

cast_str_to_number( str, type )
{
	return cast_str_to_type_internal( str, type );
}

cast_str_to_vector( str )
{
	return cast_str_to_type_internal( str, "vector" );
}

cast_boolean_to_str( bool, binary_string_options )
{
	return cast_boolean_to_str_internal( bool, binary_string_options );
}

cast_str_to_boolean( str )
{
	return cast_str_to_type_internal( str, "boolean" );
}

cast_str_to_cmd( alias )
{
	return cast_str_to_type_internal( alias, "cmdalias" );
}

cast_str_to_primitive_type( str, type )
{
	return cast_str_to_primitive_type_internal( str, type );
}

cast_contents_to_str( contents_int )
{
	return cast_contents_to_str_internal( contents_int );
}

cast_str_to_contents( str )
{
	return cast_str_to_type_internal( str, "contents" );
}

cast_str_to_type( str, type )
{
	return cast_str_to_type_internal( str, type );
}

is_alpha( chr, start, end )
{
	_REQUIRED( chr, "is_alpha:chr is a required argument" );
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
	_REQUIRED( chr, "is_alpha_numeric:chr is a required argument" );
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
	_REQUIRED( chr, "is_numeric:chr is a required argument" );
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

// max_history = 16
add_cmd_history( cmd_string )
{
	if ( !isdefined( self.cmd_history ) )
	{
		self.cmd_history = [];
	}

	cmd_history_limit = get_dvar_int_default( "max_cmd_history", 16 );
	if ( self.cmd_history.size >= cmd_history_limit )
	{
		arrayremoveindex( self.cmd_history, 0 );
	}

	self.cmd_history[ self.cmd_history.size ] = cmd_string;
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

add_executor_cmdinfo( format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	self add_player_msg( self.executor, message, "cmdinfo", undefined );
}

add_executor_cmdwarning( format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	self add_player_msg( self.executor, message, "cmdwarning", undefined );
}

add_executor_cmderror( format, a, b, c, d, e, f, g, h, i, j, k )
{
	self.error_count++;
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	self add_player_msg( self.executor, message, "cmderror", undefined );
}

add_player_cmdinfo( player, format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	self add_player_msg( player, message, "cmdinfo", undefined );
}

add_player_cmdwarning( player, format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	self add_player_msg( player, message, "cmdwarning", undefined );
}

add_player_cmderror( player, format, a, b, c, d, e, f, g, h, i, j, k )
{
	self.error_count++;
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	self add_player_msg( player, message, "cmderror", undefined );
}

/*result_obj_t*/ set_cast_error( result_obj, format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	result_obj.errored = true;
	result_obj.value = undefined;
	result_obj.msg = message;

	return result_obj;
}

/*result_obj_t*/ set_cast_success( result_obj, new_value, format, a, b, c, d, e, f, g, h, i, j, k )
{
	message = format( format, a, b, c, d, e, f, g, h, i, j, k );
	result_obj.value = new_value;
	result_obj.msg = message;

	return result_obj;
}

repackage_args( args, delimiter )
{
	delimiter = _DEFAULT( delimiter, " " );
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
		args_string = args_string + args[ i ] + delimiter;
	}
	return args_string;
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

private _init_exceptions( entity )
{
	if ( !isdefined( level._exception_entities ) )
	{
		level._exception_entities = [];
	}

	if ( !isdefined( entity._exception_handlers ) )
	{
		entity._exception_handlers = [];
	}
}

add_exception( entity, exception_handler )
{
	_init_exceptions( entity );

	level._exception_entities[ level._exception_entities.size ] = entity;

	if ( isdefined( entity._exception_handlers[ exception_handler ] ) )
	{
		assert( false );
		return;
	}

	entity._exception_handlers[ exception_handler ] = true;
}

remove_exceptions( destruct, destruct_handler )
{
	self waittill( destruct );

	for ( entry = 0; entry < _SIZE( level._exception_entities.size ); entry++ )
	{
		entity_check = level._exception_entities[ entry ];
		if ( isdefined( entity_check ) && entity_check == self )
		{
			while ( entry < _SIZE( level._exception_entities.size ) - 1 )
			{
				level._exception_entities[entry] = level._exception_entities[entry + 1];
				entry++;
			}

			level._exception_entities[entry] = undefined;
			break;
		}
	}
	if ( isdefined( destruct_handler ) )
	{
		self [[ destruct_handler ]]();
	}
}

entity_handles_exception( entity, exception_handler )
{
	_init_exceptions( entity );
	for ( entry = 0; entry < _SIZE( level._exception_entities.size ); entry++ )
	{
		entity_check = level._exception_entities[ entry ];

		if ( isdefined( entity_check ) && entity_check == entity )
		{
			keys = getarraykeys( entity._exception_handlers );
			for ( handler = 0; handler < _SIZE( keys.size ); handler++ )
			{
				key = keys[ handler ];
				if ( exception_handler == key )
				{
					return true;
				}
			}

			return false;
		}
	}

	return false;
}

catch_exception( exception_handler, destructor )
{
	_REQUIRED( exception_handler, "catch_exception:exception_handler is a required argument" );
	destructor = _DEFAULT( destructor, undefined );
	if ( entity_handles_exception( self, exception_handler ) )
	{
		return;
	}

	add_exception( self, exception_handler );

	if ( isdefined( destructor ) )
	{
		self endon( destructor );
	}
	
	for ( ;; )
	{
		self waittill( exception_handler, exception_obj );
		self.in_command_frame = false;
		if ( !exception_obj.do_print )
		{
			continue;
		}
		self com_printerror( exception_obj.msg );
	}
}

catch_uncaught_exceptions()
{
	exception_handler = "uncaught_exception";
	if ( entity_handles_exception( self, exception_handler ) )
	{
		return;
	}

	add_exception( self, exception_handler );

	for ( ;; )
	{
		self waittill( exception_handler, exception_obj );
		self com_printdebugerror( "UNCAUGHT EXCEPTION!!!" );
		self com_printdebugerror( exception_obj.msg );
	}
}

/*noreturn*/ throw_exception( handler, generic_obj, format, a, b, c, d, e, f, g, h, i, j, k )
{
	error_msg = format( format, a, b, c, d, e, f, g, h, i, j, k );
	generic_obj = _DEFAULT( generic_obj, generic_obj_t_new( handler ) );
	generic_obj.errored = true;
	generic_obj.msg = error_msg;
	generic_obj.do_print = true;
	generic_obj.callstack = _DEFAULT( generic_obj.callstack, getdvarint( "tcs_developer" ) );
	generic_obj.debugbox = _DEFAULT( generic_obj.debugbox, getdvarint( "tcs_developer" ) );

	if ( is_true( generic_obj.callstack ) )
	{
		assert( false );
	}

	if ( is_true( generic_obj.debugbox ) )
	{
		debugbox( handler );
	}

	if ( !isdefined( self._exception_handlers ) || !isdefined( self._exception_handlers[ handler ] ) )
	{
		assert( false );
		_GET_SERVER_ENTITY() notify( "uncaught_exception", generic_obj );
		return;
	}

	self notify( handler, generic_obj );
	generic_obj.handled = 1;
	waittillframeend;
	assert( false ); // you should not see this assert unless the exception try/catch system using endons wasn't setup to kill execution
	generic_obj.handled = 2;
	_GET_SERVER_ENTITY() notify( "uncaught_exception", generic_obj );

	return;
}

// likely undefined behavior
/*noreturn*/ throw_cmd_exception( generic_obj, format, a, b, c, d, e, f, g, h, i, j, k )
{
	generic_obj = _DEFAULT( generic_obj, generic_obj_t_new( "cmd_exception" ) );
	throw_exception( "cmd_exception", generic_obj, format, a, b, c, d, e, f, g, h, i, j, k );
}

// normal exceptions for user feedback
/*noreturn*/ throw_user_cmd_exception( generic_obj, format, a, b, c, d, e, f, g, h, i, j, k )
{
	generic_obj = _DEFAULT( generic_obj, generic_obj_t_new( "cmd_exception" ) );
	generic_obj.callstack = false;
	generic_obj.debugbox = false;
	throw_exception( "cmd_exception", generic_obj, format, a, b, c, d, e, f, g, h, i, j, k );
}

has_all_perms()
{
	return is_true( self.is_server ) || is_true( self.is_host ) || true;
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

	msg = "Invalid " + type + ": '" + arg + "', valid " + type + "s are: \n" + list;

	return msg;
}

// inlineable...
random_key( arr )
{
	keys = getarraykeys( arr );
	_ASSERT_MSG( isstring( keys[ 0 ] ) );
	return keys[ randomint( keys.size ) ];
}

random_index( arr )
{
	keys = getarraykeys( arr );
	_ASSERT_MSG( isint( keys[ 0 ] ) );
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

_MAX( val, limit )
{
	if ( val > limit )
	{
		return limit;
	}

	return val;
}

_MIN( val, limit )
{
	if ( val < limit )
	{
		return limit;
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

_REQUIRED( value, fmt, a, b, c, d, e, f, g, h, i, j, k )
{
	if ( !isdefined( value ) )
	{
		generic_obj = generic_obj_t_new( "debug_exception" );
		generic_obj.callstack = true;
		generic_obj.debugbox = true;
		throw_exception( "debug", generic_obj, fmt, a, b, c, d, e, f, g, h, i, j, k );
	}
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
	if ( !isdefined( arr_size ) || !isint( arr_size ) )
	{
		// exits the loop as undefined is used in a truthy way
		_ASSERT_MSG_ONLY( "Infinite loop prevented by invalid array!" );
		return 0;
	}

	return arr_size;
}

private delete_after_time( entity )
{
	entity endon( "death" );

	wait 0.05;

	entity delete();
}

private spawn_test_ent()
{
	test_ent = spawn( "script_model", ( 0, 0, -5000 ) );
	level thread delete_after_time( test_ent );

	return test_ent;
}

_MODEL_EXISTS( arg )
{
	test_ent = spawn_test_ent();
	test_ent setmodel( arg );

	if ( test_ent.model == "" )
	{
		test_ent delete();
		return false;
	}

	test_ent delete();
	return true;
}

_WEAPON_EXISTS( name )
{
	// csc alternative
	return weaponclass( name ) != "none";
}

_FX_EXISTS( alias )
{
	return isdefined( level._effect[ alias ] );
}

_get_real_fx()
{
	arr = [];
	keys = getarraykeys( level._effect );
	for ( i = 0; i < keys.size; i++ )
	{
		if ( !isdefined( level._effect[ keys[ i ] ] ) )
		{
			continue;
		}

		arr[ keys[ i ] ] = level._effect[ keys[ i ] ];
	}

	return arr;
}

_init_server()
{
	if ( !isdefined( level.server ) )
	{
		level.server = spawnStruct();
		entity = spawnstruct();
		entity.cmd_history = [];
		entity.playername = getdvar( "sv_hostname" );
		entity.name = getdvar( "sv_hostname" );
		entity.is_server = true;
		entity.origin = ( 0, 0, 0 );
		entity.angles = ( 0, 0, 0 );
		entity.default_targets = []; // treat this value as the default target for optional target specifying
		entity.default_executors = []; // treat this value as the default executor for the command; the command is executed on behalf of the server on a player
		_SET_SERVER_ENTITY( entity );
		level.server.entity.default_executors[ 0 ] = level.server.entity;
	}
}

_GET_SERVER_ENTITY()
{
	return level.server.entity;
}

_SET_SERVER_ENTITY( new_entity )
{
	level.server.entity = new_entity;
}

_IS_SERVER_ENTITY()
{
	return is_true( self.is_server );
}

_ARRAY_VALIDATE( array )
{
	return isdefined( array ) && isarray( array ) && array.size > 0;
}

server_safe_notify_thread( notify_name, index )
{
	waittillframeend;
	level notify( notify_name );
}

/@
"Name: timescale_tween( <start>, <end>, <time>, [delay], [step_time] )"
"Summary: Tweens timescale from a starting value to an ending value over time."
"Module: Utility"
"MandatoryArg: start: Starting timescale."
"MandatoryArg: end: Ending timescale."
"MandatoryArg: time: Time to get form start to end."
"OptionalArg: delay: time delay before starting."
"OptionalArg: step_time: time delay between setting timescale values (how smoothly you want to step)."
"Example: level thread timescale_tween(.06, 1, tween_time);"
"SPMP: SP"
@/
timescale_tween(start, end, time, delay = 0.0, step_time = 0.1 )
{
	if ( !IsDefined( start ) )
	{
		start = getdvar("timescale");
	}
	
	num_steps = time / step_time;
	time_scale_range = end - start;

	time_scale_step = 0;
	if (num_steps > 0)
	{
		time_scale_step = abs(time_scale_range) / num_steps;
	}

	if ( delay > 0.0 )
	{
		wait delay;
	}

	level notify("timescale_tween");
	level endon("timescale_tween");

	time_scale = start;
	setdvar( "timescale", time_scale );

	while (time_scale != end)
	{
		wait(step_time);

		if (time_scale_range > 0)
		{
			time_scale = min(time_scale + time_scale_step, end);
		}
		else if (time_scale_range < 0)
		{
			time_scale = max(time_scale - time_scale_step, end);
		}

		setdvar( "timescale", time_scale );
	}
}

cmd_execute_single_command( message, is_hidden, is_team_chat )
{
	self thread cmd_execute_internal( message, self, is_hidden, is_team_chat ); // the default caller of a non threaded function is the caller of the parent thread
}

flag_wait_until_set_once( flag )
{
	while ( !level flag_exists( flag ) || !flag( flag ) )
		wait 0.05;
}

new_debug_hud( x, y_offset, multi_hud = false )
{
	if ( !isdefined( level.debug_hud_y_offset ) )
	{
		level.debug_hud_y_offset = 0;
	}
	
	if ( !multi_hud )
	{
		level.debug_hud_y_offset += y_offset;
	}
	hud = newClientHudElem( self );
	hud.alignx = "left";
	hud.aligny = "middle";
	hud.horzalign = "user_left";
	hud.vertalign = "user_bottom";
	hud.x += x;
	hud.y += level.debug_hud_y_offset;
	hud.fontscale = 1.4;
	hud.alpha = 1;
	hud.color = ( 1, 1, 1 );
	hud.hidewheninmenu = 1;
	hud.foreground = 1;

	return hud;
}

destroy_on_intermission()
{
	self endon( "death" );

	level waittill( "intermission" );

	if ( isDefined( self.elemtype ) && self.elemtype == "bar" )
	{
		self.bar destroy();
		self.barframe destroy();
	}

	self destroy();
}

is_player_looking_at( origin, dot, do_trace, ignore_ent )
{
	_ASSERT_MSG( isplayer( self ), "player_looking_at must be called on a player." );

	if ( !isdefined( dot ) )
		dot = 0.7;

	if ( !isdefined( do_trace ) )
		do_trace = 1;

	eye = self geteye();
	delta_vec = anglestoforward( vectortoangles( origin - eye ) );
	view_vec = anglestoforward( self getplayerangles() );
	new_dot = vectordot( delta_vec, view_vec );

	if ( new_dot >= dot )
	{
		if ( do_trace )
			return bullettracepassed( origin, eye, 0, ignore_ent );
		else
			return 1;
	}

	return 0;
}

parse_cmd_message( message )
{
	return parse_cmd_message_internal( message );
}

function_void()
{
	return;
}

cast_entity_raycast_from_player_eye()
{
	direction = self getplayerangles();
	direction_vec = anglestoforward( direction );
	eye = self geteye();
	scale = 8000;
	direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
	trace = bullettrace( eye, eye + direction_vec, false, undefined );

	if ( !isdefined( trace[ "entity" ] ) )
	{
		trace = physicstrace( eye, eye + direction_vec, vectorscale( ( -1, -1, 0 ), 15.0 ), vectorscale( ( 1, 1, 0 ), 15.0 ), self, level._editor_ent_mask );
		if ( !isdefined( trace[ "entity" ] ) )
		{
			return trace;
		}
	}

	return trace;
}

get_entity_type_name( ent )
{
	if ( !isdefined( ent ) )
	{
		return "null";
	}

	typename = level._entity_typenums[ ent getentitytype() ];
	if ( !isdefined( typename ) )
	{
		return "null";
	}

	return typename;
}

add_mapent_entity( ent, mapent_type, id )
{
	ent.mapent_type = mapent_type;
	ent.mapent_id = id;
	if ( !isdefined( ent.keys ) )
	{
		ent.keys = [];
	}
	
	level._mapents[ mapent_type ][ id ] = ent;
}

new_mapent_struct( a, b )
{
	new_struct = spawnstruct();
	new_struct.keys = [];
	return new_struct;
}

pack( a, b, c, d, e, f, g, h, i, j, k )
{
	arr = [];

	arr[ arr.size ] = a;
	arr[ arr.size ] = b;
	arr[ arr.size ] = c;
	arr[ arr.size ] = d;
	arr[ arr.size ] = e;
	arr[ arr.size ] = f;
	arr[ arr.size ] = g;
	arr[ arr.size ] = h;
	arr[ arr.size ] = i;
	arr[ arr.size ] = j;
	arr[ arr.size ] = k;

	arrayremovevalue( arr, undefined );

	return arr;
}

format( fmt, a, b, c, d, e, f, g, h, i, j, k )
{
	args = pack( a, b, c, d, e, f, g, h, i, j, k );

	if ( !_ARRAY_VALIDATE( args ) )
	{
		return fmt;
	}

	_SAVE_FMT();
	_ASSERT_MSG( isstring( fmt ) );

	insert_arg_index = 0;

	_RESET_FMT( fmt );

	for ( ;; )
	{
		remaining = _PUSH_POS_UNTIL_CHAR( "{" );
		if ( remaining <= 0 )
		{
			break;
		}

		if ( _GET_IDX_CHAR_AT( level._fmt_pos + 1 ) == "}" )
		{
			level._fmt_final_str += args[ insert_arg_index ];
			insert_arg_index++;
			level._fmt_pos++;
		}

		level._fmt_pos++;
	}

	if ( insert_arg_index != args.size )
	{
		_ASSERT_MSG_ONLY( "format: Mismatched inserts to args!" );
	}

	level._fmt_pos = undefined;
	level._fmt_str = undefined;

	result = level._fmt_final_str;
	_RESTORE_FMT();
	return result;
}

_MAKE_ORDINAL_KEY( integer )
{
	return integer + "";
}

_GET_RADIANT_KEYS_OBJ()
{
	if ( !isdefined( level._radiant_keys_obj ) || !_ARRAY_VALIDATE( level._radiant_keys_obj.data ) )
	{
		_ASSERT_MSG_ONLY( "_GET_RADIANT_KEYS_OBJ: level._radiant_keys_obj was not setup!" );
		return undefined;
	}

	return level._radiant_keys_obj;
}

_IS_KEY_VALID_FOR_RADIANT( key )
{
	keys_obj = _GET_RADIANT_KEYS_OBJ();

	if ( !isdefined( keys_obj ) )
	{
		return false;
	}

	return isdefined( keys_obj.data[ key ] );
}

_cast_radiant_kvp( key, value )
{
	if ( !_IS_KEY_VALID_FOR_RADIANT( key ) )
	{
		return undefined;
	}

	keys_obj = _GET_RADIANT_KEYS_OBJ();

	if ( keys_obj.data[ key ].type == "string" )
	{
		return value;
	}

	result_obj = cast_str_to_primitive_type( value, keys_obj.data[ key ].type );

	_ASSERT_MSG( !result_obj.errored, "_cast_radiant_kvp: '{}'", result_obj.msg );
	return result_obj;
}

_type_for_radiant_key( key )
{
	keys_obj = _GET_RADIANT_KEYS_OBJ();

	if ( !isdefined( keys_obj ) )
	{
		return "";
	}

	return keys_obj.data[ key ].type;
}

_desc_for_radiant_key( key )
{
	keys_obj = _GET_RADIANT_KEYS_OBJ();

	if ( !isdefined( keys_obj ) )
	{
		return "";
	}

	return keys_obj.data[ key ].desc;
}

_is_whitespace( c )
{
	return c == " " || c == "\t" || c == "\r";
}

// removes all preceding and succeeding whitespace
_trim( str )
{
	new_str = "";
	for ( i = 0; i < _SIZE( str.size ); i++ )
	{
		if ( !_is_whitespace( str[ i ] ) )
		{
			new_str = getsubstr( str, i );
			break;
		}
	}

	new_str2 = "";
	for ( i = _SIZE( new_str.size ) - 1; i >= 0; i-- )
	{
		if ( !_is_whitespace( str[ i ] ) )
		{
			new_str2 = getsubstr( new_str, 0, i );
			break;
		}
	}

	return new_str2;
}

_remove_whitespace( str )
{
	new_str = "";
	for ( i = 0; i < _SIZE( str.size ); i++ )
	{
		if ( _is_whitespace( str[ i ] ) )
		{
			continue;
		}

		new_str += str[ i ];
	}

	return new_str;
}

_istricmp( str1, str2, length )
{
	length = _DEFAULT( length, _SIZE( str2.size ) );

	lower1 = tolower( str1 );
	lower2 = tolower( str2 );
	return !( getsubstr( lower1, 0, length ) == lower2 );
}

clamp_array( arr, limit )
{
	if ( limit >= arr.size )
	{
		return arr;
	}

	new_arr = [];
	i = 0;
	foreach ( key, val in arr )
	{
		if ( i >= limit )
		{
			break;
		}

		new_arr[ key ] = val;
		i++;
	}

	return new_arr;
}