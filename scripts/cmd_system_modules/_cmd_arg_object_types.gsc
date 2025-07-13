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
	cmd_find_result = cast_str_to_cmd( arg );
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
	cmd_find_result = cast_str_to_cmd( arg );
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
	result_obj = result_obj_new( "model", "string" );
	return set_cast_success( result_obj, arg, "model==" + arg );
}