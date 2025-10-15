#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;

init_mp_consts()
{
	arg_type_register( "weapon", ::arg_obj_weapon_generate, ::arg_obj_weapon_cast );
}

arg_obj_weapon_cast( arg )
{
	return isDefined( level.tcs_weapons[ arg ] );
} 

arg_obj_weapon_generate()
{
	weapons = getArrayKeys( level.tcs_weapons );
	return weapons[ randomInt( weapons.size ) ];
}