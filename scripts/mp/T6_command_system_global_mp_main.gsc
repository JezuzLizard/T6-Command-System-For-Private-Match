#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\mp\cmd_system_modules_mp\_cmd_util_mp;

#include maps\mp\killstreaks\_dogs;

main()
{
	while ( !is_true( level.cmd_init_done ) )
	{
		wait 0.05;
	}

	cmd_block_set_module_group( "core_mp" );
	cmd_block_set_rank_group( "cheat" );
	sicdogsonplayer_cmd = cmd_add( "sicdogsonplayer", ::cmd_sicdogsonplayer_f, "sicdogsonplayer {player} [count] [invisible]" );
	sicdogsonplayer_cmd arg_obj_add_cmd( "wholenum wholenum", 0, 2 );
	givenotarget_cmd target_obj_add_cmd( "player" );

	removedogs_cmd = cmd_add( "removedogs", ::cmd_removedogs_f );

	arg_obj_register( "weapon", ::arg_obj_weapon_generate, ::arg_obj_weapon_cast );

	level thread on_unittest();

	level thread on_player_connect();
	level.cmd_init_mp_done = true;
}