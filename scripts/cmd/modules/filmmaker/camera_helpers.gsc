#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;
#include scripts\cmd\core\_hud_utility;

autoexec add_helpers()
{
	level._placed_cameras = [];
	addcallback( "on_player_connect", ::on_connect );
	addcallback( "on_player_disconnect", ::on_disconnect );

	level.server init_user_cameras(); // init the cameras for the server "player"
}

private on_connect()
{
	max_user_cameras = get_dvar_int_default( "max_user_cameras", 8 ); // 144 total...

	self init_user_cameras( max_user_cameras );
}

private on_disconnect()
{
	if ( isdefined( level._placed_cameras[ self.name ] ) )
	{
		foreach ( camera_name, cam in level._placed_cameras[ self.name ].cams )
		{
			level._placed_cameras[ self.name ].cams[ camera_name ] delete();
			level._placed_cameras[ self.name ].cams[ camera_name ] = undefined;
		}

		level._placed_cameras[ self.name ] = undefined;
	}
}

private init_user_cameras( limit )
{
	if ( !isdefined( level._placed_cameras[ self.name ] ) )
	{
		level._placed_cameras[ self.name ] = spawnstruct();
		level._placed_cameras[ self.name ].cams = [];
		level._placed_cameras[ self.name ].limit = limit;
	}
}

register_placed_camera( camera_name, origin, angles, model = "tag_origin" )
{
	if ( ( level._placed_cameras[ self.name ].cams.size + 1 ) > level._placed_cameras[ self.name ].limit )
	{
		return false;
	}

	cam_ent = spawn_camera_ent( camera_name, origin, angles, model );
	// check for reregistration
	if ( isdefined( level._placed_cameras[ self.name ].cams[ camera_name ] ) )
	{
		self unregister_placed_camera( camera_name );
	}

	level._placed_cameras[ self.name ].cams[ camera_name ] = cam_ent;
	return true;
}

unregister_placed_camera( camera_name )
{
	if ( isdefined( level._placed_cameras[ self.name ].cams[ camera_name ] ) )
	{
		level._placed_cameras[ self.name ].cams[ camera_name ] delete();
		level._placed_cameras[ self.name ].cams[ camera_name ] = undefined;
	}
}

get_placed_camera( camera_name )
{
	return level._placed_cameras[ self.name ].cams[ camera_name ];
}

placed_camera_exists( camera_name )
{
	return isdefined( level._placed_cameras[ self.name ].cams[ camera_name ] );
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
	if ( !isdefined( self._cmds_cameras[ camera_name ] ) )
	{
		return;
	}

	camera_ent = self._cmds_cameras[ camera_name ];
	camera_ent linkto( ent, tag_name, origin_offset, angles_offset );
}