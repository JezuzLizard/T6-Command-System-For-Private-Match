#include common_scripts\utility;
#include maps\mp\_utility;

// reference all scripts for autoexec
#include scripts\cmd\core\_cmd_execute;
#include scripts\cmd\core\_cmd_parse2;
#include scripts\cmd\core\_com;
#include scripts\cmd\core\_api_cast;
#include scripts\cmd\core\_api_hud;
#include scripts\cmd\core\_utility_hud;
#include scripts\cmd\core\_perms;
#include scripts\cmd\core\_utility;

// common cmds
#include scripts\cmd\modules\core_cmds;
#include scripts\cmd\modules\core_helpers;
// entity cmds
#include scripts\cmd\modules\editor\entity_cmds;
#include scripts\cmd\modules\editor\entity_helpers;
// path cmds
#include scripts\cmd\modules\editor\path_cmds;
#include scripts\cmd\modules\editor\path_helpers;
// debug cmds
#include scripts\cmd\modules\editor\debug_cmds;
#include scripts\cmd\modules\editor\debug_helpers;
// filmmaker cmds
#include scripts\cmd\modules\filmmaker\camera_cmds;
#include scripts\cmd\modules\filmmaker\camera_helpers;
// unittest cmds
#include scripts\cmd\modules\unittest_cmds;
#include scripts\cmd\modules\unittest_helpers;

#include scripts\cmd\core\parsers\_radiant_keys_parser;

private main()
{
	_init_server();
	level._tcs_developer = getdvarint( "tcs_developer" );
	level.tcs_glob = spawnstruct();
	level.tcs_glob.irestart_countdown = 5;
	level.tcs_glob.icmd_total = 0;
	level.tcs_glob.max_cmd_length = 512;
	level.tcs_glob.icooldown = getdvarintdefault( "tcs_cmd_cd", 5 );
	level.tcs_glob.bsilent_cmds = getdvarintdefault( "tcs_silent_cmds", 0 );
	level.tcs_glob.blog_cmds = getdvarintdefault( "tcs_logprint_cmd_usage", 1 );
	level.tcs_glob.bhidden_cmds = getdvarintdefault( "tcs_allow_hidden_cmds", 1 );
	level.tcs_glob.acmd_tokens = [];

	level.clientdvars = [];
	tokens_str = get_dvar_string_default( "tcs_cmd_tokens", "" ); //separated by spaces, good tokens are generally not used at the start of a normal message 
	if ( tokens_str != "" )
	{
		tokens = strtok( tokens_str, " " );
		for ( i = 0; i < tokens.size; i++ )
		{
			level.tcs_glob.acmd_tokens[ level.tcs_glob.acmd_tokens.size ] = tokens[ i ];
		}
	}
	
	com_init();
	init_consts();
	init_unittest_helpers();
	init_camera_helpers();
	init_debug_helpers();
	init_entity_helpers();
	init_path_helpers();
	// parse_radiant_keys();
	level thread start_cmd_buffer_thread();

	addcallback( "on_player_connect", ::tcs_on_connect );
	registerclientsys( "cl_tcs" );

	level thread drive_connected_notifies_for_mp();
	level thread drive_disconnected_notifies();

	_GET_SERVER_ENTITY() thread catch_uncaught_exceptions();
	_GET_SERVER_ENTITY() thread catch_exception( "debug" );

	wait 0.05;
	waittillframeend;
	add_unittest_cmds();
	add_camera_cmds();
	add_core_cmds();
	add_debug_cmds();
	add_entity_cmds();
	add_path_cmds();
	level.onplayerdisconnect_old = level.onplayerdisconnect;
	level.onplayerdisconnect = ::onplayerdisconnect;
}

drive_connected_notifies_for_mp()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		if ( !sessionmodeiszombiesgame() )
		{
			player callback( "on_player_connect" ); // MP doesn't have...
		}
	}
}

onplayerdisconnect()
{
	if ( sessionmodeiszombiesgame() )
	{
		level notify( "disconnect", self ); // ZM doesn't have...
	}

	self [[ level.onplayerdisconnect_old ]]();
}

drive_disconnected_notifies()
{
	for ( ;; )
	{
		level waittill( "disconnect", player );
		player callback( "on_player_disconnect" );
	}
}

tcs_p_obj_new()
{
	tcs_pl_obj = spawnstruct();
	tcs_pl_obj.tcs_rank = get_dvar_string_default( "tcs_default_rank", "user" );
	return tcs_pl_obj;
}

tcs_on_connect()
{
	tcs_pl_obj = tcs_p_obj_new();
	self.tcs_pl = tcs_pl_obj;

	found_entry = false;
	if ( self ishost() )
	{
		self.tcs_pl.tcs_rank = "host";
		_SET_SERVER_ENTITY( self );
		self.is_host = true;
		found_entry = true;
	}
	else if ( _ARRAY_VALIDATE( level.tcs_player_entries ) )
	{
		foreach ( entry in level.tcs_player_entries )
		{
			find = _GET_SERVER_ENTITY() cast_str_to_entity( entry.player_entry, "player" );
			if ( !find.errored && find.ent == self )
			{
				self.tcs_pl.tcs_rank = entry.tcs_rank;
				found_entry = true;
			}
		}
	}
	self._connected = true;

	self.default_targets = []; // the default target is by default the default_executors instead as most commands would prefer 'self' which is the executor to be the assumed default target
	self.default_executors = [];
	self.default_executors[ 0 ] = self;

	self.cmd_history = [];
}