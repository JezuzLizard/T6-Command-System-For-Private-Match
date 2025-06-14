#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;

get_perk_from_alias_zm( alias )
{
	switch ( alias )
	{
		case "ju":
		case "jug":
		case "jugg":
		case "juggernog":
			return "specialty_armorvest";
		case "ro":
		case "rof":
		case "double":
		case "doubletap":
			return "specialty_rof";
		case "qq":
		case "quick":
		case "revive":
		case "quickrevive":
			return "specialty_quickrevive";
		case "sp":
		case "speed":
		case "fastreload":
		case "speedcola":
			return "specialty_fastreload";
		case "st":
		case "staminup":
		case "longersprint":
			return "specialty_longersprint";
		case "fl":
		case "flakjacket":
		case "flopper":
			return "specialty_flakjacket";
		case "ds":
		case "deadshot":
			return "specialty_deadshot";
		case "mk":
		case "mulekick":
			return "specialty_additionalprimaryweapon";
		case "tm":
		case "tombstone":
			return "specialty_scavenger";
		case "ww":
		case "whoswho":
			return "specialty_finalstand";
		case "ec":
		case "electriccherry":
			return "specialty_grenadepulldeath";
		case "va":
		case "vultureaid":
			return "specialty_nomotionsensor";
		case "all":
			return "all";
		default:
			return alias;
	}
}

perk_list_zm()
{
	if ( !isDefined( level._zm_perks ) )
	{
		level._zm_perks = [];
	}
	else 
	{
		return level._zm_perks; //Fix so even if quickrevive machine is removed it can still be given.
	}
	switch ( level.script )
	{
		case "zm_tomb":
			level._zm_perks = level._random_perk_machine_perk_list;
			return level._zm_perks;
		case "zm_transit": //Fix so you can give perks with cmds on maps without perk machines.
			level._zm_perks = array( "specialty_quickrevive", "specialty_rof", "specialty_fastreload", "specialty_armorvest", "specialty_longersprint", "specialty_scavenger" );
			return level._zm_perks;
		default:
			machines = getentarray( "zombie_vending", "targetname" );
			perks = [];

			for ( i = 0; i < machines.size; i++ )
			{
				if ( machines[ i ].script_noteworthy == "specialty_weapupgrade" )
					continue;

				perks[ perks.size ] = machines[ i ].script_noteworthy;
			}
			level._zm_perks = perks;
			return level._zm_perks;
	}
}

get_powerup_from_alias_zm( alias )
{
	switch ( alias )
	{
		case "nuke":
			return "nuke";
		case "insta":
		case "instakill":
			return "insta_kill";
		case "double":
		case "doublepoints":
			return "double_points";
		case "max":
		case "ammo":
		case "maxammo":
			return "full_ammo";
		case "carp":
			return "carpenter";
		case "sale":
		case "firesale":
			return "fire_sale";
		case "perk":
		case "freeperk":
			return "free_perk";
		case "blood":
		case "zombieblood":
			return "zombie_blood";
		case "points":
			return "bonus_points";
		case "teampoints":
			return "bonus_points_team";
		default:
			return alias;
	}
}

powerup_list_zm()
{
	return getarraykeys( level.zombie_include_powerups );
}

get_perma_perk_from_alias( alias )
{
	switch ( alias )
	{
		case "bo":
		case "boards":
			return "pers_boarding";
		case "re":
		case "revive":
			return "pers_reviveonperk";
		case "he":
		case "headshots":
			return "pers_multikill_headshots";
		case "ca":
		case "cashback":
			return "pers_cash_back_prone";
		case "in":
		case "instakill":
			return "pers_insta_kill";
		case "ju":
		case "jugg":
			return "pers_jugg";
		case "cr":
		case "carpenter":
			return "pers_carpenter";
		case "fl":
		case "flopper":
			return "pers_flopper_counter";
		case "pe":
		case "perklose":
			return "pers_perk_lose_counter";
		case "pp":
		case "pistolpoints":
			return "pers_double_points_counter";
		case "sn":
		case "sniperpoints":
			return "pers_sniper_counter";
		case "bx":
		case "boxweapon":
			return "pers_box_weapon_counter";
		case "nu":
		case "nube":
			return "pers_nube_counter";
		case "all":
			return "all";
		default: 
			return alias;
	}
}

permaperk_list_zm()
{
	return getarraykeys( level.pers_upgrades );
}

get_all_weapons()
{
	return getarraykeys( level.zombie_include_weapons );
}

