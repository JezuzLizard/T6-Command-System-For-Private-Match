#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;
#include scripts\cmd\sv\modules\core_helpers;

add_core_cmds()
{
	cmd_block_set_module_group( "core_common" );
	cmd_block_set_rank_group( "cheat" );
	cmd_add( "cvar", ::cmd_setcvar_f, "cvar <cvarname> <newval>" );
	arg_add_required( 1, "cvarname", "string", "Name of client dvar" );
	arg_add_required( 2, "newval", "string", "New value to assign to client dvar" );
	target_add_optional( 1, "player", "player", "Players to modify cvar for" );
	target_set_default_target( 1, "self" );

	cmd_add( "god", ::cmd_god_f, "god" );
	target_add_optional( 1, "player", "player", "Players to give god status" );
	target_set_default_target( 1, "self" );

	cmd_add( "notarget", ::cmd_notarget_f, "notarget" );
	target_add_optional( 1, "player", "player", "Players to give notarget status" );
	target_set_default_target( 1, "self" );

	cmd_add( "invisible", ::cmd_invisible_f, "invisible" );
	target_add_optional( 1, "player", "player", "Players to give invisible status" );
	target_set_default_target( 1, "self" );

	cmd_add( "togglehud", ::cmd_togglehud_f, "togglehud" );
	target_add_optional( 1, "player", "player", "Players to disable hud" );
	target_set_default_target( 1, "self" );

	cmd_add( "bottomlessclip", ::cmd_bottomlessclip_f, "bottomlessclip" );
	target_add_optional( 1, "player", "player", "Players to give bottomless clip" );
	target_set_default_target( 1, "self" );

	cmd_add( "dvar", ::cmd_server_dvar_f, "dvar <dvarname> <newval>" );
	arg_add_required( 1, "dvarname", "string", "Name of dvar" );
	arg_add_required( 2, "newval", "string", "New value to assign to dvar" );

	cmd_add( "setrank", ::cmd_setrank_f, "setrank {player} <rank>" );
	arg_add_required( 1, "rank", "rank", "New rank to assign to target player" );
	target_add_required( 1, "player", "player", "Player whos rank will be modified to be <rank>", 1 );

	cmd_add( "entitylist", ::cmd_entitylist_f, "entitylist {entities}" );
	target_add_optional( 1, "entities", "general", "Entities to print info for" );

	cmd_add( "dodamage", ::cmd_dodamage_f, "dodamage {victim} <damage> <origin> {attacker} {inflictor} [hitloc] [MOD] [idflags] [weapon]" );
	arg_add_required( 1, "damage", "float", "Amount of damage to inflict upon entity" );
	arg_add_optional_with_default( 2, "origin", "vector", "The position where the entity will take damage from", ( 0, 0, 0 ) );
	arg_add_optional( 3, "hitloc", "hitloc", "Hit location on the entity the damage will hit" );
	arg_add_optional_with_default( 4, "meansofdeath", "MOD", "The means of death(MOD) the damage will do", "MOD_UNKNOWN" );
	arg_add_optional( 5, "idflags", "idflags", "Special damage flags modifying the damage effects" );
	arg_add_optional( 6, "damageweapon", "weapon", "The weapon used for damage effects" );
	target_add_required( 1, "victims", "general", "Entities who will receive <damage> from <origin>" );
	target_add_optional( 2, "attacker", "general", "Entity who will be set as the <attacker>", 1 );
	target_add_optional( 3, "inflictor", "general", "Entity who will be set as the <inflictor>", 1 );

	cmd_add( "teleportentity", ::cmd_teleportentity_f, "teleportentity {entity_from} {entity_to}" );
	target_add_optional( 1, "entity_from", "general", "Entity who will be teleported" );
	target_add_required( 2, "entity_to", "general", "Entity to teleport to", 1 );
	target_set_default_target( 1, "self" );

	cmd_add( "teleportorigin", ::cmd_teleportorigin_f, "teleportorigin {entity_from} <origin>" );
	target_add_optional( 1, "entity_from", "general", "Entity who will be teleported" );
	arg_add_required( 2, "origin", "vector", "Origin to teleport to" );
	target_set_default_target( 1, "self" );

	// very nice builtin which allows get entities in an arbitrary abstract volume
	// GetTouchingVolume( vec, vec, vec );
	// printentitiesinradius_cmd = cmd_add( "printentitiesinradius", ::cmd_printentitiesinradius_f, "printentitiesinradius {entity_anchor} {entity_filter} [radius=1000]" );
	// printentitiesinradius_cmd arg_add( "float", 0, 1 );
	// printentitiesinradius_cmd target_add( "entity entity" );

	cmd_add( "scrnotify", ::cmd_scrnotify_f, "scrnotify {entity} <notifyname> [notifyargs] ..." );
	arg_add_required( 1, "notifyname", "string", "Name of notify to notify on the entity" );
	arg_add_optional( 2, "notifyargs", "...", "Additional arguments to send with the notify" );
	target_add_optional( 1, "entity", "general", "Entity who will be notified", 1 );
	make_cmd_immune_to_unittest();

	cmd_block_set_rank_group( "none" );
	cmd_add( "cmdlist", ::cmd_cmdlist_f );

	cmd_add( "playerlist", ::cmd_playerlist_f, "playerlist [team]" );
	arg_add_optional( 1, "team", "team", "Filter players by team" );

	cmd_add( "printorigin", ::cmd_printorigin_f, "printorigin {entity}" );
	target_add_optional( 1, "entity", "general", "Entity who's origin will be printed; default the executor's" );
	target_set_default_target( 1, "self" );

	cmd_add( "printangles", ::cmd_printangles_f, "printangles {entity}" );
	target_add_optional( 1, "entity", "general", "Entity who's angles will be printed; default the executor's" );
	target_set_default_target( 1, "self" );

	cmd_add( "help", ::cmd_help_f, "help [cmdalias]" );
	arg_add_optional( 1, "cmdalias", "cmdalias", "Provide help for specific command" );

	// Sets the default cmd target for the executor(normally 'self'); this allows the server through rcon or otherwise to still use the default target functionality that makes the default target 'self' or another entity.
	cmd_add( "setdefaultcmdtarget", ::cmd_setdefaultcmdtarget_f, "setdefaultcmdtarget {entity}" );
	target_add_required( 1, "entity", "general", "Entity set as the default target for commands with optional targets" );

	cmd_add( "debug", ::cmd_debug_f, "debug ..." );
	arg_add_optional( 1, "additional_args", "...", "Special arguments for debugging" );
	make_cmd_immune_to_unittest();

	cmd_add( "lastcmd", ::cmd_lastcmd_f, "lastcmd", "Execute the previous used command string, except this one." );
	make_cmd_immune_to_lastcmd();

	cmd_add( "listcmdhistory", ::cmd_listcmdhistory_f, "listcmdhistory", "Print the last 16 executed command strings." );

	cmd_add( "kill", ::cmd_kill_f, "kill {entity}" );
	target_add_required( 1, "victim", "general", "Entities to kill" );

	cmd_add( "delete", ::cmd_delete_f, "delete {entity}" );
	target_add_required( 1, "victim", "general", "Entities to delete" );
}

