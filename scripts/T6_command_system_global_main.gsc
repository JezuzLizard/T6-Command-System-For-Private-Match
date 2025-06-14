
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_debug;
#include scripts\cmd_system_modules\_perms;
#include scripts\cmd_system_modules\global_client_commands;
#include scripts\cmd_system_modules\global_commands;

#include common_scripts\utility;
#include maps\mp\_utility;

main()
{
	com_init();
	//config_load();
	level.tcs_glob = spawnstruct();
	level.tcs_sv = spawnStruct();
	level.tcs_sv.playername = getdvar( "sv_hostname" );
	level.tcs_sv.bis_server = true;
	level.tcs_sv.name = tcs_sv.playername;
	level.tcs_glob.irestart_countdown = 5;
	level.tcs_glob.icmd_total = 0;
	level.tcs_glob.icooldown = getdvarintdefault( "tcs_cmd_cd", 5 );
	level.tcs_glob.bsilent_cmds = getdvarintdefault( "tcs_silent_cmds", 0 );
	level.tcs_glob.blog_cmds = getdvarintdefault( "tcs_logprint_cmd_usage", 1 );
	level.tcs_glob.bhidden_cmds = getdvarintdefault( "tcs_allow_hidden_cmds", 1 );

	tcs_default_ranks = array( "none", "user", "trusted", "elevated", "moderator", "cheat", "host", "owner" );
	tcs_default_ranks_cmdpower = array( 0, 1, 20, 40, 60, 80, 100, 100 );
	tcs_perms = spawnstruct();
	tcs_perms.ranks = [];
	for ( i = 0; i < tcs_default_ranks.size; i++ )
	{
		rank = tcs_default_ranks[ i ];
		allowedcmds_dvar = getdvarstringdefault( "tcs_rank_" + rank + "_allowedcmds", "" );
		disallowedcmds_dvar = getdvarstringdefault( "tcs_rank_" + rank + "_disallowedcmds", "" );
		cmdpower_dvar = getdvarintdefault( "tcs_rank_" + rank + "_cmdpower", tcs_default_ranks_cmdpower[ i ] );
		tcs_perms.ranks[ rank ] = spawnStruct();
		tcs_perms.ranks[ rank ].allowedcmds = allowedcmds_dvar != "" ? strtok( allowedcmds_dvar, " " ) : undefined;
		tcs_perms.ranks[ rank ].disallowedcmds = disallowedcmds_dvar != "" ? strtok( disallowedcmds_dvar, " " ) : undefined;
		tcs_perms.ranks[ rank ].cmdpower = cmdpower_dvar;
	}

	custom_ranks_str = getdvarstringdefault( "tcs_custom_rank_names", "" );
	custom_ranks = custom_ranks_str != "" ? strtok( custom_ranks_str, " " ) : undefined;
	if ( isdefined( custom_ranks ) )
	{
		for ( i = 0; i < custom_ranks.size; i++ )
		{
			rank = custom_ranks[ i ];
			allowedcmds_dvar = getdvarstringdefault( "tcs_rank_" + rank + "_allowedcmds", "" );
			disallowedcmds_dvar = getdvarstringdefault( "tcs_rank_" + rank + "_disallowedcmds", "" );
			cmdpower_dvar = getdvarintdefault( "tcs_rank_" + rank + "_cmdpower", 0 );
			tcs_perms.ranks[ rank ] = spawnstruct();
			tcs_perms.ranks[ rank ].allowedcmds = allowedcmds_dvar != "" ? strtok( allowedcmds_dvar, " " ) : undefined;
			tcs_perms.ranks[ rank ].disallowedcmds = disallowedcmds_dvar != "" ? strtok( disallowedcmds_dvar, " " ) : undefined;
			tcs_perms.ranks[ rank ].cmdpower = cmdpower_dvar;
		}
	}
	level.tcs_perms = tcs_perms;

	level.clientdvars = [];
	tokens_str = getdvarstringdefault( "tcs_cmd_tokens", "" ); //separated by spaces, good tokens are generally not used at the start of a normal message 
	if ( tokens_str != "" )
	{
		tokens = strtok( tokens_str, " " );
		for ( i = 0; i < tokens.size; i++ )
		{
			level.custom_cmds_tokens[ tokens[ i ] ] = tokens[ i ];
		}
	}
	// "\" is always useable by default
	cmd_perms_init();
	level.tcs_add_cmd_func = ::cmd_add;
	level.tcs_set_cmd_power_func = ::cmd_set_power;
	level.tcs_remove_cmd = ::cmd_remove;
	level.tcs_remove_cmd_by_group = ::cmd_remove_by_group;
	level.tcs_com_printf = ::com_printf;
	level.tcs_com_get_feedback_channel = ::com_get_cmd_feedback_channel;
	level.tcs_find_player_in_server = ::cast_str_to_player;
	level.tcs_check_cmd_collisions = ::check_for_cmd_alias_collisions;
	level.tcs_player_is_valid_check = scripts\cmd_system_modules\_cmd_util::is_player_valid;
	level.tcs_debug_create_random_valid_args = ::create_random_valid_args2;
	level.tcs_repackage_args = ::repackage_args;
	cmd_add( "setcvar", false, "scv", "setcvar <name|guid|clientnum|self> <cvarname> <newval>", ::cmd_setcvar_f, "cheat", 3, false );
	cmd_add( "dvar", false, "dv", "dvar <dvarname> <newval>", ::cmd_server_dvar_f, "cheat", 2, false );
	cmd_add( "cvarall", false, "cva", "cvarall <cvarname> <newval>", ::cmd_cvarall_f, "cheat", 2, false );
	cmd_add( "givegod", false, "ggd", "givegod <name|guid|clientnum|self>", ::cmd_givegod_f, "cheat", 1, true );
	cmd_add( "givenotarget", false, "gnt", "givenotarget <name|guid|clientnum|self>", ::cmd_givenotarget_f, "cheat", 1, true );
	cmd_add( "giveinvisible", false, "ginv", "giveinvisible <name|guid|clientnum|self>", ::cmd_giveinvisible_f, "cheat", 1, true );
	cmd_add( "setrank", false, "sr", "setrank <name|guid|clientnum|self> <rank>", ::cmd_setrank_f, "cheat", 2, false );

	cmd_add( "execonallplayers", false, "execonall exall", "execonallplayers <cmd> [cmdargs] ...", ::cmd_execonallplayers_f, "host", 1, false );
	cmd_add( "execonteam", false, "execteam exteam", "execonteam <team> <cmd> [cmdargs] ...", ::cmd_execonteam_f, "host", 2, false );

	cmd_add( "cmdlist", false, "cl", "cmdlist", ::cmd_cmdlist_f, "none", 0, false );
	cmd_add( "playerlist", false, "plist", "playerlist [team]", ::cmd_playerlist_f, "none", 0, false );
	cmd_add( "entitylist", false, "elist", "entitylist [targetname]", ::cmd_entitylist_f, "cheat", 0, false );

	cmd_add( "help", false, undefined, "help [cmdalias]", ::cmd_help_f, "none", 0, false );

	cmd_add( "unittest", false, undefined, "unittest [botcount] [duration]", ::cmd_unittest_validargs_f, "host", 0, false );
	cmd_add( "testcmd", false, undefined, "testcmd <cmdalias> [threadcount] [duration]", ::cmd_testcmd_f, "host", 1, false );
	//cmd_add( "unittestinvalidargs", "uinvalid", "unittest [botcount] [duration]", ::cmd_unittest_invalidargs_f, "host", 0, false );

	cmd_add( "dodamage", false, "dd", "dodamage <entitynum|classname|targetname|self> <damage> <origin> [entitynum|classname|targetname|self] [entitynum|classname|targetname|self] [hitloc] [MOD] [idflags] [weapon]", ::cmd_dodamage_f, "cheat", 3, false );

	cmd_add( "teleportplayer", false, "tp", "teleportplayer <name|guid|clientnum|self> <name|guid|clientnum>", ::cmd_teleportplayer_f, "cheat", 2, false );

	arg_obj_add_cmd( "givegod", "player" );
	arg_obj_add_cmd( "givenotarget", "player" );
	arg_obj_add_cmd( "giveinvisible", "player" );
	arg_obj_add_cmd( "setrank", "player rank" );
	arg_obj_add_cmd( "execonallplayers", "cmdalias" );
	arg_obj_add_cmd( "execonteam", "team cmdalias" );
	arg_obj_add_cmd( "playerlist", "team" );
	arg_obj_add_cmd( "help", "cmdalias" );
	arg_obj_add_cmd( "unittest", "wholenum wholenum" );
	arg_obj_add_cmd( "testcmd", "cmdalias wholenum wholenum" );
	arg_obj_add_cmd( "dodamage", "entity float vector entity entity hitloc MOD idflags weapon" );
	arg_obj_add_cmd( "teleportplayer", "player player" );

	cmd_add( "togglehud", true, "toghud", "togglehud", ::cmd_togglehud_f, "none", 0, false );
	cmd_add( "god", true, undefined, "god", ::cmd_god_f, "cheat", 0, true );
	cmd_add( "notarget", true, "nt", "notarget", ::cmd_notarget_f, "cheat", 0, true );
	cmd_add( "invisible", true, "invis", "invisible", ::cmd_invisible_f, "cheat", 0, true );
	cmd_add( "printorigin", true, "printorg por", "printorigin", ::cmd_printorigin_f, "none", 0, false );
	cmd_add( "printangles", true, "printang pan", "printangles", ::cmd_printangles_f, "none", 0, false );
	cmd_add( "bottomlessclip", true, "botclip bcl", "bottomlessclip", ::cmd_bottomlessclip_f, "cheat", 0, true );
	cmd_add( "teleport", true, "tele", "teleport <name|guid|clientnum>", ::cmd_teleport_f, "cheat", 1, false );
	cmd_add( "cvar", true, "cv", "cvar <cvarname> <newval>", ::cmd_cvar_f, "cheat", 2, false );
	cmd_add( "printentitiesinradius", true, "peir", "printentitiesinradius [radius=1000] [classname|targetname|script_noteworthy]", ::cmd_printentitiesinradius_f, "cheat", 0, false );

	arg_obj_add_cmd( "teleport", "player" );
	arg_obj_add_cmd( "printentitiesinradius", "float" );

	arg_obj_register( "player", ::arg_obj_player_validate, ::arg_obj_player_generate, ::arg_obj_player_cast, "not a valid player" );
	//arg_obj_register( "playernotself", ::arg_obj_playernotself_validate, ::arg_obj_generate_rand_playernotself, ::arg_obj_cast_to_player, "not a valid player(cannot be self)" );
	arg_obj_register( "wholenum", ::arg_obj_wholenum_validate, ::arg_obj_wholenum_generate, ::arg_obj_wholenum_cast, "not a whole number" );
	arg_obj_register( "boolean", ::arg_obj_boolean_validate, ::arg_obj_boolean_generate, ::arg_obj_boolean_cast, "not a boolean" );
	arg_obj_register( "int", ::arg_obj_int_validate, ::arg_obj_int_generate, ::arg_obj_int_cast, "not an int" );
	arg_obj_register( "float", ::arg_obj_float_validate, ::arg_obj_float_generate, ::arg_obj_float_cast, "not a float" );
	arg_obj_register( "wholefloat", ::arg_obj_wholefloat_validate, ::arg_obj_wholefloat_generate, ::arg_obj_wholefloat_cast, "not a float greater than 0" );
	arg_obj_register( "vector", ::arg_obj_vector_validate, ::arg_obj_vector_generate, ::arg_obj_vector_cast, "not a valid vector, format is float,float,float" );
	arg_obj_register( "team", ::arg_obj_team_validate, ::arg_obj_team_generate, undefined, "not a valid team" );
	arg_obj_register( "cmdalias", ::arg_obj_cmdalias_validate, ::arg_obj_cmdalias_generate, ::arg_obj_cmdalias_cast, "not a valid cmdalias" );
	arg_obj_register( "rank", ::arg_obj_rank_validate, ::arg_obj_rank_generate, undefined, "not a valid rank" );
	arg_obj_register( "entity", ::arg_obj_entity_validate, ::arg_obj_entity_generate, ::arg_obj_entity_cast, "not a valid entity" );
	arg_obj_register( "hitloc", ::arg_obj_hitloc_validate, ::arg_obj_hitloc_generate, undefined, "not a valid hitloc" );
	arg_obj_register( "MOD", ::arg_obj_mod_validate, ::arg_obj_mod_generate, ::arg_obj_mod_cast, "not a valid mod" );
	arg_obj_register( "idflags", ::arg_obj_idflags_validate, ::arg_obj_idflags_generate, ::arg_obj_idflags_cast, "not a valid idflag" );
	arg_obj_register( "bot", ::arg_obj_bot_handler, ::arg_obj_bot_generate, ::arg_obj_bot_cast, "not a valid bot" );

	//exclude_clientcmd_from_unittest_pool();
	//exclude_servercmd_from_unittest_pool();

	scripts\cmd_system_modules\_consts::build_hitlocs_array();
	scripts\cmd_system_modules\_consts::build_mods_array();
	scripts\cmd_system_modules\_consts::build_idflags_array();
	
	if ( !isdedicated() )
	{
		if ( getdvarint( "g_logsync" ) != 2 )
		{
			setdvar( "g_logsync", 2 );
		}
		if ( getdvar( "g_log" ) == "" )
		{
			if ( sessionmodeiszombiesgame() )
			{
				setdvar( "g_log", "logs\games_zm.log" );
			}
			else 
			{
				setdvar( "g_log", "logs\games_mp.log" );
			}
		}
	}
	
	level thread cmd_buffer();
	level thread end_cmds_on_end_game();
	level thread scr_dvar_cmd_watcher();
	level thread tcs_on_connect();
	level thread check_for_cmd_alias_collisions();
	level.cmd_init_done = true;
}

