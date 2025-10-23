#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;
#include scripts\cmd\sv\core\_hud_utility;

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

	for ( i = 0 ; i < _SIZE( level._radiant_key_types.size ); i++ )
	{
		key = level._radiant_key_types[ i ];
		level._radiant_key_types_keys[ key ] = i;
	}

	level._radiant_keys_file = fs_fopen( "cmd/assets/keys.txt", "read" );

	level._radiant_keys_obj = radiant_keys_parse_obj_t_new();

	level._fmt_pos = 0;
	level._fmt_str = "";
	level._fmt_final_str = "";

	for ( ;; )
	{
		line = fs_readline( level._radiant_keys_file );

		if ( !isdefined( line ) )
		{
			break;
		}

		// skip empty lines
		if ( line == "" )
		{
			continue;
		}

		// skip lines with comments at the start
		if ( line[ 0 ] == "/" )
		{
			continue;
		}

		_RESET_FMT( line );
		
		// consume type
		remaining = _PUSH_POS_UNTIL_PREDICATE( ::is_alpha_numeric, true, true );
		type = level._fmt_final_str;
		_RESET_FINAL_STR();
		if ( _MY_ASSERT_HANDLER( remaining > 0, "1Early end to radiant line parse Line: '{}', ParseToken: '{}', Remaining '{}'", level._fmt_str, type, remaining ) )
		{
			continue;
		}

		// skip this token
		if ( type == "client" )
		{
			continue;
		}

		if ( _MY_ASSERT_HANDLER( isdefined( level._radiant_key_types_keys[ type ] ), "Invalid type '{}', Line: '{}', ParseToken: '{}', Remaining '{}'", type, level._fmt_str, type, remaining ) )
		{
			continue;
		}

		// skip arbitrary characters between the type and the key
		remaining = _PUSH_POS_UNTIL_PREDICATE( ::is_alpha_numeric, false, true );
		_RESET_FINAL_STR();
		if ( _MY_ASSERT_HANDLER( remaining > 0, "2Early end to radiant line parse Line: '{}', ParseToken: '{}', Remaining '{}'", level._fmt_str, level._fmt_final_str, remaining ) )
		{
			continue;
		}

		// consume the key
		remaining = _PUSH_POS_UNTIL_PREDICATE( ::is_alpha_numeric, true, true );
		key = level._fmt_final_str;
		_RESET_FINAL_STR();
		if ( remaining <= 0 )
		{
			level._radiant_keys_obj radiant_key_obj_t_new( key, type );
			continue;
		}

		// skip the characters between the comment
		remaining = _PUSH_POS_WHILE_CHARS( "/ \t\r" );
		_RESET_FINAL_STR();
		if ( remaining <= 0 )
		{
			level._radiant_keys_obj radiant_key_obj_t_new( key, type );
			continue;
		}

		// find the start of the description
		// remaining = _PUSH_POS_UNTIL_PREDICATE( ::is_alpha_numeric, false, true );
		// if ( _MY_ASSERT_HANDLER( remaining > 0, "5Early end to radiant line parse Line: '{}', ParseToken: '{}', Remaining '{}'", level._fmt_str, level._fmt_final_str, remaining ) )
		// {
		// 	continue;
		// }
		
		desc =  getsubstr( line, level._fmt_pos );
		level._radiant_keys_obj radiant_key_obj_t_new( key, type, desc );
	}

	_CLEAR_FMT();

	fs_fclose( level._radiant_keys_file );

	print_radiant_keys();
}

print_radiant_keys()
{
	keys = getarraykeys( level._radiant_keys_obj.data );
	for ( i = 0; i < _SIZE( keys.size ); i++ )
	{
		member = level._radiant_keys_obj.data[ keys[ i ] ];

		_GET_SERVER_ENTITY() com_printnotitle( "Key: '{}', Type: '{}', Desc: '{}'", keys[ i ], member.type, member.desc );
	}
}