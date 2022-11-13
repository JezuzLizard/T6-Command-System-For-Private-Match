#include common_scripts\utility;
#include maps\mp\_utility;

main()
{
	level thread on_player_connect();
}

on_player_connect()
{
	while ( true )
	{
		level waittill( "connected", player );
		if ( player isTestClient() && is_true( level.doing_command_system_unittest ) )
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