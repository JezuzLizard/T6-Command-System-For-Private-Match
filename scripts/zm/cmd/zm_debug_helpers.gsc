#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_zonemgr;

#include scripts\cmd\sv\core\_utility;
#include scripts\zm\cmd\sv\_zm_utility;

init_zm_debug_helpers()
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
	self._debug_draw = [];
	self._debug_draw[ "zones" ] = false;
	self._debug_draw[ "sph" ] = false;
	self._debug_draw[ "zombie_total" ] = false;
	self._debug_draw[ "zombie_current" ] = false;
	self zone_hud_init();
	self sph_hud_init();
	self zombie_total_hud_init();
	self zombie_count_hud_init();
}

private zone_hud_init()
{
	self endon( "disconnect" );

	x = 5;
	y = 0;
	zone_hud = self new_debug_hud( x, y );
	zone_hud thread destroy_on_intermission();

	self thread zone_hud_thread( zone_hud );
}

private zone_hud_thread( zone_hud )
{
	self endon( "disconnect" );
	zone_hud endon("death");

	flag_wait_until_set_once( "initial_blackscreen_passed" );

	zone = self get_current_zone();
	if ( isdefined( zone ) )
	{
		zone_hud settext( zone );
	}
	prev_zone = "";

	for ( ;; )
	{
		while ( !self._debug_draw[ "zones" ] )
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

private fill_zombie_anim_basic_info( animstates )
{
	anim_keys = getarraykeys( animstates );

	for ( i = 0; i < _SIZE( anim_keys.size ); i++ )
	{
		key = anim_keys[ i ];
		anim_info = spawnstruct();
		substate_count = self GetAnimSubStateCountFromASD( key );
		if ( !isdefined( substate_count ) )
		{
			return;
		}

		anim_info.substate_info = [];
		for ( j = 0; j < _SIZE( substate_count ); j++ )
		{
			substate = spawnstruct();
			substate.anim_length = self GetAnimLengthFromASD( key, j );
			anim_info.substate_info[ anim_info.substate_info.size ] = substate;
		}

		animstates[ key ] = anim_info;
	}
}

private fill_zombie_anim_special_info( animstates )
{
	keys = getarraykeys( animstates );
	for ( i = 0; i < _SIZE( keys.size ); i++ )
	{
		key = keys[ i ];
		anim_info = animstates[ key ];
		anim_info.is_crawler = false;
		anim_info.is_death = false;
		anim_info.is_barrier = false;
		anim_info.is_traverse = false;
		anim_info.move_type = "none";
		anim_info.attack_type = "none";
		anim_info.sidestep_type = "none";
		anim_info.spawn_type = "none";

		// is_crawler
		switch ( key )
		{
			case "zm_inert_crawl":
			case "zm_inert_crawl_trans":
			case "zm_idle_crawl":
			case "zm_move_walk_crawl":
			case "zm_move_run_crawl":
			case "zm_move_sprint_crawl":
			case "zm_move_super_sprint_crawl":
			case "zm_move_stumpy":
			case "zm_walk_melee_crawl":
			case "zm_run_melee_crawl":
			case "zm_stumpy_melee":
			case "zm_zbarrier_board_tear_in_crawl":
			case "zm_zbarrier_board_tear_loop_crawl":
			case "zm_zbarrier_board_tear_out_crawl":
			case "zm_death_crawl":
			case "zm_traverse_barrier_crawl":
			case "zm_barricade_enter_crawl":
			case "zm_traverse_crawl":
				anim_info.is_crawler = true;
				break;
		}

		// move_type
		switch ( key )
		{
			case "zm_inert":
			case "zm_inert_trans":
			case "zm_inert_crawl":
			case "zm_inert_crawl_trans":
				anim_info.move_type = "inert";
				break;
			case "zm_idle":
			case "zm_idle_crawl":
				anim_info.move_type = "idle";
				break;
			case "zm_move_walk":
			case "zm_move_walk_crawl":
				anim_info.move_type = "walk";
				break;
			case "zm_move_run":
			case "zm_move_run_crawl":
				anim_info.move_type = "run";
				break;
			case "zm_move_sprint":
			case "zm_move_sprint_crawl":
				anim_info.move_type = "sprint";
				break;
			case "zm_move_super_sprint":
			case "zm_move_super_sprint_crawl":
				anim_info.move_type = "super_sprint";
				break;
			case "zm_move_stumpy":
				anim_info.move_type = "stumpy";
				break;
			case "zm_taunt":
				anim_info.move_type = "taunt";
				break;
		}

		// attack_type
		switch ( key )
		{
			case "zm_walk_melee":
			case "zm_walk_melee_crawl":
				anim_info.attack_type = "walk";
				break;
			case "zm_run_melee":
			case "zm_run_melee_crawl":
				anim_info.attack_type = "run";
				break;
			case "zm_window_melee":
				anim_info.attack_type = "barrier";
				break;
			case "zm_stumpy_melee":
				anim_info.attack_type = "stumpy";
				break;
		}

		// sidestep_type
		switch ( key )
		{
			case "zm_step_left":
				anim_info.sidestep_type = "left";
				break;
			case "zm_step_right":
				anim_info.sidestep_type = "right";
				break;
			case "zm_roll_forward":
				anim_info.attack_type = "roll";
				break;
		}

		// spawn_type
		switch ( key )
		{
			case "zm_rise":
				anim_info.spawn_type = "rise";
				break;
			case "zm_faller_emerge":
				anim_info.spawn_type = "fall";
				break;
		}

		// is_death
		switch ( key )
		{
			case "zm_death":
			case "zm_death_crawl":
			case "zm_rise_death_in":
			case "zm_rise_death_out":
			case "zm_faller_emerge_death":
				anim_info.is_death = true;
				break;
		}

		// is_barrier
		switch ( key )
		{
			case "zm_zbarrier_board_tear_in":
			case "zm_zbarrier_board_tear_loop":
			case "zm_zbarrier_board_tear_out":
			case "zm_zbarrier_board_tear_in_crawl":
			case "zm_zbarrier_board_tear_loop_crawl":
			case "zm_zbarrier_board_tear_out_crawl":
				anim_info.is_barrier = true;
				break;
		}

		// is_traverse
		switch ( key )
		{
			case "zm_traverse_barrier":
			case "zm_traverse_barrier_crawl":
			case "zm_barricade_enter":
			case "zm_barricade_enter_crawl":
			case "zm_traverse":
			case "zm_traverse_crawl":
				anim_info.is_traverse = true;
				break;
		}
	}
}

draw_debug_zombie_info()
{
	level endon( "draw_debug_zombie_info_stop" );
	self._debug_zombie endon( "death" );
	while ( !isDefined( level.zones ) )
	{
		wait 1;
	}

	flag_wait_until_set_once( "initial_blackscreen_passed" );

	for ( ;; )
	{
		wait 0.05;
		target = self._debug_zombie;
		if ( !isdefined( target ) )
		{
			continue;
		}

		if ( target._print_anim_timings )
		{
			animstates = [];
			switch ( target.animstatedef )
			{
				case "zm_nuked_basic.asd":
					animstates[ "zm_inert" ] = [];
					animstates[ "zm_inert_trans" ] = [];
					animstates[ "zm_inert_crawl" ] = [];
					animstates[ "zm_inert_crawl_trans" ] = [];
					animstates[ "zm_idle" ] = [];
					animstates[ "zm_idle_crawl" ] = [];
					animstates[ "zm_move_walk" ] = [];
					animstates[ "zm_move_walk_crawl" ] = [];
					animstates[ "zm_move_run" ] = [];
					animstates[ "zm_move_run_crawl" ] = [];
					animstates[ "zm_move_sprint" ] = [];
					animstates[ "zm_move_sprint_crawl" ] = [];
					animstates[ "zm_move_super_sprint" ] = [];
					animstates[ "zm_move_super_sprint_crawl" ] = [];
					animstates[ "zm_move_stumpy" ] = [];
					animstates[ "zm_step_left" ] = [];
					animstates[ "zm_step_right" ] = [];
					animstates[ "zm_roll_forward" ] = [];
					animstates[ "zm_walk_melee" ] = [];
					animstates[ "zm_walk_melee_crawl" ] = [];
					animstates[ "zm_run_melee" ] = [];
					animstates[ "zm_run_melee_crawl" ] = [];
					animstates[ "zm_stumpy_melee" ] = [];
					animstates[ "zm_taunt" ] = [];
					animstates[ "zm_zbarrier_board_tear_in" ] = [];
					animstates[ "zm_zbarrier_board_tear_loop" ] = [];
					animstates[ "zm_zbarrier_board_tear_out" ] = [];
					animstates[ "zm_zbarrier_board_tear_in_crawl" ] = [];
					animstates[ "zm_zbarrier_board_tear_loop_crawl" ] = [];
					animstates[ "zm_zbarrier_board_tear_out_crawl" ] = [];
					animstates[ "zm_window_melee" ] = [];
					animstates[ "zm_rise" ] = [];
					animstates[ "zm_rise_death_in" ] = [];
					animstates[ "zm_rise_death_out" ] = [];
					animstates[ "zm_faller_attack" ] = [];
					animstates[ "zm_faller_emerge" ] = [];
					animstates[ "zm_faller_emerge_death" ] = [];
					animstates[ "zm_faller_fall" ] = [];
					animstates[ "zm_faller_fall_loop" ] = [];
					animstates[ "zm_faller_land" ] = [];
					animstates[ "zm_death" ] = [];
					animstates[ "zm_death_crawl" ] = [];
					animstates[ "zm_traverse_barrier" ] = [];
					animstates[ "zm_traverse_barrier_crawl" ] = [];
					animstates[ "zm_barricade_enter" ] = [];
					animstates[ "zm_barricade_enter_crawl" ] = [];
					animstates[ "zm_traverse" ] = [];
					animstates[ "zm_traverse_crawl" ] = [];
					self fill_zombie_anim_basic_info( animstates );
					self fill_zombie_anim_special_info( animstates );
					break;
			}
		}
	}
}

private sph_hud_init()
{
	if ( !isdefined( level.zombie_kill_times ) )
	{
		level.sph_hud_counter = 0;
		level.zombie_kill_times = [];
		level thread calculate_sph_thread();
	}

	sph_hud_counter = self new_debug_hud( 5, 10 );
	sph_hud_counter.alpha = 0;
	sph_hud_counter.label = &"SPH: ";

	self thread sph_hud_thread( sph_hud_counter );
}

private sph_hud_thread( sph_hud_counter )
{
	self endon( "disconnect" );

	for ( ;; )
	{
		while ( !self._debug_draw[ "sph" ] )
		{
			sph_hud_counter.alpha = 0;
			wait 1;
		}
		while ( level.sph_hud_counter == 0 )
		{
			sph_hud_counter setText( "" );
			wait 1;
		}

		sph_hud_counter.alpha = 1;
		sph_hud_counter setValue( level.sph_hud_counter );
		wait 0.05;
	}
}

private calculate_sph_thread()
{
	for ( ;; )
	{
		wait 0.05;
		
		kill_times = getArrayKeys( level.zombie_kill_times );
		now = getTime();
		kills_this_minute = 0;

		for ( i = 0; i < kill_times.size; i++ )
		{
			kill_time = kill_times[ i ];
			
			if ( ( now - int( kill_time ) ) > 60000 )
			{
				level.zombie_kill_times[ kill_time ] = undefined;
				continue;
			}

			kills_this_minute += level.zombie_kill_times[kill_time];
		}

		if ( kills_this_minute > 0 )
		{
			hordes_per_minute = kills_this_minute / 24;
			hordes_per_second = hordes_per_minute / 60;
			seconds_per_horde = 1 / hordes_per_second;
			level.sph_hud_counter = seconds_per_horde;
		}
		else
		{
			level.sph_hud_counter = 0;
		}
	}
}

private zombie_total_hud_init()
{
	zombie_total_hud = self new_debug_hud( 5, 10 );
	zombie_total_hud.alpha = 0;
	zombie_total_hud.label = &"Zombie Total: ";

	self thread zombie_total_hud_thread( zombie_total_hud );
}

private zombie_total_hud_thread( zombie_total_hud )
{
	flag_wait( "all_players_connected" );
	wait 10;
	zombie_total_hud.alpha = 1;
	for ( ;; )
	{
		while ( !self._debug_draw[ "zombie_total" ] )
		{
			zombie_total_hud.alpha = 0;
			wait 1;
		}

		while ( !is_round_ongoing() )
		{
			zombie_total_hud setText( "" );
			wait 1;
		}

		zombie_total_hud.alpha = 1;
		enemies = level.zombie_total;
		zombie_total_hud setValue( enemies );
		wait 0.05;
	}
}

private zombie_count_hud_init()
{
	zombie_count_hud = self new_debug_hud( 5, 10 );
	zombie_count_hud.alpha = 0;
	zombie_count_hud.label = &"Zombie Count: ";

	self thread zombie_count_hud_thread( zombie_count_hud );
}

private zombie_count_hud_thread( zombie_count_hud )
{
	self endon( "disconnect" );

	flag_wait( "all_players_connected" );
	wait 10;
	zombie_count_hud.alpha = 1;
	for ( ;; )
	{
		while ( !self._debug_draw[ "zombie_current" ] )
		{
			zombie_count_hud.alpha = 0;
			wait 1;
		}

		while ( !is_round_ongoing() )
		{
			zombie_count_hud setText( "" );
			wait 1;
		}

		zombie_count_hud.alpha = 1;
		enemies = get_current_zombie_count();
		zombie_count_hud setValue( enemies );
		wait 0.05;
	}
}

private is_round_ongoing()
{
	return ( get_current_zombie_count() > 0 || level.zombie_total > 0 );
}