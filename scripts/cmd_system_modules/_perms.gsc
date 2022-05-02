#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;

CMD_INIT_PERMS()
{
	level.server_users = [];
	level.server_users[ "admins" ] = spawnStruct();
	level.server_users[ "admins" ].names = [];
	level.server_users[ "admins" ].guids = [];
	level.server_users[ "admins" ].cmd_rate_limit = -1;
	str_keys = strTok( getDvar( "server_admin_guids" ), "," );
	int_keys = [];
	foreach ( key in str_keys )
	{
		int_keys[ int_keys.size ] = int( key );
	}
	level.server_users[ "admins" ].guids = int_keys;
}

CMD_COOLDOWN()
{
	if ( self == level.host )
	{
		return;
	}
	if ( is_true( self.is_admin ) )
	{
		return;
	}
	player_guid = self getGUID();
	foreach ( guid in level.server_users[ "admins" ].guids )
	{
		if ( player_guid == guid )
		{
			self.is_admin = true;
			return;
		}
	}
	player.cmd_cooldown = level.custom_commands_cooldown_time;
	while ( player.cmd_cooldown > 0 )
	{
		player.cmd_cooldown--;
		wait 1;
	}
}

can_use_multi_cmds()
{
	if ( self == level.host )
	{
		return true;
	}
	if ( is_true( self.is_admin ) )
	{
		return true;
	}
	player_guid = self getGUID();
	foreach ( guid in level.server_users[ "admins" ].guids )
	{
		if ( player_guid == guid )
		{
			self.is_admin = true;
			return true;
		}
	}
	return false;
}

has_permission_for_cmd( cmdname, is_clientcmd )
{
	if ( self == level.host )
	{
		return true;
	}
	if ( is_clientcmd && ( self.cmdpower_client >= level.client_commands[ cmdname ].power ) )
	{
		return true;
	}
	if ( self.cmdpower_server >= level.server_commands[ cmdname ].power )
	{
		return true;
	}
	return false;
}