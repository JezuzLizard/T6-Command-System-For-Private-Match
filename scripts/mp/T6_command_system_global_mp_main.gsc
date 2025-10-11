#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\mp\cmd\t6\sv\_mp_consts;
#include scripts\mp\cmd\t6\sv\mp_core_cmds;

main()
{
	init_mp_consts();
	init_core_helpers();

	waittillframeend;
	add_core_cmds();
}