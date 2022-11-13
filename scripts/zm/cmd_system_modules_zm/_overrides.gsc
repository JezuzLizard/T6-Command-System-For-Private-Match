#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\zombies\_zm_pers_upgrades_system;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;

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

wait_network_frame_override()
{
	wait 0.1;
}

checkforalldead_override()
{
	return;
}

check_end_game_intermission_delay_override()
{
	while ( is_true( level.doing_command_system_unittest ) )
	{
		wait 1;
	}
}

never_end_game()
{
	return false;
}

player_fake_death_override()
{
	return;
}

no_player_damage_during_unittest( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return 0;
	}
	if ( level.player_damage_callbacks[ 0 ] != ::no_player_damage_during_unittest )
	{
		return [[ level.player_damage_callbacks[ 0 ] ]]();
	}
	else 
	{
		return -1;
	}
}

setclientfield_override( field_name, value )
{
	if ( !isDefined( self ) || self != level && ( !isPlayer( self ) || self isTestClient() || is_true( self.is_bot ) ) )
	{
		return;
	}
	if ( self == level )
		codesetworldclientfield( field_name, value );
	else
		codesetclientfield( self, field_name, value );
}

setclientfieldtoplayer_override( field_name, value )
{
	if ( !isDefined( self ) || !isPlayer( self ) || self isTestClient() || is_true( self.is_bot ) )
	{
		return;
	}
	codesetplayerstateclientfield( self, field_name, value );
}

vsmgr_monitor_override()
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
				if ( players[player_index] isTestClient() || is_true( players[player_index].is_bot ) )
				{
					continue;
				}
					
				update_clientfields_override( players[player_index], level.vsmgr[type] );
			}
		}
	}
}

update_clientfields_override( player, type_struct )
{
    name = player maps\mp\_visionset_mgr::get_first_active_name( type_struct );
    player setclientfieldtoplayer( type_struct.cf_slot_name, type_struct.info[name].slot_index );

    if ( 1 < type_struct.cf_lerp_bit_count )
        player setclientfieldtoplayer( type_struct.cf_lerp_name, type_struct.info[name].state.players[player._player_entnum].lerp );
}

watch_rampage_bookmark_override()
{
	while ( true )
	{
		wait 0.05;
		waittillframeend;
		now = gettime();
		oldest_allowed = now - level.rampage_bookmark_kill_times_msec;
		players = get_players();

		for ( player_index = 0; player_index < players.size; player_index++ )
		{
			player = players[player_index];
			if ( player isTestClient() )
				continue;

			for ( time_index = 0; time_index < level.rampage_bookmark_kill_times_count; time_index++ )
			{
				if ( !player.rampage_bookmark_kill_times[time_index] )
					break;
				else if ( oldest_allowed > player.rampage_bookmark_kill_times[time_index] )
				{
					player.rampage_bookmark_kill_times[time_index] = 0;
					break;
				}
			}

			if ( time_index >= level.rampage_bookmark_kill_times_count )
			{
				maps\mp\_demo::bookmark( "zm_player_rampage", gettime(), player );
				player maps\mp\zombies\_zm::reset_rampage_bookmark_kill_times();
				player.ignore_rampage_kill_times = now + level.rampage_bookmark_kill_times_delay;
			}
		}
	}
}

is_bot_override()
{
	return self isTestClient() || is_true( self.is_bot );
}

onplayerconnect_clientdvars_override()
{
	if ( self isTestClient() || is_true( self.is_bot ) )
	{
		self maps\mp\zombies\_zm_laststand::player_getup_setup();
		return;
	}
	self setclientcompass( 0 );
	self setclientthirdperson( 0 );
	self resetfov();
	self setclientthirdpersonangle( 0 );
	self setclientammocounterhide( 1 );
	self setclientminiscoreboardhide( 1 );
	self setclienthudhardcore( 0 );
	self setclientplayerpushamount( 1 );
	self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
	self setclientaimlockonpitchstrength( 0.0 );
	self maps\mp\zombies\_zm_laststand::player_getup_setup();
}