weapon_is_upgrade( weapon )
{
	return issubstr( weapon, "upgraded" );
}

array_validate( array )
{
	return isdefined( array ) && isarray( array ) && array.size > 0;
}

server_safe_notify_thread( notify_name, index )
{
	wait( ( 0.05 * index ) + 0.05 );
	level notify( notify_name );
}

/*result_t*/ result_new( msg, filter, channels = "" )
{
	result = spawnstruct();
	result.msg = msg;
	result.filter = filter;
	result.channels = channels;
	result.errored = false;

	return result;
}

/*result_t*/ result_copy( result )
{
	copy_result = spawnstruct();
	copy_result.msg = result.msg;
	copy_result.filter = result.filter;
	copy_result.channels = result.channels;
	copy_result.errored = result.errored;
}

/*result_t*/ result_cmdinfo( msg )
{
	result = result_new( msg, "cmdinfo" );

	return result;
}

/*result_t*/ result_cmderror( msg )
{
	result = result_new( msg, "cmderror" );
	result.errored = true;

	return result;
}

/*result_obj_t*/ result_obj_new( expected_value_type, noprint = true )
{
	result_obj = spawnstruct();
	result_obj.errored = false;
	result_obj.noprint = noprint;
	result_obj.value = undefined;
	result_obj.type = "undefined";
	result_obj.msg = "";

	return result_obj;
}

/*result_obj_t*/ result_obj_copy( result_obj )
{
	copy_result_obj = spawnstruct();
	copy_result_obj.errored = result_obj.errored;
	copy_result_obj.noprint = result_obj.noprint;
	copy_result_obj.value = result_obj.value;
	copy_result_obj.type = result_obj.type;
	copy_result_obj.msg = result_obj.msg;

	return copy_result_obj;
}

/*result_obj_t*/ set_cast_error( result_obj, error_msg )
{
	result_obj.errored = true;
	result_obj.value = undefined;
	result_obj.type = "undefined";
	result_obj.msg = error_msg;

	return result_obj;
}

/*result_obj_t*/ set_cast_success( result_obj, new_value, success_msg )
{
	result_obj.value = new_value;
	result_obj.msg = success_msg;

	return result_obj;
}

/*result_obj_t*/ cast_str_to_self( result_obj, str )
{
	if ( str == "self" )
	{
		if ( is_true( self.is_server ) )
		{
			if ( isdedicated() )
			{
				return set_cast_error( result_obj, "You cannot use self as an arg for type player as the dedicated server" );
			}
			else
			{
				return set_cast_success( result_obj, level.host, "player==host" );
			}
		}

		return set_cast_success( result_obj, self, "player==self" );
	}

	return set_cast_error( result_obj, "player!=self" );
}

cast_classname_to_ent_array( result_obj, key_value )
{
	result_obj.type = "entarray";
	result_obj.value = getentarray( key_value, "classname" );
	result_obj.msg = "entarray==classname";
}

cast_script_noteworthy_to_ent_array( result_obj, key_value )
{
	result_obj.type = "entarray";
	result_obj.value = getentarray( key_value, "script_noteworthy" );
	result_obj.msg = "entarray==script_noteworthy";
}

cast_targetname_to_ent_array( result_obj, key_value )
{
	result_obj.type = "entarray";
	result_obj.value = getentarray( key_value, "targetname" );
	result_obj.msg = "entarray==targetname";
}

cast_origin_to_ent_array( result_obj, origin, maxdist, max )
{
	result_obj.type = "entarray";
	ents = getentarray();
	result_obj.value = get_array_of_closest( origin, ents, undefined, max, maxdist );
	result_obj.msg = "entarray==origin";
}

cast_origin_to_ent( result_obj, radius )
{

}

