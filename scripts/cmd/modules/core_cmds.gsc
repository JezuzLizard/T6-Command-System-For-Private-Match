#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_utility;

#include scripts\cmd\core_command_helpers;

autoexec add_cmds()
{
	cmd_block_set_module_group( "core_common" );
	cmd_block_set_rank_group( "cheat" );
	setcvar_cmd = cmd_add( "cvar", ::cmd_setcvar_f, "cvar {player} <cvarname> <newval>" );
	setcvar_cmd arg_obj_add_cmd( "string string", 2, 2 );
	setcvar_cmd target_obj_add_cmd( "player", false, "Player whos <cvarname> will be set to <newval>" );

	dvar_cmd = cmd_add( "dvar", ::cmd_server_dvar_f, "dvar <dvarname> <newval>" );
	dvar_cmd arg_obj_add_cmd( "string string", 2, 2 );

	givegod_cmd = cmd_add( "god", ::cmd_givegod_f, "god {player}" );
	givegod_cmd target_obj_add_cmd( "player", false, "Player who will receive god status" );

	givenotarget_cmd = cmd_add( "notarget", ::cmd_givenotarget_f, "notarget {player}" );
	givenotarget_cmd target_obj_add_cmd( "player", false, "Player who will receive notarget status" );

	giveinvisible_cmd = cmd_add( "invisible", ::cmd_giveinvisible_f, "invisible {player}" );
	giveinvisible_cmd target_obj_add_cmd( "player", false, "Player who will be hidden" );

	setrank_cmd = cmd_add( "setrank", ::cmd_setrank_f, "setrank {player} <rank>" );
	setrank_cmd arg_obj_add_cmd( "rank", 1, 1 );
	setrank_cmd target_obj_add_cmd( "player", true, "Player whos rank will be modified to be <rank>" );

	entitylist_cmd = cmd_add( "entitylist", ::cmd_entitylist_f, "entitylist [targetname]" );
	entitylist_cmd arg_obj_add_cmd( "string", 0, 1 );

	dodamage_cmd = cmd_add( "dodamage", ::cmd_dodamage_f, "dodamage {entity_to_be_damaged} <damage> <origin> {entity_who_is_attacker} {entity_who_is_inflictor} [hitloc] [MOD] [idflags] [weapon]" );
	dodamage_cmd arg_obj_add_cmd( "float vector hitloc MOD idflags weapon", 2, 6 );
	dodamage_cmd target_obj_add_cmd( "entity", true, "Entity who will receive <damage> from <origin>" );
	dodamage_cmd target_obj_add_cmd( "entity", false, "Entity who will be set as the <attacker>" );
	dodamage_cmd target_obj_add_cmd( "entity", false, "Entity who will be set as the <inflictor>" );

	teleportplayer_cmd = cmd_add( "teleporttoplayer", ::cmd_teleportplayer_f, "teleporttoplayer {player_from} {player_to}" );
	teleportplayer_cmd target_obj_add_cmd( "player", false, "Player who will be teleported" );
	teleportplayer_cmd target_obj_add_cmd( "player", true, "Player who will be teleported" );

	bottomlessclip_cmd = cmd_add( "bottomlessclip", ::cmd_bottomlessclip_f, "bottomlessclip {player}" );
	bottomlessclip_cmd target_obj_add_cmd( "player" );

	printentitiesinradius_cmd = cmd_add( "printentitiesinradius", ::cmd_printentitiesinradius_f, "printentitiesinradius {entity_anchor} {entity_filter} [radius=1000]" );
	printentitiesinradius_cmd arg_obj_add_cmd( "float", 0, 1 );
	printentitiesinradius_cmd target_obj_add_cmd( "entity entity" );

	togglehud_cmd = cmd_add( "scrnotify", ::cmd_scrnotify_f, "scrnotify {entity} <notifyent> <notifyname> [notifyargs] ..." );
	togglehud_cmd arg_obj_add_cmd( "string string ...", 2, 255 );
	togglehud_cmd target_obj_add_cmd( "entity" );

	cmd_block_set_rank_group( "none" );
	cmdlist_cmd = cmd_add( "cmdlist", ::cmd_cmdlist_f );

	playerlist_cmd = cmd_add( "playerlist", ::cmd_playerlist_f, "playerlist {team}" );
	playerlist_cmd target_obj_add_cmd( "team" );

	printorigin_cmd = cmd_add( "printorigin", ::cmd_printorigin_f, "printorigin {entity}" );
	printorigin_cmd target_obj_add_cmd( "entity" );

	printangles_cmd = cmd_add( "printangles", ::cmd_printangles_f, "printangles {entity}" );
	printangles_cmd target_obj_add_cmd( "entity" );

	help_cmd = cmd_add( "help", ::cmd_help_f, "help [cmdalias]" );
	help_cmd arg_obj_add_cmd( "cmdalias", 0, 1 );

	togglehud_cmd = cmd_add( "togglehud", ::cmd_togglehud_f, "togglehud {player}" );
	togglehud_cmd target_obj_add_cmd( "player" );

	// Sets the default cmd target for the executor(normally 'self'); this allows the server through rcon or otherwise to still use the default target functionality that makes the default target 'self' or another entity.
	setdefaultcmdtarget_cmd = cmd_add( "setdefaultcmdtarget", ::cmd_setdefaultcmdtarget_f, "setdefaultcmdtarget {player}" );
	setdefaultcmdtarget_cmd target_obj_add_cmd( "player", true );

	setdefaultcmdexecutor_cmd = cmd_add( "setdefaultcmdexecutor", ::cmd_setdefaultcmdexecutor_f, "setdefaultcmdexecutor {player}" );
	setdefaultcmdexecutor_cmd target_obj_add_cmd( "player", true );

	// entities are no longer used in plain argument syntax, use the target syntax instead

	// executor argtype/target for level.server and player commands
}

