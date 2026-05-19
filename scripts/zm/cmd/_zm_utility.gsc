#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_weap_claymore;

#include scripts\cmd\core\_utility;

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
	perks = getarraykeys( level._spawnable_perk_machines );
	new_arr = [];
	foreach ( perk in perks )
	{
		// remove pap perk for the perk giving functionality to not get confused
		if ( perk == "specialty_weapupgrade" )
		{
			continue;
		}

		new_arr[ new_arr.size ] = perk;
	}
	return new_arr;
}

spawn_blocker_collision( origin, angles )
{
	blocker = spawn( "script_model", origin, 1 );
	blocker.angles = angles;
	blocker setmodel( "zm_collision_perks1" );
	blocker.script_noteworthy = "clip";
	blocker disconnectpaths();
	return blocker;
}

_spawn_perk_machine( internal_name, specialty_perk, model, origin, angles, blocker_model, clip_model, keys )
{
	const trigger_offset = ( 0, 0, 30 );
	const trigger_flags = 0;
	const trigger_height = 40;
	const trigger_radius = 70;
	blocker_model = _DEFAULT( blocker_model, undefined );
	clip_model = _DEFAULT( clip_model, "zm_collision_perks1" );

	use_trigger = spawn( "trigger_radius_use", origin + trigger_offset, trigger_flags, trigger_height, trigger_radius );
	use_trigger.targetname = "zombie_vending";
	use_trigger.script_noteworthy = specialty_perk;
	use_trigger triggerignoreteam();
	perk_machine = spawn( "script_model", origin );
	perk_machine.angles = angles;
	perk_machine setmodel( model );
	perk_machine._perk_trigger = use_trigger;
	use_trigger._perk_machine = perk_machine;
	
	if ( isdefined( level._no_vending_machine_bump_trigs ) && level._no_vending_machine_bump_trigs )
	{
		bump_trigger = undefined;
	}
	else
	{
		bump_trigger = spawn( "trigger_radius", origin, 0, 35, 64 );
		bump_trigger.script_activated = 1;
		bump_trigger.script_sound = "zmb_perks_bump_bottle";
		bump_trigger.targetname = "audio_bump_trigger";
		
		if ( specialty_perk != "specialty_weapupgrade" )
		{
			bump_trigger thread thread_bump_trigger();
		}
	}
	
	collision = spawn( "script_model", origin, 1 );
	collision.angles = angles;
	collision setmodel( clip_model );
	collision.script_noteworthy = "clip";
	collision disconnectpaths();
	use_trigger.clip = collision;
	use_trigger.machine = perk_machine;
	use_trigger.bump = bump_trigger;
	
	if ( isdefined( blocker_model ) )
	{
		use_trigger.blocker_model = blocker_model;
	}
	
	switch ( specialty_perk )
	{
		case "specialty_quickrevive":
		case "specialty_quickrevive_upgrade":
			use_trigger.script_sound = "mus_perks_revive_jingle";
			use_trigger.script_string = "revive_perk";
			use_trigger.script_label = "mus_perks_revive_sting";
			use_trigger.target = "vending_revive";
			perk_machine.script_string = "revive_perk";
			perk_machine.targetname = "vending_revive";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "revive_perk";
			}
			
			break;
			
		case "specialty_fastreload":
		case "specialty_fastreload_upgrade":
			use_trigger.script_sound = "mus_perks_speed_jingle";
			use_trigger.script_string = "speedcola_perk";
			use_trigger.script_label = "mus_perks_speed_sting";
			use_trigger.target = "vending_sleight";
			perk_machine.script_string = "speedcola_perk";
			perk_machine.targetname = "vending_sleight";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "speedcola_perk";
			}
			
			break;
			
		case "specialty_longersprint":
		case "specialty_longersprint_upgrade":
			use_trigger.script_sound = "mus_perks_stamin_jingle";
			use_trigger.script_string = "marathon_perk";
			use_trigger.script_label = "mus_perks_stamin_sting";
			use_trigger.target = "vending_marathon";
			perk_machine.script_string = "marathon_perk";
			perk_machine.targetname = "vending_marathon";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "marathon_perk";
			}
			
			break;
			
		case "specialty_armorvest":
		case "specialty_armorvest_upgrade":
			use_trigger.script_sound = "mus_perks_jugganog_jingle";
			use_trigger.script_string = "jugg_perk";
			use_trigger.script_label = "mus_perks_jugganog_sting";
			use_trigger.longjinglewait = 1;
			use_trigger.target = "vending_jugg";
			perk_machine.script_string = "jugg_perk";
			perk_machine.targetname = "vending_jugg";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "jugg_perk";
			}
			
			break;
			
		case "specialty_scavenger":
		case "specialty_scavenger_upgrade":
			use_trigger.script_sound = "mus_perks_tombstone_jingle";
			use_trigger.script_string = "tombstone_perk";
			use_trigger.script_label = "mus_perks_tombstone_sting";
			use_trigger.target = "vending_tombstone";
			perk_machine.script_string = "tombstone_perk";
			perk_machine.targetname = "vending_tombstone";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "tombstone_perk";
			}
			
			break;
			
		case "specialty_rof":
		case "specialty_rof_upgrade":
			use_trigger.script_sound = "mus_perks_doubletap_jingle";
			use_trigger.script_string = "tap_perk";
			use_trigger.script_label = "mus_perks_doubletap_sting";
			use_trigger.target = "vending_doubletap";
			perk_machine.script_string = "tap_perk";
			perk_machine.targetname = "vending_doubletap";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "tap_perk";
			}
			
			break;
			
		case "specialty_finalstand":
		case "specialty_finalstand_upgrade":
			use_trigger.script_sound = "mus_perks_whoswho_jingle";
			use_trigger.script_string = "tap_perk";
			use_trigger.script_label = "mus_perks_whoswho_sting";
			use_trigger.target = "vending_chugabud";
			perk_machine.script_string = "tap_perk";
			perk_machine.targetname = "vending_chugabud";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "tap_perk";
			}
			
			break;
			
		case "specialty_additionalprimaryweapon":
		case "specialty_additionalprimaryweapon_upgrade":
			use_trigger.script_sound = "mus_perks_mulekick_jingle";
			use_trigger.script_string = "tap_perk";
			use_trigger.script_label = "mus_perks_mulekick_sting";
			use_trigger.target = "vending_additionalprimaryweapon";
			perk_machine.script_string = "tap_perk";
			perk_machine.targetname = "vending_additionalprimaryweapon";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "tap_perk";
			}
			
			break;
			
		case "specialty_weapupgrade":
			use_trigger.target = "vending_packapunch";
			use_trigger.script_sound = "mus_perks_packa_jingle";
			use_trigger.script_label = "mus_perks_packa_sting";
			use_trigger.longjinglewait = 1;
			perk_machine.targetname = "vending_packapunch";
			
			flag_pos = spawnStruct();
			flag_pos.targetname = "pack_flag";
			flag_pos.origin = origin + ( anglesToForward( angles ) * 29 ) + ( anglesToRight( angles ) * -13.5 ) + ( anglesToUp( angles ) * 49.5 );
			flag_pos.angles = angles + ( 0, 180, 180 );
			flag_pos.model = "zombie_sign_please_wait";
			
			if ( isdefined( flag_pos ) )
			{
				perk_machine_flag = spawn( "script_model", flag_pos.origin );
				perk_machine_flag.angles = flag_pos.angles;
				perk_machine_flag setmodel( flag_pos.model );
				perk_machine_flag.targetname = flag_pos.targetname;
				perk_machine.target = "pack_flag";
			}
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "perks_rattle";
			}
			
			break;
			
		case "specialty_deadshot":
		case "specialty_deadshot_upgrade":
			use_trigger.script_sound = "mus_perks_deadshot_jingle";
			use_trigger.script_string = "deadshot_perk";
			use_trigger.script_label = "mus_perks_deadshot_sting";
			use_trigger.target = "vending_deadshot";
			perk_machine.script_string = "deadshot_vending";
			perk_machine.targetname = "vending_deadshot";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "deadshot_vending";
			}
			
			break;
			
		default:
			use_trigger.script_sound = "mus_perks_speed_jingle";
			use_trigger.script_string = "speedcola_perk";
			use_trigger.script_label = "mus_perks_speed_sting";
			use_trigger.target = "vending_sleight";
			perk_machine.script_string = "speedcola_perk";
			perk_machine.targetname = "vending_sleight";
			
			if ( isdefined( bump_trigger ) )
			{
				bump_trigger.script_string = "speedcola_perk";
			}
			
			break;
	}
	
	if ( isdefined( level._custom_perks[ specialty_perk ] ) && isdefined( level._custom_perks[ specialty_perk ].perk_machine_set_kvps ) )
	{
		[[ level._custom_perks[ specialty_perk ].perk_machine_set_kvps ]]( use_trigger, perk_machine, bump_trigger, collision );
	}
	
	if ( specialty_perk == "specialty_grenadepulldeath" )
	{
		use_trigger.target = "vending_cherry";
		perk_machine.targetname = "vending_cherry";
	}
	
	add_mapent_entity( use_trigger, "perk_machines", internal_name );
	return use_trigger;
}

