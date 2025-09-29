#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;
#include scripts\cmd\core\_hud_utility;
#include scripts\cmd\modules\filmmaker\camera_helpers;

autoexec add_cmds()
{
	waittillframeend;
	// camera commands
	cmd_block_set_module_group( "addon_entity_tools" );
	cmd_block_set_rank_group( "cheat" );

	createcamera_cmd = cmd_add( "createcamera", ::cmd_createcamera_f, "createcamera <camera_name> [origin] [angles] [model]" );
	createcamera_cmd arg_add_required( 1, "camera_name", "string", "Name of camera to identify it later" );
	createcamera_cmd arg_add_optional( 2, "origin", "vector", "Where the camera will be placed" );
	createcamera_cmd arg_add_optional( 3, "angles", "vector", "The angles of the camera" );
	createcamera_cmd arg_add_optional_with_default( 4, "model", "model", "Model of the camera", "tag_origin" );

	setcamera_cmd = cmd_add( "setcamera", ::cmd_setcamera_f, "setcamera <camera_name> [flags]" );
	setcamera_cmd arg_add_required( 1, "camera_name", "string", "Name of camera to use" );
	setcamera_cmd arg_add_optional_with_default( 2, "flags", "cameraflags", "Optional flags to control how the camera operates", 1 );

	unsetcamera_cmd = cmd_add( "unsetcamera", ::cmd_unsetcamera_f, "unsetcamera <camera_name>" );
	unsetcamera_cmd arg_add_required( 1, "camera_name", "string", "Name of camera to unset" );

	deletecamera_cmd = cmd_add( "deletecamera", ::cmd_deletecamera_f, "deletecamera <camera_name>" );
	deletecamera_cmd arg_add_required( 1, "camera_name", "string", "Name of camera to delete" );

	linkcameratoent_cmd = cmd_add( "linkcameratoent", ::cmd_linkcameratoent_f, "linkcameratoent {entity} <camera_name> [tagname] [origin_offset] [angles_offset]" );
	linkcameratoent_cmd arg_add_required( 1, "camera_name", "string", "Name of camera to attempt to link to {entity}" );
	linkcameratoent_cmd arg_add_optional_with_default( 2, "tagname", "string", "Tagname of {entity} to link to", "" );
	linkcameratoent_cmd arg_add_optional_with_default( 3, "origin_offset", "vector", "Origin offset from {entity} origin", ( 0, 0, 0 ) );
	linkcameratoent_cmd arg_add_optional_with_default( 4, "angles_offset", "vector", "Angles offset from {entity} angles", ( 0, 0, 0 ) );
	linkcameratoent_cmd target_add_required( 1, "entity", "general", "Entity to link a spawned camera to", 1 );

	linkcameratoent_cmd = cmd_add( "unlinkcamera", ::cmd_unlinkcamera_f, "unlinkcamera <camera_name>" );
	linkcameratoent_cmd arg_add_required( 1, "camera_name", "string", "Name of camera to attempt to unlink from an entity" );

	spectateactor_cmd = cmd_add( "spectateactor", ::cmd_spectateactor_f, "spectateactor {actor} <tagname>" );
	spectateactor_cmd arg_add_required( 1, "tagname", "string", "Begin spectating {actor}'s POV" );
	spectateactor_cmd target_add_required( 1, "actor", "actor", "Actor to spectate", 1 );
}

private cmd_createcamera_f( param )
{
	camera_name = param.a[ 0 ];
	origin = _DEFAULT( param.a[ 1 ], self.origin );
	angles = _DEFAULT( param.a[ 2 ], self getplayerangles() );
	model = _DEFAULT( param.a[ 3 ], "tag_origin" );

	if ( !self register_placed_camera( camera_name, origin, angles, model ) )
	{
		return param add_executor_cmderror( "Reached limit of '" + get_dvar_int_default( "max_user_cameras", 8 ) + "' cameras for your user" );
	}

	param add_executor_cmdinfo( "Created a camera named: '" + camera_name + "' at position: '" + origin + "' with angles: '" + angles + "' with model: " + model );
}

private cmd_setcamera_f( param )
{
	camera_name = param.a[ 0 ];
	camera_flags = _DEFAULT( param.a[ 1 ], 1 );
	
	player = self;
	camera_ent = self._cmds_cameras[ camera_name ];
	if ( !isdefined( camera_ent ) )
	{
		return param add_executor_cmderror( "No camera with name '" + camera_name + "' exists!" );
	}

	player camerasetposition( camera_ent );
	player camerasetlookat();
	player cameraactivate( camera_flags );

	param add_executor_cmdinfo( "Set camera lookat to a camera named: '" + camera_name + "' at: '" + self.origin + "' with angles: '" + self.angles + "'" );
}

private cmd_unsetcamera_f( param )
{
	player = self;
	player cameraactivate( 0 );
	camera_name = param.a[ 0 ];

	param add_executor_cmdinfo( "Set camera lookat to a camera named: '" + camera_name + "' at: '" + self.origin + "' with angles: '" + self.angles + "'" );
}

private cmd_deletecamera_f( param )
{
	camera_name = param.a[ 0 ];
	camera_flags = param.a[ 1 ];
	player = self;

	camera_ent = self._cmds_cameras[ camera_name ];
	if ( !isdefined( camera_ent ) )
	{
		return param add_executor_cmderror( "No camera with name '" + camera_name + "' exists!" );
	}

	camera_ent unlink();
	camera_ent delete();
	param add_executor_cmdinfo( "Deleted camera lookat for a camera named: '" + camera_name + "' at: '" + self.origin + " with angles: '" + self.angles + "'" );
}

private cmd_linkcameratoent_f( param )
{
	camera_name = param.a[ 0 ];
	entity = param.t[ 0 ][ 0 ];
	tag_name = _DEFAULT( param.a[ 1 ], "" );
	origin_offset = _DEFAULT( param.a[ 2 ], ( 0, 0, 0 ) );
	angles_offset = _DEFAULT( param.a[ 3 ], ( 0, 0, 0 ) );
	camera_ent = self._cmds_cameras[ camera_name ];
	if ( !isdefined( camera_ent ) )
	{
		return param add_executor_cmderror( "No camera with name '" + camera_name + "' exists!" );
	}

	self scripts\cmd\modules\entity_helpers::link_camera_to_ent( camera_name, entity, tag_name, origin_offset, angles_offset );
	param add_executor_cmdinfo( "Linked camera '" + camera_name + "' to ent '" + entity.classname + "'!"  );
}

private cmd_unlinkcamera_f( param )
{
	camera_name = param.a[ 0 ];
	camera_ent = self._cmds_cameras[ camera_name ];
	if ( !isdefined( camera_ent ) )
	{
		return return result_cmderror( "No camera with name '" + camera_name + "' exists!" );( "No camera with name '" + camera_name + "' exists!" );
	}
	
	camera_ent unlink();
	param add_executor_cmdinfo( "Unlinked camera '" + camera_name + "'!"  );
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

	param add_executor_cmdinfo( "You are now linked to actor: " + actor getentitynumber() );
}