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
		case "insta_kill":
			return "insta_kill";
		case "double":
		case "doublepoints":
		case "double_points":
			return "double_points";
		case "max":
		case "ammo":
		case "maxammo":
		case "full_ammo":
			return "full_ammo";
		case "carp":
		case "carpenter":
			return "carpenter";
		case "sale":
		case "firesale":
		case "fire_sale":
			return "fire_sale";
		case "perk":
		case "freeperk":
		case "free_perk":
			return "free_perk";
		case "blood":
		case "zombieblood":
		case "zombie_blood":
			return "zombie_blood";
		case "points":
		case "bonus_points":
			return "bonus_points";
		case "teampoints":
		case "bonus_points_team":
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

find_player_in_server( clientnum_guid_or_name, noprint )
{
	if ( !isDefined( noprint ) )
	{
		noprint = false;
	}
	if ( self.cmdpower >= level.CMD_POWER_MODERATOR )
	{
		partial_message = "clientnums and guids";
	}
	else 
	{
		partial_message = "clientnums";	
	}
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( !isDefined( clientnum_guid_or_name ) )
	{
		if ( !noprint )
		{
			level com_printf( channel, "cmderror", "Could not find player", self );
			level com_printf( channel, "cmderror", "Try using /playerlist to view " + partial_message + " to use a cmd on instead of the name", self );
		}

		return undefined;
	}
	if ( clientnum_guid_or_name == "self" )
	{
		return self;
	}
	is_int = is_str_int( clientnum_guid_or_name );
	client_num = undefined;
	guid = undefined;
	name = undefined;
	if ( is_int && ( int( clientnum_guid_or_name ) < getDvarInt( "sv_maxclients" ) ) )
	{
		client_num = int( clientnum_guid_or_name );
		enum = 0;
	}
	else if ( is_int )
	{
		guid = int( clientnum_guid_or_name );
		enum = 1;
	}
	else 
	{
		name = clientnum_guid_or_name;
		enum = 2;
	}
	player_data = [];
	players = getPlayers();
	switch ( enum )
	{
		case 0:
			for ( i = 0; i < players.size; i++ )
			{
				player = players[ i ];
				if ( player getEntityNumber() == client_num )
				{
					return player;
				}
			}
			break;
		case 1:
			for ( i = 0; i < players.size; i++ )
			{
				player = players[ i ];
				if ( player getGUID() == guid )
				{
					return player;
				}
			}
			break;
		case 2:
			for ( i = 0; i < players.size; i++ )
			{
				player = players[ i ];
				if ( clean_player_name_of_clantag( toLower( player.name ) ) == clean_player_name_of_clantag( name ) || isSubStr( toLower( player.name ), name ) )
				{
					return player;
				}
			}
			break;
	}
	if ( !noprint )
	{
		level com_printf( channel, "cmderror", "Could not find player", self );
		level com_printf( channel, "cmderror", "Try using /playerlist to view " + partial_message + " to use a cmd on instead of the name", self );
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
	if ( isDefined( level.custom_commands_tokens ) && isDefined( level.custom_commands_tokens[ char ] ) )
	{
		return true;
	}
	return false;
}

is_str_int(value)
{
	zero = [];
	zero[ "0" ] = true;
	if ( is_true( zero[ value ] ) )
		return true;
	return int( value ) != 0;
}

is_natural_num(value)
{
	return int(value) > 0;
}

clean_player_name_of_clantag( name )
{
	//count how many square brackets are in the name
	//because Plutonium allows users to create names with square brackets in them criiiiiinge
	cancer_chars_left = [];
	cancer_chars_left[ "[" ] = true;
	cancer_chars_right = [];
	cancer_chars_right[ "]" ] = true;
	count_left = 0;
	count_right = 0;
	name_is_cancer = false;
	for ( i = 0; i < name.size; i++ )
	{
		if ( is_true( cancer_chars_left[ name[ i ] ] ) )
		{
			count_left++;
		}
		else if ( is_true( cancer_chars_right[ name[ i ] ] ) )
		{
			count_right++;
		}
		if ( count_left > 1 || count_right > 1 )
		{
			name_is_cancer = true;
			break;
		}
	}
	if ( name_is_cancer )
	{
		return name;
	}
	else 
	{
		if ( isSubStr( name, "]" ) )
		{
			keys = strTok( name, "]" );
			return keys[ 1 ];
		}
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

cmd_addservercommand( cmdname, cmdaliases, cmdusage, cmdfunc, rankgroup, minargs, is_threaded_cmd )
{
	if ( !isDefined( level.tcs_ranks[ rankgroup ] ) )
	{
		level com_printf( "con|g_log", "cmderror", "Failed to register server cmd " + cmdname + ", attempted to use an unregistered rankgroup " + rankgroup );
		return;
	}
	aliases = [];
	aliases[ 0 ] = cmdname;
	if ( isDefined( cmdaliases ) )
	{
		cmd_aliases_tokens = strTok( cmdaliases, " " );
		for ( i = 1; i < cmd_aliases_tokens.size; i++ )
		{
			aliases[ i ] = cmd_aliases_tokens[ i - 1 ];
		}
	}

	level.server_commands[ cmdname ] = spawnStruct();
	level.server_commands[ cmdname ].usage = cmdusage;
	level.server_commands[ cmdname ].func = cmdfunc;
	level.server_commands[ cmdname ].aliases = aliases;
	level.server_commands[ cmdname ].power = level.tcs_ranks[ rankgroup ].cmdpower;
	level.server_commands[ cmdname ].minargs = minargs;
	level.commands_total++;
	if ( is_true( is_threaded_cmd ) )
	{
		level.threaded_commands[ cmdname ] = true;
	}
	if ( !isDefined( level.server_command_groups ) )
	{
		level.server_command_groups = [];
	}
	if ( !isDefined( level.server_command_groups[ rankgroup ] ) )
	{
		level.server_command_groups[ rankgroup ] = [];
	}
	level.server_command_groups[ rankgroup ][ cmdname ] = true;
}

cmd_removeservercommand( cmdname )
{
	new_command_array = [];
	cmd_keys = getArrayKeys( level.server_commands );
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		cmd = cmd_keys[ i ];
		if ( cmdname != cmd )
		{
			new_command_array[ cmd ] = spawnStruct();
			new_command_array[ cmd ].usage = level.server_commands[ cmd ].usage;
			new_command_array[ cmd ].func = level.server_commands[ cmd ].func;
			new_command_array[ cmd ].aliases = level.server_commands[ cmd ].aliases;
			new_command_array[ cmd ].power = level.server_commands[ cmd ].power;
			new_command_array[ cmd ].minargs = level.server_commands[ cmd ].minargs;
		}
		else 
		{
			level.threaded_commands[ cmd ] = undefined;
			rankgroups = getArrayKeys( level.server_command_groups );
			for ( j = 0; j < rankgroups.size; j++ )
			{
				if ( isDefined( level.server_command_groups[ rankgroups[ i ] ][ cmd ] ) )
				{
					level.server_command_groups[ rankgroups[ i ] ][ cmd ] = undefined;
					break;
				}
			}
		}
	}
	level.server_commands = new_command_array;
}

cmd_setservercommandcmdpower( cmdname, power )
{
	if ( isDefined( level.server_commands[ cmdname ] ) )
	{
		level.server_commands[ cmdname ].power = power;
	}
}

cmd_addclientcommand( cmdname, cmdaliases, cmdusage, cmdfunc, rankgroup, minargs, is_threaded_cmd )
{
	if ( !isDefined( level.tcs_ranks[ rankgroup ] ) )
	{
		level com_printf( "con|g_log", "cmderror", "Failed to register client cmd " + cmdname + ", attempted to use an unregistered rankgroup " + rankgroup );
		return;
	}
	aliases = [];
	aliases[ 0 ] = cmdname;
	if ( isDefined( cmdaliases ) )
	{
		cmd_aliases_tokens = strTok( cmdaliases, " " );
		for ( i = 1; i < cmd_aliases_tokens.size; i++ )
		{
			aliases[ i ] = cmd_aliases_tokens[ i - 1 ];
		}
	}
	level.client_commands[ cmdname ] = spawnStruct();
	level.client_commands[ cmdname ].usage = cmdusage;
	level.client_commands[ cmdname ].func = cmdfunc;
	level.client_commands[ cmdname ].aliases = aliases;
	level.client_commands[ cmdname ].power = level.tcs_ranks[ rankgroup ].cmdpower;
	level.client_commands[ cmdname ].minargs = minargs;
	level.commands_total++;
	if ( is_true( is_threaded_cmd ) )
	{
		level.threaded_commands[ cmdname ] = true;
	}
	if ( !isDefined( level.client_command_groups ) )
	{
		level.client_command_groups = [];
	}
	if ( !isDefined( level.client_command_groups[ rankgroup ] ) )
	{
		level.client_command_groups[ rankgroup ] = [];
	}
	level.client_command_groups[ rankgroup ][ cmdname ] = true;
}

cmd_removeclientcommand( cmdname )
{
	new_command_array = [];
	cmd_keys = getArrayKeys( level.client_commands );
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		cmd = cmd_keys[ i ];
		if ( cmdname != cmd )
		{
			new_command_array[ cmd ] = spawnStruct();
			new_command_array[ cmd ].usage = level.client_commands[ cmd ].usage;
			new_command_array[ cmd ].func = level.client_commands[ cmd ].func;
			new_command_array[ cmd ].aliases = level.client_commands[ cmd ].aliases;
			new_command_array[ cmd ].power = level.client_commands[ cmd ].power;
			new_command_array[ cmd ].minargs = level.client_commands[ cmd ].minargs;
		}
		else 
		{
			level.threaded_commands[ cmd ] = undefined;
			rankgroups = getArrayKeys( level.client_command_groups );
			for ( j = 0; j < rankgroups.size; j++ )
			{
				if ( isDefined( level.client_command_groups[ rankgroups[ i ] ][ cmd ] ) )
				{
					level.client_command_groups[ rankgroups[ i ] ][ cmd ] = undefined;
					break;
				}
			}
		}
	}
	level.client_commands = new_command_array;
}

cmd_setclientcommandcmdpower( cmdname, power )
{
	if ( isDefined( level.client_commands[ cmdname ] ) )
	{
		level.client_commands[ cmdname ].power = power;
	}
}

cmd_execute( cmdname, arg_list, is_clientcmd, silent, nologprint )
{
	// An attempt at printing the usage if the min args isn't met
	channel = self com_get_cmd_feedback_channel();
	result = [];
	if ( !test_cmd_is_valid( cmdname, arg_list, is_clientcmd ) )
	{
		return;
	}
	if ( is_clientcmd )
	{
		if ( is_true( level.threaded_commands[ cmdname ] ) )
		{
			self thread [[ level.client_commands[ cmdname ].func ]]( arg_list );
			return;
		}
		else 
		{
			result = self [[ level.client_commands[ cmdname].func ]]( arg_list );
		}
	}
	else 
	{
		if ( is_true( level.threaded_commands[ cmdname ] ) )
		{
			self thread [[ level.server_commands[ cmdname ].func ]]( arg_list );
			return;
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
	channel = self com_get_cmd_feedback_channel();
	if ( result[ "filter" ] != "cmderror" )
	{
		cmd_log = self.name + " executed " + result[ "message" ];
		if ( !is_true( nologprint ) )
		{
			level com_printf( "g_log", result[ "filter" ], cmd_log, self );
		}
		if ( isDefined( result[ "channels" ] ) )
		{
			level com_printf( result[ "channels" ], result[ "filter" ], result[ "message" ], self );
		}
		else 
		{
			level com_printf( channel, result[ "filter" ], result[ "message" ], self );
		}
	}
	else
	{
		level com_printf( channel, result[ "filter" ], result[ "message" ], self );
	}
}


//If we have a lot of clientdvars in the pool delay setting them to prevent client command overflow error.
setClientDvarThread( dvar, value, index )
{
	wait( index * 0.25 );
	self setClientDvar( dvar, value );
}

check_for_command_alias_collisions()
{
	wait 5;
	server_command_keys = getArrayKeys( level.server_commands );
	client_command_keys = getArrayKeys( level.client_commands );
	aliases = [];
	for ( i = 0; i < client_command_keys.size; i++ )
	{
		for ( j = 0; j < level.client_commands[ client_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.client_commands[ client_command_keys[ i ] ].aliases[ j ];
		}
	}
	for ( i = 0; i < server_command_keys.size; i++ )
	{
		for ( j = 0; j < level.server_commands[ server_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.server_commands[ server_command_keys[ i ] ].aliases[ j ];
		}
	}
	for ( i = 0; i < aliases.size; i++ )
	{
		for ( j = i + 1; j < aliases.size; j++ )
		{
			if ( aliases[ i ] == aliases[ j ] )
			{
				level com_printf( "con", "cmderror", "Command alias collision detected alias " + aliases[ i ] + " is duplicated", level );
				break;
			}
		}
	}
}

parse_cmd_message( message )
{
	if ( message == "" )
	{
		return [];
	}
	//Strip command tokens.
	stripped_message = message;
	if ( is_command_token( message[ 0 ] ) )
	{
		stripped_message = "";
		for ( i = 1; i < message.size; i++ )
		{
			stripped_message += message[ i ];
		}
	}
	multi_cmds = [];
	command_keys = [];
	multiple_cmds_keys = strTok( stripped_message, "," );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_args = strTok( multiple_cmds_keys[ i ], " " );
		cmdname = get_client_cmd_from_alias( cmd_args[ 0 ] );
		cmd_is_clientcmd = true;
		if ( cmdname == "" )
		{
			cmdname = get_server_cmd_from_alias( cmd_args[ 0 ] );
			cmd_is_clientcmd = false;
		}
		if ( cmdname != "" )
		{
			command_keys[ "cmdname" ] = cmdname;
			arrayRemoveIndex( cmd_args, 0 );
			command_keys[ "args" ] = [];
			command_keys[ "args" ] = cmd_args;
			command_keys[ "is_clientcmd" ] = cmd_is_clientcmd;
			multi_cmds[ multi_cmds.size ] = command_keys;
		}
	}
	return multi_cmds;
}

get_server_cmd_from_alias( alias )
{
	command_keys = getArrayKeys( level.server_commands );
	for ( i = 0; i < command_keys.size; i++ )
	{
		for ( j = 0; j < level.server_commands[ command_keys[ i ] ].aliases.size; j++ )
		{
			if ( alias == level.server_commands[ command_keys[ i ] ].aliases[ j ] )
			{
				return command_keys[ i ];
			}
		}
	}
	return "";
}

get_client_cmd_from_alias( alias )
{
	command_keys = getArrayKeys( level.client_commands );
	for ( i = 0; i < command_keys.size; i++ )
	{
		for ( j = 0; j < level.client_commands[ command_keys[ i ] ].aliases.size; j++ )
		{
			if ( alias == level.client_commands[ command_keys[ i ] ].aliases[ j ] )
			{
				return command_keys[ i ];
			}
		}
	}
	return "";
}

test_cmd_is_valid( cmdname, arg_list, is_clientcmd )
{
	channel = self com_get_cmd_feedback_channel();
	if ( is_clientcmd )
	{
		if ( arg_list.size < level.client_commands[ cmdname ].minargs )
		{
			level com_printf( channel, "cmderror", "Usage: " + level.client_commands[ cmdname ].usage, self );
			return false;
		}
	}
	else
	{
		if ( arg_list.size < level.server_commands[ cmdname ].min_args )
		{
			level com_printf( channel, "cmderror", "Usage: " + level.server_commands[ cmdname ].usage, self );
			return false;
		}
	}
	return true;
}