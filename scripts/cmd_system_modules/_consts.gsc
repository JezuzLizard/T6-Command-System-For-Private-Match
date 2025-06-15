build_hitlocs_array()
{
	level.tcs_hitlocs = [];
	level.tcs_hitlocs[ "none" ] = 0;
	level.tcs_hitlocs[ "gun" ] = 1;
	level.tcs_hitlocs[ "head" ] = 2;
	level.tcs_hitlocs[ "helmet" ] = 3;
	level.tcs_hitlocs[ "neck" ] = 4;
	level.tcs_hitlocs[ "shield" ] = 5;
	level.tcs_hitlocs[ "torso_upper" ] = 6;
	level.tcs_hitlocs[ "torso_lower" ] = 7;
	level.tcs_hitlocs[ "left_arm_lower" ] = 8;
	level.tcs_hitlocs[ "left_arm_upper" ] = 9;
	level.tcs_hitlocs[ "right_arm_lower" ] = 10;
	level.tcs_hitlocs[ "right_arm_upper" ] = 11;
	level.tcs_hitlocs[ "left_hand" ] = 12;
	level.tcs_hitlocs[ "right_hand" ] = 13;
	level.tcs_hitlocs[ "left_leg_lower" ] = 14;
	level.tcs_hitlocs[ "left_leg_upper" ] = 15;
	level.tcs_hitlocs[ "right_leg_lower" ] = 16;
	level.tcs_hitlocs[ "right_leg_upper" ] = 17;
	level.tcs_hitlocs[ "left_foot" ] = 18;
	level.tcs_hitlocs[ "right_foot" ] = 19;
}

build_mods_array()
{
	level.tcs_mods = [];
	level.tcs_mods[ "MOD_UNKNOWN" ] = 0;
	level.tcs_mods[ "MOD_PISTOL_BULLET" ] = 1;
	level.tcs_mods[ "MOD_RIFLE_BULLET" ] = 2;
	level.tcs_mods[ "MOD_GRENADE" ] = 3;
	level.tcs_mods[ "MOD_GRENADE_SPLASH" ] = 4;
	level.tcs_mods[ "MOD_PROJECTILE" ] = 5;
	level.tcs_mods[ "MOD_PROJECTILE_SPLASH" ] = 6;
	level.tcs_mods[ "MOD_MELEE" ] = 7;
	level.tcs_mods[ "MOD_BAYONET" ] = 8;
	level.tcs_mods[ "MOD_HEAD_SHOT" ] = 9;
	level.tcs_mods[ "MOD_CRUSH" ] = 10;
	level.tcs_mods[ "MOD_TELEFRAG" ] = 11;
	level.tcs_mods[ "MOD_FALLING" ] = 12;
	level.tcs_mods[ "MOD_SUICIDE" ] = 13;
	level.tcs_mods[ "MOD_TRIGGER_HURT" ] = 14;
	level.tcs_mods[ "MOD_EXPLOSIVE" ] = 15;
	level.tcs_mods[ "MOD_IMPACT" ] = 16;
	level.tcs_mods[ "MOD_BURNED" ] = 17;
	level.tcs_mods[ "MOD_HIT_BY_OBJECT" ] = 18;
	level.tcs_mods[ "MOD_DROWN" ] = 19;
	level.tcs_mods[ "MOD_GAS" ] = 20;
}

build_idflags_array()
{
	level.tcs_idflags = [];
	level.tcs_idflags[ "radius" ] = 1 << 0;
	level.tcs_idflags[ "no_armor" ] = 1 << 1;
	level.tcs_idflags[ "no_knockback" ] = 1 << 2;
	level.tcs_idflags[ "penetration" ] = 1 << 3;
	level.tcs_idflags[ "destructible_entity" ] = 1 << 4;
	level.tcs_idflags[ "shield_explosive_impact" ] = 1 << 5;
	level.tcs_idflags[ "shield_explosive_impact_huge" ] = 1 << 6;
	level.tcs_idflags[ "shield_explosive_splash" ] = 1 << 7;
	level.tcs_idflags[ "no_team_protection" ] = 1 << 8;
	level.tcs_idflags[ "no_protection" ] = 1 << 9;
	level.tcs_idflags[ "passthru" ] = 1 << 10;
}

build_sessionstate_array()
{
	level.tcs_sessstates = [];
	level.tcs_sessstates[ "playing" ] = 0;
	level.tcs_sessstates[ "dead" ] = 1;
	level.tcs_sessstates[ "spectator" ] = 2;
	level.tcs_sessstates[ "intermission" ] = 3;
}

get_perk_from_alias_zm( alias )
{
	switch ( alias )
	{
		case "ju":
		case "jug":
		case "jugg":
		case "juggernog":
			return "specialty_armorvest";
		case "ro":
		case "rof":
		case "double":
		case "doubletap":
			return "specialty_rof";
		case "qq":
		case "quick":
		case "revive":
		case "quickrevive":
			return "specialty_quickrevive";
		case "sp":
		case "speed":
		case "fastreload":
		case "speedcola":
			return "specialty_fastreload";
		case "st":
		case "staminup":
		case "longersprint":
			return "specialty_longersprint";
		case "fl":
		case "flakjacket":
		case "flopper":
			return "specialty_flakjacket";
		case "ds":
		case "deadshot":
			return "specialty_deadshot";
		case "mk":
		case "mulekick":
			return "specialty_additionalprimaryweapon";
		case "tm":
		case "tombstone":
			return "specialty_scavenger";
		case "ww":
		case "whoswho":
			return "specialty_finalstand";
		case "ec":
		case "electriccherry":
			return "specialty_grenadepulldeath";
		case "va":
		case "vultureaid":
			return "specialty_nomotionsensor";
		case "all":
			return "all";
		default:
			return alias;
	}
}

get_powerup_from_alias_zm( alias )
{
	switch ( alias )
	{
		case "nuke":
			return "nuke";
		case "insta":
		case "instakill":
			return "insta_kill";
		case "double":
		case "doublepoints":
			return "double_points";
		case "max":
		case "ammo":
		case "maxammo":
			return "full_ammo";
		case "carp":
			return "carpenter";
		case "sale":
		case "firesale":
			return "fire_sale";
		case "perk":
		case "freeperk":
			return "free_perk";
		case "blood":
		case "zombieblood":
			return "zombie_blood";
		case "points":
			return "bonus_points";
		case "teampoints":
			return "bonus_points_team";
		default:
			return alias;
	}
}

powerup_list_zm()
{
	return getarraykeys( level.zombie_include_powerups );
}

get_perma_perk_from_alias( alias )
{
	switch ( alias )
	{
		case "bo":
		case "boards":
			return "pers_boarding";
		case "re":
		case "revive":
			return "pers_reviveonperk";
		case "he":
		case "headshots":
			return "pers_multikill_headshots";
		case "ca":
		case "cashback":
			return "pers_cash_back_prone";
		case "in":
		case "instakill":
			return "pers_insta_kill";
		case "ju":
		case "jugg":
			return "pers_jugg";
		case "cr":
		case "carpenter":
			return "pers_carpenter";
		case "fl":
		case "flopper":
			return "pers_flopper_counter";
		case "pe":
		case "perklose":
			return "pers_perk_lose_counter";
		case "pp":
		case "pistolpoints":
			return "pers_double_points_counter";
		case "sn":
		case "sniperpoints":
			return "pers_sniper_counter";
		case "bx":
		case "boxweapon":
			return "pers_box_weapon_counter";
		case "nu":
		case "nube":
			return "pers_nube_counter";
		case "all":
			return "all";
		default: 
			return alias;
	}
}