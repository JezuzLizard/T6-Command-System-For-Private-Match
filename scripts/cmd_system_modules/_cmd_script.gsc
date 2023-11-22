#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_debug;
#include scripts\cmd_system_modules\_perms;

#include common_scripts\utility;
#include maps\mp\_utility;

#define CHECKS_TYPE_DVAR 0
#define CHECKS_TYPE_PLAYER 1

#define EVENT_TYPES_UNKNOWN -1
#define EVENT_TYPES_NORMAL 0
#define EVENT_TYPES_DVARMOD 1

cmd_init_script()
{

}

determine_event_type( event )
{
	types = strTok( event, " " );
	if ( types.size <= 1 )
	{
		return EVENT_TYPES_NORMAL;
	}

	switch ( types[ 0 ] )
	{
		case "dvarmod":
			return EVENT_TYPES_DVARMOD;
		default:
			return EVENT_TYPES_UNKNOWN;
	}
}

register_autoexec_command_event( struct )
{
	if ( !isDefined( level.tcs_autoexec_commands ) )
	{
		level.tcs_autoexec_commands = [];
	}
	if ( !isDefined( level.tcs_autoexec_commands[ event ] ) )
	{
		level.tcs_autoexec_commands[ event ] = [];
	}
	struct.event_type = determine_event_type( event );

	level.tcs_autoexec_commands[ struct.name ][ level.tcs_autoexec_commands[ event ].size ] = struct;
}

check_command_operator( value1, value2, struct )
{
	// ==
	// !=
	// >
	// <
	// >=
	// <=
	switch ( struct.op )
	{
		case "==":
			return value1 == value2;
		case "!=":
			return value1 != value2;
		case ">":
			return value1 > value2;
		case "<":
			return value1 < value2;
		case ">=":
			return value1 >= value2;
		case "<=":
			return value1 <= value2;
		default:
			// Error handling
			return false;
	}
}

resolve_player_cmdpower_value( target, struct )
{
	return check_command_operator( target.cmdpower, int( struct.value ), struct );
}

resolve_player_field_for_player( player, struct )
{
	fields = strTok( struct.target, "." );
	if ( fields.size <= 1 )
	{
		// Invalid syntax error
		return undefined;
	}

	if ( !isDefined( player ) )
	{
		return undefined;
	}
	switch ( fields[ 1 ] )
	{
		case "cmdpower":
			return resolve_player_cmdpower_value( player, struct );
		default:
			// Unsupported field error
			return undefined;
	}
}

check_command_control_flow_return_value( target, struct )
{
	switch ( struct.type )
	{
		case CHECKS_TYPE_DVAR:
			return check_command_operator( getDvar( struct.target ), struct.value, struct );
		case CHECKS_TYPE_PLAYER:
			return resolve_player_field_for_player( target, struct );
		default:
			// Add error reporting here
			return false;
	}
}

can_run_command( cmd )
{
	requires_map_check = false;
	is_valid_map = true;
	requires_gametype_check = false;
	is_valid_gametype = true;
	if_checks_passed = false;
	when_checks_passed = false;
	has_if_check = false;
	has_when_check = false;


	if ( isDefined( cmd.maps ) )
	{
		is_valid_map = false;
		requires_map_check = true;
		mapname = getDvar( "mapname" );
		for ( i = 0; i < cmd.maps.size; i++ )
		{
			if ( cmd.maps[ i ] == mapname )
			{
				is_valid_map = true;
				break;
			}
		}
	}

	if ( isDefined( cmd.gametypes ) )
	{
		is_valid_gametype = false;
		requires_gametype_check = true;
		gametype = getDvar( "g_gametype" );
		for ( i = 0; i < cmd.gametypes.size; i++ )
		{
			if ( cmd.gametypes[ i ] == gametype )
			{
				is_valid_gametype = true;
				break;
			}
		}
	}

	if ( isDefined( cmd.ifs ) )
	{
		has_if_check = true;
		for ( i = 0; i < cmd.ifs.size; i++ )
		{
			if ( is_true( check_command_control_flow_return_value( self, cmd.ifs[ i ] ) ) )
			{
				if_checks_passed = true;
				break;
			}
		}
	}

	if ( isDefined( cmd.whens ) )
	{
		has_when_check = true;
		when_checks_passed_count = 0;
		for ( i = 0; i < cmd.whens.size; i++ )
		{
			if ( is_true( check_command_control_flow_return_value( self, cmd.whens[ i ] ) ) )
			{
				when_checks_passed_count++;
				continue;
			}

			break
		}
		when_checks_passed = when_checks_passed_count == cmd.whens.size;
	}

	if ( has_if_check && !if_checks_passed )
	{
		return false;
	}

	if ( has_when_check && !when_checks_passed )
	{
		return false;
	}

	if ( requires_map_check )
	{
		if ( requires_gametype_check )
		{
			return is_valid_map && is_valid_gametype;
		}

		return is_valid_map;
	}

	if ( requires_gametype_check )
	{
		return is_valid_gametype;
	}

	return true;
}