private cmd_server_dvar_f( target_obj, args )
{
	dvarname = args[ 0 ];
	dvarvalue = args[ 1 ];
	setDvar( dvarname, dvarvalue );

	return result_cmdinfo( "Successfully set " + dvarname + " to " + dvarvalue );
}

private cmd_cvarall_f( target_obj, args )
{
	dvarname = args[ 0 ];
	dvarvalue = args[ 1 ];
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] setClientDvar( dvarname, dvarvalue );
	}
	new_dvar = [];
	new_dvar[ "name" ] = dvarname;
	new_dvar[ "value" ] = dvarvalue; 
	level.clientdvars[ level.clientdvars.size ] = new_dvar;

	return result_cmdinfo( "Successfully set " + dvarname + " to " + dvarvalue + " for all players" );
}

private cmd_setcvar_f( target_obj, args )
{
	target = args[ 0 ];
	dvarname = args[ 1 ];
	dvarvalue = args[ 2 ];
	target setClientDvar( dvarname, dvarvalue );

	return result_cmdinfo( "Successfully set " + target.name + "'s " + dvarname + " to " + dvarvalue );
}

private cmd_givegod_f( target_obj, args )
{
	target = args[ 0 ];
	if ( !is_true( target.tcs_is_invulnerable ) )
	{
		target enableInvulnerability();
		target.tcs_is_invulnerable = true;
	}
	else 
	{
		target disableInvulnerability();
		target.tcs_is_invulnerable = false;
	}

	return result_cmdinfo( "Toggled god for " + target.name );
}

private cmd_givenotarget_f( target_obj, args )
{
	target = args[ 0 ];
	target.ignoreme = !target.ignoreme;

	return result_cmdinfo( "Toggled notarget for " + target.name );
}

private cmd_giveinvisible_f( target_obj, args )
{
	target = args[ 0 ];
	if ( !is_true( target.tcs_is_invisible ) )
	{
		target hide();
		target.tcs_is_invisible = true;
	}
	else 
	{
		target show();
		target.tcs_is_invisible = false;
	}

	return result_cmdinfo( "Toggled invisibility for " + target.name );
}

private cmd_setrank_f( target_obj, args )
{
	target = args[ 0 ];
	if ( !is_true( self.is_server ) && self.cmdpower < target.cmdpower )
	{
		return result_cmderror( "Insufficient cmdpower to set " + target.name + "'s rank" );
	}
	new_rank = args[ 1 ];
	if ( !is_true( self.is_server ) && ( level.tcs_perms.ranks[ new_rank ].cmdpower >= self.cmdpower ) && self.cmdpower < level.tcs_perms.ranks[ "host" ].cmdpower )
	{
		return result_cmderror( "You cannot set " + target.name + " to a rank higher than or equal to your own" );
	}

	target.tcs_rank = new_rank;
	target.cmdpower = level.tcs_perms.ranks[ new_rank ].cmdpower;
	//add_player_perms_entry( target );
	target com_printinfo( "Your new rank is " + new_rank );

	return result_cmdinfo( "Target's new rank is " + new_rank );
}

private cmd_playerlist_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	players = getPlayers();
	if ( players.size == 0 )
	{
		return result_cmderror( "There are no players in the server" );
	}
	self thread list_players_throttled( channel, players );

	return result_cmdinfo( "" );
}

private cmd_cmdlist_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	self thread list_cmds_throttled( channel );
	return result_cmdinfo( "" );
}

private cmd_help_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	if ( is_true( self.is_server ) )
	{
		level com_printf( channel, "notitle", "^3To view cmds you can use tcscmd cmdlist in the console", self );
		level com_printf( channel, "notitle", "^3To view players in the server do tcscmd playerlist in the console", self );
		level com_printf( channel, "notitle", "^3To view the usage of a specific cmd do tcscmd help <cmdalias>", self );
		if ( isDefined( level.tcs_additional_help_prints_func ) )
		{
			self [[ level.tcs_additional_help_prints_func ]]( channel );
		}
	}
	else 
	{
		valid_cmd_tokens = getDvar( "tcs_cmd_tokens" );
		if ( level.tcs_allow_hidden_cmds )
		{
			level com_printf( channel, "notitle", "^3Valid cmd tokens are / " + valid_cmd_tokens, self );
		}
		else 
		{
			level com_printf( channel, "notitle", "^3Valid cmd tokens are " + valid_cmd_tokens, self );
		}
		level com_printf( channel, "notitle", "^3To view cmds you can use cmdlist prefixed with the cmd token", self );
		level com_printf( channel, "notitle", "^3To view players in the server do playerlist prefixed with the cmd token", self );
		level com_printf( channel, "notitle", "^3To view the usage of a specific cmd do help <cmdalias> prefixed with the cmd token", self );
		if ( isDefined( level.tcs_additional_help_prints_func ) )
		{
			self [[ level.tcs_additional_help_prints_func ]]( channel );
		}
		self com_printinfo( "Use shift + ` and scroll to the bottom to view the full list" );
	}

	return result_cmdinfo( "" );
}

