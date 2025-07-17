#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

autoexec cmd_init_perms()
{
	level.tcs_player_entries = [];

	tcs_default_ranks = array( "none", "user", "trusted", "elevated", "moderator", "cheat", "host", "owner" );
	tcs_perms = spawnstruct();
	tcs_perms.ranks = [];
	for ( i = 0; i < tcs_default_ranks.size; i++ )
	{
		rank = tcs_default_ranks[ i ];
		allowedcmds_dvar = getdvarstringdefault( "tcs_rank_" + rank + "_allowedcmds", "" );
		disallowedcmds_dvar = getdvarstringdefault( "tcs_rank_" + rank + "_disallowedcmds", "" );
		tcs_perms.ranks[ rank ] = spawnStruct();
		tcs_perms.ranks[ rank ].allowedcmds = allowedcmds_dvar != "" ? strtok( allowedcmds_dvar, " " ) : undefined;
		tcs_perms.ranks[ rank ].disallowedcmds = disallowedcmds_dvar != "" ? strtok( disallowedcmds_dvar, " " ) : undefined;
	}

	custom_ranks_str = getdvarstringdefault( "tcs_custom_rank_names", "" );
	custom_ranks = custom_ranks_str != "" ? strtok( custom_ranks_str, " " ) : undefined;
	if ( isdefined( custom_ranks ) )
	{
		for ( i = 0; i < custom_ranks.size; i++ )
		{
			rank = custom_ranks[ i ];
			allowedcmds_dvar = getdvarstringdefault( "tcs_rank_" + rank + "_allowedcmds", "" );
			disallowedcmds_dvar = getdvarstringdefault( "tcs_rank_" + rank + "_disallowedcmds", "" );
			tcs_perms.ranks[ rank ] = spawnstruct();
			tcs_perms.ranks[ rank ].allowedcmds = allowedcmds_dvar != "" ? strtok( allowedcmds_dvar, " " ) : undefined;
			tcs_perms.ranks[ rank ].disallowedcmds = disallowedcmds_dvar != "" ? strtok( disallowedcmds_dvar, " " ) : undefined;
		}
	}
	level.tcs_perms = tcs_perms;

	player_perm_list = getDvar( "tcs_player_cmd_perms" );
	if ( player_perm_list != "" )
	{
		player_entries = strTok( player_perm_list, "|" );
		index = 0;
		for ( i = 0; i < player_entries.size; i++ )
		{
			player_entry = player_entries[ i ];
			player_entry_array = strTok( player_entry, " " );
			if ( isDefined( player_entry_array[ 0 ] ) && isDefined( player_entry_array[ 1 ] ) && isDefined( player_entry_array[ 2 ] ) )
			{
				level.tcs_player_entries[ level.tcs_player_entries.size ] = spawnStruct(); 
				level.tcs_player_entries[ level.tcs_player_entries.size -1 ].player_entry = player_entry_array[ 0 ];
				level.tcs_player_entries[ level.tcs_player_entries.size -1 ].rank = player_entry_array[ 1 ];
			}
			else 
			{
				level com_printf( "con|g_log", "permserror", "tcs_player_cmd_perms index " + index + " has (player_entry " + isDefined( player_entry_array[ 0 ] ) + "), (rank " + isDefined( player_entry_array[ 1 ] ) + ")" );
				level com_printf( "con|g_log", "permserror", "Please check your tcs_player_cmd_perms dvar" );
			}
			index++;
		}
	}
}

private add_player_perms_entry( player )
{
	if ( player_exists_in_perms_system( player ) )
	{
		set_player_perms_entry( player );
		return;
	}
	player_perm_list = getDvar( "tcs_player_cmd_perms" );
	player_entry = player.name + " " + player.tcs_rank;
	if ( player_perm_list[ player_perm_list.size - 1 ] == "|" )
	{
		player_perm_list = player_perm_list + player_entry;
	}
	else 
	{
		player_perm_list = player_perm_list + "|" + player_entry;
	}
	if ( player_perm_list.size > 1024 )
	{
		level com_printf( "con|g_log", "permserror", "Cannot save dvar tcs_player_cmd_perms, new size is greater than 1024" );
		return;
	}
	setDvar( "tcs_player_cmd_perms", player_perm_list );
	level com_printf( "g_log", "permsinfo", "set tcs_player_cmd_perms \"" + player_perm_list + "\" \n" );
	cmd_init_perms();
}

private set_player_perms_entry( player )
{
	player_perm_list = getDvar( "tcs_player_cmd_perms" );
	if ( player_perm_list != "" )
	{
		player_entry_array = undefined;
		player_entries = strTok( player_perm_list, "|" );
		index = 0;
		found_player = false;
		for ( i = 0; i < player_entries.size; i++ )
		{
			player_entry = player_entries[ i ];
			player_entry_array = strTok( player_entry, " " );
			player_in_server = level.server cast_str_to_entity( player_entry_array[ 0 ], "player" );
			if ( !player_in_server.errored && player_in_server.value == player )
			{
				player_entry_array[ 1 ] = player.tcs_rank;
				found_player = true;
				break;
			}
			if ( !found_player )
			{
				index++;
			}
		}
		if ( found_player )
		{
			player_entries[ index ] = player_entry_array[ 0 ] + " " + player_entry_array[ 1 ] + " " + player_entry_array[ 2 ];
			new_perms_list = "";
			for ( i = 0; i < player_entries.size; i++ )
			{
				new_perms_list += player_entries[ i ] + ",";
			}
			if ( new_perms_list.size > 1024 )
			{
				return;
			}
			setDvar( "tcs_player_cmd_perms", new_perms_list );
			level com_printf( "g_log", "permsinfo", "set tcs_player_cmd_perms \"" + player_perm_list + "\" \n" );
			cmd_init_perms();
		}
	}
}

private player_exists_in_perms_system( player )
{
	for ( i = 0; i < level.tcs_player_entries.size; i++ )
	{
		player_in_server = level.server cast_str_to_entity( level.tcs_player_entries[ i ].player_entry, "player" );
		if ( !player_in_server.errored && player_in_server.value == player )
		{
			return true;
		}
	}
	return false;
}