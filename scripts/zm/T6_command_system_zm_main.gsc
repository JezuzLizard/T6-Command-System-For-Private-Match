#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\cmd\core\_utility;

// zm only cmds registered by autoexec
#include scripts\zm\cmd\modules\_utility;
#include scripts\zm\cmd\modules\_zm_consts;
#include scripts\zm\cmd\modules\zm_core_cmds;

main()
{
	replaceFunc( maps\mp\zombies\_zm_utility::wait_network_frame, ::wait_network_frame_override );
	replaceFunc( maps\mp\_visionset_mgr::monitor, ::monitor_stub );
	replaceFunc( maps\mp\zombies\_zm_perks::perk_machine_spawn_init, ::perk_machine_spawn_init_hook );
}

wait_network_frame_override()
{
	wait 0.1;
}

monitor_stub()
{
	while ( level.vsmgr_initializing )
		wait 0.05;

	typekeys = getarraykeys( level.vsmgr );

	while ( true )
	{
		wait 0.05;
		waittillframeend;
		players = getplayers();

		for ( type_index = 0; type_index < _SIZE( typekeys.size ); type_index++ )
		{
			type = typekeys[type_index];

			if ( !level.vsmgr[type].in_use )
				continue;

			for ( player_index = 0; player_index < _SIZE( players.size ); player_index++ )
			{
				if ( players[ player_index ] istestclient() )
					continue;

				maps\mp\_visionset_mgr::update_clientfields( players[player_index], level.vsmgr[type] );
			}
		}
	}
}

perk_machine_spawn_init_hook()
{
	initialize_custom_perk_arrays();
	disabledetouronce( maps\mp\zombies\_zm_perks::perk_machine_spawn_init );
	maps\mp\zombies\_zm_perks::perk_machine_spawn_init();

	vending_triggers = getentarray( "zombie_vending", "targetname" );

	level.machine_assets = [];
	level.custom_vending_precaching = ::mod_vending_precache;

	if ( !isdefined( level.packapunch_timeout ) )
	{
		level.packapunch_timeout = 15;
	}

	// precache anyway for dynamic spawning
	if ( vending_triggers.size < 1 )
	{
		precachemodel( "zm_collision_perks1" );
		precachemodel( "zombie_sign_please_wait" );
		[[ level.custom_vending_precaching ]]();
	}
}

