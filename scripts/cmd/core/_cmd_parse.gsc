#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

/*generic_obj_t*/ private set_parse_success( generic_obj, success_msg = "" )
{
	generic_obj.msg = success_msg;

	return generic_obj;
}

private set_parse_warning( generic_obj, msg = undefined )
{
	generic_obj.warning = true;
	if ( isdefined( msg ) )
	{
		generic_obj.msg = msg;
	}
	
	return generic_obj;
}

private reset_parse_warning( obj )
{
	obj.warning = false;

	return obj;
}

private parse_array( string, generic_obj )
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
		throw_exception( "Last character of array wasn't terminated with ']'", generic_obj );
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
			generic_obj add_token( array_token );
			str_start = i + 1;
		}
		else if ( is_alpha_numeric( string[ i ] ) )
		{

		}
		else
		{
			// error
			throw_exception( "Cannot use characters other than alnum, '_', '[]', ',' in an array", generic_obj );
		}

		square_brackets_match = square_bracket_count == 0;
	}

	if ( generic_obj.token_values.size <= 0 )
	{
		// error
		throw_exception( "Directive array cannot be empty", generic_obj );
	}

	if ( !square_brackets_match )
	{
		// error
		throw_exception( "Directive using unmatched array", generic_obj );
	}

	return set_parse_success( generic_obj, "token_values.size=" + generic_obj.token_values.size );
}

private set_parse_random_limit( token_parse_obj, new_value )
{
	token_parse_obj.target_values[ 0 ] = new_value;

	if ( int( token_parse_obj.target_values[ 0 ] ) <= 0 )
	{
		return set_parse_success( token_parse_obj, "Random target pool limit must be greater than 0" );
	}

	return set_parse_success( token_parse_obj, "random_limit=" + new_value );
}

/*func_call_parse_obj_t*/ private func_call_parse_obj_t_new( function_name )
{
	func_call_parse_obj = spawnstruct();
	func_call_parse_obj.arg_directives = [];
	func_call_parse_obj.function_name = function_name;

	return func_call_parse_obj;
}

// structure of a function:
// 0 - function_name
// 1 - function caller, use undefined for no caller
// >1 - arguments
private parse_function( generic_obj, call_value )
{
	// basic checks
	str_start = 0;
	str_end = call_value.size - 1;

	tokens = [];
	if ( call_value[ str_end ] != ")" )
	{
		// error
		throw_exception( "Last character of function wasn't terminated with ')'", generic_obj );
	}

	in_comma = false;
	for ( i = 0; i < call_value.size; i++ )
	{
		switch ( call_value[ i ] )
		{
			case "$":
				generic_obj add_token( "random" );
				if ( call_value[ i + 1 ] != "," )
				{
					throw_exception( "$ is a single token arg directive", generic_obj );
				}

				in_comma = false;
				continue;
			case "!":
				generic_obj add_token( "undefined" );
				if ( call_value[ i + 1 ] != "," )
				{
					throw_exception( "! is a single token arg directive", generic_obj );
				}

				in_comma = false;
				continue;
			case "&":
				generic_obj add_token( "self" );
				if ( call_value[ i + 1 ] != "," )
				{
					throw_exception( "& is a single token arg directive", generic_obj );
				}

				in_comma = false;
				continue;
			case "#":
				generic_obj add_token( "default" );
				if ( call_value[ i + 1 ] != "," )
				{
					throw_exception( "# is a single token arg directive", generic_obj );
				}

				in_comma = false;
				continue;
		}

		if ( call_value[ i ] == "," || i == ( call_value.size - 1 ) )
		{
			if ( call_value[ i + 1 ] == "," )
			{
				throw_exception( "Arg directive cannot be empty", generic_obj );
			}

			if ( in_comma )
			{
				str_end = i - 1;
				string = getsubstr( call_value, str_start, str_end );
				generic_obj add_token( string );

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
			throw_exception( "Cannot use characters other than alnum, '_', ',', '$', '!', '&', '#' in an function call", generic_obj );
		}
	}

	return set_parse_success( generic_obj );
}

private parse_target_random( target_string, token_parse_obj )
{
	token_parse_obj.token_type = "random";

	if ( target_string.size <= 1 )
	{
		return set_parse_random_limit( token_parse_obj, "99999" );
	}

	if ( target_string[ i + 1 ] == "[" )
	{
		token_parse_obj.token_type = "array_random";
		return parse_array( target_string, token_parse_obj );
	}

	str_start = 0;
	str_end = target_string.size - 1;
	for ( i = 0; i < target_string.size; i++ )
	{
		if ( !is_numeric( target_string[ i ] ) )
		{
			throw_exception( "Random target pool limit must be a number", token_parse_obj );
		}
	}

	random_limit = getsubstr( target_string, str_start );
	return set_parse_random_limit( token_parse_obj, random_limit );
}

private try_parse_function( string, generic_obj )
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
				throw_exception( "Function names can only contain alnum, '_', and '('", generic_obj );
			}
			
			str_end = i - 1;
			function_name = getsubstr( string, str_start, str_end );
			generic_obj.token_type = "function";
			generic_obj add_token( function_name );
			return parse_function( generic_obj, string );
		}
		else
		{
			invalid_for_func_char_count++;
		}
	}

	return set_parse_warning( generic_obj );
}

