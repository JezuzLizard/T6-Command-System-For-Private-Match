
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_text_parser;
#include scripts\cmd_system_modules\_perms;
#include scripts\cmd_system_modules\global_client_commands;
#include scripts\cmd_system_modules\global_client_threaded_commands;
#include scripts\cmd_system_modules\global_commands;
#include scripts\cmd_system_modules\global_threaded_commands;

#include common_scripts\utility;
#include maps\mp\_utility;

main()
{
	COM_INIT();
	level.custom_commands_restart_countdown = 5;
	level.commands_total = 0;
	level.commands_page_count = 0;
	level.commands_page_max = 4;
	level.custom_commands_cooldown_time = getDvarIntDefault( "tcs_cmd_cd", 5 );
	level.tcs_use_silent_commands = getDvarIntDefault( "tcs_silent_cmds", 0 );
	level.tcs_logprint_cmd_usage = getDvarIntDefault( "tcs_logprint_cmd_usage", 1 );
	level.CMD_POWER_NONE = 0;
	level.CMD_POWER_USER = 1;
	level.CMD_POWER_TRUSTED_USER = 20;
	level.CMD_POWER_ELEVATED_USER = 40;
	level.CMD_POWER_MODERATOR = 60;
	level.CMD_POWER_CHEAT = 80;
	level.CMD_POWER_HOST = 100;
	level.TCS_RANK_NONE = "none";
	level.TCS_RANK_USER = "user";
	level.TCS_RANK_TRUSTED_USER = "trusted";
	level.TCS_RANK_ELEVATED_USER = "elevated";
	level.TCS_RANK_MODERATOR = "moderator";
	level.TCS_RANK_CHEAT = "cheat";
	level.TCS_RANK_HOST = "host";
	level.FL_GODMODE = 1;
	level.FL_DEMI_GODMODE = 2;
	level.FL_NOTARGET = 4;
	level.clientdvars = [];
	tokens = getDvarStringDefault( "tcs_cmd_tokens", "" ); //separated by spaces, good tokens are generally not used at the start of a normal message 
	if ( tokens != "" )
	{
		level.custom_commands_tokens = strTok( tokens, " " );
	}
	// "\" is always useable by default
	CMD_INIT_PERMS();
	level.tcs_add_server_command_func = ::CMD_ADDSERVERCOMMAND;
	level.tcs_add_client_command_func = ::CMD_ADDCLIENTCOMMAND;
	level.tcs_remove_server_command = ::CMD_REMOVESERVERCOMMAND;
	level.tcs_remove_client_command = ::CMD_REMOVECLIENTCOMMAND;
	level.server_commands = [];
	CMD_ADDSERVERCOMMAND( "setcvar", "setcvar scv", "setcvar <name|guid|clientnum|self> <cvarname> <newval>", ::CMD_SETCVAR_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "dvar", "dvar dv", "dvar <dvarname> <newval>", ::CMD_SERVER_DVAR_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "cvarall", "cvarall cva", "cvarall <cvarname> <newval>", ::CMD_CVARALL_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "givegod", "givegod ggd", "givegod <name|guid|clientnum|self>", ::CMD_GIVEGOD_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "givenotarget", "givenotarget gnt", "givenotarget <name|guid|clientnum|self>", ::CMD_GIVENOTARGET_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "giveinvisible", "giveinvisible ginv", "giveinvisible <name|guid|clientnum|self>", ::CMD_GIVEINVISIBLE_f, level.CMD_POWER_CHEAT );
	CMD_ADDSERVERCOMMAND( "setrank", "setrank sr", "setrank <name|guid|clientnum|self> <rank>", ::CMD_SETRANK_f, level.CMD_POWER_HOST );

	CMD_ADDSERVERCOMMAND( "execonallplayers", "execonallplayers execonall exall", "execonallplayers <cmdname> [cmdargs] ...", ::CMD_EXECONALLPLAYERS_f, level.CMD_POWER_HOST );
	CMD_ADDSERVERCOMMAND( "execonteam", "execonteam execteam exteam", "execonteam <team> <cmdname> [cmdargs] ...", ::CMD_EXECONTEAM_f, level.CMD_POWER_HOST );

	level.client_commands = [];
	CMD_ADDCLIENTCOMMAND( "togglehud", "togglehud toghud", "togglehud", ::CMD_TOGGLEHUD_f, level.CMD_POWER_NONE );
	CMD_ADDCLIENTCOMMAND( "god", "god", "god", ::CMD_GOD_f, level.CMD_POWER_CHEAT );
	CMD_ADDCLIENTCOMMAND( "notarget", "notarget nt", "notarget", ::CMD_NOTARGET_f, level.CMD_POWER_CHEAT );
	CMD_ADDCLIENTCOMMAND( "invisible", "invisible invis", "invisible", ::CMD_INVISIBLE_f, level.CMD_POWER_CHEAT );
	CMD_ADDCLIENTCOMMAND( "printorigin", "printorigin printorg por", "printorigin", ::CMD_PRINTORIGIN_f, level.CMD_POWER_NONE );
	CMD_ADDCLIENTCOMMAND( "printangles", "printangles printang pan", "printangles", ::CMD_PRINTANGLES_f, level.CMD_POWER_NONE );
	CMD_ADDCLIENTCOMMAND( "bottomlessclip", "bottomlessclip botclip bcl", "bottomlessclip", ::CMD_BOTTOMLESSCLIP_f, level.CMD_POWER_CHEAT );
	//CMD_ADDCLIENTCOMMAND( "teleport", "teleport tele", "teleport <name|guid|clientnum|origin>", ::CMD_TELEPORT_f, level.CMD_POWER_CHEAT );
	CMD_ADDCLIENTCOMMAND( "cvar", "cvar cv", "cvar <cvarname> <newval>", ::CMD_CVAR_f, level.CMD_POWER_CHEAT );
	// CMD_ADDCLIENTCOMMAND( "cmdlist", "cmdlist cl", "cmdlist", ::CMD_CMDLIST_f, level.CMD_POWER_NONE, true );
	// CMD_ADDCLIENTCOMMAND( "playerlist", "playerlist plist", "playerlist [team]", ::CMD_PLAYERLIST_f, level.CMD_POWER_NONE, true );

	// CMD_ADDCOMMANDLISTENER( "listener_cmdlist", "showmore" );
	// CMD_ADDCOMMANDLISTENER( "listener_cmdlist", "page" );
	// CMD_ADDCOMMANDLISTENER( "listener_playerlist", "showmore" );
	// CMD_ADDCOMMANDLISTENER( "listener_playerlist", "page" );
	level thread COMMAND_BUFFER();
	level thread end_commands_on_end_game();
	level thread scr_dvar_command_watcher();
	level thread tcs_on_connect();
	level.command_init_done = true;
}

