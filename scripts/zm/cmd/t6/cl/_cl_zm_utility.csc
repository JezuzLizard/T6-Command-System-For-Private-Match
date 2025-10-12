#include scripts\cmd\core\_cl_utility;

get_specialty_from_machine_name( machine_name )
{
	switch ( machine_name )
	{
		case "divetonuke":
			return "specialty_flakjacket";
		case "packapunch":
			return "specialty_weapupgrade";
		case "additionalprimaryweapon":
			return "specialty_additionalprimaryweapon";
		case "deadshot":
			return "specialty_deadshot";
		case "doubletap":
			return "specialty_rof";
		case "juggernog":
			return "specialty_armorvest";
		case "marathon":
			return "specialty_longersprint";
		case "revive":
			return "specialty_quickrevive";
		case "speedcola":
			return "specialty_fastreload";
		case "tombstone":
			return "specialty_scavenger";
		case "whoswho":
			return "specialty_finalstand";
	}

	return "unknown";
}

get_machine_name_from_specialty( specialty )
{
	switch ( specialty )
	{
		case "specialty_flakjacket":
			return "divetonuke";
		case "specialty_weapupgrade":
			return "packapunch";
		case "specialty_additionalprimaryweapon":
			return "additionalprimaryweapon";
		case "specialty_deadshot":
			return "deadshot";
		case "specialty_rof":
			return "doubletap";
		case "specialty_armorvest":
			return "juggernog";
		case "specialty_longersprint":
			return "marathon";
		case "specialty_quickrevive":
			return "revive";
		case "specialty_fastreload":
			return "speedcola";
		case "specialty_scavenger":
			return "tombstone";
		case "specialty_finalstand":
			return "whoswho";
	}

	return "unknown";
}