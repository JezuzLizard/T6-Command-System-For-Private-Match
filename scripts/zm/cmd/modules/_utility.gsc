#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weapons;

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
	return getarraykeys( level._spawnable_perk_machines );
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

_spawn_perk_machine_from_structs( perk_struct, location_struct )
{
	perk = perk_struct.script_noteworthy;
	model = perk_struct.model;
	origin = location_struct.origin;
	angles = location_struct.angles;
	blocker_model = location_struct.blocker_model;
	
	return _spawn_perk_machine( perk, model, origin, angles, blocker_model );
}

_spawn_perk_machine( specialty_perk, model, origin, angles, blocker_model, clip_model )
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
			bump_trigger thread maps\mp\zombies\_zm_perks::thread_bump_trigger();
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
_power_on_packapunch()
{
	self thread maps\mp\zombies\_zm_perks::vending_weapon_upgrade();
	
	// only needs to be set the first time a packapunch spawns
	if ( !is_true( level._packapunch_on_thread ) )
	{
		if ( isdefined( level._custom_turn_packapunch_on ) )
		{
			level thread [[ level._custom_turn_packapunch_on ]]();
		}
		else
		{
			level thread maps\mp\zombies\_zm_perks::turn_packapunch_on();
		}

		level._packapunch_on_thread = true;
	}

	wait 0.05;
	waittillframeend;
	level notify( "Pack_A_Punch_on" );
}

