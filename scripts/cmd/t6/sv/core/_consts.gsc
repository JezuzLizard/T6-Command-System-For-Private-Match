#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\t6\sv\core\_utility;

autoexec init_consts()
{
	build_contents_array();
	build_hitlocs_array();
	build_mods_array();
	build_idflags_array();
	build_sessionstate_array();
	build_dynamic_spawnable_classname_array();
	build_dynamic_spawnable_function_array();
	build_bsp_spawnable_classname_array();

	level._number_strings = [];
	level._number_strings[ "float" ] = "-.0123456789";
	level._number_strings[ "positive_float" ] = ".0123456789";
	level._number_strings[ "int" ] = "-0123456789";
	level._number_strings[ "positive_int" ] = "0123456789";
	level._number_strings[ "natural_int" ] = "123456789";

	level._boolean_strings = [];
	level._boolean_strings[ "true" ] = [];
	level._boolean_strings[ "true" ][0] = "1";
	level._boolean_strings[ "true" ][1] = "true";
	level._boolean_strings[ "false" ] = [];
	level._boolean_strings[ "false" ][0] = "0";
	level._boolean_strings[ "false" ][1] = "false";

	level._alphabet_array = [];

	alpha_string = "abcdefghijklmnopqrstuvwxyz";

	for ( i = 0; i < alpha_string.size; i++ )
	{
		level._alphabet_array[ alpha_string[ i ] ] = i;
	}

	level._numeric_array = [];

	numeric_string = "0123456789";

	for ( i = 0; i < numeric_string.size; i++ )
	{
		level._numeric_array[ numeric_string[ i ] ] = i;
	}

	/*
		ET_GENERAL = 0x0,
		ET_PLAYER = 0x1,
		ET_PLAYER_CORPSE = 0x2,
		ET_ITEM = 0x3,
		ET_MISSILE = 0x4,
		ET_INVISIBLE = 0x5,
		ET_SCRIPTMOVER = 0x6,
		ET_SOUND_BLEND = 0x7,
		ET_FX = 0x8,
		ET_LOOP_FX = 0x9,
		ET_PRIMARY_LIGHT = 0xA,
		ET_TURRET = 0xB,
		ET_HELICOPTER = 0xC,
		ET_PLANE = 0xD,
		ET_VEHICLE = 0xE,
		ET_VEHICLE_CORPSE = 0xF,
		ET_ACTOR = 0x10,
		ET_ACTOR_SPAWNER = 0x11,
		ET_ACTOR_CORPSE = 0x12,
		ET_STREAMER_HINT = 0x13,
		ET_ZBARRIER = 0x14,
		ET_EVENTS = 0x15,
	*/
	level._entity_types = [];
	level._entity_types[ "undefined" ] = -2;
	level._entity_types[ "world" ] = -1;
	level._entity_types[ "general" ] = 0;
	level._entity_types[ "player" ] = 1;
	level._entity_types[ "player_corpse" ] = 2;
	level._entity_types[ "item" ] = 3;
	level._entity_types[ "missile" ] = 4;
	level._entity_types[ "invisible" ] = 5;
	level._entity_types[ "scriptmover" ] = 6;
	level._entity_types[ "sound_blend" ] = 7;
	level._entity_types[ "fx" ] = 8;
	level._entity_types[ "loop_fx" ] = 9;
	level._entity_types[ "primary_light" ] = 10;
	level._entity_types[ "turret" ] = 11;
	level._entity_types[ "helicopter" ] = 12;
	level._entity_types[ "plane" ] = 13;
	level._entity_types[ "vehicle" ] = 14;
	level._entity_types[ "vehicle_corpse" ] = 15;
	level._entity_types[ "actor" ] = 16;
	level._entity_types[ "actor_spawner" ] = 17;
	level._entity_types[ "actor_corpse" ] = 18;
	level._entity_types[ "streamer_hint" ] = 19;
	level._entity_types[ "zbarrier" ] = 20;
	level._entity_types[ "temp_entity" ] = 21;

	register_entity_type( "undefined", ::get_null_entity_array );
	register_entity_type( "world", ::get_world_entity_array );
	register_entity_type( "general", ::get_ent_array );
	register_entity_type( "player", ::get_player_array );
	register_entity_type( "player_corpse", ::get_player_corpse_array ); // getcorpsearray only returns player_corpse on MP
	register_entity_type( "item", ::get_item_array );
	register_entity_type( "missile", ::get_missile_array );
	register_entity_type( "invisible", ::get_invisible_array );
	register_entity_type( "scriptmover", ::get_scriptmover_array );
	register_entity_type( "sound_blend", ::get_sound_blend_array );
	register_entity_type( "fx", ::get_fx_array );
	register_entity_type( "loop_fx", ::get_loop_fx_array );
	register_entity_type( "primary_light", ::get_primary_light_array );
	register_entity_type( "turret", ::get_turret_array );
	register_entity_type( "helicopter", ::get_helicopter_array );
	register_entity_type( "plane", ::get_plane_array );
	register_entity_type( "vehicle", ::get_vehicle_array );
	register_entity_type( "vehicle_corpse", ::get_vehicle_corpse_array );
	register_entity_type( "actor", ::get_actor_array );
	register_entity_type( "actor_spawner", ::get_actor_spawner_array );
	register_entity_type( "actor_corpse", ::get_actor_corpse_array );
	register_entity_type( "streamer_hint", ::get_streamer_hint_array );
	register_entity_type( "zbarrier", ::get_zbarrier_array );
	register_entity_type( "temp_entity", ::get_temp_entity_array );

	register_custom_entity_getter( "bot", ::get_bot_array );

	register_entnum_range( "player", 0, 17, 18 );
	register_entnum_range( "player_corpse", 18, 21, 4 );
	register_entnum_range( "actor", 22, 53, 32 );
	register_entnum_range( "actor_corpse", 54, 61, 8 );
	register_entnum_range( "vehicle", 62, 77, 16 );
	register_entnum_range( "turret", 78, 109, 32 );
	register_entnum_range( "any", 110, 1021, 910 );
	register_entnum_range( "world", 1022, 1022, 1 );
	register_entnum_range( "undefined", 1023, 1023, 1 );

	arg_type_register( "int", ::arg_obj_int_generate, ::arg_obj_int_cast );
	arg_type_register( "positive_int", ::arg_obj_positive_int_generate, ::arg_obj_positive_int_cast );
	arg_type_register( "natural_int", ::arg_obj_natural_int_generate, ::arg_obj_natural_int_cast );
	arg_type_register( "boolean", ::arg_obj_boolean_generate, ::arg_obj_boolean_cast );
	arg_type_register( "float", ::arg_obj_float_generate, ::arg_obj_float_cast );
	arg_type_register( "positive_float", ::arg_obj_positive_float_generate, ::arg_obj_positive_float_cast );
	arg_type_register( "vector", ::arg_obj_vector_generate, ::arg_obj_vector_cast );
	arg_type_register( "team", ::arg_obj_team_generate, ::arg_obj_team_cast );
	arg_type_register( "cmdalias", ::arg_obj_cmdalias_generate, ::arg_obj_cmdalias_cast );
	arg_type_register( "rank", ::arg_obj_rank_generate, ::arg_obj_rank_cast );
	arg_type_register( "hitloc", ::arg_obj_hitloc_generate, ::arg_obj_hitloc_cast );
	arg_type_register( "MOD", ::arg_obj_mod_generate, ::arg_obj_mod_cast );
	arg_type_register( "idflags", ::arg_obj_idflags_generate, ::arg_obj_idflags_cast );
	arg_type_register( "string", ::arg_obj_string_generate, ::arg_obj_string_cast );
	arg_type_register( "model", ::arg_obj_model_generate, ::arg_obj_model_cast );
	arg_type_register( "spawnable_classname", ::arg_obj_spawnable_classname_generate, ::arg_obj_spawnable_classname_cast );
	arg_type_register( "weapon", ::arg_obj_weapon_generate, ::arg_obj_weapon_cast );
	arg_type_register( "...", undefined, undefined );

	register_entity_string_field( "classname", "string", true );
	register_entity_string_field( "origin", "vector" );
	register_entity_string_field( "model", "model", true );
	register_entity_string_field( "spawnflags", "spawnflags", true );
	register_entity_string_field( "target", "string" );
	register_entity_string_field( "targetname", "string" );
	register_entity_string_field( "script_noteworthy", "string" );
	register_entity_string_field( "count", "int" );
	register_entity_string_field( "health", "int" );
	register_entity_string_field( "dmg", "int" );
	register_entity_string_field( "angles", "vector" );
	register_entity_string_field( "birthtime", "int", true );
	register_entity_string_field( "index", "int" );
	register_entity_string_field( "lerp_to_lighter", "float" );
	register_entity_string_field( "lerp_to_darker", "float" );

	level._target_obj_generate = ::target_obj_generate;
}

