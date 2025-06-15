#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_cmd_util;

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

	if ( !test_obj.errored )
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
	else if ( is_str_int( clientnum_guid_or_name ) )
	{
		int_number = int( clientnum_guid_or_name );
		if ( int_number == -1 )
		{
			return set_cast_success( result_obj, undefined, "player==undefined" );
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
	if ( is_whole_number )
	{
		if ( entnum == 1023 )
		{
			return set_cast_success( result_obj, undefined, "ent==undefined" );
		}
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
	result_obj = result_obj_new( "boolean" );
	if ( str == "true" || str == "1" )
	{
		return set_cast_success( result_obj, true, str == "true" ? "boolean==true" : "boolean==1" );
	}
	else if ( str == "false" || str == "0" )
	{
		return set_cast_success( result_obj, false, str == "true" ? "boolean==false" : "boolean==0" );
	}

	return set_cast_error( result_obj, "boolean!=boolean" );
}

get_cmd_from_alias( alias )
{
	result_obj = result_obj_new( "cmdobject" );
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
				return set_cast_success( result_obj, level.tcs_cmds[ cmd_keys[ i ] ], "alias==" + cmd_keys[ i ] );
			}
		}
	}

	return set_cast_error( result_obj, "Couldn't find cmd" );
}

test_cmd_is_valid( cmd_object, args )
{
	self com_printcmd( cmd_object );
	if ( args.size < cmd_object.min_args )
	{
		self com_printerror( "Too few args: usage: " + cmd_object.usage );
		return false;
	}
	if ( args.size > cmd_object.max_args )
	{
		self com_printerror( "Too many args: usage: " + cmd_object.usage );
		return false;
	}
	if ( array_validate( cmd_object.arg_types ) && args.size > 0 )
	{
		arg_types = cmd_object.arg_types;
		for ( i = 0; i < args.size; i++ )
		{
			if ( !isdefined( level.tcs_arg_type_handlers[ arg_types[ i ] ] ) )
			{
				self com_printerror( "Unhandled argtype: '" + arg_types[ i ] + "' in cmd: '" + cmd_object.cmd_name + "'!" );
				continue;
			}

			if ( !isdefined( level.tcs_arg_type_handlers[ arg_types[ i ] ].checker_func ) )
			{
				continue;
			}

			if ( !self [[ level.tcs_arg_type_handlers[ arg_types[ i ] ].checker_func ]]( args[ i ] ) )
			{
				arg_num = i;
				self com_printerror( "Arg " + arg_num + " " + args[ i ] + " is " + level.tcs_arg_type_handlers[ arg_types[ i ] ].error_message );
				return false;
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
	result_obj = cast_str_to_bool( arg );
	return !result_obj.errored;
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
	result_obj = result_obj_new( "int" );
	return set_cast_success( result_obj, int( arg ), "int==true" );
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
	result_obj = result_obj_new( "float" );
	return set_cast_success( result_obj, float( arg ), "float==true" );
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
	result_obj = cast_str_to_vector( arg );
	return !result_obj.errored;
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
	cmd_find_result = get_cmd_from_alias( arg );
	return !cmd_find_result.errored;
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
	cmd_find_result = get_cmd_from_alias( arg );
	return cmd_find_result;	
}

arg_obj_rank_validate( arg )
{
	return isdefined( level.tcs_perms.ranks[ arg ] );
}

arg_obj_rank_generate()
{
	ranks = getarraykeys( level.tcs_perms.ranks );
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

arg_obj_string_validate( arg )
{
	list = [];
	val = 1;
	list["0"] = val;
	list["1"] = val;
	list["2"] = val;
	list["3"] = val;
	list["4"] = val;
	list["5"] = val;
	list["6"] = val;
	list["7"] = val;
	list["8"] = val;
	list["9"] = val;
	list["_"] = val;
	list["a"] = val;
	list["b"] = val;
	list["c"] = val;
	list["d"] = val;
	list["e"] = val;
	list["f"] = val;
	list["g"] = val;
	list["h"] = val;
	list["i"] = val;
	list["j"] = val;
	list["k"] = val;
	list["l"] = val;
	list["m"] = val;
	list["n"] = val;
	list["o"] = val;
	list["p"] = val;
	list["q"] = val;
	list["r"] = val;
	list["s"] = val;
	list["t"] = val;
	list["u"] = val;
	list["v"] = val;
	list["w"] = val;
	list["x"] = val;
	list["y"] = val;
	list["z"] = val;

	for ( i = 0; i < arg.size; i++ )
	{
		if ( !isdefined( list[ arg[ i ] ] ) )
		{
			return false;
		}
	}

	return true;
}

arg_obj_string_generate( arg )
{
	return "null";
}

arg_obj_model_validate( arg )
{
	return true;
} 

arg_obj_model_generate()
{
	return "null";
}

// unimplmented
arg_obj_model_cast( arg )
{
	result_obj = result_obj_new( "model" );
	return set_cast_success( result_obj, arg, "model==" + arg );
}