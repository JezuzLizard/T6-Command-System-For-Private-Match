#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;

get_perk_from_alias_zm( alias )
{
	switch ( alias )
	{
		case "ju":
		case "jug":
		case "jugg":
		case "juggernog":
			return "specialty_armorvest";
		case "ro":
		case "rof":
		case "double":
		case "doubletap":
			return "specialty_rof";
		case "qq":
		case "quick":
		case "revive":
		case "quickrevive":
			return "specialty_quickrevive";
		case "sp":
		case "speed":
		case "fastreload":
		case "speedcola":
			return "specialty_fastreload";
		case "st":
		case "staminup":
		case "longersprint":
			return "specialty_longersprint";
		case "fl":
		case "flakjacket":
		case "flopper":
			return "specialty_flakjacket";
		case "ds":
		case "deadshot":
			return "specialty_deadshot";
		case "mk":
		case "mulekick":
			return "specialty_additionalprimaryweapon";
		case "tm":
		case "tombstone":
			return "specialty_scavenger";
		case "ww":
		case "whoswho":
			return "specialty_finalstand";
		case "ec":
		case "electriccherry":
			return "specialty_grenadepulldeath";
		case "va":
		case "vultureaid":
			return "specialty_nomotionsensor";
		case "all":
			return "all";
		default:
			return alias;
	}
}

perk_list_zm()
{
	gametype = getDvar( "ui_zm_mapstartlocation" );
	switch ( level.script )
	{
		case "zm_transit":
			return array( "specialty_armorvest", "specialty_rof", "specialty_quickrevive", "specialty_fastreload", "specialty_longersprint", "specialty_scavenger" );
		case "zm_nuked":
			return array( "specialty_armorvest", "specialty_rof", "specialty_quickrevive", "specialty_fastreload" );
		case "zm_highrise":
			return array( "specialty_armorvest", "specialty_rof", "specialty_quickrevive", "specialty_fastreload", "specialty_additionalprimaryweapon", "specialty_finalstand" );
		case "zm_prison":
			if ( gametype == "zgrief" )
			{
				return array( "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_deadshot", "specialty_grenadepulldeath" );
			}
			else 
			{
				return array( "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_deadshot", "specialty_additionalprimaryweapon", "specialty_flakjacket" );
			}
		case "zm_buried":
			if ( gametype == "zgrief" )
			{
				return array( "specialty_armorvest", "specialty_rof", "specialty_quickrevive", "specialty_fastreload", "specialty_longersprint", "specialty_additionalprimaryweapon" );
			}
			else 
			{
				return array( "specialty_armorvest", "specialty_rof", "specialty_quickrevive", "specialty_fastreload", "specialty_longersprint", "specialty_additionalprimaryweapon", "specialty_nomotionsensor" );
			}
		case "zm_tomb":
			return level._random_perk_machine_perk_list;
	}
}

get_powerup_from_alias_zm( alias )
{
	switch ( alias )
	{
		case "nuke":
			return "nuke";
		case "insta":
		case "instakill":
			return "insta_kill";
		case "double":
		case "doublepoints":
			return "double_points";
		case "max":
		case "ammo":
		case "maxammo":
			return "full_ammo";
		case "carp":
		case "carpenter":
			return "carpenter";
		case "sale":
		case "firesale":
			return "fire_sale";
		case "perk":
		case "freeperk":
			return "free_perk";
		case "blood":
		case "zombieblood":
			return "zombie_blood";
		case "points":
			return "bonus_points";
		case "teampoints":
			return "bonus_points_team";
		default:
			return alias;
	}
}

