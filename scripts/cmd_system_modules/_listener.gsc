#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;

command_listener_wait_for_user_input()
{
	self endon( "new_command_listener" );
	self waittill( "listener", args );
	result = [];
	var_args = strTok( args, " " );
	return var_args;
}

command_listener_timeout( listener_name )
{
	self endon( "new_command_listener" );
	self endon( "listener" );
	
	for ( current_time = 0; current_time < level.tcs_listener_timeout_time; current_time += 0.05 )
	{
		wait 0.05;
	}
	self notify( "listener", "timeout" );
}