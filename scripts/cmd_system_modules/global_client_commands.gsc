#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;

cmd_togglehud_f( target_obj, args )
{
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

	return result_cmdinfo( "Your hud has been toggled " + on_off );
}

cmd_god_f( target_obj, args )
{
	on_off = scripts\cmd_system_modules\_cmd_arg::cast_bool_to_str( !is_true( self.tcs_is_invulnerable ), "on off" );
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

	return result_cmdinfo( "God " + on_off );
}

cmd_notarget_f( target_obj, args )
{
	on_off = scripts\cmd_system_modules\_cmd_arg::cast_bool_to_str( !is_true( self.ignoreme ), "on off" );
	if ( on_off == "on" )
	{
		self.ignoreme = true;
	}
	else 
	{
		self.ignoreme = false;
	}
	
	return result_cmdinfo( "Notarget " + on_off );
}

cmd_invisible_f( target_obj, args )
{
	on_off = scripts\cmd_system_modules\_cmd_arg::cast_bool_to_str( !is_true( self.tcs_is_invisible ), "on off" );
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

	return result_cmdinfo( "Invisible " + on_off );
}

cmd_printorigin_f( target_obj, args )
{
	return result_cmdinfo( "Your origin is " + self.origin );
}

cmd_printangles_f( target_obj, args )
{
	return result_cmdinfo( "Your angles are " + self.angles );
}

cmd_bottomlessclip_f( target_obj, args )
{
	on_off = scripts\cmd_system_modules\_cmd_arg::cast_bool_to_str( !is_true( self.tcs_bottomless_clip ), "on off" );
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

	return result_cmdinfo( "Bottomless Clip " + on_off );
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

cmd_teleport_f( target_obj, args )
{
	target = args[ 0 ];
	if ( target == self )
	{
		return result_cmderror( "You cannot teleport to yourself" );
	}

	self setOrigin( target.origin + anglesToForward( target.angles ) * 64 + anglesToRight( target.angles ) * 64 );
	return result_cmdinfo( "Successfully teleported to " + target.name + "'s position" );
}

cmd_cvar_f( target_obj, args )
{
	dvarname = args[ 0 ];
	dvarvalue = args[ 1 ];
	self setClientDvar( dvarname, dvarvalue );

	return result_cmdinfo( "Successfully set " + dvarname + " to " + dvarvalue );
}