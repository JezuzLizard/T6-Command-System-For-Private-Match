
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_debug;
#include scripts\cmd_system_modules\_perms;
#include scripts\cmd_system_modules\global_client_commands;
#include scripts\cmd_system_modules\global_commands;
#include scripts\cmd_system_modules\global_threaded_commands;

#include common_scripts\utility;
#include maps\mp\_utility;

main()
{
	COM_INIT();
	level.server = spawnStruct();
	level.server.playername = "Server";
	level.server.is_server = true;
	level.server.name = "Server";
	level.custom_commands_restart_countdown = 5;
	level.commands_total = 0;
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
	level.tcs_set_server_command_power_func = ::cmd_setservercommandpower;
	level.tcs_add_client_command_func = ::cmd_addclientcommand;
	level.tcs_set_client_command_power_func = ::cmd_setclientcommandpower;
	level.tcs_remove_server_command = ::cmd_removeservercommand;
	level.tcs_remove_client_command = ::cmd_removeclientcommand;
	level.tcs_remove_server_command_by_group = ::cmd_removeservercommandbygroup;
	level.tcs_remove_client_command_by_group = ::cmd_removeclientcommandbygroup;
	level.tcs_com_printf = ::com_printf;
	level.tcs_com_get_feedback_channel = ::com_get_cmd_feedback_channel;
	level.tcs_find_player_in_server = ::cast_str_to_player;
	level.tcs_check_cmd_collisions = ::check_for_command_alias_collisions;
	level.tcs_player_is_valid_check = scripts\cmd_system_modules\_cmd_util::is_player_valid;
	level.tcs_debug_create_random_valid_args = ::create_random_valid_args2;
	level.tcs_repackage_args = ::repackage_args;
	level.server_commands = [];
	CMD_ADDSERVERCOMMAND( "setcvar", "scv", "setcvar <name|guid|clientnum|self> <cvarname> <newval>", ::CMD_SETCVAR_f, "cheat", 3, false );
	CMD_ADDSERVERCOMMAND( "dvar", "dv", "dvar <dvarname> <newval>", ::CMD_SERVER_DVAR_f, "cheat", 2, false );
	CMD_ADDSERVERCOMMAND( "cvarall", "cva", "cvarall <cvarname> <newval>", ::CMD_CVARALL_f, "cheat", 2, false );
	CMD_ADDSERVERCOMMAND( "givegod", "ggd", "givegod <name|guid|clientnum|self>", ::CMD_GIVEGOD_f, "cheat", 1, true );
	CMD_ADDSERVERCOMMAND( "givenotarget", "gnt", "givenotarget <name|guid|clientnum|self>", ::CMD_GIVENOTARGET_f, "cheat", 1, true );
	CMD_ADDSERVERCOMMAND( "giveinvisible", "ginv", "giveinvisible <name|guid|clientnum|self>", ::CMD_GIVEINVISIBLE_f, "cheat", 1, true );
	CMD_ADDSERVERCOMMAND( "setrank", "sr", "setrank <name|guid|clientnum|self> <rank>", ::CMD_SETRANK_f, "cheat", 2, false );

	CMD_ADDSERVERCOMMAND( "execonallplayers", "execonall exall", "execonallplayers <cmdname> [cmdargs] ...", ::CMD_EXECONALLPLAYERS_f, "host", 1, false );
	CMD_ADDSERVERCOMMAND( "execonteam", "execteam exteam", "execonteam <team> <cmdname> [cmdargs] ...", ::CMD_EXECONTEAM_f, "host", 2, false );

	CMD_ADDSERVERCOMMAND( "cmdlist", "cl", "cmdlist", ::CMD_CMDLIST_f, "none", 0, false, true );
	CMD_ADDSERVERCOMMAND( "playerlist", "plist", "playerlist [team]", ::CMD_PLAYERLIST_f, "none", 0, false, true );
	cmd_addservercommand( "entitylist", "elist", "entitylist [targetname]", ::cmd_entitylist_f, "cheat", 0, false );

	cmd_addservercommand( "help", undefined, "help [cmdalias]", ::cmd_help_f, "none", 0, false );

	cmd_addservercommand( "unittest", undefined, "unittest [botcount] [duration]", ::cmd_unittest_validargs_f, "host", 0, false );
	cmd_addservercommand( "testcmd", undefined, "testcmd <cmdalias> [threadcount] [duration]", ::cmd_testcmd_f, "host", 1, false );
	//cmd_addservercommand( "unittestinvalidargs", "uinvalid", "unittest [botcount]", ::cmd_unittest_invalidargs_f, "host", 0, false );

	cmd_addservercommand( "dodamage", "dd", "dodamage <entitynum|targetname|self> <damage> <origin> [entitynum|targetname|self] [entitynum|targetname|self] [hitloc] [MOD] [idflags] [weapon]", ::cmd_dodamage_f, "cheat", 3, false );

	cmd_register_arg_types_for_server_cmd( "givegod", "player" );
	cmd_register_arg_types_for_server_cmd( "givenotarget", "player" );
	cmd_register_arg_types_for_server_cmd( "giveinvisible", "player" );
	cmd_register_arg_types_for_server_cmd( "setrank", "player rank" );
	cmd_register_arg_types_for_server_cmd( "execonallplayers", "cmdalias" );
	cmd_register_arg_types_for_server_cmd( "execonteam", "team cmdalias" );
	cmd_register_arg_types_for_server_cmd( "playerlist", "team" );
	cmd_register_arg_types_for_server_cmd( "help", "cmdalias" );
	cmd_register_arg_types_for_server_cmd( "unittest", "int" );
	cmd_register_arg_types_for_server_cmd( "testcmd", "cmdalias wholenum wholenum" );
	cmd_register_arg_types_for_server_cmd( "dodamage", "entity float vector entity entity hitloc MOD idflags weapon" );

	level.client_commands = [];
	CMD_ADDCLIENTCOMMAND( "togglehud", "toghud", "togglehud", ::CMD_TOGGLEHUD_f, "none", 0, false );
	CMD_ADDCLIENTCOMMAND( "god", undefined, "god", ::CMD_GOD_f, "cheat", 0, true );
	CMD_ADDCLIENTCOMMAND( "notarget", "nt", "notarget", ::CMD_NOTARGET_f, "cheat", 0, true );
	CMD_ADDCLIENTCOMMAND( "invisible", "invis", "invisible", ::CMD_INVISIBLE_f, "cheat", 0, true );
	CMD_ADDCLIENTCOMMAND( "printorigin", "printorg por", "printorigin", ::CMD_PRINTORIGIN_f, "none", 0, false );
	CMD_ADDCLIENTCOMMAND( "printangles", "printang pan", "printangles", ::CMD_PRINTANGLES_f, "none", 0, false );
	CMD_ADDCLIENTCOMMAND( "bottomlessclip", "botclip bcl", "bottomlessclip", ::CMD_BOTTOMLESSCLIP_f, "cheat", 0, true );
	CMD_ADDCLIENTCOMMAND( "teleport", "tele", "teleport <name|guid|clientnum>", ::CMD_TELEPORT_f, "cheat", 1, false );
	CMD_ADDCLIENTCOMMAND( "cvar", "cv", "cvar <cvarname> <newval>", ::CMD_CVAR_f, "cheat", 2, false );

	cmd_register_arg_types_for_client_cmd( "teleport", "player" );

	cmd_register_arg_type_handlers( "player", ::arg_player_handler, ::arg_generate_rand_player, ::arg_cast_to_player, "not a valid player" );
	cmd_register_arg_type_handlers( "wholenum", ::arg_wholenum_handler, ::arg_generate_rand_wholenum, ::arg_cast_to_int, "not a whole number" );
	cmd_register_arg_type_handlers( "int", ::arg_int_handler, ::arg_generate_rand_int, ::arg_cast_to_int, "not an int" );
	cmd_register_arg_type_handlers( "float", ::arg_float_handler, ::arg_generate_rand_float, ::arg_cast_to_float, "not a float" );
	cmd_register_arg_type_handlers( "wholefloat", ::arg_wholefloat_handler, ::arg_generate_rand_wholefloat, ::arg_cast_to_float, "not a float greater than 0" );
	cmd_register_arg_type_handlers( "vector", ::arg_vector_handler, ::arg_generate_rand_vector, ::arg_cast_to_vector, "not a valid vector, format is float,float,float" );
	cmd_register_arg_type_handlers( "team", ::arg_team_handler, ::arg_generate_rand_team, undefined, "not a valid team" );
	cmd_register_arg_type_handlers( "cmdalias", ::arg_cmdalias_handler, ::arg_generate_rand_cmdalias, ::arg_cast_to_cmd, "not a valid cmdalias" );
	cmd_register_arg_type_handlers( "rank", ::arg_rank_handler, ::arg_generate_rand_rank, undefined, "not a valid rank" );
	cmd_register_arg_type_handlers( "entity", ::arg_entity_handler, ::arg_generate_rand_entity, ::arg_cast_to_entity, "not a valid entity" );
	cmd_register_arg_type_handlers( "hitloc", ::arg_hitloc_handler, ::arg_generate_rand_hitloc, undefined, "not a valid hitloc" );
	cmd_register_arg_type_handlers( "MOD", ::arg_mod_handler, ::arg_generate_rand_mod, ::arg_cast_to_mod, "not a valid mod" );
	cmd_register_arg_type_handlers( "idflags", ::arg_idflags_handler, ::arg_generate_rand_idflags, ::arg_cast_to_int, "not a valid idflag" );

	//exclude_clientcommand_from_unittest_pool();
	//exclude_servercommand_from_unittest_pool();

	build_hitlocs_array();
	build_mods_array();
	build_idflags_array();
	
	if ( !isDedicated() )
	{
		if ( getDvarInt( "g_logsync" ) != 2 )
		{
			setDvar( "g_logsync", 2 );
		}
		if ( getDvar( "g_log" ) == "" )
		{
			if ( sessionModeIsZombiesGame() )
			{
				setDvar( "g_log", "logs\games_zm.log" );
			}
			else 
			{
				setDvar( "g_log", "logs\games_mp.log" );
			}
		}
	}
	
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
		arg_list = [];
		arg_list[ 0 ] = getDvarInt( "tcs_unittest" );
		cmd_unittest_validargs_f( arg_list );
	}
}

