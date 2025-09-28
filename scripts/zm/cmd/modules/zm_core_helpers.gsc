#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weapons;

#include scripts\cmd\core\_utility;

#include scripts\zm\cmd\modules\_utility;

autoexec init_helpers()
{
	register_modifiable_zombie_stat( "health_increase_flat", "int", 100, ::zombie_recalculate_health );
	register_modifiable_zombie_stat( "health_increase_multiplier", "float", 0.1, ::zombie_recalculate_health );
	register_modifiable_zombie_stat( "health_start", "int", 150, ::zombie_recalculate_health );
	register_modifiable_zombie_stat( "spawn_delay", "float", 2.0, ::zombie_recalculate_spawn_delay );
	register_modifiable_zombie_stat( "move_speed_multiplier", "int", 8, ::zombie_recalculate_move_speed );
	register_modifiable_zombie_stat( "move_speed_multiplier_easy", "int", 2, ::zombie_recalculate_move_speed );
	register_modifiable_zombie_stat( "max_ai", "int", 24, ::zombie_recalculate_total );
	register_modifiable_zombie_stat( "ai_per_player", "int", 6, ::zombie_recalculate_total );
	register_modifiable_zombie_stat( "ai_limit", "int", 24 );

	level.tcs_additional_help_prints_func = ::zm_help_prints;

	level thread on_unittest();

	registerclientsys( "zm_cmds" );
}

zm_help_prints()
{
	if ( is_true( self.is_server ) )
	{
		self com_printnotitle( "^3To view available powerups use 'tcscmd poweruplist'" );
		self com_printnotitle( "^3To view available perks use 'tcscmd perklist'" );
		self com_printnotitle( "^3To view available weapons use 'tcscmd weaponlist'" );
	}
	else 
	{
		self com_printnotitle( "^3To view available powerups do 'poweruplist'" );
		self com_printnotitle( "^3To view available perks do 'perklist'" );
		self com_printnotitle( "^3To view available weapons do 'weaponlist's" );		
	}
}

never_end_game()
{
	return false;
}

unittest_check_player_is_valid_for_powerup( player )
{
	return player istestclient();
}

no_player_damage_during_unittest( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( is_true( level.doing_cmd_system_unittest ) )
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

on_unittest()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "unittest_start" );
		level.solo_lives_given = -1000000;
		level.custom_player_fake_death = maps\mp\gametypes_zm\_callbacksetup::callbackvoid;
		level.no_end_game_check = true;
		level._game_module_game_end_check = ::never_end_game;
		level.player_out_of_playable_area_monitor = false;
		level.zm_disable_recording_stats = true;
		level.powerup_player_valid = ::unittest_check_player_is_valid_for_powerup;
		if ( isDefined( level.player_damage_callbacks ) && isDefined( level.player_damage_callbacks[ 0 ] ) )
		{
			old_player_damage_callback = level.player_damage_callbacks[ 0 ];
			level.player_damage_callbacks[ 0 ] = ::no_player_damage_during_unittest;
		}
		else 
		{
			level.player_damage_callbacks = [];
			level.player_damage_callbacks[ 0 ] = ::no_player_damage_during_unittest;
		}

		register_player_damage_callback( ::no_player_damage_during_unittest );
	}
}

give_powerup_zm( powerup_name )
{
	can_spawn = true;
	if ( self.origin[ 0 ] > 16384 || self.origin[ 0 ] < -16384 )
	{
		can_spawn = false;
	}
	else if ( self.origin[ 1 ] > 16384 || self.origin[ 1 ] < -16384 )
	{
		can_spawn = false;
	}
	else if ( self.origin[ 2 ] > 32768 || self.origin[ 2 ] < -32768 )
	{
		can_spawn = false;
	}
	if ( !can_spawn )
	{
		self com_printerror( "Cannot spawn a powerup this far from the map center" );
		return false;
	}
	powerup_loc = self.origin + anglestoforward( self.angles ) * 64 + anglestoright( self.angles ) * 64;
	powerup = maps\mp\zombies\_zm_powerups::specific_powerup_drop( powerup_name, powerup_loc );
	if ( powerup_name == "teller_withdrawl" )
	{
		powerup.value = 1000;
	}
	return true;
}

give_perk_zm( perkname, index )
{
	if ( !self hasperk( perkname ) )
	{
		self maps\mp\zombies\_zm_perks::give_perk( perkname, true );
	}
}