init()
{
	do_unit_test = getdvarintdefault( "tcs_unittest", 0 ) > 0;
	if ( do_unit_test )
	{
		args = [];
		args[ 0 ] = getdvarInt( "tcs_unittest" );
		cmd_unittest_validargs_f( args );
	}
}

scr_dvar_cmd_watcher()
{
	level endon( "end_cmds" );
	wait 1;
	setDvar( "tcscmd", "" );
	setDvar( "sv_tcscmd", "" );
	while ( true )
	{
		parse_cmd_dvar();
		wait 0.05;
	}
}

parse_cmd_dvar()
{
	dvar_value = getdvar( "tcscmd" );
	if ( dvar_value != "" )
	{
		tokens = strtok( dvar_value, " " );
		player = undefined;
		if ( tokens.size > 0 )
		{
			player = cast_str_to_player( tokens[ 0 ] );
		}
		level notify( "say", dvar_value, player, false, true );
		setDvar( "tcscmd", "" );
	}

	dvar_value = getdvar( "sv_tcscmd" );
	if ( dvar_value != "" )
	{
		level notify( "say", dvar_value, undefined, false, true );
		setDvar( "sv_tcscmd", "" );
	}
	dvar_value = undefined;
}
	
cmd_buffer()
{
	level endon( "end_cmds" );
	while ( true )
	{
		level waittill( "say", message, player, is_hidden, from_rcon );
		cmd_execute( message, player, is_hidden, from_rcon );
	}
}