scr_dvar_command_watcher()
{
	level endon( "end_commands" );
	wait 1;
	setDvar( "tcscmd", "" );
	while ( true )
	{
		parse_command_dvar();
		wait 0.05;
	}
}

parse_command_dvar()
{
	dvar_value = getDvar( "tcscmd" );
	if ( dvar_value != "" )
	{
		level notify( "say", dvar_value, undefined, false );
		setDvar( "tcscmd", "" );
	}
	dvar_value = undefined;
}
	
COMMAND_BUFFER()
{
	level endon( "end_commands" );
	while ( true )
	{
		level waittill( "say", message, player, isHidden );
		cmd_execute( message, player, isHidden );
	}
}

cmd_execute( message, player, is_hidden )
{
	if ( isDefined( player ) && !is_hidden && !is_command_token( message[ 0 ] ) )
	{
		return;
	}
	if ( !isDefined( player ) )
	{
		if ( isDedicated() )
		{
			player = level.server;
		}
		else 
		{
			player = level.host;
		}
	}
	channel = player COM_GET_CMD_FEEDBACK_CHANNEL();
	if ( isDefined( player.cmd_cooldown ) && player.cmd_cooldown > 0 )
	{
		level COM_PRINTF( channel, "cmderror", "You cannot use another command for " + player.cmd_cooldown + " seconds", player );
		return;
	}
	message = toLower( message );
	multi_cmds = parse_cmd_message( message );
	if ( multi_cmds.size < 1 )
	{
		level COM_PRINTF( channel, "cmderror", "Invalid command", player );
		return;
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
			if ( is_clientcmd && is_true( player.is_server ) )
			{
				level com_printf( channel, "cmderror", "You cannot use " + cmdname + " client command as the server", player );
			}
			else 
			{
				player cmd_execute_internal( cmdname, args, is_clientcmd, false, level.tcs_logprint_cmd_usage );
				player thread cmd_cooldown();
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
		player on_connect_internal();
	}
}

on_connect_internal()
{
	is_bot = is_true( self.pers[ "isBot" ] );
	if ( is_bot )
	{
		if ( is_true( level.doing_command_system_testcmd ) )
		{
			if ( isDefined( self.specific_cmd ) )
			{
				self thread activate_specific_cmd();
			}
		}
		else if ( is_true( level.doing_command_system_unittest ) )
		{
			self thread activate_random_cmds();
		}
	}

	foreach ( index, dvar in level.clientdvars )
	{
		self thread setClientDvarThread( dvar[ "name" ], dvar[ "value" ], index );
	}
	found_entry = false;
	if ( self isHost() )
	{
		self.cmdpower = level.CMD_POWER_HOST;
		self.tcs_rank = level.TCS_RANK_HOST;
		level.host = self;
		found_entry = true;
	}
	else if ( array_validate( level.tcs_player_entries ) )
	{
		foreach ( entry in level.tcs_player_entries )
		{
			player_in_server = level.server cast_str_to_player( entry.player_entry, true );
			if ( isDefined( player_in_server ) && player_in_server == self )
			{
				self.cmdpower = entry.cmdpower;
				self.tcs_rank = entry.rank;
				found_entry = true;
			}
		}
	}
	if ( !is_true( found_entry ) )
	{
		self.cmdpower = getDvarIntDefault( "tcs_cmdpower_default", level.CMD_POWER_USER );
		self.tcs_rank = getDvarStringDefault( "tcs_default_rank", level.TCS_RANK_USER );
	}
	self._connected = true;
}