give_perk_zm_wrapper_executor( param, perk_name )
{
	if ( perk_name != "all" )
	{
		self give_perk_zm( perk_name );
		param add_executor_cmdinfo( "Gave perk " + perk_name + " to you" );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			self give_perk_zm( perk );
		}

		param add_executor_cmdinfo( "Gave you all perks" );
	}
}

give_perk_zm_wrapper_target( param, perk_name, player )
{
	if ( perk_name != "all" )
	{
		player give_perk_zm( perk_name );
		param add_executor_cmdinfo( "Gave perk '" + perk_name + "' to '" + player.name + "'" );
		param add_player_cmdinfo( player, "You received perk '" + perk_name + "'" );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			player give_perk_zm( perk );
		}

		param add_executor_cmdinfo( "Gave you all perks" );
		param add_player_cmdinfo( player, "You received perk '" + perk_name + "'" );
	}
}

take_perk_zm_wrapper_executor( param, perk_name )
{
	if ( perk_name != "all" )
	{
		self notify( perk_name + "_stop" );
		param add_executor_cmdinfo( "Gave perk " + perk_name + " to you" );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			self notify( perk + "_stop" );
		}

		param add_executor_cmdinfo( "Took all perks from you" );
	}
}

take_perk_zm_wrapper_target( param, perk_name, player )
{
	if ( perk_name != "all" )
	{
		player notify( perk_name + "_stop" );
		param add_executor_cmdinfo( "Gave perk '" + perk_name + "' to '" + player.name + "'" );
		param add_player_cmdinfo( player, "You lost perk '" + perk_name + "'" );
	}
	else 
	{
		valid_perk_list = perk_list_zm();
		foreach ( perk in valid_perk_list )
		{
			player notify( perk + "_stop" );
		}

		param add_executor_cmdinfo( "Gave you all perks" );
		param add_player_cmdinfo( player, "You lost all perks" );
	}
}

disable_zombies()
{
	level endon( "game_unpaused" );

	flag_clear( "spawn_zombies" );
	disablezombies( 1 );

	for ( ;; )
	{
		actors = [[ level._entity_type_funcs[ "actor" ].getter ]]();

		for ( i = 0; i < _SIZE( actors.size ); i++ )
		{
			ai = actors[ i ];
			ai.lastchunk_destroy_time = gettime();
			ai.ignore_distance_tracking = true;
		}

		wait 3;
	}
}

enable_zombies()
{
	flag_set( "spawn_zombies" );
	enablezombies( 1 );

	actors = [[ level._entity_type_funcs[ "actor" ].getter ]]();

	for ( i = 0; i < _SIZE( actors.size ); i++ )
	{
		ai = actors[ i ];
		ai.ignore_distance_tracking = undefined;
	}

	wait 3;
}

game_pause( duration )
{
	level thread disable_zombies();
	foreach ( player in level.players )
	{
		player enableInvulnerability();
		player.tcs_is_invulnerable = true;
	}
	level thread unpause_after_time( duration );
}

unpause_after_time( duration )
{
	if ( duration < 0 )
	{
		return;
	}
	level notify( "unpause_countdown" );
	level endon( "unpause_countdown" );
	level endon( "game_unpaused" );
	duration_seconds = duration * 60;
	for ( ; _SIZE( duration_seconds ) > 0; duration_seconds-- )
	{
		wait 1;
	}
	game_unpause();
}

game_unpause()
{
	level notify( "game_unpaused" );

	level thread enable_zombies();
	foreach ( player in level.players )
	{
		player disableInvulnerability();
		player.tcs_is_invulnerable = false;
	}
}

give_perma_perk( perk_name )
{
	self maps\mp\zombies\_zm_stats::increment_client_stat( perk_name, 0 );
}

give_all_perma_perks()
{
	foreach ( key in level.pers_upgrades_keys )
	{
		self give_perma_perk( level.pers_upgrades[ key ].stat_names[ 0 ] );
	}
}

unlimited_weapons( player )
{
	return 5;
}

list_weapons_throttled()
{
	self notify( "listing_weapons" );
	self endon( "listing_weapons" );

	weapons = get_all_weapons();
	for ( i = 0; i < _SIZE( weapons.size ); i++ )
	{
		self com_printnotitle( weapons[ i ] );
		wait 0.1;
	}
	
	self com_printconsoleprintlore();
}

