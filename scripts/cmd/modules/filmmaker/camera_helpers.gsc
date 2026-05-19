#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;
#include scripts\cmd\core\_utility_hud;

init_camera_helpers()
{
	addcallback( "on_player_disconnect", ::on_disconnect );

	max_user_cameras = get_dvar_int_default( "max_user_cameras", 8 ); // 144 total...

	init_user_cameras( max_user_cameras );
}

private on_disconnect()
{
	if ( _ARRAY_VALIDATE( level._placed_cameras ) )
	{
		foreach ( camera_name, cam in level._placed_cameras.cams )
		{
			if ( cam.user != self )
			{
				continue;
			}
			
			level._placed_cameras.cams[ camera_name ] delete();
			level._placed_cameras.cams[ camera_name ] = undefined;
		}
	}
}

private init_user_cameras( limit )
{
	if ( !isdefined( level._placed_cameras ) )
	{
		level._placed_cameras = spawnstruct();
		level._placed_cameras.cams = [];
		level._placed_cameras.limit = limit;
	}
}

get_cameras_by_username( username )
{
	list = [];
	for ( i = 0; i < level._placed_cameras.cams.size; i++ )
	{
		cam = level._placed_cameras.cams[ i ];
		if ( cam.username == username )
		{
			list[ list.size ] = cam;
		}
	}

	return list;
}

get_camera_for_user( camera_name )
{
	return level._placed_cameras.cams[ camera_name ];
}

register_placed_camera( camera_name, origin, angles, model = "tag_origin" )
{
	owned_cams = get_cameras_by_username( self.name );
	if ( ( owned_cams.size + 1 ) > level._placed_cameras.limit )
	{
		return false;
	}

	cam_ent = spawn_camera_ent( camera_name, origin, angles, model );
	// check for reregistration
	if ( isdefined( level._placed_cameras.cams[ camera_name ] ) )
	{
		self unregister_placed_camera( camera_name );
	}

	cam_ent.username = self.name;
	cam_ent.user = self;
	level._placed_cameras.cams[ camera_name ] = cam_ent;
	return true;
}

unregister_placed_camera( camera_name )
{
	if ( isdefined( level._placed_cameras.cams[ camera_name ] ) )
	{
		level._placed_cameras.cams[ camera_name ] delete();
		level._placed_cameras.cams[ camera_name ] = undefined;
	}
}

get_placed_camera( camera_name )
{
	return level._placed_cameras.cams[ camera_name ];
}

placed_camera_exists( camera_name )
{
	return isdefined( level._placed_cameras.cams[ camera_name ] );
}

spawn_camera_ent( camera_name, origin, angles, model = "tag_origin" )
{
	model = _DEFAULT( model, "tag_origin" );
	camera_ent = spawn( "script_model", origin );
	camera_ent.angles = angles;
	camera_ent setmodel( model );
	camera_ent.camera_name = camera_name;

	return camera_ent;
}

link_camera_to_ent( camera_name, ent, tag_name, origin_offset = undefined, angles_offset = undefined )
{
	origin_offset = _DEFAULT( origin_offset, ( 0, 0, 0 ) );
	angles_offset = _DEFAULT( angles_offset, ( 0, 0, 0 ) );
	camera_ent = self get_camera_for_user( camera_name );
	if ( !isdefined( camera_ent ) )
	{
		return;
	}

	camera_ent linkto( ent, tag_name, origin_offset, angles_offset );
}