private cmd_dodamage_f( target_obj, args )
{
	result = [];
	target = args[ 0 ];
	damage = args[ 1 ];
	pos = args[ 2 ];
	attacker = args[ 3 ];
	inflictor = args[ 4 ];
	hitloc = args[ 5 ];
	mod = args[ 6 ];
	idflags = args[ 7 ];
	weapon = args[ 8 ];
	switch ( args.size )
	{
		case 3:
			target dodamage( damage, pos );
			break;
		case 4:
			target dodamage( damage, pos, attacker );
			break;
		case 5:
			target dodamage( damage, pos, attacker, inflictor );
			break;
		case 6:
			target dodamage( damage, pos, attacker, inflictor, hitloc );
			break;
		case 7:
			target dodamage( damage, pos, attacker, inflictor, hitloc, mod );
			break;
		case 8:
			target dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags );
			break;
		case 9:
			target dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags, weapon );
			break;
		default:
			return result_cmderror( "Wrong number of parameters sent to cmd dodamage max is 9 and min is 3" );
	}

	return result_cmdinfo( "Executed dodamage on target" );
}

private cmd_entitylist_f( target_obj, args )
{
	channel = self com_get_cmd_feedback_channel();
	entities = getEntArray();
	if ( entities.size <= 0 )
	{
		return result_cmderror( "There are no entities in the server" );
	}
	self thread list_entities_throttled( channel, args[ 0 ], entities );

	return result_cmdinfo( "" );
}

private cmd_teleportplayer_f( target_obj, args )
{
	target1 = args[ 0 ];
	target2 = args[ 1 ];
	if ( target1 == self && target2 == self )
	{
		return result_cmderror( "You cannot teleport to yourself" );
	}
	target1 setOrigin( target2.origin + anglesToForward( target2.angles ) * 64 + anglesToRight( target2.angles ) * 64 );

	return result_cmdinfo( "Successfully teleported " + target1.name + " to " + target2.name + "'s position" );
}

private cmd_scrnotify_f( target_obj, args )
{
	notify_ent_str = args[ 0 ];
	notify_name = args[ 1 ];

	arg_count = args.size - 2;

	notify_ent = undefined;
	if ( notify_ent_str == "level" )
	{
		notify_ent = level;
	}
	else if ( notify_ent_str == "self" )
	{
		notify_ent = self;
	}
	else
	{
		ent_find = self scripts\zm\cmd_system_modules\_cmd_arg::cast_str_to_entity( notify_ent_str );

		if ( ent_find.errored )
		{
			return result_cmderror( ent_find.msg );
		}

		notify_ent = ent_find.value;
	}

	switch ( arg_count )
	{
		case 0:
			notify_ent notify( notify_name );
			break;
		case 1:
			notify_ent notify( notify_name, args[ 2 ] );
			break;
		case 2:
			notify_ent notify( notify_name, args[ 2 ], args[ 3 ] );
			break;
		case 3:
			notify_ent notify( notify_name, args[ 2 ], args[ 3 ], args[ 4 ] );
			break;
		default:
			return result_cmderror( "Max arguments is 3!" );
	}

	return result_cmdinfo( "Successfully delivered notify " + notify_name );
}

private cmd_setdefaultcmdtarget_f( target_obj, args )
{
	
}

private cmd_togglehud_f( target_obj, args )
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

private cmd_god_f( target_obj, args )
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

private cmd_notarget_f( target_obj, args )
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

private cmd_invisible_f( target_obj, args )
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

private cmd_printorigin_f( target_obj, args )
{
	return result_cmdinfo( "Your origin is " + self.origin );
}

private cmd_printangles_f( target_obj, args )
{
	return result_cmdinfo( "Your angles are " + self.angles );
}

private cmd_bottomlessclip_f( target_obj, args )
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

private cmd_teleport_f( target_obj, args )
{
	target = args[ 0 ];
	if ( target == self )
	{
		return result_cmderror( "You cannot teleport to yourself" );
	}

	self setOrigin( target.origin + anglesToForward( target.angles ) * 64 + anglesToRight( target.angles ) * 64 );
	return result_cmdinfo( "Successfully teleported to " + target.name + "'s position" );
}

private cmd_cvar_f( target_obj, args )
{
	dvarname = args[ 0 ];
	dvarvalue = args[ 1 ];
	self setClientDvar( dvarname, dvarvalue );

	return result_cmdinfo( "Successfully set " + dvarname + " to " + dvarvalue );
}