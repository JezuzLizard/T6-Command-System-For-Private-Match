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

arg_obj_entity_validate( arg )
{
	test_result = self cast_str_to_entity( arg );
	return !test_result.errored;
}

arg_obj_entity_generate()
{
	randomint = randomint( 4 );
	entities = getentarray();
	if ( entities.size <= 0 )
	{
		return 1023;
	}
	random_entity = entities[ randomint( entities.size ) ];
	switch ( randomint )
	{
		case 0:
			return random_entity getentitynumber();
		case 1:
			if ( is_true( self.is_server ) )
			{
				return random_entity getentitynumber();
			}
			else
			{
				return "self";
			}
		case 2:
			return 1022;
		case 3:
			return 1023;
	}
}

arg_obj_entity_cast( arg )
{
	return self cast_str_to_entity( arg, true );
}

arg_obj_entity_allow_null_validate( arg )
{
	test_result = self cast_str_to_entity( arg, true, true );
	return !test_result.errored;
}

arg_obj_entity_allow_null_generate()
{
	return arg_obj_entity_generate();
}

arg_obj_entity_allow_null_cast( arg )
{
	return self cast_str_to_entity( arg, true, true );
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

arg_obj_actor_validate( arg )
{
	test_result = self cast_str_to_entity( arg );
	return !test_result.errored && isai( test_result.value );
} 

arg_obj_actor_generate()
{
	return undefined;
}

// unimplmented
arg_obj_actor_cast( arg )
{
	return self cast_str_to_entity( arg );
}

arg_obj_spawnable_classname_validate( arg )
{
	result_obj = result_obj_new( "spawnable_classname", "string" );

	if ( !isdefined( level.tcs_dynamic_spawns[ arg ] ) )
	{
		return set_cast_error( result_obj, "arg!=classname" );
	}

	return set_cast_success( result_obj, arg, "classname==" + arg );
}

arg_obj_spawnable_classname_generate()
{
	return undefined;
}

arg_obj_spawnable_classname_cast( arg )
{
	result_obj = result_obj_new( "spawnable_classname", "string" );

	if ( !isdefined( level.tcs_dynamic_spawns[ arg ] ) )
	{
		return set_cast_error( result_obj, "arg!=classname" );
	}

	return set_cast_success( result_obj, arg, "classname==" + arg );
}