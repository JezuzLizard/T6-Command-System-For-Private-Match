#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;
#include scripts\cmd\core\_hud_utility;
#include scripts\cmd\modules\entity_helpers;

autoexec add_cmds()
{
	waittillframeend;
	cmd_block_set_module_group( "addon_entity_tools" );
	cmd_block_set_rank_group( "cheat" );

	// camera commands
	createcamera_cmd = cmd_add( "createcamera", ::cmd_createcamera_f, "createcamera <camera_name>" );
	createcamera_cmd arg_obj_add_cmd( "string", 1, 1 );

	setcamera_cmd = cmd_add( "setcamera", ::cmd_setcamera_f, "setcamera <camera_name> [flags]" );
	setcamera_cmd arg_obj_add_cmd( "string cameraflags", 1, 2 );

	unsetcamera_cmd = cmd_add( "unsetcamera", ::cmd_unsetcamera_f, "unsetcamera <camera_name>" );
	unsetcamera_cmd arg_obj_add_cmd( "string", 1, 1 );

	deletecamera_cmd = cmd_add( "deletecamera", ::cmd_deletecamera_f, "deletecamera <camera_name>" );
	deletecamera_cmd arg_obj_add_cmd( "string", 1, 1 );

	linkcameratoent_cmd = cmd_add( "linkcameratoent", ::cmd_linkcameratoent_f, "linkcameratoent {entity} <camera_name> [tagname] [origin_offset] [angles_offset]" );
	linkcameratoent_cmd arg_obj_add_cmd( "string string vector vector", 1, 4 );
	linkcameratoent_cmd target_type_add_cmd( "general", true, "Entity to link a spawned camera to", 1 );

	linkcameratoent_cmd = cmd_add( "unlinkcamera", ::cmd_unlinkcamera_f, "unlinkcamera <camera_name>" );
	linkcameratoent_cmd arg_obj_add_cmd( "string", 1, 1 );

	spectateactor_cmd = cmd_add( "spectateactor", ::cmd_spectateactor_f, "spectateactor {actor} <tagname>" );
	spectateactor_cmd arg_obj_add_cmd( "string", 1, 1 );
	spectateactor_cmd target_type_add_cmd( "actor", true, "Actor to spectate", 1 );

	// entity manipulation
	seteditortargetent_cmd = cmd_add( "seteditortargetent", ::cmd_seteditortargetent_f, "seteditortargetent {entity}" );
	seteditortargetent_cmd target_type_add_cmd( "general", false, "Manual entity to target for editing", 1 );

	seteditortargetangles_cmd = cmd_add( "seteditortargetangles", ::cmd_seteditortargetangles_f, "seteditortargetangles <angles> [relative] [scale]" );
	seteditortargetangles_cmd arg_obj_add_cmd( "vector boolean", 1, 3 );

	seteditortargetorigin_cmd = cmd_add( "seteditortargetorigin", ::cmd_seteditortargetorigin_f, "seteditortargetorigin <pos> [relative]" );
	seteditortargetorigin_cmd arg_obj_add_cmd( "vector boolean", 1, 2 );

	editheldmodel_cmd = cmd_add( "editheldmodel", ::cmd_editheldmodel_f, "editheldmodel [model] [carry_origin_offset] [carry_angles_offset]" );
	editheldmodel_cmd arg_obj_add_cmd( "model vector vector", 0, 3 );

	editorspawnheldmodel_cmd = cmd_add( "editorspawnheldmodel", ::cmd_editorspawnheldmodel_f, "editorspawnheldmodel <ent_name> <model> [carry_origin_offset] [carry_angles_offset]" );
	editorspawnheldmodel_cmd arg_obj_add_cmd( "string model vector vector", 2, 4 );
	editorspawnheldmodel_cmd make_cmd_immune_to_unittest();

	editorpickup_cmd = cmd_add( "editorpickup", ::cmd_editorpickup_f, "editorpickup {entity} [carry_origin_offset] [carry_angles_offset]" );
	editorpickup_cmd arg_obj_add_cmd( "vector vector", 0, 2 );
	editorpickup_cmd target_type_add_cmd( "general", false, "Manual entity to pickup for editing", 1 );

	editorsetcontext_cmd = cmd_add( "editorsetcontext", ::cmd_editorsetcontext_f, "editorsetcontext <context_mode> [context_scale]" );
	editorsetcontext_cmd arg_obj_add_cmd( "string", 1, 1 );

	editorcontextmodifyentity_cmd = cmd_add( "editorcontextmodifyentity", ::cmd_editorcontextmodifyentity_f, "editorcontextmodifyentity <scale> [total_time] [accel_time] [decel_time]" );
	editorcontextmodifyentity_cmd arg_obj_add_cmd( "float float float float", 1, 4 );

	editorsave_cmd = cmd_add( "editorsave", ::cmd_editorsave_f );
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
	setviewpos_cmd = cmd_add( "setviewpos", ::cmd_setviewpos_f, "setviewpos <origin> [angles]" );
	setviewpos_cmd arg_obj_add_cmd( "vector vector", 1, 2 );

	//spawn_cmd = cmd_add( "spawn", ::cmd_spawn_f, "spawn <classname> <origin> [spawnflags] [contextual1] [contextual2] [contextual3]" );
	//spawn_cmd arg_obj_add_cmd( "spawnable_classname vector string string string string", 2, 6 );

	//dumpent_cmd = cmd_add( "saveent", ::cmd_dumpent_f, "saveent <type> [classname]" );
	//dumpent_cmd arg_obj_add_cmd( "string string", 1, 2 );
}