/*result_obj_t*/ cast_str_to_player( clientnum_guid_or_name, noprint = false )
{
	result_obj = result_obj_new( "player", noprint );

	if ( is_true( self.is_server ) || self.cmdpower >= level.CMD_POWER_MODERATOR )
	{
		partial_message = "clientnums and guids";
	}
	else 
	{
		partial_message = "clientnums";	
	}

	if ( level.players.size <= 0 )
	{
		return set_cast_error( result_obj, "No players currently in the server" );
	}

	if ( !isDefined( clientnum_guid_or_name ) )
	{
		return set_cast_error( result_obj, "Try using /playerlist to view " + partial_message + " to use a cmd on instead of the name" );
	}

	test_obj = result_obj_copy( result_obj );
	cast_str_to_self( test_obj, clientnum_guid_or_name );

	if ( test_obj.errored )
	{
		return test_obj;
	}

	is_whole_number = is_natural_num( clientnum_guid_or_name );
	if ( is_whole_number )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[ i ];
			
			client_num = int( clientnum_guid_or_name );
			if ( player getentitynumber() == client_num )
			{
				return set_cast_success( result_obj, player, "player==entnum" );
			}

			guid = int( clientnum_guid_or_name );
			if ( !is_true( player.pers["isBot"] ) && player getGUID() == guid )
			{
				return set_cast_success( result_obj, player, "player==guid" );
			}
		}
	}

	name = tolower( clientnum_guid_or_name );
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[ i ];

		target_playername = tolower( player.name );
		if ( issubstr( target_playername, name ) )
		{
			return set_cast_success( result_obj, player, "player==name" );
		}
	}

	return set_cast_error( result_obj, "Try using /playerlist to view " + partial_message + " to use a cmd on instead of the name" );
}

/*boolean*/ is_player_valid( player, checkignoremeflag, ignore_laststand_players )
{
	if ( !isdefined( player ) )
	{
		return false;
	}

	if ( !isalive( player ) )
	{
		return false;
	}

	if ( !isplayer( player ) )
	{
		return false;
	}

	if ( isdefined( player.is_zombie ) && player.is_zombie == 1 )
	{
		return false;
	}

	if ( player.sessionstate == "spectator" )
	{
		return false;
	}

	if ( player.sessionstate == "intermission" )
	{
		return false;
	}

	if ( isdefined( self.intermission ) && self.intermission )
	{
		return false;
	}

	if ( !( isdefined( ignore_laststand_players ) && ignore_laststand_players ) )
	{
		if ( isDefined( player.revivetrigger ) || is_true( player.lastand ) )
		{
			return false;
		}
	}

	if ( isdefined( checkignoremeflag ) && checkignoremeflag && player.ignoreme )
	{
		return false;
	}

	if ( isdefined( level.is_player_valid_override ) )
	{
		return [[ level.is_player_valid_override ]]( player );
	}

	return true;
}

/*result_obj_t*/ cast_str_to_entity( entnum_targetname_or_self, noprint = false )
{
	result_obj = result_obj_new( "entity", noprint );
	if ( !isDefined( entnum_targetname_or_self ) )
	{
		return set_cast_error( result_obj, "Missing value to find entity" );
	}

	entities = getentarray();
	if ( entities.size <= 0 )
	{
		return set_cast_error( result_obj, "No entities currently in the server" );
	}

	is_whole_number = is_natural_num( entnum_targetname_or_self );
	entnum = int( entnum_targetname_or_self );
	if ( is_whole_number && entnum < 1023 )
	{	
		for ( i = 0; i < entities.size; i++ )
		{
			ent = entities[ i ];
			if ( !is_entity_valid( ent ) )
			{
				continue;
			}
			if ( ent getentitynumber() == entnum )
			{
				return set_cast_success( result_obj, ent, "ent==entnum" );
			}
		}
	}

	for ( i = 0; i < entities.size; i++ )
	{
		ent = entities[ i ];
		if ( !is_entity_valid( ent ) )
		{
			continue;
		}
		if ( !isdefined( ent.targetname ) )
		{
			continue;
		}
		if ( ent.targetname == entnum_targetname_or_self )
		{
			return set_cast_success( result_obj, ent, "ent==targetname" );
		}
	}

	return set_cast_error( result_obj, "Couldn't find entity from input: " + entnum_targetname_or_self );
}

is_entity_valid( entity )
{
	if ( !isDefined( entity ) )
	{
		return false;
	}
	if ( isPlayer( entity ) )
	{
		return is_player_valid( entity );
	}
	return true;
}

getDvarStringDefault( dvarname, default_value )
{
	cur_dvar_value = getDvar( dvarname );
	if ( isDefined( cur_dvar_value ) && cur_dvar_value != "" )
	{
		return cur_dvar_value;
	}
	else 
	{
		setDvar( dvarname, default_value );
		return default_value;
	}
}

is_cmd_token( char )
{
	if ( isdefined( level.custom_cmds_tokens ) && isdefined( level.custom_cmds_tokens[ char ] ) )
	{
		return true;
	}
	return false;
}

is_str_int( str )
{
	numbers = [];
	for ( i = 0; i < 10; i++ )
	{
		numbers[ i + "" ] = i;
	}
	negative_sign[ "-" ] = true;
	if ( isdefined( negative_sign[ str[ 0 ] ] ) )
	{
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}
	for ( i = start_index; i < str.size; i++ )
	{
		if ( !isdefined( numbers[ str[ i ] ] ) )
		{
			return false;
		}
	}
	return true;
}

