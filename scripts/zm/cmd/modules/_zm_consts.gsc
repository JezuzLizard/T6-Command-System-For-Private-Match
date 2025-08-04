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

	register_spawnable_perk_machine( "zombie_vending_revive", "specialty_quickrevive", "revive_light" );
	register_spawnable_perk_machine( "zombie_vending_sleight", "specialty_fastreload", "sleight_light" );
	register_spawnable_perk_machine( "zombie_vending_doubletap2", "specialty_rof", "doubletap_light" );
	register_spawnable_perk_machine( "zombie_vending_jugg", "specialty_armorvest", "jugger_light" );
	register_spawnable_perk_machine( "p6_anim_zm_buildable_pap", "specialty_weapupgrade", "packapunch_fx" );
	register_spawnable_perk_machine( "zombie_vending_three_gun", "specialty_additionalprimaryweapon", "additionalprimaryweapon_light" );
	register_spawnable_perk_machine( "p6_zm_al_vending_ads", "specialty_deadshot", "deadshot_light" );
	register_spawnable_perk_machine( "p6_zm_al_vending_nuke", "specialty_flakjacket", "divetonuke_light" );
	register_spawnable_perk_machine( "p6_zm_vending_electric_cherry", "specialty_grenadepulldeath", "electriccherry" );
	register_spawnable_perk_machine( "zombie_vending_marathon", "specialty_longersprint", "marathon_light" );
	register_spawnable_perk_machine( "zombie_vending_tombstone", "specialty_scavenger", "tombstone_light" );
	register_spawnable_perk_machine( "p6_zm_vending_chugabud", "specialty_finalstand", "tombstone_light" );
	register_spawnable_perk_machine( "p6_zm_vending_vultureaid", "specialty_nomotionsensor", "vulture_light" );
	register_spawnable_perk_machine( "p6_zm_vending_diesel_magic", "specialty_stalker", "perk_machine_light" );
}

register_spawnable_perk_machine( model, script_noteworthy, perk_fx )
{
	if ( !isdefined( level._spawnable_perk_machines ) )
	{
		level._spawnable_perk_machines = [];
	}
	
	if ( !is_specialty_in_use( script_noteworthy ) )
	{
		return;
	}
	
	new_perk_obj = spawnstruct();
	new_perk_obj.model = model; // const
	new_perk_obj.script_noteworthy = script_noteworthy; // const
	
	if ( script_noteworthy == "specialty_stalker" )
	{
		new_perk_obj.is_wunderfizz = true;
		new_perk_obj.targetname = "random_perk_machine"; // const
	}
	else
	{
		new_perk_obj.is_wunderfizz = false;
		new_perk_obj.targetname = "zm_perk_machine_override"; // const
	}
	
	new_perk_obj.perk_fx = perk_fx;
	level._spawnable_perk_machines[ script_noteworthy ] = new_perk_obj;
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