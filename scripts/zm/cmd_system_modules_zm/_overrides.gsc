#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\zombies\_zm_pers_upgrades_system;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;

pers_upgrades_monitor_override()
{
	if ( !isdefined( level.pers_upgrades ) )
		return;

	if ( !is_classic() )
		return;

	level thread wait_for_game_end();

	while ( true )
	{
		waittillframeend;
		players = getplayers();

		for ( player_index = 0; player_index < players.size; player_index++ )
		{
			player = players[player_index];
			if ( is_true( player.tcs_disable_pers_system ) )
			{
				continue;
			}
			if ( is_player_valid( player ) && isdefined( player.stats_this_frame ) )
			{
				if ( !player.stats_this_frame.size && !( isdefined( player.pers_upgrade_force_test ) && player.pers_upgrade_force_test ) )
					continue;

				for ( pers_upgrade_index = 0; pers_upgrade_index < level.pers_upgrades_keys.size; pers_upgrade_index++ )
				{
					pers_upgrade = level.pers_upgrades[level.pers_upgrades_keys[pers_upgrade_index]];
					is_stat_updated = player is_any_pers_upgrade_stat_updated( pers_upgrade );

					if ( is_stat_updated )
					{
						should_award = player check_pers_upgrade( pers_upgrade );

						if ( should_award )
						{
							if ( isdefined( player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] ) && player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] )
								continue;

							player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] = 1;

							if ( flag( "initial_blackscreen_passed" ) && !is_true( player.is_hotjoining ) )
							{
								type = "upgrade";

								if ( isdefined( level.snd_pers_upgrade_force_type ) )
									type = level.snd_pers_upgrade_force_type;

								player playsoundtoplayer( "evt_player_upgrade", player );

								if ( isdefined( level.pers_upgrade_vo_spoken ) && level.pers_upgrade_vo_spoken )
									player delay_thread( 1, maps\mp\zombies\_zm_audio::create_and_play_dialog, "general", type, undefined, level.snd_pers_upgrade_force_variant );
								else
									player delay_thread( 1, ::play_vox_to_player, "general", type, level.snd_pers_upgrade_force_variant );

								if ( isdefined( player.upgrade_fx_origin ) )
								{
									fx_org = player.upgrade_fx_origin;
									player.upgrade_fx_origin = undefined;
								}
								else
								{
									fx_org = player.origin;
									v_dir = anglestoforward( player getplayerangles() );
									v_up = anglestoup( player getplayerangles() );
									fx_org = fx_org + v_dir * 30 + v_up * 12;
								}

								playfx( level._effect["upgrade_aquired"], fx_org );
								level thread maps\mp\zombies\_zm::disable_end_game_intermission( 1.5 );
							}
							if ( isdefined( pers_upgrade.upgrade_active_func ) )
								player thread [[ pers_upgrade.upgrade_active_func ]]();

							continue;
						}

						if ( isdefined( player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] ) && player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] )
						{
							if ( flag( "initial_blackscreen_passed" ) && !is_true( player.is_hotjoining ) )
								player playsoundtoplayer( "evt_player_downgrade", player );
						}

						player.pers_upgrades_awarded[level.pers_upgrades_keys[pers_upgrade_index]] = 0;
					}
				}

				player.pers_upgrade_force_test = 0;
				player.stats_this_frame = [];
			}
		}

		wait 0.05;
	}
}

wait_network_frame_override()
{
	wait 0.1;
}

checkforalldead_override()
{
	return;
}

check_end_game_intermission_delay_override()
{
	while ( is_true( level.doing_command_system_unittest ) )
	{
		wait 1;
	}
}

never_end_game()
{
	return false;
}

player_fake_death_override()
{
	return;
}

no_player_damage_during_unittest( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return 0;
	}
	if ( level.player_damage_callbacks[ 0 ] != ::no_player_damage_during_unittest )
	{
		return [[ level.player_damage_callbacks[ 0 ] ]]();
	}
	else 
	{
		return -1;
	}
}

