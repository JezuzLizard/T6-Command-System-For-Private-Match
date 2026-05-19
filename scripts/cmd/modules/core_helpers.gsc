#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

list_players_throttled( team )
{
	self notify( "listing_players" );
	self endon( "listing_players" );

	for ( i = 0; i < _SIZE( level.players.size ); i++ )
	{
		player = level.players[ i ];
		if ( isdefined( team ) && player.team != team )
		{
			continue;
		}

		str = "^name: " + player.name;
		str += " entnum: " + player getentitynumber();
		if ( self has_all_perms() )
		{
			str += " guid: " + player getguid();
		}

		self com_printnotitle( str );
		wait 0.1;
	}
		
	self com_printconsoleprintlore();
}

list_cmds_throttled()
{
	self notify( "listing_cmds" );
	self endon( "listing_cmds" );

	cmds = getArrayKeys( level.tcs_cmds );
	for ( i = 0; i < _SIZE( cmds.size ); i++ )
	{
		cmd = cmds[ i ];
		if ( self has_permission_for_cmd( cmd ) )
		{
			message = level.tcs_cmds[ cmd ].usage;
			
			self com_printnotitle( message );
			wait 0.1;
		}
	}
		
	self com_printconsoleprintlore();
}

list_entities_throttled( param )
{
	self notify( "listing_entities" );
	self endon( "listing_entities" );

	entities = param.t[ 0 ];

	targetname_str = undefined;
	classname_str = undefined;
	script_noteworthy_str = undefined;
	for ( i = 0; i < _SIZE( entities.size ); i++ )
	{
		ent = entities[ i ];
		if ( !isdefined( ent ) )
		{
			continue;
		}

		str = "^3entnum " + ent getentitynumber();
		str += "\nClassname: " + _DEFAULT( ent.classname, "" );
		str += "\nAngles: " + ent.angles;
		str += "\nOrigin: " + ent.origin;
		str += "\nTargetname: " + _DEFAULT( ent.targetname, "" );
		str += "\nTarget: " + _DEFAULT( ent.target, "" );
		str += "\nScript_noteworthy: " + _DEFAULT( ent.script_noteworthy, "" );
		str += "\nScript_string: " + _DEFAULT( ent.script_string, "" );
		str += "\Model: " + _DEFAULT( ent.model, "" );
		str += "\nTeam: " + _DEFAULT( ent.team, "" );

		self com_printnotitle( str );
		
		wait 0.1;
	}
		
	self com_printconsoleprintlore();
}

bottomless_clip()
{
	self endon( "disconnect" );
	self endon( "stop_bottomless_clip" );

	for ( ;; )
	{
		weapon = self getcurrentweapon();
		if ( weapon != "none" )
		{
			self setweaponammoclip( weapon, weaponclipsize( weapon ) );
			self givemaxammo( weapon );
		}
		wait 0.05;
	}
}

player_intersection_handle_teleport( player )
{
	if ( is_true( player._intersection_tracker_immune ) || is_true( self._player_intersection_tracker_immune ) )
	{
		return true;
	}

	if ( isdefined( level.player_intersection_tracker_override_original ) && isdefined( level.player_intersection_tracker_override ) && level.player_intersection_tracker_override_original != level.player_intersection_tracker_override )
	{
		return self [[ level.player_intersection_tracker_override_original ]]( player );
	}

	return false;
}

_dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags, weapon )
{
	attacker_default = _DEFAULT( attacker, self );
	inflictor_default = _DEFAULT( inflictor, self );
	hitloc_default = _DEFAULT( hitloc, "head" );
	mod_default = _DEFAULT( mod, "MOD_UNKNOWN" );
	idflags_default = _DEFAULT( idflags, 0 );
	weapon_default = undefined;
	if ( isplayer( self ) )
	{
		weapon_default = _DEFAULT( weapon, self getcurrentweapon() );
	}

	if ( isdefined ( weapon_default ) )
	{
		self dodamage( damage, pos, attacker_default, inflictor_default, hitloc_default, mod_default, idflags_default, weapon_default );
	}
	else if ( isdefined( idflags ) )
	{
		self dodamage( damage, pos, attacker_default, inflictor_default, hitloc_default, mod_default, idflags_default );
	}
	else if ( isdefined( mod ) )
	{
		self dodamage( damage, pos, attacker_default, inflictor_default, hitloc_default, mod_default );
	}
	else if ( isdefined( hitloc ) )
	{
		self dodamage( damage, pos, attacker_default, inflictor_default, hitloc_default );
	}
	else if ( isdefined( inflictor ) )
	{
		self dodamage( damage, pos, attacker_default, inflictor_default );
	}
	else if ( isdefined( attacker ) )
	{
		self dodamage( damage, pos, attacker_default );
	}
	else
	{
		self dodamage( damage, pos );
	}
}

toggle_invulnerability( on_off )
{
	if ( on_off )
	{
		self enableInvulnerability();
		self.tcs_is_invulnerable = true;
	}
	else
	{
		self disableInvulnerability();
		self.tcs_is_invulnerable = false;
	}
}

toggle_notarget( on_off )
{
	if ( on_off )
	{
		self.ignoreme = true;
	}
	else 
	{
		self.ignoreme = false;
	}
}

toggle_invisibility( on_off )
{
	if ( on_off )
	{
		self hide();
		self.tcs_is_invisible = true;
	}
	else 
	{
		self show();
		self.tcs_is_invisible = false;
	}
}

toggle_hud( on_off )
{
	if ( on_off )
	{
		self setclientuivisibilityflag( "hud_visible", 0 );
		self.tcs_hud_toggled = true;
	}
	else
	{
		self setclientuivisibilityflag( "hud_visible", 1 );
		self.tcs_hud_toggled = false;
	}
}

toggle_bottomless_clip( on_off )
{
	if ( on_off )
	{
		self thread bottomless_clip();
		self.tcs_bottomless_clip = true;
	}
	else 
	{
		self notify( "stop_bottomless_clip" );
		self.tcs_bottomless_clip = false;
	}
}

get_eligible_last_cmd()
{
	for ( i = ( _SIZE( self.cmd_history.size ) - 1 ); i >= 0; i-- )
	{
		eligible = true;
		old_cmd_strings = strtok( self.cmd_history[ i ], "^" );
		for ( j = 0; j < old_cmd_strings.size; j++ )
		{
			old_cmd = strtok( old_cmd_strings[ j ], " " )[ 0 ];
			if ( is_true( level.tcs_cmds[ old_cmd ].immune_to_lastcmd ) )
			{
				eligible = false;
				break;
			}
		}

		if ( eligible )
		{
			return self.cmd_history[ i ];
		}
	}

	return "";
}