is_natural_num(str)
{
	return is_str_int( str ) && int( str ) >= 0;
}

is_str_float( str )
{
	numbers = [];
	for ( i = 0; i < 10; i++ )
	{
		numbers[ i + "" ] = i;
	}
	negative_sign[ "-" ] = true;
	if ( isdefined( negative_sign[ str[ 0 ] ] ) )
	{
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}
	period[ "." ] = true;
	periods_found = 0;
	if ( isdefined( period[ str[ str.size - 1 ] ] ) )
	{
		return false;
	}
	for ( i = start_index; i < str.size; i++ )
	{
		if ( isdefined( period[ str[ i ] ] ) )
		{
			periods_found++;
			if ( periods_found > 1 )
			{
				return false;
			}
			continue;
		}
		if ( !isdefined( numbers[ str[ i ] ] ) )
		{
			return false;
		}
	}
	return true;
}

is_whole_float( str )
{
	return ( is_str_float( str ) || is_str_int( str ) ) && float( str ) >= 0.0;
}

cast_str_to_vector( str )
{
	result_obj = result_obj_new( "vector" );
	floats = strTok( str, "," );
	if ( floats.size != 3 )
	{
		return set_cast_error( result_obj, "expected vector in format of x,x,x" );
	}
	for ( i = 0; i < floats.size; i++ )
	{
		if ( !is_str_float( floats[ i ] ) || !is_str_int( floats[ i ] ) )
		{
			return set_cast_error( result_obj, "expected vector component " + i + " to be a float or int type" );
		}
	}

	new_vector = ( float( floats[ 0 ] ), float( floats[ 1 ] ), float( floats[ 2 ] ) );
	return set_cast_success( result_obj, new_vector, "vector==vector" );
}

cast_bool_to_str( bool, binary_string_options )
{
	options = strTok( binary_string_options, " " );
	if ( options.size == 2 )
	{
		if ( bool )
		{
			return options[ 0 ];
		}
		else 
		{
			return options[ 1 ];
		}
	}
	return bool + "";
}

cast_str_to_bool( str )
{
	if ( str == "true" || str == "1" )
	{
		return true;
	}
	else if ( str == "false" || str == "0" )
	{
		return false;
	}

	return false;
}

repackage_args( args )
{
	args_string = "";
	if ( !isdefined( args ) )
	{
		return args_string;
	}
	for ( i = 0; i < args.size; i++ )
	{
		if ( i == ( args.size - 1 ) )
		{
			args_string = args_string + args[ i ];
			continue;
		}
		args_string = args_string + args[ i ] + " ";
	}
	return args_string;
}

cmd_add( cmd, is_clientcmd, cmdaliases, cmdusage, cmdfunc, rank_group, min_args, uses_player_validity_check, is_threaded_cmd )
{
	if ( !isdefined( level.tcs_cmds ) )
	{
		level.tcs_cmds = [];
		level.threaded_cmds = [];
	}
	if ( !isdefined( level.tcs_ranks[ rank_group ] ) )
	{
		level com_printf( "con|g_log", "cmderror", "Failed to register cmd " + cmd + ", attempted to use an unregistered rank_group " + rank_group );
		return;
	}
	aliases = [];
	aliases[ 0 ] = cmd;
	if ( isdefined( cmdaliases ) )
	{
		cmd_aliases_tokens = strTok( cmdaliases, " " );
		for ( i = 1; i < cmd_aliases_tokens.size; i++ )
		{
			aliases[ i ] = cmd_aliases_tokens[ i - 1 ];
		}
	}

	level.tcs_cmds[ cmd ] = spawnstruct();
	level.tcs_cmds[ cmd ].is_clientcmd = is_clientcmd;
	level.tcs_cmds[ cmd ].usage = cmdusage;
	level.tcs_cmds[ cmd ].func = cmdfunc;
	level.tcs_cmds[ cmd ].aliases = aliases;
	level.tcs_cmds[ cmd ].power = level.tcs_ranks[ rank_group ].cmdpower;
	level.tcs_cmds[ cmd ].min_args = min_args;
	level.tcs_cmds[ cmd ].uses_player_validity_check = uses_player_validity_check;
	level.tcs_cmds_total++;
	if ( is_true( is_threaded_cmd ) )
	{
		level.threaded_cmds[ cmd ] = true;
	}
	if ( !isdefined( level.cmd_groups ) )
	{
		level.cmd_groups = [];
	}
	if ( !isdefined( level.cmd_groups[ rank_group ] ) )
	{
		level.cmd_groups[ rank_group ] = [];
	}
	level.cmd_groups[ rank_group ][ cmd ] = true;	
}

