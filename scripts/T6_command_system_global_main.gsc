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
	level.server.default_target = level.server; // treat this value as the default target for optional target specifying
	level.server.default_executor = level.server; // treat this value as the default executor for the command; the command is executed on behalf of the server on a player
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

	// Special target syntax for players/entities:
	// {*} - if the argument expects a player/entity, execute on all of them
	// {playername1,playername2} - execute only on these players
	// certain reserved syntaxes also apply:
	// {*[team=allies&classname=player]} - only execute on <team> AND <classname>
	// {*[team=axis|classname=player]} - execute on <team> OR <classname>
	// {*[target=self]} - manually set the target to an entity in this case self or the executor, default behavior; if server is executing they must specify the target
	// {$39} - pick random targets up to $<x> from possible pool of targets, <x> defaults to 1
	// {$[team=allies&classname=player]} - pick one random target matching the criteria
	// %{player} - forces this player to be the executor of the command as if they typed the command in the chat
	// {(some_func(arg1,arg2,arg3))} - execute a script function to retrieve targets

	// TLDR;
	// {} by itself represents targets of the command
	// %{} represents executors of the command
	// you can specify both the executor and targets syntax since they have different enough syntax

	// Target Hierarchy:
	// Entity{Everything}
	// Player{Bot}, Sentient{Actor, Bot}


	cmd_block_set_rank_group( "cheat" );
	setcvar_cmd = cmd_add( "cvar", ::cmd_setcvar_f, "cvar {player} <cvarname> <newval>" );
	setcvar_cmd arg_obj_add_cmd( "string string", 2, 2 );
	setcvar_cmd target_obj_add_cmd( "player", false, "Player whos <cvarname> will be set to <newval>" );

	dvar_cmd = cmd_add( "dvar", ::cmd_server_dvar_f, "dvar <dvarname> <newval>" );
	dvar_cmd arg_obj_add_cmd( "string string", 2, 2 );

	givegod_cmd = cmd_add( "god", ::cmd_givegod_f, "god {player}" );
	givegod_cmd target_obj_add_cmd( "player", false, "Player who will receive god status" );

	givenotarget_cmd = cmd_add( "notarget", ::cmd_givenotarget_f, "notarget {player}" );
	givenotarget_cmd target_obj_add_cmd( "player", false, "Player who will receive notarget status" );

	giveinvisible_cmd = cmd_add( "invisible", ::cmd_giveinvisible_f, "invisible {player}" );
	giveinvisible_cmd target_obj_add_cmd( "player", false, "Player who will be hidden" );

	setrank_cmd = cmd_add( "setrank", ::cmd_setrank_f, "setrank {player} <rank>" );
	setrank_cmd arg_obj_add_cmd( "rank", 1, 1 );
	setrank_cmd target_obj_add_cmd( "player", true, "Player whos rank will be modified to be <rank>" );

	entitylist_cmd = cmd_add( "entitylist", ::cmd_entitylist_f, "entitylist [targetname]" );
	entitylist_cmd arg_obj_add_cmd( "string", 0, 1 );

	unittest_cmd = cmd_add( "unittest", ::cmd_unittest_validargs_f, "unittest [botcount] [duration]" );
	unittest_cmd arg_obj_add_cmd( "wholenum wholenum", 0, 2 );

	testcmd_cmd = cmd_add( "testcmd", ::cmd_testcmd_f, "testcmd <cmdalias> [threadcount] [duration]" );
	testcmd_cmd arg_obj_add_cmd( "cmdalias wholenum wholenum", 1, 3 );

	dodamage_cmd = cmd_add( "dodamage", ::cmd_dodamage_f, "dodamage {entity_to_be_damaged} <damage> <origin> {entity_who_is_attacker} {entity_who_is_inflictor} [hitloc] [MOD] [idflags] [weapon]" );
	dodamage_cmd arg_obj_add_cmd( "float vector hitloc MOD idflags weapon", 2, 6 );
	dodamage_cmd target_obj_add_cmd( "entity", true, "Entity who will receive <damage> from <origin>" );
	dodamage_cmd target_obj_add_cmd( "entity", false, "Entity who will be set as the <attacker>" );
	dodamage_cmd target_obj_add_cmd( "entity", false, "Entity who will be set as the <inflictor>" );

	teleportplayer_cmd = cmd_add( "teleporttoplayer", ::cmd_teleportplayer_f, "teleporttoplayer {player_from} {player_to}" );
	teleportplayer_cmd target_obj_add_cmd( "player", false, "Player who will be teleported" );
	teleportplayer_cmd target_obj_add_cmd( "player", true, "Player who will be teleported" );

	bottomlessclip_cmd = cmd_add( "bottomlessclip", ::cmd_bottomlessclip_f, "bottomlessclip {player}" );
	bottomlessclip_cmd target_obj_add_cmd( "player" );

	printentitiesinradius_cmd = cmd_add( "printentitiesinradius", ::cmd_printentitiesinradius_f, "printentitiesinradius {entity_anchor} {entity_filter} [radius=1000]" );
	printentitiesinradius_cmd arg_obj_add_cmd( "float", 0, 1 );
	printentitiesinradius_cmd target_obj_add_cmd( "entity entity" );

	togglehud_cmd = cmd_add( "scrnotify", ::cmd_scrnotify_f, "scrnotify {entity} <notifyent> <notifyname> [notifyargs] ..." );
	togglehud_cmd arg_obj_add_cmd( "string string ...", 2, 255 );
	togglehud_cmd target_obj_add_cmd( "entity" );

	cmd_block_set_rank_group( "none" );
	cmdlist_cmd = cmd_add( "cmdlist", ::cmd_cmdlist_f );

	playerlist_cmd = cmd_add( "playerlist", ::cmd_playerlist_f, "playerlist {team}" );
	playerlist_cmd target_obj_add_cmd( "team" );

	printorigin_cmd = cmd_add( "printorigin", ::cmd_printorigin_f, "printorigin {entity}" );
	printorigin_cmd target_obj_add_cmd( "entity" );

	printangles_cmd = cmd_add( "printangles", ::cmd_printangles_f, "printangles {entity}" );
	printangles_cmd target_obj_add_cmd( "entity" );

	help_cmd = cmd_add( "help", ::cmd_help_f, "help [cmdalias]" );
	help_cmd arg_obj_add_cmd( "cmdalias", 0, 1 );

	togglehud_cmd = cmd_add( "togglehud", ::cmd_togglehud_f, "togglehud {player}" );
	togglehud_cmd target_obj_add_cmd( "player" );

	// Sets the default cmd target for the executor(normally 'self'); this allows the server through rcon or otherwise to still use the default target functionality that makes the default target 'self' or another entity.
	setdefaultcmdtarget_cmd = cmd_add( "setdefaultcmdtarget", ::cmd_setdefaultcmdtarget_f, "setdefaultcmdtarget {player}" );
	setdefaultcmdtarget_cmd target_obj_add_cmd( "player", true );

	setdefaultcmdexecutor_cmd = cmd_add( "setdefaultcmdexecutor", ::cmd_setdefaultcmdexecutor_f, "setdefaultcmdexecutor {player}" );
	setdefaultcmdexecutor_cmd target_obj_add_cmd( "player", true );

	arg_obj_register( "player", ::arg_obj_player_validate, ::arg_obj_player_generate, ::arg_obj_player_cast, "not a valid player", true );
	arg_obj_register( "wholenum", ::arg_obj_wholenum_validate, ::arg_obj_wholenum_generate, ::arg_obj_int_cast, "not a whole number" );
	arg_obj_register( "boolean", ::arg_obj_boolean_validate, ::arg_obj_boolean_generate, ::arg_obj_boolean_cast, "not a boolean" );
	arg_obj_register( "int", ::arg_obj_int_validate, ::arg_obj_int_generate, ::arg_obj_int_cast, "not an int" );
	arg_obj_register( "float", ::arg_obj_float_validate, ::arg_obj_float_generate, ::arg_obj_float_cast, "not a float" );
	arg_obj_register( "wholefloat", ::arg_obj_wholefloat_validate, ::arg_obj_wholefloat_generate, ::arg_obj_float_cast, "not a float greater than 0" );
	arg_obj_register( "vector", ::arg_obj_vector_validate, ::arg_obj_vector_generate, ::arg_obj_vector_cast, "not a valid vector, format is float,float,float" );
	arg_obj_register( "team", ::arg_obj_team_validate, ::arg_obj_team_generate, undefined, "not a valid team", true );
	arg_obj_register( "cmdalias", ::arg_obj_cmdalias_validate, ::arg_obj_cmdalias_generate, ::arg_obj_cmdalias_cast, "not a valid cmdalias" );
	arg_obj_register( "rank", ::arg_obj_rank_validate, ::arg_obj_rank_generate, undefined, "not a valid rank" );
	arg_obj_register( "entity", ::arg_obj_entity_validate, ::arg_obj_entity_generate, ::arg_obj_entity_cast, "not a valid entity", true );
	arg_obj_register( "entity_allow_null", ::arg_obj_entity_allow_null_validate, ::arg_obj_entity_allow_null_generate, ::arg_obj_entity_allow_null_cast, "not a valid entity or null entity", true );
	arg_obj_register( "hitloc", ::arg_obj_hitloc_validate, ::arg_obj_hitloc_generate, undefined, "not a valid hitloc" );
	arg_obj_register( "MOD", ::arg_obj_mod_validate, ::arg_obj_mod_generate, ::arg_obj_mod_cast, "not a valid mod" );
	arg_obj_register( "idflags", ::arg_obj_idflags_validate, ::arg_obj_idflags_generate, ::arg_obj_idflags_cast, "not a valid idflag" );
	arg_obj_register( "bot", ::arg_obj_bot_validate, ::arg_obj_bot_generate, ::arg_obj_bot_cast, "not a valid bot", true );
	arg_obj_register( "string", ::arg_obj_string_validate, ::arg_obj_string_generate, undefined, "not a valid string" );
	arg_obj_register( "string_allow_null", ::arg_obj_string_allow_null_validate, ::arg_obj_string_allow_null_generate, undefined, "not a valid string or blank string" );
	arg_obj_register( "model", ::arg_obj_model_validate, ::arg_obj_model_generate, ::arg_obj_model_cast, "not a valid model" );
	arg_obj_register( "actor", ::arg_obj_actor_validate, ::arg_obj_actor_generate, ::arg_obj_actor_cast, "not a valid actor", true );
	arg_obj_register( "spawnable_classname", ::arg_obj_spawnable_classname_validate, ::arg_obj_spawnable_classname_generate, ::arg_obj_spawnable_classname_cast, "not a spawnable classname" );
	// executor argtype/target for level.server and player commands

	//exclude_clientcmd_from_unittest_pool();
	//exclude_servercmd_from_unittest_pool();

	scripts\cmd_system_modules\_consts::init_consts();
	
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
	self endon( "disconnect" );

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

	self.default_target = self;
	self.default_executor = self;
}