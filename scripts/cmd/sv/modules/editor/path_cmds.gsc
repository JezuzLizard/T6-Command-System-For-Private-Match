#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\sv\core\_utility;
#include scripts\cmd\sv\core\_hud_utility;
#include scripts\cmd\sv\modules\editor\entity_helpers;

add_path_cmds()
{
	cmd_block_set_module_group( "pathnode_cmds" );
	cmd_block_set_rank_group( "cheat" );

	cmd_add( "spawncustompathnode", ::cmd_spawncustompathnode_f, "spawncustompathnode <id> [origin] [kvps...]" );
	arg_add_required( 1, "id", "string", "Pathnode identifier, must be unique" );
	arg_add_optional( 2, "origin", "vector", "Pathnode origin" );
	arg_add_optional( 3, "kvps", "...", "Key value pairs to define on pathnode entity" );

	cmd_add( "modifycustompathnode", ::cmd_modifycustompathnode_f, "modifycustompathnode <id> [kvps...]" );
	arg_add_required( 1, "id", "string", "Pathnode identifier, must be unique" );
	arg_add_optional( 2, "origin", "vector", "Pathnode origin" );
	arg_add_optional( 3, "kvps", "...", "Key value pairs to define on pathnode entity" );
	// save
	// load
	// draw
	// select
	// modify
	// delete
}

private cmd_spawncustompathnode_f( param )
{
	id = param.a[ 0 ];
	origin = _DEFAULT( param.a[ 1 ], self.origin );
	kvps = param.a;
	if ( array_validate( kvps ) && ( ( kvps.size - 1 ) % 2 ) != 0 )
	{
		return param add_executor_cmderror( "You must input an even number of key value pairs" );
	}

	keys = [];
	keys[ "origin" ] = origin;

	// push past origin argument
	for ( i = 1; i < _SIZE( param.a ); i += 2 )
	{
		keys[ param.a[ i ] ] = param.a[ i + 1 ];
	}

	node = generate_pathnode_for_mapents( keys );
	param add_executor_cmdinfo( "Spawned pathnode at origin: '{}'", origin );
}

private cmd_modifycustompathnode_f( param )
{

}