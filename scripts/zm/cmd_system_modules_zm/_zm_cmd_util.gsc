#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_magicbox;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;

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

		return;
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
			return;
	}

	if ( weapon == "cymbal_monkey_zm" )
	{
		self maps\mp\zombies\_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
		return;
	}
	else if ( issubstr( weapon, "knife_ballistic_" ) )
		weapon = self maps\mp\zombies\_zm_melee_weapon::give_ballistic_knife( weapon, issubstr( weapon, "upgraded" ) );
	else if ( weapon == "claymore_zm" )
	{
		self thread maps\mp\zombies\_zm_weap_claymore::claymore_setup();
		return;
	}

	if ( isdefined( level.zombie_weapons_callbacks ) && isdefined( level.zombie_weapons_callbacks[weapon] ) )
	{
		self thread [[ level.zombie_weapons_callbacks[weapon] ]]();
		return;
	}
	if ( weapon == "ray_gun_zm" )
		playsoundatposition( "mus_raygun_stinger", ( 0, 0, 0 ) );
	if ( !is_weapon_upgraded( weapon ) )
		self giveweapon( weapon );
	else
		self giveweapon( weapon, 0, self get_pack_a_punch_weapon_options( weapon ) );
	if ( is_true( self.pers["isBot"] ) )
	{
		self setSpawnWeapon( weapon );
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
	for ( i = 1; i <= level.round_number; i++ )
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
	maps\mp\zombies\_zm::ai_calculate_health( target_round );
	zombies = get_round_enemy_array();

	if ( isdefined( zombies ) )
	{
		for ( i = 0; i < zombies.size; i++ )
			zombies[i] dodamage( zombies[i].health + 666, zombies[i].origin );
	}
	level thread maps\mp\zombies\_zm::round_think( 1 );
}

bot_unittest_func()
{
	self maps\mp\zombies\_zm::reset_rampage_bookmark_kill_times();
}

register_modifiable_zombie_stat( stat_name, value_type, current_value, reset_value, recalculate_func )
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

	for ( i = 2; i <= level.round_number; i++ )
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
	for ( i = 1; i <= level.round_number; i++ )
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

	player_num = getPlayers().size;

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

arg_perk_handler( arg )
{
	perks = perk_list_zm();
	channel = self com_get_cmd_feedback_channel();
	if ( perks.size <= 0 )
	{
		level com_printf( channel, "notitle", "There are no perks on the map", self );
		return false;
	}
	return isInArray( perks, arg ) || arg == "all";
}

arg_generate_rand_perk()
{
	perks = perk_list_zm();
	if ( perks.size <= 0 )
	{
		return "invalid_perk";
	}
	return randomInt( 20 ) < 1 ? "all" : perks[ randomInt( perks.size ) ];	
}

arg_weapon_handler( arg )
{
	channel = self com_get_cmd_feedback_channel();
	if ( !isDefined( level.zombie_include_weapons ) || level.zombie_include_weapons.size <= 0 )
	{
		level com_printf( channel, "notitle", "There are no weapons on the map", self );
		return false;
	}
	return isDefined( level.zombie_include_weapons[ arg ] );
}

arg_generate_rand_weapon()
{
	if ( !isDefined( level.zombie_include_weapons ) || level.zombie_include_weapons.size <= 0 )
	{
		return "invalid_weapon";
	}
	weapon_keys = getArrayKeys( level.zombie_include_weapons );
	return weapon_keys[ randomInt( weapon_keys.size ) ];	
}

arg_powerup_handler( arg )
{
	channel = self com_get_cmd_feedback_channel();
	if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size <= 0 )
	{
		level com_printf( channel, "notitle", "There are no powerups on the map", self );
		return false;
	}
	return isDefined( level.zombie_include_powerups[ arg ] );
}

arg_generate_rand_powerup()
{
	if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size <= 0 )
	{
		return "invalid_powerup";
	}
	powerup_keys = getArrayKeys( level.zombie_include_powerups );
	powerup = "";
	while ( powerup == "" || powerup == "teller_withdrawl" )
	{
		powerup = powerup_keys[ randomInt( powerup_keys.size ) ];
	}
	return powerup;	
}

arg_round_handler( arg )
{
	return is_natural_num( arg ) && int( arg ) <= 255;
}

arg_generate_rand_round()
{
	return randomint( 256 );
}