get_entities_by_etype( etype, start, end  )
{
	start = _DEFAULT( start, 0 );
	start = _CLAMP( start, 0, 1024 );
	end = _DEFAULT( ent, 1024 );
	end = _CLAMP( end, 1, 1024 );
	ents = [];

	if ( !isdefined( etype ) || !isdefined( level._entity_types[ etype ] ) )
	{
		return ents;
	}
	for ( i = start; i < end; i++ )
	{
		ent = getentbynum( i );

		if ( !isdefined( ent ) )
		{
			continue;
		}

		if ( etype == "temp_entity" )
		{
			if ( ent getentitytype() >= level._entity_types[ "temp_entity" ] )
			{
				ents[ ents.size ] = ent;
				continue;
			}
		}
		
		if ( ent getentitytype() != level._entity_types[ etype ] )
		{
			continue;
		}

		ents[ ents.size ] = ent;
	}

	return ents;
}

get_entities_by_static_range( static_type )
{
	start = level._ent_num_ranges[ static_type ].first_entnum;
	end = level._ent_num_ranges[ static_type ].last_entnum;

	entities = [];
	for ( i = start; i <= end; i++ )
	{
		ent = getentbynum( i );
		if ( !isdefined( ent ) )
		{
			continue;
		}

		entities[ entities.size ] = ent;
	}

	return entities;
}