private cmd_createcamera_f( param )
{
	camera_name = param.a[ 0 ];
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

private cmd_setcamera_f( param )
{
	camera_name = param.a[ 0 ];
	camera_flags = _DEFAULT( param.a[ 1 ], 1 );
	
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

private cmd_unsetcamera_f( param )
{
	player = self;
	player cameraactivate( 0 );
	camera_name = param.a[ 0 ];

	return result_cmdinfo( "Set camera lookat to a camera named: '" + camera_name + "' at: '" + self.origin + "' with angles: '" + self.angles + "'" );
}

private cmd_deletecamera_f( param )
{
	camera_name = param.a[ 0 ];
	camera_flags = param.a[ 1 ];
	player = self;

	camera_ent = self._cmds_cameras[ camera_name ];
	if ( isdefined( camera_ent ) )
	{
		camera_ent unlink();
		camera_ent delete();
		return result_cmdinfo( "Deleted camera lookat for a camera named: '" + camera_name + "' at: '" + self.origin + " with angles: '" + self.angles + "'" );
	}
	else
	{
		return result_cmderror( "No camera with name '" + camera_name + "' exists!" );
	}
}

private cmd_linkcameratoent_f( param )
{
	camera_name = param.a[ 0 ];
	entity = param.t[ 0 ][ 0 ];
	tag_name = _DEFAULT( param.a[ 1 ], "" );
	origin_offset = _DEFAULT( param.a[ 2 ], ( 0, 0, 0 ) );
	angles_offset = _DEFAULT( param.a[ 3 ], ( 0, 0, 0 ) );
	camera_ent = self._cmds_cameras[ camera_name ];
	if ( isdefined( camera_ent ) )
	{
		self link_camera_to_ent( camera_name, entity, tag_name, origin_offset, angles_offset );
		return result_cmdinfo( "Linked camera '" + camera_name + "' to ent '" + entity.classname + "'!"  );
	}
	else
	{
		return result_cmderror( "No camera with name '" + camera_name + "' exists!" );
	}
}

private cmd_unlinkcamera_f( param )
{
	camera_name = param.a[ 0 ];
	camera_ent = self._cmds_cameras[ camera_name ];
	if ( isdefined( camera_ent ) )
	{
		camera_ent unlink();
		return result_cmdinfo( "Unlinked camera '" + camera_name + "'!"  );
	}
	else
	{
		return result_cmderror( "No camera with name '" + camera_name + "' exists!" );
	}
	
}

private cmd_spectateactor_f( param )
{
	actor = param.t[ 0 ][ 0 ];
	tag_name = param.a[ 0 ];

	args2 = [];
	args2[ 0 ] = "auto1";
	args3 = [];
	args3[ 0 ] = "auto1";
	self cmd_createcamera_f( args2 );
	self scripts\cmd\modules\entity_helpers::link_camera_to_ent( "auto1", actor, tag_name );
	self cmd_setcamera_f( args3 );

	return result_cmdinfo( "You are now linked to actor: " + actor getentitynumber() );
}

// GScr_PhysicsTrace masks
/*
	level.physicstracemaskphysics = 1;
	level.physicstracemaskvehicle = 2;
	level.physicstracemaskwater = 4;
	level.physicstracemaskclip = 8;
	level.physicstracecontentsvehicleclip = 16;
*/
private cmd_seteditortargetent_f( param )
{
	entity = param.t[ 0 ][ 0 ];
	if ( !isdefined( entity ) )
	{
		trace = self scripts\cmd\modules\entity_helpers::cast_entity_raycast_from_player_eye();
		entity = trace[ "entity" ];
		if ( !isdefined( entity ) )
		{
			return result_cmderror( "Not looking at an entity!" );
		}
	}

	self hud_binding_subscribe_to_entity( "editor_selected_ent_context", entity );
	return result_cmdinfo( "Selected target entity: " + entity.classname + " origin: " + entity.origin + " angles: " + entity.angles );
}

private cmd_seteditortargetangles_f( param )
{
	editor_ent = self hud_binding_get_subscribed_entity( "editor_selected_ent_context" );
	if ( !isdefined( editor_ent ) )
	{
		return result_cmderror( "No target entity selected!" );
	}

	new_angles = param.a[ 0 ];
	is_relative = param.a[ 1 ];
	scale = param.a[ 2 ];

	if ( is_true( is_relative ) )
	{
		self scripts\cmd\modules\entity_helpers::editor_move_selected_ent_relative( editor_ent, new_angles, ( 0, 0, 0 ), scale );
		editor_ent.angles += new_angles;
	}
	else
	{
		self scripts\cmd\modules\entity_helpers::editor_move_selected_ent_absolute( editor_ent, new_angles, ( 0, 0, 0 ) );
		editor_ent.angles = new_angles;
	}

	return result_cmdinfo( "Set angles of target entity: '" + editor_ent.classname + "' to: '" + editor_ent.angles + "'" );
}

private cmd_seteditortargetorigin_f( param )
{
	editor_ent = self hud_binding_get_subscribed_entity( "editor_selected_ent_context" );
	if ( !isdefined( editor_ent ) )
	{
		return result_cmderror( "No target entity selected!" );
	}

	new_origin = param.a[ 0 ];
	is_relative = param.a[ 1 ];

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

private cmd_setviewpos_f( param )
{
	self com_printerror( "UNIMPLEMENTED" );
}

private cmd_editheldmodel_f( param )
{
	editor_held_ent = self hud_binding_get_subscribed_entity( "editor_held_context" );
	model = _DEFAULT( param.a[ 0 ], "null" );
	carry_offset = _DEFAULT( param.a[ 1 ], ( 22, 0, 0 ) );
	carry_angles = _DEFAULT( param.a[ 2 ], ( 0, 0, 0 ) );

	if ( !isdefined( editor_held_ent ) )
	{
		return result_cmderror( "Cannot set model on held model, you are not holding a model!" );
	}

	if ( !isdefined( param.a[ 0 ] ) && !isdefined( param.a[ 1 ] ) && !isdefined( param.a[ 2 ] ) )
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

private cmd_editorspawnheldmodel_f( param )
{
	ent_name = param.a[ 0 ];
	model = param.a[ 1 ];
	carry_offset = _DEFAULT( param.a[ 2 ], ( 22, 0, 0 ) );
	carry_angles = _DEFAULT( param.a[ 3 ], ( 0, 0, 0 ) );

	editor_held_ent = self hud_binding_get_subscribed_entity( "editor_held_context" );
	if ( isdefined( editor_held_ent ) )
	{
		return result_cmderror( "You are already holding a model!" );
	}

	self.editor_spawn_ent_name = ent_name;
	held_ent = scripts\cmd\modules\entity_helpers::give_player_turret( model, "auto_turret", "equip_turbine_zm_turret", "", true, carry_offset, carry_angles );
	self thread scripts\cmd\modules\entity_helpers::take_player_turret_thread( held_ent );
	self thread scripts\cmd\modules\entity_helpers::editor_held_model_thread( held_ent, "spawn" );

	return result_cmdinfo( "Successfully set your carried model to " + model );
}

private cmd_editorspawn_f( param )
{

}

private cmd_editorpickup_f( param )
{
	target_entity = param.t[ 0 ][ 0 ];
	carry_offset = _DEFAULT( param.a[ 0 ], ( 22, 0, 0 ) );
	carry_angles = _DEFAULT( param.a[ 1 ], ( 0, 0, 0 ) );

	editor_held_ent = self hud_binding_get_subscribed_entity( "editor_held_context" );
	if ( isdefined( editor_held_ent ) )
	{
		return result_cmderror( "You are already holding a model!" );
	}

	if ( !isdefined( target_entity ) )
	{
		trace = self scripts\cmd\modules\entity_helpers::cast_entity_raycast_from_player_eye();
		if ( !isdefined( trace[ "entity" ] ) )
		{
			return result_cmderror( "Not looking at an entity!" );
		}

		target_entity = trace[ "entity" ];
	}

	target_entity hide(); // we haven't actually moved the entity yet, we are actually picking up a copy of the model aka "preview"
	self.editor_move_ent = target_entity;
	self hud_binding_subscribe_to_entity( "editor_held_context", target_entity );

	held_ent = scripts\cmd\modules\entity_helpers::give_player_turret( target_entity.model, "auto_turret", "equip_turbine_zm_turret", "", true, carry_offset, carry_angles );
	self thread scripts\cmd\modules\entity_helpers::take_player_turret_thread( held_ent );
	self thread scripts\cmd\modules\entity_helpers::editor_held_model_thread( held_ent, "move" );
	return result_cmdinfo( "Picked up target entity: " + target_entity.classname );
}

private cmd_editorcontextmodifyentity_f( param )
{
	context_scale = float( self hud_binding_get( "editor_scale_context" ).binding_val );
	total_time = _DEFAULT( param.a[ 0 ], 0.1 );
	accel_time = _DEFAULT( param.a[ 1 ], 0.05 );
	decel_time = _DEFAULT( param.a[ 2 ], 0.05 );

	if ( context_scale == 0.0 )
	{
		return result_cmderror( "<scale> cannot be 0!" );
	}

	editor_context = self hud_binding_get( "editor_mode_context" ).binding_val;
	if ( editor_context.binding_val == "none" )
	{
		return result_cmderror( "You must set the context using the command 'editorsetmodifycontext' first!" );
	}

	base_delta = 1;
	delta = base_delta * context_scale;
	ent = self hud_binding_get( "editor_selected_ent_context" ).binding_val;
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
			return result_cmderror( "'editor_mode_context' must be one of 'pitch', 'yaw', 'roll', 'x', 'y', 'z'!" );
	}
}

private cmd_editorsetcontext_f( param )
{
	context_mode = param.a[ 0 ];
	current_scale = float( self hud_binding_get( "editor_scale_context" ).binding_val );
	context_scale = _DEFAULT( current_scale, param.a[ 1 ] );

	if ( context_scale > 0.0 || context_scale < 0.0 )
	{
		self hud_binding_set( "editor_scale_context", context_scale );
	}
	else
	{
		return result_cmderror( "<context_scale> cannot be 0.0!" );
	}

	switch ( context_mode )
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
			return result_cmderror( "<context> must be one of 'pitch', 'yaw', 'roll', 'x', 'y', 'z', 'none'!" );
	}
	
	self hud_binding_set( "editor_mode_context", context_mode );
}

private cmd_editorsave_f( param )
{

}

private cmd_spawn_f( param )
{
	classname = param.a[ 0 ];
	origin = param.a[ 1 ];
	spawnflags = _DEFAULT( param.a[ 2 ], 0 );

	ent = undefined;
	switch ( classname )
	{
		case "trigger_radius":
			ent = self scripts\cmd\modules\entity_helpers::spawn_trigger_radius( origin, spawnflags, param.a[ 3 ], param.a[ 4 ] );
			break;
		case "trigger_box":
			ent = self scripts\cmd\modules\entity_helpers::spawn_trigger_box( origin, spawnflags, param.a[ 3 ], param.a[ 4 ], param.a[ 5 ] );
			break;
		case "trigger_box_use":
			ent = self scripts\cmd\modules\entity_helpers::spawn_trigger_box_use( origin, spawnflags, param.a[ 3 ], param.a[ 4 ], param.a[ 5 ] );
			break;
		case "trigger_radius_use":
			ent = self scripts\cmd\modules\entity_helpers::spawn_trigger_radius_use( origin, spawnflags, param.a[ 3 ], param.a[ 4 ] );
			break;
		case "trigger_damage":
			ent = self scripts\cmd\modules\entity_helpers::spawn_trigger_damage( origin, spawnflags, param.a[ 3 ], param.a[ 4 ] );
			break;
		case "script_model":
			ent = self scripts\cmd\modules\entity_helpers::spawn_script_model( origin, spawnflags );
			break;
		case "script_origin":
			ent = self scripts\cmd\modules\entity_helpers::spawn_script_origin( origin, spawnflags );
			break;
		case "info_notnull":
		case "info_notnull_big":
		case "info_volume":
		default:
			return result_cmderror( "Unsupported classname: " + classname );
	}
}

private cmd_dumpent_f( param )
{
	type = param.a[ 0 ];
	classname = param.a[ 1 ];
	description = param.a[ 2 ];
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
				level scripts\cmd\modules\entity_helpers::dump_mapents_dog_actor_spawner( player.angles, player.origin );
				break;

			case "minimap":
				level scripts\cmd\modules\entity_helpers::dump_mapents_minimap_corner( player.angles, player.origin );
				break;

			case "player_spawn":
				level scripts\cmd\modules\entity_helpers::dump_gsc_spawnpoint( classname, player.angles, player.origin );
				level scripts\cmd\modules\entity_helpers::dump_mapents_spawnpoint( classname, player.angles, player.origin );
				break;
		}

		scripts\cmd\modules\entity_helpers::create_entity_location_screenshot( type, player.name, player.angles, player.origin, classname );
		return result;
	}
	else
	{
		return result_cmderror( "Type " + type + " is unsupported!" );
	}
}