_spawn_wunderfizz_from_struct( location_struct )
{
	origin = location_struct.origin;
	angles = location_struct.angles;
	blocker_model = location_struct.blocker_model;
	return _spawn_wunderfizz( origin, angles, blocker_model );
}

_spawn_wunderfizz( origin, angles, blocker_model )
{
	wunderfizz = spawn( "script_model", origin );
	wunderfizz.angles = angles;
	wunderfizz.targetname = "random_perk_machine";
	wunderfizz.script_noteworthy = "start_machine";
	wunderfizz setmodel( "p6_zm_vending_diesel_magic" );
	wunderfizz.is_locked = 1;
	wunderfizz.clip = spawn_blocker_collision( origin, angles );
	
	return wunderfizz;
}

// self = packapunch use trigger
private _power_on_packapunch()
{
	self thread vending_weapon_upgrade();
	
	// only needs to be set the first time a packapunch spawns
	if ( !is_true( level._packapunch_on_thread ) )
	{
		if ( isdefined( level._custom_turn_packapunch_on ) )
		{
			level thread [[ level._custom_turn_packapunch_on ]]();
		}
		else
		{
			level thread turn_packapunch_on();
		}

		level._packapunch_on_thread = true;
	}

	wait 0.05;
	waittillframeend;
	level notify( "Pack_A_Punch_on" );
}

