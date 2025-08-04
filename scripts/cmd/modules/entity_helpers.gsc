#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

#include scripts\cmd\core\_hud_api;
#include scripts\cmd\core\_hud_utility;

autoexec init_helpers()
{
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

	addcallback( "on_player_connect", ::on_editor_connect );
}

private on_editor_connect()
{
	if ( !isdefined( level._first_player ) )
	{
		level._first_player = true;
		level._baseline_text_hud = create_text_hud_baseline();
		level._baseline_text_hud.alpha = 0.0;
		level._baseline_text_hud settext( "REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE" );
	}

	if ( !isdefined( self._editor_placed_ents ) )
	{
		self._editor_placed_ents = [];
	}
	if ( !isdefined( self._editor_moved_ents ) )
	{
		self._editor_moved_ents = [];
	}

	self notifyonplayercommand( "toggle_unlink", "+speed_throw" );

	self hud_binding_register( "editor_mode_context", "text", "edit_mode", "No editor context!" );
	self hud_binding_register( "editor_scale_context", "text", "edit_scale", "No editor context scale!" );
	self hud_binding_register( "editor_selected_ent_context", "entity", "selected_entity", "No selected entity!" );
	self hud_binding_register( "editor_held_context", "entity", "held_entity", "No held entity!" );
	self hud_binding_register( "editor_placed_context", "entity", "placed_entities", "No placed entities!" );

	vertical_hud_list_obj = vertical_text_list_create( 20, 1.0, "objective", 1.8, "left", "top", "user_left", "user_top" );
	vertical_hud_list_obj set_alpha( 1.0 );

	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_mode_context" );
	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_scale_context" );
	//fontelem settext( "GRUS1" );
	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_selected_ent_context" );
	//fontelem settext( "GRUS2" );
	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_held_context" );
	//fontelem settext( "GRUS3" );

	self hud_binding_set( "editor_mode_context", "none" );
	self hud_binding_set( "editor_scale_context", 1.0 );

	self thread hud_bindings_update_loop();
}

cast_entity_raycast_from_player_eye()
{
	direction = self getplayerangles();
	direction_vec = anglestoforward( direction );
	eye = self geteye();
	scale = 8000;
	direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
	trace = bullettrace( eye, eye + direction_vec, false, undefined );

	if ( !isdefined( trace[ "entity" ] ) )
	{
		trace = physicstrace( eye, eye + direction_vec, vectorscale( ( -1, -1, 0 ), 15.0 ), vectorscale( ( 1, 1, 0 ), 15.0 ), self, level._editor_ent_mask );
		if ( !isdefined( trace[ "entity" ] ) )
		{
			return trace;
		}
	}

	return trace;
}

give_player_turret( model, turret_classname, turret_weapon_name, turret_type, set_turret_carried, carry_offset, carry_angles )
{
	placeturret = spawnturret( turret_classname, self.origin, turret_weapon_name );
	placeturret.angles = self.angles;
	placeturret setmodel( model );
	placeturret setturretcarried( set_turret_carried );
	placeturret setturretowner( self );

	self carryturret( placeturret, carry_offset, carry_angles );
	self hud_binding_subscribe_to_entity( "editor_held_context", placeturret );

	return placeturret;
}

take_player_turret( held_ent )
{
	self stopcarryturret( held_ent );
	held_ent setturretcarried( false );
	held_ent delete();
}

take_player_turret_thread( held_ent )
{
	result = self waittill_any_return( "disconnect", "editor_place_cancel", "editor_place_success" );

	self take_player_turret( held_ent );
}

add_placed_ent( new_ent )
{
	ent_name = self.editor_spawn_ent_name;
	if ( isdefined( self._editor_placed_ents[ ent_name ] ) )
	{
		self._editor_placed_ents[ ent_name ] delete();
	}
	self._editor_placed_ents[ ent_name ] = new_ent;

	new_ent.editor_name = ent_name;
	self.editor_spawn_ent_name = undefined;
}

