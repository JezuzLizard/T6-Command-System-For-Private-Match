
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_perms;
#include scripts\cmd_system_modules\global_client_commands;
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

	tcs_default_ranks = array( "none", "user", "trusted", "elevated", "moderator", "cheat", "host", "owner" );
	tcs_default_ranks_cmdpower = array( 0, 1, 20, 40, 60, 80, 100, 100 );
	level.tcs_ranks = [];
	for ( i = 0; i < tcs_default_ranks.size; i++ )
	{
		rank = tcs_default_ranks[ i ];
		allowedcmds_dvar = getDvarStringDefault( "tcs_rank_" + rank + "_allowedcmds", "" );
		disallowedcmds_dvar = getDvarStringDefault( "tcs_rank_" + rank + "_disallowedcmds", "" );
		cmdpower_dvar = getDvarIntDefault( "tcs_rank_" + rank + "_cmdpower", tcs_default_ranks_cmdpower[ i ] );
		level.tcs_ranks[ rank ] = spawnStruct();
		level.tcs_ranks[ rank ].allowedcmds = allowedcmds_dvar != "" ? strTok( allowedcmds_dvar, " " ) : undefined;
		level.tcs_ranks[ rank ].disallowedcmds = disallowedcmds_dvar != "" ? strTok( disallowedcmds_dvar, " " ) : undefined;
		level.tcs_ranks[ rank ].cmdpower = cmdpower_dvar;
	}
	custom_ranks_str = getDvarStringDefault( "tcs_custom_rank_names", "" );
	custom_ranks = custom_ranks_str != "" ? strTok( custom_ranks_str, " " ) : undefined;
	if ( isDefined( custom_ranks ) )
	{
		for ( i = 0; i < custom_ranks.size; i++ )
		{
			rank = custom_ranks[ i ];
			allowedcmds_dvar = getDvarStringDefault( "tcs_rank_" + rank + "_allowedcmds", "" );
			disallowedcmds_dvar = getDvarStringDefault( "tcs_rank_" + rank + "_disallowedcmds", "" );
			cmdpower_dvar = getDvarIntDefault( "tcs_rank_" + rank + "_cmdpower", 0 );
			level.tcs_ranks[ rank ] = spawnStruct();
			level.tcs_ranks[ rank ].allowedcmds = allowedcmds_dvar != "" ? strTok( allowedcmds_dvar, " " ) : undefined;
			level.tcs_ranks[ rank ].disallowedcmds = disallowedcmds_dvar != "" ? strTok( disallowedcmds_dvar, " " ) : undefined;
			level.tcs_ranks[ rank ].cmdpower = cmdpower_dvar;
		}
	}

	level.FL_GODMODE = 1;
	level.FL_DEMI_GODMODE = 2;
	level.FL_NOTARGET = 4;
	level.clientdvars = [];
	tokens_str = getDvarStringDefault( "tcs_cmd_tokens", "" ); //separated by spaces, good tokens are generally not used at the start of a normal message 
	if ( tokens_str != "" )
	{
		tokens = strTok( tokens_str, " " );
		for ( i = 0; i < tokens.size; i++ )
		{
			level.custom_commands_tokens[ tokens[ i ] ] = tokens[ i ];
		}
	}
	// "\" is always useable by default
	CMD_INIT_PERMS();
	level.tcs_add_server_command_func = ::cmd_addservercommand;
	level.tcs_set_server_command_power_func = ::cmd_setservercommandcmdpower;
	level.tcs_add_client_command_func = ::cmd_addclientcommand;
	level.tcs_set_client_command_power_func = ::cmd_setclientcommandcmdpower;
	level.tcs_remove_server_command = ::cmd_removeservercommand;
	level.tcs_remove_client_command = ::cmd_removeclientcommand;
	level.tcs_com_printf = ::com_printf;
	level.tcs_com_get_feedback_channel = ::com_get_cmd_feedback_channel;
	level.tcs_find_player_in_server = ::find_player_in_server;
	level.tcs_check_cmd_collisions = ::check_for_command_alias_collisions;
	level.server_commands = [];
	CMD_ADDSERVERCOMMAND( "setcvar", "scv", "setcvar <name|guid|clientnum|self> <cvarname> <newval>", ::CMD_SETCVAR_f, "cheat", 3 );
	CMD_ADDSERVERCOMMAND( "dvar", "dv", "dvar <dvarname> <newval>", ::CMD_SERVER_DVAR_f, "cheat", 2 );
	CMD_ADDSERVERCOMMAND( "cvarall", "cva", "cvarall <cvarname> <newval>", ::CMD_CVARALL_f, "cheat", 2 );
	CMD_ADDSERVERCOMMAND( "givegod", "ggd", "givegod <name|guid|clientnum|self>", ::CMD_GIVEGOD_f, "cheat", 1 );
	CMD_ADDSERVERCOMMAND( "givenotarget", "gnt", "givenotarget <name|guid|clientnum|self>", ::CMD_GIVENOTARGET_f, "cheat", 1 );
	CMD_ADDSERVERCOMMAND( "giveinvisible", "ginv", "giveinvisible <name|guid|clientnum|self>", ::CMD_GIVEINVISIBLE_f, "cheat", 1 );
	CMD_ADDSERVERCOMMAND( "setrank", "sr", "setrank <name|guid|clientnum|self> <rank>", ::CMD_SETRANK_f, "cheat", 2 );

	CMD_ADDSERVERCOMMAND( "execonallplayers", "execonall exall", "execonallplayers <cmdname> [cmdargs] ...", ::CMD_EXECONALLPLAYERS_f, "host", 1 );
	CMD_ADDSERVERCOMMAND( "execonteam", "execteam exteam", "execonteam <team> <cmdname> [cmdargs] ...", ::CMD_EXECONTEAM_f, "host", 2 );

	CMD_ADDSERVERCOMMAND( "cmdlist", "cl", "cmdlist", ::CMD_CMDLIST_f, "none", 0, true );
	CMD_ADDSERVERCOMMAND( "playerlist", "plist", "playerlist [team]", ::CMD_PLAYERLIST_f, "none", 0, true );

	cmd_addservercommand( "help", undefined, "help [cmdalias]", ::cmd_help_f, "none", 0 );

	cmd_addservercommand( "unittest", undefined, "unittest [botcount]", ::cmd_unittest_f, "host", 0 );

	level.client_commands = [];
	CMD_ADDCLIENTCOMMAND( "togglehud", "toghud", "togglehud", ::CMD_TOGGLEHUD_f, "none", 0 );
	CMD_ADDCLIENTCOMMAND( "god", undefined, "god", ::CMD_GOD_f, "cheat", 0 );
	CMD_ADDCLIENTCOMMAND( "notarget", "nt", "notarget", ::CMD_NOTARGET_f, "cheat", 0 );
	CMD_ADDCLIENTCOMMAND( "invisible", "invis", "invisible", ::CMD_INVISIBLE_f, "cheat", 0 );
	CMD_ADDCLIENTCOMMAND( "printorigin", "printorg por", "printorigin", ::CMD_PRINTORIGIN_f, "none", 0 );
	CMD_ADDCLIENTCOMMAND( "printangles", "printang pan", "printangles", ::CMD_PRINTANGLES_f, "none", 0 );
	CMD_ADDCLIENTCOMMAND( "bottomlessclip", "botclip bcl", "bottomlessclip", ::CMD_BOTTOMLESSCLIP_f, "cheat", 0 );
	CMD_ADDCLIENTCOMMAND( "teleport", "tele", "teleport <name|guid|clientnum|origin>", ::CMD_TELEPORT_f, "cheat", 1 );
	CMD_ADDCLIENTCOMMAND( "cvar", "cv", "cvar <cvarname> <newval>", ::CMD_CVAR_f, "cheat", 2 );

	level thread COMMAND_BUFFER();
	level thread end_commands_on_end_game();
	level thread scr_dvar_command_watcher();
	level thread tcs_on_connect();
	level thread check_for_command_alias_collisions();
	level.command_init_done = true;
}

init()
{
	do_unit_test = getDvarIntDefault( "tcs_unittest", 0 ) > 0;
	if ( do_unit_test )
	{
		scripts\cmd_system_modules\global_commands::do_unit_test();
	}
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

tcs_on_connect()
{
	level endon( "end_commands" );
	while ( true )
	{
		level waittill( "connected", player );
		foreach ( index, dvar in level.clientdvars )
		{
			player thread setClientDvarThread( dvar[ "name" ], dvar[ "value" ], index );
		}
		if ( player isHost() )
		{
			player.cmdpower = level.CMD_POWER_HOST;
			player.tcs_rank = level.TCS_RANK_HOST;
			level.host = player;
		}
		else if ( array_validate( level.tcs_player_entries ) )
		{
			foreach ( entry in level.tcs_player_entries )
			{
				if ( find_player_in_server( entry.player_entry ) == player )
				{
					player.cmdpower = entry.cmdpower;
					player.tcs_rank = entry.rank;
				}
			}
		}
		else 
		{
			player.cmdpower = getDvarIntDefault( "tcs_cmdpower_default", level.CMD_POWER_USER );
			player.tcs_rank = getDvarStringDefault( "tcs_default_rank", level.TCS_RANK_USER );
		}
	}
}