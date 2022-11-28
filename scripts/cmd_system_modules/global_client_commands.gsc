#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;

CMD_TOGGLEHUD_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( is_true( self.tcs_hud_toggled ), "on off" );
	if ( on_off == "off" )
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
	result[ "message" ] = "Your hud has been toggled " + on_off;
	return result;
}

CMD_GOD_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_is_invulnerable ), "on off" );
	if ( on_off == "on" )
	{
		self enableInvulnerability();
		self.tcs_is_invulnerable = true;
	}
	else 
	{
		self disableInvulnerability();
		self.tcs_is_invulnerable = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "God " + on_off;
	return result;
}

CMD_NOTARGET_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_is_notarget ), "on off" );
	if ( on_off == "on" )
	{
		self.ignoreme = true;
		self.tcs_is_notarget = true;
	}
	else 
	{
		self.ignoreme = false;
		self.tcs_is_notarget = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Notarget " + on_off;
	return result;
}

CMD_INVISIBLE_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_is_invisible ), "on off" );
	if ( on_off == "on" )
	{
		self hide();
		self.tcs_is_invisible = true;
	}
	else 
	{
		self show();
		self.tcs_is_invisible = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Invisible " + on_off;
	return result;
}

CMD_PRINTORIGIN_f( arg_list )
{
	result = [];
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Your origin is " + self.origin;
	return result;
}

CMD_PRINTANGLES_f( arg_list )
{
	result = [];
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Your angles are " + self.angles;
	return result;
}

CMD_BOTTOMLESSCLIP_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_bottomless_clip ), "on off" );
	if ( on_off == "on" )
	{
		self thread bottomless_clip();
		self.tcs_bottomless_clip = true;
	}
	else 
	{
		self notify( "stop_bottomless_clip" );
		self.tcs_bottomless_clip = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Bottomless Clip " + on_off;
	return result;
}

bottomless_clip()
{
	self endon( "disconnect" );
	self endon( "stop_bottomless_clip" );
	while ( true )
	{
		weapon = self getCurrentWeapon();
		if ( weapon != "none" )
		{
			self setWeaponAmmoClip( weapon, weaponClipSize( weapon ) );
			self giveMaxAmmo( weapon );
		}
		wait 0.05;
	}
}

CMD_TELEPORT_f( arg_list )
{
	result = [];
	target = self cast_str_to_player( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
	else 
	{
		self setOrigin( target.origin + anglesToForward( target.angles ) * 64 + anglesToRight( target.angles ) * 64 );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully teleported to " + target.name + "'s position";
	}
	return result;
}

CMD_CVAR_f( arg_list )
{
	result = [];
	self setClientDvar( arg_list[ 0 ], arg_list[ 1 ] );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + arg_list[ 0 ] + " to " + arg_list[ 1 ];
	return result;
}