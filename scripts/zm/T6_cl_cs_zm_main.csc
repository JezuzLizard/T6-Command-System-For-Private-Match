#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;

#include scripts\zm\cmd\t6\cl\_cl_zm_consts;
#include scripts\zm\cmd\t6\cl\cl_zm_debug_cmds;
#include scripts\zm\cmd\t6\cl\cl_zm_debug_helpers;

main()
{
	waittillframeend;
	init_cl_consts();
	init_zm_debug_helpers();
	add_cl_zm_debug_cmds();
}