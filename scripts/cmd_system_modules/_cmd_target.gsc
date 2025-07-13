target_cast( etype, directive_type, directive_args )
{
	obj = generic_obj_t_new( "target_cast" );

	obj.value = get_entity_targets( etype, directive_type, directive_args );
	if ( !isdefined( obj.value ) || obj.value.size == 0 )
	{
		obj.errored = true;
		obj.msg = "Failed to find any compatible entities";
	}

	return obj;
}

cast_to_array( item )
{
	new_array = [];
	new_array[ new_array.size ] = item;
	return new_array;
}

get_random_limited_array( array, limit )
{
	new_array = [];
	array = array_randomize( array );
	for ( i = 0; i < limit; i++ )
	{
		new_array = add_to_array( new_array, array[ i ] );
	}

	return new_array;
}

get_executors( executor_type, directive_args )
{
	executors = [];
	switch ( executor_type )
	{
		case "all":
			executors = level.players;
			return executors;
		case "undefined": // error
			return [];
		case "random":
			limit = 1;
			if ( isdefined( directive_args[ 0 ] ) )
			{
				limit = int( directive_args[ 0 ] );
			}
			
			return get_random_limited_array( level.players, limit );
		case "array":
			players = [];
			foreach ( presumed_player in directive_args )
			{
				players[ players.size ] = cast_str_to_entity( presumed_player, "player" );
			}

			return players;
		case "array_random":
			players = [];
			foreach ( presumed_player in directive_args )
			{
				players[ players.size ] = cast_str_to_entity( presumed_player, "player" );
			}

			return add_to_array( undefined, random( players ) );
		case "self":
			return add_to_array( undefined, self );
		case "default":
			return add_to_array( undefined, self.default_executor );
	}
}

get_entity_targets( etype, directive_type, directive_args )
{
	assert( isplayer( self ) );

	if ( !isdefined( level._entity_type_funcs[ etype ] ) )
	{
		assert( false );
		return [];
	}

	ents = undefined;
	switch ( directive_type )
	{
		case "all":
			ents = [[ level._entity_type_funcs [ etype ] ]]();
			return ents;
		case "undefined":
			return [];
		case "random":
			ents = [[ level._entity_type_funcs [ etype ] ]]();
			limit = 1;
			if ( isdefined( directive_args[ 0 ] ) )
			{
				limit = int( directive_args[ 0 ] );
			}
			
			return get_random_limited_array( ents, limit );
		case "array":
		case "array_random":
			ents = [];
			foreach ( presumed_ent in directive_args )
			{
				ents[ ents.size ] = cast_str_to_entity( presumed_ent, etype );
			}

			if ( directive_type == "array" )
			{
				return ents;
			}
			else
			{
				return add_to_array( undefined, random( ents ) );
			}
			
		case "self":
			return add_to_array( undefined, self );
		case "default":
			return add_to_array( undefined, self.default_target );
	}
}

get_zbarrier_targets()
{
	return getzbarrierarray();
}

get_script_mover_targets()
{
	return getscriptmoverarray();
}

get_spawner_targets()
{
	return getspawnerarray();
}

get_item_targets()
{
	return getitemarray();
}

get_corpse_targets()
{
	return getcorpsearray();
}

// very nice builtin which allows get entities in an arbitrary abstract volume
// GetTouchingVolume( vec, vec, vec );

get_targets_by_func()
{

}

target_obj_add_cmd( target_type_name, is_required_target, doc_string )
{
	if ( !is_true( self.is_cmd_object ) )
	{
		assert( false );
		return;
	}

	if ( !isdefined( target_type_name ) || target_type_name == "" )
	{
		return;
	}

	self.target_types[ self.target_types.size ] = spawnstruct();
	target_type = self.target_types[ self.target_types.size - 1 ];
	target_type.etype = target_type_name;
	target_type.is_required = is_required_target;
	target_type.max_targets = 18;
}