add_moved_ent( moved_ent )
{
	entnum = moved_ent getentitynumber();
	self._editor_moved_ents[ entnum ] = moved_ent;
}

editor_spawn_held_ent( held_ent, angles, origin )
{
	new_ent = spawn( "script_model", origin );
	new_ent.angles = angles;
	new_ent setmodel( held_ent.model );

	self add_placed_ent( new_ent );
}

editor_move_held_ent( held_ent, angles, origin )
{
	original_ent = self.editor_move_ent;
	original_ent.angles = angles;
	original_ent.origin = origin;
	original_ent show();

	self add_moved_ent( original_ent );
	self.editor_move_ent = undefined;
}

editor_move_selected_ent_absolute( selected_ent, absolute_angles, absolute_origin )
{
	selected_ent.angles = absolute_angles;
	selected_ent.origin = absolute_origin;

	self add_moved_ent( selected_ent );
}

editor_move_selected_ent_relative( selected_ent, relative_angles, relative_origin, scale )
{
	scale = _DEFAULT( scale, 1.0 );
	selected_ent.angles += ( relative_angles * scale );
	selected_ent.origin += ( relative_origin * scale );

	self add_moved_ent( selected_ent );
}

editor_held_model_thread( held_ent, place_mode )
{
	self endon( "disconnect" );
	self endon( "editor_place_cancel" );

	for ( ;; )
	{
		self waittill( "editor_place_held" );

		if ( !( isdefined( level.use_legacy_equipment_placement ) && level.use_legacy_equipment_placement ) )
			turret_placement = self canplayerplaceturret();

		if ( turret_placement[ "result" ] )
		{
			if ( place_mode == "spawn" )
			{
				self editor_spawn_held_ent( held_ent, turret_placement[ "angles" ], turret_placement[ "origin" ] );
			}
			else if ( place_mode == "move" )
			{
				self editor_move_held_ent( held_ent, turret_placement[ "angles" ], turret_placement[ "origin" ] );
			}

			break;
		}
	}

	self notify( "editor_place_success" );
}

add_field_history( entfield_name, new_value )
{

}