mod_vending_precache()
{
	custom_vending_power_on = undefined;
	custom_vending_power_off = undefined;
	
	if ( level.script == "zm_tomb" )
	{
		custom_vending_power_on = GetFunction( "maps/mp/zm_tomb_capture_zones", "custom_vending_power_on" );
		custom_vending_power_off = GetFunction( "maps/mp/zm_tomb_capture_zones", "custom_vending_power_off" );
	}
	else if ( level.script == "zm_prison" )
	{
		custom_vending_power_on = GetFunction( "maps/mp/zm_prison", "custom_vending_power_on" );
		custom_vending_power_off = GetFunction( "maps/mp/zm_prison", "custom_vending_power_off" );
	}
	
	if ( is_true( level.zombiemode_using_divetonuke_perk ) )
	{
		level._custom_perks[ "specialty_flakjacket" ].precache_func = undefined; // nuke broken default logic for dive to nuke precaching as custom perk
		
		precacheshader( "specialty_divetonuke_zombies" );
		precachestring( &"ZOMBIE_PERK_DIVETONUKE" );
		
		level.machine_assets["divetonuke"] = spawnstruct();
		level.machine_assets["divetonuke"].weapon = "zombie_perk_bottle_nuke";
		
		if ( level.script == "zm_prison" )
		{
			level._effect["divetonuke_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		}
		else
		{
			level._effect["divetonuke_light"] = loadfx( "misc/fx_zombie_cola_dtap_on" );
		}
		
		level.machine_assets["divetonuke"].off_model = "p6_zm_al_vending_nuke";
		level.machine_assets["divetonuke"].on_model = "p6_zm_al_vending_nuke_on";
	}
	
	if ( is_true( level.zombiemode_using_pack_a_punch ) )
	{
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH" );
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH_ATT" );
		
		level.machine_assets["packapunch"] = spawnstruct();
		level.machine_assets["packapunch"].weapon = "zombie_knuckle_crack";
		
		if ( level.script == "zm_highrise" )
		{
			level._effect["packapunch_fx"] = loadfx( "maps/zombie/fx_zmb_highrise_packapunch" );
			level.machine_assets["packapunch"].off_model = "p6_anim_zm_buildable_pap";
			level.machine_assets["packapunch"].on_model = "p6_anim_zm_buildable_pap_on";
		}
		else if ( level.script == "zm_prison" )
		{
			level._effect["packapunch_fx"] = loadfx( "maps/zombie/fx_zombie_packapunch" );
			level.machine_assets["packapunch"].off_model = "p6_zm_al_vending_pap_on";
			level.machine_assets["packapunch"].on_model = "p6_zm_al_vending_pap_on";
		}
		else if ( level.script == "zm_tomb" )
		{
			level._effect["packapunch_fx"] = loadfx( "maps/zombie/fx_zombie_packapunch" );
			level.machine_assets["packapunch"].no_power_on_callback = true;
		}
		else
		{
			level._effect["packapunch_fx"] = loadfx( "maps/zombie/fx_zombie_packapunch" );
			level.machine_assets["packapunch"].off_model = "p6_anim_zm_buildable_pap";
			level.machine_assets["packapunch"].on_model = "p6_anim_zm_buildable_pap_on";
		}
	}
	
	if ( is_true( level.zombiemode_using_additionalprimaryweapon_perk ) )
	{
		precacheshader( "specialty_additionalprimaryweapon_zombies" );
		precachestring( &"ZOMBIE_PERK_ADDITIONALWEAPONPERK" );
		
		level.machine_assets["additionalprimaryweapon"] = spawnstruct();
		level.machine_assets["additionalprimaryweapon"].weapon = "zombie_perk_bottle_additionalprimaryweapon";
		
		if ( level.script == "zm_tomb" )
		{
			level._effect["additionalprimaryweapon_light"] = loadfx( "misc/fx_zombie_cola_arsenal_on" );
			level.machine_assets["additionalprimaryweapon"].off_model = "p6_zm_tm_vending_three_gun";
			level.machine_assets["additionalprimaryweapon"].on_model = "p6_zm_tm_vending_three_gun";
		}
		else if ( level.script == "zm_prison" )
		{
			level._effect["additionalprimaryweapon_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
			level.machine_assets["additionalprimaryweapon"].off_model = "p6_zm_al_vending_three_gun_on";
			level.machine_assets["additionalprimaryweapon"].on_model = "p6_zm_al_vending_three_gun_on";
		}
		else
		{
			level._effect["additionalprimaryweapon_light"] = loadfx( "misc/fx_zombie_cola_arsenal_on" );
			level.machine_assets["additionalprimaryweapon"].off_model = "zombie_vending_three_gun";
			level.machine_assets["additionalprimaryweapon"].on_model = "zombie_vending_three_gun_on";
		}
	}
	
	if ( is_true( level.zombiemode_using_deadshot_perk ) )
	{
		precacheshader( "specialty_ads_zombies" );
		precachestring( &"ZOMBIE_PERK_DEADSHOT" );
		
		level.machine_assets["deadshot"] = spawnstruct();
		level.machine_assets["deadshot"].weapon = "zombie_perk_bottle_deadshot";
		
		if ( level.script == "zm_prison" )
		{
			level._effect["deadshot_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
			level.machine_assets["deadshot"].off_model = "p6_zm_al_vending_ads_on";
		}
		else
		{
			level._effect["deadshot_light"] = loadfx( "misc/fx_zombie_cola_dtap_on" );
			level.machine_assets["deadshot"].off_model = "p6_zm_al_vending_ads";
		}
		
		level.machine_assets["deadshot"].on_model = "p6_zm_al_vending_ads_on";
	}
	
	if ( is_true( level.zombiemode_using_doubletap_perk ) )
	{
		precacheshader( "specialty_doubletap_zombies" );
		precachestring( &"ZOMBIE_PERK_DOUBLETAP" );
		
		level.machine_assets["doubletap"] = spawnstruct();
		level.machine_assets["doubletap"].weapon = "zombie_perk_bottle_doubletap";
		
		if ( level.script == "zm_prison" )
		{
			level._effect["doubletap_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
			level.machine_assets["doubletap"].off_model = "p6_zm_al_vending_doubletap2_on";
			level.machine_assets["doubletap"].on_model = "p6_zm_al_vending_doubletap2_on";
		}
		else
		{
			level._effect["doubletap_light"] = loadfx( "misc/fx_zombie_cola_dtap_on" );
			level.machine_assets["doubletap"].off_model = "zombie_vending_doubletap2";
			level.machine_assets["doubletap"].on_model = "zombie_vending_doubletap2_on";
		}
	}
	
	if ( is_true( level.zombiemode_using_juggernaut_perk ) )
	{
		precacheshader( "specialty_juggernaut_zombies" );
		precachestring( &"ZOMBIE_PERK_JUGGERNAUT" );
		
		level.machine_assets["juggernog"] = spawnstruct();
		level.machine_assets["juggernog"].weapon = "zombie_perk_bottle_jugg";
		
		if ( level.script == "zm_prison" )
		{
			level._effect["jugger_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
			level.machine_assets["juggernog"].off_model = "p6_zm_al_vending_jugg_on";
			level.machine_assets["juggernog"].on_model = "p6_zm_al_vending_jugg_on";
		}
		else
		{
			level._effect["jugger_light"] = loadfx( "misc/fx_zombie_cola_jugg_on" );
			level.machine_assets["juggernog"].off_model = "zombie_vending_jugg";
			level.machine_assets["juggernog"].on_model = "zombie_vending_jugg_on";
		}
	}
	
	if ( is_true( level.zombiemode_using_marathon_perk ) )
	{
		precacheshader( "specialty_marathon_zombies" );
		precachestring( &"ZOMBIE_PERK_MARATHON" );
		
		level.machine_assets["marathon"] = spawnstruct();
		level.machine_assets["marathon"].weapon = "zombie_perk_bottle_marathon";
		
		if ( level.script == "zm_prison" )
		{
			level._effect["marathon_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		}
		else
		{
			level._effect["marathon_light"] = loadfx( "maps/zombie/fx_zmb_cola_staminup_on" );
		}
		
		level.machine_assets["marathon"].off_model = "zombie_vending_marathon";
		level.machine_assets["marathon"].on_model = "zombie_vending_marathon_on";
	}
	
	if ( is_true( level.zombiemode_using_revive_perk ) )
	{
		precacheshader( "specialty_quickrevive_zombies" );
		precachestring( &"ZOMBIE_PERK_QUICKREVIVE" );
		
		level.machine_assets["revive"] = spawnstruct();
		level.machine_assets["revive"].weapon = "zombie_perk_bottle_revive";
		
		if ( level.script == "zm_tomb" )
		{
			level._effect["revive_light"] = loadfx( "misc/fx_zombie_cola_revive_on" );
			level._effect["revive_light_flicker"] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
			level.machine_assets["revive"].off_model = "p6_zm_tm_vending_revive";
			level.machine_assets["revive"].on_model = "p6_zm_tm_vending_revive_on";
		}
		else if ( level.script == "zm_prison" )
		{
			level._effect["revive_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
			level._effect["revive_light_flicker"] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
			level.machine_assets["revive"].off_model = "zombie_vending_revive";
			level.machine_assets["revive"].on_model = "zombie_vending_revive_on";
		}
		else
		{
			level._effect["revive_light"] = loadfx( "misc/fx_zombie_cola_revive_on" );
			level._effect["revive_light_flicker"] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
			level.machine_assets["revive"].off_model = "zombie_vending_revive";
			level.machine_assets["revive"].on_model = "zombie_vending_revive_on";
		}
	}
	
	if ( is_true( level.zombiemode_using_sleightofhand_perk ) )
	{
		precacheshader( "specialty_fastreload_zombies" );
		precachestring( &"ZOMBIE_PERK_FASTRELOAD" );
		
		level.machine_assets["speedcola"] = spawnstruct();
		level.machine_assets["speedcola"].weapon = "zombie_perk_bottle_sleight";
		
		if ( level.script == "zm_prison" )
		{
			level._effect["sleight_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
			level.machine_assets["speedcola"].off_model = "p6_zm_al_vending_sleight_on";
			level.machine_assets["speedcola"].on_model = "p6_zm_al_vending_sleight_on";
		}
		else
		{
			level._effect["sleight_light"] = loadfx( "misc/fx_zombie_cola_on" );
			level.machine_assets["speedcola"].off_model = "zombie_vending_sleight";
			level.machine_assets["speedcola"].on_model = "zombie_vending_sleight_on";
		}
	}
	
	if ( is_true( level.zombiemode_using_tombstone_perk ) )
	{
		precacheshader( "specialty_tombstone_zombies" );
		precachemodel( "ch_tombstone1" );
		precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
		
		level.machine_assets["tombstone"] = spawnstruct();
		level.machine_assets["tombstone"].weapon = "zombie_perk_bottle_tombstone";
		
		if ( level.script == "zm_prison" )
		{
			level._effect["tombstone_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		}
		else
		{
			level._effect["tombstone_light"] = loadfx( "misc/fx_zombie_cola_on" );
		}
		
		level.machine_assets["tombstone"].off_model = "zombie_vending_tombstone";
		level.machine_assets["tombstone"].on_model = "zombie_vending_tombstone_on";
	}
	
	if ( is_true( level.zombiemode_using_chugabud_perk ) )
	{
		precachestring( &"ZOMBIE_PERK_CHUGABUD" );
		
		level.machine_assets["whoswho"] = spawnstruct();
		level.machine_assets["whoswho"].weapon = "zombie_perk_bottle_whoswho";
		
		if ( level.script == "zm_prison" )
		{
			level._effect["tombstone_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		}
		else
		{
			level._effect["tombstone_light"] = loadfx( "misc/fx_zombie_cola_on" );
		}
		
		level.machine_assets["whoswho"].off_model = "p6_zm_vending_chugabud";
		level.machine_assets["whoswho"].on_model = "p6_zm_vending_chugabud_on";
	}
	
	if ( level._custom_perks.size > 0 )
	{
		a_keys = getarraykeys( level._custom_perks );
		
		for ( i = 0; i < _SIZE( a_keys.size ); i++ )
		{
			if ( isdefined( level._custom_perks[a_keys[i]].precache_func ) )
			{
				level [[ level._custom_perks[a_keys[i]].precache_func ]]();
			}
		}
	}
	
	keys = getarraykeys( level.machine_assets );
	
	for ( i = 0; i < _SIZE( keys.size ); i++ )
	{
		if ( !is_true( level.machine_assets[ keys[ i ] ].no_power_on_callback ) )
		{
			if ( isdefined( custom_vending_power_on ) )
			{
				level.machine_assets[ keys[ i ] ].power_on_callback = custom_vending_power_on;
			}
			
			if ( isdefined( custom_vending_power_off ) )
			{
				level.machine_assets[ keys[ i ] ].power_off_callback = custom_vending_power_off;
			}
		}
		
		if ( isdefined( level.machine_assets[ keys[ i ] ].off_model ) )
		{
			precachemodel( level.machine_assets[ keys[ i ] ].off_model );
		}
		
		if ( isdefined( level.machine_assets[ keys[ i ] ].on_model ) )
		{
			precachemodel( level.machine_assets[ keys[ i ] ].on_model );
		}
		
		if ( isdefined( level.machine_assets[ keys[ i ] ].weapon ) )
		{
			precacheitem( level.machine_assets[ keys[ i ] ].weapon );
		}
	}
}