setclientfield_override( field_name, value )
{
	if ( !isDefined( self ) || self != level && ( !isPlayer( self ) || self isTestClient() || is_true( self.is_bot ) ) )
	{
		return;
	}
	if ( self == level )
		codesetworldclientfield( field_name, value );
	else
		codesetclientfield( self, field_name, value );
}

setclientfieldtoplayer_override( field_name, value )
{
	if ( !isDefined( self ) || !isPlayer( self ) || self isTestClient() || is_true( self.is_bot ) )
	{
		return;
	}
	codesetplayerstateclientfield( self, field_name, value );
}

vsmgr_monitor_override()
{
	while ( level.vsmgr_initializing )
		wait 0.05;

	typekeys = getarraykeys( level.vsmgr );

	while ( true )
	{
		wait 0.05;
		waittillframeend;
		players = getPlayers();

		for ( type_index = 0; type_index < typekeys.size; type_index++ )
		{
			type = typekeys[type_index];

			if ( !level.vsmgr[type].in_use )
				continue;

			for ( player_index = 0; player_index < players.size; player_index++ )
			{
				if ( players[player_index] isTestClient() || is_true( players[player_index].is_bot ) )
				{
					continue;
				}
					
				update_clientfields_override( players[player_index], level.vsmgr[type] );
			}
		}
	}
}

update_clientfields_override( player, type_struct )
{
    name = player maps\mp\_visionset_mgr::get_first_active_name( type_struct );
    player setclientfieldtoplayer( type_struct.cf_slot_name, type_struct.info[name].slot_index );

    if ( 1 < type_struct.cf_lerp_bit_count )
        player setclientfieldtoplayer( type_struct.cf_lerp_name, type_struct.info[name].state.players[player._player_entnum].lerp );
}

watch_rampage_bookmark_override()
{
	while ( true )
	{
		wait 0.05;
		waittillframeend;
		now = gettime();
		oldest_allowed = now - level.rampage_bookmark_kill_times_msec;
		players = get_players();

		for ( player_index = 0; player_index < players.size; player_index++ )
		{
			player = players[player_index];
			if ( player isTestClient() )
				continue;

			for ( time_index = 0; time_index < level.rampage_bookmark_kill_times_count; time_index++ )
			{
				if ( !player.rampage_bookmark_kill_times[time_index] )
					break;
				else if ( oldest_allowed > player.rampage_bookmark_kill_times[time_index] )
				{
					player.rampage_bookmark_kill_times[time_index] = 0;
					break;
				}
			}

			if ( time_index >= level.rampage_bookmark_kill_times_count )
			{
				maps\mp\_demo::bookmark( "zm_player_rampage", gettime(), player );
				player maps\mp\zombies\_zm::reset_rampage_bookmark_kill_times();
				player.ignore_rampage_kill_times = now + level.rampage_bookmark_kill_times_delay;
			}
		}
	}
}

is_bot_override()
{
	return self isTestClient() || is_true( self.is_bot );
}

onplayerconnect_clientdvars_override()
{
	if ( self isTestClient() || is_true( self.is_bot ) )
	{
		self maps\mp\zombies\_zm_laststand::player_getup_setup();
		return;
	}
	self setclientcompass( 0 );
	self setclientthirdperson( 0 );
	self resetfov();
	self setclientthirdpersonangle( 0 );
	self setclientammocounterhide( 1 );
	self setclientminiscoreboardhide( 1 );
	self setclienthudhardcore( 0 );
	self setclientplayerpushamount( 1 );
	self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
	self setclientaimlockonpitchstrength( 0.0 );
	self maps\mp\zombies\_zm_laststand::player_getup_setup();
}

full_ammo_move_hud_override( player_team )
{
    players = getPlayers( player_team );
    players[0] playsoundtoteam( "zmb_full_ammo", player_team );
    wait 0.5;
    move_fade_time = 1.5;
    self fadeovertime( move_fade_time );
    self moveovertime( move_fade_time );
    self.y = 270;
    self.alpha = 0;
    wait( move_fade_time );
    self maps\mp\gametypes_zm\_hud_util::destroyelem();
}

