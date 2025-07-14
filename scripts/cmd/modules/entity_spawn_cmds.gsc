#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd_system_modules\_cmd_arg;
#include scripts\cmd_system_modules\_hud;

add_field_history( entfield_name, new_value )
{

}

set_entfield_relative( entfield_name, new_value )
{
	result_obj = result_obj_new( "entfield" );
	switch ( entfield_name )
	{
		case "classname":
		case "spawnflags":
		case "birthtime":
			return set_cast_error( result_obj, entfield_name + " is read only!" );
		case "model":
		case "destkey":
		case "targetname":
		case "script_noteworthy":
			return set_cast_error( result_obj, entfield_name + " cannot be changed relatively!" );
		case "count":
			self.count += int( new_value );
			break;
		case "health":
			self.health += int( new_value );
			break;
		case "dmg":
			self.dmg += int( new_value );
			break;
		case "index":
			self.index += int( new_value );
			break;
		case "lerp_to_lighter":
			self.lerp_to_lighter += float( new_value );
			break;
		case "lerp_to_dark":
			self.lerp_to_dark += float( new_value );
			break;
		case "origin":
			vector_origin += cast_str_to_vector( new_value );
			self setorigin( vector_origin );
			break;
		case "angles":
			vector_angles += cast_str_to_vector( new_value );
			self setangles( vector_origin );
			break;
		default:
			//TODO: handle radiant/keys.txt here...
			return set_cast_error( result_obj, entfield_name + " is unsupported!" );
	}

	self add_field_history( entfield_name, new_value );

	return set_cast_success( result_obj, self, "Successfully set: " + entfield_name + " to value: " + new_value );
}

set_entfield( entfield_name, new_value )
{
	result_obj = result_obj_new( "entfield" );
	switch ( entfield_name )
	{
		case "classname":
		case "spawnflags":
		case "birthtime":
			return set_cast_error( result_obj, entfield_name + " is read only!" );
		case "model":
			self setmodel( new_value );
			break;
		case "destkey":
			self.destkey = new_value;
			break;
		case "targetname":
			self.targetname = new_value;
			break;
		case "script_noteworthy":
			self.script_noteworthy = new_value;
			break;
		case "count":
			self.count = int( new_value );
			break;
		case "health":
			self.health = int( new_value );
			break;
		case "dmg":
			self.dmg = int( new_value );
			break;
		case "index":
			self.index = int( new_value );
			break;
		case "lerp_to_lighter":
			self.lerp_to_lighter = float( new_value );
			break;
		case "lerp_to_dark":
			self.lerp_to_dark = float( new_value );
			break;
		case "origin":
			vector_origin = cast_str_to_vector( new_value );
			self setorigin( vector_origin );
			break;
		case "angles":
			vector_angles = cast_str_to_vector( new_value );
			self setangles( vector_origin );
			break;
		case "takedamage":
			self setcandamage( int( new_value ) );
			break;
		case "contents":
			self setcontents( int( new_value ) );
			break;
		case "solid":
			self solid();
			break;
		case "notsolid":
			self notsolid();
			break;
		case "setcheapflag":
			self setcheapflag( int( new_value ) );
			break;
		case "ignorecheapentityflag":
			self ignorecheapentityflag( int( new_value ) );
			break;
		default:
			return set_cast_error( result_obj, entfield_name + " is unsupported!" );
	}

	self add_field_history( entfield_name, new_value );

	return set_cast_success( result_obj, self, "Successfully set: " + entfield_name + " to value: " + new_value );
}

