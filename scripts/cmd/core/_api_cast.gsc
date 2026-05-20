#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

init_consts()
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

	level._trigger_types = [];
	level._trigger_types[ "radius" ] = 0;
	level._trigger_types[ "box" ] = 1;
	level._trigger_types[ "box_use" ] = 2;
	level._trigger_types[ "radius_use" ] = 3;
	level._trigger_types[ "damage" ] = 4;

	level._node_types = [];
	level._node_types[ "BAD_NODE" ] = 0;
	level._node_types[ "Path" ] = 1;
	level._node_types[ "Cover_Stand" ] = 2;
	level._node_types[ "Cover_Crouch" ] = 3;
	level._node_types[ "Cover_Crouch_Window" ] = 4;
	level._node_types[ "Cover_Prone" ] = 5;
	level._node_types[ "Cover_Right" ] = 6;
	level._node_types[ "Cover_Left" ] = 7;
	level._node_types[ "Cover_Pillar" ] = 8;
	level._node_types[ "Ambush" ] = 9;
	level._node_types[ "Exposed" ] = 10;
	level._node_types[ "Conceal_Stand" ] = 11;
	level._node_types[ "Conceal_Crouch" ] = 12;
	level._node_types[ "Conceal_Prone" ] = 13;
	level._node_types[ "Reacquire" ] = 14;
	level._node_types[ "Balcony" ] = 15;
	level._node_types[ "Scripted" ] = 16;
	level._node_types[ "Begin" ] = 17;
	level._node_types[ "End" ] = 18;
	level._node_types[ "Turret" ] = 19;
	level._node_types[ "Guard" ] = 20;

	level._camera_flags = [];
	level._camera_flags[ "CLEAR" ] = 0;
	level._camera_flags[ "CUSTOM" ] = 2;
	level._camera_flags[ "ENTITY" ] = 4;
	level._camera_flags[ "LOOKAT" ] = 8;
	level._camera_flags[ "LOOKAT_ENTITY" ] = 16;
	level._camera_flags[ "REMOVE_LOOKAT" ] = 32;

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

	arg_type_register( "int", ::generate_int, ::cast_str_to_int_internal );
	arg_type_register( "positive_int", ::generate_positive_int, ::cast_str_to_positive_int_internal );
	arg_type_register( "natural_int", ::generate_natural_int, ::cast_str_to_natural_int_internal );
	arg_type_register( "boolean", ::generate_boolean, ::cast_str_to_boolean_internal );
	arg_type_register( "float", ::generate_float, ::cast_str_to_float_internal );
	arg_type_register( "positive_float", ::generate_positive_float, ::cast_str_to_positive_float_internal );
	arg_type_register( "vector", ::generate_vector, ::cast_str_to_vector_internal );
	arg_type_register( "team", ::generate_team, ::cast_str_to_team_internal );
	arg_type_register( "cmdalias", ::generate_cmdalias, ::cast_str_to_cmdalias_internal );
	arg_type_register( "rank", ::generate_rank, ::cast_str_to_rank_internal );
	arg_type_register( "hitloc", ::generate_hitloc, ::cast_str_to_hitloc_internal );
	arg_type_register( "MOD", ::generate_mod, ::cast_str_to_mod_internal );
	arg_type_register( "idflags", ::generate_idflags, ::cast_str_to_idflags_internal );
	arg_type_register( "string", ::generate_string, ::cast_str_to_string_internal );
	arg_type_register( "model", ::generate_model, ::cast_str_to_model_internal );
	arg_type_register( "spawnable_classname", ::generate_spawnable_classname, ::cast_str_to_spawnable_classname_internal );
	arg_type_register( "weapon", ::generate_weapon, ::cast_str_to_weapon_internal );
	arg_type_register( "enttype", ::generate_enttype, ::cast_str_to_enttype_internal );
	arg_type_register( "nodetype", ::generate_nodetype, ::cast_str_to_nodetype_internal );
	arg_type_register( "triggertype", ::generate_triggertype, ::cast_str_to_triggertype_internal );
	arg_type_register( "entfield", ::generate_entfield, ::cast_str_to_entfield_internal );
	arg_type_register( "fx", ::generate_fx, ::cast_str_to_fx_internal );
	arg_type_register( "cameraflags", ::generate_cameraflags, ::cast_str_to_cameraflags_internal );
	arg_type_register( "cmdmodule", ::generate_cmdmodule, ::cast_str_to_cmdmodule_internal );
	arg_type_register( "...", undefined, undefined );

	register_entity_string_field( "classname", "string", true );
	register_entity_string_field( "origin", "vector" );
	register_entity_string_field( "model", "model" );
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

