#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;
#include scripts\cmd\core\_api_hud;
#include scripts\cmd\core\_utility_hud;

init_entity_helpers()
{
	level._mapents = [];
	level._mapents[ "player_spawns" ] = [];
	level._mapents[ "zombies_spawns" ] = [];
	level._mapents[ "path_nodes" ] = [];
	level._mapents[ "actor_spawners" ] = [];
	level._mapents[ "mystery_box_locations" ] = [];
	level._mapents[ "wallbuy_locations" ] = [];
	level._mapents[ "perk_machines" ] = [];

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

debug_line( from, to, color, time, depthtest )
{
	if ( !isdefined( time ) )
		time = 1000;

	if ( !isdefined( depthtest ) )
		depthtest = 1;

	line( from, to, color, 1, depthtest, time );
}

getmousepos()
{
	return ( 0, 0, 0 );
}

project2dto3d( x, y, znear )
{
	return ( 0, 0, 0 );
}

raycast_from_mouse_pos( scale )
{
	mouse_pos = self getmousepos();
	//mouse_pos = ( getdvarfloat( "mouse_pos_x" ), getdvarfloat( "mouse_pos_y" ), 0 );
	//print( "mouse_pos: x=" + mouse_pos[ 0 ] + " y=" + mouse_pos[ 1 ] + "\n" );

	//print( "znear_val1: " + znear_val1 + "\n" );
	//print( "znear_val2: " + znear_val2 + "\n" );
	unprojected_origin_to = self project2dto3d( mouse_pos[ 0 ], mouse_pos[ 1 ], 0.0 );
	unprojected_origin_from = self project2dto3d( mouse_pos[ 0 ], mouse_pos[ 1 ], 1.0 );
	//debugstar( unprojected_origin_to, 1000, ( 1, 0, 0 ), ( 1, 1, 1 ), "to" );
	//debugstar( unprojected_origin_from, 1000, ( 0, 0, 1 ), ( 1, 1, 1 ), "from" );
	direction = unprojected_origin_to - unprojected_origin_from;
	//print( "direction: " + direction + "\n" );
	dir_normalized = vectornormalize( direction );
	//print( "dir_normalized: " + dir_normalized + "\n" );
	//print( "unprojected_origin_to: x=" + unprojected_origin_to[ 0 ] + " y=" + unprojected_origin_to[ 1 ] + " z=" + unprojected_origin_to[ 2 ] + "\n" );
	//print( "unprojected_origin_from: x=" + unprojected_origin_from[ 0 ] + " y=" + unprojected_origin_from[ 1 ] + " z=" + unprojected_origin_from[ 2 ] + "\n" );
	//print( "self.origin: " + self.origin + "\n" );
	//print( "self geteye: " + self geteye() + "\n" );
	direction_vec = dir_normalized * scale;
	//print( "direction_vec: " + direction_vec + "\n" );

	trace = [];
	trace[ 0 ] = unprojected_origin_from;
	trace[ 1 ] = unprojected_origin_from + direction_vec;
	return trace;
}

cast_entity_raycast_from_player_mouse_pos()
{
	ray = self raycast_from_mouse_pos( 8000 );
	trace = bullettrace( ray[ 0 ], ray[ 1 ], false, undefined );

	//debug_line( ray[ 0 ], trace[ "position" ], ( 0, 0, 1 ), 100 );

	if ( !isdefined( trace[ "entity" ] ) )
	{
		trace = physicstrace( ray[ 0 ], ray[ 1 ], vectorscale( ( -1, -1, 0 ), 15.0 ), vectorscale( ( 1, 1, 0 ), 15.0 ), self, level._editor_ent_mask );

		//debug_line( ray[ 0 ], trace[ "position" ], ( 1, 0, 0 ), 100 );
		if ( !isdefined( trace[ "entity" ] ) )
		{
			return trace;
		}
	}

	return trace;
}

cast_non_entity_raycast_from_player_mouse_pos()
{
	ray = self raycast_from_mouse_pos( 8000 );

	debug_line( ray[ 0 ], ray[ 1 ], ( 0, 0, 1 ), 100 );

	if ( _ARRAY_VALIDATE( level._mapents[ "path_nodes" ] ) )
	{
		foreach ( node in level._mapents[ "path_nodes" ] )
		{
			radial_origin = pointonsegmentnearesttopoint( ray[ 0 ], ray[ 1 ], node.origin );

			if ( distancesquared( node.origin, radial_origin ) < 100 * 100 )
			{
				return node;
			}
		}
	}
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

// maybe budget only 32 per ent
add_change_history( entfield_name, old_value, new_value )
{
	if ( !isdefined( self._change_history ) )
	{
		self._change_history = [];
	}

	if ( !isdefined( level._change_history ) )
	{
		level._change_history = [];
	}

	hist_obj = spawnstruct();
	hist_obj.field = entfield_name;
	hist_obj.value = new_value;

	limit = get_dvar_int_default( "editor_ent_history_limit", 32 );
	limit = clamp( limit, 0, 1024 );
	while ( _SIZE( self._change_history.size ) > limit )
	{
		// remove oldest
		arrayremoveindex( self._change_history, 0 );
	}

	self._change_history[ self._change_history.size ] = hist_obj;
	if ( !isinarray( level._change_history, self ) )
	{
		level._change_history[ level._change_history.size ] = self;
	}
}

set_entfield_relative( entfield_name, new_value, scale )
{
	scale = _DEFAULT( scale, 1.0 );
	result_obj = generic_obj_t_new( "entfield" );
	if ( isdefined( self._entfield_custom_callback ) )
	{
		result_obj = self [[ self._entfield_custom_callback ]]( entfield_name, new_value, true, scale );
		if ( result_obj.errored )
		{
			return result_obj;
		}
		if ( !result_obj.pass )
		{
			self add_change_history( entfield_name, new_value );

			return set_cast_success( result_obj, self, "Successfully set: " + entfield_name + " to value: " + new_value );
		}
	}

	vector_cast = cast_str_to_type( new_value, "vector" );
	int_cast = cast_str_to_type( new_value, "int" );
	float_cast = cast_str_to_type( new_value, "float" );
	str_cast = new_value;
	switch ( entfield_name )
	{
		case "classname":
		case "spawnflags":
		case "birthtime":
			return set_cast_error( result_obj, "'{}' is read only!", entfield_name );
		case "model":
		case "target":
		case "targetname":
		case "script_noteworthy":
			return set_cast_error( result_obj, "'{}' cannot be changed relatively!", entfield_name );
		case "count":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self.count += int( int_cast.value * scale );
			break;
		case "health":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self.health += int( int_cast.value * scale );
			break;
		case "dmg":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self.dmg += int( int_cast.value * scale );
			break;
		case "index":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self.index += int( int_cast.value * scale );
			break;
		case "lerp_to_lighter":
			if ( float_cast.errored )
			{
				return float_cast;
			}
			self.lerp_to_lighter += float_cast.value * scale;
			break;
		case "lerp_to_dark":
			if ( float_cast.errored )
			{
				return float_cast;
			}
			self.lerp_to_dark += float_cast.value * scale;
			break;
		case "origin":
			if ( vector_cast.errored )
			{
				return vector_cast;
			}
			vector_origin = vector_cast.value * scale;
			self.origin += vector_origin;
			break;
		case "angles":
			if ( vector_cast.errored )
			{
				return vector_cast;
			}
			vector_angles += vector_cast.value * scale;
			self.angles = vector_angles;
			break;
		default:
			//TODO: handle radiant/keys.txt here...
			if ( isdefined( self._entfield_custom_handler ) )
			{
				result_obj = self [[ self._entfield_custom_handler ]]( entfield_name, new_value, true, scale );
				return result_obj;
			}

			return set_cast_error( result_obj, "'{}' is unsupported!", entfield_name );
	}

	self add_change_history( entfield_name, new_value );

	return set_cast_success( result_obj, new_value, "Successfully set: '{}' to value: '{}'", entfield_name, new_value );
}

set_entfield( entfield_name, new_value )
{
	result_obj = generic_obj_t_new( "entfield" );

	if ( isdefined( self._entfield_custom_callback ) )
	{
		result_obj = self [[ self._entfield_custom_callback ]]( entfield_name, new_value, false );
		if ( result_obj.errored )
		{
			return result_obj;
		}
		if ( !result_obj.pass )
		{
			self add_change_history( entfield_name, new_value );

			return set_cast_success( result_obj, self, "Successfully set: '{}' to value: '{}'", entfield_name, new_value );
		}
	}

	vector_cast = cast_str_to_type( new_value, "vector" );
	int_cast = cast_str_to_type( new_value, "int" );
	float_cast = cast_str_to_type( new_value, "float" );
	str_cast = new_value;
	switch ( entfield_name )
	{
		case "classname":
		case "spawnflags":
		case "birthtime":
			return set_cast_error( result_obj, "'{}' is read only!", entfield_name );
		case "model":
			if ( !_MODEL_EXISTS( str_cast ) )
			{
				return set_cast_error( result_obj, "Model '{}' is not precached, cannot set model", str_cast );
			}
			self setmodel( str_cast );
			break;
		case "target":
			self.target = str_cast;
			break;
		case "targetname":
			self.targetname = str_cast;
			break;
		case "script_noteworthy":
			self.script_noteworthy = str_cast;
			break;
		case "count":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self.count = int_cast.value;
			break;
		case "health":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self.health = int_cast.value;
			break;
		case "dmg":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self.dmg = int_cast.value;
			break;
		case "index":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self.index = int_cast.value;
			break;
		case "lerp_to_lighter":
			if ( float_cast.errored )
			{
				return float_cast;
			}
			self.lerp_to_lighter = float_cast.value;
			break;
		case "lerp_to_dark":
			if ( float_cast.errored )
			{
				return float_cast;
			}
			self.lerp_to_dark = float_cast.value;
			break;
		case "origin":
			if ( vector_cast.errored )
			{
				return vector_cast;
			}
			self.origin = vector_cast.value;
			break;
		case "angles":
			if ( vector_cast.errored )
			{
				return vector_cast;
			}
			self.angles = vector_cast.value;
			break;
		case "takedamage":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self setcandamage( int_cast.value );
			break;
		case "contents":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self setcontents( int_cast.value );
			break;
		case "solid":
			self solid();
			break;
		case "notsolid":
			self notsolid();
			break;
		case "setcheapflag":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self setcheapflag( int_cast.value );
			break;
		case "ignorecheapentityflag":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self ignorecheapentityflag( int_cast.value );
			break;
		case "setzombieshrink":
			if ( int_cast.errored )
			{
				return int_cast;
			}
			self setzombieshrink( int_cast.value );
			break;
		default:
			if ( isdefined( self._entfield_custom_handler ) )
			{
				result_obj = self [[ self._entfield_custom_handler ]]( entfield_name, new_value, false );
				return result_obj;
			}
			return set_cast_error( result_obj, "'{}' is unsupported!", entfield_name );
	}

	self add_change_history( entfield_name, new_value );

	return set_cast_success( result_obj, self, "Successfully set: '{}' to value: '{}'", entfield_name, new_value );
}

get_entfield( entfield_name )
{
	result_obj = generic_obj_t_new( "entfield" );
	switch ( entfield_name )
	{
		case "classname":
			return set_cast_success( result_obj, self.classname, "classname=='{}'", self.classname );
		case "spawnflags":
			return set_cast_success( result_obj, self.spawnflags, "spawnflags=='{}'", self.spawnflags );
		case "birthtime":
			return set_cast_success( result_obj, self.birthtime, "birthtime=='{}'", self.birthtime );
		case "model":
			return set_cast_success( result_obj, self.model, "model=='{}'", self.model );
		case "target":
			return set_cast_success( result_obj, self.target, "target=='{}'", self.target );
		case "targetname":
			return set_cast_success( result_obj, self.targetname, "targetname=='{}'", self.targetname );
		case "script_noteworthy":
			return set_cast_success( result_obj, self.script_noteworthy, "script_noteworthy=='{}'", self.script_noteworthy );
		case "count":
			return set_cast_success( result_obj, self.count, "count=='{}'", self.count );
		case "health":
			return set_cast_success( result_obj, self.health, "health=='{}'", self.health );
		case "dmg":
			return set_cast_success( result_obj, self.dmg, "dmg=='{}'", self.dmg );
		case "index":
			return set_cast_success( result_obj, self.index, "index=='{}'", self.index );
		case "lerp_to_lighter":
			return set_cast_success( result_obj, self.lerp_to_lighter, "lerp_to_lighter=='{}'", self.lerp_to_lighter );
		case "lerp_to_dark":
			return set_cast_success( result_obj, self.lerp_to_dark, "lerp_to_dark=='{}'", self.lerp_to_dark );
		case "origin":
			return set_cast_success( result_obj, self.origin, "origin=='{}'", self.origin );
		case "angles":
			return set_cast_success( result_obj, self.angles, "angles=='{}'", self.angles );
		case "contents":
			old_contents = self setcontents( 1 );
			self setcontents( old_contents );
			return set_cast_success( result_obj, old_contents, "contents=='{}'", old_contents );
		case "centroid":
			centroid = self getcentroid();
			return set_cast_success( result_obj, centroid, "centroid=='{}'", centroid );
		case "mins":
			mins = self getmins();
			return set_cast_success( result_obj, mins, "mins=='{}'", mins );
		case "maxs":
			maxs = self getmaxs();
			return set_cast_success( result_obj, maxs, "maxs=='{}'", maxs );
		case "absmins":
			absmins = self getabsmins();
			return set_cast_success( result_obj, absmins, "absmins=='{}'", absmins );
		case "absmaxs":
			absmaxs = self getabsmaxs();
			return set_cast_success( result_obj, absmaxs, "absmaxs=='{}'", absmaxs );
		case "velocity":
			velocity = self getvelocity();
			return set_cast_success( result_obj, velocity, "velocity=='{}'", velocity );
		case "takedamage":
		default:
			return set_cast_error( result_obj, "'{}' is unsupported!", entfield_name );
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

save_entity( optional_keys )
{
	required_keys = _DEFAULT( self._optional_keys, [] );
	required_keys[ "origin" ] = self.origin;
	required_keys[ "angles" ] = self.angles;
	required_keys[ "classname" ] = self.classname;

	//write_gsc( required_keys );
	//write_mapents( required_keys );
}

spawn_script_origin( origin, spawnflags )
{
	ent = spawn( "script_origin", origin, spawnflags );
	return ent;
}

spawn_script_model( origin, spawnflags )
{
	//#define SPAWNFLAG_MODEL_DYNAMIC_PATH 1
	ent = spawn( "script_model", origin, spawnflags );
	return ent;
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

spawn_path_node( classname, origin, angles, key1, val1, key2, val2, key3, val3 )
{
	ent = undefined;
	if ( isdefined( key3 ) )
	{
		//ent = spawnpathnode( classname, origin, angles, key1, val1, key2, val2, key3, val3 );
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

get_mapents_vector( vector )
{
	mapents_vector_str = "\"" + vector[ 0 ] + " " + vector[ 1 ] + " " + vector[ 2 ] + "\"";

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

dump_mapents_kvp( fh, key, val )
{
	if ( isint( val ) || isfloat( val ) || isstring( val ) )
	{
		fs_writeline( fh, "\"" + key + "\"" + " " + "\"" + val + "\"" );
	}
	else if ( isvec( val ) )
	{
		vec_str = get_mapents_vector( val );
		fs_writeline( fh, "\"" + key + "\"" + " " + "\"" + vec_str + "\"" );
	}
}

dump_gsc_kvp( fh, ent_var_name, key, val )
{
	if ( isstring( val ) )
	{
		fs_writeline( fh, ent_var_name + "." + key + " = " + "\"" + val + "\"" );
	}
	else
	{
		fs_writeline( fh, ent_var_name + "." + key + " = " + val );
	}

	fs_writeline( fh, ";\n" );
}

generate_mapents_spawnpoint( classname, angles, origin )
{
	fh = level.spawnpoints_mapents_fh;

	fs_writeline( fh, "{" );
	//level dump_mapents_classname_key( fh, classname );
	//level dump_mapents_angles_key( fh, angles );
	//level dump_mapents_origin_key( fh, origin );
	fs_writeline( fh, "}" );
}

generate_gsc_spawnpoint( classname, angles, origin )
{
	fh = level.spawnpoints_gsc_fh;

	args = array( classname, origin, 0, angles[ 1 ], 0 );
	dump_gsc_func_call( fh, "spawn", args, "new_spawnpoint" );
	dump_gsc_kvp( fh, "new_spawnpoint", "script_gameobjectname", level.gametype );
}

dump_gsc_func_call( fh, func, args, return_val )
{
	if ( isdefined( return_val ) )
	{
		fs_writeline( fh, return_val + " = " );
	}

	fs_writeline( fh, func );
	fs_writeline( fh, "( " );
	for ( i = 0; i < args.size; i++ )
	{
		if ( isstring( args[ i ] ) )
		{
			fs_writeline( fh, "\"" + args[ i ] + "\"" );
		}
		else
		{
			fs_writeline( fh, args[ i ] );
		}

		if ( ( i + 1 ) < args.size )
		{
			fs_writeline( fh, ", " );
		}
	}

	fs_writeline( fh, " );\n" );
}

generate_dog_actor_spawner( angles, origin )
{
	fh = level.spawnpoints_mapents_fh;
	fs_writeline( fh, "{" );
	level dump_mapents_kvp( fh, "classname", "actor_enemy_dog_mp" );
	level dump_mapents_kvp( fh, "angles", angles );
	level dump_mapents_kvp( fh, "origin", origin );
	level dump_mapents_kvp( fh, "model", "tag_origin" );
	level dump_mapents_kvp( fh, "targetname", "dog_spawner" );
	level dump_mapents_kvp( fh, "spawnflags", 1 );
	fs_writeline( fh, "}" );
}

generate_minimap_corner( keys )
{
	fh = level.spawnpoints_mapents_fh;
	fs_writeline( fh, "{" );
	level dump_mapents_kvp( fh, "classname", "script_origin" );
	level dump_mapents_kvp( fh, "targetname", "minimap_corner" );
	level dump_mapents_kvp( fh, "angles", keys[ "angles" ] );
	level dump_mapents_kvp( fh, "origin", keys[ "origin" ] );
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