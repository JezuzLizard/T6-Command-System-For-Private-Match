#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd_system_modules\_hud;

init()
{
	level.spawnpoints_mapents_fh = fs_fopen( "spawns_" + getdvar( "mapname" ) + ".mapents", "append" );
	level.spawnpoints_gsc_fh = fs_fopen( "spawns_" + getdvar( "mapname" ) + ".gsc", "append" );
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
	for ( i = 0; i < vector_str.size; i++ )
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
	for ( i = 0; i < vector_str.size; i++ )
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



cmd_dumpent_f( args )
{
	type = args[ 0 ];
	classname = args[ 1 ];
	description = args[ 2 ];
	player = self;
	fh = level.spawnpoints_mapents_fh;

	result = undefined;
	valid_type = false;
	switch ( type )
	{
		case "dogs":
			valid_type = true;
			result = result_cmdinfo( "Successfully added a dog spawner!" );
			break;

		case "minimap":
			valid_type = true;
			result = result_cmdinfo( "Successfully added a minimap corner!" );
			break;

		case "player_spawn":
			if ( !isdefined( classname ) )
			{
				return result_cmderror( "player_spawn type requires a classname!" );
			}

			valid_type = true;
			result = result_cmdinfo( "Successfully added a player spawnpoint!" );
			break;
	}

	if ( valid_type )
	{
		switch ( type )
		{
			case "dogs":
				level dump_mapents_dog_actor_spawner( player.angles, player.origin );
				break;

			case "minimap":
				level dump_mapents_minimap_corner( player.angles, player.origin );
				break;

			case "player_spawn":
				level dump_gsc_spawnpoint( classname, player.angles, player.origin );
				level dump_mapents_spawnpoint( classname, player.angles, player.origin );
				break;
		}
		create_entity_location_screenshot( type, player.name, player.angles, player.origin, classname );
		return result;
	}
	else
	{
		return result_cmderror( "Type " + type + " is unsupported!" );
	}
}

cmd_createcamera_f( args )
{
	camera_name = args[ 0 ];
	player = self;
	if ( isdefined( self._cmds_cameras[ camera_name ] ) )
	{
		self._cmds_cameras[ camera_name ] delete();
	}
	camera_ent = spawn( "script_model", self.origin );
	camera_ent.angles = self.angles;
	camera_ent setmodel( "tag_origin" );
	camera_ent.camera_name = camera_name;

	self._cmds_cameras[ camera_name ] = camera_ent;

	return result_cmdinfo( "Created a camera named: '" + camera_name + "' at: '" + self.origin + "' with angles: '" + self.angles + "'" );
}

cmd_setcamera_f( args )
{
	camera_name = args[ 0 ];
	camera_flags = _DEFAULT( args[ 1 ], 1 );
	
	player = self;
	camera_ent = self._cmds_cameras[ camera_name ];
	if ( isdefined( camera_ent ) )
	{
		player camerasetposition( camera_ent );
		player camerasetlookat();
		player cameraactivate( camera_flags );

		return result_cmdinfo( "Set camera lookat to a camera named: '" + camera_name + "' at: '" + self.origin + "' with angles: '" + self.angles + "'" );
	}
	else
	{
		return result_cmderror( "No camera with name '" + camera_name + "' exists!" );
	}
}

cmd_unsetcamera_f( args )
{
	player = self;
	player cameraactivate( 0 );
	camera_name = args[ 0 ];

	return result_cmdinfo( "Set camera lookat to a camera named: '" + camera_name + "' at: '" + self.origin + "' with angles: '" + self.angles + "'" );
}

cmd_deletecamera_f( args )
{
	camera_name = args[ 0 ];
	camera_flags = args[ 1 ];
	player = self;

	camera_ent = self._cmds_cameras[ camera_name ];
	if ( isdefined( camera_ent ) )
	{
		return result_cmdinfo( "Deleted camera lookat for a camera named: '" + camera_name + "' at: '" + self.origin + " with angles: '" + self.angles + "'" );
	}
	else
	{
		return result_cmderror( "No camera with name '" + camera_name + "' exists!" );
	}
}
// GScr_PhysicsTrace masks
/*
	level.physicstracemaskphysics = 1;
	level.physicstracemaskvehicle = 2;
	level.physicstracemaskwater = 4;
	level.physicstracemaskclip = 8;
	level.physicstracecontentsvehicleclip = 16;
*/
cmd_seteditortargetent_f( args )
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
			return result_cmderror( "Not looking at an entity!" );
		}
	}

	editor_ent = self hud_binding_subscribe_to_entity( "editor_ent_context", trace[ "entity" ] );
	return result_cmdinfo( "Selected target entity: " + editor_ent.classname );
}