waittill_string_override( msg, ent )
{
	if ( msg != "death" )
		self endon( "death" );

	ent endon( "die" );

	self waittill( msg );

	ent notify( "returned", msg );
}

/*
        at function "function_3" in file "scripts/callstack_test.gsc"
        at function "function_2" in file "scripts/callstack_test.gsc"
        at function "function_1" in file "scripts/callstack_test.gsc"
        at function "init" in file "scripts/callstack_test.gsc"
*/
get_caller( callstack, caller_index_wanted )
{
	caller_depth = 0;
	//strings = strTok( callstack, "\"" );
	strings = strTok( callstack, " " );
	function_name = "";
	filename = "";
	for ( i = 0; i < strings.size; i++ )
	{
		if ( strings[ i ] == "function" )
		{
			function_name = strings[ i + 1 ];
		}
		else if ( strings[ i ] == "file" )
		{
			filename = strings[ i + 1 ];
		}
		if ( function_name != "" && filename != "" )
		{
			if ( caller_depth == caller_index_wanted )
			{
				return function_name + " " + filename;
			}
			else 
			{
				caller_depth++;
				function_name = "";
				filename = "";
			}
		}
	}
	return "ERROR_NO_CALLER";
}

waittill_multiple_override( string1, string2, string3, string4, string5 )
{
	if ( !isDefined( level.hash_tables ) )
	{
		level.hash_tables = [];
	}
	if ( !isDefined( level.hash_tables[ "waittill_multiple" ] ) )
	{
		level.hash_tables[ "waittill_multiple" ] = [];
	}
	self endon( "death" );
	ent = spawnstruct();
	ent.threads = 0;
	ent.id = level.waittill_ent_id;
	level.waittill_ent_id++;
	if ( isdefined( string1 ) )
	{
		self thread waittill_string( string1, ent );
		ent.threads++;
	}

	if ( isdefined( string2 ) )
	{
		self thread waittill_string( string2, ent );
		ent.threads++;
	}

	if ( isdefined( string3 ) )
	{
		self thread waittill_string( string3, ent );
		ent.threads++;
	}

	if ( isdefined( string4 ) )
	{
		self thread waittill_string( string4, ent );
		ent.threads++;
	}

	if ( isdefined( string5 ) )
	{
		self thread waittill_string( string5, ent );
		ent.threads++;
	}

	message = "";
	if ( self == level )
	{
		object = "level";
	}
	else if ( isAi( self ) )
	{
		object = "ai";
	}
	else if ( isPlayer( self ) )
	{
		object = "player";
	}
	else 
	{
		object = "unknown";
	}
	
	caller = get_caller( getCallStack(), 1 );

	args_hash = 0;
	caller_hash = 0;
	if ( isDefined( string5 ) )
	{
		strings_grouped = string1 + " " + string2 + " " + string3 + " " + string4 + " " + string5;
		args_hash = hashString( strings_grouped );
		message = object + " ent.id: " + ent.id + " starts waittill_multiple: " + strings_grouped + " threads: " + ent.threads + " args_hash: " + args_hash + " caller: " + caller;
		logprint( message + "\n" );
	}
	else if ( isDefined( string4 ) )
	{
		strings_grouped = string1 + " " + string2 + " " + string3 + " " + string4;
		args_hash = hashString( strings_grouped );
		message = object + " ent.id: " + ent.id + " starts waittill_multiple: " + strings_grouped + " threads: " + ent.threads + " args_hash: " + args_hash + " caller: " + caller;
		logprint( message + "\n" );
	}
	else if ( isDefined( string3 ) )
	{
		strings_grouped = string1 + " " + string2 + " " + string3;
		args_hash = hashString( strings_grouped );
		message = object + " ent.id: " + ent.id + " starts waittill_multiple: " + strings_grouped + " threads: " + ent.threads + " args_hash: " + args_hash + " caller: " + caller;
		logprint( message + "\n" );
	}
	else if ( isDefined( string2 ) )
	{
		strings_grouped = string1 + " " + string2;
		args_hash = hashString( strings_grouped );
		message = object + " ent.id: " + ent.id + " starts waittill_multiple: " + strings_grouped + " threads: " + ent.threads + " args_hash: " + args_hash + " caller: " + caller;
		logprint( message + "\n" );
	}
	else if ( isDefined( string1 ) )
	{
		strings_grouped = string1;
		args_hash = hashString( strings_grouped );
		message = object + " ent.id: " + ent.id + " starts waittill_multiple: " + strings_grouped + " threads: " + ent.threads + " args_hash: " + args_hash + " caller: " + caller;
		logprint( message + "\n" );
	}
	else 
	{
		message = object + " ent.id: " + ent.id + " starts waittill_multiple: ERROR_NO_WAITTILL_STRING" + " threads: " + ent.threads + " args_hash: " + args_hash + " caller: " + caller;
		logprint( message + "\n" );		
	}

	if ( level.hash_tables[ "waittill_multiple" ].size > 0 )
	{
		for ( i = 0; i < level.hash_tables[ "waittill_multiple" ].size; i++ )
		{
			table_obj = level.hash_tables[ "waittill_multiple" ][ i ];
			if ( table_obj.id != ent.id && table_obj.args_hash == args_hash && table_obj.object == self && table_obj.caller_hash == caller_hash )
			{
				message = "WARNING: waittill_multiple called again with same parameters before returning, object: " + object + " args_hash: " + args_hash + " caller: " + caller;
				logprint( message + "\n" );
				break;
			}
		}
	}

	if ( args_hash != 0 )
	{
		caller_hash = hashString( caller );
		size = level.hash_tables[ "waittill_multiple" ].size;
		level.hash_tables[ "waittill_multiple" ][ size ] = spawnStruct();
		level.hash_tables[ "waittill_multiple" ][ size ].args_hash = args_hash;
		level.hash_tables[ "waittill_multiple" ][ size ].object = self;
		level.hash_tables[ "waittill_multiple" ][ size ].id = ent.id;
		level.hash_tables[ "waittill_multiple" ][ size ].caller_hash = caller_hash;
	}
	while ( ent.threads )
	{
		ent waittill( "returned" );

		ent.threads--;
	}
	if ( level.hash_tables[ "waittill_multiple" ].size > 0 )
	{
		for ( i = 0; i < level.hash_tables[ "waittill_multiple" ].size; i++ )
		{
			table_obj = level.hash_tables[ "waittill_multiple" ][ i ];
			if ( table_obj.id == ent.id )
			{
				arrayRemoveIndex( level.hash_tables[ "waittill_multiple" ], i );
				break;
			}
		}
	}
	message = object + " ent.id " + ent.id + " ends waittill_multiple";
	logprint( message + "\n" );
	ent notify( "die" );
}

