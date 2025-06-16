#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_cmd_util;
#include scripts\mp\cmd_system_modules_mp\_cmd_util_mp;

#include maps\mp\killstreaks\_dogs;

main()
{
	while ( !is_true( level.cmd_init_done ) )
	{
		wait 0.05;
	}

	cmd_block_set_rank_group( "cheat" );
	sicdogsonplayer_cmd = cmd_add( "sicdogsonplayer", ::cmd_sicdogsonplayer_f, "sicdogsonplayer {player} [count] [invisible]" );
	sicdogsonplayer_cmd arg_obj_add_cmd( "wholenum wholenum", 0, 2 );
	givenotarget_cmd target_obj_add_cmd( "player" );

	removedogs_cmd = cmd_add( "removedogs", ::cmd_removedogs_f );

	arg_obj_register( "weapon", ::arg_obj_weapon_validate, ::arg_obj_weapon_generate, undefined, "not a valid weapon" );

	level thread on_unittest();

	level thread on_player_connect();
	level.cmd_init_mp_done = true;
}

on_unittest()
{
	level endon( "game_ended" );
	while ( true )
	{
		level waittill( "unittest_start" );
		registerscorelimit( 0, 0 );
		registertimelimit( 0, 0 );
		registernumlives( 9999, 9999 );
	}
}

init()
{
	build_weapons_array();
}

on_player_connect()
{
	level endon( "game_ended" );
	while ( true )
	{
		level waittill( "connected", player );
		if ( is_true( level.doing_command_system_unittest ) && is_true( player.pers[ "isBot" ] ) )
		{
			player thread wait_spawn_bot_think();
		}
	}
}

wait_spawn_bot_think()
{
	wait 5;
	self thread maps\mp\bots\_bot::bot_spawn_think( random( level.teams ) );
}

cmd_sicdogsonplayer_f( target_obj, args )
{
	target = args[ 0 ];
	count = args[ 1 ];
	invisible = args[ 2 ];

	other_team = getOtherTeam( target.team );

	if ( !isDefined( count ) )
	{
		count = 1;
	}

	if ( ( getFreeActorCount() - count ) < 0 )
	{
		return result_cmderror( "Cannot spawn more than 32 dogs at once" );
	}
	for ( i = 0; i < count; i++ )
	{
		dog_manager_spawn_dog( target, other_team, invisible );
	}
	self com_printinfo( "Spawned in " + count + " dogs to hunt " + target.name );
	self com_printinfo( "Use cmd removedogs to remove the dogs spawned with this cmd" );
}

cmd_removedogs_f( target_obj, args )
{
	level notify( "remove_dogs" );

	return result_cmdinfo( "Removed all cmd spawned dogs" );
}

wait_for_removal()
{
	level waittill( "remove_dogs" );
	self dog_leave();
}

init_dog()
{
	assert( isai( self ) );
	self.targetname = "attack_dog";
	self.animtree = "dog.atr";
	self.type = "dog";
	self.accuracy = 0.2;
	self.health = 99999999;
	self.maxhealth = 99999999;
	self.aiweapon = "dog_bite_mp";
	self.secondaryweapon = "";
	self.sidearm = "";
	self.grenadeammo = 0;
	self.goalradius = 128;
	self.nododgemove = 1;
	self.ignoresuppression = 1;
	self.suppressionthreshold = 1;
	self.disablearrivals = 0;
	self.pathenemyfightdist = 512;
	self.soundmod = "dog";
	self.ignoreall = true;
}

find_target()
{
	level endon( "game_ended" );

	while ( true )
	{
		if ( !isDefined( self.target_player ) )
		{
			self dog_leave();
			break;
		}
		if ( self.aiteam == self.target_player.team )
		{
			self.aiteam = getOtherTeam( self.aiteam );
		}
		if ( !isDefined( self.enemy ) )
		{
			self SetEntityTarget( self.target_player, 1.0 );
		}
		wait 1;
	}
}

dog_set_model()
{
	self setmodel( "german_shepherd_vest" );
	self setenemymodel( "german_shepherd_vest_black" );
}

dog_manager_spawn_dog( target, team, invisible )
{
	dog_spawner = getent( "dog_spawner", "targetname" );
	dog = dog_spawner spawnactor();
	spawn_node = get_spawn_node( level, level );
	dog forceteleport( spawn_node.origin, spawn_node.angles );
	dog init_dog();
	dog dog_set_model();
	dog thread wait_for_removal();
	if ( is_true( invisible ) )
	{
		dog hide();
		dog stopsounds();
	}
	dog.target_player = target;
	dog thread find_target();
	dog.aiteam = team;
	return dog;
}