#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;

cmd_init_perms()
{
	level.tcs_player_entries = [];
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
				level.tcs_player_entries[ level.tcs_player_entries.size -1 ].cmdpower = int( player_entry_array[ 2 ] );
			}
			else 
			{
				level com_printf( "con|g_log", "permserror", "tcs_player_cmd_perms index " + index + " has (player_entry " + isDefined( player_entry_array[ 0 ] ) + "), (rank " + isDefined( player_entry_array[ 1 ] ) + "), (cmdpower " + isDefined( player_entry_array[ 2 ] ) + ")" );
				level com_printf( "con|g_log", "permserror", "Please check your tcs_player_cmd_perms dvar" );
			}
			index++;
		}
	}
}

add_player_perms_entry( player )
{
	if ( player_exists_in_perms_system( player ) )
	{
		set_player_perms_entry( player );
		return;
	}
	player_perm_list = getDvar( "tcs_player_cmd_perms" );
	player_entry = player.name + " " + player.tcs_rank + " " + player.cmdpower;
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

set_player_perms_entry( player )
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
			player_in_server = level.server cast_str_to_player( player_entry_array[ 0 ], true );
			if ( isDefined( player_in_server ) && player_in_server == player )
			{
				player_entry_array[ 1 ] = player.tcs_rank;
				player_entry_array[ 2 ] = player.cmdpower + "";
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

player_exists_in_perms_system( player )
{
	for ( i = 0; i < level.tcs_player_entries.size; i++ )
	{
		player_in_server = level.server cast_str_to_player( level.tcs_player_entries[ i ].player_entry, true );
		if ( isDefined( player_in_server ) && player_in_server == player )
		{
			return true;
		}
	}
	return false;
}

cmd_cooldown()
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return;
	}
	if ( is_true( self.is_server ) )
	{
		return;
	}
	if ( isDefined( level.host ) && self == level.host )
	{
		return;
	}
	if ( self.cmdpower >= level.cmd_power_trusted_user )
	{
		return;
	}
	self.cmd_cooldown = level.custom_cmds_cooldown_time;
	while ( self.cmd_cooldown > 0 )
	{
		self.cmd_cooldown--;
		wait 1;
	}
}

can_use_multi_cmds()
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return true;
	}
	if ( is_true( self.is_server ) )
	{
		return true;
	}
	if (isDefined( level.host ) && self == level.host )
	{
		return true;
	}
	if ( self.cmdpower >= level.cmd_power_cheat )
	{
		return true;
	}
	return false;
}

has_permission_for_cmd( cmd )
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return true;
	}
	if ( is_true( self.is_server ) )
	{
		return true;
	}
	if ( isDefined( level.host ) && self == level.host )
	{
		return true;
	}
	if ( isDefined( level.tcs_ranks[ self.tcs_rank ] ) && isDefined( level.tcs_ranks[ self.tcs_rank ].disallowed_cmds ) )
	{
		for ( i = 0; i < level.tcs_ranks[ self.tcs_rank ].disallowed_cmds.size; i++ )
		{
			disallowed_cmd = level.tcs_ranks[ self.tcs_rank ].disallowed_cmds[ i ];
			if ( disallowed_cmd == "all_cmds" )
			{
				return false;
			}
			else if ( level.tcs_cmds[ cmd ].is_clientcmd )
			{
				if ( disallowed_cmd == "all_client_cmds" )
				{
					return false;
				}
			}
			else if ( disallowed_cmd == "all_server_cmds" )
			{
				return false;
			}
			if ( cmd == disallowed_cmd )
			{
				return false;
			}
			// In this case the token must be a rank name
			else if ( isDefined( level.cmd_groups[ disallowed_cmd ] ) && isDefined( level.cmd_groups[ disallowed_cmd ][ cmd ] ) )
			{
				return false;
			}
		}
	}
	if ( isDefined( level.tcs_ranks[ self.tcs_rank ] ) && isDefined( level.tcs_ranks[ self.tcs_rank ].allowed_cmds ) )
	{
		for ( i = 0; i < level.tcs_ranks[ self.tcs_rank ].allowed_cmds.size; i++ )
		{
			allowed_cmd = level.tcs_ranks[ self.tcs_rank ].allowed_cmds[ i ];
			if ( allowed_cmd == "all_cmds" )
			{
				return true;
			}
			else if ( level.tcs_cmds[ cmd ].is_clientcmd )
			{
				if ( allowed_cmd == "all_client_cmds" )
				{
					return true;
				}
			}
			else if ( allowed_cmd == "all_server_cmds" )
			{
				return true;
			}
			if ( cmd == allowed_cmd )
			{
				return true;
			}
			// In this case the token must be a rank name
			else if ( isDefined( level.cmd_groups[ allowed_cmd ] ) && isDefined( level.cmd_groups[ allowed_cmd ][ cmd ] ) )
			{
				return true;
			}
		}
	}
	if ( self.cmdpower >= level.tcs_cmds[ cmd ].power )
	{
		return true;
	}
	return false;
}