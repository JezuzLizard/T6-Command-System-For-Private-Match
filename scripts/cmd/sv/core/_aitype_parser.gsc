#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;
#include scripts\cmd\sv\core\_hud_utility;

// RULE 1: 'self' is always a aitype_parse_obj_t object

/*aitype_parse_obj_t*/ private aitype_parse_obj_t_new( aitype )
{
	aitype_parse_obj = generic_obj_t_new( "aitype_parse" );
	aitype_parse_obj.aitype = 
	aitype_parse_obj.animations = []; // string -> struct of {type, desc}
	aitype_parse_obj.characters = [];
	aitype_parse_obj.keys[ "accuracy" ] = 1;
	aitype_parse_obj.keys[ "animtree" ] = "";
	aitype_parse_obj.keys[ "animstatedef" ] = "";
	aitype_parse_obj.keys[ "csvinclude" ] = "";
	aitype_parse_obj.keys[ "demolockonhighlightdistance" ] = 100;
	aitype_parse_obj.keys[ "demolockonviewheightoffset1" ] = 8;
	aitype_parse_obj.keys[ "demolockonviewheightoffset2" ] = 8;
	aitype_parse_obj.keys[ "demolockonviewpitchmax1" ] = 60;
	aitype_parse_obj.keys[ "demolockonviewpitchmax2" ] = 60;
	aitype_parse_obj.keys[ "demolockonviewpitchmin1" ] = 0;
	aitype_parse_obj.keys[ "demolockonviewpitchmin2" ] = 0;
	aitype_parse_obj.keys[ "footstepfxtable" ] = "";
	aitype_parse_obj.keys[ "footstepprepend" ] = "";
	aitype_parse_obj.keys[ "footstepscriptcallback" ] = 0;
	aitype_parse_obj.keys[ "grenadeammo" ] = 0;
	aitype_parse_obj.keys[ "grenadeweapon" ] = "";
	aitype_parse_obj.keys[ "health" ] = 200;
	aitype_parse_obj.keys[ "precachescript" ] = "";
	aitype_parse_obj.keys[ "secondaryweapon" ] = "";
	aitype_parse_obj.keys[ "sidearm" ] = "";
	aitype_parse_obj.keys[ "subclass" ] = "regular";
	aitype_parse_obj.keys[ "team" ] = "axis";
	aitype_parse_obj.keys[ "type" ] = "zombie";
	aitype_parse_obj.keys[ "weapon" ] = "";
	min_engagement_dist = [];
	min_engagement_dist[ "x" ] = 256.0;
	min_engagement_dist[ "y" ] = 0.0;
	max_engagement_dist = [];
	max_engagement_dist[ "x" ] = 768.0;
	max_engagement_dist[ "y" ] = 1024.0;
	aitype_parse_obj.keys[ "setengagementmindist" ] = min_engagement_dist;
	aitype_parse_obj.keys[ "setengagementmaxdist" ] = max_engagement_dist;
	aitype_parse_obj.keys[ "setcharacterindex" ] = 0;
	aitype_parse_obj.keys[ "get_random_character" ] = 0;
	aitype_parse_obj.keys[ "setspawnerteam" ] = aitype_parse_obj.keys[ "team" ];
	aitype_parse_obj.keys[ "reference_anims_from_animtree" ] = "()";
	aitype_parse_obj.keys[ "precacheanimstatedef" ] = aitype_parse_obj.keys[ "animstatedef" ];
	aitype_parse_obj.keys[ "precache" ] = [];

	return aitype_parse_obj;
}

/*aitype_parse_obj_t*/ private aitype_parse_obj_t_new( key, type, desc )
{
	desc = _DEFAULT( desc, "No description" );
	struc = spawnstruct();
	struc.obj_type = "aitype_parse_data";
	struc.type = type;
	struc.desc = desc;
	self.data[ key ] = struc;
}

_fs_readline_trimmed( fh )
{
	line = fs_readline( fh );
	if ( !isdefined( line ) )
	{
		return line;
	}

	trimmed_line = _TRIM( line );
	return trimmed_line;
}

private in_function_reference_anims_from_animtree( aitype_parse_obj )
{
	for ( ;; )
	{
		line = fs_readline( level._radiant_keys_file );

		if ( !isdefined( line ) )
		{
			return; // ??
		}

		if ( line == "" || line == "\n" || line == "\r" || line == "\t" )
		[
			continue;
		]

		if ( line[ 0 ] == "{" )
		{
			continue;
		}
		else if ( line[ 0 ] == "}" )
		{
			return;
		}

		trimmed_line = _REMOVE_WHITESPACE( line );
		tokens = strtok( line, "=" );

		animation = getsubstr( tokens[ 1 ], 1, ( tokens[ 1 ].size - 1 ) )
		aitype_parse_obj.animations[ aitype_parse_obj.animations.size ] = animation;
	}
}

