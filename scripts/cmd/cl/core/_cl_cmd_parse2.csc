#include clientscripts\mp\_utility;

#include scripts\cmd\cl\core\_cl_utility;

private com_printparse( msg )
{
	if ( getdvarint( "tcs_debug_parser" ) == 1 )
	{
		com_printinfo( msg );
	}
}

private throw_parse_exception( msg )
{
	throw_exception( msg, level._parse_obj );
}

private parse_array()
{
	tokens = [];
	if ( level._parse_obj.current_value_string[ level._parse_obj.current_value_string.size - 1 ] != "]" )
	{
		// error
		throw_parse_exception( "Last character of array wasn't terminated with ']'" );
	}

	set_type( "array" );
}

private parse_target_random()
{
	if ( level._parse_obj.current_value_string.size <= 1 )
	{
		throw_parse_exception( "Random target pool limit must be a number and greater than '1' OR be followed by an array start '['" );
	}

	if ( level._parse_obj.current_value_string[ 1 ] == "[" )
	{
		level._parse_obj.current_value_string = getsubstr( level._parse_obj.current_value_string, 2 );
		parse_array();
		set_type( "array_random" );
		return;
	}

	if ( !is_numeric( level._parse_obj.current_value_string, 1 ) )
	{
		throw_parse_exception( "Random target pool limit must be a number" );
	}

	level._parse_obj.current_value_string = getsubstr( level._parse_obj.current_value_string, 1 );

	if ( int( level._parse_obj.current_value_string ) <= 1 )
	{
		throw_parse_exception( "Random target pool limit must be a number and greater than '1'" );
	}

	set_type( "random" );
}

private try_parse_function()
{
	end_pos = -1;
	path_end_pos = -1;
	name_end_pos = -1;
	str = level._parse_obj.current_value_string;
	for ( i = 0; i < _SIZE( str.size ); i++ )
	{
		if ( str[ i ] == "(" ) // function start
		{
			name_end_pos = i - 1;
			break;
		}

		if ( str[ i ] == ":" && str[ i + 1 ] == ":" )
		{
			path_end_pos = i - 1;
		}
	}

	// the path doesn't need to be specified as we can add a command to set search paths for getfunction
	if ( name_end_pos == -1 )
	{
		return false;
	}

	if ( !is_alpha_numeric( level._parse_obj.current_value_string, true, path_end_pos + 2, name_end_pos ) )
	{
		throw_parse_exception( "Function names can only contain alnum, '_', and '('" );
	}

	if ( level._parse_obj.current_value_string[ level._parse_obj.current_value_string.size - 1 ] != ")" )
	{
		throw_parse_exception( "Function wasn't terminated with ')'" );
	}

	// path
	if ( path_end_pos == -1 )
	{
		level._parse_obj.kvps[ level._parse_obj.current_key_string ].v[ level._parse_obj.current_value_index ] = "";
		level._parse_obj.current_value_index++;
		path_end_pos = -3;
	}
	else
	{
		level._parse_obj.kvps[ level._parse_obj.current_key_string ].v[ level._parse_obj.current_value_index ] = getsubstr( level._parse_obj.current_value_string, 0, path_end_pos );
		level._parse_obj.current_value_index++;
	}

	// name
	level._parse_obj.kvps[ level._parse_obj.current_key_string ].v[ level._parse_obj.current_value_index ] = getsubstr( level._parse_obj.current_value_string, path_end_pos + 3, name_end_pos );
	level._parse_obj.current_value_index++;
	// args
	level._parse_obj.kvps[ level._parse_obj.current_key_string ].v[ level._parse_obj.current_value_index ] = getsubstr( level._parse_obj.current_value_string, name_end_pos + 2, level._parse_obj.current_value_string.size - 1 );
	set_type( "function_call" );

	return true;
}

private try_parse_name()
{
	if ( !is_alpha_numeric( level._parse_obj.current_value_string, true ) )
	{
		throw_parse_exception( "Target names can only contain alnum, and '_'" );
	}

	set_type( "name" );
}

