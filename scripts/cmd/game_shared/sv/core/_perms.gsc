#include common_scripts\utility;

#include scripts\cmd\game_shared\sv\core\_utility;

init_perms()
{
	level.tcs_player_entries = [];

	tcs_default_ranks = _ARRAY( "none", "user", "trusted", "elevated", "moderator", "cheat", "host", "owner" );
	tcs_perms = spawnstruct();
	tcs_perms.ranks = [];
	for ( i = 0; i < _SIZE( tcs_default_ranks.size ); i++ )
	{
		rank = tcs_default_ranks[ i ];
		allowedcmds_dvar = get_dvar_string_default( "tcs_rank_" + rank + "_allowedcmds", "" );
		disallowedcmds_dvar = get_dvar_string_default( "tcs_rank_" + rank + "_disallowedcmds", "" );
		tcs_perms.ranks[ rank ] = spawnstruct();
		if ( allowedcmds_dvar != "" )
		{
			tcs_perms.ranks[ rank ].allowedcmds = _STRTOK( allowedcmds_dvar, " " );
		}
		if ( disallowedcmds_dvar != "" )
		{
			tcs_perms.ranks[ rank ].disallowedcmds = _STRTOK( disallowedcmds_dvar, " " );
		}
	}

	custom_ranks_str = get_dvar_string_default( "tcs_custom_rank_names", "" );
	custom_ranks = undefined;
	if ( custom_ranks_str != "" )
	{
		custom_ranks = _STRTOK( custom_ranks_str, " " );
	}

	if ( isdefined( custom_ranks ) )
	{
		for ( i = 0; i < _SIZE( custom_ranks.size ); i++ )
		{
			rank = custom_ranks[ i ];
			allowedcmds_dvar = get_dvar_string_default( "tcs_rank_" + rank + "_allowedcmds", "" );
			disallowedcmds_dvar = get_dvar_string_default( "tcs_rank_" + rank + "_disallowedcmds", "" );
			tcs_perms.ranks[ rank ] = spawnstruct();
			if ( allowedcmds_dvar != "" )
			{
				tcs_perms.ranks[ rank ].allowedcmds = _STRTOK( allowedcmds_dvar, " " );
			}
			if ( disallowedcmds_dvar != "" )
			{
				tcs_perms.ranks[ rank ].disallowedcmds = _STRTOK( disallowedcmds_dvar, " " );
			}
		}
	}
	level.tcs_perms = tcs_perms;

	player_perm_list = getDvar( "tcs_player_cmd_perms" );
	if ( player_perm_list != "" )
	{
		player_entries = _STRTOK( player_perm_list, "|" );
		index = 0;
		for ( i = 0; i < _SIZE( player_entries.size ); i++ )
		{
			player_entry = player_entries[ i ];
			player_entry_array = _STRTOK( player_entry, " " );
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