waittill_any_return_override( string1, string2, string3, string4, string5, string6, string7 )
{
	if ( !isDefined( level.hash_tables ) )
	{
		level.hash_tables = [];
	}
	if ( !isDefined( level.hash_tables[ "waittill_any_return" ] ) )
	{
		level.hash_tables[ "waittill_any_return" ] = [];
	}
	if ( ( !isdefined( string1 ) || string1 != "death" ) && ( !isdefined( string2 ) || string2 != "death" ) && ( !isdefined( string3 ) || string3 != "death" ) && ( !isdefined( string4 ) || string4 != "death" ) && ( !isdefined( string5 ) || string5 != "death" ) && ( !isdefined( string6 ) || string6 != "death" ) && ( !isdefined( string7 ) || string7 != "death" ) )
		self endon( "death" );

	ent = spawnstruct();
	ent.id = level.waittill_ent_id;
	level.waittill_ent_id++;
	if ( isdefined( string1 ) )
		self thread waittill_string( string1, ent );

	if ( isdefined( string2 ) )
		self thread waittill_string( string2, ent );

	if ( isdefined( string3 ) )
		self thread waittill_string( string3, ent );

	if ( isdefined( string4 ) )
		self thread waittill_string( string4, ent );

	if ( isdefined( string5 ) )
		self thread waittill_string( string5, ent );

	if ( isdefined( string6 ) )
		self thread waittill_string( string6, ent );

	if ( isdefined( string7 ) )
		self thread waittill_string( string7, ent );

	message = "";
	if ( self == level )
	{
		object = "level";
	}
	else if ( isAi( self ) )
	{
		object = "ai";
	}
	else if ( isPlayer( self ) )
	{
		object = "player";
	}
	else 
	{
		object = "unknown";
	}
	
	caller = get_caller( getCallStack(), 1 );

	args_hash = 0;
	caller_hash = 0;
	if ( isDefined( string7 ) )
	{
		strings_grouped = string1 + " " + string2 + " " + string3 + " " + string4 + " " + string5 + " " + string6 + " " + string7;
	}
	else if ( isDefined( string6 ) )
	{
		strings_grouped = string1 + " " + string2 + " " + string3 + " " + string4 + " " + string5 + " " + string6;
	}	
	else if ( isDefined( string5 ) )
	{
		strings_grouped = string1 + " " + string2 + " " + string3 + " " + string4 + " " + string5;
	}
	else if ( isDefined( string4 ) )
	{
		strings_grouped = string1 + " " + string2 + " " + string3 + " " + string4;
	}
	else if ( isDefined( string3 ) )
	{
		strings_grouped = string1 + " " + string2 + " " + string3;
	}
	else if ( isDefined( string2 ) )
	{
		strings_grouped = string1 + " " + string2;
	}
	else if ( isDefined( string1 ) )
	{
		strings_grouped = string1;
	}
	else 
	{
		message = object + " ent.id: " + ent.id + " starts waittill_any_return: ERROR_NO_WAITTILL_STRING caller: " + caller;
		logprint( message + "\n" );		
	}	
	if ( isDefined( strings_grouped ) && strings_grouped != "" )
	{
		args_hash = hashString( strings_grouped );
		message = object + " ent.id: " + ent.id + " starts waittill_any_return: " + strings_grouped + " args_hash: " + args_hash + " caller: " + caller;
		logprint( message + "\n" );
	}

	if ( level.hash_tables[ "waittill_any_return" ].size > 0 )
	{
		for ( i = 0; i < level.hash_tables[ "waittill_any_return" ].size; i++ )
		{
			table_obj = level.hash_tables[ "waittill_any_return" ][ i ];
			if ( table_obj.id != ent.id && table_obj.args_hash == args_hash && table_obj.object == self && table_obj.caller_hash == caller_hash )
			{
				message = "WARNING: waittill_any_return called again with same parameters before returning, object: " + object + " args_hash: " + args_hash + " caller: " + caller;
				logprint( message + "\n" );
				break;
			}
		}
	}

	if ( args_hash != 0 )
	{
		caller_hash = hashString( caller );
		size = level.hash_tables[ "waittill_any_return" ].size;
		level.hash_tables[ "waittill_any_return" ][ size ] = spawnStruct();
		level.hash_tables[ "waittill_any_return" ][ size ].args_hash = args_hash;
		level.hash_tables[ "waittill_any_return" ][ size ].object = self;
		level.hash_tables[ "waittill_any_return" ][ size ].id = ent.id;
		level.hash_tables[ "waittill_any_return" ][ size ].caller_hash = caller_hash;
	}

	ent waittill( "returned", msg );

	message = object + " ent.id: " + ent.id + " ends waittill_any_return";
	logprint( message + "\n" );

	ent notify( "die" );
	return msg;
}