private parse_target_value()
{
	// basic tokens
	switch ( level._parse_obj.current_value_string[ 0 ] )
	{
		case "*":
			set_type( "all" );
			return;
		case "!":
			set_type( "undefined" );
			return;
		case "&":
			set_type( "self" ); // explicit self
			return;
		case "#":
			set_type( "default" ); // the default, and configureable target explicitly specified
			return;
	}

	// array and random
	switch ( level._parse_obj.current_value_string[ 0 ] )
	{
		case "$":
			return parse_target_random();
		case "[":
			return parse_array();
	}

	// function and name(identifier)
	if ( is_alpha_numeric( level._parse_obj.current_value_string[ 0 ], true ) )
	{
		// ambiguous, could be function start or a name
		is_function = try_parse_function();
		if ( is_function )
		{
			return;
		}

		// not a function, no '(' token
		// names can contain a lot of weird characters, but you are better off using the guid/clientnum syntax anyway
		try_parse_name();
		return;
	}

	throw_parse_exception( "Unsupported target directive value: '" + level._parse_obj.current_value_string + "'" );
}

private parse_directive()
{
	check_str = level._parse_obj.current_key_string;
	if ( level._parse_obj.current_base_key_string != level._parse_obj.current_key_string )
	{
		check_str = level._parse_obj.current_base_key_string;
	}
	
	com_printparse( "parse_directive: '" + check_str + "'" );

	if ( check_str[ 0 ] == "t" || check_str == "target" )
	{
		parse_target_value();
		return;
	}
	else if ( check_str[ 0 ] == "e" || check_str == "executor" ) // allows you to specify the 'executor' or who executes the command
	{
		parse_target_value();
		return;
	}

	if ( check_str[ 0 ] == "cl" || check_str == "client" )
	{
		parse_target_value();
		return;
	}
	
	switch ( check_str )
	{
		case "c":
		case "call":
			//parse_call_value( value );
			return;
		case "script":
			//parse_script_value( value );
			return;
		case "func":
			return;
		case "hook":
			//parse_args_value( value );
			return;
		case "types":
			return;
		case "name": // a component of a function; functions contain: a name, a script, and types
			return;
		case "unhook": // remove a hook from a function
			return;
		case "print_args": // the redirected function will also print its arguments based on the specified types
			return;
		case "nullsub": // redirect function to a do nothing or nullsub function; boolean
			return;
		case "persist": // persist the hook by committing it to the filesystem; boolean
			return;
		case "cmd_arg": // this allows manually specifying more data about the arguments if needed; syntax is arg1 or arg followed by the argument ordinal
			return;
	}

	throw_parse_exception( "Unsupported directive key '" + level._parse_obj.current_key_string + "'" );
}

// @{target1=[a,b,c],t2=JezuzLizard,t3={a=5,b=8}}
// post '@{...}' removal
// target1=[a,b,c],t2=JezuzLizard,t3={a=5,b=8}
// post "," split
// target1=[a,b,c]
// t2=JezuzLizard
// t3={a=5,b=8}
// post '=' split
// target1 [a,b,c]
// t2 JezuzLizard
// t3 {a=5,b=8} // if we just split the kvps again we can actually parse them at least!
private split_combined_kvps()
{
	keys_to_values = [];

	kvps = strtok( level._parse_obj.current_token, "=" );

	if ( ( kvps.size % 2 ) != 0 )
	{
		throw_parse_exception( "Key value pairs are not matching" );
	}

	for ( i = 0; i < _SIZE( kvps.size ); i += 2 )
	{
		switch ( kvps[ i + 1 ][ 0 ] )
		{
			case "{":
				throw_parse_exception( "Nested keys are not supported" );
				break;
			default:
				keys_to_values[ kvps[ i ] ] = kvps[ i + 1 ];
				break;
		}
	}

	return keys_to_values;
}