cmd_seteditortargetangles_f( args )
{
	editor_ent = self hud_binding_get_subscribed_entity( "editor_ent_context" );
	if ( !isdefined( editor_ent ) )
	{
		return result_cmderror( "No target entity selected!" );
	}

	new_angles = args[ 0 ];
	is_relative = args[ 1 ];

	if ( is_true( is_relative ) )
	{
		editor_ent.angles += new_angles;
	}
	else
	{
		editor_ent.angles = new_angles;
	}

	return result_cmdinfo( "Set angles of target entity: '" + editor_ent.classname + "' to: '" + new_angles + "'" );
}

cmd_seteditortargetorigin_f( args )
{
	editor_ent = self hud_binding_get_subscribed_entity( "editor_ent_context" );
	if ( !isdefined( editor_ent ) )
	{
		return result_cmderror( "No target entity selected!" );
	}

	new_origin = args[ 0 ];
	is_relative = args[ 1 ];

	if ( is_true( is_relative ) )
	{
		editor_ent.origin += new_origin;
	}
	else
	{
		editor_ent.origin = new_origin;
	}

	return result_cmdinfo( "Set origin of target entity: '" + editor_ent.classname + "' to: '" + new_origin + "'" );
}

cmd_setviewpos_f( args )
{
	self com_printerror( "UNIMPLEMENTED" );
}

cmd_editheldmodel_f( args )
{
	editor_held_ent = self hud_binding_get_subscribed_entity( "editor_held_context" );
	model = _DEFAULT( args[ 0 ], "null" );
	carry_offset = _DEFAULT( args[ 1 ], ( 22, 0, 0 ) );
	carry_angles = _DEFAULT( args[ 2 ], ( 0, 0, 0 ) );

	if ( !isdefined( editor_held_ent ) )
	{
		return result_cmderror( "Cannot set model on held model, you are not holding a model!" );
	}

	if ( !isdefined( args[ 0 ] ) && !isdefined( args[ 1 ] ) && !isdefined( args[ 2 ] ) )
	{
		return result_cmderror( "No arguments, no changes..." );
	}

	self stopcarryturret( editor_held_ent );
	editor_held_ent setturretcarried( false );
	if ( model != "null" )
	{
		editor_held_ent setmodel( model );
	}
	
	editor_held_ent setturretcarried( true );
	self carryturret( editor_held_ent, carry_offset, carry_angles );

	return result_cmdinfo( "Successfully set your carried model to " + model );
}

cmd_editorspawnheldmodel_f( args )
{
	ent_name = args[ 0 ];
	model = args[ 1 ];
	carry_offset = _DEFAULT( args[ 2 ], ( 22, 0, 0 ) );
	carry_angles = _DEFAULT( args[ 3 ], ( 0, 0, 0 ) );

	editor_held_ent = self hud_binding_get_subscribed_entity( "editor_held_context" );
	if ( isdefined( editor_held_ent ) )
	{
		return result_cmderror( "You are already holding a model!" );
	}

	self thread editor_spawn_held_model_thread( ent_name, model, carry_offset, carry_angles );

	return result_cmdinfo( "Successfully set your carried model to " + model );
}