get_null_entity_array()
{
	return [];
}

get_world_entity_array()
{
	entities = [];
	entities[ 0 ] = getentbynum( 1022 );
	return entities;
}

get_ent_array( value = "", key = "" )
{
	if ( value != "" && key != "" )
	{
		return getentarray( value, key );
	}

	return getentarray();
}

get_player_array()
{
	return level.players;
}

get_player_corpse_array()
{
	return get_entities_by_static_range( "player_corpse" );
}

get_item_array()
{
	return getitemarray();
}

/*
	classnames:
	"rocket"
	"grenade"
*/
get_missile_array( classnames_str )
{
	classnames = strtok( classnames_str, " " );

	entities = [];
	for ( i = 0; i < _SIZE( classnames.size ); i++ )
	{
		missile_entities = getentarray( classnames[ i ], "classname" );

		entities = arraycombine( entities, missile_entities, false, false );
	}

	return entities;
}

get_invisible_array()
{
	return get_entities_by_etype( "invisible" );
}

get_sound_blend_array()
{
	return get_entities_by_etype( "sound_blend" );
}

get_fx_array()
{
	return get_entities_by_etype( "fx" );
}

get_loop_fx_array()
{
	return get_entities_by_etype( "loop_fx" );
}

get_scriptmover_array()
{
	return getscriptmoverarray();
}

get_primary_light_array()
{
	return getentarray( "light", "classname" );
}

get_turret_array()
{
	return get_entities_by_static_range( "turret" );
}
get_helicopter_array()
{
	vehicles = get_entities_by_static_range( "vehicle" );

	helicopters = [];
	for ( i = 0; i < _SIZE( vehicles.size ); i++ )
	{
		if ( vehicles[ i ] getentitytype() == level._entity_types[ "helicopter" ] )
		{
			helicopters[ helicopters.size ] = vehicles[ i ];
		}
	}
	return helicopters;
}

get_plane_array()
{
	return get_entities_by_etype( "plane" );
}

get_vehicle_array()
{
	start = level._ent_num_ranges[ "vehicle" ].first_entnum;
	end = level._ent_num_ranges[ "vehicle" ].last_entnum;
	return get_entities_by_etype( "vehicle", start, end + 1 );
}

get_vehicle_corpse_array()
{
	start = level._ent_num_ranges[ "vehicle_corpse" ].first_entnum;
	end = level._ent_num_ranges[ "vehicle_corpse" ].last_entnum;
	return get_entities_by_etype( "vehicle_corpse", start, end + 1 );
}

get_actor_array()
{
	return get_entities_by_static_range( "actor" );
}

get_actor_spawner_array()
{
	return getspawnerarray();
}

get_actor_corpse_array()
{
	return get_entities_by_static_range( "actor_corpse" );
}

get_streamer_hint_array()
{
	return get_entities_by_etype( "streamer_hint", 109 );
}

get_zbarrier_array()
{
	return getzbarrierarray();
}