cast_str_to_type_internal( str, type )
{
	if ( isdefined( level.tcs_arg_type_handlers[ type ] ) && isdefined( level.tcs_arg_type_handlers[ type ].cast_func ) )
	{
		return [[ level.tcs_arg_type_handlers[ type ].cast_func ]]( str );
	}

	find = generic_obj_t_new();
	_ASSERT_MSG_ONLY( "cast_str_to_type_internal: Unexpected type '{}' while casting string '{}'", type, str );

	return set_cast_error( find );
}

cast_contents_to_str_internal( contents_int )
{
	result_obj = generic_obj_t_new( "contents" );

	contents_str = "";
	keys = getarraykeys( level.tcs_contents );
	for ( i = 0; i < _SIZE( keys.size ); i++ )
	{
		if ( ( contents_int & level.tcs_contents[ keys[ i ] ] ) != 0 )
		{
			if ( contents_str != "" )
			{
				contents_str += "|";
			}

			contents_str += keys[ i ];
		}
	}

	return set_cast_success( result_obj, contents_str, "contents==" + contents_str );
}

cast_str_to_primitive_type_internal( str, type )
{
	result_obj = generic_obj_t_new( "cmdobj" );

	switch ( type )
	{
		case "boolean":
			return cast_str_to_boolean_internal( str );
		case "vector":
			return cast_str_to_vector_internal( str );
		case "int":
		case "positive_int":
		case "natural_int":
		case "float":
		case "positive_float":
			return cast_str_to_number_internal( str, type );
	}

	_ASSERT_MSG_ONLY( "cast_str_to_primitive_type: Unexpected type '{}' while casting string '{}'", type, str );
	return set_cast_error( result_obj, "Unknown type: '{}' while casting string '{}'", type, str );
}

cast_boolean_to_str_internal( bool, binary_string_options )
{
	options = strTok( binary_string_options, " " );
	if ( options.size == 2 )
	{
		if ( bool )
		{
			return options[ 0 ];
		}
		else 
		{
			return options[ 1 ];
		}
	}
	return bool + "";
}

private get_entities_by_etype( etype, start, end  )
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

private get_entities_by_static_range( static_type )
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

private get_null_entity_array()
{
	return [];
}

private get_world_entity_array()
{
	entities = [];
	entities[ 0 ] = getentbynum( 1022 );
	return entities;
}

private get_ent_array( value = "", key = "" )
{
	if ( value != "" && key != "" )
	{
		return getentarray( value, key );
	}

	return getentarray();
}

private get_player_array()
{
	return level.players;
}

private get_player_corpse_array()
{
	return get_entities_by_static_range( "player_corpse" );
}

private get_item_array()
{
	return getitemarray();
}

/*
	classnames:
	"rocket"
	"grenade"
*/
private get_missile_array( classnames_str )
{
	classnames = [];
	classnames[ 0 ] = "rocket";
	classnames[ 1 ] = "grenade";

	entities = [];
	for ( i = 0; i < _SIZE( classnames.size ); i++ )
	{
		missile_entities = getentarray( classnames[ i ], "classname" );

		entities = arraycombine( entities, missile_entities, false, false );
	}

	return entities;
}

private get_invisible_array()
{
	return get_entities_by_etype( "invisible" );
}

private get_sound_blend_array()
{
	return get_entities_by_etype( "sound_blend" );
}

private get_fx_array()
{
	return get_entities_by_etype( "fx" );
}

private get_loop_fx_array()
{
	return get_entities_by_etype( "loop_fx" );
}

private get_scriptmover_array()
{
	return getscriptmoverarray();
}

private get_primary_light_array()
{
	return getentarray( "light", "classname" );
}

private get_turret_array()
{
	return get_entities_by_static_range( "turret" );
}

private get_helicopter_array()
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

private get_plane_array()
{
	return get_entities_by_etype( "plane" );
}

private get_vehicle_array()
{
	start = level._ent_num_ranges[ "vehicle" ].first_entnum;
	end = level._ent_num_ranges[ "vehicle" ].last_entnum;
	return get_entities_by_etype( "vehicle", start, end + 1 );
}

