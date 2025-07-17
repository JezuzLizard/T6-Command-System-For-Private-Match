#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

#include scripts\zm\cmd\modules\_utility;

autoexec init_consts()
{
	arg_type_register( "perk", ::arg_obj_perk_generate, ::arg_obj_perk_cast );
	arg_type_register( "weapon", ::arg_obj_weapon_generate, ::arg_obj_weapon_cast );
	arg_type_register( "powerup", ::arg_obj_powerup_generate, ::arg_obj_powerup_cast );

	arg_type_register( "permaperk", ::arg_obj_permaperk_generate, ::arg_obj_permaperk_cast );
}

arg_obj_perk_cast( arg )
{
	find = generic_obj_t_new();

	perks = perk_list_zm();
	if ( perks.size <= 0 )
	{
		return set_cast_error( find, "There are no perks on the map" );
	}

	if ( !isinarray( perks, arg ) && arg != "all" )
	{
		msg = get_possible_array_values_msg( arg, perks, "perk", false );
		msg += "PERK: 'all'\n";

		return set_cast_error( find, msg );
	}

	return set_cast_success( find, arg, "perk==" + arg );
}

arg_obj_perk_generate()
{
	find = generic_obj_t_new();

	perks = perk_list_zm();
	if ( perks.size <= 0 )
	{
		find.rand_gen_unimplemented = true;
		return set_cast_success( find, "", "No perks" );
	}

	perk = randomInt( 20 ) < 1 ? "all" : random_val( perks );
	find.str_value = perk;
	return set_cast_success( find, perk );
}

arg_obj_weapon_cast( arg )
{
	find = generic_obj_t_new();
	if ( !isdefined( level.zombie_include_weapons ) || level.zombie_include_weapons.size <= 0 )
	{
		return set_cast_error( find, "There are no weapons on the map" );
	}

	if ( !isdefined( level.zombie_include_weapons[ arg ] ) )
	{
		msg = get_possible_array_values_msg( arg, level.zombie_include_weapons, "weapon" );

		return set_cast_error( find, msg );
	}

	return set_cast_success( find, arg, "weapon==" + arg );
}

arg_obj_weapon_generate()
{
	find = generic_obj_t_new();
	if ( !isdefined( level.zombie_include_weapons ) || level.zombie_include_weapons.size <= 0 )
	{
		find.rand_gen_unimplemented = true;
		return set_cast_success( find, "", "No weapons" );
	}

	weapon = random_key( level.zombie_include_weapons );
	find.str_value = weapon;
	return set_cast_success( find, weapon );
}

arg_obj_powerup_cast( arg )
{
	find = generic_obj_t_new();
	if ( !isdefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size <= 0 )
	{
		return set_cast_error( find, "There are no powerups on the map" );
	}

	if ( !isdefined( level.zombie_include_powerups[ arg ] ) )
	{
		msg = get_possible_array_values_msg( arg, level.zombie_include_powerups, "powerup" );

		return set_cast_error( find, msg );
	}

	return set_cast_success( find, arg, "powerup==" + arg );
}

arg_obj_powerup_generate()
{
	find = generic_obj_t_new();
	if ( !isdefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size <= 0 )
	{
		find.rand_gen_unimplemented = true;
		return set_cast_success( find, "", "No powerups" );
	}

	powerup = random_key( level.zombie_include_powerups );
	find.str_value = powerup;
	return set_cast_success( find, powerup );
}

arg_obj_permaperk_cast( arg )
{
	find = generic_obj_t_new();
	if ( !isdefined( level.pers_upgrades[ arg ] ) )
	{
		msg = get_possible_array_values_msg( arg, level.pers_upgrades, "permaperk" );

		return set_cast_error( find, msg );
	}

	return set_cast_success( find, arg, "permaperk==" + arg );
}

arg_obj_permaperk_generate()
{
	find = generic_obj_t_new();
	
	if ( !array_validate( level.pers_upgrades_keys ) )
	{
		find.rand_gen_unimplemented = true;
		return set_cast_success( find, "", "No permaperks" );
	}

	permaperk = random_key( level.pers_upgrades_keys );
	find.str_value = permaperk;
	return set_cast_success( find, permaperk );
}