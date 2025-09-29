#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_zonemgr;

#include scripts\cmd\core\_utility;
#include scripts\zm\cmd\modules\_utility;

autoexec zm_debug_helpers()
{
	addcallback( "on_player_connect", ::zm_debug_connect );
}

draw_zombie_spawn_locations()
{
	level endon( "draw_zombie_spawn_locations_stop" );
	while ( !isDefined( level.zones ) )
	{
		wait 1;
	}

	flag_wait_until_set_once( "initial_blackscreen_passed" );

	for ( ;; )
	{
		wait 0.05;

		if ( !level._debug_zombie_spawn_loc_draw_enabled )
		{
			continue;
		}

		zkeys = getarraykeys( level.zones );
		for ( z = 0; z < zkeys.size; z++ )
		{
			zone = level.zones[ zkeys[ z ] ];

			if ( level._debug_zombie_spawn_loc_show_only_active_spawns && ( !zone.is_enabled || !zone.is_active || !zone.is_spawning_allowed ) )
			{
				continue;
			}

			draw_specific_zombie_spawn_locations( zone.spawn_locations, zkeys[ z ], ( 0.8, 0.8, 0.8 ), "zombie" );
			draw_specific_zombie_spawn_locations( zone.inert_locations, zkeys[ z ], ( 0.8, 0, 0.8 ), "inert" );
			draw_specific_zombie_spawn_locations( zone.dog_locations, zkeys[ z ], ( 0.8, 0.8, 0 ), "dog" );
			draw_specific_zombie_spawn_locations( zone.screecher_locations, zkeys[ z ], ( 0, 0.8, 0.8 ), "screecher" );
			draw_specific_zombie_spawn_locations( zone.avogadro_locations, zkeys[ z ], ( 0.3, 0.8, 0.8 ), "avogadro" );
			draw_specific_zombie_spawn_locations( zone.quad_locations, zkeys[ z ], ( 0.8, 0.3, 0.8 ), "quad" );
			draw_specific_zombie_spawn_locations( zone.leaper_locations, zkeys[ z ], ( 0.8, 0.8, 0.3 ), "leaper" );
			draw_specific_zombie_spawn_locations( zone.astro_locations, zkeys[ z ], ( 0, 0, 0.8 ), "astro" );
			draw_specific_zombie_spawn_locations( zone.napalm_locations, zkeys[ z ], ( 0.8, 0, 0 ), "napalm" );
			draw_specific_zombie_spawn_locations( zone.brutus_locations, zkeys[ z ], ( 0, 0.8, 0 ), "brutus" );
			draw_specific_zombie_spawn_locations( zone.mechz_locations, zkeys[ z ], ( 0.3, 0.3, 0.8 ), "mechz" );
		}
	}
}

private zm_debug_connect()
{
	iprintln( "************zm_debug_connect callback\n" );
	self._debug_draw_zones_enabled = false;
	self thread zone_hud();
}

private zone_hud()
{
	self endon( "disconnect" );

	x = 5;
	y = 0;
	zone_hud = self new_debug_hud( x, y );
	zone_hud endon("death");
	zone_hud thread destroy_on_intermission();

	flag_wait_until_set_once( "initial_blackscreen_passed" );

	zone = self get_current_zone();
	prev_zone = zone;
	zone_hud settext( zone );

	for (;;)
	{
		while ( !self._debug_draw_zones_enabled )
		{
			zone_hud.alpha = 0;
			wait 1;
		}

		zone = self get_current_zone();
		if ( !isDefined( zone ) )
		{
			wait 1;
			continue;
		}
		if ( prev_zone != zone )
		{
			prev_zone = zone;

			zone_hud fadeovertime( 0.25 );
			zone_hud.alpha = 0;
			wait 0.25;

			zone_hud settext( zone );

			zone_hud fadeovertime( 0.25 );
			zone_hud.alpha = 1;
			wait 0.25;

			continue;
		}

		wait 0.05;
	}
}

private draw_zombie_spawn_location_box( origin, color, vec = ( 20, 20, 40 ) )
{
	box( origin + ( 0, 0, 20 ), vec * -1, vec, 0, color, 1.0 );
}

private draw_zome_spawn_location_info_text( origin, color, zone_name, location_type_name )
{
	print3d( origin + ( 0, 0, 49 ), "ZONE:" + zone_name );
	print3d( origin + ( 0, 0, 37 ), "TYPE:" + location_type_name );
	print3d( origin + ( 0, 0, 25 ), "ORIGIN:" + origin );
}

private draw_specific_zombie_spawn_locations( loc_array, zone_name, color, type )
{
	draw_type = level._debug_zombie_spawn_loc_draw_aitypes;
	if ( draw_type == "" || ( draw_type != "all" && draw_type != type ) )
	{
		return;
	}

	for ( i = 0; i < loc_array.size; i++ )
	{
		if ( level._debug_zombie_spawn_loc_draw_text )
		{
			draw_zome_spawn_location_info_text( loc_array[ i ].origin, color, zone_name, type );
		}
		
		draw_zombie_spawn_location_box( loc_array[ i ].origin, color );
	}
}