private cmd_setcvar_f( param )
{
	dvarname = param.a[ 0 ];
	dvarvalue = param.a[ 1 ];
	targets = param.t[ 0 ];
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			player setClientDvar( dvarname, dvarvalue );
			param add_executor_cmdinfo( "Successfully set '{}' '{}' '{}'", player.name, dvarname, dvarvalue );
			param add_player_cmdinfo( player, "Your '{}' was modified to '{}'", dvarname, dvarvalue );
		}
	}
	else
	{
		param add_executor_cmdinfo( "Successfully set your '{}' to '{}'", dvarname, dvarvalue );
		self setClientDvar( dvarname, dvarvalue );
	}
}

private cmd_god_f( param )
{
	targets = param.t[ 0 ];

	on_off = cast_bool_to_str( !is_true( self.tcs_is_invulnerable ), "on off" );
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			player toggle_invulnerability( on_off == "on" );
			param add_executor_cmdinfo( "Successfully toggled '{}' god status to '{}'", player.name, on_off );
			param add_player_cmdinfo( player, "Your god status was toggled '{}'", on_off );
		}
	}
	else
	{
		self toggle_invulnerability( on_off == "on" );
		param add_executor_cmdinfo( "God " + on_off );
	}
}

private cmd_notarget_f( param )
{
	targets = param.t[ 0 ];

	on_off = cast_bool_to_str( !is_true( self.ignoreme ), "on off" );
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			player toggle_notarget( on_off == "on" );
			param add_executor_cmdinfo( "Successfully toggled '{}' notarget status to '{}'", player.name, on_off );
			param add_player_cmdinfo( player, "Your notarget status was toggled '{}'", on_off );
		}
	}
	else
	{
		self toggle_notarget( on_off == "on" );
		param add_executor_cmdinfo( "Notarget " + on_off );
	}
}