private try_parse_name( string, generic_obj, str_start = 0, str_end = undefined )
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
		generic_obj.token_type = "identifier";
		generic_obj add_token( name );
		return set_parse_success( generic_obj );
	}
	else
	{
		throw_exception( "Target names can only contain alnum, and '_'", generic_obj );
	}
}

private parse_target_value( target_string )
{
	token_parse_obj = token_parse_obj_t_new( "unassigned" );
	first = target_string[ 0 ];

	// basic tokens
	switch ( first )
	{
		case "*":
			token_parse_obj.token_type = "all";
			break;
		case "!":
			token_parse_obj.token_type = "undefined";
			break;
		case "&":
			token_parse_obj.token_type = "self"; // explicit self
			break;
		case "#":
			token_parse_obj.token_type = "default"; // the default, and configureable target explicitly specified
			break;
	}

	if ( token_parse_obj.token_type != "unassigned" )
	{
		if ( target_string.size > 1 )
		{
			throw_exception( "The '" + token_parse_obj.token_type + "' valid targets syntax '" + first + "' cannot be used with any other syntax as the first element", token_parse_obj );
		}

		return set_parse_success( token_parse_obj, "target=" + token_parse_obj.token_type );
	}

	// array and random
	switch ( first )
	{
		case "$":
			return parse_target_random( target_string, token_parse_obj );
		case "[":
			token_parse_obj.token_type = "array";
			return parse_array( target_string, token_parse_obj );
	}

	// function and name(identifier)
	if ( is_alpha_numeric( first ) )
	{
		// ambiguous, could be function start or a name
		function_call_obj = try_parse_function( target_string, token_parse_obj );
		if ( !function_call_obj.warning )
		{
			return function_call_obj;
		}

		reset_parse_warning( token_parse_obj );

		// not a function, no '(' token
		// names can contain a lot of weird characters, but you are better off using the guid/clientnum syntax anyway
		name_token_obj = try_parse_name( target_string, token_parse_obj );
		return name_token_obj;
	}

	throw_exception( "Unsupported target directive value", token_parse_obj );
}

