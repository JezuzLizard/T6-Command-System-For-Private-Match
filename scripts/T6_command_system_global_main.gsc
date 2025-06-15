#include scripts\cmd_system_modules\_cmd_arg;
#include scripts\cmd_system_modules\_cmd_execute;
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
	level.server = spawnStruct();
	level.server.playername = getdvar( "sv_hostname" );
	level.server.name = getdvar( "sv_hostname" );
	level.server.is_server = true;
	level.tcs_glob = spawnstruct();
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
	cmd_init_perms();
	level.tcs_add_cmd_func = ::cmd_add;
	level.tcs_set_cmd_power_func = ::cmd_set_power;
	level.tcs_remove_cmd = ::cmd_remove;
	level.tcs_remove_cmd_by_group = ::cmd_remove_by_group;
	level.tcs_com_printf = ::com_printf;
	level.tcs_com_get_feedback_channel = ::com_get_cmd_feedback_channel;
	level.tcs_find_player_in_server = ::cast_str_to_player;
	level.tcs_check_cmd_collisions = ::check_for_cmd_alias_collisions;
	level.tcs_player_is_valid_check = ::is_player_valid;
	level.tcs_debug_create_random_valid_args = ::create_random_valid_args2;
	level.tcs_repackage_args = ::repackage_args;

	cmd_block_set_rank_group( "cheat" );
	setcvar_cmd = cmd_add( "setcvar", false, "scv", "setcvar <name|guid|clientnum|self> <cvarname> <newval>", ::cmd_setcvar_f );
	setcvar_cmd arg_obj_add_cmd( "player string string", 3, 3 );

	dvar_cmd = cmd_add( "dvar", false, "dv", "dvar <dvarname> <newval>", ::cmd_server_dvar_f );
	dvar_cmd arg_obj_add_cmd( "string string", 2, 2 );

	cvarall_cmd = cmd_add( "cvarall", false, "cva", "cvarall <cvarname> <newval>", ::cmd_cvarall_f );
	cvarall_cmd arg_obj_add_cmd( "string string", 2, 2 );

	givegod_cmd = cmd_add( "givegod", false, "ggd", "givegod <name|guid|clientnum|self>", ::cmd_givegod_f, true );
	givegod_cmd arg_obj_add_cmd( "player", 1, 1 );

	givenotarget_cmd = cmd_add( "givenotarget", false, "gnt", "givenotarget <name|guid|clientnum|self>", ::cmd_givenotarget_f, true );
	givenotarget_cmd arg_obj_add_cmd( "player", 1, 1 );

	giveinvisible_cmd = cmd_add( "giveinvisible", false, "ginv", "giveinvisible <name|guid|clientnum|self>", ::cmd_giveinvisible_f, true );
	giveinvisible_cmd arg_obj_add_cmd( "player", 1, 1 );

	setrank_cmd = cmd_add( "setrank", false, "sr", "setrank <name|guid|clientnum|self> <rank>", ::cmd_setrank_f );
	setrank_cmd arg_obj_add_cmd( "player rank", 2, 2 );

	entitylist_cmd = cmd_add( "entitylist", false, "elist", "entitylist [targetname]", ::cmd_entitylist_f );
	entitylist_cmd arg_obj_add_cmd( "string", 0, 1 );

	execonallplayers_cmd = cmd_add( "execonallplayers", false, "execonall exall", "execonallplayers <cmd> [cmdargs] ...", ::cmd_execonallplayers_f );
	execonallplayers_cmd arg_obj_add_cmd( "cmdalias", 1, 255 );

	execonteam_cmd = cmd_add( "execonteam", false, "execteam exteam", "execonteam <team> <cmd> [cmdargs] ...", ::cmd_execonteam_f );
	execonteam_cmd arg_obj_add_cmd( "team cmdalias", 2, 255 );

	unittest_cmd = cmd_add( "unittest", false, undefined, "unittest [botcount] [duration]", ::cmd_unittest_validargs_f );
	unittest_cmd arg_obj_add_cmd( "wholenum wholenum", 0, 2 );

	testcmd_cmd = cmd_add( "testcmd", false, undefined, "testcmd <cmdalias> [threadcount] [duration]", ::cmd_testcmd_f );
	testcmd_cmd arg_obj_add_cmd( "cmdalias wholenum wholenum", 1, 3 );

	dodamage_cmd = cmd_add( "dodamage", false, "dd", "dodamage <entitynum|classname|targetname|self> <damage> <origin> [entitynum|classname|targetname|self] [entitynum|classname|targetname|self] [hitloc] [MOD] [idflags] [weapon]", ::cmd_dodamage_f );
	dodamage_cmd arg_obj_add_cmd( "entity float vector entity entity hitloc MOD idflags weapon", 3, 9 );

	teleportplayer_cmd = cmd_add( "teleportplayer", false, "tp", "teleportplayer <name|guid|clientnum|self> <name|guid|clientnum>", ::cmd_teleportplayer_f );
	teleportplayer_cmd arg_obj_add_cmd( "player player", 2, 2 );

	god_cmd = cmd_add( "god", true, undefined, "god", ::cmd_god_f, true );
	god_cmd arg_obj_add_cmd( "", 0, 0 );

	notarget_cmd = cmd_add( "notarget", true, "nt", "notarget", ::cmd_notarget_f, true );
	notarget_cmd arg_obj_add_cmd( "", 0, 0 );

	invisible_cmd = cmd_add( "invisible", true, "invis", "invisible", ::cmd_invisible_f, true );
	invisible_cmd arg_obj_add_cmd( "", 0, 0 );

	bottomlessclip_cmd = cmd_add( "bottomlessclip", true, "botclip bcl", "bottomlessclip", ::cmd_bottomlessclip_f, true );
	bottomlessclip_cmd arg_obj_add_cmd( "", 0, 0 );

	teleport_cmd = cmd_add( "teleport", true, "tele", "teleport <name|guid|clientnum>", ::cmd_teleport_f );
	teleport_cmd arg_obj_add_cmd( "player", 1, 1 );

	cvar_cmd = cmd_add( "cvar", true, "cv", "cvar <cvarname> <newval>", ::cmd_cvar_f, 2 );
	cvar_cmd arg_obj_add_cmd( "string string", 2, 2 );

	printentitiesinradius_cmd = cmd_add( "printentitiesinradius", true, "peir", "printentitiesinradius [radius=1000] [classname|targetname|script_noteworthy]", ::cmd_printentitiesinradius_f );
	printentitiesinradius_cmd arg_obj_add_cmd( "float string", 0, 2 );

	cmd_block_set_rank_group( "none" );
	cmdlist_cmd = cmd_add( "cmdlist", false, "cl", "cmdlist", ::cmd_cmdlist_f );
	cmdlist_cmd arg_obj_add_cmd( "team cmdalias", 0, 0 );

	playerlist_cmd = cmd_add( "playerlist", false, "plist", "playerlist [team]", ::cmd_playerlist_f );
	playerlist_cmd arg_obj_add_cmd( "team", 0, 1 );

	printorigin_cmd = cmd_add( "printorigin", true, "printorg por", "printorigin", ::cmd_printorigin_f );
	printorigin_cmd arg_obj_add_cmd( "", 0, 0 );

	printangles_cmd = cmd_add( "printangles", true, "printang pan", "printangles", ::cmd_printangles_f );
	printangles_cmd arg_obj_add_cmd( "", 0, 0 );

	help_cmd = cmd_add( "help", false, undefined, "help [cmdalias]", ::cmd_help_f );
	help_cmd arg_obj_add_cmd( "cmdalias", 0, 1 );

	togglehud_cmd = cmd_add( "togglehud", true, "toghud", "togglehud", ::cmd_togglehud_f );
	togglehud_cmd arg_obj_add_cmd( "", 0, 0 );

	arg_obj_register( "player", ::arg_obj_player_validate, ::arg_obj_player_generate, ::arg_obj_player_cast, "not a valid player" );
	//arg_obj_register( "playernotself", ::arg_obj_playernotself_validate, ::arg_obj_generate_rand_playernotself, ::arg_obj_cast_to_player, "not a valid player(cannot be self)" );
	arg_obj_register( "wholenum", ::arg_obj_wholenum_validate, ::arg_obj_wholenum_generate, ::arg_obj_int_cast, "not a whole number" );
	arg_obj_register( "boolean", ::arg_obj_boolean_validate, ::arg_obj_boolean_generate, ::arg_obj_boolean_cast, "not a boolean" );
	arg_obj_register( "int", ::arg_obj_int_validate, ::arg_obj_int_generate, ::arg_obj_int_cast, "not an int" );
	arg_obj_register( "float", ::arg_obj_float_validate, ::arg_obj_float_generate, ::arg_obj_float_cast, "not a float" );
	arg_obj_register( "wholefloat", ::arg_obj_wholefloat_validate, ::arg_obj_wholefloat_generate, ::arg_obj_float_cast, "not a float greater than 0" );
	arg_obj_register( "vector", ::arg_obj_vector_validate, ::arg_obj_vector_generate, ::arg_obj_vector_cast, "not a valid vector, format is float,float,float" );
	arg_obj_register( "team", ::arg_obj_team_validate, ::arg_obj_team_generate, undefined, "not a valid team" );
	arg_obj_register( "cmdalias", ::arg_obj_cmdalias_validate, ::arg_obj_cmdalias_generate, ::arg_obj_cmdalias_cast, "not a valid cmdalias" );
	arg_obj_register( "rank", ::arg_obj_rank_validate, ::arg_obj_rank_generate, undefined, "not a valid rank" );
	arg_obj_register( "entity", ::arg_obj_entity_validate, ::arg_obj_entity_generate, ::arg_obj_entity_cast, "not a valid entity" );
	arg_obj_register( "hitloc", ::arg_obj_hitloc_validate, ::arg_obj_hitloc_generate, undefined, "not a valid hitloc" );
	arg_obj_register( "MOD", ::arg_obj_mod_validate, ::arg_obj_mod_generate, ::arg_obj_mod_cast, "not a valid mod" );
	arg_obj_register( "idflags", ::arg_obj_idflags_validate, ::arg_obj_idflags_generate, ::arg_obj_idflags_cast, "not a valid idflag" );
	arg_obj_register( "bot", ::arg_obj_bot_validate, ::arg_obj_bot_generate, ::arg_obj_bot_cast, "not a valid bot" );
	arg_obj_register( "string", ::arg_obj_string_validate, ::arg_obj_string_generate, undefined, "not a valid string" );
	arg_obj_register( "model", ::arg_obj_model_validate, ::arg_obj_model_generate, ::arg_obj_model_cast, "not a valid string" );

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
	
	level thread scripts\cmd_system_modules\_cmd_execute::cmd_buffer();
	level thread end_cmds_on_end_game();
	level thread scripts\cmd_system_modules\_cmd_execute::scr_dvar_cmd_watcher();
	level thread tcs_on_connect();
	level thread check_for_cmd_alias_collisions();

	precachemodel( "defaultactor" );

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
	tcs_pl_obj.cmdpower = getdvarintdefault( "tcs_cmdpower_default", level.tcs_perms.ranks[ "user" ].cmdpower );
	tcs_pl_obj.tcs_rank = getdvarstringdefault( "tcs_default_rank", "user" );
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
		self.tcs_pl.cmdpower = level.tcs_perms.ranks[ "host" ].cmdpower;
		self.tcs_pl.tcs_rank = "host";
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
				self.tcs_pl.cmdpower = entry.cmdpower;
				self.tcs_pl.tcs_rank = entry.tcs_rank;
				found_entry = true;
			}
		}
	}
	self._connected = true;
}