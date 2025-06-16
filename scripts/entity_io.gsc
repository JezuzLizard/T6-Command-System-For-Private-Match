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



cmd_dumpent_f( target_obj, args )
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

main()
{
	cmd_block_set_rank_group( "cheat" );
	dumpent_cmd = level [[ level.tcs_add_cmd_func ]]( "saveent", "saveent", "saveent <type> [classname]", ::cmd_dumpent_f );
	dumpent_cmd arg_obj_add_cmd( "string string", 1, 2 );
}

init()
{
	level.spawnpoints_mapents_fh = fs_fopen( "spawns_" + getdvar( "mapname" ) + ".mapents", "append" );
	level.spawnpoints_gsc_fh = fs_fopen( "spawns_" + getdvar( "mapname" ) + ".gsc", "append" );
}