private parse_directive( cmd_parse, key_type, ordinal_argument, value )
{
	if ( key_type[ 0 ] == "t" || issubstr( key_type, "target" ) )
	{
		directive_value = parse_target_value( value );
		return directive_parse_obj_t_new( "target", directive_value, ordinal_argument );
	}
	else if ( key_type[ 0 ] == "e" || issubstr( key_type, "executor" ) ) // allows you to specify the 'executor' or who executes the command
	{
		directive_value = parse_target_value( value );
		return directive_parse_obj_t_new( "executor", directive_value, ordinal_argument );
	}
	directive_value = undefined;
	switch ( key_type )
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

	throw_exception( "Unsupported directive key '" + key_type + "'", cmd_parse );
}

private parse_directives( cmd_parse, token_str )
{
	// parse directives
	if ( token_str[ 1 ] != "{" )
	{
		//fail, invalid options block start
		throw_exception( "Invalid directive block start", cmd_parse );
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
				throw_exception( "Cannot nest directives", cmd_parse );
		}

		if ( brace_count < 0 )
		{
			throw_exception( "Too many closing braces", cmd_parse );
		}
	}

	even_number_of_braces = brace_count == 0;
	if ( !even_number_of_braces )
	{
		//fail, every opening brace must be closed
		throw_exception( "Directive blocks must be closed", cmd_parse );
	}

	if ( token_str.size == 3 && token_str[ 2 ] == "}" )
	{
		//fail?, or show help? as an empty directives block means that it will do nothing for that target selector; unless this is a way to skip it...
		//no. implementing a "skip" directive makes more sense i.e "skip=1"
		//so fail
		throw_exception( "Empty directive block isn't allowed", cmd_parse );
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
				throw_exception( "Directive key contains an invalid character", cmd_parse );
			}

			key_end++;
		}

		if ( key_end == token_str.size )
		{
			throw_exception( "Directives are key value pairs; missing complete key", cmd_parse );
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
					throw_exception( "Missing terminating array ']' token", cmd_parse );
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
				throw_exception( "Missing key value pair terminator '}' or separator ','", cmd_parse );
			}
		}

		value = getsubstr( token_str, value_start, value_end );

		key_type = key;
		ordinal_argument = int( key[ key.size - 1 ] );
		if ( ordinal_argument > 0 )
		{
			key_type = getsubstr( key, 0, key.size - 1 );
		}

		if ( !isdefined( cmd_parse.directive_kvps[ key_type ] ) )
		{
			cmd_parse.directive_kvps[ key_type ] = [];
		}
		cmd_parse.directive_kvps[ key_type ][ cmd_parse.directive_kvps[ key_type ].size ] = parse_directive( cmd_parse, key_type, ordinal_argument, value );
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

private add_token( value )
{
	self.token_values[ self.token_values.size ] = value;
}

/*token_parse_obj_t*/ private token_parse_obj_t_new( token_type )
{
	token_parse_obj = generic_obj_t_new( "token_parse" );
	token_parse_obj.token_type = token_type;
	token_parse_obj.token_values = []; // if type is array, index > 0 is used, otherwise only index 0 is
	return token_parse_obj;
}

/*directive_parse_obj_t*/ private directive_parse_obj_t_new( directive_type, directive_value, directive_ordinal )
{
	directive_parse_obj = generic_obj_t_new( "directive_parse" );
	directive_parse_obj.directive_type = directive_type;
	directive_parse_obj.directive_value = directive_value; // type determines what data the directive_value struct holds
	directive_parse_obj.directive_ordinal = directive_ordinal; // specifies which key is to be used for which target argument
	directive_parse_obj.is_default = false;
	return directive_parse_obj;
}

/*cmd_parse_obj_t*/ private cmd_parse_obj_t_new( cmd_string )
{
	cmd_parse_obj = generic_obj_t_new( "cmd_parse" );
	cmd_parse_obj.directive_kvps = []; // string -> array[ directive_parse_obj_t ]
	cmd_parse_obj.args = []; // index -> string
	cmd_parse_obj.cmd_name = "";
	cmd_parse_obj.start_pos = 0;
	cmd_parse_obj.end_pos = 0;
	cmd_parse_obj.cmd_string = cmd_string;
	return cmd_parse_obj;
}

