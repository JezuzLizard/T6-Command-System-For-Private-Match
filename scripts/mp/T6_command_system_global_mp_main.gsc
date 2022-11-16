#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\mp\cmd_system_modules_mp\_cmd_util_mp;

main()
{
	while ( !is_true( level.command_init_done ) )
	{
		wait 0.05;
	}

	cmd_register_arg_type_handlers( "weapon", ::arg_weapon_handler, ::arg_generate_rand_weapon, "not a valid weapon" );

	level thread on_unittest();

	level thread on_player_connect();
	level.command_init_mp_done = true;
}

on_unittest()
{
	level endon( "game_ended" );
	while ( true )
	{
		level waittill( "unittest_start" );
		registerscorelimit( 0, 0 );
		registertimelimit( 0, 0 );
		registernumlives( 9999, 9999 );
	}
}

init()
{
	build_weapons_array();
}

on_player_connect()
{
	level endon( "game_ended" );
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
	self thread maps\mp\bots\_bot::bot_spawn_think( random( level.teams ) );
}