powerup_list_zm()
{
	gametype = getDvar( "g_gametype" );
	switch ( level.script )
	{
		case "zm_transit":
			if ( gametype == "zgrief" )
			{
				return array( "nuke", "insta_kill", "double_points", "full_ammo", "meat_stink", "teller_withdrawl" );
			}
			else 
			{
				return array( "nuke", "insta_kill", "double_points", "full_ammo", "carpenter", "teller_withdrawl" );
			}
		case "zm_nuked":
			return array( "nuke", "insta_kill", "double_points", "full_ammo", "fire_sale" );
		case "zm_highrise":
			return array( "nuke", "insta_kill", "double_points", "full_ammo", "carpenter", "free_perk" );
		case "zm_prison":
			if ( gametype == "zgrief" )
			{
				return array( "nuke", "insta_kill", "double_points", "full_ammo", "fire_sale", "meat_stink" );
			}
			else 
			{
				return array( "nuke", "insta_kill", "double_points", "full_ammo", "fire_sale" );
			}
		case "zm_buried":
			if ( gametype == "zgrief" )
			{
				return array( "nuke", "insta_kill", "double_points", "full_ammo", "carpenter", "free_perk", "fire_sale", "teller_withdrawl", "random_weapon", "meat_stink" );
			}
			else 
			{
				return array( "nuke", "insta_kill", "double_points", "full_ammo", "carpenter", "free_perk", "fire_sale", "teller_withdrawl", "random_weapon" );
			}
		case "zm_tomb":
			return array( "nuke", "insta_kill", "double_points", "full_ammo", "free_perk", "fire_sale", "zombie_blood", "bonus_points", "bonus_points_team" );
	}
}

get_perma_perk_from_alias( alias )
{
	switch ( alias )
	{
		case "bo":
		case "boards":
			return "pers_boarding";
		case "re":
		case "revive":
			return "pers_reviveonperk";
		case "he":
		case "headshots":
			return "pers_multikill_headshots";
		case "ca":
		case "cashback":
			return "pers_cash_back_prone";
		case "in":
		case "instakill":
			return "pers_insta_kill";
		case "ju":
		case "jugg":
			return "pers_jugg";
		case "cr":
		case "carpenter":
			return "pers_carpenter";
		case "fl":
		case "flopper":
			return "pers_flopper_counter";
		case "pe":
		case "perklose":
			return "pers_perk_lose_counter";
		case "pp":
		case "pistolpoints":
			return "pers_double_points_counter";
		case "sn":
		case "sniperpoints":
			return "pers_sniper_counter";
		case "bx":
		case "boxweapon":
			return "pers_box_weapon_counter";
		case "nu":
		case "nube":
			return "pers_nube_counter";
		case "all":
			return "all";
		default: 
			return alias;
	}
}

weapon_is_available( weapon )
{
	possible_weapons = getArrayKeys( level.zombie_include_weapons );
	weapon_is_available = false;
	for ( i = 0; i < possible_weapons.size; i++ )
	{
		if ( weapon == possible_weapons[ i ] )
		{
			weapon_is_available = true;
			break;
		}
	}
	return weapon_is_available;
}

get_all_weapons()
{
	return getArrayKeys( level.zombie_include_weapons );
}

weapon_is_upgrade( weapon )
{
	return isSubStr( weapon, "upgraded" );
}

array_validate( array )
{
	return isDefined( array ) && isArray( array ) && array.size > 0;
}

cast_to_vector( vector_string )
{
	keys = strTok( vector_string, "," );
	vector_array = [];
	for ( i = 0; i < keys.size; i++ )
	{
		vector_array[ i ] = float( keys[ i ] ); 
	}
	vector = ( vector_array[ 0 ], vector_array[ 1 ], vector_array[ 2 ] );
	return vector;
}

server_safe_notify_thread( notify_name, index )
{
	wait( ( 0.05 * index ) + 0.05 );
	level notify( notify_name );
}