/*cmd_parse_obj_array_t*/ private cmd_parse_obj_array_t_new()
{
	cmd_parse_obj = generic_obj_t_new( "cmd_parse_array" );
	cmd_parse_obj.cmds = []; // string -> cmd_parse_obj_t
	return cmd_parse_obj;
}

// by convention the following are true:
// the command to be executed is the first alnum + '_' string encountered; therefore it can be before or after any '@' directives
// directives '@' can appear in any order in the string
// spaces can now be used within directives, functions and arrays; otherwise it would not be possible to 
private custom_split( str )
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
/*cmd_parse_obj_array_t export*/ parse_cmd_message( message )
{
	cmd_parse_array = cmd_parse_obj_array_t_new();
	if ( message == "" )
	{
		throw_exception( "Command string is empty", cmd_parse_array );
	}

	//Strip cmd tokens.
	stripped_message = message;
	if ( is_cmd_token( message[ 0 ] ) )
	{
		stripped_message = getsubstr( message, 1 );
	}

	multiple_cmds_keys = strtok( stripped_message, "^" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_string = custom_split( multiple_cmds_keys[ i ] );
		cmd_find_result = cast_str_to_cmd( cmd_string[ 0 ] );
		if ( cmd_find_result.errored )
		{
			throw_exception( cmd_find_result.msg, cmd_parse_array );
		}

		new_cmd_parse = cmd_parse_obj_t_new( cmd_string );
		new_cmd_parse.cmd_name = cmd_find_result.value.cmd_name;

		start_pos = 0;
		//end_pos = cmd_string[ 1 ].size;
		for ( j = 1; j < cmd_string.size; j++ )
		{
			// "@" should be a variable; it should be configureable
			if ( cmd_string[ j ][ start_pos ] == "@" )
			{
				if ( cmd_string[ j ].size < 3 )
				{
					//fail, must be at least 3 characters to be at least somewhat valid "@{}"
					throw_exception( "Directive must be at least '@{}'", cmd_parse_array );
				}

				parse_check_obj = parse_directives( new_cmd_parse, cmd_string[ j ] );
				if ( parse_check_obj.errored )
				{
					throw_exception( parse_check_obj.msg, cmd_parse_array );
				}
			}
			else
			{
				new_cmd_parse.args[ new_cmd_parse.args.size ] = cmd_string[ j ];
			}

			start_pos = new_cmd_parse.start_pos;
			end_pos = new_cmd_parse.end_pos;
		}

		// set default as the executor
		if ( !isdefined( new_cmd_parse.directive_kvps[ "executor" ] ) )
		{
			token_obj = token_parse_obj_t_new( "default" );
			executor_directive = directive_parse_obj_t_new( "executor", token_obj, 1 );
			executor_directive.is_default = true;
			new_cmd_parse.directive_kvps[ "executor" ] = [];
			new_cmd_parse.directive_kvps[ "executor" ][ new_cmd_parse.directive_kvps[ "executor" ].size ] = executor_directive;
		}

		// set default as the target
		if ( !isdefined( new_cmd_parse.directive_kvps[ "target" ] ) )
		{
			token_obj = token_parse_obj_t_new( "default" );
			target_directive = directive_parse_obj_t_new( "target", token_obj, 1 );
			target_directive.is_default = true;
			new_cmd_parse.directive_kvps[ "target" ] = [];
			new_cmd_parse.directive_kvps[ "target" ][ new_cmd_parse.directive_kvps[ "target" ].size ] = target_directive;
		}

		cmd_parse_array.cmds[ new_cmd_parse.cmd_name ] = new_cmd_parse;
		
		if ( new_cmd_parse.directive_kvps[ "executor" ].directive_value.token_type == "undefined" )
		{
			throw_exception( "Executor cannot be 'undefined'", cmd_parse_array );
		}
	}

	return set_parse_success( cmd_parse_array );
}