get_entfield( entfield_name )
{
	result_obj = result_obj_new( "entfield" );
	switch ( entfield_name )
	{
		case "classname":
			return set_cast_success( result_obj, self.classname, "classname==" + self.classname, "string" );
		case "spawnflags":
			return set_cast_success( result_obj, self.spawnflags, "spawnflags==" + self.spawnflags, "spawnflags" );
		case "birthtime":
			return set_cast_success( result_obj, self.birthtime, "birthtime==" + self.birthtime, "int" );
		case "model":
			return set_cast_success( result_obj, self.model, "model==" + self.model, "string" );
		case "destkey":
			return set_cast_success( result_obj, self.destkey, "destkey==" + self.destkey, "string" );
		case "targetname":
			return set_cast_success( result_obj, self.targetname, "targetname==" + self.targetname, "string" );
		case "script_noteworthy":
			return set_cast_success( result_obj, self.script_noteworthy, "script_noteworthy==" + self.script_noteworthy, "string" );
		case "count":
			return set_cast_success( result_obj, self.count, "count==" + self.count, "int" );
		case "health":
			return set_cast_success( result_obj, self.health, "health==" + self.health, "int" );
		case "dmg":
			return set_cast_success( result_obj, self.dmg, "dmg==" + self.dmg, "int" );
		case "index":
			return set_cast_success( result_obj, self.index, "index==" + self.index, "int" );
		case "lerp_to_lighter":
			return set_cast_success( result_obj, self.lerp_to_lighter, "lerp_to_lighter==" + self.lerp_to_lighter, "float" );
		case "lerp_to_dark":
			return set_cast_success( result_obj, self.lerp_to_dark, "lerp_to_dark==" + self.lerp_to_dark, "float" );
		case "origin":
			return set_cast_success( result_obj, self.origin, "origin==" + self.origin, "vector" );
		case "angles":
			return set_cast_success( result_obj, self.angles, "angles==" + self.angles, "vector" );
		case "takedamage":
		default:
			return set_cast_error( result_obj, entfield_name + " is unsupported!" );
	}
}
/*
#define SPAWNFLAG_MODEL_DYNAMIC_PATH 1
#define SPAWNFLAG_PATH_CAN_PARENT 256
#define SPAWNFLAG_PATH_DISABLED 512
#define SPAWNFLAG_TRIGGER_AI_AXIS 1
#define SPAWNFLAG_TRIGGER_AI_ALLIES 2
#define SPAWNFLAG_TRIGGER_AI_NEUTRAL 4
#define SPAWNFLAG_TRIGGER_SPAWN 32
#define SPAWNFLAG_TRIGGER_LOOK 256
#define SPAWNFLAG_TRIGGER_SPAWN_MANAGER 512
#define SPAWNFLAG_TRIGGER_TRIGGER_ONCE 1024
#define SPAWNFLAG_VEHICLE_NODE_START_NODE 1
#define SPAWNFLAG_VEHICLE_SPAWNER 2
#define SPAWNFLAG_VEHICLE_NODE_ROTATE 65536
#define SPAWNFLAG_TURRET_ENABLED 1
#define SPAWNFLAG_TURRET_GET_USERS 2
#define SPAWNFLAG_ACTOR_SPAWNER 1
#define SPAWNFLAG_ACTOR_SCRIPTFORCESPAWN 16
#define SPAWNFLAG_ACTOR_SM_PRIORITY 32
*/

load_script_origin()
{

}

save_script_origin()
{

}

spawn_script_origin( origin, spawnflags )
{
	ent = spawn( "script_origin", origin, spawnflags );
	return ent;
}

load_script_model()
{
	ent = spawn_script_model( origin, spawnflags );
	//ent load_entfields();
}

save_script_model()
{

}

spawn_script_model( origin, spawnflags )
{
	//#define SPAWNFLAG_MODEL_DYNAMIC_PATH 1
	ent = spawn( "script_model", origin, spawnflags );
	return ent;
}

load_trigger_damage()
{
	ent = spawn_trigger_damage( origin, spawnflags, radius, height );
	//ent load_entfields();
}

save_trigger_damage()
{

}

spawn_trigger_damage( origin, spawnflags, radius, height )
{
	radius = _DEFAULT( args[ 3 ], 128 );
	height = _DEFAULT( args[ 4 ], 96 );
	//#define SPAWNFLAG_WAIT 512
	ent = spawn( "trigger_damage", origin, spawnflags, radius, height );
	// Mirroring engine code
	ent.health = 32000;
	ent setcandamage( true );
	ent setcontents( 0x405C0008 );
	return ent;
}

load_trigger_radius_use()
{
	ent = spawn_trigger_radius_use( origin, spawnflags, radius, height );
	//ent load_entfields();
}

save_trigger_radius_use()
{

}