run_command_after_delay( cmd )
{
	if ( isDefined( cmd.delay ) && cmd.delay > 0 )
	{
		time = cmd.delay;
		while ( time > 0 )
		{
			wait 0.05;
			time -= 0.05;
		}
	}

	self cmd_execute_internal( cmds[ i ].cmd, cmds[ i ].cmdargs, true, true );
}

run_commands( cmds )
{
	if ( !isDefined( cmds ) )
	{
		return;
	}
	for ( i = 0; i < cmds.size; i++ )
	{
		if ( self can_run_command( cmds[ i ] ) )
		{
			self thread run_command_after_delay( cmds[ i ], );
		}
	}
}

run_connected_autoexec_commands()
{
	cmds = level.tcs_autoexec_commands[ "con" ];

	self run_commands( cmds );
}

run_spawned_player_autoexec_commands()
{
	cmds = level.tcs_autoexec_commands[ "spawn" ];

	self run_commands( cmds );
}

parse_token( string, start_pos, token_struct, delimiter )
{
	end_pos = start_pos;
	buffer = "";
	for ( i = start_pos; ; i++ )
	{
		if ( !isDefined( string[ i ] ) )
		{
			// End of string no closing curly brace error
			break;
		}
		if ( string[ i ] == delimiter )
		{
			break;
		}
		end_pos++;
		buffer += string[ i ];
	}

	token_struct.token = buffer;
	return end_pos + 1;	
}

validate_string( dvarname, string )
{
	left_bracket_count = 0;
	right_bracket_count = 0;
	left_parentheses_count = 0;
	right_parentheses_count = 0;
	parsing_name_args = false;
	parsing_cmd_args = false;
	errored = false;
	for ( i = 0; i < string.size; i++ )
	{
		if ( string[ i ] == "(" )
		{
			if ( parsing_name_args )
			{
				errored = true;
				break;
			}
			parsing_name_args = true;
			left_parentheses_count++;
		}
		else if ( string[ i ] == "{" )
		{
			if ( parsing_cmd_args )
			{
				errored = true;
				break;
			}
			parsing_cmd_args = true;
			left_bracket_count++;
		}
		else if ( string[ i ] == ")" )
		{
			if ( !parsing_name_args )
			{
				errored = true;
				break;
			}
			parsing_name_args = false;
			right_parentheses_count++;
		}
		else if ( string[ i ] == "}" )
		{
			if ( !parsing_cmd_args )
			{
				errored = true;
				break;
			}
			parsing_cmd_args = false;
			right_bracket_count++;
		}
	}
	if ( left_parentheses_count != right_parantheses_count )
	{
		errored = true;
	}
	else if ( left_bracket_count != right_bracket_count )
	{
		errored = true;
	}

	if ( errored )
	{
		level com_printf( "con|g_log", "autoexec", "Bad syntax in " + dvarname );
		return false;
	}

	return true;
}