// self = perk use trigger
private _power_on_perk( perk_machine )
{
	self thread vending_trigger_think();
	self thread electric_perks_dialog();
	
	if ( self.script_noteworthy != "specialty_quickrevive" )
	{
		perk_machine setmodel( level._spawnable_perk_machines[ self.script_noteworthy ].assets.on_model );
		perk_machine vibrate( vectorscale( ( 0, -1, 0 ), 100.0 ), 0.3, 0.4, 3 );
		perk_machine playsound( "zmb_perks_power_on" );
		perk_machine thread perk_fx( level._spawnable_perk_machines[ self.script_noteworthy ].assets.fx );
		perk_machine thread play_loop_on_machine();
	}
	else
	{
		level thread turn_revive_on();
		
		wait 0.05;
		waittillframeend;
		level notify( "revive_on" );
		return;
	}
	
	wait 0.05;
	waittillframeend;
	level notify( self.script_noteworthy + "_power_on" );
	self set_power_on( 1 );
}

private _power_on_wunderfizz()
{
	wait 0.05;
	//level thread init_machines();
	//level thread start_random_machine();
	wait 1;
	self.num_til_moved = ( 1 << 31 ) - 1;
	self.is_locked = false;
}

_power_on_machine( perk_machine )
{
	if ( isdefined( perk_machine.targetname ) && perk_machine.targetname == "random_perk_machine" )
	{
		perk_machine thread _power_on_wunderfizz();
		return;
	}
	
	perk_trigger = perk_machine._perk_trigger;
	
	if ( perk_trigger.script_noteworthy == "specialty_weapupgrade" )
	{
		perk_trigger thread _power_on_packapunch();
		return;
	}
	
	perk_trigger thread _power_on_perk( perk_machine );
}