find_player_in_server( clientnum_guid_or_name )
{
	if ( !isDefined( clientnum_guid_or_name ) )
	{
		return undefined;
	}
	if ( clientnum_guid_or_name == "self" )
	{
		return self;
	}
	is_int = is_str_int( clientnum_guid_or_name );
	if ( is_int && ( int( clientnum_guid_or_name ) < getDvarInt( "sv_maxclients" ) ) )
	{
		client_num = int( clientnum_guid_or_name );
		enum = 0;
	}
	else if ( is_int )
	{
		GUID = int( clientnum_guid_or_name );
		enum = 1;
	}
	else 
	{
		name = clientnum_guid_or_name;
		enum = 2;
	}
	player_data = [];
	switch ( enum )
	{
		case 0:
			foreach ( player in level.players )
			{
				if ( player getEntityNumber() == client_num )
				{
					return player;
				}
			}
			break;
		case 1:
			foreach ( player in level.players )
			{
				if ( player getGUID() == GUID )
				{
					return player;
				}
			}
			break;
		case 2:
			foreach ( player in level.players )
			{
				if ( clean_player_name_of_clantag( toLower( player.name ) ) == clean_player_name_of_clantag( name ) || isSubStr( toLower( player.name ), name ) )
				{
					return player;
				}
			}
			break;
	}
	return undefined;
}

getDvarStringDefault( dvarname, default_value )
{
	cur_dvar_value = getDvar( dvarname );
	if ( cur_dvar_value != "" )
	{
		return cur_dvar_value;
	}
	else 
	{
		return default_value;
	}
}

is_command_token( char )
{
	if ( isDefined( level.custom_commands_tokens ) )
	{
		foreach ( token in level.custom_commands_tokens )
		{
			if ( char == token )
			{
				return true;
			}
		}
	}
	return false;
}

is_str_int( str )
{
	val = 0;
	list_num = [];
	list_num[ "0" ] = val;
	val++;
	list_num[ "1" ] = val;
	val++;
	list_num[ "2" ] = val;
	val++;
	list_num[ "3" ] = val;
	val++;
	list_num[ "4" ] = val;
	val++;
	list_num[ "5" ] = val;
	val++;
	list_num[ "6" ] = val;
	val++;
	list_num[ "7" ] = val;
	val++;
	list_num[ "8" ] = val;
	val++;
	list_num[ "9" ] = val;
	for ( i = 0; i < str.size; i++ )
	{
		if ( !isDefined( list_num[ str[ i ] ] ) )
		{
			return false;
		}
	}
	return true;
}

clean_player_name_of_clantag( name )
{
	if ( isSubStr( name, "]" ) )
	{
		keys = strTok( name, "]" );
		return keys[ 1 ];
	}
	return name;
}

cast_bool_to_str( bool, binary_string_options )
{
	options = strTok( binary_string_options, " " );
	if ( options.size == 2 )
	{
		if ( bool )
		{
			return options[ 0 ];
		}
		else 
		{
			return options[ 1 ];
		}
	}
	return bool + "";
}

repackage_args( arg_list )
{
	args_string = "";
	foreach ( arg in arg_list )
	{
		args_string = args_string + arg + " ";
	}
	return args_string;
}

CMD_ADDSERVERCOMMAND( cmdname, cmdaliases, cmdusage, cmdfunc, cmdpower, is_threaded_cmd )
{
	aliases = strTok( cmdaliases, " " );
	level.server_commands[ cmdname ] = spawnStruct();
	level.server_commands[ cmdname ].usage = cmdusage;
	level.server_commands[ cmdname ].func = cmdfunc;
	level.server_commands[ cmdname ].aliases = aliases;
	level.server_commands[ cmdname ].power = cmdpower;
	level.commands_total++;
	if ( ceil( level.commands_total / level.commands_page_max ) >= level.commands_page_count )
	{
		level.commands_page_count++;
	}
	if ( is_true( is_threaded_cmd ) )
	{
		level.threaded_commands[ cmdname ] = true;
	}
}

