#include clientscripts\mp\_utility;

#include scripts\cmd\cl\core\_cl_utility;

#include scripts\zm\cmd\cl\_cl_zm_consts;
#include scripts\zm\cmd\cl\cl_zm_debug_helpers;

#include scripts\zm\cmd\cl\_cl_zm_utility;

add_cl_zm_debug_cmds()
{
	cmd_block_set_module_group( "debug_zm" );
	cmd_block_set_rank_group( "cheat" );
	setzombiesanimrate_cmd = cmd_add( "setzombiesanimrate", ::cmd_setzombiesanimrate_f, "setzombiesanimrate <value>" );
	setzombiesanimrate_cmd arg_add_required( 1, "animrate", "float", "Animrate to synchronize with the server to" );
}

private cmd_setzombiesanimrate_f( param )
{
	animrate = param.a[ 0 ];


}