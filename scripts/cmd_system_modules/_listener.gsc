#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;

CMD_ADDSERVERCOMMANDLISTENER( listener_name, listener_cmd )
{
	if ( !isDefined( level.listener_commands ) )
	{
		level.listener_commands = [];
	}
	if ( !isDefined( level.listener_commands[ listener_name ] ) )
	{
		level.listener_commands[ listener_name ] = [];
	}
	if ( !isDefined( level.listener_commands[ listener_name ][ listener_cmd ] ) )
	{
		level.listener_commands[ listener_name ][ listener_cmd ] = true;
	}
}

CMD_ISCOMMANDLISTENER_ACTIVE( listener_name )
{
	return is_true( self.cmd_listeners[ listener_name ].active );
}

CMD_ISCOMMANDLISTENER( listener_name, listener_cmd )
{
	return is_true( level.listener_commands[ listener_name ][ listener_cmd ] );
}

CMD_EXECUTELISTENER( listener_name, arg_list )
{
	self.cmd_listeners[ listener_name ].data = arg_list;
}

setup_command_listener( listener_name )
{
	if ( !isDefined( self.cmd_listeners ) )
	{
		self.cmd_listeners = [];
	}
	if ( !isDefined( self.cmd_listeners[ listener_name ] ) )
	{
		self.cmd_listeners[ listener_name ] = spawnStruct();
	}
	self.cmd_listeners[ listener_name ].data = [];
	self.cmd_listeners[ listener_name ].timeout = false;
	self.cmd_listeners[ listener_name ].active = true;
	self thread command_listener_timelimit( listener_name );
	self thread clear_command_listener_on_cmd_reuse( listener_name );
}

wait_command_listener( listener_name )
{
	self endon( listener_name );
	result = [];
	while ( true )
	{
		if ( array_validate( self.cmd_listeners[ listener_name ].data ) )
		{
			result = self.cmd_listeners[ listener_name ].data;
			return result;
		}
		else if ( !self.cmd_listeners[ listener_name ].active )
		{
			result[ 0 ] = "timeout";
			return result;
		}
		wait 0.05;
	}
}

clear_command_listener_on_cmd_reuse( listener_name )
{
	self endon( listener_name + "_timeout_reset" );
	self waittill( listener_name );
	self.cmd_listeners[ listener_name ].active = false;
}

clear_command_listener( listener_name )
{
	self endon( listener_name + "_timeout_reset" );
	self.cmd_listeners[ listener_name ].active = false;
}

command_listener_timelimit( listener_name )
{
	self endon( listener_name );
	self endon( listener_name + "_timeout_reset" );
	for ( i = level.custom_commands_listener_timeout; i > 0; i-- )
	{
		wait 1;
	}
	self.cmd_listeners[ listener_name ].active = false;
}