private in_function_main( aitype_parse_obj )
{
	for ( ;; )
	{
		trimmed_line = _fs_readline_trimmed( level._radiant_keys_file );

		if ( !isdefined( line ) )
		{
			return; // ??
		}

		if ( line[ 0 ] == "{" )
		{
			continue;
		}
		else if ( line[ 0 ] == "}" )
		{
			return;
		}

		if ( !_I_STRICMP( trimmed_line, "switch" ) )
		{
			in_switch = 1;

			for ( ;; )
			{
				line = fs_readline( level._radiant_keys_file );

				if ( !isdefined( line ) )
				{
					return; // ??
				}

				if ( line[ 0 ] == "{" )
				{
					in_switch++;
					continue;
				}
				else if ( line[ 0 ] == "}" )
				{
					in_switch--;
					if ( in_switch == 0 )
					{
						break;
					}
				}

				if ( !_I_STRICMP( line, "case", 4 ) )
				{
					pos = 3;
					start = 4;
					for ( ;; )
					{
						pos++;
						if ( !isdefined( line[ pos ] ) )
						{
							break;
						}
						if ( line[ pos ] == ":" )
						{
							number = getsubstr( line, start, ( pos - 1 ) );
						}
						if ( line[ pos ] == " " )
						{
							start++;
							continue;
						}
					}
					for ( ;; )
					{
						line = fs_readline( level._radiant_keys_file );

						if ( !isdefined( line ) )
						{
							return; // ??
						}
					}
				}
			}
		}
		else if ( !_I_STRICMP( trimmed_line, "self " ) )
		{
			start = 5;
			end = trimmed_line.size - 1;
			for ( i = start; i < _SIZE( trimmed_line.size ); i++ )
			{
				if ( trimmed_line[ i ] == "(" )
				{
					end = ( i - 1 );
					break;
				}
			}

			function_name = getsubstr( trimmed_line, start, end );
		}
		else if ( !_I_STRICMP( trimmed_line, "self." ) )
		{

		}
		else if ( !_I_STRICMP( trimmed_line, "randchar" ) )
		{
			continue;
		}

		in_field = false;
		in_string = false;
		in_function_call = false;

		// pre parse line
		for ( i = 0; i < _SIZE( line.size ); i++ )
		{
			if ( line[ i ] == "." )
			{
				in_field = true;
				break;
			}
			if ( line[ i ] == "\"" )
			{
				in_string = true; // ??
				break;
			}
			if ( line[ i ] == "(" )
			{
				in_function_call = true;
				break;
			}
		}

		if ( in_field )
		{
			tokens = [];
			start = 0;
			for ( i = 0; i < _SIZE( line.size ); i++ )
			{
				if ( line[ i ] == "." )
				{
					start = i;
					for ( j = start; j < _SIZE( line.size ); j++ )
					{
						if ( _IS_WHITESPACE( line[ j ] ) )
						{
							continue;
						}
						if ( line[ j ] == "=" )
						{
							tokens[ tokens.size ] = getsubstr( line, start, ( j - 1 ) );
							break;
						}
					}
				}
				if ( line[ i ] == "=" )
				{
					start = i;
					j = start;
					for ( ; j < _SIZE( line.size ); j++ )
					{
						if ( _IS_WHITESPACE( line[ j ] ) )
						{
							start++;
							continue;
						}

						tokens[ tokens.size ] = getsubstr( line, start, ( line.size - 1 ) );
						break;
					}
				}
			}
		}

		if ( in_function_call )
		{

		}
		if ( trimmed_line.size >= 4 )
		{
			if ( getsubstr( trimmed_line, 0, 4 ) == "self." )
			{
				in_field = true;
			}
		}

		tokens = [];
		if ( in_field )
		{
			// remove ent on left
			tokens = strtok( trimmed_line, "." );
			kvps = strtok( trimmed_line, "=" );

			key = kvps[ 0 ];
			value = getsubstr( kvps[ 1 ], 0, ( kvps[ 1 ].size - 1 ) );
		}
		for ( i = 0; i < _SIZE( trimmed_line ); i++ )
		{

		}

		tokens = strtok( line, "=" );

		if ( tokens.size != 1 )
		{

		}
		else
		{
			tokens = strtok( line, "(" );
		}

		animation = getsubstr( tokens[ 1 ], 1, ( tokens[ 1 ].size - 1 ) )
		aitype_parse_obj.animations[ aitype_parse_obj.animations.size ] = animation;
	}
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

	level._aitype_anims = [];
	level._aitype_name = "";

	level._radiant_keys_file = fs_fopen( "cmd/assets/keys.txt", "read" );
	level._aitype_anims[ level._aitype_name ] = [];

	level._radiant_keys_obj = radiant_keys_parse_obj_t_new();

	level._fmt_pos = 0;
	level._fmt_str = "";
	level._fmt_final_str = "";

	in_function = false;

	for ( ;; )
	{
		line = fs_readline( level._radiant_keys_file );

		if ( !isdefined( line ) )
		{
			break;
		}

		if ( in_function )
		{
			// parse functions
			// 1, reference_anims_from_animtree
			// 2, main
			// 3, spawner
			// 4, precache
			continue;
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

		if ( line[ 0 ] == "#" )
		{
			// parse include or animtree
			continue;
		}

		if ( is_alpha_numeric( line[ 0 ] ) )
		{
			in_function = true;
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