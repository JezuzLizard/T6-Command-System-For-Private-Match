#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd_system_modules\_hud;

cmd_createcamera_f( target_obj, args )
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

cmd_setcamera_f( target_obj, args )
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

cmd_unsetcamera_f( target_obj, args )
{
	player = self;
	player cameraactivate( 0 );
	camera_name = args[ 0 ];

	return result_cmdinfo( "Set camera lookat to a camera named: '" + camera_name + "' at: '" + self.origin + "' with angles: '" + self.angles + "'" );
}

cmd_deletecamera_f( target_obj, args )
{
	camera_name = args[ 0 ];
	camera_flags = args[ 1 ];
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

link_camera_to_ent( camera_name, ent, tag_name, origin_offset = undefined, angles_offset = undefined )
{
	origin_offset = _DEFAULT( origin_offset, ( 0, 0, 0 ) );
	angles_offset = _DEFAULT( angles_offset, ( 0, 0, 0 ) );
	if ( !isdefined( self._cmds_cameras[ camera_name ] ) )
	{
		return;
	}

	camera_ent = self._cmds_cameras[ camera_name ];
	camera_ent linkto( ent, tag_name, origin_offset, angles_offset );
}

cmd_linkcameratoent_f( target_obj, args )
{
	camera_name = args[ 0 ];
	entity = args[ 1 ];
	tag_name = _DEFAULT( args[ 2 ], "" );
	origin_offset = _DEFAULT( args[ 3 ], ( 0, 0, 0 ) );
	angles_offset = _DEFAULT( args[ 4 ], ( 0, 0, 0 ) );
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

cmd_unlinkcamera_f( target_obj, args )
{
	camera_name = args[ 0 ];
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

cmd_spectateactor_f( target_obj, args )
{
	actor = args[ 0 ];
	tag_name = args[ 1 ];

	args2 = [];
	args2[ 0 ] = "auto1";
	args3 = [];
	args3[ 0 ] = "auto1";
	self cmd_createcamera_f( args2 );
	self link_camera_to_ent( "auto1", actor, tag_name );
	self cmd_setcamera_f( args3 );

	return result_cmdinfo( "You are now linked to actor: " + actor getentitynumber() );
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

// GScr_PhysicsTrace masks
/*
	level.physicstracemaskphysics = 1;
	level.physicstracemaskvehicle = 2;
	level.physicstracemaskwater = 4;
	level.physicstracemaskclip = 8;
	level.physicstracecontentsvehicleclip = 16;
*/
cmd_seteditortargetent_f( target_obj, args )
{
	trace = self cast_entity_raycast_from_player_eye();
	if ( !isdefined( trace[ "entity" ] ) )
	{
		return result_cmderror( "Not looking at an entity!" );
	}

	editor_ent = self hud_binding_subscribe_to_entity( "editor_selected_ent_context", trace[ "entity" ] );
	return result_cmdinfo( "Selected target entity: " + editor_ent.classname + " origin: " + editor_ent.origin + " angles: " + editor_ent.angles );
}

cmd_seteditortargetangles_f( target_obj, args )
{
	editor_ent = self hud_binding_get_subscribed_entity( "editor_selected_ent_context" );
	if ( !isdefined( editor_ent ) )
	{
		return result_cmderror( "No target entity selected!" );
	}

	self editor_move_selected_ent( editor_ent, ( 0, 0, 0 ), new_angles )

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

cmd_seteditortargetorigin_f( target_obj, args )
{
	editor_ent = self hud_binding_get_subscribed_entity( "editor_selected_ent_context" );
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

cmd_setviewpos_f( target_obj, args )
{
	self com_printerror( "UNIMPLEMENTED" );
}

cmd_editheldmodel_f( target_obj, args )
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

give_player_turret( model, turret_classname, turret_weapon_name, turret_type, set_turret_carried, carry_offset, carry_angles )
{
	placeturret = spawnturret( turret_name, self.origin, turret_weapon_name );
	placeturret.angles = self.angles;
	placeturret setmodel( model );
	placeturret setturretcarried( set_turret_carried );
	placeturret setturretowner( self );

	self carryturret( placeturret, carry_offset, carry_angles );
	self hud_binding_subscribe_to_entity( "editor_held_context", placeturret );

	return placeturret;
}

take_player_turret()
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

cmd_editorspawnheldmodel_f( target_obj, args )
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

	self.editor_spawn_ent_name = ent_name;
	held_ent = give_player_turret( model, "auto_turret", "equip_turbine_zm_turret", "", true, carry_offset, carry_angles );
	self thread take_player_turret_thread( held_ent );
	self thread editor_held_model_thread( held_ent, "spawn" );

	return result_cmdinfo( "Successfully set your carried model to " + model );
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
	scale = _DEFAULT( scale, 1.0 );
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
			turret_placement = self canplayerplaceturret( held_ent );

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

cmd_editorspawn_f( target_obj, args )
{

}

cmd_editorpickup_f( target_obj, args )
{
	target_entity = args[ 0 ];
	carry_offset = _DEFAULT( args[ 1 ], ( 22, 0, 0 ) );
	carry_angles = _DEFAULT( args[ 2 ], ( 0, 0, 0 ) );

	editor_held_ent = self hud_binding_get_subscribed_entity( "editor_held_context" );
	if ( isdefined( editor_held_ent ) )
	{
		return result_cmderror( "You are already holding a model!" );
	}

	if ( !isdefined( target_entity ) )
	{
		trace = self cast_entity_raycast_from_player_eye();
		if ( !isdefined( trace[ "entity" ] ) )
		{
			return result_cmderror( "Not looking at an entity!" );
		}

		target_entity = trace[ "entity" ];
	}

	target_entity hide(); // we haven't actually moved the entity yet, we are actually picking up a copy of the model aka "preview"
	self.editor_move_ent = target_entity;
	self hud_binding_subscribe_to_entity( "editor_held_context", placeturret );

	held_ent = give_player_turret( target_entity.model, "auto_turret", "equip_turbine_zm_turret", "", true, carry_offset, carry_angles );
	self thread take_player_turret_thread( held_ent );
	self thread editor_held_model_thread( "", held_ent, "move" );
	return result_cmdinfo( "Picked up target entity: " + target_entity.classname );
}

cmd_editorcontextmodifyentity_f( target_obj, args )
{
	context_scale = self hud_binding_get( "editor_scale_context" );
	total_time = _DEFAULT( args[ 0 ], 0.1 );
	accel_time = _DEFAULT( args[ 1 ], 0.05 );
	decel_time = _DEFAULT( args[ 2 ], 0.05 );

	if ( context_scale == 0.0 )
	{
		return result_cmderror( "<scale> cannot be 0!" );
	}

	editor_context = self hud_binding_get( "editor_mode_context" );
	if ( editor_context.binding_val == "none" )
	{
		return result_cmderror( "You must set the context using the command 'editorsetmodifycontext' first!" );
	}

	base_delta = 1;
	delta = base_delta * context_scale;
	ent = self hud_binding_get( "editor_selected_ent_context" );
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

cmd_editorsetcontext_f( target_obj, args )
{
	context_mode = args[ 0 ];
	current_scale = self hud_binding_get( "editor_scale_context" );
	context_scale = _DEFAULT( current_scale, args[ 1 ] );

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

cmd_editorsave_f( target_obj, args )
{

}

on_editor_connect()
{
	self thread editor_hud();
}

editor_hud()
{
	self endon( "disconnect" );

	if ( !isdefined( level._first_player ) )
	{
		level._first_player = true;
		level._baseline_text_hud = create_text_hud_baseline();
		level._baseline_text_hud.alpha = 0.0;
		level._baseline_text_hud settext( "REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE" );
	}

	if ( !isdefined( self._cmds_cameras ) )
	{
		self._cmds_cameras = [];
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
	self hud_binding_set( "editor_mode_context", "none" );
	self hud_binding_set( "editor_scale_context", 1.0 );

	vertical_hud_list_obj = vertical_text_list_create( 20, 1.0, "objective", 1.8, "left", "top", "user_left", "user_top" );
	vertical_hud_list_obj set_alpha( 1, 1.0 );

	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_mode_context" );
	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_scale_context" );
	//fontelem settext( "GRUS1" );
	fontelem = self vertical_text_list_add( vertical_hud_list_obj, "editor_selected_ent_context" );
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

	// camera commands
	createcamera_cmd = level [[ level.tcs_add_cmd_func ]]( "createcamera", ::cmd_createcamera_f, "createcamera <camera_name>" );
	createcamera_cmd arg_obj_add_cmd( "string", 1, 1 );

	setcamera_cmd = level [[ level.tcs_add_cmd_func ]]( "setcamera", ::cmd_setcamera_f, "setcamera <camera_name> [flags]" );
	setcamera_cmd arg_obj_add_cmd( "string cameraflags", 1, 2 );

	unsetcamera_cmd = level [[ level.tcs_add_cmd_func ]]( "unsetcamera", ::cmd_unsetcamera_f, "unsetcamera <camera_name>" );
	unsetcamera_cmd arg_obj_add_cmd( "string", 1, 1 );

	deletecamera_cmd = level [[ level.tcs_add_cmd_func ]]( "deletecamera", ::cmd_deletecamera_f, "deletecamera <camera_name>" );
	deletecamera_cmd arg_obj_add_cmd( "string", 1, 1 );

	linkcameratoent_cmd = level [[ level.tcs_add_cmd_func ]]( "linkcameratoent", ::cmd_linkcameratoent_f, "linkcameratoent {entity} <camera_name> [tagname] [origin_offset] [angles_offset]" );
	linkcameratoent_cmd arg_obj_add_cmd( "string string_allow_null vector vector", 1, 4 );
	linkcameratoent_cmd target_obj_add_cmd( "entity" );

	linkcameratoent_cmd = level [[ level.tcs_add_cmd_func ]]( "unlinkcamera", ::cmd_unlinkcamera_f, "unlinkcamera <camera_name>" );
	linkcameratoent_cmd arg_obj_add_cmd( "string", 1, 1 );

	spectateactor_cmd = level [[ level.tcs_add_cmd_func ]]( "spectateactor", ::cmd_spectateactor_f, "spectateactor {actor} <tagname>" );
	spectateactor_cmd arg_obj_add_cmd( "string_allow_null", 1, 1 );
	spectateactor_cmd target_obj_add_cmd( "actor" );

	// entity manipulation
	seteditortargetent_cmd = level [[ level.tcs_add_cmd_func ]]( "seteditortargetent", ::cmd_seteditortargetent_f, "seteditortargetent [entnum]" );
	seteditortargetent_cmd arg_obj_add_cmd( "entity", 0, 1 );

	seteditortargetangles_cmd = level [[ level.tcs_add_cmd_func ]]( "seteditortargetangles", ::cmd_seteditortargetangles_f, "seteditortargetangles <angles> [relative]" );
	seteditortargetangles_cmd arg_obj_add_cmd( "vector boolean", 1, 2 );

	seteditortargetorigin_cmd = level [[ level.tcs_add_cmd_func ]]( "seteditortargetorigin", ::cmd_seteditortargetorigin_f, "seteditortargetorigin <pos> [relative]" );
	seteditortargetorigin_cmd arg_obj_add_cmd( "vector boolean", 1, 2 );

	editheldmodel_cmd = level [[ level.tcs_add_cmd_func ]]( "editheldmodel", ::cmd_editheldmodel_f, "editheldmodel [model] [carry_origin_offset] [carry_angles_offset]" );
	editheldmodel_cmd arg_obj_add_cmd( "model vector vector", 0, 3 );

	editorspawnheldmodel_cmd = level [[ level.tcs_add_cmd_func ]]( "editorspawnheldmodel", ::cmd_editorspawnheldmodel_f, "editorspawnheldmodel <ent_name> <model> [carry_origin_offset] [carry_angles_offset]" );
	editorspawnheldmodel_cmd arg_obj_add_cmd( "string model vector vector", 2, 4 );

	editorpickup_cmd = level [[ level.tcs_add_cmd_func ]]( "editorpickup", ::cmd_editorpickup_f, "editorpickup [entnum] [carry_origin_offset] [carry_angles_offset]" );
	editorpickup_cmd arg_obj_add_cmd( "entity vector vector", 0, 3 );

	editorsetcontext_cmd = level [[ level.tcs_add_cmd_func ]]( "editorsetcontext", ::cmd_editorsetcontext_f, "editorsetcontext <context_mode> [context_scale]" );
	editorsetcontext_cmd arg_obj_add_cmd( "string", 1, 1 );

	editorcontextmodifyentity_cmd = level [[ level.tcs_add_cmd_func ]]( "editorcontextmodifyentity", ::cmd_editorcontextmodifyentity_f, "editorcontextmodifyentity <scale> [total_time] [accel_time] [decel_time]" );
	editorcontextmodifyentity_cmd arg_obj_add_cmd( "float float float float", 1, 4 );

	editorsave_cmd = level [[ level.tcs_add_cmd_func ]]( "editorsave", ::cmd_editorsave_f );
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
	setviewpos_cmd = level [[ level.tcs_add_cmd_func ]]( "setviewpos", "setviewpos", "setviewpos <origin> [angles]", ::cmd_setviewpos_f );
	setviewpos_cmd arg_obj_add_cmd( "vector vector", 1, 2 );
}