private split_kvps()
{
	combined_kvps = [];
	commas_delimit = true;
	func_needs_closed = 0;
	array_needs_closed = 0;
	key_needs_closed = 0;
	is_single_kvp = true;

	str = level._parse_obj.current_token;

	start_pos = 0;
	for ( pos = start_pos;; pos++ )
	{
		if ( pos >= str.size )
		{
			if ( !commas_delimit )
			{
				throw_parse_exception( "Unmatching function or array braces" );
			}
			break;
		}

		if ( str[ pos ] == "{" )
		{
			key_needs_closed++;
		}
		else if ( str[ pos ] == "}" )
		{
			key_needs_closed--;
		}
		else if ( str[ pos ] == "(" )
		{
			func_needs_closed++;
		}
		else if ( str[ pos ] == ")" )
		{
			func_needs_closed--;
		}
		else if ( str[ pos ] == "[" )
		{
			array_needs_closed++;
		}
		else if ( str[ pos ] == "]" )
		{
			array_needs_closed--;
		}

		commas_delimit = array_needs_closed == 0 && func_needs_closed == 0 && key_needs_closed == 0;

		if ( commas_delimit && str[ pos ] == "," )
		{
			is_single_kvp = false;
			index = combined_kvps.size;
			combined_kvps[ index ] = getsubstr( str, start_pos, pos );
			start_pos = pos + 1; // start after the separating comma
			com_printparse( "split_kvps() Delimited '" + index + "' key: '" + combined_kvps[ index ] + "'" );
		}

		if ( ( pos + 1 ) >= str.size )
		{
			combined_kvps[ combined_kvps.size ] = getsubstr( str, start_pos );
			com_printparse( "split_kvps() Terminating key: '" + combined_kvps[ combined_kvps.size - 1 ] + "'" );
			break;
		}
	}

	if ( is_single_kvp )
	{
		combined_kvps[ 0 ] = getsubstr( str, start_pos );
		com_printparse( "split_kvps() is_single_kvp key: '" + combined_kvps[ 0 ] + "'" );
	}

	return combined_kvps;
} 

/*cmd_parse_obj_array_t*/ private cmd_parse_obj_array_t_new()
{
	cmd_parse_obj = generic_obj_t_new( "cmd_parse_array" );
	cmd_parse_obj.cmds = []; // string -> cmd_parse_obj_t
	return cmd_parse_obj;
}

/*token_obj_t*/ private token_obj_t_new( base_key, ordinal_argument )
{
	parse_token_obj = generic_obj_t_new( "parse_token" );
	parse_token_obj.base_key = base_key;
	parse_token_obj.ordinal_argument = ordinal_argument;
	parse_token_obj.type = "unassigned"; // can be "identifier"(for a name or string), "number"(int, float)
	parse_token_obj.v = []; // 0 is used for singleton types like identifier, > 0 is used for arrays

	return parse_token_obj;
}

/*parse_obj_t*/ private parse_obj_t_new( cmd_string, cmd_data_source )
{
	level._parse_obj = generic_obj_t_new( "parse" );
	level._parse_obj.args = [];
	level._parse_obj.kvps = [];
	level._parse_obj.kvps_ordinal = [];
	level._parse_obj.cmd_data_source = cmd_data_source;
	level._parse_obj.cmd_string = cmd_string;

	// volatile; assume these are overwritten between uses of this object
	level._parse_obj.current_token = "";
	level._parse_obj.current_key_string = "";
	level._parse_obj.current_value_string = "";
	level._parse_obj.current_base_key_string = "";
	level._parse_obj.current_ordinal_argument = 0; // 0 is invalid
	level._parse_obj.start_pos = 0;
	level._parse_obj.end_pos = 0;
}

private copy_parse_obj_t( parse_obj )
{
	copy = generic_obj_t_new( "parse" );
	copy.args = parse_obj.args;
	copy.kvps = parse_obj.kvps;
	copy.kvps_ordinal = parse_obj.kvps_ordinal;
	copy.cmd_data_source = parse_obj.cmd_data_source;
	copy.cmd_string = parse_obj.cmd_string;

	// volatile things are not needed

	return copy;
}

