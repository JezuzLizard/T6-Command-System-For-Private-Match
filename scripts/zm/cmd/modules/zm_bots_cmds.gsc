#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weapons;

#include scripts\cmd\core\_utility;

#include maps\mp\bots\_bot_api;

autoexec add_cmds()
{
	waittillframeend;
	cmd_block_set_module_group( "core_common" );
	cmd_block_set_rank_group( "cheat" );
	setscriptgoal = cmd_add( "setscriptgoal", "scriptgoal {<bot>} <goal|entity> [dist]", ::cmd_setscriptgoal_f );
	setscriptgoal arg_add_required( 1, "goal", "goal", "Goal to force the bot to go to" );
	setscriptgoal arg_add_required( 2, "dist", "positive_float", "Distance from <goal> until bot considers goal reached" );
	setscriptgoal target_add_required( 1, "bot", "bot", "Bot to set goal for" );

	clearscriptgoal = cmd_add( "clearscriptgoal", "clearscriptgoal {<bot>}", ::cmd_clearscriptgoal_f );
	setscriptgoal target_add_required( 1, "bot", "bot", "Bot to clear goal for" );

	hasscriptgoal = cmd_add( "hasscriptgoal", "hasscriptgoal {<bot>}", ::cmd_hasscriptgoal_f );
	hasscriptgoal target_add_required( 1, "bot", "bot", "Bot to print goal for" );
}

private cmd_setscriptgoal_f( param )
{
	result = [];
	bot = param.t[ 0 ][ 0 ];
	goal = param.a[ 0 ];
	player = self;
	dist = _DEFAULT( param.a[ 1 ], 16 );

	if ( !isdefined( goal ) )
	{
		direction = player getplayerangles();
		direction_vec = anglestoforward( direction );
		eye = player geteye();
		scale = 8000;
		direction_vec = ( direction_vec[ 0 ] * scale, direction_vec[ 1 ] * scale, direction_vec[ 2 ] * scale );
		trace = bullettrace( eye, eye + direction_vec, 0, undefined );
		direction_vec = player.origin - trace[ "position" ];
		direction = vectortoangles( direction_vec );

		goal = trace[ "position" ];

		bot setscriptgoalpos( goal, dist );
	}
	else
	{
		is_vector_goal = arg_vector_validate( goal );
		if ( !is_vector_goal )
		{
			ent = arg_obj_entity_cast( goal );
			if ( !isdefined( ent ) )
			{
				return param add_executor_cmderror( "Invalid entity for bot goal" );
			}
			else
			{
				bot SetScriptGoalEnt( ent, dist );
				goal = ent.origin;
			}
		}
		else
		{
			goal = cast_str_to_vector( goal );
			bot SetScriptGoalPos( goal, dist );
		}
	}

	param add_executor_cmdinfo( "Set " + bot.name + " goal to " + goal );
}

private cmd_clearscriptgoal_f( param )
{
	bot = param.t[ 0 ][ 0 ];
	bot ClearScriptGoal();
	param add_executor_cmdinfo( "Cleared " + bot.name + " goal" );
}

private cmd_hasscriptgoal_f( param )
{
	bot = param.t[ 0 ][ 0 ];
	bot ClearScriptGoal();
	param add_executor_cmdinfo( "Bot " + bot.name + " has goal: " + cast_bool_to_str( bot HasScriptGoal(), "yes no" ) );
}