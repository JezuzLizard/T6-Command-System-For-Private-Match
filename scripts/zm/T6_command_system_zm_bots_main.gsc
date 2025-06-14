#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weapons;

#include scripts\cmd_system_modules\_cmd_util;
#include scripts\cmd_system_modules\_com;
#include scripts\cmd_system_modules\_perms;
#include scripts\zm\cmd_system_modules_zm\_overrides;
#include scripts\zm\cmd_system_modules_zm\_zm_cmd_util;

#include maps\mp\bots\_bot_api;

main()
{
	while ( !is_true( level.command_init_done ) )
	{
		wait 0.05;
	}

	cmd_add( "setscriptgoal", true, "ssg", "scriptgoal <bot> [goal|entity] [dist]", ::cmd_setscriptgoal_f, "cheat", 1, false );
	arg_obj_add_cmd( "setscriptgoal", "bot" );
	cmd_add( "clearscriptgoal", true, "csg", "clearscriptgoal <bot>", ::cmd_clearscriptgoal_f, "cheat", 1, false );
	arg_obj_add_cmd( "clearscriptgoal", "bot" );
	cmd_add( "hasscriptgoal", true, "hsg", "hasscriptgoal <bot>", ::cmd_hasscriptgoal_f, "cheat", 1, false );
	arg_obj_add_cmd( "hasscriptgoal", "bot" );

	level thread check_for_command_alias_collisions();
}

cmd_setscriptgoal_f( args )
{
	result = [];
	bot = args[ 0 ];
	goal = args[ 1 ];
	player = self;
	dist = isdefined( args[ 2 ] ) ? arg_cast_to_float( args[ 2 ] ) : 16;

	if ( !isdefined( goal ) )
	{
		direction = player getplayerangles();
		direction_vec = anglestoforward( direction );
		eye = player geteye();
		scale = 8000;
		direction_vec = ( direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale );
		trace = bullettrace( eye, eye + direction_vec, 0, undefined );
		direction_vec = player.origin - trace["position"];
		direction = vectortoangles( direction_vec );

		goal = trace[ "position" ];

		bot SetScriptGoalPos( goal, dist );
	}
	else
	{
		is_vector_goal = arg_vector_handler( args[ 1 ] );
		if ( !is_vector_goal )
		{
			ent = arg_cast_to_entity( args[ 1 ] );
			if ( !isdefined( ent ) )
			{
				return result_cmderror( "Invalid entity for bot goal" );
			}
			else
			{
				bot SetScriptGoalEnt( ent, dist );
				goal = ent.origin;
			}
		}
		else
		{
			goal = cast_str_to_vector( args[ 1 ] );
			bot SetScriptGoalPos( goal, dist );
		}
	}

	return result_cmdinfo( "Set " + bot.name + " goal to " + goal );
}

cmd_clearscriptgoal_f( args )
{
	bot ClearScriptGoal();
	return result_cmdinfo( "Cleared " + bot.name + " goal" );
}

cmd_hasscriptgoal_f( args )
{
	bot ClearScriptGoal();
	return result_cmdinfo( "Bot " + bot.name + " has goal: " + cast_bool_to_str( bot HasScriptGoal(), "yes no" ) );
}