CMD_REMOVESERVERCOMMAND( cmdname )
{
	new_command_array = [];
	cmd_keys = getArrayKeys( level.server_commands );
	foreach ( cmd in cmd_keys )
	{
		if ( cmdname != cmd )
		{
			new_command_array[ cmd ] = spawnStruct();
			new_command_array[ cmd ].usage = level.server_commands[ cmd ].usage;
			new_command_array[ cmd ].func = level.server_commands[ cmd ].func;
			new_command_array[ cmd ].aliases = level.server_commands[ cmd ].aliases;
			new_command_array[ cmd ].power = level.server_commands[ cmd ].power;
		}
		else 
		{
			level.threaded_commands[ cmd ] = false;
		}
	}
	level.server_commands = new_command_array;
	recalculate_command_page_counts();
} 

CMD_ADDCLIENTCOMMAND( cmdname, cmdaliases, cmdusage, cmdfunc, cmdpower, is_threaded_cmd )
{
	aliases = strTok( cmdaliases, " " );
	level.client_commands[ cmdname ] = spawnStruct();
	level.client_commands[ cmdname ].usage = cmdusage;
	level.client_commands[ cmdname ].func = cmdfunc;
	level.client_commands[ cmdname ].aliases = aliases;
	level.client_commands[ cmdname ].power = cmdpower;
	level.commands_total++;
	if ( ceil( level.commands_total / level.commands_page_max ) >= level.commands_page_count )
	{
		level.commands_page_count++;
	}
	if ( is_true( is_threaded_cmd ) )
	{
		level.threaded_commands[ cmdname ] = true;
	}
}

CMD_REMOVECLIENTCOMMAND( cmdname )
{
	new_command_array = [];
	cmd_keys = getArrayKeys( level.client_commands );
	foreach ( cmd in cmd_keys )
	{
		if ( cmdname != cmd )
		{
			new_command_array[ cmd ] = spawnStruct();
			new_command_array[ cmd ].usage = level.client_commands[ cmd ].usage;
			new_command_array[ cmd ].func = level.client_commands[ cmd ].func;
			new_command_array[ cmd ].aliases = level.client_commands[ cmd ].aliases;
			new_command_array[ cmd ].power = level.client_commands[ cmd ].power;
		}
		else 
		{
			level.threaded_commands[ cmd ] = false;
		}
	}
	level.client_commands = new_command_array;
	recalculate_command_page_counts();
} 

recalculate_command_page_counts()
{
	total_commands = arrayCombine( level.server_commands, level.client_commands, 1, 0 );
	level.commands_page_count = 0;
	for ( level.commands_total = 0; level.commands_total < total_commands.size; level.commands_total++ )
	{
		if ( ceil( level.commands_total / level.commands_page_max ) >= level.commands_page_count )
		{
			level.commands_page_count++;
		}
	}

}

// CMD_CONFIG_UPDATE()
// {
// 	buffer = FS_read( "tcs_config.json" );
// 	if ( buffer != "" )
// 	{
// 		parsed_config_array = jsonParse( buffer );
// 		foreach (  )
// 	}
// }

// VOTE_ADDVOTEABLE( vote_type, vote_type_aliases, usage, pre_vote_execute_func, post_vote_execute_func )
// {
// 	if ( !isDefined( level.custom_votes ) )
// 	{
// 		level.custom_votes = [];
// 	}
// 	if ( !isDefined( level.custom_votes[ vote_type ] ) )
// 	{
// 		level.custom_votes_total++;
// 		if ( ceil( level.custom_votes_total / level.commands_page_max ) >= level.custom_votes_page_count )
// 		{
// 			level.custom_votes_page_count++;
// 		}
// 		level.custom_votes[ vote_type ] = spawnStruct();
// 		level.custom_votes[ vote_type ].pre_func = pre_vote_execute_func;
// 		level.custom_votes[ vote_type ].post_func = post_vote_execute_func;
// 		level.custom_votes[ vote_type ].usage = usage;
// 		level.custom_votes[ vote_type ].aliases = vote_type_aliases;
// 	}
// }

