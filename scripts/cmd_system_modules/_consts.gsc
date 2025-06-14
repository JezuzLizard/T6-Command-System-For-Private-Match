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