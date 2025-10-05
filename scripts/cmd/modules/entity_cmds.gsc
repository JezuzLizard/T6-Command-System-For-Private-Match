#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;
#include scripts\cmd\core\_hud_utility;
#include scripts\cmd\modules\entity_helpers;

autoexec add_cmds()
{
	precacheitem( "equip_turbine_zm_turret" );

	waittillframeend;
	cmd_block_set_module_group( "addon_entity_tools" );
	cmd_block_set_rank_group( "cheat" );

	// entity manipulation
	seteditortargetent_cmd = cmd_add( "seteditortargetent", ::cmd_seteditortargetent_f, "seteditortargetent {entity}" );
	seteditortargetent_cmd target_add_required( 1, "entity", "general", "Manual entity to target for editing", 1 );

	editentfield_cmd = cmd_add( "editentfield", ::cmd_editentfield_f, "editentfield {[entity]} <fieldname> <fieldvalue> [scale] [relative]" );
	editentfield_cmd arg_add_required( 1, "fieldname", "string", "New angles to set the target entity to" );
	editentfield_cmd arg_add_optional( 2, "fieldvalue", "string", "Causes the entity angles to be modified by <angles> instead of assigned" );
	editentfield_cmd arg_add_optional( 3, "scale", "float", "The scale of the angle modification" );
	editentfield_cmd arg_add_optional( 4, "relative", "boolean", "The scale of the angle modification" );
	editentfield_cmd target_add_optional( 1, "entity", "general", "Manual entity to target for editing" );

	seteditortargetangles_cmd = cmd_add( "seteditortargetangles", ::cmd_seteditortargetangles_f, "seteditortargetangles {[entity]} <angles> [relative] [scale]" );
	seteditortargetangles_cmd arg_add_required( 1, "angles", "vector", "New angles to set the target entity to" );
	seteditortargetangles_cmd arg_add_optional_with_default( 2, "relative", "boolean", "Causes the entity angles to be modified by <angles> instead of assigned", false );
	seteditortargetangles_cmd arg_add_optional_with_default( 3, "scale", "float", "The scale of the angle modification", 1.0 );
	seteditortargetangles_cmd target_add_optional( 1, "entity", "general", "Manual entity to target for editing", 1 );

	seteditortargetorigin_cmd = cmd_add( "seteditortargetorigin", ::cmd_seteditortargetorigin_f, "seteditortargetorigin {[entity]} <pos> [relative]" );
	seteditortargetorigin_cmd arg_add_required( 1, "pos", "vector", "New position to set the target entity to" );
	seteditortargetorigin_cmd arg_add_optional( 2, "relative", "boolean", "Causes the entity origin to be modified by <pos> instead of assigned" );
	seteditortargetorigin_cmd target_add_optional( 1, "entity", "general", "Manual entity to target for editing", 1 );

	editheldmodel_cmd = cmd_add( "editheldmodel", ::cmd_editheldmodel_f, "editheldmodel [model] [carry_origin_offset] [carry_angles_offset]" );
	editheldmodel_cmd arg_add_optional( 1, "model", "model", "New model to assign the held model to" );
	editheldmodel_cmd arg_add_optional( 2, "carry_origin_offset", "vector", "New carry origin offset" );
	editheldmodel_cmd arg_add_optional( 3, "carry_angles_offset", "vector", "New carry angles offset" );

	editorspawnheldmodel_cmd = cmd_add( "editorspawnheldmodel", ::cmd_editorspawnheldmodel_f, "editorspawnheldmodel <ent_name> <model> [carry_origin_offset] [carry_angles_offset]" );
	editorspawnheldmodel_cmd arg_add_required( 1, "ent_name", "string", "Name of entity to identify it with later commands" );
	editorspawnheldmodel_cmd arg_add_required( 2, "model", "model", "Model to assign to entity" );
	editorspawnheldmodel_cmd arg_add_optional( 3, "carry_origin_offset", "vector", "Initial carry origin offset" );
	editorspawnheldmodel_cmd arg_add_optional( 4, "carry_angles_offset", "vector", "Initial carry angles offset" );
	editorspawnheldmodel_cmd make_cmd_immune_to_unittest();

	editorpickup_cmd = cmd_add( "editorpickup", ::cmd_editorpickup_f, "editorpickup {entity} [carry_origin_offset] [carry_angles_offset]" );
	editorpickup_cmd arg_add_optional( 1, "carry_origin_offset", "vector", "Initial carry origin offset" );
	editorpickup_cmd arg_add_optional( 2, "carry_angles_offset", "vector", "Initial carry angles offset" );
	editorpickup_cmd target_add_optional( 1, "entity", "general", "Manual entity to pickup for editing", 1 );

	editorsetcontext_cmd = cmd_add( "editorsetcontext", ::cmd_editorsetcontext_f, "editorsetcontext <context_mode> [context_scale]" );
	editorsetcontext_cmd arg_add_required( 1, "context_mode", "string", "Mode for editing selected entity" );
	editorsetcontext_cmd arg_add_optional( 2, "context_scale", "float", "Scale applied to change values" );

	editorcontextmodifyentity_cmd = cmd_add( "editorcontextmodifyentity", ::cmd_editorcontextmodifyentity_f, "editorcontextmodifyentity <scale> [total_time] [accel_time] [decel_time]" );
	editorcontextmodifyentity_cmd arg_add_required( 1, "scale", "float", "Scale of changes made" );
	editorcontextmodifyentity_cmd arg_add_optional_with_default( 2, "total_time", "float", "Total time for entity changes to occur over", 1 );
	editorcontextmodifyentity_cmd arg_add_optional_with_default( 3, "accel_time", "float", "Acceleration time before entity change speed maximum is reached", 0.05 );
	editorcontextmodifyentity_cmd arg_add_optional_with_default( 4, "decel_time", "float", "Deceleration time before entity change speed minimum is reached", 0.05 );

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
	setviewpos_cmd arg_add_required( 1, "origin", "vector", "New origin for you to be moved to" );
	setviewpos_cmd arg_add_optional( 2, "angles", "vector", "New angles for you to have" );

	editorputdown_cmd = cmd_add( "editorputdown", ::cmd_editorputdown_f, "editorputdown" );

	//spawn_cmd = cmd_add( "spawn", ::cmd_spawn_f, "spawn <classname> <origin> [spawnflags] [contextual1] [contextual2] [contextual3]" );
	//spawn_cmd arg_add( "spawnable_classname vector string string string string", 2, 6 );

	//dumpent_cmd = cmd_add( "saveent", ::cmd_dumpent_f, "saveent <type> [classname]" );
	//dumpent_cmd arg_add( "string string", 1, 2 );
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
			return param add_executor_cmderror( "Not looking at an entity!" );
		}
	}

	self hud_binding_subscribe_to_entity( "editor_selected_ent_context", entity );
	param add_executor_cmdinfo( "Selected target entity: " + entity.classname + " origin: " + entity.origin + " angles: " + entity.angles );
}