open_seseme()
{
	level.tcs_doors_all_opened = !is_true( level.tcs_doors_all_opened );
	flag_wait( "initial_blackscreen_passed" );
	setdvar( "zombie_unlock_all", 1 );
	flag_set( "power_on" );

	zombie_doors = getentarray( "zombie_door", "targetname" );
	for ( i = 0; i < _SIZE( zombie_doors.size ); i++ )
	{
		zombie_doors[ i ] notify( "trigger" );
		if ( is_true( zombie_doors[ i ].power_door_ignore_flag_wait ) )
		{
			zombie_doors[ i ] notify( "power_on" );
		}
		wait 0.05;
	}
	zombie_airlock_doors = getentarray( "zombie_airlock_buy", "targetname" );
	for ( i = 0; i < _SIZE( zombie_airlock_doors.size ); i++ )
	{
		zombie_airlock_doors[ i ] notify( "trigger" );
		wait 0.05;
	}
	zombie_debris = getentarray( "zombie_debris", "targetname" );
	for ( i = 0; i < _SIZE( zombie_debris.size ); i++ )
	{
		zombie_debris[ i ] notify( "trigger", level.players[ 0 ] );
		wait 0.05;
	}
	setdvar( "zombie_unlock_all", 0 );
}

list_powerups_throttled()
{
	self notify( "listing_powerups" );
	self endon( "listing_powerups" );

	powerups = getarraykeys( level.zombie_include_powerups );
	for ( i = 0; i < _SIZE( powerups.size ); i++ )
	{
		self com_printnotitle( powerups[ i ] );
		wait 0.1;
	}
}

list_perks_throttled()
{
	self notify( "listing_perks" );
	self endon( "listing_perks" );

	perks = perk_list_zm();
	for ( i = 0; i < _SIZE( perks.size ); i++ )
	{
		self com_printnotitle( perks[ i ] );
		wait 0.1;
	}
}

set_global_zombie_stat( stat, stat_name, stat_value )
{
	if ( isDefined( level.zombie_vars[ "zombie_" + stat_name ] ) )
	{
		level.tcs_modifiable_zombie_stats[ stat_name ].current_value = stat_value;
		level.zombie_vars[ "zombie_" + stat_name ] = stat_value;
		level [[ stat.recalculate_func ]]( stat_name, stat_value );
		return true;
	}
	switch ( stat_name )
	{
		case "ai_limit":
			level.tcs_modifiable_zombie_stats[ stat_name ].current_value = stat_value;
			level.zombie_ai_limit = stat_value;
			return true;
		default:
			return false;
	}
}

list_zombie_stats_throttled()
{
	self notify( "listing_zombie_stats" );
	self endon( "listing_zombie_stats" );
	stat_names = getArrayKeys( level.tcs_modifiable_zombie_stats );
	for ( i = 0; i < _SIZE( stat_names.size ); i++ )
	{
		cur_value = level.tcs_modifiable_zombie_stats[ stat_names[ i ] ].current_value;
		reset_value = level.tcs_modifiable_zombie_stats[ stat_names[ i ] ].reset_value;

		message = stat_names[ i ] + " current: " +  cur_value + " default: " + reset_value;

		self com_printnotitle( message );
		wait 0.1;
	}

	self com_printconsoleprintlore();
}

end_of_round_behavior()
{
	level.first_round = 0;
	level notify( "end_of_round" );
	level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_end" );
	uploadstats();

	if ( isdefined( level.round_end_custom_logic ) )
		[[ level.round_end_custom_logic ]]();

	if ( isdefined( level.no_end_game_check ) && level.no_end_game_check )
	{
		level thread last_stand_revive();
		level thread spectators_respawn();
	}
	else if ( 1 != level.players.size )
		level thread spectators_respawn();

	array_thread( level.players, maps\mp\zombies\_zm_pers_upgrades_system::round_end );
	timer = level.zombie_vars["zombie_spawn_delay"];

	setroundsplayed( level.round_number );
	matchutctime = getutc();

	foreach ( player in level.players )
	{
		if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
			player maps\mp\zombies\_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );

		player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
		player maps\mp\zombies\_zm_stats::update_playing_utc_time( matchutctime );
	}

	check_quickrevive_for_hotjoin();
	level round_over();
	level notify( "between_round_over" );
	restart = 0;
}