spawn_trigger_radius_use( origin, spawnflags, radius, height )
{
	radius = _DEFAULT( args[ 3 ], 128 );
	height = _DEFAULT( args[ 4 ], 96 );
	ent = spawn( "trigger_radius_use", origin, spawnflags, radius, height );
	// Mirroring engine code
	contents = 0;
	if ( ( spawnflags & 8 ) == 0 )
	{
		contents = 0x40000000;
	}
	if ( ( spawnflags & 1 ) != 0 )
	{
		contents |= 0x40000u;
	}
	if ( ( spawnflags & 2 ) != 0 )
	{
		contents |= 0x80000u;
	}
	if ( ( spawnflags & 4 ) != 0 )
	{
		contents |= 0x100000u;
	}
	if ( ( spawnflags & 0x10 ) != 0 )
	{
		contents |= 8u;
	}
	ent setcontents( contents | 0x200000 );
	return ent;
}

load_trigger_box_use()
{
	ent = spawn_trigger_box_use( origin, spawnflags, width, length, height );
	//ent load_entfields();
}

save_trigger_box_use()
{

}

spawn_trigger_box_use( origin, spawnflags, width, length, height )
{
	//#define SPAWNFLAG_WAIT 64
	width = _DEFAULT( width, 10 );
	length = _DEFAULT( length, 10 );
	height = _DEFAULT( height, 10 );
	ent = spawn( "trigger_box_use", origin, spawnflags, width, length height );
	// Mirroring engine code
	contents = 0;
	if ( ( spawnflags & 8 ) == 0 )
	{
		contents = 0x40000000;
	}
	if ( ( spawnflags & 1 ) != 0 )
	{
		contents |= 0x40000u;
	}
	if ( ( spawnflags & 2 ) != 0 )
	{
		contents |= 0x80000u;
	}
	if ( ( spawnflags & 4 ) != 0 )
	{
		contents |= 0x100000u;
	}
	if ( ( spawnflags & 0x10 ) != 0 )
	{
		contents |= 8u;
	}
	ent setcontents( contents | 0x200000 );
	return ent;
}

load_trigger_box()
{
	ent = spawn_trigger_box( origin, spawnflags, width, length, height );
	//ent load_entfields();
}

save_trigger_box()
{

}

spawn_trigger_box( origin, spawnflags, width, length, height )
{
	//#define SPAWNFLAG_WAIT 64
	width = _DEFAULT( width, 10 );
	length = _DEFAULT( length, 10 );
	height = _DEFAULT( height, 10 );
	ent = spawn( "trigger_box", origin, spawnflags, width, length height );
	// Mirroring engine code
	contents = 0;
	if ( ( spawnflags & 8 ) == 0 )
	{
		contents = 0x40000000;
	}
	if ( ( spawnflags & 1 ) != 0 )
	{
		contents |= 0x40000u;
	}
	if ( ( spawnflags & 2 ) != 0 )
	{
		contents |= 0x80000u;
	}
	if ( ( spawnflags & 4 ) != 0 )
	{
		contents |= 0x100000u;
	}
	if ( ( spawnflags & 0x10 ) != 0 )
	{
		contents |= 8u;
	}
	ent setcontents( contents | 0x200000 );
	return ent;
}

load_trigger_radius()
{
	ent = spawn_trigger_radius( origin, spawnflags, radius, height );
	//ent load_entfields();
}

save_trigger_radius()
{

}

spawn_trigger_radius( origin, spawnflags, radius, height )
{
	//#define SPAWNFLAG_WAIT 64
	radius = _DEFAULT( args[ 3 ], 128 );
	height = _DEFAULT( args[ 4 ], 96 );
	ent = spawn( "trigger_radius", origin, spawnflags, radius, height );
	// Mirroring engine code
	contents = 0;
	if ( ( spawnflags & 8 ) == 0 )
	{
		contents = 0x40000000;
	}
	if ( ( spawnflags & 1 ) != 0 )
	{
		contents |= 0x40000u;
	}
	if ( ( spawnflags & 2 ) != 0 )
	{
		contents |= 0x80000u;
	}
	if ( ( spawnflags & 4 ) != 0 )
	{
		contents |= 0x100000u;
	}
	if ( ( spawnflags & 0x10 ) != 0 )
	{
		contents |= 8u;
	}
	ent setcontents( contents | 0x200000 );
	return ent;
}

