#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/cmd_system_modules/_com;

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
	switch ( level.script )
	{
		case "zm_transit":
			return array( "specialty_armorvest", "specialty_rof", "specialty_quickrevive", "specialty_fastreload", "specialty_longersprint", "specialty_scavenger" );
		case "zm_nuked":
			return array( "specialty_armorvest", "specialty_rof", "specialty_quickrevive", "specialty_fastreload" );
		case "zm_highrise":
			return array( "specialty_armorvest", "specialty_rof", "specialty_quickrevive", "specialty_fastreload", "specialty_additionalprimaryweapon", "specialty_finalstand" );
		case "zm_prison":
			return array( "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_deadshot", "specialty_grenadepulldeath" );
		case "zm_buried":
			return array( "specialty_armorvest", "specialty_rof", "specialty_quickrevive", "specialty_fastreload", "specialty_longersprint", "specialty_additionalprimaryweapon", "specialty_nomotionsensor" );
		case "zm_tomb":
			return level._random_perk_machine_perk_list;
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

CMD_ADDCOMMAND( cmdname, cmdaliases, cmdusage, cmdfunc, cmdpower, is_threaded_cmd )
{
	aliases = strTok( cmdaliases, " " );
	level.custom_commands[ cmdname ] = spawnStruct();
	level.custom_commands[ cmdname ].usage = cmdusage;
	level.custom_commands[ cmdname ].func = cmdfunc;
	level.custom_commands[ cmdname ].aliases = aliases;
	level.custom_commands[ cmdname ].power = cmdpower;
	level.custom_commands_total++;
	if ( ceil( level.custom_commands_total / level.custom_commands_page_max ) >= level.custom_commands_page_count )
	{
		level.custom_commands_page_count++;
	}
	if ( is_true( is_threaded_cmd ) )
	{
		level.custom_threaded_commands[ cmdname ] = true;
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

VOTE_ADDVOTEABLE( vote_type, vote_type_aliases, usage, pre_vote_execute_func, post_vote_execute_func )
{
	if ( !isDefined( level.custom_votes ) )
	{
		level.custom_votes = [];
	}
	if ( !isDefined( level.custom_votes[ vote_type ] ) )
	{
		level.custom_votes_total++;
		if ( ceil( level.custom_votes_total / level.custom_commands_page_max ) >= level.custom_votes_page_count )
		{
			level.custom_votes_page_count++;
		}
		level.custom_votes[ vote_type ] = spawnStruct();
		level.custom_votes[ vote_type ].pre_func = pre_vote_execute_func;
		level.custom_votes[ vote_type ].post_func = post_vote_execute_func;
		level.custom_votes[ vote_type ].usage = usage;
		level.custom_votes[ vote_type ].aliases = vote_type_aliases;
	}
}

CMD_EXECUTE( cmdname, arg_list )
{
	if ( is_true( level.custom_threaded_commands[ cmdname ] ) )
	{
		self thread [[ level.custom_commands[ cmdname ].func ]]( arg_list );
		return;
	}
	else 
	{
		result = [];
		result = self [[ level.custom_commands[ cmdname ].func ]]( arg_list );
	}
	channel = "iprint";
	if ( result[ "filter" ] != "cmderror" )
	{
		cmd_log = self.name + " executed " + result[ "message" ];
		level COM_PRINTF( "g_log", result[ "filter" ], cmd_log, self );
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

set_clientdvars_on_connect()
{
	level endon( "end_commands" );
	while ( true )
	{
		level waittill( "connected", player );
		foreach ( dvar in level.clientdvars )
		{
			player setClientDvar( dvar[ "name" ], dvar[ "value" ] );
		}
	}
}