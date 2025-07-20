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

private parse_array( token_parse )
{
	token_parse.start_pos++; // skip '['
	// basic checks

	tokens = [];
	if ( token_parse.str[ token_parse.str.size - 1 ] != "]" )
	{
		// error
		throw_exception( "Last character of array wasn't terminated with ']'", token_parse );
	}

	token_parse.str = getsubstr( token_parse.str, token_parse.start_pos, token_parse.str.size - 1 );
	token_parse.start_pos = 0;

	for ( ;; )
	{
		if ( token_parse.start_pos >= token_parse.str.size )
		{
			break;
		}

		// parse value
		value = parse_value( token_parse );
		token_parse add_token( "array", value );
		token_parse.start_pos = token_parse.end_pos;
	}

	if ( token_parse get_token_count() <= 0 )
	{
		// error
		throw_exception( "Directive array cannot be empty", token_parse );
	}

	return set_parse_success( token_parse, "tokens.size==" + get_token_count() );
}

private set_parse_random_limit( token_parse, new_value )
{
	token_parse.target_values[ 0 ] = new_value;

	if ( int( token_parse.target_values[ 0 ] ) <= 0 )
	{
		return set_parse_success( token_parse, "Random target pool limit must be greater than 0" );
	}

	return set_parse_success( token_parse, "random_limit=" + new_value );
}

// structure of a function:
// 0 - function_name
// 1 - function caller, use undefined for no caller
// >1 - arguments
private parse_function( token_parse )
{
	// the 'function' at this point is just a comma delimited list of arguments...
	// strtok them!

	func_args = strtok( token_parse.str, "," );
	for ( i = 0; i < func_args.size; i++ )
	{
		switch ( func_args[ i ] )
		{
			case "$":
				token_parse add_token( "func_args", "random" );
				continue;
			case "!":
				token_parse add_token( "func_args", "undefined" );
				continue;
			case "&":
				token_parse add_token( "func_args", "self" );
				continue;
			case "#":
				token_parse add_token( "func_args", "default" );
				continue;
		}

		if ( !is_alpha_numeric( func_args[ i ], true ) )
		{
			throw_exception( "Cannot use characters other than alnum, '_', ',', '$', '!', '&', '#' in an function call", token_parse );
		}
	}

	return set_parse_success( token_parse );
}

private parse_target_random( token_parse )
{
	token_parse.context_type = "random";
	token_parse.start_pos++; // skip $

	if ( token_parse.start_pos == token_parse.str.size )
	{
		return set_parse_random_limit( token_parse, "99999" );
	}

	if ( token_parse.str[ token_parse.start_pos ] == "[" )
	{
		directive = parse_array( token_parse );
		token_parse.context_type = "array_random"; // override token type
		return directive;
	}

	if ( !is_numeric( token_parse.str, token_parse.start_pos ) )
	{
		throw_exception( "Random target pool limit must be a number", token_parse );
	}

	random_limit = getsubstr( token_parse.str, token_parse.start_pos );
	return set_parse_random_limit( token_parse, random_limit );
}

private try_parse_function( token_parse )
{
	end_pos = -1;
	for ( i = 0; i < token_parse.str.size; i++ )
	{
		if ( token_parse.str[ i ] == "(" ) // function start
		{
			end_pos = i - 1;
			break;
		}
	}

	if ( end_pos == -1 )
	{
		return set_parse_warning( token_parse );
	}

	if ( !is_alpha_numeric( token_parse.str, token_parse.start_pos, end_pos ) )
	{
		throw_exception( "Function names can only contain alnum, '_', and '('", token_parse );
	}

	function_name = getsubstr( token_parse.str, token_parse.start_pos, end_pos );
	token_parse add_token( "function", function_name );

	if ( token_parse.str[ token_parse.str.size - 1 ] != ")" )
	{
		throw_exception( "Function wasn't terminated with ')'", token_parse );
	}

	// push token string ahead of the function name and remove parentheses
	token_parse.str = getsubstr( token_parse.str, ( token_parse.start_pos + function_name.size + 1 ), function_name.size - 1 );
	return parse_function( token_parse );
}

private try_parse_name( token_parse )
{
	if ( !is_alpha_numeric( token_parse.str, true ) )
	{
		throw_exception( "Target names can only contain alnum, and '_'", token_parse );
	}

	name = getsubstr( token_parse.str, 0, token_parse.str.size );
	token_parse add_token( "identifier", name );
	return set_parse_success( token_parse );
}