is_specialty_in_use( perk )
{
	switch ( perk )
	{
		case "specialty_additionalprimaryweapon":
			return is_true( level.zombiemode_using_additionalprimaryweapon_perk );
			
		case "specialty_flakjacket":
			if ( level.script == "zm_buried" )
			{
				return isdefined( level._custom_perks[ perk ] );
			}
			
			return is_true( level.zombiemode_using_divetonuke_perk ); // buried doesnt set this...
			
		case "specialty_deadshot":
			return is_true( level.zombiemode_using_deadshot_perk );
			
		case "specialty_longersprint":
			return is_true( level.zombiemode_using_marathon_perk );
			
		case "specialty_rof":
			return is_true( level.zombiemode_using_doubletap_perk );
			
		case "specialty_armorvest":
			return is_true( level.zombiemode_using_juggernaut_perk );
			
		case "specialty_quickrevive":
			return is_true( level.zombiemode_using_revive_perk );
			
		case "specialty_fastreload":
			return is_true( level.zombiemode_using_sleightofhand_perk );
			
		case "specialty_scavenger":
			return is_true( level.zombiemode_using_tombstone_perk );
			
		case "specialty_weapupgrade":
			return is_true( level.zombiemode_using_pack_a_punch );
			
		case "specialty_finalstand":
			return is_true( level.zombiemode_using_chugabud_perk );
			
		case "specialty_stalker": // custom specialty for the fizz
			return is_true( level.zombiemode_using_random_perk );
			
		case "specialty_grenadepulldeath":
			return is_true( level.zombiemode_using_electric_cherry_perk ); // csc doesnt use this...
			
		default:
			return isdefined( level._custom_perks[ perk ] ); // vulture aid doesnt have a bool at all!
	}
}

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

// supported targetnames
/*
	weapon_upgrade

	bowie_upgrade
	sickle_upgrade
	tazer_upgrade
	buildable_wallbuy
	claymore_purchase

*/
/*
targetname supported_keys = 
	script_noteworthy - location
	script_width - adjusts unitrigger
	script_length
	script_height
	script_int
	script_vector
	angles
	origin
	zombie_weapon_upgrade - weapon_name
	keys for target
		script_noteworthy - location
		model
		angles
		origin

buildable wallbuy keys = 
	script_noteworthy - location
	script_location
	script_width - adjusts unitrigger
	script_length
	script_height
	angles
	origin
	org_model
	keys for target
		script_noteworthy
		model
		angles
		origin
		script_width - adjusts unitrigger
		script_length
		script_height
		script_location
		script_angles
		targetname
		org_model
*/

copy_additional_keys( keys )
{
	// common keys
	self.script_noteworthy = _DEFAULT( keys[ "script_noteworthy" ], level.scr_zm_ui_gametype + "_" + level.scr_zm_map_start_location );
	
	self.script_length = _OPTIONAL( keys[ "script_length" ] );
	self.script_width = _OPTIONAL( keys[ "script_width" ] );
	self.script_height = _OPTIONAL( keys[ "script_height" ] );
	self.script_int = _OPTIONAL( keys[ "script_int" ] );
	self.script_vector = _OPTIONAL( keys[ "script_vector" ] );
	self.script_angles = _OPTIONAL( keys[ "script_angles" ] );

	// dynamic buildable keys
	self.script_location = _DEFAULT( keys[ "script_location" ], "" );
	self.org_model = _DEFAULT( keys[ "org_model" ], "" );
}

