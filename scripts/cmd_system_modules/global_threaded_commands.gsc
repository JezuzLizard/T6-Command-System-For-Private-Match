#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;
#include scripts/cmd_system_modules/_listener;
#include scripts/cmd_system_modules/_perms;
#include scripts/cmd_system_modules/_text_parser;
#include scripts/cmd_system_modules/_vote;

#include common_scripts/utility;
#include maps/mp/_utility;

CMD_VOTESTART_f( arg_list )
{
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	if ( !is_true( self.is_admin ) )
	{
		if ( is_true( self.vote_started ) )
		{
			level COM_PRINTF( channel, "cmderror", "vote:start: You cannot start a new vote for the remainder of this match.", self );
			return;
		}
	}
	if ( is_true( level.vote_in_progress ) )
	{
		level COM_PRINTF( channel, "cmderror", "vote:start: You cannot start a new vote until the current vote is finished in " 
		+ level.vote_in_progress_timeleft + " seconds.", self );
		return;
	}
	if ( get_vote_threshold() == -1 )
	{
		level COM_PRINTF( channel, "cmderror", "vote:start: You cannot start a new vote when there is less than 3 players.", self );
		return;
	}
	key_type = arg_list[ 0 ];
	cmd_arg_1 = arg_list[ 1 ];
	cmd_arg_2 = arg_list[ 2 ];
	cmd_arg_3 = arg_list[ 3 ];
	cmd_arg_4 = arg_list[ 4 ];
	if ( !isDefined( key_type ) )
	{
		level COM_PRINTF( channel, "cmderror", "vote:start: Missing params, 2 args required <key_type>, <key_value>.", self );
		return;
	}
	if ( level.vote_start_anonymous )
	{
		name = "Anon";
	}
	else 
	{
		name = self.name;
	}
	cmd_type_keys = getArrayKeys( level.custom_votes );
	votename = get_voteable_from_alias( key_type );
	if ( votename != "" )
	{
		func_args = [];
		func_args[ 0 ] = name;
		func_args[ 1 ] = cmd_arg_1;
		func_args[ 2 ] = cmd_arg_2;
		func_args[ 3 ] = cmd_arg_3;
		func_args[ 4 ] = cmd_arg_4;
		pre_message_result = self [[ level.custom_votes[ votename ].pre_func ]]( func_args );
		level COM_PRINTF( pre_message_result[ "channels" ], pre_message_result[ "filter" ], pre_message_result[ "message" ], self );
		if ( pre_message_result[ "filter" ] == "cmderror" )
		{
			return;
		}
	}
	else 
	{
		level COM_PRINTF( channel, "cmderror", "vote:start: Unsupported key_type " + key_type + " recevied.", self );
		return;
	}
	level COM_PRINTF( "g_log", "cmdinfo", "Voteables Usage: " + self.name + " started vote for " + key_type, level.players );
	level COM_PRINTF( "iprint", "notitle", "You have " + level.vote_timeout + " seconds to cast your vote.", level.players );
	level COM_PRINTF( "iprint", "notitle", "Do /yes or /no to vote.", level.players );
	level COM_PRINTF( "iprint", "notitle", "Outcome is determined from players who cast a vote, not from the total players.", level.players );
	level thread vote_timeout_countdown();
	level.vote_in_progress_votes = [];
	foreach ( player in level.players )
	{
		player thread player_track_vote();
	}
	level thread count_votes();
	level.vote_in_progress = true;
	self.vote_started = true;
	level waittill( "vote_ended", result );
	level.vote_in_progress = false;
	if ( !result )
	{
		return;
	}
	self [[ level.custom_votes[ votename ].post_func ]]( func_args );
}