// self = perk use trigger
_power_on_perk( perk_machine )
{
	self thread maps\mp\zombies\_zm_perks::vending_trigger_think();
	self thread maps\mp\zombies\_zm_perks::electric_perks_dialog();
	
	if ( self.script_noteworthy != "specialty_quickrevive" )
	{
		perk_machine setmodel( level._spawnable_perk_machines[ self.script_noteworthy ].model + "_on" );
		perk_machine vibrate( vectorscale( ( 0, -1, 0 ), 100.0 ), 0.3, 0.4, 3 );
		perk_machine playsound( "zmb_perks_power_on" );
		perk_machine thread perk_fx( level._spawnable_perk_machines[ self.script_noteworthy ].perk_fx );
		perk_machine thread play_loop_on_machine();
	}
	else
	{
		level thread maps\mp\zombies\_zm_perks::turn_revive_on();
		
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

_power_on_wunderfizz()
{
	wait 0.05;
	//level thread maps\mp\zombies\_zm_perk_random::init_machines();
	//level thread maps\mp\zombies\_zm_perk_random::start_random_machine();
	wait 1;
	self.num_til_moved = ( 1 << 31 ) - 1;
	self.is_locked = false;
}

_power_on_machine( perk_machine )
{
	if ( !isdefined( perk_machine.targetname ) )
	{
		return;
	}

	if ( perk_machine.targetname == "random_perk_machine" )
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

init_spawnable_weapon_upgrade()
{
	spawn_list = [];
	spawnable_weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "bowie_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "sickle_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "tazer_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "buildable_wallbuy", "targetname" ), 1, 0 );

	if ( !is_true( level.headshots_only ) )
		spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "claymore_purchase", "targetname" ), 1, 0 );

	match_string = "";
	location = level.scr_zm_map_start_location;

	if ( ( location == "default" || location == "" ) && isdefined( level.default_start_location ) )
		location = level.default_start_location;

	match_string = level.scr_zm_ui_gametype;

	if ( "" != location )
		match_string = match_string + "_" + location;

	match_string_plus_space = " " + match_string;

	for ( i = 0; i < spawnable_weapon_spawns.size; i++ )
	{
		spawnable_weapon = spawnable_weapon_spawns[i];

		if ( isdefined( spawnable_weapon.zombie_weapon_upgrade ) && spawnable_weapon.zombie_weapon_upgrade == "sticky_grenade_zm" && is_true( level.headshots_only ) )
			continue;

		if ( !isdefined( spawnable_weapon.script_noteworthy ) || spawnable_weapon.script_noteworthy == "" )
		{
			spawn_list[spawn_list.size] = spawnable_weapon;
			continue;
		}

		matches = strtok( spawnable_weapon.script_noteworthy, "," );

		for ( j = 0; j < matches.size; j++ )
		{
			if ( matches[j] == match_string || matches[j] == match_string_plus_space )
				spawn_list[spawn_list.size] = spawnable_weapon;
		}
	}

	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );

	for ( i = 0; i < spawn_list.size; i++ )
	{
		clientfieldname = spawn_list[i].zombie_weapon_upgrade + "_" + spawn_list[i].origin;
		numbits = 2;

		if ( isdefined( level._wallbuy_override_num_bits ) )
			numbits = level._wallbuy_override_num_bits;

		registerclientfield( "world", clientfieldname, 1, numbits, "int" );
		target_struct = getstruct( spawn_list[i].target, "targetname" );

		if ( spawn_list[i].targetname == "buildable_wallbuy" )
		{
			bits = 4;

			if ( isdefined( level.buildable_wallbuy_weapons ) )
				bits = getminbitcountfornum( level.buildable_wallbuy_weapons.size + 1 );

			registerclientfield( "world", clientfieldname + "_idx", 12000, bits, "int" );
			spawn_list[i].clientfieldname = clientfieldname;
			continue;
		}

		precachemodel( target_struct.model );
		unitrigger_stub = spawnstruct();
		unitrigger_stub.origin = spawn_list[i].origin;
		unitrigger_stub.angles = spawn_list[i].angles;
		tempmodel.origin = spawn_list[i].origin;
		tempmodel.angles = spawn_list[i].angles;
		mins = undefined;
		maxs = undefined;
		absmins = undefined;
		absmaxs = undefined;
		tempmodel setmodel( target_struct.model );
		tempmodel useweaponhidetags( spawn_list[i].zombie_weapon_upgrade );
		mins = tempmodel getmins();
		maxs = tempmodel getmaxs();
		absmins = tempmodel getabsmins();
		absmaxs = tempmodel getabsmaxs();
		bounds = absmaxs - absmins;
		unitrigger_stub.script_length = bounds[0] * 0.25;
		unitrigger_stub.script_width = bounds[1];
		unitrigger_stub.script_height = bounds[2];
		unitrigger_stub.origin = unitrigger_stub.origin - anglestoright( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
		unitrigger_stub.target = spawn_list[i].target;
		unitrigger_stub.targetname = spawn_list[i].targetname;
		unitrigger_stub.cursor_hint = "HINT_NOICON";

		if ( spawn_list[i].targetname == "weapon_upgrade" )
		{
			unitrigger_stub.cost = get_weapon_cost( spawn_list[i].zombie_weapon_upgrade );

			if ( !( isdefined( level.monolingustic_prompt_format ) && level.monolingustic_prompt_format ) )
			{
				unitrigger_stub.hint_string = get_weapon_hint( spawn_list[i].zombie_weapon_upgrade );
				unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
			}
			else
			{
				unitrigger_stub.hint_parm1 = get_weapon_display_name( spawn_list[i].zombie_weapon_upgrade );

				if ( !isdefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" || unitrigger_stub.hint_parm1 == "none" )
					unitrigger_stub.hint_parm1 = "missing weapon name " + spawn_list[i].zombie_weapon_upgrade;

				unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
				unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
			}
		}

		unitrigger_stub.weapon_upgrade = spawn_list[i].zombie_weapon_upgrade;
		unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
		unitrigger_stub.require_look_at = 1;

		if ( isdefined( spawn_list[i].require_look_from ) && spawn_list[i].require_look_from )
			unitrigger_stub.require_look_from = 1;

		unitrigger_stub.zombie_weapon_upgrade = spawn_list[i].zombie_weapon_upgrade;
		unitrigger_stub.clientfieldname = clientfieldname;
		maps\mp\zombies\_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );

		if ( is_melee_weapon( unitrigger_stub.zombie_weapon_upgrade ) )
		{
			if ( unitrigger_stub.zombie_weapon_upgrade == "tazer_knuckles_zm" && isdefined( level.taser_trig_adjustment ) )
				unitrigger_stub.origin = unitrigger_stub.origin + level.taser_trig_adjustment;

			maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}
		else if ( unitrigger_stub.zombie_weapon_upgrade == "claymore_zm" )
		{
			unitrigger_stub.prompt_and_visibility_func = maps\mp\zombies\_zm_weap_claymore::claymore_unitrigger_update_prompt;
			maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps\mp\zombies\_zm_weap_claymore::buy_claymores );
		}
		else
		{
			unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
			maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}

		spawn_list[i].trigger_stub = unitrigger_stub;
	}

	level._spawned_wallbuys = spawn_list;
	tempmodel delete();
}

init_weapon_upgrade()
{
	init_spawnable_weapon_upgrade();
	weapon_spawns = [];
	weapon_spawns = getentarray( "weapon_upgrade", "targetname" );

	for ( i = 0; i < weapon_spawns.size; i++ )
	{
		if ( !( isdefined( level.monolingustic_prompt_format ) && level.monolingustic_prompt_format ) )
		{
			hint_string = get_weapon_hint( weapon_spawns[i].zombie_weapon_upgrade );
			cost = get_weapon_cost( weapon_spawns[i].zombie_weapon_upgrade );
			weapon_spawns[i] sethintstring( hint_string, cost );
			weapon_spawns[i] setcursorhint( "HINT_NOICON" );
		}
		else
		{
			cost = get_weapon_cost( weapon_spawns[i].zombie_weapon_upgrade );
			weapon_display = get_weapon_display_name( weapon_spawns[i].zombie_weapon_upgrade );

			if ( !isdefined( weapon_display ) || weapon_display == "" || weapon_display == "none" )
				weapon_display = "missing weapon name " + weapon_spawns[i].zombie_weapon_upgrade;

			hint_string = &"ZOMBIE_WEAPONCOSTONLY";
			weapon_spawns[i] sethintstring( hint_string, weapon_display, cost );
		}

		weapon_spawns[i] usetriggerrequirelookat();
		weapon_spawns[i] thread weapon_spawn_think();
		model = getent( weapon_spawns[i].target, "targetname" );

		if ( isdefined( model ) )
		{
			model useweaponhidetags( weapon_spawns[i].zombie_weapon_upgrade );
			model hide();
		}
	}
}