cmd_remove( cmd )
{
	new_cmd_array = [];
	cmd_keys = getarraykeys( level.tcs_cmds );
	found_cmd = false;
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		cmd_k = cmd_keys[ i ];
		if ( cmd != cmd_k )
		{
			new_cmd_array[ cmd_k ] = spawnstruct();
			new_cmd_array[ cmd_k ].is_clientcmd = level.tcs_cmds[ cmd_k ].is_clientcmd;
			new_cmd_array[ cmd_k ].usage = level.tcs_cmds[ cmd_k ].usage;
			new_cmd_array[ cmd_k ].func = level.tcs_cmds[ cmd_k ].func;
			new_cmd_array[ cmd_k ].aliases = level.tcs_cmds[ cmd_k ].aliases;
			new_cmd_array[ cmd_k ].power = level.tcs_cmds[ cmd_k ].power;
			new_cmd_array[ cmd_k ].min_args = level.tcs_cmds[ cmd_k ].min_args;
			new_cmd_array[ cmd_k ].uses_player_validity_check = level.tcs_cmds[ cmd_k ].uses_player_validity_check;
		}
		else 
		{
			found_cmd = true;
			level.threaded_cmds[ cmd_k ] = undefined;
			rank_groups = getarraykeys( level.cmd_groups );
			for ( j = 0; j < rank_groups.size; j++ )
			{
				if ( isdefined( level.cmd_groups[ rank_groups[ i ] ][ cmd_k ] ) )
				{
					level.cmd_groups[ rank_groups[ i ] ][ cmd_k ] = undefined;
					break;
				}
			}
		}
	}
	if ( found_cmd )
	{
		level.tcs_cmds_total--;
	}
	level.tcs_cmds = new_cmd_array;
}

cmd_remove_by_group( rank_group )
{
	if ( !isdefined( level.cmd_groups[ rank_group ] ) )
	{
		return;
	}
	cmds = getarraykeys( level.cmd_groups[ rank_group ] );
	for ( i = 0; i < cmds.size; i++ )
	{
		cmd_remove( cmds[ i ] );
	}
}

cmd_set_power( cmd, power )
{
	if ( isdefined( level.tcs_cmds[ cmd ] ) )
	{
		level.tcs_cmds[ cmd ].power = power;
	}
}

arg_obj_add_cmd( cmd, arg_types )
{
	if ( !isdefined( level.tcs_cmds[ cmd ] ) )
	{
		level com_printf( "con|g_log", "cmderror", "arg_obj_add_cmd() " + cmd + " is not registered" );
		return;
	}
	if ( !isdefined( arg_types ) || arg_types == "" )
	{
		return;
	}
	level.tcs_cmds[ cmd ].arg_types = strTok( arg_types, " " );
}

arg_obj_register( argtype, checker_func, rand_gen_func, cast_func, error_message )
{
	if ( !isDefined( level.tcs_arg_type_handlers ) )
	{
		level.tcs_arg_type_handlers = [];
	}
	if ( !isDefined( argtype ) || argtype == "" )
	{
		return;
	}
	level.tcs_arg_type_handlers[ argtype ] = spawnStruct();
	level.tcs_arg_type_handlers[ argtype ].checker_func = checker_func;
	level.tcs_arg_type_handlers[ argtype ].rand_gen_func = rand_gen_func;
	level.tcs_arg_type_handlers[ argtype ].cast_func = cast_func;
	level.tcs_arg_type_handlers[ argtype ].error_message = error_message;
}

cmd_add_unittest_exclusion( cmd )
{
	if ( !isDefined( level.cmd_system_unittest_cmd_exclusions ) )
	{
		level.cmd_system_unittest_cmd_exclusions = [];
	}
	level.cmd_system_unittest_cmd_exclusions[ cmd ] = true;
}

