#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

_C_LEFT()
{
	return level._fmt_str.size - level._fmt_pos;
}

_PUSH_POS_UNTIL_CHAR( c )
{
	start = level._fmt_pos;
	while ( _C_LEFT() > 0 )
	{
		if ( _GET_IDX_CHAR_AT( level._fmt_pos ) == c )
		{
			break;
		}
		level._fmt_pos++;
	}

	remaining = _C_LEFT();
	if ( remaining <= 0 )
	{
		// consume remaining
		level._fmt_final_str += getsubstr( level._fmt_str, start );
	}
	else
	{
		// we found the char!
		end = level._fmt_pos;
		level._fmt_final_str += getsubstr( level._fmt_str, start, end );
	}

	return remaining;
}

_PUSH_POS_UNTIL_CHARS( chars )
{
	start = level._fmt_pos;
	exit = false;
	while ( _C_LEFT() > 0 )
	{
		for ( i = 0; i < _SIZE( chars.size ); i++ )
		{
			c = chars[ i ];
			exit = _GET_IDX_CHAR_AT( level._fmt_pos ) == c;
			if ( exit )
			{
				break;
			}
		}

		if ( exit )
		{
			break;
		}

		level._fmt_pos++;
	}

	remaining = _C_LEFT();
	if ( remaining <= 0 )
	{
		// consume remaining
		level._fmt_final_str += getsubstr( level._fmt_str, start );
	}
	else
	{
		// we found the char!
		end = level._fmt_pos;
		level._fmt_final_str += getsubstr( level._fmt_str, start, end );
	}

	return remaining;
}

_PUSH_POS_WHILE_CHARS( chars )
{
	start = level._fmt_pos;
	while ( _C_LEFT() > 0 )
	{
		found = false;
		for ( i = 0; i < _SIZE( chars.size ); i++ )
		{
			c = chars[ i ];
			found = _GET_IDX_CHAR_AT( level._fmt_pos ) == c;
			if ( found )
			{
				break;
			}
		}

		if ( !found )
		{
			break;
		}

		level._fmt_pos++;
	}

	remaining = _C_LEFT();
	if ( remaining <= 0 )
	{
		// consume remaining
		level._fmt_final_str += getsubstr( level._fmt_str, start );
	}
	else
	{
		// we found the char!
		end = level._fmt_pos;
		level._fmt_final_str += getsubstr( level._fmt_str, start, end );
	}

	return remaining;
}

_PUSH_POS_UNTIL_PREDICATE( predicate, negate, arg1, arg2, arg3 )
{
	start = level._fmt_pos;
	while ( _C_LEFT() > 0 )
	{
		c = level._fmt_str[ level._fmt_pos ];
		result = undefined;
		if ( isdefined( arg3 ) )
		{
			result = [[ predicate ]]( c, arg1, arg2, arg3 );
		}
		else if ( isdefined( arg2 ) )
		{
			result = [[ predicate ]]( c, arg1, arg2 );
		}
		else if ( isdefined( arg1 ) )
		{
			result = [[ predicate ]]( c, arg1 );
		}
		else
		{
			result = [[ predicate ]]( c );
		}

		if ( negate )
		{
			result = !result;
		}

		if ( result )
		{
			break;
		}

		level._fmt_pos++;
	}

	remaining = _C_LEFT();
	if ( remaining <= 0 )
	{
		// consume remaining
		level._fmt_final_str += getsubstr( level._fmt_str, start );
	}
	else
	{
		// we found the char!
		end = level._fmt_pos;
		level._fmt_final_str += getsubstr( level._fmt_str, start, end );
	}

	return remaining;
}

_RESET_POS()
{
	level._fmt_pos = 0;
}

_RESET_FINAL_STR()
{
	level._fmt_final_str = "";
}

_SAVE_FMT()
{
	level._fmt_pos_save = level._fmt_pos;
	level._fmt_str_save = level._fmt_str;
	level._fmt_final_str_save = level._fmt_final_str;
}

_RESTORE_FMT()
{
	level._fmt_pos = level._fmt_pos_save;
	level._fmt_str = level._fmt_str_save;
	level._fmt_final_str = level._fmt_final_str_save;
}

_RESET_FMT( str )
{
	str = _DEFAULT( str, "" );
	level._fmt_pos = 0;
	level._fmt_str = str;
	level._fmt_final_str = "";
}

_CLEAR_FMT()
{
	level._fmt_pos = undefined;
	level._fmt_str = undefined;
	level._fmt_final_str = undefined;
}

_GET_IDX_CHAR_AT( i )
{
	c = "";
	//println( "t1: " + t );
	if ( i < level._fmt_str.size )
	{
		c = level._fmt_str[ i ];
		//println( "t2: " +  t2 );
	}

	return c;
}