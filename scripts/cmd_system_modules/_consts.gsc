init_consts()
{
	build_tcs_consts();
	build_contents_array();
	build_hitlocs_array();
	build_mods_array();
	build_idflags_array();
	build_sessionstate_array();
	build_dynamic_spawnable_classname_array();
	build_dynamic_spawnable_function_array();
	build_bsp_spawnable_classname_array();
}

build_tcs_consts()
{
	level._is_required_target = true;
	level._is_optional_target = false;
}

/*
	CONTENTS_SOLID = 0x1,
	CONTENTS_FOLIAGE = 0x2,
	CONTENTS_NONCOLLIDING = 0x4,
	CONTENTS_GLASS = 0x10,
	CONTENTS_WATER = 0x20,
	CONTENTS_CANSHOOTCLIP = 0x40,
	CONTENTS_MISSILECLIP = 0x80,
	CONTENTS_ITEM = 0x100,
	CONTENTS_VEHICLECLIP = 0x200,
	CONTENTS_ITEMCLIP = 0x400,
	CONTENTS_SKY = 0x800,
	CONTENTS_AI_NOSIGHT = 0x1000,
	CONTENTS_CLIPSHOT = 0x2000,
	CONTENTS_CORPSE_CLIPSHOT = 0x4000,
	CONTENTS_ACTOR = 0x8000,
	CONTENTS_FAKE_ACTOR = 0x8000,
	CONTENTS_PLAYERCLIP = 0x10000,
	CONTENTS_MONSTERCLIP = 0x20000,
	CONTENTS_PLAYERVEHICLECLIP = 0x40000,
	CONTENTS_USE = 0x200000,
	CONTENTS_UTILITYCLIP = 0x400000,
	CONTENTS_VEHICLE = 0x800000,
	CONTENTS_MANTLE = 0x1000000,
	CONTENTS_PLAYER = 0x2000000,
	CONTENTS_CORPSE = 0x4000000,
	CONTENTS_DETAIL = 0x8000000,
	CONTENTS_STRUCTURAL = 0x10000000,
	CONTENTS_LOOKAT = 0x10000000,
	CONTENTS_TRIGGER = 0x40000000,
	CONTENTS_NODROP = 0x80000000,
*/
build_contents_array()
{
	level.tcs_contents = [];
	level.tcs_contents[ "NONE" ] = 0;
	level.tcs_contents[ "SOLID" ] = 1 << 0;
	level.tcs_contents[ "FOILAGE" ] = 1 << 1;
	level.tcs_contents[ "NONCOLLIDING" ] = 1 << 2;
	level.tcs_contents[ "UNK1" ] = 1 << 3;
	level.tcs_contents[ "GLASS" ] = 1 << 4;
	level.tcs_contents[ "WATER" ] = 1 << 5;
	level.tcs_contents[ "CANSHOOTCLIP" ] = 1 << 6;
	level.tcs_contents[ "MISSILECLIP" ] = 1 << 7;
	level.tcs_contents[ "ITEM" ] = 1 << 8;
	level.tcs_contents[ "VEHICLECLIP" ] = 1 << 9;
	level.tcs_contents[ "ITEMCLIP" ] = 1 << 10;
	level.tcs_contents[ "SKY" ] = 1 << 11;
	level.tcs_contents[ "AI_NOSIGHT" ] = 1 << 12;
	level.tcs_contents[ "CLIPSHOT" ] = 1 << 13;
	level.tcs_contents[ "CORPSE_CLIPSHOT" ] = 1 << 14;
	level.tcs_contents[ "ACTOR" ] = 1 << 15;
	level.tcs_contents[ "FAKE_ACTOR" ] = level.tcs_contents[ "ACTOR" ];
	level.tcs_contents[ "PLAYERCLIP" ] = 1 << 16;
	level.tcs_contents[ "MONSTERCLIP" ] = 1 << 17;
	level.tcs_contents[ "PLAYERVEHICLECLIP" ] = 1 << 18;
	level.tcs_contents[ "UNK2" ] = 1 << 19;
	level.tcs_contents[ "UNK3" ] = 1 << 20;
	level.tcs_contents[ "USE" ] = 1 << 21;
	level.tcs_contents[ "UTILITYCLIP" ] = 1 << 22;
	level.tcs_contents[ "VEHICLE" ] = 1 << 23;
	level.tcs_contents[ "MANTLE" ] = 1 << 24;
	level.tcs_contents[ "PLAYER" ] = 1 << 25;
	level.tcs_contents[ "CORPSE" ] = 1 << 26;
	level.tcs_contents[ "DETAIL" ] = 1 << 27;
	level.tcs_contents[ "STRUCTURAL" ] = 1 << 28;
	level.tcs_contents[ "LOOKAT" ] = level.tcs_contents[ "STRUCTURAL" ];
	level.tcs_contents[ "UNK4" ] = 1 << 29;
	level.tcs_contents[ "TRIGGER" ] = 1 << 30;
	level.tcs_contents[ "NODROP" ] = 1 << 31;
}

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

