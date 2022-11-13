#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\mp\cmd_system_modules\_cmd_util_mp;

main()
{
	while ( !is_true( level.command_init_done ) )
	{
		wait 0.05;
	}

	cmd_register_arg_type_handlers( "weapon", ::arg_weapon_handler, ::arg_generate_rand_weapon, "not a valid weapon" );

	level thread on_player_connect();
	level.command_init_mp_done = true;
}

init()
{
	build_weapons_array();
}

on_player_connect()
{
	while ( true )
	{
		level waittill( "connected", player );
		if ( is_true( level.doing_command_system_unittest ) && is_true( player.pers[ "isBot" ] ) )
		{
			player thread wait_spawn_bot_think();
		}
	}
}

wait_spawn_bot_think()
{
	wait 5;
	self [[ level.spawnplayer ]]();
}