private cmd_seteditortargetangles_f( param )
{
	// allow using the argument from the target system to optionally override
	editor_ent = param.t[ 0 ][ 0 ];
	if ( !isdefined( editor_ent ) )
	{
		editor_ent = self hud_binding_get_subscribed_entity( "editor_selected_ent_context" );
		if ( !isdefined( editor_ent ) )
		{
			return param add_executor_cmderror( "No target entity selected!" );
		}
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

	param add_executor_cmdinfo( "Set angles of target entity: '" + editor_ent.classname + "' to: '" + editor_ent.angles + "'" );
}

private cmd_seteditortargetorigin_f( param )
{
	// allow using the argument from the target system to optionally override
	editor_ent = param.t[ 0 ][ 0 ];
	if ( !isdefined( editor_ent ) )
	{
		editor_ent = self hud_binding_get_subscribed_entity( "editor_selected_ent_context" );
		if ( !isdefined( editor_ent ) )
		{
			return param add_executor_cmderror( "No target entity selected!" );
		}
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

	param add_executor_cmdinfo( "Set origin of target entity: '" + editor_ent.classname + "' to: '" + new_origin + "'" );
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
		return param add_executor_cmderror( "Cannot set model on held model, you are not holding a model!" );
	}

	if ( !isdefined( param.a[ 0 ] ) && !isdefined( param.a[ 1 ] ) && !isdefined( param.a[ 2 ] ) )
	{
		return param add_executor_cmderror( "No arguments, no changes..." );
	}

	self stopcarryturret( editor_held_ent );
	editor_held_ent setturretcarried( false );
	if ( model != "null" )
	{
		editor_held_ent setmodel( model );
	}
	
	editor_held_ent setturretcarried( true );
	self carryturret( editor_held_ent, carry_offset, carry_angles );

	param add_executor_cmdinfo( "Successfully set your carried model to " + model );
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
		return param add_executor_cmderror( "You are already holding a model!" );
	}

	self.editor_spawn_ent_name = ent_name;
	held_ent = scripts\cmd\modules\entity_helpers::give_player_turret( model, "auto_turret", "equip_turbine_zm_turret", "", true, carry_offset, carry_angles );
	self thread scripts\cmd\modules\entity_helpers::take_player_turret_thread( held_ent );
	self thread scripts\cmd\modules\entity_helpers::editor_held_model_thread( held_ent, "spawn" );

	param add_executor_cmdinfo( "Successfully set your carried model to " + model );
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
		return param add_executor_cmderror( "You are already holding a model!" );
	}

	if ( !isdefined( target_entity ) )
	{
		trace = self scripts\cmd\modules\entity_helpers::cast_entity_raycast_from_player_eye();
		if ( !isdefined( trace[ "entity" ] ) )
		{
			return param add_executor_cmderror( "Not looking at an entity!" );
		}

		target_entity = trace[ "entity" ];
	}

	target_entity hide(); // we haven't actually moved the entity yet, we are actually picking up a copy of the model aka "preview"
	self.editor_move_ent = target_entity;
	self hud_binding_subscribe_to_entity( "editor_held_context", target_entity );

	held_ent = scripts\cmd\modules\entity_helpers::give_player_turret( target_entity.model, "auto_turret", "equip_turbine_zm_turret", "", true, carry_offset, carry_angles );
	self thread scripts\cmd\modules\entity_helpers::take_player_turret_thread( held_ent );
	self thread scripts\cmd\modules\entity_helpers::editor_held_model_thread( held_ent, "move" );
	param add_executor_cmdinfo( "You picked up target entity: " + target_entity.classname );
}

