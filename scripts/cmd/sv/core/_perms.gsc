#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;

init_perms()
{
	level.tcs_player_entries = [];

	tcs_default_ranks = array( "none", "user", "trusted", "elevated", "moderator", "cheat", "host", "owner" );
	tcs_perms = spawnstruct();
	tcs_perms.ranks = [];
	for ( i = 0; i < tcs_default_ranks.size; i++ )
	{
		rank = tcs_default_ranks[ i ];
		allowedcmds_dvar = get_dvar_string_default( "tcs_rank_" + rank + "_allowedcmds", "" );
		disallowedcmds_dvar = get_dvar_string_default( "tcs_rank_" + rank + "_disallowedcmds", "" );
		tcs_perms.ranks[ rank ] = spawnstruct();
		tcs_perms.ranks[ rank ].allowedcmds = allowedcmds_dvar != "" ? strtok( allowedcmds_dvar, " " ) : undefined;
		tcs_perms.ranks[ rank ].disallowedcmds = disallowedcmds_dvar != "" ? strtok( disallowedcmds_dvar, " " ) : undefined;
	}

	custom_ranks_str = get_dvar_string_default( "tcs_custom_rank_names", "" );
	custom_ranks = custom_ranks_str != "" ? strtok( custom_ranks_str, " " ) : undefined;
	if ( isdefined( custom_ranks ) )
	{
		for ( i = 0; i < _SIZE( custom_ranks.size ); i++ )
		{
			rank = custom_ranks[ i ];
			allowedcmds_dvar = get_dvar_string_default( "tcs_rank_" + rank + "_allowedcmds", "" );
			disallowedcmds_dvar = get_dvar_string_default( "tcs_rank_" + rank + "_disallowedcmds", "" );
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
		for ( i = 0; i < _SIZE( player_entries.size ); i++ )
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