editor_spawn_held_model_thread( ent_name, model, carry_offset, carry_angles )
{
	placeturret = spawnturret( "auto_turret", self.origin, "equip_turbine_zm_turret" );
	placeturret.angles = self.angles;
	placeturret setmodel( model );
	placeturret setturretcarried( true );
	placeturret setturretowner( self );

	self carryturret( placeturret, carry_offset, carry_angles );

	self.is_holding_model = true;
	hud_binding_obj = self hud_binding_subscribe_to_entity( "editor_held_context", placeturret );

	held_ent = self hud_binding_get_subscribed_entity( "editor_held_context" );
	for ( ;; )
	{
		self notifyonplayercommand( "toggle_unlink", "+speed_throw" );
		ended = self waittill_any_return( "toggle_unlink" );

		if ( !( isdefined( level.use_legacy_equipment_placement ) && level.use_legacy_equipment_placement ) )
			turret_placement = self canplayerplaceturret( held_ent );

		if ( turret_placement[ "result" ] )
		{
			new_ent = spawn( "script_model", turret_placement[ "origin" ] );
			new_ent.angles = turret_placement[ "angles" ];
			new_ent setmodel( held_ent.model );

			if ( isdefined( self._editor_placed_ents[ ent_name ] ) )
			{
				self._editor_placed_ents[ ent_name ] delete();
			}
			self._editor_placed_ents[ ent_name ] = new_ent;

			break;
		}
	}

	self stopcarryturret( held_ent );
	held_ent setturretcarried( false );
	held_ent delete();

	self.is_holding_model = false;
}

cmd_editorspawn_f( args )
{

}

live_pickup_adjust_preview( placeturret, carry_offset, carry_angles )
{
	
}

editor_pickup_model_thread( original_ent, carry_offset, carry_angles )
{
	original_ent hide(); // we haven't actually moved the entity yet, we are actually picking up a copy of the model aka "preview"

	placeturret = spawnturret( "auto_turret", self.origin, "equip_turbine_zm_turret" );
	placeturret.angles = self.angles;
	placeturret setmodel( original_ent.model );
	placeturret setturretcarried( true );
	placeturret setturretowner( self );

	self carryturret( placeturret, carry_offset, carry_angles );

	self.is_holding_model = true;
	hud_binding_obj = self hud_binding_subscribe_to_entity( "editor_held_context", placeturret );
	held_ent = self hud_binding_get_subscribed_entity( "editor_held_context" );

	for ( ;; )
	{
		self notifyonplayercommand( "toggle_unlink", "+speed_throw" );
		ended = self waittill_any_return( "toggle_unlink" );

		if ( !( isdefined( level.use_legacy_equipment_placement ) && level.use_legacy_equipment_placement ) )
			turret_placement = self canplayerplaceturret( held_ent );

		if ( turret_placement[ "result" ] )
		{
			original_ent.angles = turret_placement[ "angles" ];
			original_ent.origin = turret_placement[ "origin" ];
			original_ent show();
			break;
		}
	}

	self stopcarryturret( held_ent );
	held_ent setturretcarried( false );
	held_ent delete();

	self.is_holding_model = false;
}

cmd_editorpickup_f( args )
{
	target_entity = args[ 0 ];
	carry_offset = _DEFAULT( args[ 1 ], ( 22, 0, 0 ) );
	carry_angles = _DEFAULT( args[ 2 ], ( 0, 0, 0 ) );

	if ( is_true( self.is_holding_model ) )
	{
		return result_cmderror( "You are already holding a model!" );
	}

	if ( !isdefined( target_entity ) )
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
				return result_cmderror( "Not looking at an entity!" );
			}
		}

		target_entity = trace[ "entity" ];
	}

	self thread editor_pickup_model_thread( target_entity, carry_offset, carry_angles );
	return result_cmdinfo( "Picked up target entity: " + target_entity.classname );
}