cmd_execute( message, player, is_hidden, from_rcon )
{
	if ( isdefined( player ) && !from_rcon )
	{
		if ( !level.tcs_allow_hidden_cmds && is_hidden )
		{
			level com_printf( channel, "cmderror", "Hidden cmds are not allowed", player );
			return;
		}
		else if ( !is_hidden && !is_cmd_token( message[ 0 ] ) )
		{
			return;
		}
	}
	else
	{
		if ( isdedicated() )
		{
			player = level.server;
		}
		else 
		{
			player = level.host;
		}
	}
	channel = player com_get_feedback_channel();
	if ( !from_rcon && isDefined( player.cmd_cooldown ) && player.cmd_cooldown > 0 )
	{
		level com_printf( channel, "cmderror", "You cannot use another cmd for " + player.cmd_cooldown + " seconds", player );
		return;
	}
	message = tolower( message );
	multi_cmds = parse_cmd_message( message );
	if ( multi_cmds.size < 1 )
	{
		level com_printf( channel, "cmderror", "Invalid cmd", player );
		return;
	}
	if ( multi_cmds.size > 1 && !player can_use_multi_cmds() && !from_rcon )
	{
		temp_array_index = multi_cmds[ 0 ];
		multi_cmds = [];
		multi_cmds[ 0 ] = temp_array_index;
		level com_printf( channel, "cmdwarning", "You do not have permission to use multi cmds; only executing the first cmd" );
	}
	for ( cmd_index = 0; cmd_index < multi_cmds.size; cmd_index++ )
	{
		cmd = multi_cmds[ cmd_index ][ "cmd" ];
		args = multi_cmds[ cmd_index ][ "args" ];
		if ( !player has_permission_for_cmd( cmd ) && !from_rcon )
		{
			level com_printf( channel, "cmderror", "You do not have permission to use " + cmd + " cmd", player );
		}
		else
		{
			if ( level.tcs_cmds[ cmd ].is_clientcmd && is_true( player.is_server ) )
			{
				level com_printf( channel, "cmderror", "You cannot use " + cmd + " client cmd as the server", player );
			}
			else 
			{
				player cmd_execute_internal( cmd, args, getdvarintdefault( "tcs_silent_cmds", 0 ), getdvarintdefault( "tcs_logprint_cmd_usage", 1 ) );
				player thread cmd_cooldown();
			}
		}
	}
}

