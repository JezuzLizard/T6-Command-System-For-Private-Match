#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

// zm only cmds registered by autoexec
#include scripts\core\modules\zm_core_cmds;

main()
{
	replaceFunc( maps\mp\zombies\_zm_utility::wait_network_frame, ::wait_network_frame_override );
	replaceFunc( maps\mp\_visionset_mgr::monitor, ::monitor_stub );
}

wait_network_frame_override()
{
	wait 0.1;
}

monitor_stub()
{
	while ( level.vsmgr_initializing )
		wait 0.05;

	typekeys = getarraykeys( level.vsmgr );

	while ( true )
	{
		wait 0.05;
		waittillframeend;
		players = getPlayers();

		for ( type_index = 0; type_index < typekeys.size; type_index++ )
		{
			type = typekeys[type_index];

			if ( !level.vsmgr[type].in_use )
				continue;

			for ( player_index = 0; player_index < players.size; player_index++ )
			{
				if ( players[ player_index ] istestclient() )
					continue;

				maps\mp\_visionset_mgr::update_clientfields( players[player_index], level.vsmgr[type] );
			}
		}
	}
}
