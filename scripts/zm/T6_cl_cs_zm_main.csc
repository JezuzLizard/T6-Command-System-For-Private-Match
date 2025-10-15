#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;

#include scripts\zm\cmd\cl\_cl_zm_consts;
#include scripts\zm\cmd\cl\cl_zm_debug_cmds;
#include scripts\zm\cmd\cl\cl_zm_debug_helpers;

main()
{
	init_cl_consts();
	init_zm_debug_helpers();
	add_cl_zm_debug_cmds();
}