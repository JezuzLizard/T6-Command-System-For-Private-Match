#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

list_players_throttled( channel, players )
{
	self notify( "listing_players" );
	self endon( "listing_players" );
	for ( i = 0; i < players.size; i++ )
	{
		if ( is_true( self.is_server ) || self.cmdpower >= level.CMD_POWER_MODERATOR )
		{
			message = "^3" + players[ i ].name + " " + players[ i ] getGUID() + " " + players[ i ] getEntityNumber();
		}
		else 
		{
			message = "^3" + players[ i ].name + " " + players[ i ] getEntityNumber();
		}
		level com_printf( channel, "notitle", message, self );
		wait 0.1;
	}
	if ( !is_true( self.is_server ) )
	{
		self com_printinfo( "Use shift + ` and scroll to the bottom to view the full list" );
	}
}

list_cmds_throttled( channel )
{
	self notify( "listing_cmds" );
	self endon( "listing_cmds" );
	cmds = getArrayKeys( level.tcs_cmds );
	for ( i = 0; i < cmds.size; i++ )
	{
		if ( self has_permission_for_cmd( cmds[ i ] ) )
		{
			message = level.tcs_cmds[ cmds[ i ] ].usage;
			
			level com_printf( channel, "notitle", message, self );
			wait 0.1;
		}
	}
	if ( !is_true( self.is_server ) )
	{
		self com_printinfo( "Use shift + ` and scroll to the bottom to view the full list" );
	}
}

list_entities_throttled( channel, str, entities )
{
	self notify( "listing_entities" );
	self endon( "listing_entities" );
	if ( isDefined( str ) )
	{
		for ( i = 0; i < entities.size; i++ )
		{
			ent = entities[ i ];
			if ( !isdefined( ent ) )
			{
				continue;
			}
			if ( isDefined( ent.targetname ) && ent.targetname == str )
			{
				if ( isDefined( ent.classname ) )
				{
					if ( isDefined( ent.script_notetworthy ) )
					{
						level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " targetname " + ent.targetname + " script_noteworthy " + ent.script_noteworthy + " origin " + ent.origin, self );
					}
					else 
					{
						level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " targetname " + ent.targetname + " origin " + ent.origin, self );
					}
				}
				else 
				{
					level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " targetname " + ent.targetname + " origin " + ent.origin, self );
				}
				wait 0.1;
			}
		}
	}
	else
	{
		for ( i = 0; i < entities.size; i++ )
		{
			ent = entities[ i ];
			if ( !isdefined( ent ) )
			{
				continue;
			}
			if ( isDefined( ent.classname ) )
			{
				if ( isDefined( ent.targetname ) )
				{
					if ( isDefined( ent.script_noteworthy ) )
					{
						level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " targetname " + ent.targetname + " script_noteworthy " + ent.script_noteworthy + " origin " + ent.origin, self );
					}
					else 
					{
						level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " targetname " + ent.targetname + " origin " + ent.origin, self );
					}
				}
				else 
				{
					level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " classname " + ent.classname + " origin " + ent.origin, self );
				}
			}
			else 
			{
				level com_printf( channel, "notitle", "Ent " + ent getEntityNumber() + " origin " + ent.origin, self );
			}
			wait 0.1;
		}
	}
	if ( !is_true( self.is_server ) )
	{
		self com_printinfo( "Use shift + ` and scroll to the bottom to view the full list" );
	}
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