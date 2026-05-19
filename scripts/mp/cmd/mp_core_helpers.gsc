#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

#include maps\mp\killstreaks\_dogs;

init_core_helpers()
{
	build_weapons_array();
	level thread on_unittest();
	addcallback( "on_player_connect", ::wait_spawn_bot_think );
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

wait_spawn_bot_think()
{
	wait 5;
	self thread bot_spawn_think( random( level.teams ) );
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

build_weapons_array()
{
	const INTERNAL_NAME_COLUMN = 4;
	const END_OF_WEAPONS_ROWS = 85;
	level.tcs_weapons = [];
	i = 0;
	while ( i < END_OF_WEAPONS_ROWS )
	{
		row = tableLookupRowNum( "statstable.csv", 0, i );
		if ( row < 0 )
		{
			break;
		}
		weapon = tableLookupColumnForRow( "statstable.csv", row, INTERNAL_NAME_COLUMN );
		if ( weapon == "weapon_null" || weapon == "" )
		{
			i++;
			continue;
		}
		level.tcs_weapons[ weapon + "_mp" ] = true;
		i++;
	}
}