private cmd_editorcontextmodifyentity_f( param )
{
	context_scale = float( self hud_binding_get( "editor_scale_context" ).binding_val );
	total_time = _DEFAULT( param.a[ 0 ], 0.1 );
	accel_time = _DEFAULT( param.a[ 1 ], 0.05 );
	decel_time = _DEFAULT( param.a[ 2 ], 0.05 );

	if ( context_scale == 0.0 )
	{
		return param add_executor_cmderror( "<scale> cannot be 0!" );
	}

	editor_context = self hud_binding_get( "editor_mode_context" ).binding_val;
	if ( editor_context.binding_val == "none" )
	{
		return param add_executor_cmderror( "You must set the context using the command 'editorsetmodifycontext' first!" );
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
			return param add_executor_cmderror( "'editor_mode_context' must be one of 'pitch', 'yaw', 'roll', 'x', 'y', 'z'!" );
	}
}

private cmd_editorsetcontext_f( param )
{
	context_mode = param.a[ 0 ];
	current_scale = float( self hud_binding_get( "editor_scale_context" ).binding_val );
	context_scale = _DEFAULT( current_scale, param.a[ 1 ] );

	if ( context_scale == 0.0 )
	{
		return param add_executor_cmderror( "<context_scale> cannot be 0.0!" );
	}

	self hud_binding_set( "editor_scale_context", context_scale );

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
			return param add_executor_cmderror( "<context> must be one of 'pitch', 'yaw', 'roll', 'x', 'y', 'z', 'none'!" );
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
			return param add_executor_cmderror( "Unsupported classname: " + classname );
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
			param add_executor_cmdinfo( "Successfully added a dog spawner!" );
			break;

		case "minimap":
			valid_type = true;
			param add_executor_cmdinfo( "Successfully added a minimap corner!" );
			break;

		case "player_spawn":
			if ( !isdefined( classname ) )
			{
				return param add_executor_cmderror( "player_spawn type requires a classname!" );
			}

			valid_type = true;
			param add_executor_cmdinfo( "Successfully added a player spawnpoint!" );
			break;
	}

	if ( !valid_type )
	{
		return param add_executor_cmderror( "Type " + type + " is unsupported!" );
	}

	switch ( type )
	{
		case "dogs":
			//level scripts\cmd\modules\entity_helpers::dump_mapents_dog_actor_spawner( player.angles, player.origin );
			break;

		case "minimap":
			//level scripts\cmd\modules\entity_helpers::dump_mapents_minimap_corner( player.angles, player.origin );
			break;

		case "player_spawn":
			//level scripts\cmd\modules\entity_helpers::dump_gsc_spawnpoint( classname, player.angles, player.origin );
			//level scripts\cmd\modules\entity_helpers::dump_mapents_spawnpoint( classname, player.angles, player.origin );
			break;
	}

	scripts\cmd\modules\entity_helpers::create_entity_location_screenshot( type, player.name, player.angles, player.origin, classname );
}

private cmd_editorputdown_f( param )
{
	self notify( "editor_place_held" );
	param add_executor_cmdinfo( "You put down held entity" );
}

private cmd_editentfield_f( param )
{
	targets = _DEFAULT( param.t[ 0 ], [] );
	fieldname = param.a[ 0 ];
	fieldvalue = param.a[ 1 ];
	scale = _DEFAULT( param.a[ 2 ], 1.0 );
	is_relative = _DEFAULT( param.a[ 3 ], false );

	editor_ent = self hud_binding_get_subscribed_entity( "editor_selected_ent_context" );
	if ( targets.size == 0 )
	{
		targets[ 0 ] = editor_ent;
		if ( targets.size == 0 )
		{
			return param add_executor_cmderror( "No target entity selected!" );
		}
	}

	if ( is_relative )
	{
		for ( i = 0; i < targets.size; i++ )
		{
			targ = targets[ i ];
			assign_result = targ set_entfield( fieldname, fieldvalue );
			if ( assign_result.errored )
			{
				param add_executor_cmderror( assign_result.msg );
			}
		}
	}
	else
	{
		for ( i = 0; i < targets.size; i++ )
		{
			targ = targets[ i ];
			assign_result = targ set_entfield_relative( fieldname, fieldvalue, scale );
			if ( assign_result.errored )
			{
				param add_executor_cmderror( assign_result.msg );
			}
		}
	}
}