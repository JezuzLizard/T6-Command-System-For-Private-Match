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

	if ( !array_validate( entities ) )
	{
		assert( false );
		return;
	}
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

		str += " classname: " + _DEFAULT( ent.classname, "" );
		str += " targetname: " + _DEFAULT( ent.targetname, "" );
		str += " script_noteworthy: " + _DEFAULT( ent.script_noteworthy, "" );
		str += " script_string: " + _DEFAULT( ent.script_string, "" );
		str += " angles: " + ent.angles;
		str += " origin: " + ent.origin;

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

	return self [[ level.player_intersection_tracker_override_original ]]( player );
}

_dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags, weapon )
{
	attacker = _DEFAULT( attacker, undefined );
	inflictor = _DEFAULT( inflictor, undefined );
	hitloc = _DEFAULT( hitloc, undefined );
	mod = _DEFAULT( mod, undefined );
	idflags = _DEFAULT( idflags, undefined );
	weapon = _DEFAULT( weapon, undefined );

	if ( isdefined( weapon ) )
	{
		self dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags, weapon );
	}
	else if ( isdefined( idflags ) )
	{
		self dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags );
	}
	else if ( isdefined( mod ) )
	{
		self dodamage( damage, pos, attacker, inflictor, hitloc, mod );
	}
	else if ( isdefined( hitloc ) )
	{
		self dodamage( damage, pos, attacker, inflictor, hitloc );
	}
	else if ( isdefined( inflictor ) )
	{
		self dodamage( damage, pos, attacker, inflictor );
	}
	else if ( isdefined( attacker ) )
	{
		self dodamage( damage, pos, attacker );
	}
	else
	{
		self dodamage( damage, pos );
	}
}