#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_cmd_util;

cmd_buffer()
{
	while ( true )
	{
		level waittill( "say", message, player, is_hidden, is_team_chat );
		player thread cmd_execute( message, player, is_hidden, is_team_chat ); // the default caller of a non threaded function is the caller of the parent thread
	}
}

is_alpha( chr )
{
	abc = "abcdefghijklmnopqrstuvwxyz";

	return isdefined( abc[ tolower( chr ) ] );
}

is_alpha_numeric( chr, check_underscore = false )
{
	abc = "0123456789abcdefghijklmnopqrstuvwxyz";

	if ( check_underscore )
	{
		abc += "_";
	}
	return isdefined( abc[ tolower( chr ) ] );
}

is_numeric( chr )
{
	abc = "0123456789";

	return isdefined( abc[ tolower( chr ) ] );
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

/*generic_obj_t*/ set_parse_error( generic_obj, error_msg )
{
	generic_obj.errored = true;
	generic_obj.msg = error_msg;

	return generic_obj;
}

/*generic_obj_t*/ set_parse_success( generic_obj, success_msg )
{
	generic_obj.msg = success_msg;

	return generic_obj;
}

set_parse_warning( generic_obj, msg = undefined )
{
	generic_obj.warning = true;
	if ( isdefined( msg ) )
	{
		generic_obj.msg = msg;
	}
	
	return generic_obj;
}

reset_parse_warning( obj )
{
	obj.warning = false;

	return obj;
}

add_parse_array( generic_obj, new_value )
{
	generic_obj.array_tokens[ generic_obj.array_tokens.size ] = new_value;
	return set_parse_success( generic_obj, "array_tokens=" + new_value.size );
}

parse_array( string, generic_obj )
{
	// basic checks
	square_bracket_count = 0;
	square_brackets_match = square_bracket_count == 0;
	str_start = 0;
	str_end = string.size - 1;

	tokens = [];
	if ( string[ str_end ] != "]" )
	{
		// error
		return set_parse_error( generic_obj, "Last character of array wasn't terminated with ']'" );
	}

	// TODO: handle array nesting, requires a struct to store the array depth
	for ( i = 0; i < string.size; i++ )
	{
		if ( string[ i ] == "[" )
		{
			square_bracket_count++; // great now we need another one
		}
		else if ( string[ i ] == "]" )
		{
			square_bracket_count--; // thank god were back to zero
		}
		else if ( string[ i ] == "," )
		{
			str_end = i - 1;
			array_token = getsubstr( string, str_start, str_end );
			add_parse_array( generic_obj, array_token );
			str_start = i + 1;
		}
		else if ( is_alpha_numeric( string[ i ] ) )
		{

		}
		else
		{
			// error
			return set_parse_error( generic_obj, "Cannot use characters other than alnum, '_', '[]', ',' in an array" );
		}

		square_brackets_match = square_bracket_count == 0;
	}

	if ( generic_obj.array_tokens.size <= 0 )
	{
		// error
		return set_parse_error( generic_obj, "Directive array cannot be empty" );
	}

	if ( !square_brackets_match )
	{
		// error
		return set_parse_error( generic_obj, "Directive using unmatched array" );
	}

	return set_parse_success( generic_obj, "array_tokens.size=" + generic_obj.array_tokens.size );
}

set_parse_random_limit( target_parse_obj, new_value )
{
	target_parse_obj.target_values[ 0 ] = new_value;

	if ( int( target_parse_obj.target_values[ 0 ] ) <= 0 )
	{
		return set_target_parse_success( target_parse_obj, "Random target pool limit must be greater than 0" );
	}

	return set_target_parse_success( target_parse_obj, "random_limit=" + new_value );
}

/*func_call_parse_obj_t*/ set_func_call_parse_error( func_call_parse_obj, error_msg )
{
	func_call_parse_obj.errored = true;
	func_call_parse_obj.msg = error_msg;

	return func_call_parse_obj;
}

/*func_call_parse_obj_t*/ set_func_call_parse_success( func_call_parse_obj, success_msg )
{
	func_call_parse_obj.msg = success_msg;

	return func_call_parse_obj;
}

/*func_call_parse_obj_t*/ func_call_parse_obj_t_new( function_name )
{
	func_call_parse_obj = spawnstruct();
	func_call_parse_obj.arg_directives = [];
	func_call_parse_obj.function_name = function_name;

	return func_call_parse_obj;
}

add_func_arg_directive( func_call_parse_obj, arg_directive )
{
	index = func_call_parse_obj.arg_directives.size;
	func_call_parse_obj.arg_directives[ index ] = arg_directive;
	index++;
	
	set_func_call_parse_success( func_call_parse_obj, "arg_directives['" + index + "']=" + arg_directive );
}

parse_function( function_name, call_value )
{
	func_call_parse_obj = func_call_parse_obj_t_new( function_name );
	// basic checks
	str_start = 0;
	str_end = call_value.size - 1;

	tokens = [];
	if ( call_value[ str_end ] != ")" )
	{
		// error
		return set_parse_error( func_call_parse_obj, "Last character of function wasn't terminated with ')'" );
	}

	in_comma = false;
	for ( i = 0; i < call_value.size; i++ )
	{
		switch ( call_value[ i ] )
		{
			case "$":
				add_func_arg_directive( func_call_parse_obj, "$" );
				if ( call_value[ i + 1 ] != "," )
				{
					return set_parse_error( func_call_parse_obj, "$ is a single token arg directive" );
				}

				in_comma = false;
				continue;
		}
		if ( call_value[ i ] == "$" ) // random
		{

		}
		else if ( call_value[ i ] == "!" ) // undefined
		{
			add_func_arg_directive( func_call_parse_obj, "!" );
			if ( call_value[ i + 1 ] != "," )
			{
				return set_parse_error( func_call_parse_obj, "! is a single token arg directive" );
			}

			in_comma = false;
		}
		else if ( call_value[ i ] == "&" ) // the executor, aka self
		{
			add_func_arg_directive( func_call_parse_obj, "&" );
			if ( call_value[ i + 1 ] != "," )
			{
				return set_parse_error( func_call_parse_obj, "& is a single token arg directive" );
			}

			in_comma = false;
		}
		else if ( call_value[ i ] == "#" ) // the default target, configureable by commands
		{
			add_func_arg_directive( func_call_parse_obj, "#" );
			if ( call_value[ i + 1 ] != "," )
			{
				return set_parse_error( func_call_parse_obj, "# is a single token arg directive" );
			}

			in_comma = false;
		}
		else if ( call_value[ i ] == "," || i == ( call_value.size - 1 ) )
		{
			if ( call_value[ i + 1 ] == "," )
			{
				return set_parse_error( func_call_parse_obj, "Arg directive cannot be empty" );
			}

			if ( in_comma )
			{
				str_end = i - 1;
				string = getsubstr( call_value, str_start, str_end );
				add_func_arg_directive( func_call_parse_obj, string );

				in_comma = false;
			}
			else
			{
				str_start = i + 1;
				in_comma = true;
			}
		}
		else if ( is_alpha_numeric( call_value[ i ], true ) )
		{

		}
		else
		{
			// error
			return set_parse_error( func_call_parse_obj, "Cannot use characters other than alnum, '_', ',', '$', '!' in an function call" );
		}
	}

	return set_parse_array( func_call_parse_obj, tokens );
}

parse_target_random( target_string, target_parse_obj )
{
	target_parse_obj.target_type = "random";

	if ( target_string.size <= 1 )
	{
		return set_parse_random_limit( target_parse_obj, "99999" );
	}

	if ( target_string[ i + 1 ] == "[" )
	{
		target_parse_obj.target_type = "explicit_array_random";
		return parse_array( target_string, target_parse_obj );
	}

	str_start = 0;
	str_end = target_string.size - 1;
	for ( i = 0; i < target_string.size; i++ )
	{
		if ( !is_numeric( target_string[ i ] ) )
		{
			return set_parse_error( target_parse_obj, "Random target pool limit must be a number" );
		}
	}

	random_limit = getsubstr( target_string, str_start );
	return set_parse_random_limit( target_parse_obj, random_limit );
}

try_parse_function( string, generic_obj )
{
	str_start = 0;
	function_name = "";
	invalid_for_func_char_count = 0;
	for ( i = 0; i < string.size; i++ )
	{
		if ( is_alpha_numeric( string[ i ], true ) )
		{
			continue;
		}

		if ( string[ i ] == "(" ) // function start
		{
			if ( invalid_for_func_char_count > 0 )
			{
				return set_parse_error( generic_obj, "Function names can only contain alnum, '_', and '('" );
			}
			
			str_end = i - 1;
			function_name = getsubstr( string, str_start, str_end );
			return parse_function( function_name, string );
		}
		else
		{
			invalid_for_func_char_count++;
		}
	}

	return set_parse_warning( generic_obj );
}

try_parse_name( string, generic_obj, str_start = 0, str_end = undefined )
{
	str_start = _DEFAULT( str_start, 0 );
	std_end = _DEFAULT( str_end, string.size );
	invalid_for_name_char_count = 0;
	for ( i = str_start; i < std_end; i++ )
	{
		if ( is_alpha_numeric( string[ i ], true ) )
		{
			continue;
		}

		invalid_for_name_char_count++;
	}

	if ( invalid_for_name_char_count == 0 )
	{
		name = getsubstr( string, str_start, str_end );
		add_parse_array( generic_obj, name );
		return set_parse_success( generic_obj );
	}
	else
	{
		return set_parse_error( generic_obj, "Target names can only contain alnum, and '_'" );
	}
}

set_target_parse_success( target_parse_obj, success_msg )
{
	check_script_error( target_parse_obj, "target_parse" );

	return set_parse_success( target_parse_obj, success_msg );
}

set_target_parse_error( target_parse_obj, error_msg )
{
	check_script_error( target_parse_obj, "target_parse" );

	return set_parse_error( target_parse_obj, error_msg );
}

// target_value is =target_value}
parse_target_value( directive_parse, target_string )
{
	target_parse_obj = target_parse_obj_t_new( "self" );
	directive_parse.directive_value = target_parse_obj;
	first = target_string[ 0 ];

	switch ( first )
	{
		case "*":
			target_parse_obj.target_type = "all";
			if ( target_string.size > 1 )
			{
				return set_parse_error( target_parse_obj, "The 'all' valid targets syntax '*' cannot be used with any other syntax" );
			}

			return set_target_parse_success( target_parse_obj, "target=all" );
		case "!":
			target_parse_obj.target_type = "undefined";
			if ( target_string.size > 1 )
			{
				return set_target_parse_error( target_parse_obj, "The 'undefined' target syntax '!' cannot be used with any other syntax" );
			}

			return set_target_parse_success( target_parse_obj, "target=none" );
		case "$":
			return parse_target_random( target_string, target_parse_obj );
		case "[":
			return parse_array( target_string, target_parse_obj );
		case "&":
			target_parse_obj.target_type = "self"; // explicit self
			if ( target_string.size > 1 )
			{
				return set_parse_error( target_parse_obj, "The 'self' target syntax '&' cannot be used with any other syntax, except as an argument or a member of an array" );
			}

			return set_target_parse_success( target_parse_obj, "target=self" );
		case "#":
			target_parse_obj.target_type = "default"; // the default, and configureable target explicitly specified
			if ( target_string.size > 1 )
			{
				return set_parse_error( target_parse_obj, "The 'default' target syntax '#' cannot be used with any other syntax, except as an argument or a member of an array" );
			}

			return set_target_parse_success( target_parse_obj, "target=default" );
	}

	if ( is_alpha_numeric( first ) )
	{
		// ambiguous, could be function start or a name
		function_call_obj = try_parse_function( target_string, target_parse_obj );
		if ( !function_call_obj.warning && !function_call_obj.errored )
		{
			return function_call_obj;
		}

		reset_parse_warning( target_parse_obj );

		// not a function, no '(' token
		// names can contain a lot of weird characters, but you are better off using the guid/clientnum syntax anyway
		name_token_obj = try_parse_name( target_string, target_parse_obj );
		if ( !name_token_obj.warning && !name_token_obj.errored )
		{
			return name_token_obj;
		}
	}

	return set_parse_error( target_parse_obj, "Unsupported target directive value" );
}

parse_directive( directive_parse, key, value )
{
	switch ( key )
	{
		case "c":
		case "call":
			//parse_call_value( directive_parse, value );
			break;
		case "t":
		case "target":
			directive_parse.directive_type = "target";
			return parse_target_value( directive_parse, value );
		case "e":
		case "executor": // allows you to specify the 'executor' or who
			directive_parse.directive_type = "executor";
			return parse_target_value( directive_parse, value );
		case "script":
			//parse_script_value( directive_parse, value );
			break;
		case "func":
			break;
		case "hook":
			//parse_args_value( directive_parse, value );
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

	return set_cmd_parse_error( directive_parse, "Unsupported directive key '" + key + "'" );
}

parse_directives( cmd_parse, token_str )
{
	// parse directives
	if ( token_str[ 1 ] != "{" )
	{
		//fail, invalid options block start
		return set_cmd_parse_error( cmd_parse, "Invalid directive block start" );
	}

	// just quickly make sure the braces match
	brace_count = 1;
	for ( k = 2; k < token_str.size; k++ )
	{
		switch ( token_str[ k ] )
		{
			case "}":
				brace_count--;
				break;
			case "{":
				brace_count++;
				return set_cmd_parse_error( cmd_parse, "Cannot nest directives" );
		}

		if ( brace_count < 0 )
		{
			return set_cmd_parse_error( cmd_parse, "Cannot nest directives" );
		}
	}

	even_number_of_braces = brace_count == 0;
	if ( !even_number_of_braces )
	{
		//fail, every opening brace must be closed
		return set_cmd_parse_error( cmd_parse, "Directive blocks must be closed" );
	}

	if ( token_str.size == 3 && token_str[ 2 ] == "}" )
	{
		//fail?, or show help? as an empty directives block means that it will do nothing for that target selector; unless this is a way to skip it...
		//no. implementing a "skip" directive makes more sense i.e "skip=1"
		//so fail
		return set_cmd_parse_error( cmd_parse, "Empty directive block isn't allowed" );
	}

	// got past the preparser so we already know it's a little valid

	key_start = 2;
	for ( ;; )
	{
		// parse key
		key_end = key_start;
		while ( key_end < token_str.size )
		{
			if ( token_str[ key_end ] == "=" )
			{
				break;
			}
			if ( !is_alpha_numeric( token_str[ key_end ] ) )
			{
				return set_cmd_parse_error( cmd_parse, "Directive key contains an invalid character" );
			}

			key_end++;
		}

		if ( key_end == token_str.size )
		{
			return set_cmd_parse_error( cmd_parse, "Directives are key value pairs; missing complete key" );
		}

		key = getsubstr( token_str, key_start, key_end );

		// parse value
		value_start = key_end + 1; // start after the '=' token
		value_end = value_start;
		if ( token_str[ value_start ] == "[" ) // start of array
		{
			value_end++;
			while ( token_str[ value_end ] != "]" )
			{
				if ( value_end >= token_str.size )
				{
					return set_cmd_parse_error( cmd_parse, "Missing terminating array ']' token" );
				}

				value_end++; 
			}
		}

		for ( ;; )
		{
			value_end++;

			if ( token_str[ value_end + 1 ] == "}" )
			{
				break; // we don't need to send the closing brace
			}

			if ( token_str[ value_end ] == "," )
			{
				break; // we don't need to send the separating comma
			}

			if ( value_end >= token_str.size )
			{
				return set_cmd_parse_error( cmd_parse, "Missing key value pair terminator '}' or separator ','" );
			}
		}

		value = getsubstr( token_str, value_start, value_end );

		new_directive_parse = directive_parse_obj_t_new();

		new_directive_parse_child = parse_directive( new_directive_parse, key, value );

		if ( new_directive_parse_child.errored )
		{
			return set_cmd_parse_error( cmd_parse, new_directive_parse_child.msg );
		}
	}
		// so everything is a key value pair, or key=<val>, where key is a primitive string followed by exactly "=" and then a formatted value
		// values will only be alphanumeric, "_", "[,]", "(,)"
		// it's supposed to be quick and simple, and if you really need to extend the logic you use the function syntax to call a function manually
		// since the command system is highly implicit you need to manually define the typing for any arbitrary function you want to call first
		// the first argument to any script method call is the entity, and if it's skipped i.e some_func(,arg2,arg3), then it uses level by default if the function definition allows it
		// since gsc isn't strictly typed there isn't any way to know what types a function expects other than how it uses them
		// however by defining the type definitions manually and defining cast functions for each type you can actually pass arbitrary string arguments to a function and it will be appropriately casted
		// in my system passing "0" to a command that expects an entity will resolve to the 0th entity or generally the first player aka host
		// we can add a directive to allow casting each argument manually and then use getfunction to call the function
		// so the directive format would be something like this some_func(@{script=maps/mp/zombies/_some_script,types=[player,string,entity]})

		// some of the global keys:
		// func_obj_t call - call function, function uses function context and global keys
		// string script - defines the current working script for call keys
		// types_kvp_t types - defines the types for each function argument as an int indexed array
		// hook_obj_t hook - invokes replacefunc on a function to cause successive calls to go to your code
		// hook=[replace=,func=[script=,types=,name=some_func],print_args=,] // to allow generic, arbitrary, runtime detours I believe you must detour to a function with exactly the same number of arguments as the function you are detouring
		// unhook=some_func
		// bool print_args - by applying the argument rules for a hook you can print the arguments
		// bool persist - causes the hook to be persisted
		// bool nullsub - hooked function will do nothing instead of the original logic
		// target_obj_t target - target(s) for the command to execute on
		// executor_obj_t executor - executor(s) for the command to be executed by

		// call context keys:
		// in the types key each argument can be accessed explicitly by the ordinal integer
		// the rules for arguments ordinals are the following:
		// -1 = rettype
		// 0 = caller
		// > 0 = arguments
		
		// calling a function example:
		// @{call=[func=some_func(hello world,79,[4,80,1003]),script=scripts/cmd_system_modules/_test,types=[0="",1=string,2=int,3=vector]]}
		// special tokens:
		// $ can be use to generate a random valid value for the type like this

		// new rule:
		// we evaluate @{} as we parse them in defined sequential order
		// [] is evaluated as the arguments for a directive
}

parse_arg( arg_parse_obj, token_str, cmd_parse )
{
	arg_parse_obj.arg = token_str;
}

// Special target syntax for players/entities:
// @{*} - if the argument expects a player/entity, execute on all of them
// @{playername1,playername2} - execute only on these players
// certain reserved syntaxes also apply:
// @{[team=allies&classname=player]} - only execute on <team> AND <classname>
// @{[team=axis|classname=player]} - execute on <team> OR <classname>
// @{[target=self]} - manually set the target to an entity in this case self or the executor, default behavior; if server is executing they must specify the target
// @{$39} - pick random targets up to $<x> from possible pool of targets, <x> defaults to 1
// @{$[team=allies&classname=player]} - pick one random target matching the criteria
// %{player} - forces this player to be the executor of the command as if they typed the command in the chat
// @{(some_func(arg1,arg2,arg3))} - execute a script function to retrieve targets

// TLDR;
// @{} - by itself represents targets of the command
// %{} - represents executors of the command
// {*} - all possible targets
// {$<x>} - of all possible targets randomly pick them up to <x>
// you can specify both the executor and targets syntax since they have different enough syntax
// ! - null argument

// Refined syntax:
// @{} - defines a directives or options block
// @{target=*} - defines the first target argument as all
// @{target=self} - defines the first target argument as self or the executor(default behavior)
// @{target=[player1,player2]} - defines the first target argument as <player1> and <player2>
// @{target=[]}
// @{target=some_func(arg1,arg2,arg3)} - useful for casting an origin(vector) to a target
// [x,y,z] - vector syntax
// ? - wildcard token for vectors
// since we must define all keys explicitly we don't need to worry about user defined keys, which means certain kinds of syntax can be simplified to be implicit(vector parsing)

/*void*/ add_cmd_parse_directive( cmd_parse_obj, new_directive_key, new_directive_value )
{
	if ( !cmd_parse_obj.directive_kvps[ new_directive_key ] )
	{
		cmd_parse_obj.directive_kvps[ new_directive_key ] = new_directive_value;
	}
}

/*cmd_parse_obj_t*/ set_cmd_parse_success( cmd_parse_obj, success_msg )
{
	check_script_error( cmd_parse_obj, "cmd_parse" );

	cmd_parse_obj.msg = success_msg;
	return cmd_parse_obj;
}

/*cmd_parse_obj_t*/ set_cmd_parse_error( cmd_parse_obj, error_msg )
{
	check_script_error( cmd_parse_obj, "cmd_parse" );

	cmd_parse_obj.msg = error_msg;
	cmd_parse_obj.errored = true;
	return cmd_parse_obj;
}

/*void*/ check_target_parse_script_error( target_parse_obj, new_value )
{
	force_error = false;
	check_script_error( target_parse_obj, "target_parse" );
}

/*void*/ add_target_parse_value( target_parse_obj, new_value )
{
	check_target_parse_script_error( target_parse_obj, new_value );

	target_parse_obj.target_values[ target_parse_obj.target_values.size ] = new_value;
}

/*target_parse_obj_t*/ target_parse_obj_t_new( target_type )
{
	target_parse_obj = generic_obj_t_new( "target_parse" );
	target_parse_obj.target_type = target_type;
	target_parse_obj.target_values = []; // if type is array, index > 0 is used, otherwise only index 0 is
	return target_parse_obj;
}

/*arg_parse_obj_t*/ arg_parse_obj_t_new()
{
	arg_parse_obj = generic_obj_t_new( "arg_parse" );
	arg_parse_obj.arg = "";
	return arg_parse_obj;
}

/*directive_parse_obj_t*/ directive_parse_obj_t_new()
{
	directive_parse_obj = generic_obj_t_new( "directive_parse" );
	directive_parse_obj.directive_type = "none";
	directive_parse_obj.directive_value = undefined; // type determines what data the directive_value struct holds
	return directive_parse_obj;
}

/*cmd_parse_obj_t*/ cmd_parse_obj_t_new()
{
	cmd_parse_obj = generic_obj_t_new( "cmd_parse" );
	cmd_parse_obj.directive_kvps = []; // string -> directive_parse_obj_t, example: "target=$2" is equivalent to .directive_kvps[ "target" ] = <parsed_val>
	cmd_parse_obj.args = []; // index -> arg_parse_obj_t
	cmd_parse_obj.cmd_name = "";
	cmd_parse_obj.start_pos = 0;
	cmd_parse_obj.end_pos = 0;
	return cmd_parse_obj;
}

/*cmd_parse_obj_array_t*/ cmd_parse_obj_array_t_new()
{
	cmd_parse_obj = generic_obj_t_new( "cmd_parse_array" );
	cmd_parse_obj.cmds = []; // string -> cmd_parse_obj_t
	return cmd_parse_obj;
}

// by convention the following are true:
// the command to be executed is the first alnum + '_' string encountered; therefore it can be before or after any '@' directives
// directives '@' can appear in any order in the string
// spaces can now be used within directives, functions and arrays; otherwise it would not be possible to 
custom_split( str )
{
	tokens = [];

	in_array = 0;
	in_directive = 0;
	in_func_call = 0;

	split_start = 0;
	split_end = split_start;
	for ( i = 0; i < str.size; i++ )
	{
		if ( str[ i ] == "[" )
		{
			in_array++;
		}
		else if ( str[ i ] == "{" )
		{
			in_directive++;
		}
		else if ( str[ i ] == "(" )
		{
			in_func_call++;
		}
		else if ( str[ i ] == "]" )
		{
			in_array--;
		}
		else if ( str[ i ] == "}" )
		{
			in_directive--;
		}
		else if ( str[ i ] == ")" )
		{
			in_func_call--;
		}
		else if ( str[ i ] == " " )
		{
			if ( in_array == 0 && in_directive == 0 && in_func_call == 0 )
			{
				tokens[ tokens.size ] = getsubstr( str, split_start, split_end );
				split_start = split_end;
			}
		}

		split_end++;
	}

	if ( tokens.size == 0 )
	{
		tokens[ 0 ] = str;
	}

	return tokens;
}

// Last command token to execute the last command implicitly
// this function is threaded, but threading is not allowed inside of it
/*cmd_parse_obj_array_t*/ parse_cmd_message( message )
{
	cmd_parse_array = cmd_parse_obj_array_t_new();
	if ( message == "" )
	{
		return set_cmd_parse_error( cmd_parse_array, "Command string is empty" );
	}

	//Strip cmd tokens.
	stripped_message = message;
	if ( is_cmd_token( message[ 0 ] ) )
	{
		stripped_message = "";
		for ( i = 1; i < message.size; i++ )
		{
			stripped_message += message[ i ];
		}
	}

	target_parse_obj = _DEFAULT( target_parse_obj, target_parse_obj_t_new() );
	multiple_cmds_keys = strtok( stripped_message, "^" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_string = custom_split( multiple_cmds_keys[ i ] );
		cmd_find_result = scripts\cmd_system_modules\_cmd_arg::get_cmd_from_alias( cmd_string[ 0 ] );
		if ( cmd_find_result.errored )
		{
			return set_cmd_parse_error( cmd_parse_array, "Command: '" + cmd_find_result.value + " doesn't exist" );
		}

		new_cmd_parse = cmd_parse_obj_t_new();
		new_cmd_parse.cmd_name = cmd_find_result.value;

		start_pos = 0;
		end_pos = cmd_string[ 1 ].size;
		for ( j = 1; j < cmd_string.size; j++ )
		{
			// "@" should be a variable; it should be configureable
			if ( cmd_string[ j ][ start_pos ] == "@" )
			{
				if ( cmd_string[ j ].size < 3 )
				{
					//fail, must be at least 3 characters to be at least somewhat valid "@{}"
					return set_cmd_parse_error( cmd_parse_array, "Directive must be at least '@{}'" );
				}

				parse_check_obj = parse_directives( new_cmd_parse, cmd_string[ j ] );
				if ( parse_check_obj.errored )
				{
					return set_cmd_parse_error( cmd_parse_array, parse_check_obj.msg );
				}
			}
			else
			{
				new_arg_parse = arg_parse_obj_t_new();

				parse_check_obj = parse_arg( new_arg_parse, cmd_string[ j ], new_cmd_parse );
				if ( parse_check_obj.errored )
				{
					return set_cmd_parse_error( cmd_parse_array, parse_check_obj.msg );
				}

				new_cmd_parse.args[ new_cmd_parse.args.size ] = new_arg_parse;
			}

			start_pos = new_cmd_parse.start_pos;
			end_pos = new_cmd_parse.end_pos;
		}
		
		cmd_parse_array.cmds[ cmd_find_result.value ] = new_cmd_parse;
	}

	return set_cmd_parse_success( cmd_parse_array, "" );
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
		}
	}
}

