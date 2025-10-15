// RULE 1: 'self' is always a radiant_keys_parse_obj_t object

/*radiant_keys_parse_obj_t*/ private radiant_keys_parse_obj_t_new()
{
	radiant_keys_obj = generic_obj_t_new( "radiant_keys" );
	radiant_keys_obj.data = []; // string -> struct of {type, desc}
	
	return radiant_keys_obj;
}

/*radiant_key_obj_t*/ private radiant_key_obj_t_new( key, type, desc )
{
	desc = _DEFAULT( desc, "No description" );
	struc = spawnstruct();
	struc.obj_type = "radiant_key_data";
	struc.type = type;
	struc.desc = desc;
	self.data[ key ] = struc;
}

parse_radiant_keys()
{
	level._radiant_key_types = [];
	level._radiant_key_types[ 0 ] = "int";
	level._radiant_key_types[ 1 ] = "float";
	level._radiant_key_types[ 2 ] = "vector";
	level._radiant_key_types[ 3 ] = "string";

	level._radiant_keys_file = fs_fopen( "cmd/assets/keys.txt", "read" );

	level._radiant_keys_obj = radiant_keys_parse_obj_t_new();

	for ( ;; )
	{
		line = fs_readline( level._radiant_keys_file )

		if ( !isdefined( line ) )
		{
			break;
		}

		start_pos = 0;
		end_pos = start_pos;
		found_token = false;
		tokens = [];
		for ( i = 0; i < _SIZE( line.size ); i++ )
		{
			token = line[ i ];
			if ( token == " " )
			{
				if ( found_token )
				{
					found_token = false;
					end_pos = ( i - 1 );
					tokens[ tokens.size ] = getsubstr( line, start_pos, end_pos );
				}
				continue;
			}

			if ( is_alpha_numeric( token, true ) && !found_token )
			{
				found_token = true;
				start_pos = i;
				continue;
			}

			if ( token == "/" )
			{
				j = i;
				for ( ; j < _SIZE( line.size ); j++ )
				{
					if ( token == "/" || token = " " )
					{
						continue;
					}

					break;
				}

				tokens[ tokens.size ] = getsubstr( line, j );
				break;
			}
		}

		level._radiant_keys_obj radiant_key_obj_t_new( tokens[ 0 ], tokens[ 1 ], tokens[ 2 ] );
	}
}