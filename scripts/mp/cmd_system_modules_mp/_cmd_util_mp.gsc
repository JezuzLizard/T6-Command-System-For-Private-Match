#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;

build_weapons_array()
{
	const INTERNAL_NAME_COLUMN = 4;
	const END_OF_WEAPONS_ROWS = 85;
	level.tcs_weapons = [];
	i = 0;
	while ( i < END_OF_WEAPONS_ROWS )
	{
		row = tableLookupRowNum( "statstable.csv", 0, i );
		if ( row < 0 )
		{
			break;
		}
		weapon = tableLookupColumnForRow( "statstable.csv", row, INTERNAL_NAME_COLUMN );
		if ( weapon == "weapon_null" || weapon == "" )
		{
			i++;
			continue;
		}
		level.tcs_weapons[ weapon + "_mp" ] = true;
		i++;
	}
}

arg_weapon_handler( arg )
{
	return isDefined( level.tcs_weapons[ arg ] );
} 

arg_generate_rand_weapon()
{
	weapons = getArrayKeys( level.tcs_weapons );
	return weapons[ randomInt( weapons.size ) ];
}