/*target_parse_obj_t*/ target_parse_obj_t_new( target_type )
{
	target_parse_obj = generic_obj_t_new( "target_parse" );
	target_parse_obj.target_type = target_type;
	target_parse_obj.target_values = []; // if type is array, index > 0 is used, otherwise only index 0 is
	return target_parse_obj;
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
	else if ( self.obj_type == "target_parse" )
	{
		print_entity com_printinfo( self.target_type );
		foreach ( key, value in self.target_values )
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

set_execute_error()
{

}

set_execute_success()
{

}

check_command_syntax_used( local_id, message, is_hidden )
{
	if ( !level.tcs_glob.bhidden_cmds && is_hidden )
	{
		self com_printerror( "Hidden cmds are not allowed" );
		self notify( "cmd_execute_" + local_id );
	}
	else if ( !is_hidden && !is_cmd_token( message[ 0 ] ) )
	{
		self notify( "cmd_execute_" + local_id );
	}
}

check_command_cooldown()
{
	channel = self com_get_cmd_feedback_channel();
	if ( isDefined( self.cmd_cooldown ) && self.cmd_cooldown > 0 )
	{
		self com_printerror( "You cannot use another cmd for " + self.cmd_cooldown + " seconds" );
		self notify( "cmd_execute_" + local_id );
	}
}

check_multi_commands( local_id, cmd_parse_obj )
{
	if ( cmd_parse_obj.cmds.size > 1 && !self scripts\cmd_system_modules\_perms::can_use_multi_cmds() )
	{
		self com_printwarning( "You do not have permission to use multi cmds" );
		self notify( "cmd_execute_" + local_id );
	}
}

handle_feedback()
{
	while ( isdefined( self ) && isdefined( self.initiator ) && !self.errored )
	{
		self waittill_any_return( "" );
	}
}

cmd_execute( message, initiator, is_hidden, is_team_chat, from_rcon )
{
	if ( !isdefined( intiator.cmd_execute_id ) )
	{
		initiator.cmd_execute_id = 0;
	}
	if ( isplayer( initiator ) )
	{
		initiator endon( "disconnect" );
	}

	cmd_execute_thread = generic_obj_t_new( "cmd_execute" );
	cmd_execute_thread.id = initiator.cmd_execute_id;
	cmd_execute_thread.owner = initiator;
	cmd_execute_thread.name = "cmd_execute";
	cmd_execute_thread thread handle_feedback();

	local_id = initiator.cmd_execute_id;
	cmd_execute_thread endon( "cmd_execute_" + local_id + "_abort" );
	initiator.cmd_execute_id++;

	from_rcon = message[ 0 ] == "~" && ( initiator == level.server || initiator == level.host );
	has_all_perms = from_rcon || ( initiator == level.server || initiator == level.host );
	message = getsubstr( message, 1 ); // remove '~' character which indicates rcon

	if ( !has_all_perms )
	{
		cmd_execute_thread check_command_syntax_used( local_id, message, is_hidden );
		cmd_execute_thread check_command_cooldown( local_id );
	}

	message = tolower( message );
	cmd_parse_obj = parse_cmd_message( message );
	add_obj_ref( cmd_execute_thread, cmd_parse_obj );
	if ( cmd_parse_obj.errored )
	{
		initiator com_printerror( cmd_parse_obj.msg );
		return;
	}

	if ( !has_all_perms )
	{
		cmd_execute_thread check_multi_commands( )
	}

	for ( cmd_index = 0; cmd_index < cmd_parse_obj.size; cmd_index++ )
	{
		cmd_obj = multi_cmds[ cmd_index ][ "cmd_obj" ]; // The command definition
		arg_obj = multi_cmds[ cmd_index ][ "args_obj" ]; // Plain arguments
		target_obj = multi_cmds[ cmd_index ][ "target_obj" ]; // Potentially multi-dimensional array of targets to execute the command on
		executor_obj = multi_cmds[ cmd_index ][ "executor_obj" ]; // Single dimension array of players/level.server to execute the command from

		if ( !array_validate( executor_obj.executors ) )
		{
			executor_obj.executors[ executor_obj.executors.size ] = initiator.default_executor;
		}

		if ( !array_validate( target_obj.targets ) )
		{
			target_obj.targets[ target_obj.targets.size ] = initiator.default_target;
		}

		for ( executor_index = 0; executor_index < executor_obj.executors.size; excutor_index++ )
		{
			executor = executor_obj.executors[ executor_index ];

			if ( executor != initiator && !initiator scripts\cmd_system_modules\_perms::has_permission_for_executor_syntax() && !is_true( from_rcon ) )
			{
				initiator com_printerror( "You do not have permission to use executor syntax!" );
				break;
			}

			if ( !initiator scripts\cmd_system_modules\_perms::has_permission_for_cmd( cmd_obj.cmd_name ) && !is_true( from_rcon ) )
			{
				initiator com_printerror( "You do not have permission to use " + cmd_obj.cmd_name + " cmd" );
				break;
			}

			initiator.tcs_silent_cmds = getdvarintdefault( "tcs_silent_cmds", 0 );
			initiator.tcs_logprint_cmd_usage = getdvarintdefault( "tcs_logprint_cmd_usage", 1 );
			initiator.tcs_feedback_mode = 2; // 0 == executor receives cmd feedback, 1 == initiator receives cmd feedback, 2 == initiator and executor receives cmd feedback
			executor cmd_execute_internal( initiator, cmd_obj, arg_obj, target_obj );
		}
	}

	if ( !has_all_perms )
	{
		initiator thread cmd_cooldown();
	}
}

cmd_execute_internal( initiator, cmd_obj, arg_obj, target_obj )
{
	if ( !initiator scripts\cmd_system_modules\_cmd_arg::test_cmd_is_valid( cmd_obj, arg_obj, target_obj ) )
	{
		return;
	}

	// Cast the args using the cast handlers
	// Arg types without a cast handler don't get casted
	// Leaving the casting up to the cmd itself
	if ( array_validate( arg_obj.args ) && array_validate( cmd_obj.arg_types ) )
	{
		for ( i = 0; i < arg_obj.args.size; i++ )
		{
			arg = arg_obj.args[ i ];
			arg_type = cmd_obj.arg_types[ i ];
			cast_result = initiator arg_cast( arg_type, arg, i );
			if ( cast_result.errored )
			{
				initiator com_printerror( cast_result.msg );
				return;
			}
			else
			{
				arg_obj.casted_args[ i ] = cast_result.value;
			}
		}
	}

	if ( array_validate( target_obj.targets ) && array_validate( cmd_obj.target_types ) )
	{
		target_types = cmd_obj.target_types;
		for ( i = 0; i < arg_obj.args.size; i++ )
		{
			target = arg_obj.targets[ i ];
			target_type = cmd_obj.target_types[ i ];
			cast_result = initiator target_cast( target_type, target, i );
			if ( cast_result.errored )
			{
				initiator com_printerror( cast_result.msg );
				return;
			}
			else
			{
				target_obj.casted_targets[ i ] = cast_result.value;
			}
		}
	}

	result = self [[ cmd_obj.func ]]( arg_obj );

	self handle_result_feedback( initiator, result, cmd_obj.cmd_name, arg_obj );
}

handle_result_feedback( initiator, result, cmd_name, arg_obj )
{
	if ( is_true( initiator.tcs_logprint_cmd_usage ) && !is_true( level.doing_cmd_system_unittest ) )
	{
		cmd_log = "";
		if ( self != initiator )
		{
			cmd_log = initiator.name + " executed " + cmd_name + " on behalf of " + self.name + " with args " + repackage_args( arg_obj.str_args );
		}
		else
		{
			cmd_log = initiator.name + " executed " + cmd_name + " with args " + repackage_args( arg_obj.str_args );
		}
		
		level com_printf( "g_log", "cmdinfo", cmd_log );
	}
	if ( !isDefined( result ) || is_true( initiator.tcs_silent_cmds ) )
	{
		return;
	}
	if ( !isDefined( result.filter ) || result.filter == "" )
	{
		level com_printf( "con|g_log", "screrror", "Attempted to print feedback for " + cmd_name + " but no filter exists in the result" );
		return;
	}
	if ( !isDefined( result.msg ) )
	{
		level com_printf( "con|g_log", "screrror", "Attempted to print feedback for " + cmd_name + " but no message exists in the result" );
		return;
	}
	if ( result.msg == "" )
	{
		return;
	}

	executor_channel = self com_get_cmd_feedback_channel();
	if ( result.channels != "" )
	{
		executor_channel = result.channels;
	}

	initiator_channel = initiator com_get_cmd_feedback_channel();
	if ( result.channels != "" )
	{
		initiator_channel = result.channels;
	}

	if ( initiator.tcs_feedback_mode == 2 )
	{
		if ( initiator != self )
		{
			level com_printf( initiator_channel, result.filter, result.msg, initiator );
		}
		
		level com_printf( executor_channel, result.filter, result.msg, self );
	}
	else if ( intiator.tcs_feedback_mode == 1 )
	{
		level com_printf( initiator_channel, result.filter, result.msg, initiator );
	}
	else if ( initiator.tcs_feedback_mode == 0 )
	{
		level com_printf( executor_channel, result.filter, result.msg, self );
	}
}

scr_dvar_cmd_watcher()
{
	setDvar( "tcscmd", "" );
	while ( true )
	{
		parse_cmd_dvar();
		wait 0.05;
	}
}

parse_cmd_dvar()
{
	dvar_value = getdvar( "tcscmd" );
	if ( dvar_value != "" )
	{
		setDvar( "tcscmd", "" );
		dvar_value = "~" + dvar_value; // special token to indicate that it's from the dvar
		waittillframeend; // prevents notifies from being dropped if they happen in the same frame
		if ( isdedicated() )
		{
			// there is no local client, so the server will always need to specify an executor/target, unless they specify the default_target and default_executor
			level notify( "say", dvar_value, level.server, true, false );
		}
		else
		{
			level notify( "say", dvar_value, level.host, true, false );
		}
	}
}