// VOTE_REMOVEVOTEABLE( vote_type )
// {
// 	new_command_array = [];
// 	vote_keys = getArrayKeys( level.custom_votes );
// 	level.custom_votes_total = 0;
// 	level.custom_votes_page_count = 0;
// 	foreach ( vote in vote_keys )
// 	{
// 		if ( vote_type != vote )
// 		{
// 			new_command_array[ vote ] = spawnStruct();
// 			new_command_array[ vote ].pre_func = level.custom_votes[ vote ].pre_func;
// 			new_command_array[ vote ].post_func = level.custom_votes[ vote ].post_func;
// 			new_command_array[ vote ].usage = level.custom_votes[ vote ].usage;
// 			new_command_array[ vote ].aliases = level.custom_votes[ vote ].aliases;
// 			level.custom_votes_total++;
// 			if ( ceil( level.custom_votes_total / level.commands_page_max ) >= level.custom_votes_page_count )
// 			{
// 				level.custom_votes_page_count++;
// 			}
// 		}
// 	}
// 	level.custom_votes = new_command_array;
// } 

CMD_EXECUTE( cmdname, arg_list, is_clientcmd, silent, nologprint )
{
	if ( is_true( level.threaded_commands[ cmdname ] ) )
	{
		if ( is_clientcmd )
		{
			self thread [[ level.client_commands[ cmdname ].func ]]( arg_list );
		}
		else 
		{
			self thread [[ level.server_commands[ cmdname ].func ]]( arg_list );
		}
		return;
	}
	else 
	{
		result = [];
		if ( is_clientcmd )
		{
			result = self [[ level.client_commands[ cmdname].func ]]( arg_list );
		}
		else 
		{
			result = self [[ level.server_commands[ cmdname ].func ]]( arg_list );
		}
	}
	if ( !isDefined( result ) || result.size == 0 || is_true( silent ) )
	{
		return;
	}
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	if ( result[ "filter" ] != "cmderror" )
	{
		cmd_log = self.name + " executed " + result[ "message" ];
		if ( !is_true( nologprint ) )
		{
			level COM_PRINTF( "g_log", result[ "filter" ], cmd_log, self );
		}
		if ( isDefined( result[ "channels" ] ) )
		{
			level COM_PRINTF( result[ "channels" ], result[ "filter" ], result[ "message" ], self );
		}
		else 
		{
			level COM_PRINTF( channel, result[ "filter" ], result[ "message" ], self );
		}
	}
	else
	{
		level COM_PRINTF( channel, result[ "filter" ], result[ "message" ], self );
	}
}

tcs_on_connect()
{
	level endon( "end_commands" );
	while ( true )
	{
		level waittill( "connected", player );
		foreach ( index, dvar in level.clientdvars )
		{
			player setClientDvarThread( dvar[ "name" ], dvar[ "value" ], index );
		}
		if ( player isHost() )
		{
			player.cmdpower_server = level.CMD_POWER_HOST;
			player.cmdpower_client = level.CMD_POWER_HOST;
			player.tcs_rank = level.TCS_RANK_HOST;
			level.host = player;
		}
		else if ( array_validate( level.tcs_player_entries ) )
		{
			foreach ( entry in level.tcs_player_entries )
			{
				if ( find_player_in_server( entry.player_entry ) == player )
				{
					player.cmdpower_server = entry.cmdpower_server;
					player.cmdpower_client = entry.cmdpower_client;
					player.tcs_rank = entry.rank;
				}
			}
		}
		else 
		{
			player.cmdpower_server = getDvarIntDefault( "tcs_cmdpower_server_default", level.CMD_POWER_USER );
			player.cmdpower_client = getDvarIntDefault( "tcs_cmdpower_client_default", level.CMD_POWER_USER );
			player.tcs_rank = getDvarStringDefault( "tcs_default_rank", level.TCS_RANK_USER );
		}
	}
}

//If we have a lot of clientdvars in the pool delay setting them to prevent client command overflow error.
setClientDvarThread( dvar, value, index )
{
	wait( index * 0.25 );
	self setClientDvar( dvar, value );
}