waittill_any_array_return_override( a_notifies )
{
	if ( !isDefined( a_notifies ) )
	{
		message = "ERROR: waittill_any_array_return input array is undefined";
		logprint( message + "\n" );
		return "ERROR";
	}
	if ( a_notifies.size <= 0 )
	{
		message = "ERROR: waittill_any_array_return input array is empty";
		logprint( message + "\n" );
		return "ERROR";
	}
	if ( isinarray( a_notifies, "death" ) )
		self endon( "death" );

	s_tracker = spawnstruct();
	s_tracker.id = level.waittill_ent_id;
	level.waittill_ent_id++;
	strings = "";
	foreach ( index, str_notify in a_notifies )
	{
		if ( isdefined( str_notify ) )
		{
			strings = strings + " " + str_notify + " ";
			self thread waittill_string( str_notify, s_tracker );
		}
		else 
		{
			message = "ERROR: waittill_any_array_return index " + index + " is undefined";
			logprint( message + "\n" );
		}
	}
	message = "";
	if ( self == level )
	{
		object = "level";
	}
	else if ( isAi( self ) )
	{
		object = "ai";
	}
	else if ( isPlayer( self ) )
	{
		object = "player";
	}
	else 
	{
		object = "unknown";
	}
	
	caller = get_caller( getCallStack(), 1 );

	args_hash = 0;
	caller_hash = 0;

	if ( strings != "" )
	{
		args_hash = hashString( strings );
	}

	message = object + " s_tracker.id: " + s_tracker.id + " starts waittill_any_array_return: " + strings;
	logprint( message + "\n" );

	if ( level.hash_tables[ "waittill_any_array_return" ].size > 0 )
	{
		for ( i = 0; i < level.hash_tables[ "waittill_any_array_return" ].size; i++ )
		{
			table_obj = level.hash_tables[ "waittill_any_array_return" ][ i ];
			if ( table_obj.id != ent.id && table_obj.args_hash == args_hash && table_obj.object == self && table_obj.caller_hash == caller_hash )
			{
				message = "WARNING: waittill_any_array_return called again with same parameters before returning, object: " + object + " args_hash: " + args_hash + " caller: " + caller;
				logprint( message + "\n" );
				break;
			}
		}
	}

	if ( args_hash != 0 )
	{
		caller_hash = hashString( caller );
		size = level.hash_tables[ "waittill_any_array_return" ].size;
		level.hash_tables[ "waittill_any_array_return" ][ size ] = spawnStruct();
		level.hash_tables[ "waittill_any_array_return" ][ size ].args_hash = args_hash;
		level.hash_tables[ "waittill_any_array_return" ][ size ].object = self;
		level.hash_tables[ "waittill_any_array_return" ][ size ].id = ent.id;
		level.hash_tables[ "waittill_any_array_return" ][ size ].caller_hash = caller_hash;
	}

	strings = undefined;
	message = undefined;
	s_tracker waittill( "returned", msg );

	message = object + " s_tracker.id: " + s_tracker.id + " ends waittill_any_array_return";
	logprint( message + "\n" );

	s_tracker notify( "die" );
	return msg;
}

