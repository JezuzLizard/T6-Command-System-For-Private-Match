#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\mp\cmd\t6\sv\_mp_consts;
#include scripts\mp\cmd\t6\sv\mp_core_cmds;

main()
{
	level thread init_mp_consts();
	level thread init_core_helpers();
	level thread add_core_cmds();
}