handle_result_feedback( result, cmd, original_args, logprint, silent )
{
	if ( is_true( logprint ) && !is_true( level.doing_cmd_system_unittest ) )
	{
		cmd_log = self.name + " executed " + cmd + " " + repackage_args( original_args );
		level com_printf( "g_log", "cmdinfo", cmd_log );
	}
	if ( !isDefined( result ) || is_true( silent ) )
	{
		return;
	}
	if ( !isDefined( result.filter ) || result.filter == "" )
	{
		level com_printf( "con|g_log", "screrror", "Attempted to print feedback for " + cmd + " but no filter exists in the result" );
		return;
	}
	if ( !isDefined( result.msg ) )
	{
		level com_printf( "con|g_log", "screrror", "Attempted to print feedback for " + cmd + " but no message exists in the result" );
		return;
	}
	if ( result.msg == "" )
	{
		return;
	}

	channel = self com_get_cmd_feedback_channel();
	if ( result.channels != "" )
	{
		channel = result.channels;
	}

	level com_printf( channel, result[ "filter" ], result[ "message" ], self );
}

cmd_execute_internal( cmd, args, silent, logprint )
{
	original_args = args;
	channel = self com_get_cmd_feedback_channel();
	result = undefined;
	if ( !self test_cmd_is_valid( cmd, args ) )
	{
		return;
	}

	// Cast the args using the cast handlers
	// Arg types without a cast handler don't get casted
	// Leaving the casting up to the cmd itself
	if ( args.size > 0 )
	{
		arg_types = level.tcs_cmds[ cmd ].arg_types;
		for ( i = 0; i < args.size; i++ )
		{
			if ( isDefined( level.tcs_arg_type_handlers[ arg_types[ i ] ] ) && isDefined( level.tcs_arg_type_handlers[ arg_types[ i ] ].cast_func ) )
			{
				cast_result = self [[ level.tcs_arg_type_handlers[ arg_types[ i ] ].cast_func ]]( args[ i ] );
				if ( cast_result.errored )
				{
					level com_printf( channel, "cmderror", cast_result.msg, self );
					return;
				}
				args[ i ] = cast_result.value;
			}
		}
	}

	// Check if the cmd should execute if the target is in an invalid state
	// Could be changed to use handlers if entities or other types need to be validated
	// For not only checks players
	if ( is_true( level.tcs_cmds[ cmd ].uses_player_validity_check ) )
	{
		if ( isDefined( level.tcs_player_is_valid_check ) )
		{
			if ( level.tcs_cmds[ cmd ].is_clientcmd )
			{
				message = "You are not in a valid state for " + cmd + " to work";
				target = self;
			}
			else 
			{
				message = "Target " + args[ 0 ].name + " is not in a valid state for " + cmd + " to work";
				target = args[ 0 ];
			}
			if ( ![[ level.tcs_player_is_valid_check ]]( target ) )
			{
				level com_printf( channel, "cmderror", message, self );
				return;
			}
		}
	}

	if ( is_true( level.threaded_cmds[ cmd ] ) )
	{
		self thread [[ level.tcs_cmds[ cmd ].func ]]( args );
		return;
	}
	else 
	{
		result = self [[ level.tcs_cmds[ cmd ].func ]]( args );
	}

	self handle_result_feedback( result, cmd, original_args, logprint, silent );
}


//If we have a lot of clientdvars in the pool delay setting them to prevent client cmd overflow error.
set_client_dvar_thread( dvar, value, index )
{
	wait( index * 0.25 );
	self setClientDvar( dvar, value );
}

check_for_cmd_alias_collisions()
{
	wait 5;
	cmd_keys = getArrayKeys( level.tcs_cmds );
	aliases = [];
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		for ( j = 0; j < level.tcs_cmds[ cmd_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.tcs_cmds[ cmd_keys[ i ] ].aliases[ j ];
		}
	}
	for ( i = 0; i < aliases.size; i++ )
	{
		for ( j = i + 1; j < aliases.size; j++ )
		{
			if ( aliases[ i ] == aliases[ j ] )
			{
				level com_printf( "con", "cmderror", "Cmd alias collision detected alias " + aliases[ i ] + " is duplicated" );
				break;
			}
		}
	}
}

parse_cmd_message( message )
{
	if ( message == "" )
	{
		return [];
	}

	//Strip cmd tokens.
	stripped_message = message;
	if ( is_cmd_token( message[ 0 ] ) )
	{
		stripped_message = "";
		for ( i = 1; i < message.size; i++ )
		{
			stripped_message += message[ i ];
		}
	}

	multi_cmds = [];
	cmd_keys = [];
	multiple_cmds_keys = strTok( stripped_message, "|" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_args = strTok( multiple_cmds_keys[ i ], " " );
		cmd = get_cmd_from_alias( cmd_args[ 0 ] );
		if ( cmd != "" )
		{
			cmd_keys[ "cmd" ] = cmd;
			arrayremoveindex( cmd_args, 0 );
			cmd_keys[ "args" ] = [];
			cmd_keys[ "args" ] = cmd_args;
			multi_cmds[ multi_cmds.size ] = cmd_keys;
		}
	}

	return multi_cmds;
}

