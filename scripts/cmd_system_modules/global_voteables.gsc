#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;
#include scripts/cmd_system_modules/_listener;
#include scripts/cmd_system_modules/_perms;
#include scripts/cmd_system_modules/_text_parser;

#include common_scripts/utility;
#include maps/mp/_utility;

VOTE_INIT()
{
	level.custom_votes_total = 0;
	level.custom_votes_page_count = 0;
	level.vote_timeout = getDvarIntDefault( "tcs_vote_timelimit_seconds", 30 );
	level.vote_start_anonymous = getDvarIntDefault( "tcs_anonymous_vote_start", 1 );
	CMD_ADDCOMMANDLISTENER( "listener_vote", "yes" );
	CMD_ADDCOMMANDLISTENER( "listener_vote", "no" );
	VOTE_ADDVOTEABLE( "cvarall", "cvarall ca", "votestart cvarall <dvarname> <newval>", ::VOTEABLE_CVARALL_PRE_f, ::VOTEABLE_CVARALL_POST_f );
	VOTE_ADDVOTEABLE( "kick", "kick k", "votestart kick <name|guid|clientnum|self>", ::VOTEABLE_KICK_PRE_f, ::VOTEABLE_KICK_POST_f );
}

VOTEABLE_CVARALL_PRE_f( arg_list )
{
	name = arg_list[ 0 ];
	dvar_name = arg_list[ 1 ];
	new_value = arg_list[ 2 ];
	result = [];
	if ( isDefined( dvar_name ) && isDefined( new_value ) )
	{
		result[ "message" ] = name + " would like to set " + dvar_name + " to " + new_value;
		result[ "channels" ] = "iprintbold";
		result[ "filter" ] = "notitle";
	}
	else 
	{
		result[ "message" ] = "Cvarall set requires a valid <dvar name>, and <dvar value>.";
		result[ "channels" ] = self COM_GET_CMD_FEEDBACK_CHANNEL();
		result[ "filter" ] = "cmderror";
	}
	return result;
}

VOTEABLE_KICK_PRE_f( arg_list )
{
	name = arg_list[ 0 ];
	player = self find_player_in_server( arg_list[ 1 ] );
	result = [];
	if ( isDefined( player ) )
	{
		result[ "message" ] = name + " would like to kick " + player.name;
		result[ "channels" ] = "iprintbold";
		result[ "filter" ] = "notitle";
	}
	else 
	{
		result[ "message" ] = "Could not find player";
		result[ "channels" ] = self COM_GET_CMD_FEEDBACK_CHANNEL();
		result[ "filter" ] = "cmderror";
	}
	return result;
}

VOTEABLE_CVARALL_POST_f( arg_list )
{
	self CMD_EXECUTE( "cvarall", arg_list );
}

VOTEABLE_KICK_POST_f( arg_list )
{
	self CMD_EXECUTE( "kick", arg_list );
}