cmd_spawn_f( target_obj, args )
{
	classname = args[ 0 ];
	origin = args[ 1 ];
	spawnflags = _DEFAULT( args[ 2 ], 0 );

	ent = undefined;
	switch ( classname )
	{
		case "trigger_radius":
			ent = spawn_trigger_radius( origin, spawnflags, args [ 3 ], args[ 4 ] );
			break;
		case "trigger_box":
			ent = spawn_trigger_box( origin, spawnflags, args [ 3 ], args[ 4 ], args[ 5 ] );
			break;
		case "trigger_box_use":
			ent = spawn_trigger_box_use( origin, spawnflags, args [ 3 ], args[ 4 ], args[ 5 ] );
			break;
		case "trigger_radius_use":
			ent = spawn_trigger_radius_use( origin, spawnflags, args [ 3 ], args[ 4 ] );
			break;
		case "trigger_damage":
			ent = spawn_trigger_damage( origin, spawnflags, args [ 3 ], args[ 4 ] );
			break;
		case "script_model":
			ent = spawn_script_model( origin, spawnflags );
			break;
		case "script_origin":
			ent = self spawn_script_origin( origin, spawnflags );
			break;
		case "info_notnull":
		case "info_notnull_big":
		case "info_volume":
		default:
			return result_cmderror( "Unsupported classname: " + classname );
	}
}

cast_str_to_actor_spawner( str, noprint = false, allow_null_actor_spawner = false )
{
	spawners = getspawnerarray();

	return spawners[ 0 ];
}

load_actor()
{
	ent = spawn_actor( actor_spawner, get_enemy_info, targetname );
	//ent load_entfields();
}

save_actor()
{

}

spawn_actor( actor_spawner, get_enemy_info, targetname )
{
	get_enemy_info = _DEFAULT( get_enemy_info, 0 );
	targetname = _DEFAULT( targetname, "" );
	actor_spawner spawnactor( get_enemy_info, targetname );
	return ent;
}

cmd_spawnactor_f( target_obj, args )
{
	actor_spawner = args[ 0 ];

	actor = spawn_actor( actor_spawner, args[ 1 ], args[ 2 ] );
}

load_collision()
{
	ent = spawn_collision( model, targetname, origin, angles );
	//ent load_entfields();
}

save_collision()
{

}

spawn_collision( model, targetname, origin, angles )
{
	ent = spawncollision( model, targetname, origin, angles );
	return ent;
}

cmd_spawncollision_f( target_obj, args )
{
	model = args[ 0 ];
	targetname = args[ 1 ];
	origin = args[ 2 ];
	angles = args[ 3 ];

	ent = spawn_collision( model, targetname, origin, angles );
}

load_plane()
{
	ent = spawn_plane( classname, origin, spawnflags );
	//ent load_entfields();
}

save_plane()
{

}

spawn_plane( owner, classname, origin, spawnflags )
{
	spawnflags = _DEFAULT( spawnflags, 0 );
	ent = spawnplane( owner, classname, origin, spawnflags );
	return ent;
}

cmd_spawnplane_f( target_obj, args )
{
	owner = args[ 0 ];
	classname = args[ 1 ];
	origin = args[ 2 ];
	spawnflags = _DEFAULT( args[ 3 ], 0 );

	ent = spawn_plane( owner, classname, origin, spawnflags );
}

load_helicopter()
{
	ent = spawn_helicopter( owner, origin, angles, vehicle_def_name, model );
	//ent load_entfields();
}

save_helicopter()
{

}

spawn_helicopter( owner, origin, angles, vehicle_def_name, model )
{
	spawnflags = _DEFAULT( spawnflags, 0 );
	ent = spawnhelicopter( owner, origin, angles, vehicle_def_name, model );
	return ent;
}

cmd_spawnhelicopter_f( target_obj, args )
{
	owner = args[ 0 ];
	origin = args[ 1 ];
	angles = args[ 2 ];
	vehicle_def_name = args[ 3 ];
	model = args[ 4 ];

	ent = spawn_helicopter( owner, origin, angles, vehicle_def_name, model );
}