cmd_editorcontextmodifyentity_f( args )
{
	scale = args[ 0 ];
	total_time = _DEFAULT( args[ 1 ], 0.1 );
	accel_time = _DEFAULT( args[ 2 ], 0.05 );
	decel_time = _DEFAULT( args[ 3 ], 0.05 );

	if ( scale == 0.0 )
	{
		return result_cmderror( "<scale> cannot be 0!" );
	}

	editor_context = self hud_binding_get( "editor_mode_context" );
	if ( editor_context.binding_val == "none" )
	{
		return result_cmderror( "You must set the context using the command 'editorsetmodifycontext' first!" );
	}

	base_delta = 1;
	delta = base_delta * scale;
	ent = self.editor_modify_context_ent;
	switch ( editor_context )
	{
		case "pitch":
			ent rotateto( ent.angles + ( delta, 0, 0 ), total_time, accel_time, decel_time );
			break;
		case "yaw":
			ent rotateto( ent.angles + ( 0, delta, 0 ), total_time, accel_time, decel_time );
			break;
		case "roll":
			ent rotateto( ent.angles + ( 0, 0, delta ), total_time, accel_time, decel_time );
			break;
		case "x":
			ent moveto( ent.origin + ( delta, 0, 0 ), total_time, accel_time, decel_time );
			break;
		case "y":
			ent moveto( ent.origin + ( 0, delta, 0 ), total_time, accel_time, decel_time );
			break;
		case "z":
			ent moveto( ent.origin + ( 0, 0, delta ), total_time, accel_time, decel_time );
			break;
		default:
			return result_cmderror( "<context> must be one of 'pitch', 'yaw', 'roll', 'x', 'y', 'z'!" );
	}
}

cmd_editorsetmodifycontext_f( args )
{
	context = args[ 0 ];

	switch ( context )
	{
		case "pitch":
			break;
		case "yaw":
			break;
		case "roll":
			break;
		case "x":
			break;
		case "y":
			break;
		case "z":
			break;
		case "none":
			break;
		default:
			return result_cmderror( "<context> must be one of 'pitch', 'yaw', 'roll', 'x', 'y', 'z'!" );
	}
	
	self hud_binding_set( "editor_mode_context", context );
}

on_editor_connect()
{
	self thread editor_hud();
}

