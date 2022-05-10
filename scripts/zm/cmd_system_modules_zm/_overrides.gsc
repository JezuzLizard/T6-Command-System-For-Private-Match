#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\zombies\_zm_pers_upgrades_system;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_text_parser;

pers_upgrades_monitor_override()
{
	if ( !isdefined( level.pers_upgrades ) )
		return;

	if ( !is_classic() )
		return;

	level thread wait_for_game_end();

	while ( true )
	{
		waittillframeend;
		players = getplayers();

		for ( player_index = 0; player_index < players.size; player_index++ )
		{
			player = players[player_index];
			if ( is_true( player.tcs_disable_pers_system ) )
			{
				continue;
			}
			if ( is_player_valid( player ) && isdefined( player.stats_this_frame ) )
			{
				if ( !player.stats_this_frame.size && !( isdefined( player.pers_upgrade_force_test ) && player.pers_upgrade_force_test ) )
					continue;

				for ( pers_upgrade_index = 0; pers_upgrade_index < level.pers_upgrades_keys.size; pers_upgrade_index++ )
				{
					pers_upgrade = level.pers_upgrades[level.pers_upgrades_keys[pers_upgrade_index]];
					is_stat_updated = player is_any_pers_upgrade_stat_updated( pers_upgrade );

					if ( is_stat_updated )
					{
						should_award = player check_pers_upgrade( pers_upgrade );

						if ( should_award )
						{
							if ( isdefined( player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] ) && player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] )
								continue;

							player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] = 1;

							if ( flag( "initial_blackscreen_passed" ) && !is_true( player.is_hotjoining ) )
							{
								type = "upgrade";

								if ( isdefined( level.snd_pers_upgrade_force_type ) )
									type = level.snd_pers_upgrade_force_type;

								player playsoundtoplayer( "evt_player_upgrade", player );

								if ( isdefined( level.pers_upgrade_vo_spoken ) && level.pers_upgrade_vo_spoken )
									player delay_thread( 1, maps\mp\zombies\_zm_audio::create_and_play_dialog, "general", type, undefined, level.snd_pers_upgrade_force_variant );
								else
									player delay_thread( 1, ::play_vox_to_player, "general", type, level.snd_pers_upgrade_force_variant );

								if ( isdefined( player.upgrade_fx_origin ) )
								{
									fx_org = player.upgrade_fx_origin;
									player.upgrade_fx_origin = undefined;
								}
								else
								{
									fx_org = player.origin;
									v_dir = anglestoforward( player getplayerangles() );
									v_up = anglestoup( player getplayerangles() );
									fx_org = fx_org + v_dir * 30 + v_up * 12;
								}

								playfx( level._effect["upgrade_aquired"], fx_org );
								level thread maps\mp\zombies\_zm::disable_end_game_intermission( 1.5 );
							}
							if ( isdefined( pers_upgrade.upgrade_active_func ) )
								player thread [[ pers_upgrade.upgrade_active_func ]]();

							continue;
						}

						if ( isdefined( player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] ) && player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] )
						{
							if ( flag( "initial_blackscreen_passed" ) && !is_true( player.is_hotjoining ) )
								player playsoundtoplayer( "evt_player_downgrade", player );
						}

						player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] = 0;
					}
				}

				player.pers_upgrade_force_test = 0;
				player.stats_this_frame = [];
			}
		}

		wait 0.05;
	}
}