init()
{
}

scr_dvar_command_watcher()
{
	level endon( "end_commands" );
	wait 1;
	while ( true )
	{
		dvar_value = getDvar( "tcscmd" );
		if ( dvar_value != "" )
		{
			level notify( "say", dvar_value, undefined, false );
			setDvar( "tcscmd", "" );
		}
		wait 0.05;
	}
}

COMMAND_BUFFER()
{
	level endon( "end_commands" );
	while ( true )
	{
		level waittill( "say", message, player, isHidden );
		if ( isDefined( player ) && !isHidden && !is_command_token( message[ 0 ] ) )
		{
			continue;
		}
		if ( !isDefined( player ) )
		{
			player = level.host;
		}
		channel = player COM_GET_CMD_FEEDBACK_CHANNEL();
		if ( isDefined( player.cmd_cooldown ) && player.cmd_cooldown > 0 )
		{
			level COM_PRINTF( channel, "cmderror", "You cannot use another command for " + player.cmd_cooldown + " seconds", player );
			continue;
		}
		message = toLower( message );
		multi_cmds = parse_cmd_message( message );
		if ( multi_cmds.size < 1 )
		{
			level COM_PRINTF( channel, "cmderror", "Invalid command", self );
			continue;
		}
		if ( multi_cmds.size > 1 && !player can_use_multi_cmds() )
		{
			temp_array_index = multi_cmds[ 0 ];
			multi_cmds = [];
			multi_cmds[ 0 ] = temp_array_index;
			level COM_PRINTF( channel, "cmdwarning", "You do not have permission to use multi cmds; only executing the first cmd" );
		}
		for ( cmd_index = 0; cmd_index < multi_cmds.size; cmd_index++ )
		{
			cmdname = multi_cmds[ cmd_index ][ "cmdname" ];
			args = multi_cmds[ cmd_index ][ "args" ];
			is_clientcmd = multi_cmds[ cmd_index ][ "is_clientcmd" ];
			if ( !player has_permission_for_cmd( cmdname, is_clientcmd ) )
			{
				level COM_PRINTF( channel, "cmderror", "You do not have permission to use " + cmdname + " command", player );
			}
			else
			{
				player CMD_EXECUTE( cmdname, args, is_clientcmd, level.tcs_use_silent_commands, level.tcs_logprint_cmd_usage );
				player thread CMD_COOLDOWN();
			}
		}
	}
}

end_commands_on_end_game()
{
	level waittill_either( "end_game", "game_ended" );
	wait 10;
	level notify( "end_commands" );
}