editor_hud()
{
	self endon( "disconnect" );

	if ( !isdefined( self._cmds_cameras ) )
	{
		self._cmds_cameras = [];
	}

	if ( !isdefined( self._editor_placed_ents ) )
	{
		self._editor_placed_ents = [];
	}

	self hud_binding_register( "editor_mode_context", "text", "edit_mode", "No editor context!" );
	self hud_binding_register( "editor_ent_context", "entity", "selected_entity", "No selected entity!" );
	self hud_binding_register( "editor_held_context", "entity", "held_entity", "No held entity!" );
	self hud_binding_register( "editor_placed_context", "entity", "placed_entities", "No placed entities!" );

	vertical_hud_list_obj = vertical_text_list_create( 20, 1.0, "objective", 1.8, "left", "top", "user_left", "user_top" );
	vertical_hud_list_obj set_alpha( 1, 1.0 );

	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_mode_context" );
	//fontelem settext( "GRUS1" );
	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_ent_context" );
	//fontelem settext( "GRUS2" );
	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_held_context" );
	//fontelem settext( "GRUS3" );

	self thread hud_bindings_update_loop();
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

	level.physicstracemaskphysics = 1;
	level.physicstracemaskvehicle = 2;
	level.physicstracemaskwater = 4;
	level.physicstracemaskclip = 8;
	level.physicstracecontentsvehicleclip = 16;
	level._editor_ent_mask = level.physicstracemaskphysics | level.physicstracemaskvehicle | level.physicstracemaskwater | level.physicstracemaskclip;

	cmd_block_set_rank_group( "cheat" );
	dumpent_cmd = level [[ level.tcs_add_cmd_func ]]( "dumpent", true, "dent", "dumpent <type> [classname]", ::cmd_dumpent_f );
	dumpent_cmd arg_obj_add_cmd( "string string", 1, 2 );

	// camera commands
	createcamera_cmd = level [[ level.tcs_add_cmd_func ]]( "createcamera", true, "createcam", "createcamera <name>", ::cmd_createcamera_f );
	createcamera_cmd arg_obj_add_cmd( "string", 1, 1 );

	setcamera_cmd = level [[ level.tcs_add_cmd_func ]]( "setcamera", true, "setcam", "setcamera <name> [flags]", ::cmd_setcamera_f );
	setcamera_cmd arg_obj_add_cmd( "string cameraflags", 1, 2 );

	unsetcamera_cmd = level [[ level.tcs_add_cmd_func ]]( "unsetcamera", true, "unsetcam", "unsetcamera <name>", ::cmd_unsetcamera_f );
	unsetcamera_cmd arg_obj_add_cmd( "string", 1, 1 );

	deletecamera_cmd = level [[ level.tcs_add_cmd_func ]]( "deletecamera", true, "delcam", "deletecamera <name>", ::cmd_deletecamera_f );
	deletecamera_cmd arg_obj_add_cmd( "string", 1, 1 );

	// entity manipulation
	seteditortargetent_cmd = level [[ level.tcs_add_cmd_func ]]( "seteditortargetent", true, "seteditent", "seteditortargetent [entnum]", ::cmd_seteditortargetent_f );
	seteditortargetent_cmd arg_obj_add_cmd( "entity", 0, 1 );

	seteditortargetangles_cmd = level [[ level.tcs_add_cmd_func ]]( "seteditortargetangles", true, "seteditangles", "seteditortargetangles <angles> [relative]", ::cmd_seteditortargetangles_f );
	seteditortargetangles_cmd arg_obj_add_cmd( "vector boolean", 1, 2 );

	seteditortargetorigin_cmd = level [[ level.tcs_add_cmd_func ]]( "seteditortargetorigin", true, "seteditorigin", "seteditortargetorigin <pos> [relative]", ::cmd_seteditortargetorigin_f );
	seteditortargetorigin_cmd arg_obj_add_cmd( "vector boolean", 1, 2 );

	editheldmodel_cmd = level [[ level.tcs_add_cmd_func ]]( "editheldmodel", true, "editheldmodel", "editheldmodel [model] [carry_origin_offset] [carry_angles_offset]", ::cmd_editheldmodel_f );
	editheldmodel_cmd arg_obj_add_cmd( "model vector vector", 0, 3 );

	editorspawnheldmodel_cmd = level [[ level.tcs_add_cmd_func ]]( "editorspawnheldmodel", true, "spawnheld", "editorspawnheldmodel <ent_name> <model> [carry_origin_offset] [carry_angles_offset]", ::cmd_editorspawnheldmodel_f );
	editorspawnheldmodel_cmd arg_obj_add_cmd( "string model vector vector", 2, 4 );

	editorpickup_cmd = level [[ level.tcs_add_cmd_func ]]( "editorpickup", true, "pickup", "editorpickup [entnum] [carry_origin_offset] [carry_angles_offset]", ::cmd_editorpickup_f );
	editorpickup_cmd arg_obj_add_cmd( "entity vector vector", 0, 3 );

	editorcontextmodifyentity_cmd = level [[ level.tcs_add_cmd_func ]]( "editorcontextmodifyentity", true, undefined, "editorcontextmodifyentity <direction>", ::cmd_editorcontextmodifyentity_f );
	editorcontextmodifyentity_cmd arg_obj_add_cmd( "string", 1, 1 );
	// TODO:
	//setmins
	//setmaxs
	//show/hide/ghost
	//print/display existing values
	//THE LINES
	//spawn command
	//setcontents
	//disconnectpaths/connectpaths
	//attach/detach
	//set/get tags
	//setanim
	//setasd
	//setentityanimrate
	//startragdoll
	//physicslaunch
	//setzombiename
	//setteam
	//setowner
	//setphysparams
	//setplayercollision
	//setvelocity
	//rotateto
	//moveto
	//spawnactor
	//magicbullet
	//magicgrenade
	//makeusable
	//makeunusable
	//spawnturret
	//setworldactivefogbank
	//hidezbarrierpiece/showzbarrierpiece/setzbarrierpiecestate/zbarrierpieceusedefaultmodel/zbarrierpieceusealternatemodel/zbarrierpieceuseupgradedmodel/zbarrierpieceuseboxriselogic
	//setzbarriercolmodel
	//setweaponoptions
	//setviewmodel
	//clientsyssetstate
	//initialweaponraise
	//kill
	//cloneplayer
	//carryturret
	// all of these
	/*
		const BuiltinMethodDef methods_2[22] =
		{
			{ "moveto", 1130u, 2, 4, &ScriptEntCmd_MoveTo, 0 },
			{ "movex", 1131u, 2, 4, &ScriptEntCmd_MoveX, 0 },
			{ "movey", 1132u, 2, 4, &ScriptEntCmd_MoveY, 0 },
			{ "movez", 1133u, 2, 4, &ScriptEntCmd_MoveZ, 0 },
			{ "movegravity", 1126u, 2, 2, &ScriptEntCmd_GravityMove, 0 },
			{ "moveslide", 1129u, 3, 3, &ScriptEntCmd_MoveSlide, 0 },
			{ "stopmoveslide", 1924u, 0, 0, &ScriptEntCmd_StopMoveSlide, 0 },
			{ "rotateto", 1395u, 2, 4, &ScriptEntCmd_RotateTo, 0 },
			{ "rotatepitch", 1392u, 2, 4, &ScriptEntCmd_RotatePitch, 0 },
			{ "rotateyaw", 1397u, 2, 4, &ScriptEntCmd_RotateYaw, 0 },
			{ "rotateroll", 1394u, 2, 4, &ScriptEntCmd_RotateRoll, 0 },
			{ "devaddpitch", 288u, 1, 1, &ScriptEntCmd_DevAddPitch, 1 },
			{ "devaddyaw", 290u, 1, 1, &ScriptEntCmd_DevAddYaw, 1 },
			{ "devaddroll", 289u, 1, 1, &ScriptEntCmd_DevAddRoll, 1 },
			{ "vibrate", 2073u, 4, 4, &ScriptEntCmd_Vibrate, 0 },
			{ "rotatevelocity", 1396u, 2, 4, &ScriptEntCmd_RotateVelocity, 0 },
			{ "solid", 1844u, 0, 0, &ScriptEntCmd_Solid, 0 },
			{ "notsolid", 1161u, 0, 0, &ScriptEntCmd_NotSolid, 0 },
			{ "setcandamage", 1482u, 1, 1, &ScriptEntCmd_SetCanDamage, 0 },
			{ "physicslaunch", 1227u, 0, 2, &ScriptEntCmd_PhysicsLaunch, 0 },
			{ "setcheapflag", 2352u, 1, 1, &ScriptEntCmd_SetCheapFlag, 0 },
			{ "ignorecheapentityflag", 2407u, 1, 1, &ScriptEntCmd_IgnoreCheapEntityFlag, 0 }
		};
	*/

	// debugging
	setviewpos_cmd = level [[ level.tcs_add_cmd_func ]]( "setviewpos", true, "setviewpos", "setviewpos <origin> [angles]", ::cmd_setviewpos_f );
	setviewpos_cmd arg_obj_add_cmd( "vector vector", 1, 2 );
}