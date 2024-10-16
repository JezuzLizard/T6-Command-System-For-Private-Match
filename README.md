# T6-Command-System-For-Private-Match
Private match only version of the T6-Command-System repo. Doesn't require the T6-GSC-utils plugin but has fewer features.

## Command List

Commands are not case sensitive. Commands can entered into chat preceding with the "/" key, or if you are host you can set the dvar "tcscmd" with the value of a command.
You can create binds by doing ```bind p "say /god"``` so when you press p the god command is executed. You can execute multiple commands at once by separating them with commas like so ```/god,notarget,togglehud,cvar aim_automelee_range 0```. I don't know what the limit for chat messages is but the limit for dvars is 1024 characters. if the usage includes ... this indicates the command can accept var args. Which means you can send more args for it to process so for example: ```/giveweapon <name|guid|clientnum|self> <weapon> ...``` the var args allows you define multiple weapons to give to the player.

### MP/ZM

Server Commands:
These are commands that can be used on any player so are more powerful than client commands.
```
/setcvar <name|guid|clientnum|self> <cvarname> <newval> //Sets a player's clientdvar <cvarname> to <newval>
/dvar <dvarname> <newval> //Sets a server dvar <dvarname> to <newval>
/cvarall <cvarname> <newval> //Sets all player's clientdvar <cvarname> to <newval>
/givegod <name|guid|clientnum|self> //Gives god to a player
/givenotarget <name|guid|clientnum|self> //Gives notarget to a player
/giveinvisible <name|guid|clientnum|self> //Gives invisibility to a player
/setrank <name|guid|clientnum|self> <rank> //Sets a player's rank valid options are "none", "user", "trusted", "elevated", "moderator", "cheat", and "host"
//Most commands require "cheat" rank or higher to be used
/execonallplayers <cmdname> [cmdargs] ... //Executes a client command on all players. Can take var args.
/execonteam <team> <cmdname> [cmdargs] ... //Executes a client command on all players on <team>
```
Client Commands:
These can only be executed on yourself.
```
/togglehud //Toggles your hud
/god //Toggles on/off godmode for yourself
/notarget //Toggles on/off notarget for yourself
/invisible //Toggles on/off invisibility for yourself
/printorigin //Prints your current origin
/printangles //Prints your current angles
/bottomlessclip //Activates bottomless clip for yourself
/cvar <cvarname> <newval> //Sets <cvarname> clientdvar to <newval>
```

### ZM

Server Commands:
```
/spectator <name|guid|clientnum|self> //Forces player into a spectator state
/togglerespawn <name|guid|clientnum|self> //Toggles whether a player will respawn at the end of a round
/killactors //Kills all alive zombies
/respawnspectators //Respawns spectators
/pause [minutes] //Disables the zombies and gives godmode to all players
/unpause //Enables the zombies and disables godmode for all players
/giveperk <name|guid|clientnum|self> <perkname> ... //Gives perk(s) to player
/givepermaperk <name|guid|clientnum|self> <perkname> ... //Gives permaperk(s) to player
/givepoints <name|guid|clientnum|self> <amount> //Gives points to player
/giveweapon <name|guid|clientnum|self> <weapon> ... //Gives weapon(s) to player functions like the normal give command
/toggleperssystemforplayer <name|guid|clientnum|self> //Disables the persistent uprade system for player they will no longer gain or lose perma perks
```

Client Commands:
```
/perk <perkname> ... //Gives perk(s) to yourself
/permaperk <perkname> ... //Gives permaperk(s) to yourself
/points <amount> //Gives points to yourself
/weapon <weaponname> ... //Gives weapon(s) to yourself
/toggleperssystem //Toggles the persistent upgrades system for yourself
```
## Permissions
Permissions start with the host who always has full permissions and access to all features. The host can set a player's rank with the ```setrank``` command.
This player entry is saved in a dvar which shouldn't reset in future matches allowing players to keep their ranks while your game is open.

# Command Api
This mod is designed to allow easily adding new commands or even removing previously added commands

## Adding Custom Commands
If you want to add your own commands you do not need to recompile the source, instead you can create a new custom script in scripts\mp or scripts\zm or scripts\ for both. In this custom script paste the following code into it:
```
main()
{
	while ( !is_true( level.command_init_done ) )
	{
		wait 0.05;
	}
}
```

Now you can register your custom commands now that the command system is initialized using CMD_ADDSERVERCOMMAND( cmdname, aliases, usage, func, cmdpower );
or CMD_ADDCLIENTCOMMAND( cmdname, aliases, usage, func, cmdpower ); for a client command.
```
cmdmane - unique string used to determine what function to execute in the system

aliases - a string split with spaces. The user types one of these in the chat to execute the command.

usage - for cmdlist to list the usage for the command. Example "giveweapon <name|guid|clientnum|self> <weapon> ..." wherre "<>" indicates a required arg, and "[]" indicates an optional arg, and ... indicates var args are allowed.

func - The function to execute.

cmdpower - The required amount of cmdpower the user must have to execute the command. Client and server commands use separate cmdpower values.
```

When writing a function for the command system to execute all it requires is to return the result.
The result is the message and outcome of the command function. 
Example in scripts\cmd_system_modules\global_client_commands.gsc
```
cmd_god_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_is_invulnerable ), "on off" );
	if ( on_off == "on" )
	{
		self enableInvulnerability();
		self.tcs_is_invulnerable = true;
	}
	else 
	{
		self disableInvulnerability();
		self.tcs_is_invulnerable = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "God " + on_off;
	return result;
}
```
The result is an array of up to 3 different keys but only 2 are required. "filter" is the way the system determines if the command errored. if "filter" is "cmderror" it has a different color. "message" is the message to tell the CMD_EXECUTE() function to print when the command is executed. "channels" can be optionally defined if the coder wants to explicitly tell CMD_EXECUTE() to print to specific channels like "con".

## Removing commands
If you want to remove a command simply call CMD_REMOVESERVERCOMMAND( cmdname ); or CMD_REMOVECLIENTCOMMAND( cmdname ); if its a client command after the command system is initialized.