change_round( target_round )
{
	level notify( "end_round_think" );
	level.zombie_vars["spectators_respawn"] = 1;
	level.zombie_total = 0;
	if ( level.gamedifficulty == 0 )
		level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
	else
		level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];
	level.zombie_vars["zombie_spawn_delay"] = 2;
	for ( i = 1; i <= _SIZE( level.round_number ); i++ )
	{
		timer = level.zombie_vars["zombie_spawn_delay"];

		if ( timer > 0.08 )
		{
			level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
			continue;
		}

		if ( timer < 0.08 )
		{
			level.zombie_vars["zombie_spawn_delay"] = 0.08;
			break;
		}
	}
	maps\mp\zombies\_zm::ai_calculate_health( target_round );
	zombies = get_round_enemy_array();

	if ( isdefined( zombies ) )
	{
		for ( i = 0; i < _SIZE( zombies.size ); i++ )
			zombies[i] dodamage( zombies[i].health + 666, zombies[i].origin );
	}

	level end_of_round_behavior();
	level thread maps\mp\zombies\_zm::round_think( 1 );
}

register_modifiable_zombie_stat( stat_name, value_type, reset_value, recalculate_func )
{
	if ( !isDefined( level.tcs_modifiable_zombie_stats ) )
	{
		level.tcs_modifiable_zombie_stats = [];
	}

	level.tcs_modifiable_zombie_stats[ stat_name ] = spawnStruct();
	level.tcs_modifiable_zombie_stats[ stat_name ].type = value_type;
	level.tcs_modifiable_zombie_stats[ stat_name ].current_value = reset_value;
	level.tcs_modifiable_zombie_stats[ stat_name ].reset_value = reset_value;
	level.tcs_modifiable_zombie_stats[ stat_name ].recalculate_func = recalculate_func;
}

zombie_recalculate_health( stat_name, new_value )
{
	level.zombie_health = level.zombie_vars["zombie_health_start"];

	for ( i = 2; i <= _SIZE( level.round_number ); i++ )
	{
		if ( i >= 10 )
		{
			old_health = level.zombie_health;
			level.zombie_health += int( level.zombie_health * level.zombie_vars["zombie_health_increase_multiplier"] );

			if ( level.zombie_health < old_health )
			{
				level.zombie_health = old_health;
				return;
			}
		}
		else
			level.zombie_health = int( level.zombie_health + level.zombie_vars["zombie_health_increase"] );
	}
}

zombie_recalculate_spawn_delay( stat_name, new_value )
{
	if ( new_value != 2 )
	{
		return;
	}
	for ( i = 1; i <= _SIZE( level.round_number ); i++ )
	{
		timer = level.zombie_vars["zombie_spawn_delay"];

		if ( timer > 0.08 )
		{
			level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
			continue;
		}

		if ( timer < 0.08 )
			level.zombie_vars["zombie_spawn_delay"] = 0.08;
	}	
}

zombie_recalculate_move_speed( stat_name, new_value )
{
	if ( level.gamedifficulty == 0 )
		level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
	else
		level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];
}

zombie_recalculate_total( stat_name, new_value )
{
	max = level.zombie_vars["zombie_max_ai"];
	multiplier = level.round_number / 5;

	if ( multiplier < 1 )
		multiplier = 1;

	if ( level.round_number >= 10 )
		multiplier *= ( level.round_number * 0.15 );

	player_num = level.players.size;

	if ( player_num == 1 )
		max += int( 0.5 * level.zombie_vars["zombie_ai_per_player"] * multiplier );
	else
		max += int( ( player_num - 1 ) * level.zombie_vars["zombie_ai_per_player"] * multiplier );

	if ( !isdefined( level.max_zombie_func ) )
		level.max_zombie_func = ::default_max_zombie_func;

	if ( !( isdefined( level.kill_counter_hud ) && level.zombie_total > 0 ) )
	{
		level.zombie_total = [[ level.max_zombie_func ]]( max );
		level notify( "zombie_total_set" );
	}	
}

weapon_check_success( weapon )
{
	return self hasweapon( weapon );
}