private get_vehicle_corpse_array()
{
	return get_entities_by_etype( "vehicle_corpse", level._ent_num_ranges[ "any" ].first_entnum );
}

private get_actor_array()
{
	return get_entities_by_static_range( "actor" );
}

private get_actor_spawner_array()
{
	return getspawnerarray();
}

private get_actor_corpse_array()
{
	return get_entities_by_static_range( "actor_corpse" );
}

private get_streamer_hint_array()
{
	return get_entities_by_etype( "streamer_hint", level._ent_num_ranges[ "any" ].first_entnum );
}

private get_zbarrier_array()
{
	return getzbarrierarray();
}

private get_temp_entity_array()
{
	return getentarray( "tempEntity", "classname" );
}

private get_bot_array()
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

		bots[ bots.size ] = player;
	}

	return bots;
}

private register_entity_type( type, getter_func, typenum )
{
	if ( !isdefined( level._entity_type_funcs ) )
	{
		level._entity_type_funcs = [];
		level._entity_typenums = [];
	}

	level._entity_type_funcs[ type ] = spawnstruct();
	level._entity_type_funcs[ type ].getter = getter_func;
	level._entity_typenums[ level._entity_types[ type ] + "" ] = type;
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

private generate_positive_int( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	int_val = randomint( 1000000 );
	find.str_value = int_val + "";
	return set_cast_success( find, int_val, "positive_int=='{}'", find.str_value );
}

private generate_natural_int( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	int_val = randomintrange( 1, 1000000 );
	find.str_value = int_val + "";
	return set_cast_success( find, int_val, "natural_int=='{}'", find.str_value );
}

private generate_boolean( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	bool_val = cointoss();
	bool_val_str = cointoss() ? cast_boolean_to_str( bool_val, "true false" ) : bool_val + "";
	find.str_value = bool_val_str;
	return set_cast_success( find, bool_val, "boolean=='{}'", find.str_value );
}

private generate_int( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	int_val = cointoss() ? randomFloat( 1000000 ) : randomFloat( 1000000 ) * -1;
	find.str_value = int_val + "";
	return set_cast_success( find, int_val, "int=='{}'", find.str_value );
}

private generate_float( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	float_val = cointoss() ? randomFloat( 1000000 ) : randomFloat( 1000000 ) * -1;
	find.str_value = float_val + "";
	return set_cast_success( find, float_val, "float=='{}'", find.str_value );
}

private generate_positive_float( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	float_val = randomfloat( 1000000 );
	find.str_value = float_val + "";
	return set_cast_success( find, float_val, "positive_float=='{}'", find.str_value );
}

private generate_vector( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	x = cointoss() ? randomfloat( 1000 ) : randomfloat( 1000 ) * -1;
	y = cointoss() ? randomfloat( 1000 ) : randomfloat( 1000 ) * -1;
	z = cointoss() ? randomfloat( 1000 ) : randomfloat( 1000 ) * -1;
	vec = ( x, y, z );

	find.str_value = x + "," + y + "," + z;
	return set_cast_success( find, vec, "vector=='{}'", find.str_value );
}

private generate_string( arg1, arg2, arg3 )
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
	return set_cast_success( find, str, "string=='{}'", str );
}

private generate_team( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	team = random_val( level.teams );
	find.str_value = team;
	return set_cast_success( find, team, "team=='{}'", team );
}

private generate_cmdalias( module, index, arg3 )
{
	module = _DEFAULT( module, undefined );
	index = _DEFAULT( index, undefined );

	find = generic_obj_t_new();

	if ( isdefined( module ) )
	{
		module_cmds = level._cmd_modules[ module ];

		if ( isdefined( index ) )
		{
			cmd = level._cmd_modules[ module ][ index ];
		}
		else
		{
			cmd = random_val( level._cmd_modules[ module ] );
		}
	}
	else
	{
		cmd = random_val( level.tcs_cmds );
	}
	
	find.str_value = cmd.cmd_name;
	if ( !isdefined( find.str_value ) )
	{
		return set_cast_error( find, "Unreachable" );	
	}

	return set_cast_success( find, cmd, "cmd=='{},", cmd.cmd_name );
}

private generate_rank( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	rank = random_key( level.tcs_perms.ranks );
	find.str_value = rank;
	return set_cast_success( find, rank, "rank=='{}'", rank );
}

private generate_hitloc( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	hitloc = random_key( level.tcs_hitlocs );
	find.str_value = hitloc;
	return set_cast_success( find, hitloc, "hitloc=='{}'", hitloc );
}

