#include clientscripts\mp\_utility;

#include scripts\cmd\t6\cl\core\_cl_utility;

// autoexec
#include scripts\zm\cmd\modules\_cl_zm_consts;
#include scripts\zm\cmd\modules\cl_zm_debug_helpers;

#include scripts\zm\cmd\modules\_cl_utility;

autoexec add_cl_zm_debug_cmds()
{
	setzombiesanimrate_cmd = cmd_add( "setzombiesanimrate", ::cmd_setzombiesanimrate_f, "setzombiesanimrate <value>" );
	setzombiesanimrate_cmd arg_add_required( 1, "animrate", "float", "Animrate to synchronize with the server to" );
}

private cmd_setzombiesanimrate_f( param )
{
	animrate = param.a[ 0 ];


}