permaperk_list_zm()
{
	return getarraykeys( level.pers_upgrades );
}

get_all_weapons()
{
	return getarraykeys( level.zombie_include_weapons );
}

weapon_is_upgrade( weapon )
{
	return issubstr( weapon, "upgraded" );
}

perk_list_zm()
{
	if ( !isDefined( level._zm_perks ) )
	{
		level._zm_perks = [];
	}
	else 
	{
		return level._zm_perks; //Fix so even if quickrevive machine is removed it can still be given.
	}
	
	switch ( level.script )
	{
		case "zm_tomb":
			level._zm_perks = level._random_perk_machine_perk_list;
			return level._zm_perks;
		case "zm_transit": //Fix so you can give perks with cmds on maps without perk machines.
			level._zm_perks = array( "specialty_quickrevive", "specialty_rof", "specialty_fastreload", "specialty_armorvest", "specialty_longersprint", "specialty_scavenger" );
			return level._zm_perks;
		default:
			machines = getentarray( "zombie_vending", "targetname" );
			for ( i = 0; i < machines.size; i++ )
			{
				if ( machines[ i ].script_noteworthy == "specialty_weapupgrade" )
					continue;

				level._zm_perks[ level._zm_perks.size ] = machines[ i ].script_noteworthy;
			}

			return level._zm_perks;
	}
}