load_vehicle()
{
	ent = spawn_vehicle( model, targetname, vehicletype, origin, angles, destructible_name );
	//ent load_entfields();
}

save_vehicle()
{

}

spawn_vehicle( model, targetname, vehicletype, origin, angles, destructible_name )
{
	//SPAWNFLAG_USABLE 1
	if ( isdefined( destructible_name ) && destructible_name != "" )
	{
		ent = spawnvehicle( model, targetname, vehicletype, origin, angles, destructible_name );
	}
	else
	{
		ent = spawnvehicle( model, targetname, vehicletype, origin, angles );
	}
	
	return ent;
}

cmd_spawnvehicle_f( target_obj, args )
{
	model = args[ 0 ];
	targetname = args[ 1 ];
	vehicletype = args[ 2 ];
	origin = args[ 3 ];
	angles = args[ 4 ];
	destructible_name = args[ 5 ];

	ent = spawn_vehicle( model, targetname, vehicletype, origin, angles, destructible_name );
}

load_turret()
{
	ent = spawn_turret( classname, origin, weapon );
	//ent load_entfields();
}

save_turret()
{

}

spawn_turret( classname, origin, weapon )
{
	ent = spawnturret( classname, origin, weapon );
	
	return ent;
}

cmd_spawnturret_f( target_obj, args )
{
	classname = args[ 0 ];
	origin = args[ 1 ];
	weapon = args[ 2 ];

	ent = spawn_turret( classname, origin, weapon );
}

load_player_clone()
{
	ent = spawn_player_clone( player, death_anim_duration );
	//ent load_entfields();
}

save_player_clone()
{

}

spawn_player_clone( player, death_anim_duration )
{
	ent = player cloneplayer( death_anim_duration );
	
	return ent;
}

cmd_cloneplayer_f( target_obj, args )
{
	player = args[ 0 ];
	death_anim_duration = args[ 1 ];

	ent = spawn_player_clone( player, death_anim_duration );
}

load_path_node()
{
	ent = spawn_path_node( classname, origin, angles, key1, val1, key2, val2, key3, val3 );
	//ent load_entfields();
}

save_path_node()
{

}

spawn_path_node( classname, origin, angles, key1, val1, key2, val2, key3, val3 )
{
	ent = undefined;
	if ( isdefined( key3 ) )
	{
		ent = spawnpathnode( classname, origin, angles, key1, val1, key2, val2, key3, val3 );
	}
	else if ( isdefined( key2 ) )
	{
		ent = spawnpathnode( classname, origin, angles, key1, val1, key2, val2 );
	}
	else if ( isdefined( key1 ) )
	{
		ent = spawnpathnode( classname, origin, angles, key1, val1 );
	}
	else
	{
		ent = spawnpathnode( classname, origin, angles );
	}
	
	return ent;
}

cmd_spawnpathnode_f( target_obj, args )
{
	classname = args[ 0 ];
	origin = args[ 1 ];
	angles = args[ 2 ];
	key1 = args[ 3 ];
	val1 = args[ 4 ];
	key2 = args[ 5 ];
	val2 = args[ 6 ];
	key3 = args[ 7 ];
	val3 = args[ 8 ];

	ent = spawn_path_node( classname, origin, angles, key1, val1, key2, val2, key3, val3 );
}

load_fx()
{
	ent = spawn_fx( fx_id, origin, forward, up );
	//ent load_entfields();
}

save_fx()
{

}

spawn_fx( fx_id, origin, forward, up )
{
	ent = spawnfx( fx_id, origin, forward, up );
	
	return ent;
}

cmd_spawnfx_f( target_obj, args )
{
	fx_id = args[ 0 ];
	origin = args [ 1 ];
	forward = args[ 2 ];
	up = args[ 3 ];

	ent = spawn_fx( fx_id, origin, forward, up );
}

/*
	level.tcs_dynamic_function_spawns = [];
	level.tcs_dynamic_function_spawns[ "spawnnapalmgroundflame" ] = 4;
*/
load_timed_fx()
{
	ent = spawn_timed_fx( weapon, origin, direction, time_seconds );
	//ent load_entfields();
}