end_cmds_on_end_game()
{
	level waittill_either( "end_game", "game_ended" );
	wait 10;
	level notify( "end_cmds" );
}

tcs_on_connect()
{
	level endon( "end_cmds" );
	while ( true )
	{
		level waittill( "connected", player );
		player on_connect_internal();
	}
}

tcs_p_obj_new()
{
	tcs_pl_obj = spawnstruct();
	tcs_pl_obj.power = getdvarintdefault( "tcs_cmdpower_default", level.CMD_POWER_USER );
	tcs_pl_obj.rank = getdvarstringdefault( "tcs_default_rank", level.TCS_RANK_USER );
	return tcs_pl_obj;
}

on_connect_internal()
{
	tcs_pl_obj = tcs_p_obj_new();
	self.tcs_pl = tcs_pl_obj;
	is_bot = is_true( self.pers[ "isBot" ] );
	if ( is_bot )
	{
		if ( is_true( level.doing_cmd_system_testcmd ) )
		{
			if ( isdefined( self.specific_cmd ) )
			{
				self thread activate_specific_cmd();
			}
		}
		else if ( is_true( level.doing_cmd_system_unittest ) )
		{
			self thread activate_random_cmds();
		}
	}

	foreach ( index, dvar in level.clientdvars )
	{
		self thread set_client_dvar_thread( dvar[ "name" ], dvar[ "value" ], index );
	}
	found_entry = false;
	if ( self ishost() )
	{
		self.tcs_pl.power = level.CMD_POWER_HOST;
		self.tcs_pl.rank = level.TCS_RANK_HOST;
		level.host = self;
		found_entry = true;
	}
	else if ( array_validate( level.tcs_player_entries ) )
	{
		foreach ( entry in level.tcs_player_entries )
		{
			player_in_server = level.server cast_str_to_player( entry.player_entry, true );
			if ( isdefined( player_in_server ) && player_in_server == self )
			{
				self.tcs_pl.power = entry.power;
				self.tcs_pl.rank = entry.rank;
				found_entry = true;
			}
		}
	}
	if ( !is_true( found_entry ) )
	{
		self.tcs_pl.power = getdvarintdefault( "tcs_cmd_power_default", level.CMD_POWER_USER );
		self.tcs_pl.rank = getdvarstringdefault( "tcs_default_rank", level.TCS_RANK_USER );
	}
	self._connected = true;
}