weapon_give_custom( weapon, is_upgrade, should_switch_weapon )
{
	primaryweapons = self getweaponslistprimaries();
	current_weapon = self getcurrentweapon();
	current_weapon = self maps\mp\zombies\_zm_weapons::switch_from_alt_weapon( current_weapon );
	if ( !isdefined( is_upgrade ) )
		is_upgrade = 0;

	weapon_limit = get_player_weapon_limit( self );

	if ( is_equipment( weapon ) )
		self maps\mp\zombies\_zm_equipment::equipment_give( weapon );

	if ( weapon == "riotshield_zm" )
	{
		if ( isdefined( self.player_shield_reset_health ) )
			self [[ self.player_shield_reset_health ]]();
	}

	if ( self hasweapon( weapon ) )
	{
		if ( issubstr( weapon, "knife_ballistic_" ) )
			self notify( "zmb_lost_knife" );

		self givestartammo( weapon );

		if ( !is_offhand_weapon( weapon ) )
			self switchtoweapon( weapon );

		return self weapon_check_success( weapon );
	}

	if ( is_melee_weapon( weapon ) )
		current_weapon = maps\mp\zombies\_zm_melee_weapon::change_melee_weapon( weapon, current_weapon );
	else if ( is_lethal_grenade( weapon ) )
	{
		old_lethal = self get_player_lethal_grenade();

		if ( isdefined( old_lethal ) && old_lethal != "" )
		{
			self takeweapon( old_lethal );
			unacquire_weapon_toggle( old_lethal );
		}

		self set_player_lethal_grenade( weapon );
	}
	else if ( is_tactical_grenade( weapon ) )
	{
		old_tactical = self get_player_tactical_grenade();

		if ( isdefined( old_tactical ) && old_tactical != "" )
		{
			self takeweapon( old_tactical );
			unacquire_weapon_toggle( old_tactical );
		}

		self set_player_tactical_grenade( weapon );
	}
	else if ( is_placeable_mine( weapon ) )
	{
		old_mine = self get_player_placeable_mine();

		if ( isdefined( old_mine ) )
		{
			self takeweapon( old_mine );
			unacquire_weapon_toggle( old_mine );
		}

		self set_player_placeable_mine( weapon );
	}

	if ( !is_offhand_weapon( weapon ) )
		self maps\mp\zombies\_zm_weapons::take_fallback_weapon();

	if ( primaryweapons.size >= weapon_limit )
	{
		if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) )
			current_weapon = undefined;

		if ( isdefined( current_weapon ) )
		{
			if ( !is_offhand_weapon( weapon ) )
			{
				if ( current_weapon == "tesla_gun_zm" )
					level.player_drops_tesla_gun = 1;

				if ( issubstr( current_weapon, "knife_ballistic_" ) )
					self notify( "zmb_lost_knife" );

				self takeweapon( current_weapon );
				unacquire_weapon_toggle( current_weapon );
			}
		}
	}

	if ( isdefined( level.zombiemode_offhand_weapon_give_override ) )
	{
		if ( self [[ level.zombiemode_offhand_weapon_give_override ]]( weapon ) )
			return self weapon_check_success( weapon );
	}

	if ( weapon == "cymbal_monkey_zm" )
	{
		self maps\mp\zombies\_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
		return self weapon_check_success( weapon );
	}
	else if ( issubstr( weapon, "knife_ballistic_" ) )
		weapon = self maps\mp\zombies\_zm_melee_weapon::give_ballistic_knife( weapon, issubstr( weapon, "upgraded" ) );
	else if ( weapon == "claymore_zm" )
	{
		self thread maps\mp\zombies\_zm_weap_claymore::claymore_setup();
		return self weapon_check_success( weapon );
	}

	if ( isdefined( level.zombie_weapons_callbacks ) && isdefined( level.zombie_weapons_callbacks[weapon] ) )
	{
		self thread [[ level.zombie_weapons_callbacks[weapon] ]]();
		return self weapon_check_success( weapon );
	}
	if ( weapon == "ray_gun_zm" )
		playsoundatposition( "mus_raygun_stinger", ( 0, 0, 0 ) );
	if ( !is_weapon_upgraded( weapon ) )
		self giveweapon( weapon );
	else
		self giveweapon( weapon, 0, self get_pack_a_punch_weapon_options( weapon ) );
	if ( self istestclient() )
	{
		self setspawnweapon( weapon );
	}
	acquire_weapon_toggle( weapon, self );
	self givestartammo( weapon );

	if ( !is_offhand_weapon( weapon ) && should_switch_weapon )
	{
		if ( !is_melee_weapon( weapon ) )
			self switchtoweapon( weapon );
		else
			self switchtoweapon( current_weapon );
	}

	return self weapon_check_success( weapon );
}