#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_listener;
#include scripts\cmd_system_modules\_perms;
#include scripts\cmd_system_modules\_text_parser;
#include common_scripts\utility;
#include maps\mp\_utility;

CMD_PLAYERLIST_f( arg_list )
{
	self notif( "new_command_listener" );
	self endon( "new_command_listener" );
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	current_page = 1;
	user_defined_page = 1;
	if ( array_validate( arg_list ) )
	{
		team = arg_list[ 0 ];
		if ( isDefined( level.teams[ team ] ) )
		{
			players = getPlayers( team );
			if ( players.size == 0 )
			{
				level COM_PRINTF( channel, "cmderror", "playerlist team " + team + " is empty", self );
				return;
			}
		}
		else 
		{
			level COM_PRINTF( channel, "cmderror", "playerlist: Received bad team " + team, self );
			return;
		}
	}
	else 
	{
		players = getPlayers();
	}
	remaining_players = players.size;
	remaining_pages = ceil( remaining_players / level.commands_page_max );
	players_to_display = [];
	for ( i = 0; i < players.size; i++ )
	{
		message = players[ i ].name + " " + players[ i ] getGUID() + " " + players[ i ] getEntityNumber() + " " + player.tcs_rank; //remember to add rank as a listing option
		players_to_display[ players_to_display.size ] = message;
		remaining_players--;
		if ( ( players_to_display.size > level.commands_page_max ) && remaining_players != 0 )
		{
			if ( current_page == user_defined_page )
			{
				foreach ( message in players_to_display )
				{
					level COM_PRINTF( channel, "notitle", message, self );
				}
				//level COM_PRINTF( channel, "cmdinfo", "Displaying page " + current_page + " out of " + remaining_pages + " do showmore or page <num> to display more players.", self );
				self thread command_listener_timeout();
				result = self command_listener_wait_for_user_input();
				if ( !isDefined( result[ 0 ] ) || result[ 0 ] == "timeout" )
				{
					return;
				}
				else if ( result[ 0 ] == "page" )
				{
					if ( !isDefined( result[ 1 ] ) )
					{
						level COM_PRINTF( channel, "cmderror", "Usage page <pagenumber>, Valid inputs are 1 thru " +  remaining_pages, self );
						return;
					}
					user_defined_page = int( result[ 1 ] );
					if ( user_defined_page > remaining_pages || user_defined_page == 0 )
					{
						level COM_PRINTF( channel, "cmderror", "Page number " + result[ 1 ] + " sent to playerlist is invalid. Valid inputs are 1 thru " + remaining_pages, self );
						return;
					}
				}
				else if ( result[ 0 ] == "showmore" )
				{
					user_defined_page++;
				}
			}
			current_page++;
			players_to_display = [];
		}
		else if ( remaining_players == 0 )
		{
			foreach ( message in players_to_display )
			{
				level COM_PRINTF( channel, "notitle", message, self );
			}
		}
	}
}

CMD_CMDLIST_f( arg_list )
{
	self notify( "new_command_listener" );
	self endon( "new_command_listener" );
	namespace_filter = arg_list[ 0 ];
	cmds_to_display = [];
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	current_page = 1;
	user_defined_page = 1;
	all_commands = arraycombine( level.server_commands, level.client_commands, 1, 0 );
	remaining_cmds = all_commands.size;
	cmdnames = getArrayKeys( all_commands );
	for ( i = 0; i < cmdnames.size; i++ )
	{
		message = "^4" + all_commands[ cmdnames[ i ] ].usage;
		cmds_to_display[ cmds_to_display.size ] = message;
		remaining_cmds--;
		if ( ( cmds_to_display.size > level.commands_page_max ) && remaining_cmds != 0 )
		{
			if ( current_page == user_defined_page )
			{
				foreach ( message in cmds_to_display )
				{
					level COM_PRINTF( channel, "notitle", message, self );
				}
				//level COM_PRINTF( channel, "cmdinfo", "Displaying page " + current_page + " out of " + level.commands_page_count + " do \showmore or \page <num> to display more commands.", self );
				self thread command_listener_timeout();
				result = self command_listener_wait_for_user_input();
				if ( !isDefined( result[ 0 ] ) || result[ 0 ] == "timeout" )
				{
					return;
				}
				else if ( result[ 0 ] == "page" )
				{
					if ( !isDefined( result[ 1 ] ) )
					{
						level COM_PRINTF( channel, "cmderror", "Usage page <pagenumber>, Valid inputs are 1 thru " + level.commands_page_count, self );
						return;
					}
					user_defined_page = int( result[ 1 ] );
					if ( user_defined_page > level.commands_page_count || user_defined_page == 0 )
					{
						level COM_PRINTF( channel, "cmderror", "Page number " + result[ 1 ] + " sent to cmdlist is invalid. Valid inputs are 1 thru " + level.commands_page_count, self );
						return;
					}
				}
				else if ( result[ 0 ] == "showmore" )
				{
					user_defined_page++;
				}
			}
			current_page++;
			cmds_to_display = [];
		}
		else if ( remaining_cmds == 0 )
		{
			foreach ( message in cmds_to_display )
			{
				level COM_PRINTF( channel, "notitle", message, self );
			}
		}
	}
}