add_dynamic_wallbuy( weapon, wallbuy, pristine )
{
	spawned_wallbuy = undefined;

	for ( i = 0; i < level._spawned_wallbuys.size; i++ )
	{
		if ( level._spawned_wallbuys[i].target == wallbuy )
		{
			spawned_wallbuy = level._spawned_wallbuys[i];
			break;
		}
	}

	if ( !isdefined( spawned_wallbuy ) )
	{
/#
		assertmsg( "Cannot find dynamic wallbuy" );
#/
		return;
	}

	if ( isdefined( spawned_wallbuy.trigger_stub ) )
	{
/#
		assertmsg( "Dynamic wallbuy already added" );
#/
		return;
	}

	target_struct = getstruct( wallbuy, "targetname" );
	wallmodel = spawn_weapon_model( weapon, undefined, target_struct.origin, target_struct.angles );
	clientfieldname = spawned_wallbuy.clientfieldname;
	model = getweaponmodel( weapon );
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = target_struct.origin;
	unitrigger_stub.angles = target_struct.angles;
	wallmodel.origin = target_struct.origin;
	wallmodel.angles = target_struct.angles;
	mins = undefined;
	maxs = undefined;
	absmins = undefined;
	absmaxs = undefined;
	wallmodel setmodel( model );
	wallmodel useweaponhidetags( weapon );
	mins = wallmodel getmins();
	maxs = wallmodel getmaxs();
	absmins = wallmodel getabsmins();
	absmaxs = wallmodel getabsmaxs();
	bounds = absmaxs - absmins;
	unitrigger_stub.script_length = bounds[0] * 0.25;
	unitrigger_stub.script_width = bounds[1];
	unitrigger_stub.script_height = bounds[2];
	unitrigger_stub.origin = unitrigger_stub.origin - anglestoright( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
	unitrigger_stub.target = spawned_wallbuy.target;
	unitrigger_stub.targetname = "weapon_upgrade";
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	unitrigger_stub.first_time_triggered = !pristine;

	if ( !is_melee_weapon( weapon ) )
	{
		if ( pristine || weapon == "claymore_zm" )
			unitrigger_stub.hint_string = get_weapon_hint( weapon );
		else
			unitrigger_stub.hint_string = get_weapon_hint_ammo();

		unitrigger_stub.cost = get_weapon_cost( weapon );
		unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
	}

	unitrigger_stub.weapon_upgrade = weapon;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
	unitrigger_stub.zombie_weapon_upgrade = weapon;
	unitrigger_stub.clientfieldname = clientfieldname;
	unitrigger_force_per_player_triggers( unitrigger_stub, 1 );

	if ( is_melee_weapon( weapon ) )
	{
		if ( weapon == "tazer_knuckles_zm" && isdefined( level.taser_trig_adjustment ) )
			unitrigger_stub.origin = unitrigger_stub.origin + level.taser_trig_adjustment;

		maps\mp\zombies\_zm_melee_weapon::add_stub( unitrigger_stub, weapon );
		maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps\mp\zombies\_zm_melee_weapon::melee_weapon_think );
	}
	else if ( weapon == "claymore_zm" )
	{
		unitrigger_stub.prompt_and_visibility_func = maps\mp\zombies\_zm_weap_claymore::claymore_unitrigger_update_prompt;
		maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps\mp\zombies\_zm_weap_claymore::buy_claymores );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
		maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
	}

	spawned_wallbuy.trigger_stub = unitrigger_stub;
	weaponidx = undefined;

	if ( isdefined( level.buildable_wallbuy_weapons ) )
	{
		for ( i = 0; i < level.buildable_wallbuy_weapons.size; i++ )
		{
			if ( weapon == level.buildable_wallbuy_weapons[i] )
			{
				weaponidx = i;
				break;
			}
		}
	}

	if ( isdefined( weaponidx ) )
	{
		level setclientfield( clientfieldname + "_idx", weaponidx + 1 );
		wallmodel delete();

		if ( !pristine )
			level setclientfield( clientfieldname, 1 );
	}
	else
	{
		level setclientfield( clientfieldname, 1 );
		wallmodel show();
	}
}