private generate_mod( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	mod = random_key( level.tcs_mods );
	find.str_value = mod;
	return set_cast_success( find, mod, "mod=='{}'", mod );
}

private generate_idflags( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();
	flags = 0;
	idflags_array = getarraykeys( level.tcs_idflags );
	max_flags_to_add = randomint( idflags_array.size );

	find.str_value = flags + "";
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

	return set_cast_success( find, flags, "idflags=='{}'", find.str_value );
}

private generate_model( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();
	find.rand_gen_unimplemented = true;
	return set_cast_success( find, undefined, "Unimplemented: model=='{}'", "null" );
}

private generate_spawnable_classname( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	classname = random_key( level.tcs_dynamic_spawns );
	find.str_value = classname;
	return set_cast_success( find, classname, "classname=='{}'", classname );
}

private generate_weapon( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();
	find.rand_gen_unimplemented = true;
	return set_cast_success( find, "Unimplemented: model=='{}'", "null" );
}

private generate_enttype( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	ent_type = random_key( level._entity_type_funcs );
	find.str_value = ent_type;
	return set_cast_success( find, ent_type, "ent_type=='{}'", ent_type );
}

private generate_nodetype( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	node_type = random_key( level._node_types );
	find.str_value = node_type;
	return set_cast_success( find, node_type, "node_type=='{}'", node_type );
}

private generate_triggertype( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	trigger_type = random_key( level._trigger_types );
	find.str_value = trigger_type;
	return set_cast_success( find, trigger_type, "trigger_type=='{}'", trigger_type );
}

private generate_entfield( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	entfield = random_key( level._entity_string_fields );
	find.str_value = entfield;
	return set_cast_success( find, entfield, "entfield=='{}'", entfield );
}

private generate_fx( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	available_fx = _get_real_fx();

	rand_fx = random_key( available_fx );

	return set_cast_success( find, rand_fx, "fx=='{}'", rand_fx );
}

private generate_cameraflags( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();

	available_fx = _get_real_fx();

	rand_fx = random_key( available_fx );

	return set_cast_success( find, rand_fx, "cameraflags=='{}'", rand_fx );
}

private generate_cmdmodule( arg1, arg2, arg3 )
{
	find = generic_obj_t_new();
	find.rand_gen_unimplemented = true;
	return set_cast_success( find, "Unimplemented: cmdmodule=='{}'", "null" );
}