save_timed_fx()
{

}

spawn_timed_fx( weapon, origin, direction, time_seconds )
{
	ent = spawntimedfx( weapon, origin, direction, time_seconds );
	
	return ent;
}

cmd_spawntimedfx_f( target_obj, args )
{
	weapon = args[ 0 ];
	origin = args [ 1 ];
	direction = _DEFAULT( args[ 2 ], ( 0, 0, 1.0 ) );
	time_seconds = _DEFAULT( args[ 3 ], 10 );

	ent = spawn_timed_fx( weapon, origin, direction, time_seconds );
}

/*
	level.tcs_dynamic_function_spawns = [];
	level.tcs_dynamic_function_spawns[ "spawnnapalmgroundflame" ] = 4;
*/
load_napalm_ground_flame()
{
	ent = spawn_napalm_ground_flame( origin, weapon, direction, time_seconds );
	//ent load_entfields();
}

save_napalm_ground_flame()
{

}

spawn_napalm_ground_flame( origin, weapon, direction, time_seconds )
{
	ent = spawnnapalmgroundflame( origin, weapon, direction, time_seconds );
	
	return ent;
}

cmd_spawnnapalmgroundflame_f( target_obj, args )
{
	origin = args [ 0 ];
	weapon = args[ 1 ];
	direction = _DEFAULT( args[ 2 ], ( 0, 0, 1.0 ) );
	time_seconds = _DEFAULT( args[ 3 ], 10 );

	ent = spawn_napalm_ground_flame( origin, weapon, direction, time_seconds );
}

hash_ent( entity )
{
	classname = entity.classname;
	origin = entity.origin + "";
	angles = entity.angles + "";
	model = entity.model;
	spawnflags = entity.spawnflags + "";
	health = entity.health + "";
	birthtime = entity.birthtime + "";

	new_string = "";

	full_string = classname + "!" + model + "!" + origin + "!" + angles + "!" + spawnflags + "!" + health + "!" + birthtime;
	for ( i = 0; i < fullstring.size; i++ )
	{
		if ( fullstring[ i ] == "(" || fullstring[ i ] == ")" )
		{
			continue;
		}

		if ( vector_str[ i ] == "." )
		{
			new_string += "@";
			continue;
		}

		new_string += fullstring[ i ];
	}
	
	return new_string;
}

write_ent_delta_to_file( entity )
{

}

/*editor_ent_history_t*/ editor_ent_history_new()
{
	ent_history_obj = spawnstruct();
	ent_history_obj.hash = hash_ent( self );
}

init()
{
	level.editor_mapents_entity_save_fh = fs_fopen( "spawned_entities_" + getdvar( "mapname" ) + ".mapents", "append" );
	level.editor_gsc_entity_save_fh = fs_fopen( "spawned_entities_" + getdvar( "mapname" ) + ".gsc", "append" );
}

main()
{
	addcallback( "on_player_connect", ::on_editor_connect );
	while ( !isdefined( level.cmd_init_done ) )
	{
		wait 0.05;
	}

	if ( !isdefined( level.tcs_add_cmd_func ) )
	{
		return;	
	}

	if ( !isdefined( level._editor_entity_history ) )
	{
		level._editor_entity_history = [];
	}

	level.physicstracemaskphysics = 1;
	level.physicstracemaskvehicle = 2;
	level.physicstracemaskwater = 4;
	level.physicstracemaskclip = 8;
	level.physicstracecontentsvehicleclip = 16;
	level._editor_ent_mask = level.physicstracemaskphysics | level.physicstracemaskvehicle | level.physicstracemaskwater | level.physicstracemaskclip;

	cmd_block_set_module_group( "addon_entity_tools" );
	cmd_block_set_rank_group( "cheat" );
	dumpent_cmd = cmd_add( "spawn", "spawn <classname> <origin> [spawnflags] [contextual1] [contextual2] [contextual3]", ::cmd_spawn_f );
	dumpent_cmd arg_obj_add_cmd( "classname vector spawnflags string string string", 2, 6 );
}