set_entfield_relative( entfield_name, new_value )
{
	result_obj = generic_obj_t_new( "entfield" );
	switch ( entfield_name )
	{
		case "classname":
		case "spawnflags":
		case "birthtime":
			return set_cast_error( result_obj, entfield_name + " is read only!" );
		case "model":
		case "target":
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
			self.angles = vector_angles;
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
	result_obj = generic_obj_t_new( "entfield" );
	switch ( entfield_name )
	{
		case "classname":
		case "spawnflags":
		case "birthtime":
			return set_cast_error( result_obj, entfield_name + " is read only!" );
		case "model":
			self setmodel( new_value );
			break;
		case "target":
			self.target = new_value;
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
			self.angles = vector_angles;
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
	result_obj = generic_obj_t_new( "entfield" );
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
		case "target":
			return set_cast_success( result_obj, self.target, "target==" + self.target, "string" );
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
	//ent = spawn_script_model( origin, spawnflags );
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
	//ent = spawn_trigger_damage( origin, spawnflags, radius, height );
	//ent load_entfields();
}

save_trigger_damage()
{

}

spawn_trigger_damage( origin, spawnflags, radius, height )
{
	radius = _DEFAULT( radius, 128 );
	height = _DEFAULT( height, 96 );
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
	//ent = spawn_trigger_radius_use( origin, spawnflags, radius, height );
	//ent load_entfields();
}

save_trigger_radius_use()
{

}

spawn_trigger_radius_use( origin, spawnflags, radius, height )
{
	radius = _DEFAULT( radius, 128 );
	height = _DEFAULT( height, 96 );
	ent = spawn( "trigger_radius_use", origin, spawnflags, radius, height );
	// Mirroring engine code
	contents = 0;
	if ( ( spawnflags & 8 ) == 0 )
	{
		contents = 0x40000000;
	}
	if ( ( spawnflags & 1 ) != 0 )
	{
		contents |= 0x40000;
	}
	if ( ( spawnflags & 2 ) != 0 )
	{
		contents |= 0x80000;
	}
	if ( ( spawnflags & 4 ) != 0 )
	{
		contents |= 0x100000;
	}
	if ( ( spawnflags & 0x10 ) != 0 )
	{
		contents |= 8;
	}
	ent setcontents( contents | 0x200000 );
	return ent;
}

load_trigger_box_use()
{
	//ent = spawn_trigger_box_use( origin, spawnflags, width, length, height );
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
	ent = spawn( "trigger_box_use", origin, spawnflags, width, length, height );
	// Mirroring engine code
	contents = 0;
	if ( ( spawnflags & 8 ) == 0 )
	{
		contents = 0x40000000;
	}
	if ( ( spawnflags & 1 ) != 0 )
	{
		contents |= 0x40000;
	}
	if ( ( spawnflags & 2 ) != 0 )
	{
		contents |= 0x80000;
	}
	if ( ( spawnflags & 4 ) != 0 )
	{
		contents |= 0x100000;
	}
	if ( ( spawnflags & 0x10 ) != 0 )
	{
		contents |= 8;
	}
	ent setcontents( contents | 0x200000 );
	return ent;
}

load_trigger_box()
{
	//ent = spawn_trigger_box( origin, spawnflags, width, length, height );
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
	ent = spawn( "trigger_box", origin, spawnflags, width, length, height );
	// Mirroring engine code
	contents = 0;
	if ( ( spawnflags & 8 ) == 0 )
	{
		contents = 0x40000000;
	}
	if ( ( spawnflags & 1 ) != 0 )
	{
		contents |= 0x40000;
	}
	if ( ( spawnflags & 2 ) != 0 )
	{
		contents |= 0x80000;
	}
	if ( ( spawnflags & 4 ) != 0 )
	{
		contents |= 0x100000;
	}
	if ( ( spawnflags & 0x10 ) != 0 )
	{
		contents |= 8;
	}
	ent setcontents( contents | 0x200000 );
	return ent;
}

load_trigger_radius()
{
	//ent = spawn_trigger_radius( origin, spawnflags, radius, height );
	//ent load_entfields();
}

save_trigger_radius()
{

}

spawn_trigger_radius( origin, spawnflags, radius, height )
{
	//#define SPAWNFLAG_WAIT 64
	radius = _DEFAULT( radius, 128 );
	height = _DEFAULT( height, 96 );
	ent = spawn( "trigger_radius", origin, spawnflags, radius, height );
	// Mirroring engine code
	contents = 0;
	if ( ( spawnflags & 8 ) == 0 )
	{
		contents = 0x40000000;
	}
	if ( ( spawnflags & 1 ) != 0 )
	{
		contents |= 0x40000;
	}
	if ( ( spawnflags & 2 ) != 0 )
	{
		contents |= 0x80000;
	}
	if ( ( spawnflags & 4 ) != 0 )
	{
		contents |= 0x100000;
	}
	if ( ( spawnflags & 0x10 ) != 0 )
	{
		contents |= 8;
	}
	ent setcontents( contents | 0x200000 );
	return ent;
}

cast_str_to_actor_spawner( str, noprint = false, allow_null_actor_spawner = false )
{
	spawners = getspawnerarray();

	return spawners[ 0 ];
}

load_actor()
{
	//ent = spawn_actor( actor_spawner, get_enemy_info, targetname );
	//ent load_entfields();
}

save_actor()
{

}

spawn_actor( actor_spawner, get_enemy_info, targetname )
{
	get_enemy_info = _DEFAULT( get_enemy_info, 0 );
	targetname = _DEFAULT( targetname, "" );
	actor = actor_spawner spawnactor( get_enemy_info, targetname );
	return actor;
}

cmd_spawnactor_f( target_obj, args )
{
	actor_spawner = args[ 0 ];

	actor = spawn_actor( actor_spawner, args[ 1 ], args[ 2 ] );
}

load_collision()
{
	//ent = spawn_collision( model, targetname, origin, angles );
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
	//ent = spawn_plane( classname, origin, spawnflags );
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
	//ent = spawn_helicopter( owner, origin, angles, vehicle_def_name, model );
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
	//ent = spawn_vehicle( model, targetname, vehicletype, origin, angles, destructible_name );
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
	//ent = spawn_turret( classname, origin, weapon );
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
	//ent = spawn_player_clone( player, death_anim_duration );
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
	//ent = spawn_path_node( classname, origin, angles, key1, val1, key2, val2, key3, val3 );
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
	//ent = spawn_fx( fx_id, origin, forward, up );
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
	//ent = spawn_timed_fx( weapon, origin, direction, time_seconds );
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
	//ent = spawn_napalm_ground_flame( origin, weapon, direction, time_seconds );
	//ent load_entfields();
}

save_napalm_ground_flame()
{

}

spawn_napalm_ground_flame( origin, weapon, direction, time_seconds )
{
	//ent = spawnnapalmgroundflame( origin, weapon, direction, time_seconds );
	
	//return ent;
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
	for ( i = 0; i < _SIZE( full_string.size ); i++ )
	{
		if ( full_string[ i ] == "(" || full_string[ i ] == ")" )
		{
			continue;
		}

		if ( full_string[ i ] == "." )
		{
			new_string += "@";
			continue;
		}

		new_string += full_string[ i ];
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

new_debug_hud( x, y_offset, multi_hud = false )
{
	if ( !multi_hud )
	{
		level.debug_hud_y_offset += y_offset;
	}
	hud = newClientHudElem( self );
	hud.alignx = "left";
	hud.aligny = "middle";
	hud.horzalign = "user_left";
	hud.vertalign = "user_bottom";
	hud.x += x;
	hud.y += level.debug_hud_y_offset;
	hud.fontscale = 1.4;
	hud.alpha = 1;
	hud.color = ( 1, 1, 1 );
	hud.hidewheninmenu = 1;
	hud.foreground = 1;

	return hud;
}

/*
get_mapents_vector( vector_str )
{
	final_vector_str = "";
	for ( i = 0; i < _SIZE( vector_str.size ); i++ )
	{
		if ( vector_str[ i ] == "(" || vector_str[ i ] == ")" || vector_str[ i ] == "," )
		{
			continue;
		}
		final_vector_str += vector_str[ i ];
	}

	return final_vector_str;
}
*/

get_mapents_vector( vector )
{
	mapents_vector_str = "\"" + vector[ 0 ] + " " + vector[ 1 ] + 90.0 + " " + vector[ 2 ] + "\""; // [1]+90 to handle player location offset

	return mapents_vector_str;
}

get_vector_filename( vector )
{
	vector_str = vector + "";

	final_vector_str = "";
	for ( i = 0; i < _SIZE( vector_str.size ); i++ )
	{
		if ( vector_str[ i ] == "(" || vector_str[ i ] == ")" )
		{
			continue;
		}

		if ( vector_str[ i ] == "," )
		{
			final_vector_str += "_";
			continue;
		}

		if ( vector_str[ i ] == "." )
		{
			final_vector_str += "-";
			continue;
		}

		final_vector_str += vector_str[ i ];
	}

	return final_vector_str;
}

dump_mapents_angles_key( fh, angles )
{
	angles_str = get_mapents_vector( angles );
	fs_writeline( fh, "\"angles\"" + " " + angles_str );
}

dump_mapents_origin_key( fh, origin )
{
	origin_str = get_mapents_vector( origin );
	fs_writeline( fh, "\"origin\"" + " " + origin_str );
}

dump_mapents_classname_key( fh, classname )
{
	fs_writeline( fh, "\"classname\"" + " " + "\"" + classname + "\"" );
}

// TODO: support script_gameobjectname space delimited array
dump_mapents_script_gameobjectname_key( fh, script_gameobjectname )
{
	fs_writeline( fh, "\"script_gameobjectname\"" + " " + "\"" + script_gameobjectname + "\"" );
}

dump_mapents_model_key( fh, model )
{
	fs_writeline( fh, "\"model\"" + " " + "\"" + model + "\"" );
}

dump_mapents_export_key( fh, export )
{
	fs_writeline( fh, "\"export\"" + " " + "\"" + export + "\"" );
}

dump_mapents_targetname_key( fh, targetname )
{
	fs_writeline( fh, "\"targetname\"" + " " + "\"" + targetname + "\"" );
}

dump_mapents_spawnflags_key( fh, spawnflags )
{
	fs_writeline( fh, "\"spawnflags\"" + " " + "\"" + spawnflags + "\"" );
}

dump_mapents_spawnpoint( classname, angles, origin )
{
	fh = level.spawnpoints_mapents_fh;

	fs_writeline( fh, "{" );
	level dump_mapents_classname_key( fh, classname );
	level dump_mapents_script_gameobjectname_key( fh, level.gametype );
	level dump_mapents_angles_key( fh, angles );
	level dump_mapents_origin_key( fh, origin );
	fs_writeline( fh, "}" );
}

dump_gsc_spawnpoint( classname, angles, origin )
{
	fh = level.spawnpoints_gsc_fh;

	func = "new_spawn = spawn( ";
	classname_arg = "\"" + classname + "\"" + "," + " ";
	origin_arg = origin + "," + " ";
	spawnflags_arg = "0" + "," + " ";
	angles_yaw_arg = angles[ 1 ] + "," + " ";
	unk_last_arg = "0" + " );";
	fs_writeline( fh, func + classname_arg + origin_arg + spawnflags_arg + angles_yaw_arg + unk_last_arg );
	new_spawn_script_gameobjectname_field = "new_spawn.script_gameobjectname = " + "\"" + level.gametype + "\"" + ";";
	fs_writeline( fh, new_spawn_script_gameobjectname_field );
}

dump_mapents_dog_actor_spawner( angles, origin )
{
	fh = level.spawnpoints_mapents_fh;
	spawner_classname = "actor_enemy_dog_mp";
	fs_writeline( fh, "{" );
	level dump_mapents_classname_key( fh, spawner_classname );
	level dump_mapents_script_gameobjectname_key( fh, level.gametype );
	level dump_mapents_angles_key( fh, angles );
	level dump_mapents_origin_key( fh, origin );
	level dump_mapents_model_key( fh, "tag_origin" );
	level dump_mapents_targetname_key( fh, "dog_spawner" );
	level dump_mapents_spawnflags_key( fh, "1" );
	fs_writeline( fh, "}" );
}

dump_mapents_minimap_corner( angles, origin )
{
	fh = level.spawnpoints_mapents_fh;
	fs_writeline( fh, "{" );
	level dump_mapents_classname_key( fh, "script_origin" );
	level dump_mapents_script_gameobjectname_key( fh, level.gametype );
	level dump_mapents_targetname_key( fh, "minimap_corner" );
	level dump_mapents_angles_key( fh, angles );
	level dump_mapents_origin_key( fh, origin );
	fs_writeline( fh, "}" );
}

// Perk Machine
/*
{
"origin" "326 9144 1128"
"model" "zombie_vending_doubletap2"
"classname" "script_struct"
"angles" "0 2.50448e-006 0"
"script_noteworthy" "specialty_rof"
"targetname" "zm_perk_machine"
"script_string" " zclassic_perks_prison"
"guid" "8A9A347E"
}
*/
dump_mapents_perk_machine( angles, origin, location, gametype, perk, modelm )
{
	fh = level.spawnpoints_mapents_fh;
	level dump_mapents_classname_key( fh, "script_origin" );
	level dump_mapents_script_gameobjectname_key( fh, level.gametype );
	level dump_mapents_targetname_key( fh, "minimap_corner" );
	level dump_mapents_angles_key( fh, angles );
	level dump_mapents_origin_key( fh, origin );
}

create_entity_location_screenshot( type, player_name, angles, origin, classname = undefined, location = undefined, gamemodegroup = undefined )
{
	classname = _DEFAULT( classname, undefined );
	angles_str = get_vector_filename( angles );
	origin_str = get_vector_filename( origin );

	screenshot_name = level.script + "_" + level.gametype + "_" + player_name + "_" + type + "_" + angles_str + "_" + origin_str;

	if ( isdefined( classname ) )
	{
		screenshot_name += "_" + classname;
	}

	if ( isdefined( location ) )
	{
		screenshot_name += "_" + location;
	}

	if ( isdefined( gamemodegroup ) )
	{
		screenshot_name += "_" + gamemodegroup;
	}
	
	level.players[ 0 ] iprintln( "Created screenshot of your location in the players folder!" );
	cmdexec( "screenshotJpeg " + screenshot_name );
}

/*
{
"classname" "trigger_radius"
"radius" "160"
"height" "128"
"targetname" "flag_primary"
"origin" "-2247 -457 -124.5"
"script_gameobjectname" "dom onslaught"
"model" "mp_flag_neutral"
"script_index" "3"
"script_label" "_c"
"guid" "142763D2"
}
{
"classname" "trigger_radius"
"radius" "160"
"height" "128"
"targetname" "flag_primary"
"origin" "3.5 18 -24"
"script_gameobjectname" "dom onslaught"
"model" "mp_flag_neutral"
"script_index" "2"
"script_label" "_b"
"guid" "8E4E74CD"
}
{
"script_index" "1"
"script_label" "_a"
"model" "mp_flag_neutral"
"script_gameobjectname" "dom onslaught"
"origin" "2220.5 493.5 -0.5"
"targetname" "flag_primary"
"height" "128"
"radius" "160"
"classname" "trigger_radius"
"guid" "9F776647"
}
{
"classname" "script_origin"
"script_linkto" "flag1 flag3"
"targetname" "flag_descriptor"
"script_linkname" "flag2"
"origin" "3.5 18 72"
"guid" "BB80AC82"
}
{
"classname" "script_origin"
"targetname" "flag_descriptor"
"script_linkname" "flag3"
"script_linkto" "flag2"
"origin" "-2247 -457 -30.5"
"guid" "FC178022"
}
{
"classname" "script_origin"
"script_linkname" "flag1"
"script_linkto" "flag2"
"targetname" "flag_descriptor"
"origin" "2220.5 493.5 99.5"
"guid" "E2C49D90"
}

*/


/*entity_string_obj_t*/ entity_string_obj_t_new( classname, origin, angles )
{
	entity_string_obj = generic_obj_t_new( "entity_string" );
	entity_string_obj.kvps = [];
	entity_string_obj.kvps[ "classname" ] = classname;
	entity_string_obj.kvps[ "origin" ] = origin;
	entity_string_obj.kvps[ "angles" ] = angles;
}


assign_editor_move_ent( target_entity )
{
	if ( !isdefined( target_entity._associated_ents ) )
	{
		target_entity._associated_ents = [];
	}

	if ( isdefined( target_entity.clip ) )
	{
		target_entity._associated_ents[ "clip" ] = target_entity.clip;
	}
	if ( isdefined( target_entity._perk_trigger ) )
	{
		target_entity._associated_ents[ "perk_trigger" ] = target_entity._perk_trigger;
	}
	if ( isdefined( target_entity.bump ) )
	{
		target_entity._associated_ents[ "bump" ] = target_entity.bump;
	}
	if ( isdefined( target_entity.blocker_model ) )
	{
		target_entity._associated_ents[ "blocker_model" ] = target_entity.blocker_model;
	}
}