#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

throw_parse_exception( msg )
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
		return;
	}

	if ( level._parse_obj.current_value_string[ 2 ] == "[" )
	{
		parse_array();
		return;
	}

	if ( !is_numeric( level._parse_obj.current_value_string, 1 ) )
	{
		throw_parse_exception( "Random target pool limit must be a number" );
	}

	number_string = getsubstr( level._parse_obj.current_value_string, 1 );

	if ( int( number_string ) <= 0 )
	{
		throw_parse_exception( "Random target pool limit must be a number and greater than '0'" );
	}

	set_type( "random" );
}

private try_parse_function()
{
	end_pos = -1;
	for ( i = 0; i < level._parse_obj.current_value_string.size; i++ )
	{
		if ( level._parse_obj.current_value_string[ i ] == "(" ) // function start
		{
			end_pos = i - 1;
			break;
		}
	}

	if ( end_pos == -1 )
	{
		return false;
	}

	if ( !is_alpha_numeric( level._parse_obj.current_value_string, true, 0, end_pos ) )
	{
		throw_parse_exception( "Function names can only contain alnum, '_', and '('" );
	}

	if ( level._parse_obj.current_value_string[ level._parse_obj.current_value_string.size - 1 ] != ")" )
	{
		throw_parse_exception( "Function wasn't terminated with ')'" );
	}

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
	if ( is_alpha_numeric( level._parse_obj.current_value_string[ 0 ] ) )
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
	}

	throw_parse_exception( "Unsupported target directive value: '" + level._parse_obj.current_value_string + "'" );
}

private parse_directive( base_key, value_string )
{
	if ( level._parse_obj.current_key_string[ 0 ] == "t" || level._parse_obj.current_key_string == "target" )
	{
		parse_target_value();
	}
	else if ( level._parse_obj.current_key_string[ 0 ] == "e" || level._parse_obj.current_key_string == "executor" ) // allows you to specify the 'executor' or who executes the command
	{
		parse_target_value();
	}
	
	switch ( level._parse_obj.current_key_string )
	{
		case "c":
		case "call":
			//parse_call_value( value );
			break;
		case "script":
			//parse_script_value( value );
			break;
		case "func":
			break;
		case "hook":
			//parse_args_value( value );
			break;
		case "types":
			break;
		case "name": // a component of a function; functions contain: a name, a script, and types
			break;
		case "unhook": // remove a hook from a function
			break;
		case "print_args": // the redirected function will also print its arguments based on the specified types
			break;
		case "nullsub": // redirect function to a do nothing or nullsub function; boolean
			break;
		case "persist": // persist the hook by committing it to the filesystem; boolean
			break;
		case "cmd_arg": // this allows manually specifying more data about the arguments if needed; syntax is arg1 or arg followed by the argument ordinal
			break;
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

	for ( i = 0; i < kvps.size; i += 2 )
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
			// we don't need to send the separating comma
			combined_kvps[ combined_kvps.size ] = getsubstr( str, start_pos, pos - 1 );
			start_pos = pos + 1; // start after the separating comma
		}
	}

	return combined_kvps;
} 

/*cmd_parse_obj_array_t*/ private cmd_parse_obj_array_t_new()
{
	cmd_parse_obj = generic_obj_t_new( "cmd_parse_array" );
	cmd_parse_obj.cmds = []; // string -> cmd_parse_obj_t
	return cmd_parse_obj;
}

/*token_obj_t*/ private token_obj_t_new( base_key )
{
	parse_token_obj = generic_obj_t_new( "parse_token" );
	parse_token_obj.base_key = base_key;
	parse_token_obj.type = "unassigned"; // can be "identifier"(for a name or string), "number"(int, float)
	parse_token_obj.v = []; // 0 is used for singleton types like identifier, > 0 is used for arrays

	return parse_token_obj;
}

