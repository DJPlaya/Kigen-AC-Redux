# Kigen Anti Cheat Redux

Requires:
- SourceMod 1.8 (Project Target: 1.10)
- Sockets 3.0.1 or newer

Optional:
- Sourcebans++
- Sourcebans

Official supported Games:
- Counter-Strike: Global Offensive
- Team Fortress 2
- Counter-Strike: Source
- Left 4 Dead 1/2
- Insurgency
- Day of Defeat: Source
- Half-Life 2: Deathmatch
  #### Most Elements of KACR will work on any Half Life Engine Game
#
#
Commands | Description | Adminflag
------------ | ------------- | -------------
kacr_addcmd | Adds a Command to be blocked by KACR | Root
kacr_addignorecmd | Adds a Command to to ignore on Command spam | Root
kacr_removecmd | Removes a Command from the Block List | Root
kacr_removeignorecmd | Removes a Command to ignore | Root
kacr_addcvar | Adds a CVar to the check list | Root
kacr_removecvar | Removes a CVar from the check list | Root
#
Status Commands | Description | Adminflag
------------ | ------------- | -------------
kacr_status | Reports KACR's Status | Generic
kacr_net_status | Reports who has been checked | Generic
kacr_cvars_status | Shows the status of all in-game clients | Generic
#
#
Note: A Config File will be automatically created

ConVar | Possible Value | Description
------------ | ------------- | -------------
kacr_version | Dont | KACR Plugin Version (do not touch)
kacr_client_enable | 1/0 | Enable the Client Protection Module
kacr_client_antirejoin | 1/0 | (CSS/CSGO only) This will prevent people from leaving the game then rejoining to respawn
kacr_client_nameprotect | 1/0 | This will protect the Server from name Crashes and Hacks
kacr_client_antispamconnect | 0-120 | Seconds to prevent someone from restablishing a Connection. 0 to disable
kacr_net_enable | 1/0 | Enable the Network Module
kacr_cvars_enable | 1/0 | Enable the CVar checking Module
kacr_rcon_crashprevent | 1/0 | Enable RCON Crash Prevention
kacr_eyes_enable | 1/0 | Enable the Eye Test detection Routine
kacr_eyes_antiwall | 1/0 | Enable Anti-Wallhack
kacr_cmds_enable | 1/0 | If the Commands Module of KACR is enabled
kacr_cmds_spam | 0-120 | Amount of Commands in one Second before Kick. 0 to disable
kacr_cmds_log | 1/0 | Log Command Usage. Use only for debugging Purposes


SMAC and KAC are outdated, VAC dosent do its Job, NoCheatz-4 is discontinued and Community Projects are often small and pretty unstable.
I hope this Plugin will help some Server Owners even doe its still in Alpha Stage.
Ime still working on my own AC System, so dont exspect massive Changes here. Still i will propapbly merge this Someday into my own Cheat Acid.
Since i havent implemented an Updater yet (or renewed the old one), watch this Project on GitHub so you will be informed about Updates.

![How to watch](https://help.github.com/assets/images/help/notifications/watcher_picker.gif)
