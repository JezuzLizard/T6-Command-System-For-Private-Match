#include clientscripts\mp\_utility;

#include scripts\cmd\t6\cl\core\_cl_utility;
#include scripts\zm\cmd\modules\_cl_utility;

autoexec zm_debug_helpers()
{
	addcallback( "on_player_connect", ::zm_debug_connect );
}