private cmd_invisible_f( param )
{
	targets = param.t[ 0 ];

	on_off = cast_bool_to_str( !is_true( self.tcs_is_invisible ), "on off" );
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			player toggle_invisibility( on_off == "on" );
			param add_executor_cmdinfo( "Successfully toggled '{}' invisibility status to '{}'", player.name, on_off );
			param add_player_cmdinfo( player, "Your invisibility status was toggled '{}'", on_off );
		}
	}
	else
	{
		self toggle_invisibility( on_off == "on" );
		param add_executor_cmdinfo( "Invisibility '{}'", on_off );
	}
}

private cmd_togglehud_f( param )
{
	targets = param.t[ 0 ];

	on_off = cast_bool_to_str( is_true( self.tcs_hud_toggled ), "on off" );
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			player toggle_hud( on_off == "on" );
			param add_executor_cmdinfo( "Successfully toggled '{}' hud status to '", player.name, on_off );
			param add_player_cmdinfo( player, "Your hud status was toggled '{}'", on_off );
		}
	}
	else
	{
		self toggle_hud( on_off == "on" );
		param add_executor_cmdinfo( "Your hud has been toggled '{}'", on_off );
	}
}

private cmd_bottomlessclip_f( param )
{
	targets = param.t[ 0 ];

	on_off = cast_bool_to_str( !is_true( self.tcs_bottomless_clip ), "on off" );
	if ( array_validate( targets ) )
	{
		for ( i = 0; i < _SIZE( targets.size ); i++ )
		{
			player = targets[ i ];
			player toggle_bottomless_clip( on_off == "on" );
			param add_executor_cmdinfo( "Successfully toggled '{}' bottomless clip status to '", player.name, on_off );
			param add_player_cmdinfo( player, "Your bottomless clip status was toggled '{}'", on_off );
		}
	}
	else
	{
		self toggle_bottomless_clip( on_off == "on" );
		param add_executor_cmdinfo( "Bottomless Clip '{}'", on_off );
	}
}

private cmd_server_dvar_f( param )
{
	dvarname = param.a[ 0 ];
	dvarvalue = param.a[ 1 ];
	setDvar( dvarname, dvarvalue );

	param add_executor_cmdinfo( "Successfully set '{}' to '{}'", dvarname, dvarvalue );
}

private cmd_setrank_f( param )
{
	target = param.t[ 0 ][ 0 ];
	if ( !self has_all_perms() )
	{
		return param add_executor_cmderror( "Insufficient rank to set '{}'s rank", target.name );
	}

	new_rank = param.a[ 0 ];
	if ( !self has_all_perms() )
	{
		return param add_executor_cmderror( "You cannot set '{}' to a rank higher than or equal to your own", target.name );
	}

	target.tcs_pl.tcs_rank = new_rank;
	//add_player_perms_entry( target );
	target com_printinfo( "Your new rank is '{}'", new_rank );

	param add_executor_cmdinfo( "Target's new rank is '{}'", new_rank );
}

private cmd_playerlist_f( param )
{
	if ( level.players.size == 0 )
	{
		return param add_executor_cmderror( "The server is empty" );
	}

	team = param.a[ 0 ];
	self thread list_players_throttled( team );
}

private cmd_cmdlist_f( param )
{
	self thread list_cmds_throttled();
}