private parse_target_value( key, value )
{
	token_parse = token_parse_obj_t_new( "unassigned", value, 0, value.size, key );

	// basic tokens
	switch ( token_parse.str[ 0 ] )
	{
		case "*":
			token_parse.context_type = "all";
			break;
		case "!":
			token_parse.context_type = "undefined";
			break;
		case "&":
			token_parse.context_type = "self"; // explicit self
			break;
		case "#":
			token_parse.context_type = "default"; // the default, and configureable target explicitly specified
			break;
	}

	if ( token_parse.context_type != "unassigned" )
	{
		if ( token_parse.str.size > 1 )
		{
			throw_exception( "The '" + token_parse.context_type + "' valid targets syntax '" + token_parse.str[ 0 ] + "' cannot be used with any other syntax as the first element: token: '" + token_parse.str + "'", token_parse );
		}

		return set_parse_success( token_parse, "target==" + token_parse.context_type );
	}

	// array and random
	switch ( token_parse.str[ 0 ] )
	{
		case "$":
			return parse_target_random( token_parse );
		case "[":
			return parse_array( token_parse );
	}

	// function and name(identifier)
	if ( is_alpha_numeric( token_parse.str[ 0 ] ) )
	{
		// ambiguous, could be function start or a name
		function_call_obj = try_parse_function( token_parse );
		if ( !function_call_obj.warning )
		{
			return function_call_obj;
		}

		reset_parse_warning( token_parse );

		// not a function, no '(' token
		// names can contain a lot of weird characters, but you are better off using the guid/clientnum syntax anyway
		name_token_obj = try_parse_name( token_parse );
		return name_token_obj;
	}

	throw_exception( "Unsupported target directive value: '" + token_parse.str + "'", token_parse );
}

