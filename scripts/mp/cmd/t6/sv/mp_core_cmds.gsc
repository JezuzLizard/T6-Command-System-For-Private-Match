#include common_scripts\utility;


#include scripts\cmd\game_shared\sv\core\_utility;

#include scripts\mp\cmd\t6\sv\mp_core_helpers;

add_core_cmds()
{
	waittillframeend;
	cmd_block_set_module_group( "core_mp" );
	cmd_block_set_rank_group( "cheat" );
	sicdogsonplayer_cmd = cmd_add( "sicdogsonplayer", ::cmd_sicdogsonplayer_f, "sicdogsonplayer {player} [count] [invisible]" );
	sicdogsonplayer_cmd arg_add_optional( 1, "count", "positive_int", "Number of dogs to spawn" );
	sicdogsonplayer_cmd arg_add_optional( 2, "invisible", "boolean", "Make dogs spawned also invisible" );
	sicdogsonplayer_cmd target_add_required( 1, "player", "player", "Player who will be hunted" );

	removedogs_cmd = cmd_add( "removedogs", ::cmd_removedogs_f );
}

cmd_sicdogsonplayer_f( param )
{
	target = param.t[ 0 ][ 0 ];
	count = param.a[ 0 ];
	invisible = param.a[ 1 ];

	other_team = getotherteam( target.team );

	if ( !isDefined( count ) )
	{
		count = 1;
	}

	if ( ( getfreeactorcount() - count ) < 0 )
	{
		return param add_player_cmderror( "Cannot spawn more than 32 dogs at once" );
	}
	for ( i = 0; i < count; i++ )
	{
		dog_manager_spawn_dog( target, other_team, invisible );
	}
	self com_printinfo( "Spawned in " + count + " dogs to hunt " + target.name );
	self com_printinfo( "Use cmd removedogs to remove the dogs spawned with this cmd" );
}

cmd_removedogs_f( param )
{
	level notify( "remove_dogs" );

	param add_executor_cmdinfo( "Removed all cmd spawned dogs" );
}