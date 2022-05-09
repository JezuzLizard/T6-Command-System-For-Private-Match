#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd_system_modules\_cmd_util;

CMD_TOGGLEHUD_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_hud_toggled ), "on off" );
	if ( on_off == "on" )
	{
		self setclientuivisibilityflag( "hud_visible", 0 );
		self.tcs_hud_toggled = true;
	}
	else 
	{
		self setclientuivisibilityflag( "hud_visible", 1 );
		self.tcs_hud_toggled = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "togglehud: Your hud has been toggled " + on_off;
	return result;
}