private parse_directive( cmd_parse, key, key_type, ordinal_argument, value )
{
	if ( key_type[ 0 ] == "t" || issubstr( key_type, "target" ) )
	{
		directive_value = parse_target_value( key, value );
		return directive_parse_obj_t_new( "target", directive_value, ordinal_argument );
	}
	else if ( key_type[ 0 ] == "e" || issubstr( key_type, "executor" ) ) // allows you to specify the 'executor' or who executes the command
	{
		directive_value = parse_target_value( key, value );
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

private parse_key( cmd_parse )
{
	key = "";

	for ( pos = cmd_parse.start_pos;; pos++ )
	{
		if ( pos >= cmd_parse.str.size )
		{
			break;
		}

		if ( cmd_parse.str[ pos ] == "=" )
		{
			cmd_parse.end_pos = pos - 1; // we don't want to send '='
			break;
		}
	}

	if ( cmd_parse.end_pos == cmd_parse.str.size )
	{
		throw_exception( "Directives are key value pairs; missing complete key", cmd_parse );
	}

	key = getsubstr( cmd_parse.str, cmd_parse.start_pos, cmd_parse.end_pos );
	if ( !is_alpha_numeric( key ) )
	{
		throw_exception( "Directive key: '" + key + "' contains an invalid character; only alnum and '_' characters are allowed", cmd_parse );
	}

	return key;
}

// {target1=[a,b,c],t2=JezuzLizard,t3={a=5,b=8}}
private split_kvps( cmd_parse )
{
	keys_to_values = [];

	kvps = strtok( cmd_parse.str, "=" );

	if ( ( kvps.size % 2 ) != 0 )
	{
		throw_exception( "Key value pairs are not matching", cmd_parse );
	}

	for ( i = 0; i < kvps.size; i += 2 )
	{
		switch ( kvps[ i + 1 ][ 0 ] )
		{
			case "{":
				throw_exception( "Nested keys are not supported", cmd_parse );
				break;
			case "[":
			default:
				keys_to_values[ kvps[ i ] ] = kvps[ i + 1 ];
				break;
		}
	}

	return keys_to_values;
}

private parse_value( cmd_parse )
{
	value = "";
	commas_delimit = true;
	func_needs_closed = 0;
	array_needs_closed = 0;
	key_needs_closed = 0;

	for ( pos = cmd_parse.start_pos;; pos++ )
	{
		if ( pos >= cmd_parse.str.size )
		{
			if ( !commas_delimit )
			{
				throw_exception( "Unmatching function or array braces", cmd_parse );
			}
			break;
		}

		if ( cmd_parse.str[ pos ] == "{" )
		{
			key_needs_closed++;
		}

		if ( cmd_parse.str[ pos ] == "}" )
		{
			key_needs_closed--;
		}

		if ( cmd_parse.str[ pos ] == "(" )
		{
			func_needs_closed++;
		}

		if ( cmd_parse.str[ pos ] == ")" )
		{
			func_needs_closed--;
		}

		if ( cmd_parse.str[ pos ] == "[" )
		{
			array_needs_closed++;
		}

		if ( cmd_parse.str[ pos ] == "]" )
		{
			array_needs_closed--;
		}

		commas_delimit = array_needs_closed == 0 && func_needs_closed == 0 && key_needs_closed == 0;

		if ( commas_delimit && cmd_parse.str[ pos ] == "," )
		{
			cmd_parse.end_pos = pos - 1; // we don't need to send the separating comma
			break;
		}
	}

	value = getsubstr( cmd_parse.str, cmd_parse.start_pos, cmd_parse.end_pos );

	return value;
} 

private parse_directives( cmd_parse )
{
	// token_str == "@{...}
	// in here we just want to parse the middle bit

	if ( cmd_parse.str.size <= 3 )
	{
		throw_exception( "Empty directive block isn't allowed", cmd_parse );
	}

	cmd_parse.str = getsubstr( cmd_parse.str, 2, ( cmd_parse.str.size - 1 ) );

	for ( ;; )
	{
		if ( cmd_parse.start_pos == cmd_parse.str.size )
		{
			break;
		}

		// parse key
		key = parse_key( cmd_parse );
		cmd_parse.start_pos = cmd_parse.end_pos + 2; // skip over the '=' token 

		// parse value
		value = parse_value( cmd_parse );
		cmd_parse.start_pos = cmd_parse.end_pos;

		key_type = key;
		ordinal_argument = int( key[ key.size - 1 ] );
		if ( ordinal_argument > 0 )
		{
			key_type = getsubstr( key, 0, key.size - 1 );
		}
		else if ( issubstr( key_type, "target" ) )
		{
			throw_exception( "'target' requires an ordinal suffix to indicate unambiguously which target is used", cmd_parse );
		}

		if ( !isdefined( cmd_parse.directive_kvps[ key_type ] ) )
		{
			cmd_parse.directive_kvps[ key_type ] = [];
		}
		cmd_parse.directive_kvps[ key_type ][ ordinal_argument - 1 ] = parse_directive( cmd_parse, key, key_type, ordinal_argument, value );
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

private add_token( key, value )
{
	if ( !isdefined( self.tokens[ key ] ) )
	{
		new_token = spawnstruct();
		new_token.key = key;
		new_token.value = value;
		new_token.tokens = [];
	}

	self.tokens[ self.tokens.size ] = new_token;

	return new_token;
}

private get_token_count()
{
	return self.tokens.size;
}

/*token_parse_obj_t*/ private token_parse_obj_t_new( context_type, str, start, end, key )
{
	token_parse_obj = generic_obj_t_new( "token_parse" );
	token_parse_obj.context_type = context_type;
	token_parse_obj.tokens = []; // string indexed array of struct using type and literal
	token_parse_obj.start_pos = start;
	token_parse_obj.end_pos = end;
	token_parse_obj.save_start_pos = start;
	token_parse_obj.save_end_pos = end;
	token_parse_obj.str = str;
	token_parse_obj.key = key;
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

/*cmd_parse_obj_t*/ private cmd_parse_obj_t_new( cmd_string, cmd_data_source )
{
	cmd_parse_obj = generic_obj_t_new( "cmd_parse" );
	cmd_parse_obj.directive_kvps = []; // string -> array[ directive_parse_obj_t ]
	cmd_parse_obj.args = []; // index -> string
	cmd_parse_obj.cmd_data_source = cmd_data_source;
	cmd_parse_obj.start_pos = 0;
	cmd_parse_obj.end_pos = 0;
	cmd_parse_obj.max_len = 0;
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
private custom_split( str, cmd_parse_array )
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
				throw_exception( "Directive must be at least '@{'", cmd_parse_array );
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
					throw_exception( "Directive must be terminated with '}'", cmd_parse_array );
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
		throw_exception( "Command string is empty", cmd_parse_array );
	}

	com_printdebugwarning( message );

	multiple_cmds_keys = strtok( message, "^" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_string = custom_split( multiple_cmds_keys[ i ], cmd_parse_array );
		cmd_find_result = cast_str_to_cmd( cmd_string[ 0 ] );
		new_cmd_parse = cmd_parse_obj_t_new( multiple_cmds_keys[ i ], cmd_find_result.value );
		if ( cmd_find_result.errored )
		{
			throw_exception( cmd_find_result.msg, cmd_parse_array );
		}
		
		cmd_name = cmd_find_result.value.cmd_name;

		for ( j = 1; j < cmd_string.size; j++ )
		{
			new_cmd_parse.start_pos = 0;
			new_cmd_parse.end_pos = cmd_string[ j ].size;
			new_cmd_parse.str = cmd_string[ j ];
			com_printdebugwarning( cmd_string[ j ] );
			// "@" should be a variable; it should be configureable
			if ( cmd_string[ j ][ 0 ] == "@" )
			{
				parse_check_obj = parse_directives( new_cmd_parse );
				if ( parse_check_obj.errored )
				{
					throw_exception( parse_check_obj.msg, cmd_parse_array );
				}
			}
			else
			{
				new_cmd_parse.args[ new_cmd_parse.args.size ] = cmd_string[ j ];
				level.players[ 0 ] script_breakpoint( new_cmd_parse );
			}
		}

		// set default as the executor
		if ( !isdefined( new_cmd_parse.directive_kvps[ "executor" ] ) )
		{
			token_obj = token_parse_obj_t_new( "default" );
			executor_directive = directive_parse_obj_t_new( "executor", token_obj, 1 );
			executor_directive.is_default = true;
			new_cmd_parse.directive_kvps[ "executor" ] = executor_directive;
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

		cmd_parse_array.cmds[ cmd_name ] = new_cmd_parse;
		
		if ( new_cmd_parse.directive_kvps[ "executor" ].directive_value.token_type == "undefined" )
		{
			throw_exception( "Executor cannot be 'undefined'", cmd_parse_array );
		}
	}

	return set_parse_success( cmd_parse_array );
}