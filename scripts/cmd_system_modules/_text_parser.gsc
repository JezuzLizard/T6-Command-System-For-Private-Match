#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;

parse_cmd_message( message )
{
	if ( message == "" )
	{
		return [];
	}
	//Strip command tokens.
	stripped_message = message;
	if ( is_command_token( message[ 0 ] ) )
	{
		stripped_message = "";
		for ( i = 1; i < message.size; i++ )
		{
			stripped_message += message[ i ];
		}
	}
	multi_cmds = [];
	command_keys = [];
	multiple_cmds_keys = strTok( stripped_message, "," );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_args = strTok( multiple_cmds_keys[ i ], " " );
		cmdname = get_client_cmd_from_alias( cmd_args[ 0 ] );
		cmd_is_clientcmd = true;
		if ( cmdname == "" )
		{
			cmdname = get_server_cmd_from_alias( cmd_args[ 0 ] );
			cmd_is_clientcmd = false;
		}
		if ( cmdname != "" )
		{
			command_keys[ "cmdname" ] = cmdname;
			arrayRemoveIndex( cmd_args, 0 );
			command_keys[ "args" ] = [];
			command_keys[ "args" ] = cmd_args;
			command_keys[ "is_clientcmd" ] = cmd_is_clientcmd;
			multi_cmds[ multi_cmds.size ] = command_keys;
		}
	}
	return multi_cmds;
}

get_server_cmd_from_alias( alias )
{
	command_keys = getArrayKeys( level.server_commands );
	for ( i = 0; i < command_keys.size; i++ )
	{
		for ( j = 0; j < level.server_commands[ command_keys[ i ] ].aliases.size; j++ )
		{
			if ( alias == level.server_commands[ command_keys[ i ] ].aliases[ j ] )
			{
				return command_keys[ i ];
			}
		}
	}
	return "";
}

get_client_cmd_from_alias( alias )
{
	command_keys = getArrayKeys( level.client_commands );
	for ( i = 0; i < command_keys.size; i++ )
	{
		for ( j = 0; j < level.client_commands[ command_keys[ i ] ].aliases.size; j++ )
		{
			if ( alias == level.client_commands[ command_keys[ i ] ].aliases[ j ] )
			{
				return command_keys[ i ];
			}
		}
	}
	return "";
}