get_temp_entity_array()
{
	return get_entities_by_etype( "temp_entity", 109 );
}

get_bot_array()
{
	players = get_player_array();

	bots = [];
	for ( i = 0; i < _SIZE( players.size ); i++ )
	{
		player = players[ i ];
		if ( !player istestclient() )
		{
			continue;
		}

		bots[ bots.size ]= player;
	}

	return bots;
}

private register_entity_type( type, getter_func )
{
	if ( !isdefined( level._entity_type_funcs ) )
	{
		level._entity_type_funcs = [];
	}

	level._entity_type_funcs[ type ] = spawnstruct();
	level._entity_type_funcs[ type ].getter = getter_func;
}

private register_entity_string_type( classname, required_fields, optional_fields )
{
	if ( !isdefined( level._entity_string_types ) )
	{
		level._entity_string_types = [];
	}

	level._entity_string_types[ classname ] = spawnstruct();
	level._entity_string_types[ classname ].required_fields = required_fields;
	level._entity_string_types[ classname ].optional_fields = optional_fields;
}

private register_entity_string_field( field_name, type_value, readonly )
{
	readonly = _DEFAULT( readonly, false );
	if ( !isdefined( level._entity_string_fields ) )
	{
		level._entity_string_fields = [];
	}

	level._entity_string_fields[ field_name ] = spawnstruct();
	level._entity_string_fields[ field_name ].type_value = type_value;
	level._entity_string_fields[ field_name ].readonly = readonly;
}

private register_custom_entity_getter( type, getter_func )
{
	if ( !isdefined( level._entity_custom_getter_funcs ) )
	{
		level._entity_custom_getter_funcs = [];
	}

	level._entity_custom_getter_funcs[ type ] = spawnstruct();
	level._entity_custom_getter_funcs[ type ].getter = getter_func;
}

private register_entnum_range( type, first_entnum, last_entnum, count )
{
	if ( !isdefined( level._ent_num_ranges ) )
	{
		level._ent_num_ranges = [];
	}

	if ( !isdefined( level._ent_num_ranges[ type ] ) )
	{
		level._ent_num_ranges[ type ] = spawnstruct();
		level._ent_num_ranges[ type ].first_entnum = first_entnum;
		level._ent_num_ranges[ type ].last_entnum = last_entnum;
		level._ent_num_ranges[ type ].count = count;
	}
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
private build_contents_array()
{
	level.tcs_contents = [];
	level.tcs_contents[ "NONE" ] = 0;
	level.tcs_contents[ "SOLID" ] = 1 << 0;
	level.tcs_contents[ "FOILAGE" ] = 1 << 1;
	level.tcs_contents[ "NONCOLLIDING" ] = 1 << 2; // AI_AVOID
	level.tcs_contents[ "VEHICLETRIGGER" ] = 1 << 3;
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
	level.tcs_contents[ "CORPSE_CLIPSHOT" ] = 0;
	level.tcs_contents[ "ACTOR" ] = 1 << 14;
	level.tcs_contents[ "FAKE_ACTOR" ] = 1 << 15;
	level.tcs_contents[ "PLAYERCLIP" ] = 1 << 16;
	level.tcs_contents[ "MONSTERCLIP" ] = 1 << 17;
	level.tcs_contents[ "AXISTRIGGER" ] = 1 << 18; // PLAYERVEHICLECLIP
	level.tcs_contents[ "ALLIESTRIGGER" ] = 1 << 19;
	level.tcs_contents[ "NEUTRALTRIGGER" ] = 1 << 20;
	level.tcs_contents[ "USE" ] = 1 << 21;
	level.tcs_contents[ "UTILITYCLIP" ] = 1 << 22; // NONSENTIENTTRIGGER
	level.tcs_contents[ "VEHICLE" ] = 1 << 23;
	level.tcs_contents[ "MANTLE" ] = 1 << 24;
	level.tcs_contents[ "PLAYER" ] = 1 << 25;
	level.tcs_contents[ "CORPSE" ] = 1 << 26;
	level.tcs_contents[ "DETAIL" ] = 1 << 27;
	level.tcs_contents[ "STRUCTURAL" ] = 1 << 28;
	level.tcs_contents[ "LOOKAT" ] = level.tcs_contents[ "STRUCTURAL" ];
	level.tcs_contents[ "UNK4" ] = 1 << 29; // LOOKAT?
	level.tcs_contents[ "PLAYERTRIGGER" ] = 1 << 30; // TRIGGER
	level.tcs_contents[ "NODROP" ] = 1 << 31;
}

private build_hitlocs_array()
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

private build_mods_array()
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

private build_idflags_array()
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

private build_sessionstate_array()
{
	level.tcs_sessstates = [];
	level.tcs_sessstates[ "playing" ] = 0;
	level.tcs_sessstates[ "dead" ] = 1;
	level.tcs_sessstates[ "spectator" ] = 2;
	level.tcs_sessstates[ "intermission" ] = 3;
}

private build_dynamic_spawnable_classname_array()
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

private build_dynamic_spawnable_function_array()
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

private build_bsp_spawnable_classname_array()
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

arg_obj_positive_int_cast( arg )
{
	return cast_str_to_number( arg, "positive_int" );
}

arg_obj_positive_int_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	int_val = randomint( 1000000 );
	find.str_value = int_val + "";
	return set_cast_success( find, int_val, "positive_int==" + find.str_value );
}