build_dynamic_spawnable_classname_array()
{
	level.tcs_dynamic_spawns = [];
	level.tcs_dynamic_spawns[ "info_notnull" ] = 0;
	level.tcs_dynamic_spawns[ "info_notnull_big" ] = 1;
	level.tcs_dynamic_spawns[ "info_volume" ] = 2;
	level.tcs_dynamic_spawns[ "trigger_radius" ] = 3;
	level.tcs_dynamic_spawns[ "trigger_box" ] = 4;
	level.tcs_dynamic_spawns[ "trigger_box_use" ] = 5;
	level.tcs_dynamic_spawns[ "trigger_radius_use" ] = 6;
	level.tcs_dynamic_spawns[ "trigger_damage" ] = 7;
	level.tcs_dynamic_spawns[ "script_model" ] = 8;
	level.tcs_dynamic_spawns[ "script_origin" ] = 9;
	level.tcs_dynamic_spawns[ "weapon_" ] = 10;
	level.tcs_dynamic_spawns[ "_spawn" ] = 11;
}

build_dynamic_spawnable_function_array()
{
	level.tcs_dynamic_function_spawns = [];
	level.tcs_dynamic_function_spawns[ "spawn" ] = 0;
	level.tcs_dynamic_function_spawns[ "spawncollision" ] = 1;
	level.tcs_dynamic_function_spawns[ "spawnplane" ] = 2;
	level.tcs_dynamic_function_spawns[ "spawnhelicopter" ] = 3;
	level.tcs_dynamic_function_spawns[ "spawnnapalmgroundflame" ] = 4;
	level.tcs_dynamic_function_spawns[ "spawntimedfx" ] = 5;
	level.tcs_dynamic_function_spawns[ "spawnturret" ] = 6;
	level.tcs_dynamic_function_spawns[ "spawnvehicle" ] = 7;
	level.tcs_dynamic_function_spawns[ "spawnactor" ] = 8;
	level.tcs_dynamic_function_spawns[ "spawnpathnode" ] = 9;
	level.tcs_dynamic_function_spawns[ "spawnfx" ] = 10;
	level.tcs_dynamic_function_spawns[ "cloneplayer" ] = 11;
}

build_bsp_spawnable_classname_array()
{
	level.tcs_bsp_spawns = [];
	level.tcs_bsp_spawns[ "trigger_use" ] = 0;
	level.tcs_bsp_spawns[ "trigger_multiple" ] = 1;
	level.tcs_bsp_spawns[ "trigger_disk" ] = 2;
	level.tcs_bsp_spawns[ "trigger_hurt" ] = 3;
	level.tcs_bsp_spawns[ "trigger_once" ] = 4;
	level.tcs_bsp_spawns[ "trigger_lookat" ] = 5;
	level.tcs_bsp_spawns[ "trigger_ik_playerclip_terrain" ] = 6;
	level.tcs_bsp_spawns[ "light" ] = 7;
	level.tcs_bsp_spawns[ "misc_turret" ] = 8;
	level.tcs_bsp_spawns[ "script_brushmodel" ] = 9;
	level.tcs_bsp_spawns[ "script_struct" ] = 10;
	level.tcs_bsp_spawns[ "script_vehicle" ] = 11;
	level.tcs_bsp_spawns[ "zbarrier_" ] = 12;
	level.tcs_bsp_spawns[ "actor_" ] = 13;
	level.tcs_bsp_spawns[ "node_" ] = 14;
	level.tcs_bsp_spawns[ "info_vehicle_node" ] = 15;
	level.tcs_bsp_spawns[ "info_vehicle_node_rotate" ] = 16;
	level.tcs_bsp_spawns[ "heli_height_lock" ] = 17;
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