private target_obj_generate( target_type, overload )
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

				if ( i >= 32 )
				{
					break;
				}

				if ( ( i + 1 ) < rand_limit )
				{
					target_str += ",";
				}
			}

			target_str += "]";
			break;
		case 2: // name
			if ( ( etype == "player" || etype == "bot" ) && cointoss() )
			{
				if ( cointoss() )
				{
					target_str += "&";
				}
				else if ( cointoss() )
				{
					target_str += ents[ 0 ].guid;
				}
				else
				{
					target_str += ents[ 0 ] getentitynumber();
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

private cast_str_to_int_internal( str )
{
	return cast_str_to_number_internal( str, "int" );
}

private cast_str_to_natural_int_internal( str )
{
	return cast_str_to_number_internal( str, "natural_int" );
}

private cast_str_to_positive_int_internal( str )
{
	return cast_str_to_number_internal( str, "positive_int" );
}

private cast_str_to_float_internal( str )
{
	return cast_str_to_number_internal( str, "float" );
}

private cast_str_to_positive_float_internal( str )
{
	return cast_str_to_number_internal( str, "positive_float" );
}

private cast_str_to_contents_internal( contents_str )
{
	result_obj = generic_obj_t_new( "contents" );

	contents_int = level.tcs_contents[ "NONE" ];
	keys = strtok( contents_str, "|" );
	for ( i = 0; i < _SIZE( keys.size ); i++ )
	{
		if ( isdefined( level.tcs_contents[ keys[ i ] ] ) )
		{
			contents_int |= level.tcs_contents[ keys[ i ] ];
		}
	}

	return set_cast_success( result_obj, contents_int, "contents==" + contents_int );
}

private cast_classname_to_ent_array_internal( result_obj, key_value )
{
	result_obj.type = "entarray";
	result_obj.value = getentarray( key_value, "classname" );
	result_obj.msg = "entarray==classname";
}

private cast_script_noteworthy_to_ent_array_internal( result_obj, key_value )
{
	result_obj.type = "entarray";
	result_obj.value = getentarray( key_value, "script_noteworthy" );
	result_obj.msg = "entarray==script_noteworthy";
}

private cast_targetname_to_ent_array_internal( result_obj, key_value )
{
	result_obj.type = "entarray";
	result_obj.value = getentarray( key_value, "targetname" );
	result_obj.msg = "entarray==targetname";
}

private cast_origin_to_ent_array_internal( result_obj, origin, maxdist, max )
{
	result_obj.type = "entarray";
	ents = getentarray();
	result_obj.value = get_array_of_closest( origin, ents, undefined, max, maxdist );
	result_obj.msg = "entarray==origin";
}

/*entity_obj_t*/ cast_str_to_entity_internal( str, etype )
{
	allow_null_ent = _DEFAULT( allow_null_ent, false );
	allow_world_ent = _DEFAULT( allow_world_ent, false );
	finder_func = _DEFAULT( finder_func, undefined );
	finder_arg1 = _DEFAULT( finder_arg1, undefined );
	finder_arg2 = _DEFAULT( finder_arg2, undefined );

	entity_obj = generic_obj_t_new( "entity" );
	entity_obj.etype = etype;
	if ( !isDefined( str ) || str == "" )
	{
		return set_cast_error( entity_obj, "Missing value to find entity" );
	}

	if ( !isdefined( etype ) || !isdefined( level._entity_type_funcs[ etype ] ) && !isdefined( level._entity_custom_getter_funcs[ etype ] ) )
	{
		return set_cast_error( entity_obj, "Unsupported etype" );
	}

	entities = [];
	if ( isdefined( level._entity_type_funcs[ etype ] ) )
	{
		entities = self [[ level._entity_type_funcs[ etype ].getter ]]();
	}
	else if ( isdefined( level._entity_custom_getter_funcs[ etype ] ) )
	{
		entities = self [[ level._entity_custom_getter_funcs[ etype ].getter ]]();
	}

	if ( entities.size <= 0 )
	{
		return set_cast_error( entity_obj, "No entities found for etype: '{}'", etype );
	}

	cast_number_obj = cast_str_to_number( str, "positive_int" );

	if ( !cast_number_obj.errored )
	{
		entnum = cast_number_obj.value;
		if ( entnum > 1023 )
		{
			return set_cast_error( entity_obj, "Entity number cannot be greater than 1023" );
		}

		if ( entnum == 1023 )
		{
			if ( allow_null_ent )
			{
				return set_cast_success( entity_obj, undefined, "ent==allow_null_ent" );
			}
			else
			{
				return set_cast_error( entity_obj, "ent!=allow_null_ent" );
			}
		}
		else if ( entnum == 1022 )
		{
			if ( allow_world_ent )
			{
				return set_cast_success( entity_obj, getentbynum( 1022 ), "ent==allow_world_ent" );
			}
			else
			{
				return set_cast_error( entity_obj, "ent!=allow_world_ent" );
			}
		}

		// check guid and name first if player
		if ( etype == "player" )
		{
			for ( i = 0; i < _SIZE( entities.size ); i++ )
			{
				ent = entities[ i ];
				if ( !ent istestclient() && ent getGUID() == entnum )
				{
					return set_cast_success( entity_obj, ent, "ent==GUID" );
				}

				target_playername = tolower( ent.name );
				if ( issubstr( target_playername, str ) )
				{
					return set_cast_success( entity_obj, ent, "player==name" );
				}
			}
		}

		for ( i = 0; i < _SIZE( entities.size ); i++ )
		{
			ent = entities[ i ];
			ent_exists_for_entnum = isdefined( getentbynum( entnum ) );

			if ( ent_exists_for_entnum )
			{
				return set_cast_success( entity_obj, ent, "ent==entnum" );
			}
		}

		return set_cast_error( entity_obj, "Could not cast numeric value: '{}' to etype: '{}'", entnum, etype );
	}

	for ( i = 0; i < _SIZE( entities.size ); i++ )
	{
		ent = entities[ i ];

		if ( !isdefined( ent ) )
		{
			continue;
		}

		if ( isdefined( finder_func ) && ent [[ finder_func ]]( str, etype, finder_arg1, finder_arg2 ) )
		{
			return set_cast_success( entity_obj, ent, "ent==finder_func" );
		}

		if ( etype == "player" )
		{
			target_playername = tolower( ent.name );
			if ( issubstr( target_playername, str ) )
			{
				return set_cast_success( entity_obj, ent, "player==name" );
			}
		}
	}

	return set_cast_error( entity_obj, "Couldn't find entity of etype: '{}' from input: '{}'", etype, str );
}

private /*str_cast_obj_t*/ str_cast_obj_t_new( type, str_value )
{
	str_cast_obj = generic_obj_t_new( "str_cast" );
	str_cast_obj.number_type = type;
	str_cast_obj.str_value = str_value;

	if ( !isdefined( type ) || !isdefined( level._number_strings[ type ] ) )
	{
		_ASSERT_MSG( false );
		return set_cast_error( str_cast_obj, "Unknown type: '{}'", type );
	}
	if ( !isdefined( str_value ) || str_value == "" )
	{
		_ASSERT_MSG( false );
		return set_cast_error( str_cast_obj, "Unknown str_value" );
	}
	return str_cast_obj;
}

private cast_str_to_number_internal( str, type )
{
	str_cast_obj = str_cast_obj_t_new( type, str );

	if ( str_cast_obj.errored )
	{
		return str_cast_obj;
	}

	if ( str[ 0 ] == "-" )
	{
		if ( type != "float" && type != "int" )
		{
			return set_cast_error( str_cast_obj, "Unexpected negative sign" );
		}
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}

	syntax = level._number_strings[ type ];

	period_allowed = false;
	if ( type == "float" || type == "positive_float" )
	{
		period_allowed = true;
	}
	
	periods_found = 0;
	if ( str[ str.size - 1 ] == "." )
	{
		return set_cast_error( str_cast_obj, "Trailing decimal point is not allowed" );
	}
	for ( i = start_index; i < _SIZE( str.size ); i++ )
	{
		if ( period_allowed && str[ i ] == "." )
		{
			periods_found++;
			if ( periods_found > 1 )
			{
				return set_cast_error( str_cast_obj, "Cannot have more than one decimal point" );
			}
			continue;
		}
		if ( str[ i ] == "-" )
		{
			return set_cast_error( str_cast_obj, "Succeeding or multiple negative signs are not allowed" );
		}
		if ( !is_numeric( str[ i ] ) )
		{
			return set_cast_error( str_cast_obj, "Invalid character for type '{}': '{}'", type, str[ i ] );
		}
	}

	value = 0;
	switch ( type )
	{
		case "natural_int":
		case "positive_int":
		case "int":
			value = int( str );
			break;
		case "positive_float":
		case "float":
			value = float( str );
			break;
	}

	return set_cast_success( str_cast_obj, value, "'{}'=='{}'", type, str );
}

private cast_str_to_vector_internal( str )
{
	result_obj = generic_obj_t_new( "vector" );
	float_strs = strTok( str, "," );
	if ( float_strs.size != 3 )
	{
		return set_cast_error( result_obj, "expected vector in format of x,x,x" );
	}

	casted_floats = [];
	for ( i = 0; i < _SIZE( float_strs.size ); i++ )
	{
		casted_floats[ i ] = cast_str_to_number( float_strs[ i ], "float" );
		if ( casted_floats[ i ].errored )
		{
			return set_cast_error( result_obj, "Error at vector component '{}': '{}'", i, casted_floats[ i ].msg );
		}
	}

	new_vector = ( casted_floats[ 0 ].value, casted_floats[ 1 ].value, casted_floats[ 2 ].value );
	return set_cast_success( result_obj, new_vector, "vector=='{}'", new_vector );
}

private cast_str_to_boolean_internal( str )
{
	lower_str = tolower( str );
	result_obj = generic_obj_t_new( "boolean" );
	if ( lower_str == "true" || lower_str == "1" )
	{
		return set_cast_success( result_obj, true, lower_str == "true" ? "boolean==true" : "boolean==1" );
	}
	else if ( lower_str == "false" || lower_str == "0" )
	{
		return set_cast_success( result_obj, false, lower_str == "false" ? "boolean==false" : "boolean==0" );
	}

	return set_cast_error( result_obj, "boolean!=boolean" );
}

private cast_str_to_cmdalias_internal( str )
{
	result_obj = generic_obj_t_new( "cmdobj" );
	if ( str == "" )
	{
		return set_cast_error( result_obj, "No alias provided" );
	}

	if ( !isdefined( level.tcs_cmds[ str ] ) )
	{
		return set_cast_error( result_obj, "Unknown cmd: '{}'", str );
	}

	return set_cast_success( result_obj, level.tcs_cmds[ str ], "cmd=='{}'", str );
}

private cast_str_to_team_internal( str )
{
	find = generic_obj_t_new();
	if ( !isdefined( level.teams[ str ] ) )
	{
		msg = get_possible_array_values_msg( str, level.teams, "team" );

		return set_cast_error( find, msg );
	}

	return set_cast_success( find, str, "team=='{}'", str );
}

private cast_str_to_rank_internal( str )
{
	find = generic_obj_t_new();
	if ( !isdefined( level.tcs_perms.ranks[ str ] ) )
	{
		msg = get_possible_array_values_msg( str, level.tcs_perms.ranks, "rank" );
		return set_cast_error( find, msg );
	}

	return set_cast_success( find, str, "rank=='{}'", str );
}

private cast_str_to_hitloc_internal( str )
{
	find = generic_obj_t_new();
	if ( !isdefined( level.tcs_hitlocs[ str ] ) )
	{
		msg = get_possible_array_values_msg( str, level.tcs_hitlocs, "hitloc" );
		return set_cast_error( find, msg );
	}

	return set_cast_success( find, str, "hitloc=='{}'", str );
}

private cast_str_to_mod_internal( str )
{
	find = generic_obj_t_new();
	toupper_str = toupper( str );
	if ( isdefined( level.tcs_mods[ toupper_str ] ) )
	{
		return set_cast_success( find, toupper_str, "MOD=='{}'", toupper_str );
	}

	msg = get_possible_array_values_msg( toupper_str, level.tcs_mods, "mod" );

	return set_cast_error( find, msg );
}

// type is FLAG, so delimited by |
private cast_str_to_idflags_internal( str )
{
	find = generic_obj_t_new();

	flag_strs = strtok( str, "|" );

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

	return set_cast_success( find, flags, "flags=='{}'", str );
}

private cast_str_to_string_internal( str )
{
	find = generic_obj_t_new();

	return set_cast_success( find, str, "string=='{}'", str );
}

private cast_str_to_model_internal( str )
{
	find = generic_obj_t_new();

	model_exists = _MODEL_EXISTS( str );
	if ( !model_exists )
	{
		return set_cast_error( find, "Model not precached: '{}'", str );
	}

	return set_cast_success( find, str, "model=='{}'", str );
}

private cast_str_to_spawnable_classname_internal( str )
{
	find = generic_obj_t_new();

	if ( !isdefined( level.tcs_dynamic_spawns[ str ] ) )
	{
		if ( isdefined( level.tcs_bsp_spawns[ str ] ) )
		{
			return set_cast_error( find, "Classname: '{}' cannot be spawned dynamically; only through mapents", str );
		}

		return set_cast_error( find, "Unsupported classname: '{}'", str );
	}

	return set_cast_success( find, str, "classname=='{}'", str );
}

private cast_str_to_weapon_internal( str )
{
	find = generic_obj_t_new();

	exists = _WEAPON_EXISTS( str );

	if ( !exists )
	{
		return set_cast_error( find, "Weapon: '{}' not precached", str );
	}

	return set_cast_success( find, str, "weapon=='{}'", str );
}

private cast_str_to_enttype_internal( str )
{
	find = generic_obj_t_new();

	types = strtok( str, "|" );

	errors = 0;
	additional_types = [];
	for ( i = 0; i < types.size; i++ )
	{
		if ( types[ i ] == "none" )
		{
			additional_types[ additional_types.size ] = "none";
			return set_cast_success( find, additional_types, "enttype==none" );
		}

		if ( !isdefined( level._entity_type_funcs[ types[ i ] ] ) )
		{
			errors++;
		}
	}

	if ( errors > 0 )
	{
		msg = get_possible_array_values_msg( str, level._entity_type_funcs, "enttype" );
		return set_cast_error( find, msg );
	}

	return set_cast_success( find, types, "enttype=='{}'", str );
}

private cast_str_to_nodetype_internal( str )
{
	find = generic_obj_t_new();

	types = strtok( str, "|" );

	errors = 0;
	additional_types = [];
	for ( i = 0; i < types.size; i++ )
	{
		if ( types[ i ] == "none" )
		{
			additional_types[ additional_types.size ] = "none";
			return set_cast_success( find, additional_types, "nodetype==none" );
		}

		if ( types[ i ] == "all" )
		{
			additional_types[ additional_types.size ] = "all";
			return set_cast_success( find, additional_types, "nodetype==all" );
		}

		if ( types[ i ] == "negotiation" )
		{
			additional_types[ additional_types.size ] = "Begin";
			additional_types[ additional_types.size ] = "End";
			return set_cast_success( find, additional_types, "nodetype==negotiation" );
		}

		node_keys = getarraykeys( level._node_types );
		j = 0;
		for ( ; j < node_keys.size; j++ )
		{
			if ( tolower( node_keys[ j ] ) == tolower( types[ i ] ) )
			{
				break;
			}
		}
		if ( j == node_keys.size )
		{
			errors++;
		}
	}

	if ( errors > 0 )
	{
		msg = get_possible_array_values_msg( str, level._node_types, "nodetype" );
		return set_cast_error( find, msg );
	}

	return set_cast_success( find, types, "nodetype=='{}'", str );
}

private cast_str_to_triggertype_internal( str )
{
	find = generic_obj_t_new();

	types = strtok( str, "|" );

	use_trigger_alieses = [];
	use_trigger_aliases[ 0 ] = "box_use";
	use_trigger_aliases[ 1 ] = "radius_use";

	additional_types = [];
	guard = false;
	errors = 0;
	for ( i = 0; i < types.size; i++ )
	{
		if ( types[ i ] == "use" )
		{
			additional_types[ additional_types.size ] = "box_use";
			additional_types[ additional_types.size ] = "radius_use";
			return set_cast_success( find, additional_types, "triggertype==use" );
		}

		if ( types[ i ] == "touch" )
		{
			additional_types[ additional_types.size ] = "box";
			additional_types[ additional_types.size ] = "radius";
			return set_cast_success( find, additional_types, "triggertype==touch" );
		}

		if ( types[ i ] == "box" )
		{
			additional_types[ additional_types.size ] = "box_use";
			additional_types[ additional_types.size ] = "box";
			return set_cast_success( find, additional_types, "triggertype==box" );
		}

		if ( types[ i ] == "radius" )
		{
			additional_types[ additional_types.size ] = "radius_use";
			additional_types[ additional_types.size ] = "radius";
			return set_cast_success( find, additional_types, "triggertype==radius" );
		}

		if ( !isdefined( level._trigger_types[ types[ i ] ] ) )
		{
			// check with "trigger_" prefix
			substr = getsubstr( types[ i ], 8 );
			if ( !isdefined( level._trigger_types[ substr ] ) )
			{
				errors++;
			}
		}
	}

	if ( errors > 0 )
	{
		msg = get_possible_array_values_msg( str, level._trigger_types, "triggertype" );
		return set_cast_error( find, msg );
	}

	return set_cast_success( find, types, "triggertype=='{}'", str );
}

private cast_str_to_entfield_internal( str )
{
	find = generic_obj_t_new();
	entfield_str = tolower( str );
	if ( !isdefined( level._entity_string_fields[ entfield_str ] ) )
	{
		msg = get_possible_array_values_msg( str, level._entity_string_fields, "entfield" );
		return set_cast_error( find, msg );
	}
	return set_cast_success( find, entfield_str, "entfield=='{}'", str );
}

private cast_str_to_fx_internal( str )
{
	find = generic_obj_t_new();

	fx_exists = _FX_EXISTS( str );
	if ( !fx_exists )
	{
		return set_cast_error( find, "FX not precached: '{}'", str );
	}

	return set_cast_success( find, level._effect[ str ], "fx=='{}'", str );
}

private cast_str_to_cameraflags_internal( str )
{
	find = generic_obj_t_new();

	fx_exists = _FX_EXISTS( str );
	if ( !fx_exists )
	{
		return set_cast_error( find, "FX not precached: '{}'", str );
	}

	return set_cast_success( find, level._effect[ str ], "cameraflags=='{}'", str );
}

private cast_str_to_cmdmodule_internal( str )
{
	result_obj = generic_obj_t_new( "cmdmodule" );
	if ( str == "" )
	{
		return set_cast_error( result_obj, "No string provided" );
	}

	if ( !isdefined( level._cmd_modules[ str ] ) )
	{
		return set_cast_error( result_obj, "Unknown cmdmodule: '{}'", str );
	}

	return set_cast_success( result_obj, str, "cmdmodule=='{}'", str );
}