arg_obj_natural_int_cast( arg )
{
	return cast_str_to_number( arg, "natural_int" );
}

arg_obj_natural_int_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	int_val = randomintrange( 1, 1000000 );
	find.str_value = int_val + "";
	return set_cast_success( find, int_val, "natural_int==" + find.str_value );
}

arg_obj_boolean_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	bool_val = cointoss();
	bool_val_str = cointoss() ? cast_bool_to_str( bool_val, "true false" ) : bool_val + "";
	find.str_value = bool_val_str;
	return set_cast_success( find, bool_val, "boolean==" + find.str_value );
}

arg_obj_boolean_cast( arg )
{
	return cast_str_to_bool( arg );
}

arg_obj_int_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	int_val = cointoss() ? randomFloat( 1000000 ) : randomFloat( 1000000 ) * -1;
	find.str_value = int_val + "";
	return set_cast_success( find, int_val, "int==" + find.str_value );
}

arg_obj_int_cast( arg )
{
	return cast_str_to_number( arg, "int" );
}

arg_obj_float_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	float_val = cointoss() ? randomFloat( 1000000 ) : randomFloat( 1000000 ) * -1;
	find.str_value = float_val + "";
	return set_cast_success( find, float_val, "float==" + find.str_value );
}

arg_obj_float_cast( arg )
{
	return cast_str_to_number( arg, "float" );
}

arg_obj_positive_float_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	float_val = randomfloat( 1000000 );
	find.str_value = float_val + "";
	return set_cast_success( find, float_val, "positive_float==" + find.str_value );
}

arg_obj_positive_float_cast( arg )
{
	return cast_str_to_number( arg, "positive_float" );
}

arg_obj_vector_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	x = cointoss() ? randomfloat( 1000 ) : randomfloat( 1000 ) * -1;
	y = cointoss() ? randomfloat( 1000 ) : randomfloat( 1000 ) * -1;
	z = cointoss() ? randomfloat( 1000 ) : randomfloat( 1000 ) * -1;
	vec = ( x, y, z );

	find.str_value = x + "," + y + "," + z;
	return set_cast_success( find, vec, "vector==" + find.str_value );
}

arg_obj_vector_cast( arg )
{
	return cast_str_to_vector( arg );
}

arg_obj_string_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	max_len = randomint( 16 ) + 1;
	str = "";

	keys = getarraykeys( level._alphabet_array );
	for ( i = 0; i < max_len; i++ )
	{
		str += keys[ randomint( keys.size ) ];
	}

	find.str_value = str;
	return set_cast_success( find, str, "string==" + str );
}

arg_obj_string_cast( arg )
{
	find = generic_obj_t_new();

	return set_cast_success( find, arg, "string==" + arg );
}

arg_obj_team_cast( arg )
{
	find = generic_obj_t_new();
	if ( !isdefined( level.teams[ arg ] ) )
	{
		msg = get_possible_array_values_msg( arg, level.teams, "team" );

		return set_cast_error( find, msg );
	}

	return set_cast_success( find, arg, "team==" + arg );
}

arg_obj_team_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	team = random_val( level.teams );
	find.str_value = team;
	return set_cast_success( find, team, "team==" + team );
}

arg_obj_cmdalias_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	cmd = random_val( level.tcs_cmds );
	find.str_value = cmd.cmd_name;
	return set_cast_success( find, cmd, "cmd==" + cmd.cmd_name );
}

