#include common_scripts\utility;
#include maps\mp\_utility;

array_randomize_from_system( seed_system, array )
{
	for ( i = 0; i < array.size; i++ )
	{
		j = randomintfromsystem( array.size, seed_system );
		temp = array[i];
		array[i] = array[j];
		array[j] = temp;
	}

	return array;
}

random_from_system( seed_system, array )
{
	keys = getarraykeys( array );
	return array[keys[randomintfromsystem( keys.size, seed_system )]];
}

register_seed( seed_name, custom_seed )
{
	if ( !isdefined( level._seeds ) )
	{
		level._seeds = [];
	}

	if ( !isdefined( level._seeds[ seed_name ] ) )
	{
		level._seeds[ seed_name ] = 0;
	}

	registered_seed = custom_seed;
	if ( !isdefined( custom_seed ) )
	{
		registered_seed = registerrandomsystem( seed_name );
	}
	else
	{
		registered_seed = registerrandomsystem( seed_name, registered_seed );
	}

	level._seeds[ seed_name ] = registered_seed;
}

reset_seed( seed_name )
{
	setrandomsystemseed( seed_name, level._seeds[ seed_name ] );
}

get_seed( seed_name )
{
	return getrandomsystemseed( seed_name );
}

set_seed( seed_name, seed )
{
	setrandomsystemseed( seed_name, seed );
}