get_cmd_from_alias( alias )
{
	result_obj = result_obj_new( "cmdalias" );
	if ( alias == "" )
	{
		return set_cast_error( result_obj, "No alias provided" );
	}

	cmd_keys = getarraykeys( level.tcs_cmds );
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		for ( j = 0; j < level.tcs_cmds[ cmd_keys[ i ] ].aliases.size; j++ )
		{
			if ( alias == level.tcs_cmds[ cmd_keys[ i ] ].aliases[ j ] )
			{
				return cmd_keys[ i ];
			}
		}
	}

	return set_cast_error( result_obj, "Couldn't find cmd" );
}

test_cmd_is_valid( cmd, args )
{
	channel = self com_get_cmd_feedback_channel();
	if ( args.size < level.tcs_cmds[ cmd ].min_args )
	{
		level com_printf( channel, "cmderror", "Usage: " + level.tcs_cmds[ cmd ].usage, self );
		return false;
	}
	if ( isdefined( level.tcs_cmds[ cmd ].arg_types ) && args.size > 0 )
	{
		arg_types = level.tcs_cmds[ cmd ].arg_types;
		for ( i = 0; i < args.size; i++ )
		{
			if ( isdefined( level.tcs_arg_type_handlers[ arg_types[ i ] ] ) && isdefined( level.tcs_arg_type_handlers[ arg_types[ i ] ].checker_func ) )
			{
				if ( !self [[ level.tcs_arg_type_handlers[ arg_types[ i ] ].checker_func ]]( args[ i ] ) )
				{
					arg_num = i;
					level com_printf( channel, "cmderror", "Arg " + arg_num + " " + args[ i ] + " is " + level.tcs_arg_type_handlers[ arg_types[ i ] ].error_message, self );
					return false;
				}
			}
		}
	}
	return true;
}

arg_obj_player_validate( arg )
{
	return isdefined( self cast_str_to_player( arg ) ); 
}

arg_obj_player_generate()
{
	if ( is_true( self.is_server ) )
	{
		randomint = randomint( 3 );
	}
	else 
	{
		randomint = randomint( 4 );
	}
	players = getplayers();

	if ( players.size <= 0 )
	{
		return -1;
	}

	random_player = players[ randomint( players.size ) ];
	switch ( randomint )
	{
		case 0:
			return random_player getentitynumber();
		case 1:
			return random_player getguid();
		case 2:
			return random_player.name;
		case 3:
			return "self";
	}
}

arg_obj_player_cast( arg )
{
	return self cast_str_to_player( arg, true );
}

arg_obj_wholenum_validate( arg )
{
	return is_natural_num( arg );
}

arg_obj_wholenum_generate()
{
	return randomint( 1000000 );
}

arg_obj_boolean_validate( arg )
{
	return cast_str_to_bool( arg );
}

arg_obj_boolean_generate()
{
	return cointoss();
}

arg_obj_boolean_cast( arg )
{
	return cast_str_to_bool( arg );
}

arg_obj_int_validate( arg )
{
	return is_str_int( arg );
}

arg_obj_int_generate()
{
	return cointoss() ? randomint( 1000000 ) : randomint( 1000000 ) * -1;
}

arg_obj_int_cast( arg )
{
	return int( arg );
}

arg_obj_float_validate( arg )
{
	return is_str_float( arg ) || is_str_int( arg );
}

arg_obj_float_generate()
{
	return cointoss() ? randomFloat( 1000000 ) : randomFloat( 1000000 ) * -1;
}

arg_obj_float_cast( arg )
{
	return float( arg );
}

arg_obj_wholefloat_validate( arg )
{
	return is_whole_float( arg );
}

arg_obj_wholefloat_generate()
{
	return randomfloat( 1000000 );
}

arg_obj_vector_validate( arg )
{
	numbers_array = strTok( arg, "," );
	if ( numbers_array.size != 3 )
	{
		
		return false;
	}
	for ( i = 0; i < numbers_array.size; i++ )
	{
		if ( !is_str_float( numbers_array[ i ] ) && !is_str_int( numbers_array[ i ] ) )
		{
			return false;
		}
	}
	return true;
}

arg_obj_vector_generate()
{
	x = cointoss() ? randomfloat( 1000 ) : randomfloat( 1000 ) * -1;
	y = cointoss() ? randomfloat( 1000 ) : randomfloat( 1000 ) * -1;
	z = cointoss() ? randomfloat( 1000 ) : randomfloat( 1000 ) * -1;
	return x + "," + y + "," + z;
}

