#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

list_players_throttled( team )
{
	self notify( "listing_players" );
	self endon( "listing_players" );

	for ( i = 0; i < level.players.size; i++ )
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
	for ( i = 0; i < cmds.size; i++ )
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

	entities = param.t[ 0 ][ 0 ];

	if ( !isdefined( entities ) )
	{
		assert( false );
		return;
	}
	targetname_str = undefined;
	classname_str = undefined;
	script_noteworthy_str = undefined;
	for ( i = 0; i < entities.size; i++ )
	{
		ent = entities[ i ];
		if ( !isdefined( ent ) )
		{
			continue;
		}

		str = "^3entnum " + ent getentitynumber();

		str += " classname: " + isdefined( ent.classname ) ? ent.classname : "";
		str += " targetname: " + isdefined( ent.targetname ) ? ent.targetname : "";
		str += " script_noteworthy: " + isdefined( ent.script_noteworthy ) ? ent.script_noteworthy : "";
		str += " script_string: " + isdefined( ent.script_string ) ? ent.script_string : "";
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