arg_obj_cmdalias_cast( arg )
{
	cmd_find_result = cast_str_to_cmd( arg );
	return cmd_find_result;	
}

arg_obj_rank_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	rank = random_key( level.tcs_perms.ranks );
	find.str_value = rank;
	return set_cast_success( find, rank, "rank==" + rank );
}

arg_obj_rank_cast( arg )
{
	find = generic_obj_t_new();
	if ( !isdefined( level.tcs_perms.ranks[ arg ] ) )
	{
		msg = get_possible_array_values_msg( arg, level.tcs_perms.ranks, "rank" );
		return set_cast_error( find, msg );
	}

	return set_cast_success( find, arg, "rank==" + arg );
}

arg_obj_hitloc_cast( arg )
{
	find = generic_obj_t_new();
	if ( !isdefined( level.tcs_hitlocs[ arg ] ) )
	{
		msg = get_possible_array_values_msg( arg, level.tcs_hitlocs, "hitloc" );
		return set_cast_error( find, msg );
	}

	return set_cast_success( find, arg, "hitloc==" + arg );
}

arg_obj_hitloc_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	hitloc = random_key( level.tcs_hitlocs );
	find.str_value = hitloc;
	return set_cast_success( find, hitloc, "hitloc==" + hitloc );
}

arg_obj_mod_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	mod = random_key( level.tcs_mods );
	find.str_value = mod;
	return set_cast_success( find, mod, "mod==" + mod );
}

arg_obj_mod_cast( arg )
{
	find = generic_obj_t_new();
	toupper_arg = toupper( arg );
	if ( isdefined( level.tcs_mods[ toupper_arg ] ) )
	{
		return set_cast_success( find, toupper_arg, "MOD==" + toupper_arg );
	}

	msg = get_possible_array_values_msg( toupper_arg, level.tcs_mods, "mod" );

	return set_cast_error( find, msg );
}

arg_obj_idflags_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();
	flags = 0;
	idflags_array = getarraykeys( level.tcs_idflags );
	max_flags_to_add = randomint( idflags_array.size );

	find.str_value = "";
	for ( i = 0; i < _SIZE( max_flags_to_add ); i++ )
	{
		random_flag_index = randomint( idflags_array.size );
		flags |= level.tcs_idflags[ idflags_array[ random_flag_index ] ];
		find.str_value += idflags_array[ random_flag_index ];

		if ( ( i + 1 ) < max_flags_to_add )
		{
			find.str_value += "|";
		}
		arrayremoveindex( idflags_array, random_flag_index );
	}

	return set_cast_success( find, flags, "idflags==" + find.str_value );
}

// type is FLAG, so delimited by |
arg_obj_idflags_cast( arg )
{
	find = generic_obj_t_new();

	flag_strs = strtok( arg, "|" );

	flags = 0;

	if ( flag_strs[ 0 ] == "all" )
	{
		flags = -1;
		return set_cast_success( find, flags, "flags==all" );
	}

	for ( i = 0; i < _SIZE( flag_strs.size ); i++ )
	{
		if ( !isdefined( level.tcs_idflags[ flag_strs[ i ] ] ) )
		{
			msg = get_possible_array_values_msg( flag_strs[ i ], level.tcs_idflags, "flag", false );
			msg += "FLAG: 'all'\n";

			return set_cast_error( find, msg );
		}

		flags |= level.tcs_idflags[ flag_strs[ i ] ];
	}

	return set_cast_success( find, flags, "flags==" + arg );
}

arg_obj_model_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();
	find.rand_gen_unimplemented = true;
	return set_cast_success( find, "Unimplemented", "model==" + "null" );
}

private delete_after_time( entity )
{
	entity endon( "death" );

	wait 0.05;

	entity delete();
}

private spawn_test_ent()
{
	test_ent = spawn( "script_model", ( 0, 0, -5000 ) );
	level thread delete_after_time( test_ent );

	return test_ent;
}

arg_obj_model_cast( arg )
{
	find = generic_obj_t_new();

	test_ent = spawn_test_ent();
	test_ent setmodel( arg );

	if ( test_ent.model == "" )
	{
		test_ent delete();
		return set_cast_error( find, "Model not precached: '" + arg + "'" );
	}

	test_ent delete();

	return set_cast_success( find, arg, "model==" + arg );
}