private cmd_help_f( param )
{
	specific_cmd = param.a[ 0 ];

	if ( isdefined( specific_cmd ) )
	{
		self com_printcmd_help( specific_cmd );
		return;
	}

	if ( is_true( self.is_server ) )
	{
		self com_printnotitle( "^3To view cmds you can use 'tcscmd cmdlist' in the console" );
		self com_printnotitle( "^3To view players in the server do 'tcscmd playerlist' in the console" );
		self com_printnotitle( "^3To view the usage of a specific cmd do 'tcscmd help' <cmdalias>" );
	}
	else 
	{
		valid_cmd_tokens = getDvar( "tcs_cmd_tokens" );
		if ( level.tcs_glob.bhidden_cmds )
		{
			self com_printnotitle("^3Valid cmd prefixes are '/ {}'", valid_cmd_tokens );
		}
		else 
		{
			self com_printnotitle( "^3Valid cmd prefixes are '{}'", valid_cmd_tokens );
		}

		self com_printnotitle( "^3To view cmds you can use 'cmdlist'" );
		self com_printnotitle( "^3To view players in the server do 'playerlist'" );
		self com_printnotitle( "^3To view the usage of a specific cmd do 'help' <cmdalias>" );
	}

	if ( isDefined( level.tcs_additional_help_prints_func ) )
	{
		self [[ level.tcs_additional_help_prints_func ]]();
	}
	self com_printconsoleprintlore();
}

private cmd_dodamage_f( param )
{
	victims = param.t[ 0 ];
	attacker = param.t[ 1 ][ 0 ];
	inflictor = param.t[ 2 ][ 0 ];
	damage = param.a[ 0 ];
	pos = param.a[ 1 ];
	hitloc = param.a[ 2 ];
	mod = param.a[ 3 ];
	idflags = param.a[ 4 ];
	weapon = param.a[ 5 ];

	for ( i = 0; i < _SIZE( victims.size ); i++ )
	{
		victim = victims[ i ];
		victim_name = _DEFAULT( victim.name, victim.classname );
		attacker_name = "unspecified";
		inflictor_name = "unspecified";
		hitloc_name = _DEFAULT( hitloc, "head" );
		mod_name = _DEFAULT( mod, "MOD_UNKNOWN" );
		idflags_val = _DEFAULT( idflags, "none" );
		weapon_name = _DEFAULT( weapon, "none" );
		if ( isdefined( attacker ) )
		{
			attacker_name = _DEFAULT( attacker.name, attacker.classname );
		}
		if ( isdefined( inflictor ) )
		{
			inflictor_name = _DEFAULT( inflictor.name, inflictor.classname );
		}
		
		param add_executor_cmdinfo( "Damaged entity: '{}' for points: '{}' of damage, from: '{}', by attacker: '{}', by inflictor: '{}', at hitloc: '{}', with mod: '{}', using weapon: '{}'", victim_name, damage, pos, attacker_name, inflictor_name, hitloc_name, mod_name, weapon_name );
		victim _dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags, weapon );
	}

	param add_executor_cmdinfo( "Damaged '{}' entities", victims.size );
}

private cmd_entitylist_f( param )
{
	self thread list_entities_throttled( param );
}

private cmd_scrnotify_f( param )
{
	notify_ent = param.t[ 0 ][ 0 ];
	notify_name = param.a[ 0 ];

	arg_count = param.a.size - 1;

	switch ( arg_count )
	{
		case 0:
			notify_ent notify( notify_name );
			break;
		case 1:
			notify_ent notify( notify_name, param.a[ 2 ] );
			break;
		case 2:
			notify_ent notify( notify_name, param.a[ 2 ], param.a[ 3 ] );
			break;
		case 3:
			notify_ent notify( notify_name, param.a[ 2 ], param.a[ 3 ], param.a[ 4 ] );
			break;
		default:
			return param add_executor_cmderror( "Max arguments is 3!" );
	}

	param add_executor_cmdinfo( "Successfully delivered notify '{}'", notify_name );
}

private cmd_printorigin_f( param )
{
	targets = param.t[ 0 ];

	if ( !array_validate( targets ) )
	{
		targets[ 0 ] = self;
	}

	for ( i = 0; i < _SIZE( targets.size ); i++ )
	{
		ent = targets[ i ];
		ent_name = _DEFAULT( ent.name, ent.classname );
		param add_executor_cmdinfo( "Entity: '{}' origin is: '{}'", ent_name, ent.origin );
	}
}

private cmd_printangles_f( param )
{
	targets = param.t[ 0 ];

	if ( !array_validate( targets ) )
	{
		targets[ 0 ] = self;
	}

	for ( i = 0; i < _SIZE( targets.size ); i++ )
	{
		ent = targets[ i ];
		ent_name = _DEFAULT( ent.name, ent.classname );
		param add_executor_cmdinfo( "Entity: '{}' angles is: '{}'", ent_name, ent.origin );
	}
}