waittill_any_timeout_override( n_timeout, string1, string2, string3, string4, string5 )
{
    if ( ( !isdefined( string1 ) || string1 != "death" ) && ( !isdefined( string2 ) || string2 != "death" ) && ( !isdefined( string3 ) || string3 != "death" ) && ( !isdefined( string4 ) || string4 != "death" ) && ( !isdefined( string5 ) || string5 != "death" ) )
        self endon( "death" );

    ent = spawnstruct();

    if ( isdefined( string1 ) )
        self thread waittill_string( string1, ent );

    if ( isdefined( string2 ) )
        self thread waittill_string( string2, ent );

    if ( isdefined( string3 ) )
        self thread waittill_string( string3, ent );

    if ( isdefined( string4 ) )
        self thread waittill_string( string4, ent );

    if ( isdefined( string5 ) )
        self thread waittill_string( string5, ent );

    ent thread _timeout( n_timeout );

	if ( self == level )
	{
		object = "level";
	}
	else if ( isAi( self ) )
	{
		object = "ai";
	}
	else if ( isPlayer( self ) )
	{
		object = "player";
	}
	else 
	{
		object = "unknown";
	}
	
	caller = get_caller( getCallStack(), 1 );

	args_hash = 0;
	caller_hash = 0;

    ent waittill( "returned", msg );

    ent notify( "die" );
    return msg;
}