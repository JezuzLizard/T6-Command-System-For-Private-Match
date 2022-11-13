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
	while ( is_true( level.doing_command_system_unittest ) || isDefined( level.custom_unittest_end_game_delay_func ) && [[ level.custom_unittest_end_game_delay_func ]]() )
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

player_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isdefined( level._game_module_player_damage_callback ) )
		self [[ level._game_module_player_damage_callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );

	idamage = self check_player_damage_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );

	if ( isdefined( self.use_adjusted_grenade_damage ) && self.use_adjusted_grenade_damage )
	{
		self.use_adjusted_grenade_damage = undefined;

		if ( self.health > idamage )
			return idamage;
	}

	if ( !idamage )
		return 0;

	if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
		return 0;

	if ( isdefined( einflictor ) )
	{
		if ( isdefined( einflictor.water_damage ) && einflictor.water_damage )
			return 0;
	}

	if ( isdefined( eattacker ) && ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie || isplayer( eattacker ) ) )
	{
		if ( isdefined( self.hasriotshield ) && self.hasriotshield && isdefined( vdir ) )
		{
			if ( isdefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped )
			{
				if ( self player_shield_facing_attacker( vdir, 0.2 ) && isdefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( 100, 0 );
					return 0;
				}
			}
			else if ( !isdefined( self.riotshieldentity ) )
			{
				if ( !self player_shield_facing_attacker( vdir, -0.2 ) && isdefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( 100, 0 );
					return 0;
				}
			}
		}
	}

	if ( isdefined( eattacker ) )
	{
		if ( isdefined( self.ignoreattacker ) && self.ignoreattacker == eattacker )
			return 0;

		if ( isdefined( self.is_zombie ) && self.is_zombie && ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie ) )
			return 0;

		if ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie )
		{
			self.ignoreattacker = eattacker;
			self thread remove_ignore_attacker();

			if ( isdefined( eattacker.custom_damage_func ) )
				idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
			else if ( isdefined( eattacker.meleedamage ) )
				idamage = eattacker.meleedamage;
			else
				idamage = 50;
		}

		eattacker notify( "hit_player" );

		if ( smeansofdeath != "MOD_FALLING" )
		{
			self thread playswipesound( smeansofdeath, eattacker );

			if ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie || isplayer( eattacker ) )
				self playrumbleonentity( "damage_heavy" );

			canexert = 1;

			if ( isdefined( level.pers_upgrade_flopper ) && level.pers_upgrade_flopper )
			{
				if ( isdefined( self.pers_upgrades_awarded["flopper"] ) && self.pers_upgrades_awarded["flopper"] )
					canexert = smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_GRENADE_SPLASH";
			}

			if ( isdefined( canexert ) && canexert )
			{
				if ( randomintrange( 0, 1 ) == 0 )
					self thread maps\mp\zombies\_zm_audio::playerexert( "hitmed" );
				else
					self thread maps\mp\zombies\_zm_audio::playerexert( "hitlrg" );
			}
		}
	}

	finaldamage = idamage;

	if ( is_placeable_mine( sweapon ) || sweapon == "freezegun_zm" || sweapon == "freezegun_upgraded_zm" )
		return 0;

	if ( isdefined( self.player_damage_override ) )
		self thread [[ self.player_damage_override ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );

	if ( smeansofdeath == "MOD_FALLING" )
	{
		if ( self hasperk( "specialty_flakjacket" ) && isdefined( self.divetoprone ) && self.divetoprone == 1 )
		{
			if ( isdefined( level.zombiemode_divetonuke_perk_func ) )
				[[ level.zombiemode_divetonuke_perk_func ]]( self, self.origin );

			return 0;
		}

		if ( isdefined( level.pers_upgrade_flopper ) && level.pers_upgrade_flopper )
		{
			if ( self maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_flopper_damage_check( smeansofdeath, idamage ) )
				return 0;
		}
	}

	if ( smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" )
	{
		if ( self hasperk( "specialty_flakjacket" ) )
			return 0;

		if ( isdefined( level.pers_upgrade_flopper ) && level.pers_upgrade_flopper )
		{
			if ( isdefined( self.pers_upgrades_awarded["flopper"] ) && self.pers_upgrades_awarded["flopper"] )
				return 0;
		}

		if ( self.health > 75 && !( isdefined( self.is_zombie ) && self.is_zombie ) )
			return 75;
	}

	if ( idamage < self.health )
	{
		if ( isdefined( eattacker ) )
		{
			if ( isdefined( level.custom_kill_damaged_vo ) )
				eattacker thread [[ level.custom_kill_damaged_vo ]]( self );
			else
				eattacker.sound_damage_player = self;

			if ( isdefined( eattacker.has_legs ) && !eattacker.has_legs )
				self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "crawl_hit" );
			else if ( isdefined( eattacker.animname ) && eattacker.animname == "monkey_zombie" )
				self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "monkey_hit" );
		}

		return finaldamage;
	}

	if ( isdefined( eattacker ) )
	{
		if ( isdefined( eattacker.animname ) && eattacker.animname == "zombie_dog" )
		{
			self maps\mp\zombies\_zm_stats::increment_client_stat( "killed_by_zdog" );
			self maps\mp\zombies\_zm_stats::increment_player_stat( "killed_by_zdog" );
		}
		else if ( isdefined( eattacker.is_avogadro ) && eattacker.is_avogadro )
		{
			self maps\mp\zombies\_zm_stats::increment_client_stat( "killed_by_avogadro", 0 );
			self maps\mp\zombies\_zm_stats::increment_player_stat( "killed_by_avogadro" );
		}
	}

	self thread clear_path_timers();

	if ( level.intermission )
		level waittill( "forever" );

	if ( level.scr_zm_ui_gametype == "zcleansed" && idamage > 0 )
	{
		if ( isdefined( eattacker ) && isplayer( eattacker ) && eattacker.team != self.team && ( !( isdefined( self.laststand ) && self.laststand ) && !self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || !isdefined( self.last_player_attacker ) ) )
		{
			if ( isdefined( eattacker.maxhealth ) && ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie ) )
				eattacker.health = eattacker.maxhealth;

			if ( isdefined( level.player_kills_player ) )
				self thread [[ level.player_kills_player ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
		}
	}

	if ( self.lives > 0 && self hasperk( "specialty_finalstand" ) )
	{
		self.lives--;

		if ( isdefined( level.chugabud_laststand_func ) )
		{
			self thread [[ level.chugabud_laststand_func ]]();
			return 0;
		}
	}

	if ( is_true( level.doing_command_system_unittest ) )
	{
		return finaldamage;
	}

	players = get_players();
	count = 0;

	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i] == self || players[i].is_zombie || players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() || players[i].sessionstate == "spectator" )
			count++;
	}

	if ( count < players.size || isdefined( level._game_module_game_end_check ) && ![[ level._game_module_game_end_check ]]() )
	{
		if ( isdefined( self.lives ) && self.lives > 0 && ( isdefined( level.force_solo_quick_revive ) && level.force_solo_quick_revive ) && self hasperk( "specialty_quickrevive" ) )
			self thread wait_and_revive();

		return finaldamage;
	}

	if ( players.size == 1 && flag( "solo_game" ) )
	{
		if ( self.lives == 0 || !self hasperk( "specialty_quickrevive" ) )
			self.intermission = 1;
	}

	solo_death = players.size == 1 && flag( "solo_game" ) && ( self.lives == 0 || !self hasperk( "specialty_quickrevive" ) );
	non_solo_death = count > 1 || players.size == 1 && !flag( "solo_game" );

	if ( ( solo_death || non_solo_death ) && !( isdefined( level.no_end_game_check ) && level.no_end_game_check ) )
	{
		level notify( "stop_suicide_trigger" );
		self thread maps\mp\zombies\_zm_laststand::playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );

		if ( !isdefined( vdir ) )
			vdir = ( 1, 0, 0 );

		self fakedamagefrom( vdir );

		if ( isdefined( level.custom_player_fake_death ) )
			self thread [[ level.custom_player_fake_death ]]( vdir, smeansofdeath );
		else
			self thread player_fake_death();
	}

	if ( count == players.size && !( isdefined( level.no_end_game_check ) && level.no_end_game_check ) )
	{
		if ( players.size == 1 && flag( "solo_game" ) )
		{
			if ( self.lives == 0 || !self hasperk( "specialty_quickrevive" ) )
			{
				self.lives = 0;
				level notify( "pre_end_game" );
				wait_network_frame();

				if ( flag( "dog_round" ) )
					increment_dog_round_stat( "lost" );

				level notify( "end_game" );
			}
			else
				return finaldamage;
		}
		else
		{
			level notify( "pre_end_game" );
			wait_network_frame();

			if ( flag( "dog_round" ) )
				increment_dog_round_stat( "lost" );

			level notify( "end_game" );
		}

		return 0;
	}
	else
	{
		surface = "flesh";
		return finaldamage;
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