spawn_wallbuy_trigger_stub( model, weapon_name )
{
	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );

	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = self.origin;
	unitrigger_stub.angles = self.angles;
	tempmodel.origin = self.origin;
	tempmodel.angles = self.angles;
	mins = undefined;
	maxs = undefined;
	absmins = undefined;
	absmaxs = undefined;
	tempmodel setmodel( model );
	tempmodel useweaponhidetags( self.zombie_weapon_upgrade );
	mins = tempmodel getmins();
	maxs = tempmodel getmaxs();
	absmins = tempmodel getabsmins();
	absmaxs = tempmodel getabsmaxs();
	bounds = absmaxs - absmins;
	unitrigger_stub.script_length = bounds[0] * 0.25;
	unitrigger_stub.script_width = bounds[1];
	unitrigger_stub.script_height = bounds[2];
	unitrigger_stub.origin = unitrigger_stub.origin - anglestoright( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
	unitrigger_stub.target = self.target;
	unitrigger_stub.targetname = self.targetname;
	unitrigger_stub.cursor_hint = "HINT_NOICON";

	if ( self.targetname == "weapon_upgrade" )
	{
		unitrigger_stub.cost = get_weapon_cost( self.zombie_weapon_upgrade );

		if ( !( isdefined( level.monolingustic_prompt_format ) && level.monolingustic_prompt_format ) )
		{
			unitrigger_stub.hint_string = get_weapon_hint( self.zombie_weapon_upgrade );
			unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
		}
		else
		{
			unitrigger_stub.hint_parm1 = get_weapon_display_name( self.zombie_weapon_upgrade );

			if ( !isdefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" || unitrigger_stub.hint_parm1 == "none" )
				unitrigger_stub.hint_parm1 = "missing weapon name " + self.zombie_weapon_upgrade;

			unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
			unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
		}
	}

	unitrigger_stub.weapon_upgrade = self.zombie_weapon_upgrade;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;

	if ( isdefined( self.require_look_from ) && self.require_look_from )
		unitrigger_stub.require_look_from = 1;

	unitrigger_stub.zombie_weapon_upgrade = self.zombie_weapon_upgrade;
	unitrigger_force_per_player_triggers( unitrigger_stub, 1 );

	if ( is_melee_weapon( unitrigger_stub.zombie_weapon_upgrade ) )
	{
		melee_weapon = undefined;
		foreach ( melee_weap in level._melee_weapons )
		{
			if ( melee_weap.weapon_name == weapon_name )
			{
				melee_weapon = melee_weap;
				break;
			}
		}

		if ( isDefined( melee_weapon ) )
		{
			unitrigger_stub.cost = melee_weapon.cost;
			unitrigger_stub.hint_string = melee_weapon.hint_string;
			unitrigger_stub.weapon_name = melee_weapon.weapon_name;
			unitrigger_stub.flourish_weapon_name = melee_weapon.flourish_weapon_name;
			unitrigger_stub.ballistic_weapon_name = melee_weapon.ballistic_weapon_name;
			unitrigger_stub.ballistic_upgraded_weapon_name = melee_weapon.ballistic_upgraded_weapon_name;
			unitrigger_stub.vo_dialog_id = melee_weapon.vo_dialog_id;
			unitrigger_stub.flourish_fn = melee_weapon.flourish_fn;

			if ( is_true( level.disable_melee_wallbuy_icons ) )
			{
				unitrigger_stub.cursor_hint = "HINT_NOICON";
				unitrigger_stub.cursor_hint_weapon = undefined;
			}
			else
			{
				unitrigger_stub.cursor_hint = "HINT_WEAPON";
				unitrigger_stub.cursor_hint_weapon = melee_weapon.weapon_name;
			}
		}

		if ( weapon_name == "tazer_knuckles_zm" )
		{
			unitrigger_stub.origin += anglestoforward( self.angles ) * -7;
			unitrigger_stub.origin += anglestoright( self.angles ) * -2;
		}

		self.wall_model.origin += anglestoforward( self.angles ) * -8; // _zm_melee_weapon::melee_weapon_show moves this back

		if ( unitrigger_stub.zombie_weapon_upgrade == "tazer_knuckles_zm" && isdefined( level.taser_trig_adjustment ) )
			unitrigger_stub.origin = unitrigger_stub.origin + level.taser_trig_adjustment;

		register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
	}
	else if ( unitrigger_stub.zombie_weapon_upgrade == "claymore_zm" )
	{
		unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
		register_static_unitrigger( unitrigger_stub, ::buy_claymores );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
		register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
	}

	self.trigger_stub = unitrigger_stub;

	tempmodel delete();
}

spawn_wallbuy_dynamically( internal_name, targetname, weapon_name, origin, angles, additional_targetname_keys, additional_target_keys )
{
	additional_targetname_keys = _DEFAULT( additional_targetname_keys, [] );
	additional_target_keys = _DEFAULT( additional_target_keys, [] );

	if ( !isdefined( level._dynamic_wallbuy_id ) )
	{
		level._dynamic_wallbuy_id = 0;
		level thread chalk_manager();
	}

	wallbuy_struct = spawnstruct();
	wallbuy_struct.invalid = false;
	switch ( targetname )
	{
		case "weapon_upgrade":
			break;
		case "bowie_upgrade":
			break;
		case "sickle_upgrade":
			break;
		case "tazer_upgrade":
			break;
		case "buildable_wallbuy":
			break;
		case "claymore_purchase":
			break;
		default:
			wallbuy_struct.invalid = true;
			wallbuy_struct.msg = "invalid targetname";
			return wallbuy_struct;
	}

	if ( !_WEAPON_EXISTS( weapon_name ) )
	{
		wallbuy_struct.invalid = true;
		wallbuy_struct.msg = "invalid weapon";
		return wallbuy_struct;
	}

	wallbuy_struct.origin = origin;
	wallbuy_struct.angles = angles;
	wallbuy_struct.targetname = targetname;
	wallbuy_struct.zombie_weapon_upgrade = weapon_name;
	wallbuy_struct.target = internal_name;
	wallbuy_struct copy_additional_keys( additional_targetname_keys );

	model_name = _OPTIONAL( additional_target_keys[ "model" ] );
	if ( weapon_name == "sticky_grenade_zm" )
	{
		model_name = "semtex_bag";
	}
	else if ( weapon_name == "claymore_zm" )
	{
		model_name = "t6_wpn_claymore_world";
	}

	model_ent = spawn_weapon_model( weapon_name, model_name, origin, angles );
	model_ent useweaponhidetags( weapon_name );
	model_ent hide();
	model_ent.targetname = wallbuy_struct.target;
	model_ent.zombie_weapon_upgrade = weapon_name;
	model_ent copy_additional_keys( additional_target_keys );
	if ( weapon_name == "claymore_zm" )
	{
		model_ent.angles += ( 0, 90, 0 );
		model_ent.script_int = 90; // fix for model sliding right to left
	}

	// move model forward so it always shows in front of chalk
	move_amount = anglestoright( model_ent.angles ) * -0.3;
	model_ent.origin += move_amount;
	wallbuy_struct.origin += move_amount;

	wallbuy_struct spawn_wallbuy_trigger_stub( model_ent.model, weapon_name );
	wallbuy_struct.wall_model = model_ent;
	model_ent.wallbuy_struct = wallbuy_struct;

	model_ent._entfield_custom_handler = ::custom_wallbuy_field_handler;
	model_ent._entfield_custom_callback = ::custom_wallbuy_field_callback;
	add_mapent_entity( wallbuy_struct, "wallbuy_locations", internal_name );
	level notify( "refresh_wall_buys" );

	return wallbuy_struct;
}

delete_dynamically_spawned_wallbuy( internal_name )
{
	wallbuy_ent = level._mapents[ "wallbuy_locations" ][ internal_name ];
	if ( !isdefined( wallbuy_ent ) )
	{
		return false;
	}

	wallbuy_struct = wallbuy_ent.wallbuy_struct;

	unregister_unitrigger( wallbuy_struct.unitrigger_stub );
	wallbuy_struct.unitrigger_stub = undefined;
	wallbuy_ent.wallbuy_struct = undefined;
	delete_dynamic_chalk( wallbuy_ent );
	level._mapents[ "wallbuy_locations" ][ internal_name ] = undefined;
	level notify( "refresh_wall_buys" );

	return true;
}

delete_dynamic_chalk( model_ent )
{
	model_ent.fx delete();
	model_ent delete();
}

chalk_manager()
{
	level waittill( "refresh_wall_buys" );

	for ( ;; )
	{
		keys = getarraykeys( level._mapents[ "wallbuy_locations" ] );
		for ( i = 0; i < level._mapents[ "wallbuy_locations" ].size; i++ )
		{
			model_ent = level._mapents[ "wallbuy_locations" ][ keys[ i ] ];
			assert( !isdefined( model_ent.fx ) );
			model_ent.fx = spawnfx( level._effect[ model_ent.zombie_weapon_upgrade + "_fx" ], model_ent.origin, anglestoforward( model_ent.angles ), anglestoup( model_ent.angles ) );
			triggerfx( model_ent.fx );
		}

		level waittill( "refresh_wall_buys" );

		keys = getarraykeys( level._mapents[ "wallbuy_locations" ] );
		for ( i = 0; i < keys.size; i++ )
		{
			model_ent = level._mapents[ "wallbuy_locations" ][ keys[ i ] ];
			if ( isdefined( model_ent.fx ) ) // it won't be defined for newly spawned wallbuys
			{
				model_ent.fx delete();
			}
		}
	}
}

private custom_wallbuy_field_handler( field, value, is_relative, scale )
{

}

private custom_wallbuy_field_callback( field, str_value, is_relative, scale )
{
	result_obj = generic_obj_t_new( "entfield" );
	result_obj.pass = false;
	trigger_stub = self.wallbuy_struct.trigger_stub;
	wallbuy_struct = self.wallbuy_struct;

	vector_cast = cast_str_to_type( str_value, "vector" );
	int_cast = cast_str_to_type( str_value, "int" );
	float_cast = cast_str_to_type( str_value, "float" );
	str_cast = str_value;
	switch ( field )
	{
		case "origin":
			if ( vector_cast.errored )
			{
				return vector_cast;
			}

			if ( is_relative )
			{
				wallbuy_struct.origin += ( vector_cast.value * scale );
				trigger_stub.origin += ( vector_cast.value * scale );
				self.origin += ( vector_cast.value * scale );
			}
			else
			{
				wallbuy_struct.origin = vector_cast.value;
				trigger_stub.origin = vector_cast.value;
				self.origin += vector_cast.value;
			}

			level notify( "refresh_wall_buys" );
			vector_cast.pass = false;
			return vector_cast;
		case "angles":
			if ( vector_cast.errored )
			{
				return vector_cast;
			}

			if ( is_relative )
			{
				wallbuy_struct.angles += ( vector_cast.value * scale );
				trigger_stub.angles += ( vector_cast.value * scale );
				self.angles += ( vector_cast.value * scale );
			}
			else
			{
				wallbuy_struct.angles = vector_cast.value;
				trigger_stub.angles = vector_cast.value;
				self.angles += vector_cast.value;
			}

			level notify( "refresh_wall_buys" );
			vector_cast.pass = false;
			return vector_cast;
	}

	result_obj.pass = true;
	return set_cast_success( result_obj, self, "" );
}