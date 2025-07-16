#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

#include scripts\mp\cmd\modules\mp_core_helpers;

autoexec add_cmds()
{
	cmd_block_set_module_group( "core_mp" );
	cmd_block_set_rank_group( "cheat" );
	sicdogsonplayer_cmd = cmd_add( "sicdogsonplayer", ::cmd_sicdogsonplayer_f, "sicdogsonplayer {player} [count] [invisible]" );
	sicdogsonplayer_cmd arg_obj_add_cmd( "positive_int positive_int", 0, 2 );
	givenotarget_cmd target_obj_add_cmd( "player" );

	removedogs_cmd = cmd_add( "removedogs", ::cmd_removedogs_f );
}

cmd_sicdogsonplayer_f( param )
{
	target = param.t[ 0 ];
	count = param.a[ 0 ];
	invisible = param.a[ 1 ];

	other_team = getotherteam( target.team );

	if ( !isDefined( count ) )
	{
		count = 1;
	}

	if ( ( getfreeactorcount() - count ) < 0 )
	{
		return result_cmderror( "Cannot spawn more than 32 dogs at once" );
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

	return result_cmdinfo( "Removed all cmd spawned dogs" );
}