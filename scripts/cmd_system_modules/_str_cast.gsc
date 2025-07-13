cast_contents_to_str( contents_int, noprint = false )
{
	result_obj = result_obj_new( "contents", "string", noprint );

	contents_str = "";
	keys = getarraykeys( level.tcs_contents );
	for ( i = 0; i < keys.size; i++ )
	{
		if ( ( contents_int & level.tcs_contents[ keys[ i ] ] ) != 0 )
		{
			if ( contents_str != "" )
			{
				contents_str += "|";
			}

			contents_str += keys[ i ];
		}
	}

	return set_cast_success( result_obj, contents_str, "contents==" + contents_str );
}

cast_str_to_contents( contents_str, noprint = false )
{
	result_obj = result_obj_new( "contents", "int", noprint );

	contents_int = level.tcs_contents[ "NONE" ];
	keys = strtok( contents_str, "|" );
	for ( i = 0; i < keys.size; i++ )
	{
		if ( isdefined( level.tcs_contents[ keys[ i ] ] ) )
		{
			contents_int |= level.tcs_contents[ keys[ i ] ];
		}
	}

	return set_cast_success( result_obj, contents_int, "contents==" + contents_int );
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

/*entity_obj_t*/ entity_obj_t_new( expected_etype, entnum = 1023 )
{
	entity_obj = generic_obj_t_new( "entity" );
	entity_obj.etype = expected_etype;
	entity_obj.entnum = entnum;
	entity_obj.ent = undefined;

	return entity_obj;
}

set_ent_cast_success( entity_obj, ent, msg )
{
	entity_obj.ent = entity_obj;
	entity_obj.entnum = ent getentitynumber();
	return set_cast_success( entity_obj, undefined, msg );
}

set_ent_cast_error( entity_obj, msg )
{
	return set_cast_error( entity_obj, msg );
}

/*entity_obj_t*/ cast_str_to_entity( str, expected_etype, allow_null_ent = false, allow_world_ent = false, finder_func = undefined, finder_arg1 = undefined, finder_arg2 = undefined )
{
	entity_obj = entity_obj_t_new( expected_etype );
	if ( !isDefined( str ) || str == "" )
	{
		return set_ent_cast_error( entity_obj, "Missing value to find entity" );
	}

	if ( !isdefined( expected_etype ) || !isdefined( level._entity_types[ expected_etype ] ) )
	{
		return set_ent_cast_error( entity_obj, "Unsupported etype" );
	}

	getter_func = level._entity_type_funcs[ expected_etype ];

	entities = [[ getter_func ]]();

	if ( entities.size <= 0 )
	{
		return set_ent_cast_error( entity_obj, "No entities found for etype: " + etype );
	}

	cast_number_obj = cast_str_to_number( str, "positive_int" );

	if ( !cast_number_obj.errored )
	{
		entnum = cast_number_obj.casted_value;
		if ( entnum > 1023 )
		{
			return set_ent_cast_error( entity_obj, "Entity number cannot be greater than 1023" );
		}

		if ( entnum == 1023 )
		{
			if ( allow_null_ent )
			{
				return set_ent_cast_success( entity_obj, undefined, "ent==allow_null_ent" );
			}
			else
			{
				return set_ent_cast_error( entity_obj, "ent!=allow_null_ent" );
			}
		}
		else if ( entnum == 1022 )
		{
			if ( allow_world_ent )
			{
				return set_ent_cast_success( entity_obj, getentbynum( 1022 ), "ent==allow_world_ent" );
			}
			else
			{
				return set_ent_cast_error( entity_obj, "ent!=allow_world_ent" );
			}
		}

		for ( i = 0; i < entities.size; i++ )
		{
			ent = entities[ i ];

			if ( ent getentitynumber() == entnum )
			{
				return set_ent_cast_success( entity_obj, ent, "ent==entnum" );
			}

			if ( expected_etype == "player" && !is_true( ent.pers[ "isBot" ] ) )
			{
				if ( ent getGUID() == entnum )
				{
					return set_ent_cast_success( entity_obj, ent, "ent==GUID" );
				}
			}
		}

		return set_ent_cast_error( entity_obj, "Could not cast numeric value to etype: '" + expected_etype + "'" );
	}

	is_whole_number = is_natural_num( entnum_targetname_or_self );


	for ( i = 0; i < entities.size; i++ )
	{
		ent = entities[ i ];

		if ( !isdefined( ent ) )
		{
			continue;
		}

		if ( isdefined( finder_func ) && ent [[ finder_func ]]( str, expected_etype, finder_arg1, finder_arg2 ) )
		{
			return set_ent_cast_success( entity_obj, ent, "ent==finder_func" );
		}

		if ( expected_etype == "player" )
		{
			target_playername = tolower( ent.name );
			if ( issubstr( target_playername, str ) )
			{
				return set_ent_cast_success( entity_obj, player, "player==name" );
			}
		}
	}

	return set_ent_cast_error( result_obj, "Couldn't find entity from input: " + str );
}

is_str_int( str )
{
	cast_obj = cast_str_to_number( str, "int" );
	return !cast_obj.errored;
}

is_str_natural_int( str )
{
	cast_obj = cast_str_to_number( str, "natural_int" );
	return !cast_obj.errored;
}

is_str_positive_int( str )
{
	cast_obj = cast_str_to_number( str, "positive_int" );
	return !cast_obj.errored;
}

is_str_float( str )
{
	cast_obj = cast_str_to_number( str, "float" );
	return !cast_obj.errored;
}

is_str_positive_float( str )
{
	cast_obj = cast_str_to_number( str, "positive_float" );
	return !cast_obj.errored;
}

/*str_cast_obj_t*/ str_cast_obj_t_new( type = "undefined", str_value = "" )
{
	str_cast_obj = generic_obj_t_new( "str_cast" );
	str_cast_obj.number_type = type;
	str_cast_obj.casted_value = undefined;
	str_cast_obj.str_value = str_value;

	if ( !isdefined( level._number_strings[ type ] ) )
	{
		assert( false );
		return set_cast_error( str_cast_obj, "Unknown type: " + type );
	}
	return str_cast_obj;
}

cast_str_to_number( str, type )
{
	str_cast_obj = str_cast_obj_t_new( type, str );

	if ( str_cast_obj.errored )
	{
		return str_cast_obj
	}

	if ( str[ 0 ] == "-" )
	{
		if ( type != "float" || type != "int" )
		{
			return set_cast_error( str_cast_obj, "Unexpected negative sign" );
		}
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}

	syntax = level._number_strings [ type ];

	period_allowed = false;
	if ( type == "float" || type == "positive_float" )
	{
		period_allowed = true;
	}
	
	periods_found = 0;
	if ( str[ str.size - 1 ] == "." )
	{
		return set_cast_error( str_cast_obj, "Trailing decimal point is not allowed" );
	}
	for ( i = start_index; i < str.size; i++ )
	{
		if ( period_allowed && str[ i ] == "." )
		{
			periods_found++;
			if ( periods_found > 1 )
			{
				return set_cast_error( str_cast_obj, "Cannot have more than one decimal point" );
			}
			continue;
		}
		if ( str[ i ] == "-" )
		{
			return set_cast_error( str_cast_obj, "Succeeding or multiple negative signs are not allowed" );
		}
		if ( !isdefined( syntax[ str[ i ] ] ) )
		{
			return set_cast_error( str_cast_obj, "Invalid character for type" );
		}
	}

	switch ( type )
	{
		case "natural_int":
		case "positive_int":
		case "int":
			str_cast_obj.casted_value = int( str );
			break;
		case "positive_float":
		case "float":
			str_cast_obj.casted_value = float( str );
			break;
	}

	return set_cast_success( str_cast_obj );
}

cast_str_to_vector( str )
{
	result_obj = result_obj_new( "vector", "vector" );
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
	lower_str = tolower( str );
	result_obj = result_obj_new( "boolean", "boolean" );
	if ( lower_str == "true" || lower_str == "1" )
	{
		return set_cast_success( result_obj, true, lower_str == "true" ? "boolean==true" : "boolean==1" );
	}
	else if ( lower_str == "false" || lower_str == "0" )
	{
		return set_cast_success( result_obj, false, lower_str == "false" ? "boolean==false" : "boolean==0" );
	}

	return set_cast_error( result_obj, "boolean!=boolean" );
}

cast_str_to_cmd( alias )
{
	result_obj = result_obj_new( "cmdobject", "struct" );
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

	return set_cast_error( result_obj, "Unknown cmd: '" + alias + "'" );
}