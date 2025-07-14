#include common_scripts\utility;
#include maps\mp\_utility;

// reference all scripts for autoexec
#include scripts\cmd\core\_cmd_execute;
#include scripts\cmd\core\_cmd_parse;
#include scripts\cmd\core\_com;
#include scripts\cmd\core\_consts;
#include scripts\cmd\core\_perms;
#include scripts\cmd\core\_utility;
#include scripts\cmd\core\unittest;

// common cmds
#include scripts\cmd\modules\core_cmds;
// entity cmds
#include scripts\cmd\modules\entity_cmds;

main()
{
	level.server = spawnStruct();
	level.server.playername = getdvar( "sv_hostname" );
	level.server.name = getdvar( "sv_hostname" );
	level.server.is_server = true;
	level.server.default_targets = undefined; // treat this value as the default target for optional target specifying
	level.server.default_executors = level.server; // treat this value as the default executor for the command; the command is executed on behalf of the server on a player
	level.tcs_glob = spawnstruct();
	level.tcs_glob.irestart_countdown = 5;
	level.tcs_glob.icmd_total = 0;
	level.tcs_glob.icooldown = getdvarintdefault( "tcs_cmd_cd", 5 );
	level.tcs_glob.bsilent_cmds = getdvarintdefault( "tcs_silent_cmds", 0 );
	level.tcs_glob.blog_cmds = getdvarintdefault( "tcs_logprint_cmd_usage", 1 );
	level.tcs_glob.bhidden_cmds = getdvarintdefault( "tcs_allow_hidden_cmds", 1 );

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
	
	addcallback( "on_player_connect", ::tcs_on_connect );

	level thread drive_connected_notifies_for_mp();
	level.cmd_init_done = true;
}

drive_connected_notifies_for_mp()
{
	while ( true )
	{
		level waittill( "connected", player );
		if ( !sessionmodeiszombiesgame() )
		{
			player callback( "on_player_connect" ); // MP doesn't have...
		}
	}
}

tcs_p_obj_new()
{
	tcs_pl_obj = spawnstruct();
	tcs_pl_obj.cmdpower = getdvarintdefault( "tcs_cmdpower_default", level.tcs_perms.ranks[ "user" ].cmdpower );
	tcs_pl_obj.tcs_rank = getdvarstringdefault( "tcs_default_rank", "user" );
	return tcs_pl_obj;
}

tcs_on_connect()
{
	tcs_pl_obj = tcs_p_obj_new();
	self.tcs_pl = tcs_pl_obj;

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
			find = level.server cast_str_to_entity( entry.player_entry, "player" );
			if ( !find.errored && find.ent == self )
			{
				self.tcs_pl.cmdpower = entry.cmdpower;
				self.tcs_pl.tcs_rank = entry.tcs_rank;
				found_entry = true;
			}
		}
	}
	self._connected = true;

	self.default_targets = undefined; // the default target is by default the default_executors instead as most commands would prefer 'self' which is the executor to be the assumed default target
	self.default_executors = self;
}