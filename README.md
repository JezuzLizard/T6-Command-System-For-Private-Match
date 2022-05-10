# T6-Command-System-For-Private-Match
Private match only version of the T6-Command-System repo. Doesn't require the T6-GSC-utils plugin but has fewer features.

## Command List

Commands are not case sensitive. Commands can entered into chat preceding with the "/" key, or if you are host you can set the dvar "tcscmd" with the value of a command.
You can create binds by doing ```bind p "say /god"``` so when you press p the god command is executed. You can execute multiple commands at once by separating them with commas like so ```/god,notarget,togglehud,cvar aim_automelee_range 0```. I don't know what the limit for chat messages is but the limit for dvars is 1024 characters.

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