/*
{target1=[a,b,c],t2=JezuzLizard,t3={a=5,b=8}}

level._parse_obj.kvps[ "target1" ].type = array;
level._parse_obj.kvps[ "target1" ].v[ 0 ] = a;
level._parse_obj.kvps[ "target1" ].v[ 1 ] = b;
level._parse_obj.kvps[ "target1" ].v[ 2 ] = c;
*/

private set_type( new_type )
{
	level._parse_obj.kvps[ level._parse_obj.current_key_string ].type = new_type;
	level._parse_obj.kvps_ordinal[ level._parse_obj.current_ordinal_argument + "" ].type = new_type;
}

private add_value( value_string )
{
	key_string = level._parse_obj.current_key_string;
	assert( isdefined( level._parse_obj.kvps[ key_string ] ) );

	level._parse_obj.current_value_string = value_string;
	level._parse_obj.current_value_index = level._parse_obj.kvps[ key_string ].v.size;
	level._parse_obj.kvps[ key_string ].v[ level._parse_obj.current_value_index ] = value_string;
	level._parse_obj.kvps_ordinal[ level._parse_obj.current_ordinal_argument + "" ].v[ level._parse_obj.current_value_index ] = value_string;
}

private add_key( key_string )
{
	assert( !isdefined( level._parse_obj.kvps[ key_string ] ) );

	base_key = key_string;
	ordinal_argument = int( key_string[ key_string.size - 1 ] );
	if ( ordinal_argument > 0 )
	{
		base_key = getsubstr( key_string, 0, key_string.size - 1 );
	}
	else
	{
		throw_parse_exception( "Target ordinal must be an integer greater than 0" );
	}

	level._parse_obj.current_key_string = key_string;
	level._parse_obj.current_base_key_string = base_key;
	level._parse_obj.current_ordinal_argument = ordinal_argument;
	level._parse_obj.kvps[ key_string ] = token_obj_t_new( base_key, ordinal_argument );
	level._parse_obj.kvps_ordinal[ _MAKE_ORDINAL_KEY( ordinal_argument ) ] = token_obj_t_new( base_key, ordinal_argument );
}

private add_arg( arg_str )
{
	level._parse_obj.args[ level._parse_obj.args.size ] = arg_str;
}

private parse_token_until_delimiter( str, start, delimiter = " " )
{
	delimited_obj = spawnstruct();
	delimited_obj.end = start;
	for ( i = start; i < _SIZE( str.size ); i++ )
	{
		if ( ( i + 1 ) >= str.size )
		{
			delimited_obj.end = i + 1;
			delimited_obj.identifier_str = getsubstr( str, start, delimited_obj.end );
			break;
		}

		if ( str[ i ] == delimiter )
		{
			delimited_obj.end = i;
			delimited_obj.identifier_str = getsubstr( str, start, delimited_obj.end );
			break;
		}
	}

	return delimited_obj;
}