CMD_PLAYERLIST_f( arg_list )
{
	self notify( "listener_playerlist" );
	self endon( "listener_playerlist" );
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	current_page = 1;
	user_defined_page = 1;
	if ( array_validate( arg_list ) )
	{
		team_name = arg_list[ 0 ];
		if ( isDefined( level.teams[ team_name ] ) )
		{
			players = getPlayers( team_name );
			if ( players.size == 0 )
			{
				level COM_PRINTF( channel, "cmderror", "playerlist team " + team_name + " is empty", self );
				return;
			}
		}
		else 
		{
			level COM_PRINTF( channel, "cmderror", "playerlist: Received bad team " + team_name, self );
			return;
		}
	}
	else 
	{
		players = getPlayers();
	}
	remaining_players = players.size;
	remaining_pages = ceil( remaining_players / level.server_commands_page_max );
	players_to_display = [];
	for ( i = 0; i < players.size; i++ )
	{
		message = players[ i ].name + players[ i ] getGUID() + players[ i ] getEntityNumber() + ""; //remember to add rank as a listing option
		players_to_display[ players_to_display.size ] = message;
		remaining_players--;
		if ( ( players_to_display.size > level.server_commands_page_max ) && remaining_players != 0 )
		{
			if ( current_page == user_defined_page )
			{
				foreach ( message in players_to_display )
				{
					level COM_PRINTF( channel, "cmdinfo", message, self );
				}
				level COM_PRINTF( channel, "cmdinfo", "Displaying page " + current_page + " out of " + remaining_pages + " do showmore or page <num> to display more players.", self );
				self setup_command_listener( "listener_playerlist" );
				result = self wait_command_listener( "listener_playerlist" );
				self clear_command_listener( "listener_playerlist" );
				if ( !isDefined( result[ 0 ] ) || result[ 0 ] == "timeout" )
				{
					return;
				}
				else if ( isSubStr( result[ 0 ], "page" ) )
				{
					user_defined_page = int( result[ 1 ] );
					if ( !isDefined( user_defined_page ) )
					{
						level COM_PRINTF( channel, "cmderror", "Page number arg sent to playerlist is undefined. Valid inputs are 1 thru " +  remaining_pages, self );
						return;
					}
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
				level COM_PRINTF( channel, "cmdinfo", message, self );
			}
		}
	}
}

CMD_UTILITY_CMDLIST_f( arg_list )
{
	self notify( "listener_cmdlist" );
	self endon( "listener_cmdlist" );
	namespace_filter = arg_list[ 0 ];
	cmds_to_display = [];
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	current_page = 1;
	user_defined_page = 1;
	remaining_cmds = level.server_commands_total;
	cmdnames = getArrayKeys( level.server_commands );
	for ( i = 0; i < cmdnames.size; i++ )
	{
		if ( self has_permission_for_cmd( cmdnames[ i ] ) )
		{
			message = "^4" + level.server_commands[ cmdnames[ i ] ].usage;
			if ( channel == "con" )
			{
				level COM_PRINTF( channel, "notitle", message, self );
			}
			else 
			{
				cmds_to_display[ cmds_to_display.size ] = message;
			}
		}
		remaining_cmds--;
		if ( ( cmds_to_display.size > level.server_commands_page_max ) && remaining_cmds != 0 )
		{
			if ( current_page == user_defined_page )
			{
				foreach ( message in cmds_to_display )
				{
					level COM_PRINTF( channel, "cmdinfo", message, self );
				}
				level COM_PRINTF( channel, "cmdinfo", "Displaying page " + current_page + " out of " + level.server_commands_page_count + " do /showmore or /page <num> to display more commands.", self );
				self setup_command_listener( "listener_cmdlist" );
				result = self wait_command_listener( "listener_cmdlist" );
				self clear_command_listener( "listener_cmdlist" );
				if ( !isDefined( result[ 0 ] ) || result[ 0 ] == "timeout" )
				{
					return;
				}
				else if ( isSubStr( result[ 0 ], "page" ) )
				{
					if ( !isDefined( result[ 1 ] ) )
					{
						level COM_PRINTF( channel, "cmderror", "Page number arg sent to cmdlist is undefined. Valid inputs are 1 thru " + level.server_commands_page_count, self );
						return;
					}
					user_defined_page = int( result[ 1 ] );
					if ( user_defined_page > level.server_commands_page_count || user_defined_page == 0 )
					{
						level COM_PRINTF( channel, "cmderror", "Page number " + result[ 1 ] + " sent to cmdlist is invalid. Valid inputs are 1 thru " + level.server_commands_page_count, self );
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
				level COM_PRINTF( channel, "cmdinfo", message, self );
			}
		}
	}
}

CMD_UTILITY_VOTELIST_f( arg_list )
{
	self notify( "listener_voteables" );
	self endon( "listener_voteables" );
	voteables_to_display = [];
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	voteables_keys = getArrayKeys( level.custom_votes );
	current_page = 1;
	user_defined_page = 1;
	remaining_cmds = voteables_keys.size;
	for ( i = 0; i < voteables_keys.size; i++ )
	{
		voteables_to_display[ voteables_to_display.size ] = "^4" + level.custom_votes[ voteables_keys[ i ] ].usage;
		remaining_cmds--;
		if ( ( voteables_to_display.size > level.server_commands_page_max ) && remaining_cmds != 0 )
		{
			if ( current_page == user_defined_page )
			{
				foreach ( message in voteables_to_display )
				{
					level COM_PRINTF( channel, "cmdinfo", message, self );
				}
				level COM_PRINTF( channel, "cmdinfo", "Displaying page " + current_page + " out of " + level.server_commands_page_count + " do /showmore or /page <num> to display more voteables.", self );
				self setup_command_listener( "listener_voteables" );
				result = self wait_command_listener( "listener_voteables" );
				self clear_command_listener( "listener_voteables" );
				if ( !isDefined( result[ 0 ] ) || result[ 0 ] == "timeout" )
				{
					return;
				}
				else if ( isSubStr( result[ 0 ], "page" ) )
				{
					user_defined_page = int( result[ 1 ] );
					if ( !isDefined( user_defined_page ) )
					{
						level COM_PRINTF( channel, "cmderror", "Page number arg sent to votelist is undefined. Valid inputs are 1 thru ", self );
						return;
					}
					if ( user_defined_page > level.server_commands_page_count || user_defined_page == 0 )
					{
						level COM_PRINTF( channel, "cmderror", "Page number " + result[ 1 ] + " sent to votelist is invalid. Valid inputs are 1 thru " + level.server_commands_page_count, self );
						return;
					}
				}
				else if ( result[ 0 ] == "showmore" )
				{
					user_defined_page++;
				}
			}
			current_page++;
			voteables_to_display = [];
		}
		else if ( remaining_cmds == 0 )
		{
			foreach ( message in voteables_to_display )
			{
				level COM_PRINTF( channel, "cmdinfo", message, self );
			}
			return;
		}
	}
}