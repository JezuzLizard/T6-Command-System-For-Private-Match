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
	result_obj = result_obj_new( "int", "int" );
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
	result_obj = result_obj_new( "float", "float" );
	return set_cast_success( result_obj, float( arg ), "float==true" );
}

arg_obj_wholefloat_validate( arg )
{
	return is_positive_float( arg );
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

arg_obj_string_validate( arg )
{
	compare_str = "01234567890_abcdefghijklmnopqrstuvwxyz";

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

arg_obj_string_allow_null_validate( arg )
{
	if ( arg == "" )
	{
		return true;
	}

	return arg_obj_string_validate( arg );
}

arg_obj_string_allow_null_generate()
{
	return "null";
}