private cmd_teleportentity_f( param )
{
	from_targets = param.t[ 0 ];
	to_target = param.t[ 1 ][ 0 ];

	// allow implicitly teleporting the executor to an entity if not specified
	from_targets[ 0 ] = _DEFAULT( from_targets[ 0 ], self );

	if ( isplayer( to_target ) )
	{
		to_target._intersection_tracker_immune = true;
	}

	if ( !isdefined( level.player_intersection_tracker_override_original ) )
	{
		level.player_intersection_tracker_override_original = level.player_intersection_tracker_override;
	}
	
	level.player_intersection_tracker_override = ::player_intersection_handle_teleport;

	for ( i = 0; i < _SIZE( from_targets.size ); i++ )
	{
		from = from_targets[ i ];
		from_name = _DEFAULT( from.name, from.classname );
		to_name = _DEFAULT( to_target.name, to_target.classname );
		if ( isplayer( from ) )
		{
			from._intersection_tracker_immune = true;
			param add_player_cmdinfo( from, "You have been teleported to entity: '{}' at: '{}'", to_name, to_target.origin );
			from setOrigin( to_target.origin );
		}
		else
		{
			from.origin = to_target.origin;
		}

		param add_executor_cmdinfo( "Successfully teleported entity: '{}' at: '{}' to: '{}'", from_name, from.origin, to_target.origin );
	}
}

private cmd_teleportorigin_f( param )
{
	from_targets = param.t[ 0 ];
	destination = param.a[ 0 ];

	// allow implicitly teleporting the executor to an entity if not specified
	from_targets[ 0 ] = _DEFAULT( from_targets[ 0 ], self );

	if ( !isdefined( level.player_intersection_tracker_override_original ) )
	{
		level.player_intersection_tracker_override_original = level.player_intersection_tracker_override;
	}
	
	level.player_intersection_tracker_override = ::player_intersection_handle_teleport;

	for ( i = 0; i < _SIZE( from_targets.size ); i++ )
	{
		from = from_targets[ i ];
		from_name = _DEFAULT( from.name, from.classname );
		if ( isplayer( from ) )
		{
			from._intersection_tracker_immune = true;
			param add_player_cmdinfo( from, "You have been teleported to origin: '{}'", destination );
			from setOrigin( destination );
		}
		else
		{
			from.origin = destination;
		}

		param add_executor_cmdinfo( "Successfully teleported entity: '{}' at: '{}' to: '", from_name, from.origin, destination );
	}
}

private cmd_setdefaultcmdtarget_f( param )
{
	self.default_targets = param.t[ 0 ];

	param add_executor_cmdinfo( "Successfully set your default cmd targets" );
}

private cmd_debug_f( param )
{
	type = param.a[ 0 ];

	switch ( type )
	{
		case "continue":
			self notify( "debug_continue" );
			break;
		case "abort":
			self notify( "debug_abort" );
			break;
	}
}

private cmd_lastcmd_f( param )
{
	last_cmd_string_to_execute = self get_eligible_last_cmd();
	if ( last_cmd_string_to_execute == "" )
	{
		return param add_executor_cmderror( "You haven't executed any previous eligible(i.e not lastcmd) commands" );
	}

	self.in_lastcmd_execution_block = true;
	self cmd_execute_single_command( last_cmd_string_to_execute, true, false );
	self.in_lastcmd_execution_block = false;
}

private cmd_listcmdhistory_f( param )
{
	if ( self.cmd_history.size <= 0 )
	{
		return param add_executor_cmderror( "You haven't executed any commands yet. Until now..." );
	}

	for ( i = 0; i < _SIZE( self.cmd_history.size ); i++ )
	{
		entry = self.cmd_history[ i ];
		self com_printnotitle( entry );
	}
}

private cmd_kill_f( param )
{
	targets = param.t[ 0 ];

	for ( i = 0; i < targets.size; i++ )
	{
		target = targets[ i ];
		target setcandamage( true );
		//target stop_magic_bullet_shield();
		if ( isplayer( self ) )
		{
			target _dodamage( target.health, ( 0, 0, 0 ), self );
		}
		else
		{
			target _dodamage( target.health, ( 0, 0, 0 ) );
		}
	}
}

private cmd_delete_f( param )
{
	targets = param.t[ 0 ];

	for ( i = 0; i < targets.size; i++ )
	{
		target = targets[ i ];
		target delete();
	}
}