// by convention the following are true:
// the command to be executed is the first alnum + '_' string encountered; therefore it can be before or after any '@' directives
// directives '@' can appear in any order in the string
// spaces can now be used within directives, functions and arrays; otherwise it would not be possible to 
private custom_split( str )
{
	tokens = [];
	in_identifier = false;

	split_start = 0;
	was_in_identifier = false;
	spaces_delimit = true;
	for ( i = 0; i < _SIZE( str.size ); i++ )
	{
		if ( str[ i ] == "@" )
		{
			spaces_delimit = false;
			split_start = i;
			i++;
			if ( i == str.size || str[ i ] != "{" )
			{
				//fail, must be at least 3 characters to be at least somewhat valid "@{}"
				throw_parse_exception( "Directive must be at least '@{'" );
			}

			brace_count = 0;
			for ( ; ; i++ )
			{
				if ( str[ i ] == "{" )
				{
					brace_count++;
				}
				else if ( str[ i ] == "}" )
				{
					brace_count--;
				}

				spaces_delimit = brace_count == 0;

				if ( spaces_delimit )
				{
					break; // we are not in a directive block anymore
				}
				if ( ( i + 1 ) == str.size )
				{
					throw_parse_exception( "Directive must be terminated with '}'" );
				}
			}

			split_end = i + 1;
			tokens[ tokens.size ] = getsubstr( str, split_start, split_end );
			com_printparse( "Custom split for directive: tok: " + tokens[ tokens.size - 1 ] + " start: " + split_start + " end: " + split_end );
			split_start = split_end;
			i = split_end;

			spaces_delimit = true;
		}
		else
		{
			delimited_str_obj = parse_token_until_delimiter( str, i, " " );
			tokens[ tokens.size ] = delimited_str_obj.identifier_str;
			com_printparse( "Custom split for arg: tok: " + tokens[ tokens.size - 1 ] + " start: " + i + " end: " + delimited_str_obj.end );
			i = delimited_str_obj.end;
		}
	}

	if ( tokens.size == 0 )
	{
		tokens[ 0 ] = str;
	}

	return tokens;
}

// Last command token to execute the last command implicitly
/*cmd_parse_obj_array_t export*/ parse_cmd_message_internal( message )
{
	cmd_parse_array = cmd_parse_obj_array_t_new();
	if ( message == "" )
	{
		throw_parse_exception( "Command string is empty" );
	}

	com_printparse( message );

	multiple_cmds_keys = strtok( message, "^" );
	for ( i = 0; i < _SIZE( multiple_cmds_keys.size ); i++ )
	{
		cmd_strings = custom_split( multiple_cmds_keys[ i ] );
		cmd_find_result = cast_str_to_cmd( cmd_strings[ 0 ] );
		if ( cmd_find_result.errored )
		{
			throw_parse_exception( cmd_find_result.msg );
		}

		parse_obj_t_new( multiple_cmds_keys[ i ], cmd_find_result.value );

		for ( j = 1; j < _SIZE( cmd_strings.size ); j++ )
		{
			level._parse_obj.current_token = cmd_strings[ j ];
			com_printparse( level._parse_obj.current_token );
			if ( level._parse_obj.current_token[ 0 ] == "@" )
			{
				if ( level._parse_obj.current_token[ 1 ] != "{" )
				{
					throw_parse_exception( "Directive block '@' must be immediately followed by a opening '{' curly brace" );
				}

				if ( level._parse_obj.current_token[ level._parse_obj.current_token.size - 1 ] != "}" )
				{
					throw_parse_exception( "Directive block '@' must be closed with a closing '}' curly brace" );
				}

				// remove the @{...}, so that it is easier to parse
				level._parse_obj.current_token = getsubstr( level._parse_obj.current_token, 2, ( level._parse_obj.current_token.size - 1 ) );
				

				combined_kvps = split_kvps();
				for ( k = 0; k < _SIZE( combined_kvps.size ); k++ )
				{
					kvps = strtok( combined_kvps[ k ], "=" );
					key = kvps[ 0 ];
					value = kvps[ 1 ];

					if ( !is_alpha_numeric( key ) )
					{
						throw_parse_exception( "Directive key: '" + key + "' contains an invalid character; only alnum and '_' characters are allowed" );
					}

					if ( value[ 0 ] == "{" )
					{
						throw_parse_exception( "Nested keys are not supported" );
					}

					add_key( key );
					com_printparse( "parse_cmd_message() key: '" + key + "'" );
					add_value( value );
					com_printparse( "parse_cmd_message() value: '" + value + "'" );
					parse_directive();
				}
			}
			else
			{
				add_arg( level._parse_obj.current_token );
				//level.primaryclient script_breakpoint( level._parse_obj );
			}
		}

		cmd_parse_array.cmds[ cmd_parse_array.cmds.size ] = copy_parse_obj_t( level._parse_obj );
	}

	return cmd_parse_array;
}