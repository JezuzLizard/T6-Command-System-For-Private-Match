

// reference all scripts for autoexec
#include scripts\cmd\game_shared\cl\core\_cl_cmd_execute;
#include scripts\cmd\game_shared\cl\core\_cl_cmd_parse2;
#include scripts\cmd\game_shared\cl\core\_cl_com;
#include scripts\cmd\game_shared\cl\core\_cl_consts;
#include scripts\cmd\game_shared\cl\core\_cl_utility;

main()
{
	_INIT_GAME();
	level._developer = getdvarint( "developer" );
	level.tcs_glob = spawnstruct();
	level.tcs_glob.icmd_total = 0;
	level.tcs_glob.acmd_tokens = [];

	tokens_str = get_dvar_string_default( "tcs_cmd_tokens", "" ); //separated by spaces, good tokens are generally not used at the start of a normal message 
	if ( tokens_str != "" )
	{
		tokens = _STRTOK( tokens_str, " " );
		for ( i = 0; i < tokens.size; i++ )
		{
			level.tcs_glob.acmd_tokens[ level.tcs_glob.acmd_tokens.size ] = tokens[ i ];
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
	
	com_init();
	init_cl_consts();
	start_cmd_buffer();

	_ADDCALLBACK( "on_player_connect", ::tcs_on_connect );
	registersystem( "cl_tcs", ::cl_tcs_handler );

	waitforclient( 0 );

	_SET_PRIMARY_CLIENT( getlocalplayers()[ 0 ] );
}

drive_disconnected_notifies()
{
	for ( ;; )
	{
		level waittill( "disconnect", player );
		player _CALLBACK( "on_player_disconnect" );
	}
}

tcs_on_connect()
{
	self._connected = true;
	self.default_targets = []; // the default target is by default the default_executors instead as most commands would prefer 'self' which is the executor to be the assumed default target
	self.default_executors = [];
	self.default_executors[ 0 ] = self;
}

cl_tcs_handler( clientnum, newstate )
{
	level notify( "say", newstate, level.primaryclient, true, false );
}