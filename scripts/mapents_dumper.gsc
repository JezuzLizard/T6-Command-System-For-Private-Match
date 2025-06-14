#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
	level.spawnpoints_mapents_fh = fs_fopen( "spawns_" + getdvar( "mapname" ) + ".mapents", "append" );
	level.spawnpoints_gsc_fh = fs_fopen( "spawns_" + getdvar( "mapname" ) + ".gsc", "append" );
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
	if ( isdefined( level._cmds_cameras[ camera_name ] ) )
	{
		level._cmds_cameras[ camera_name ] delete();
	}
	camera_ent = spawn( "script_model", self.origin );
	camera_ent.angles = self.angles;
	camera_ent setmodel( "tag_origin" );
	camera_ent.camera_name = camera_name;

	level._cmds_cameras[ camera_name ] = camera_ent;

	return result_cmdinfo( "Created a camera named: '" + camera_name + "' at: '" + self.origin + "' with angles: '" + self.angles + "'" );
}

cmd_setcamera_f( args )
{
	camera_name = args[ 0 ];
	camera_flags = 1;
	if ( isdefined( args[ 1 ] ) )
	{
		camera_flags = args[ 1 ];
	}
	player = self;
	camera_ent = level._cmds_cameras[ camera_name ];
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

	camera_ent = level._cmds_cameras[ camera_name ];
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

	self.targetent_selected = trace[ "entity" ];
	return result_cmdinfo( "Selected target entity: " + self.targetent_selected.classname );
}

cmd_seteditortargetangles_f( args )
{
	if ( !isdefined( self.targetent_selected ) )
	{
		return result_cmderror( "No target entity selected!" );
	}

	if ( args.size < 1 )
	{
		return result_cmderror( "No angles specified!" );
	}

	new_angles = args[ 0 ];
	is_relative = args[ 1 ];

	if ( is_true( is_relative ) )
	{
		self.targetent_selected.angles += new_angles;
	}
	else
	{
		self.targetent_selected.angles = new_angles;
	}

	return result_cmdinfo( "Set angles of target entity: '" + self.targetent_selected.classname + "' to: '" + new_angles + "'" );
}

cmd_seteditortargetorigin_f( args )
{
	if ( !isdefined( self.targetent_selected ) )
	{
		return result_cmderror( "No target entity selected!" );
	}

	if ( args.size < 1 )
	{
		return result_cmderror( "No pos specified!" );
	}

	new_origin = args[ 0 ];
	is_relative = args[ 1 ];

	if ( is_true( is_relative ) )
	{
		self.targetent_selected.origin += new_origin;
	}
	else
	{
		self.targetent_selected.origin = new_origin;
	}

	return result_cmdinfo( "Set origin of target entity: '" + self.targetent_selected.classname + "' to: '" + new_origin + "'" );
}

cmd_setviewpos_f( args )
{
	self com_printerror( "UNIMPLEMENTED" );
}

cmd_editheldmodel_f( args )
{
	model = args[ 0 ];

	if ( !isdefined( self.carried_model ) )
	{
		return result_cmderror( "Cannot set model on held model, you are not holding a model!" );
	}

	self.carried_model setmodel( model );
	return result_cmdinfo( "Successfully set your carried model to " + model );
}

equipment_watch_placement( equipment )
{

}

cmd_editorspawnheldmodel_f( args )
{
	ent_name = args[ 0 ];
	model = args[ 1 ];
	carry_offset = args[ 2 ];
	carry_angles = args[ 3 ];
	if ( !isdefined( carry_offset ) )
	{
		carry_offset = ( 22, 0, 0 );
	}

	if ( !isdefined( carry_angles ) )
	{
		carry_angles = ( 0, 0, 0 );
	}

	if ( is_true( self.is_holding_model ) )
	{
		return result_cmderror( "You are already holding a model!" );
	}

	self thread editor_spawn_held_model_thread();

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
	self.carried_model = placeturret;

	for ( ;; )
	{
		ended = self waittill_any_return( "weapon_change" );

		if ( !( isdefined( level.use_legacy_equipment_placement ) && level.use_legacy_equipment_placement ) )
			turret_placement = self canplayerplaceturret( self.carried_model );

		if ( turret_placement[ "result" ] )
		{
			new_ent = spawn( "script_model", turret_placement[ "origin" ] );
			new_ent.angles = turret_placement[ "angles" ];
			new_ent setmodel( self.carried_model.model );

			if ( isdefined( level._editor_placed_ents[ ent_name ] ) )
			{
				level._editor_placed_ents[ ent_name ] delete();
			}
			level._editor_placed_ents[ ent_name ] = new_ent;

			break;
		}
	}

	self stopcarryturret( self.carried_model );
	self.carried_model setturretcarried( false );
	self.carried_model delete();

	self.is_holding_model = false;
}

cmd_editorspawn_f( args )
{

}

main()
{
	while ( !isdefined( level.cmd_init_done ) )
	{
		wait 0.05;
	}

	if ( !isdefined( level.tcs_add_cmd_func ) )
	{
		return;	
	}

	if ( !isdefined( level._cmds_cameras ) )
	{
		level._cmds_cameras = [];
	}

	if ( !isdefined( level._editor_placed_ents ) )
	{
		level._editor_placed_ents = [];
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

	editheldmodel_cmd = level [[ level.tcs_add_cmd_func ]]( "editheldmodel", true, "editheldmodel", "editheldmodel <model>", ::cmd_editheldmodel_f );
	editheldmodel_cmd arg_obj_add_cmd( "string", 1, 1 );

	editorspawnheldmodel_cmd = level [[ level.tcs_add_cmd_func ]]( "editorspawnheldmodel", true, "spawnheld", "editorspawnheldmodel <ent_name> <model> [carry_origin_offset] [carry_angles_offset]", ::cmd_editorspawnheldmodel_f );
	editorspawnheldmodel_cmd = arg_obj_add_cmd( "string model vector vector", 2, 4 );
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
	setviewpos_cmd = arg_obj_add_cmd( "vector vector", 1, 2 );
}