parse_autoexec_dvar_values_into_structs( dvar_value_pairs )
{
	syntax_tree = spawnStruct();
	syntax_tree.names = [];
	token_struct = spawnStruct();
	dvar_names = getArrayKeys( dvar_value_pairs );
	for ( i = 0; i < dvar_names.size; i++ )
	{
		string = dvar_value_pairs[ dvar_names[ i ] ];
		if ( !validate_string( dvar_names[ i ], string ) )
		{
			continue;
		}
		start_pos = 0;
		parsing_name = true;
		cmds = undefined;
		errored = false;
		while ( true )
		{
			if ( parsing_name )
			{
				errored = false;
				start_pos = parse_token( string, start_pos, token_struct, "(" );
				if ( start_pos >= string.size )
				{
					break;
				}
				token = token_struct.token;
				syntax_tree.names[ token ].parent = dvar_names[ i ];
				syntax_tree.names[ token ].cmds = [];
				cmds = syntax_tree.names[ token ].cmds;
				parsing_name = false;
			}
			
			start_pos = parse_token( string, start_pos, token_struct, "{" );
			if ( start_pos >= string.size )
			{
				errored = true;
				break;
			}
			if ( token_struct.token == "" )
			{
				errored = true;
				break;
			}
			if ( isDefined( cmds[ token_struct.token ] ) )
			{
				cmds[ token_struct.token ][ cmds[ token_struct.token ].size ] = spawnStruct();
			}
			else
			{
				cmds[ token_struct.token ] = [];
				cmds[ token_struct.token ][ 0 ] = spawnStruct();
			}
			
			start_pos = parse_token( string, start_pos, token_struct, "}" );
			if ( start_pos >= string.size )
			{
				errored = true;
				break;
			}
			if ( token_struct.token == "" )
			{
				errored = true;
				break;
			}

			cmds[ token_struct.token ][ cmds[ token_struct.token ].size - 1 ].cmdargs = token_struct.token;
			syntax_tree.names[ token ].cmds = cmds;

			if ( string[ start_pos ] == ")" )
			{
				parsing_name = true;
			}
		}
		if ( errored )
		{
			level com_printf( "con|g_log", "autoexec", "Bad syntax" );
			continue;
		}
		register_autoexec_command_event( syntax_tree.names[ token ] );
	}
}

run_autoexec_commands()
{
	// Tokens
	// name - Name of autoexec entry
		// Goes before the opening ()
		// Used for debugging
		// Syntax 
			// <name>(<args>)
	// on - Event prefacing
		// Possible values split by spaces
		// connecting - "connecting" notify
		// connected - "connected" notify
		// spawned_player - "spawned_player"
		// death - "death" notify
		// prematch_over - "prematch_over" notify
		// disconnect - level "disconnect" notify
		// end_game - level "end_game" notify
		// game_ended - level "game_ended" notfiy
		// tcs_autoexec_repeat - level "tcs_autoexec_repeat" notify
		// tcs_once - level "tcs_once" notify
		// dvarmod - level "<dvar>_modified> notify
		// Syntax
			// on{<event>}
		// Syntax dvarmod
			// on{dvarmod <dvar>}
		// Can be defined multiple times to allow for multiple triggers by different events
	// cmd - Command prefacing for client command
	// Optional tokens
	// maps
		// Possible values
		// Any valid mapname separated by spaces
		// Syntax
			// maps{<map1> <map2> ...}
	// gametypes 
		// Possible values
		// Any valid gametype by spaces
		// Syntax
			// maps{<gametype1> <gametype2> ...}
	// delay
		// Possible values
		// wholefloat
		// Syntax
			// delay{<wholefloat>}
	// when dvar or field
		// Possible values
		// ==
		// !=
		// >
		// <
		// >=
		// <=
		// Can be defined multiple times requiring all of them resolving true to execute the command
		// when{timescale == 1.5}
		// Syntax
			// when{<dvar> <control_flow_token> <value>}
			// when{self.<field> <control_flow_token> <value>}
	// if dvar or field
		// Possible values 
		// ==
		// !=
		// >
		// <
		// >=
		// <=
		// Can be defined multiple times requiring only one to be true to activate the command
		// Priority over when keyword
		// Syntax
			// if{<dvar> <control_flow_token> <value>}
			// if{self.<field> <control_flow_token> <value>}
	// set tcs_autoexec_dvar_0 "give_rank_if_cheats(cmd{setrank -a cheat}on{dvarmod sv_cheats}when{sv_cheats == 1}when{-a.cmdpower < 80})take_rank_if_not_cheats(cmd{setrank all user}on{dvarmod sv_cheats}when{sv_cheats == 0}when{-a.cmdpower == 80})"

	// set tcs_autoexec_dvar_0 "disable_fog(cmd{setcvar -a r_fog 0}on{spawned_player}maps{mp_raid zm_transit}gametypes{tdm zclassic})give_invis(cmd{invis}on{spawn}delay{5.5}when(timescale == 1.5))"

	autoexec_dvar_values = [];
	for ( i = 0; ; i++ )
	{
		autoexec_dvar = getDvar( "tcs_autoexec_dvar_" + i );
		if ( autoexec_dvar == "" )
		{
			break;
		}

		autoexec_dvar_values[ "tcs_autoexec_dvar_" + i ] = autoexec_dvar;
	}

	if ( autoexec_dvar_values.size <= 0 )
	{
		return;
	}

	parse_autoexec_dvar_values_into_structs( autoexec_dvar_values );
}