arg_obj_spawnable_classname_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	classname = random_key( level.tcs_dynamic_spawns );
	find.str_value = classname;
	return set_cast_success( find, classname, "classname==" + classname );
}

arg_obj_spawnable_classname_cast( arg )
{
	find = generic_obj_t_new();

	if ( !isdefined( level.tcs_dynamic_spawns[ arg ] ) )
	{
		if ( isdefined( level.tcs_bsp_spawns[ arg ] ) )
		{
			return set_cast_error( find, "Classname: '" + arg + "' cannot be spawned dynamically; only through mapents" );
		}
		return set_cast_error( find, "Unsupported classname: '" + arg + "'" );
	}

	return set_cast_success( find, arg, "classname==" + arg );
}

arg_obj_weapon_generate( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();
	find.rand_gen_unimplemented = true;
	return set_cast_success( find, "Unimplemented", "model==" + "null" );
}

arg_obj_weapon_cast( arg )
{
	find = generic_obj_t_new();

	exists = _WEAPON_EXISTS( arg );

	if ( !exists )
	{
		return set_cast_error( find, "Weapon: '" + arg + "' not precached" );
	}

	return set_cast_success( find, arg, "weapon==" + arg );
}

clamp_array( arr, limit )
{
	if ( limit >= arr.size )
	{
		return arr;
	}

	new_arr = [];
	i = 0;
	foreach ( key, val in arr )
	{
		if ( i >= limit )
		{
			break;
		}

		new_arr[ key ] = val;
		i++;
	}

	return new_arr;
}

target_obj_generate( target_type, overload )
{
	is_required = target_type.is_required;
	max_targets = _DEFAULT( overload.max_targets, 1024 );
	etype = overload.etype;
	find = generic_obj_t_new( "target_gen" );

	target_str = "";
	rand = randomint( 10 );
	if ( rand < 2 )
	{
		// prevent script error in situation where argument is required
		if ( is_required )
		{
			rand = randomintrange( 2, 3 );
		}
		else
		{
			rand = randomintrange( 0, 3 );
		}

		switch ( rand )
		{
			case 0:
				target_str += "!"; // undefined
				break;
			case 1:
				target_str += "#"; // default
				break;
			case 2:
				// prevent script error during unittesting if the rand generator picks all entities when only 1 is allowed max
				if ( max_targets > 1 )
				{
					target_str += "*"; // all
				}
				break;
			case 3:
				target_str += "&"; // self
				break;
		}

		if ( target_str != "" )
		{
			return target_str;
		}
	}

	ents = self [[ level._entity_type_funcs[ etype ].getter ]]();
	if ( ents.size == 0 )
	{
		return "";
	}

	max_targets = _CLAMP( max_targets, 1, ents.size );

	ents = array_randomize( ents );
	ents = clamp_array( ents, max_targets );
	if ( ents.size == 0 )
	{
		return "";
	}

	// no point in continuing if we only have one entity to work with
	if ( ents.size == 1 )
	{
		return target_str + ents[ 0 ] getentitynumber();
	}

	rand = randomint( 3 );

	// it doesn't exactly make sense to generate rand_limits of 1
	if ( ents.size <= 2 )
	{
		rand = 2;
	}

	switch ( rand )
	{
		case 0: // random
			target_str += "$";
			rand_limit = randomintrange( 2, ( ents.size + 1 ) );
			target_str += rand_limit;
			break;
		case 1: // array
			if ( cointoss() )
			{
				target_str += "$";
			}
			target_str += "[";
			rand_limit = randomintrange( 2, ( ents.size + 1 ) );

			for ( i = 0; i < _SIZE( rand_limit ); i++ )
			{
				if ( ( etype == "player" || etype == "bot" ) && cointoss() )
				{
					if ( cointoss() )
					{
						target_str += ents[ i ].name;
					}
					else if ( cointoss() )
					{
						target_str += "&";
					}
					else
					{
						target_str += ents[ i ].guid;
					}
				}
				else
				{
					target_str += ents[ i ] getentitynumber();
				}

				if ( ( i + 1 ) < rand_limit )
				{
					target_str += ",";
				}
			}

			target_str += "]";
			break;
		case 2: // name
			rand = randomint( 100 );
			if ( rand == 0 )
			{
				if ( cointoss() )
				{
					target_str += "1022";
				}
				else
				{
					target_str += "1023";
				}
			}
			else
			{
				target_str += ents[ 0 ] getentitynumber();
			}
			break;
	}

	return target_str;
}