arg_obj_vector_cast( arg )
{
	return cast_str_to_vector( arg );
}

arg_obj_team_validate( arg )
{
	return isdefined( level.teams[ arg ] );
}

arg_obj_team_generate()
{
	return random( level.teams );
}

arg_obj_cmdalias_validate( arg )
{
	cmd_to_execute = get_cmd_from_alias( arg );
	return cmd_to_execute != "";
}

arg_obj_cmdalias_generate()
{
	cmd_keys = getarraykeys( level.tcs_cmds );
	aliases = [];
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		if ( is_true( level.cmd_system_unittest_cmd_exclusions[ cmd_keys[ i ] ] ) )
		{
			continue;
		}
		for ( j = 0; j < level.tcs_cmds[ cmd_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.tcs_cmds[ cmd_keys[ i ] ].aliases[ j ];
		}
	}
	return aliases[ randomInt( aliases.size ) ];
}

arg_obj_cmdalias_cast( arg )
{
	cmd_to_execute = get_cmd_from_alias( arg );
	return cmd_to_execute;	
}

arg_obj_rank_validate( arg )
{
	return isdefined( level.tcs_ranks[ arg ] );
}

arg_obj_rank_generate()
{
	ranks = getarraykeys( level.tcs_ranks );
	return ranks[ randomInt( ranks.size ) ]; 
}

arg_obj_entity_validate( arg )
{
	test_result = self cast_str_to_entity( arg );
	return !test_result.errored;
}

arg_obj_entity_generate()
{
	randomint = randomint( 2 );
	entities = getentarray();
	if ( entities.size <= 0 )
	{
		return -1;
	}
	random_entity = entities[ randomint( entities.size ) ];
	if ( is_true( self.is_server ) )
	{
		return random_entity getentitynumber();
	}
	switch ( randomint )
	{
		case 0:
			return random_entity getentitynumber();
		case 1:
			return "self";
	}
}

arg_obj_entity_cast( arg )
{
	return self cast_str_to_entity( arg, true );
}

arg_obj_hitloc_validate( arg )
{
	return isdefined( level.tcs_hitlocs[ arg ] );
}

arg_obj_hitloc_generate()
{
	hitlocs = getarraykeys( level.tcs_hitlocs );
	return hitlocs[ randomint( hitlocs.size ) ];
}

arg_obj_mod_validate( arg )
{
	return isdefined( level.tcs_mods[ toupper( arg ) ] );
}

arg_obj_mod_generate()
{
	mods = getarraykeys( level.tcs_mods );
	return mods[ randomInt( mods.size ) ];
}

arg_obj_mod_cast( arg )
{
	cast_obj = toupper( arg );
	return cast_obj;
}

arg_obj_idflags_validate( arg )
{
	return is_natural_num( arg ) && int( arg ) < 2048;
} 

arg_obj_idflags_generate()
{
	flags = 0;
	idflags_array = level.tcs_idflags;
	max_flags_to_add = randomint( level.tcs_idflags.size );
	for ( i = 0; i < max_flags_to_add && ( idflags_array.size > 0 ); i++ )
	{
		random_flag_index = randomint( idflags_array.size );
		flags |= idflags_array[ random_flag_index ];
		arrayremoveindex( idflags_array, random_flag_index );
	}

	return flags;
}

// unimplmented
arg_obj_idflags_cast( arg )
{

}

arg_obj_bot_validate( arg )
{
	player = self cast_str_to_player( arg );
	return isDefined( player ) && player istestclient();
} 

arg_obj_bot_generate()
{
	if ( is_true( self.is_server ) )
	{
		randomint = randomInt( 3 );
	}
	else 
	{
		randomint = randomInt( 4 );
	}

	bots = [];
	for ( i = 0; i < level.players.size; i++ )
	{
		if ( !level.players[ i ] istestclient() )
		{
			continue;
		}
		bots[ bots.size ] = level.players[ i ];
	}

	if ( bots.size <= 0 )
	{
		return -1;
	}

	random_bot = bots[ randomInt( bots.size ) ];
	switch ( randomint )
	{
		case 0:
			return random_bot getEntityNumber();
		case 1:
			return random_bot getGuid();
		case 2:
			return random_bot.name;
		case 3:
			return "self";
	}
}

arg_obj_bot_cast( arg )
{
	return self cast_str_to_player( arg, true );
}