/*parse_obj_t*/ private parse_obj_t_new( cmd_string, cmd_data_source )
{
	level._parse_obj = generic_obj_t_new( "parse" );
	level._parse_obj.args = [];
	level._parse_obj.kvps = [];
	level._parse_obj.cmd_data_source = cmd_data_source;
	level._parse_obj.cmd_string = cmd_string;

	// volatile; assume these are overwritten between uses of this object
	level._parse_obj.current_token = "";
	level._parse_obj.current_key_string = "";
	level._parse_obj.current_value_string = "";
	level._parse_obj.start_pos = 0;
	level._parse_obj.end_pos = 0;
}

private copy_parse_obj_t( parse_obj )
{
	copy = generic_obj_t_new( "parse" );
	copy.args = parse_obj.args;
	copy.kvps = parse_obj.kvps;
	copy.cmd_data_source = parse_obj.cmd_data_source;
	copy.str = parse_obj.str;
	copy.start_pos = parse_obj.start_pos;
	copy.end_pos = parse_obj.end_pos;

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
}

private add_value( value_string )
{
	key_string = level._parse_obj.current_key_string;
	assert( isdefined( level._parse_obj.kvps[ key_string ] ) );

	level._parse_obj.current_value_string = value_string;
	level._parse_obj.kvps[ key_string ].v[ level._parse_obj.kvps[ key_string ].v.size ] = value_string;
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

	level._parse_obj.current_key_string = base_key;
	level._parse_obj.kvps[ key_string ] = token_obj_t_new( base_key );
}

private add_arg( arg_str )
{
	level._parse_obj.args[ level._parse_obj.args.size ] = arg_str;
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
	for ( i = 0; i < str.size; i++ )
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

			split_end = ( i + 1 );
			tokens[ tokens.size ] = getsubstr( str, split_start, split_end );
			com_printdebugwarning( "Custom split for directive: tok: " + tokens[ tokens.size - 1 ] + " start: " + split_start + " end: " + split_end );

			in_identifier = false;
			spaces_delimit = true;
		}
		else if ( is_alpha_numeric( str[ i ], true ) )
		{
			if ( !was_in_identifier )
			{
				split_start = i;
				was_in_identifier = true;
			}
			in_identifier = true;
		}

		if ( str[ i ] == " " )
		{
			if ( in_identifier )
			{
				tokens[ tokens.size ] = getsubstr( str, split_start, i );
				split_start = i;
				was_in_identifier = false;
			}

			in_identifier = false;
		}

		if ( ( i + 1 ) == str.size )
		{
			if ( in_identifier )
			{
				tokens[ tokens.size ] = getsubstr( str, split_start );
				split_start = i;
				was_in_identifier = false;
			}

			in_identifier = false;
		}
	}

	if ( tokens.size == 0 )
	{
		tokens[ 0 ] = str;
	}

	return tokens;
}

// Last command token to execute the last command implicitly
/*cmd_parse_obj_array_t export*/ parse_cmd_message( message )
{
	cmd_parse_array = cmd_parse_obj_array_t_new();
	if ( message == "" )
	{
		throw_parse_exception( "Command string is empty" );
	}

	com_printdebugwarning( message );

	multiple_cmds_keys = strtok( message, "^" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_string = custom_split( multiple_cmds_keys[ i ] );
		cmd_find_result = cast_str_to_cmd( cmd_string[ 0 ] );
		parse_obj_t_new( cmd_string, cmd_find_result );
		if ( cmd_find_result.errored )
		{
			throw_parse_exception( cmd_find_result.msg );
		}
		
		cmd_name = cmd_find_result.value.cmd_name;

		for ( j = 1; j < cmd_string.size; j++ )
		{
			level._parse_obj.current_token = cmd_string[ j ];
			com_printdebugwarning( level._parse_obj.current_token );
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

				kvps = split_kvps();
				for ( k = 0; k < kvps.size; k += 2 )
				{
					kvps = strtok( kvps[ k ], "=" );
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
					add_value( value );
					parse_directive();
				}
			}
			else
			{
				add_arg( cmd_string[ j ] );
				level.players[ 0 ] script_breakpoint( level._parse_obj );
			}
		}

		cmd_parse_array.cmds[ cmd_parse_array.cmds.size ] = copy_parse_obj_t( level._parse_obj );
	}

	return cmd_parse_array;
}