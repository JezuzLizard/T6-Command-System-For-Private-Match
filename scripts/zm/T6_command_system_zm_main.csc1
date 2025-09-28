#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;

// #include scripts\cmd\_utility;

// #include scripts\zm\cmd\modules\_utility;

main()
{
	register_tcs_handler( "spawnwallbuy", ::cmd_spawnwallbuy_callback );
	onplayerconnect_callback( ::wallbuy_player_connect );
}

cmd_spawnwallbuy_callback( localclientnum, oldstate, state )
{
	if ( state != oldstate )
	{
		wallbuy_callback( localclientnum, oldstate, state );
	}
}

wallbuy_player_connect( localclientnum )
{
	keys = getarraykeys( level._dynamically_spawned_active_wallbuys );
/#
	println( "Wallbuy connect cb : " + localclientnum );
#/

	if ( isdefined( level.createfx_enabled ) && level.createfx_enabled )
		return;

	for ( i = 0; i < _SIZE( keys.size ); i++ )
	{
		wallbuy = level._dynamically_spawned_active_wallbuys[keys[i]];
		fx = level._effect["m14_zm_fx"];

		if ( wallbuy.targetname == "buildable_wallbuy" )
			fx = level._effect["dynamic_wallbuy_fx"];
		else if ( isdefined( level._effect[wallbuy.zombie_weapon_upgrade + "_fx"] ) )
			fx = level._effect[wallbuy.zombie_weapon_upgrade + "_fx"];

		wallbuy.fx[localclientnum] = playfx( localclientnum, fx, wallbuy.origin, anglestoforward( wallbuy.angles ), anglestoup( wallbuy.angles ), 0.1 );
		target_struct = getstruct( wallbuy.target, "targetname" );

		if ( wallbuy.targetname == "buildable_wallbuy" )
			continue;

		target_model = spawn_weapon_model( localclientnum, wallbuy.zombie_weapon_upgrade, target_struct.model, target_struct.origin, target_struct.angles );
		target_model hide();
		target_model.parent_struct = target_struct;
		wallbuy.models[localclientnum] = target_model;
	}
}

wallbuy_callback( localclientnum, oldstate, state )
{
	if ( !isdefined( level._dynamically_spawned_active_wallbuys ) )
	{
		level._dynamically_spawned_active_wallbuys = [];
	}

	args = strtok( state, " " );
	newval = args[ 0 ];
	clientfieldname = args[ 1 ];
	origin = args[ 2 ];
	angles = args[ 3 ];
	additional_targetname_keys = strtok( args[ 4 ], "," );
	additional_target_keys = strtok( args[ 5 ], "," );

	struc = level._dynamically_spawned_active_wallbuys[ clientfieldname ];
	if ( !isdefined( struc ) )
	{
		return;
	}
/#
	println( "wallbuy callback " + localclientnum );
#/

	switch ( newval )
	{
		case "init":
			struct.models[localclientnum].origin = struct.models[localclientnum].parent_struct.origin;
			struct.models[localclientnum].angles = struct.models[localclientnum].parent_struct.angles;
			struct.models[localclientnum] hide();
			break;
		case "purchase":
			wait 0.05;

			if ( localclientnum == 0 )
				playsound( 0, "zmb_weap_wall", struct.origin );

			vec_offset = ( 0, 0, 0 );

			if ( isdefined( struct.models[localclientnum].parent_struct.script_vector ) )
				vec_offset = struct.models[localclientnum].parent_struct.script_vector;

			struct.models[localclientnum].origin = struct.models[localclientnum].parent_struct.origin + anglestoright( struct.models[localclientnum].angles + vec_offset ) * 8;
			struct.models[localclientnum] show();
			struct.models[localclientnum] moveto( struct.models[localclientnum].parent_struct.origin, 1 );
			break;
		case "hack":
			if ( isdefined( level.wallbuy_callback_hack_override ) )
				struct.models[localclientnum] [[ level.wallbuy_callback_hack_override ]]();
			break;
		case 3:


			struc = spawnstruct();
			break;
	}
}