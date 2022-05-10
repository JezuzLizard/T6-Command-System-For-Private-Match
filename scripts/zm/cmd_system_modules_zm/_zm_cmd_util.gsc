#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_magicbox;

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
