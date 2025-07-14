#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

autoexec init_consts()
{
	arg_obj_register( "weapon", ::arg_obj_weapon_generate, ::arg_obj_weapon_cast );
	arg_obj_register( "perk", ::arg_obj_perk_generate, ::arg_obj_perk_cast );
	arg_obj_register( "powerup", ::arg_obj_powerup_generate, ::arg_obj_powerup_cast );
	arg_obj_register( "round", ::arg_obj_round_generate, ::arg_obj_int_cast );
}

arg_obj_perk_validate( arg )
{
	perks = perk_list_zm();
	if ( perks.size <= 0 )
	{
		self com_printerror( "There are no perks on the map" );
		return false;
	}
	return isInArray( perks, arg ) || arg == "all";
}

arg_obj_perk_generate()
{
	perks = perk_list_zm();
	if ( perks.size <= 0 )
	{
		return "invalid_perk";
	}
	return randomInt( 20 ) < 1 ? "all" : perks[ randomInt( perks.size ) ];	
}

arg_obj_weapon_validate( arg )
{
	if ( !isDefined( level.zombie_include_weapons ) || level.zombie_include_weapons.size <= 0 )
	{
		self com_printerror( "There are no weapons on the map" );
		return false;
	}
	return isDefined( level.zombie_include_weapons[ arg ] );
}

arg_obj_weapon_generate()
{
	if ( !isDefined( level.zombie_include_weapons ) || level.zombie_include_weapons.size <= 0 )
	{
		return "invalid_weapon";
	}
	weapon_keys = getArrayKeys( level.zombie_include_weapons );
	return weapon_keys[ randomInt( weapon_keys.size ) ];	
}

arg_obj_powerup_validate( arg )
{
	if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size <= 0 )
	{
		self com_printerror( "There are no powerups on the map" );
		return false;
	}
	return isDefined( level.zombie_include_powerups[ arg ] );
}

arg_obj_powerup_generate()
{
	if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size <= 0 )
	{
		return "invalid_powerup";
	}
	powerup_keys = getArrayKeys( level.zombie_include_powerups );
	powerup = "";
	while ( powerup == "" || powerup == "teller_withdrawl" )
	{
		powerup = powerup_keys[ randomInt( powerup_keys.size ) ];
	}
	return powerup;	
}

arg_obj_round_validate( arg )
{
	return scripts\cmd_system_modules\_cmd_arg::is_natural_num( arg ) && int( arg ) <= 255;
}

arg_obj_round_generate()
{
	return randomint( 256 );
}