# Kigen Anti Cheat Redux

Requires
- SourceMod 1.8
- Sockets 3.0.1 or newer

Optional:
- Sourcebans++
- Sourcebans
#
#
Commands | Description | Adminflag
------------ | ------------- | -------------
kacr_addcmd | Adds a Command to be blocked by KACR | ADMFLAG_ROOT
kacr_addignorecmd | Adds a Command to to ignore on Command spam | ADMFLAG_ROOT
kacr_removecmd | Removes a Command from the Block List | ADMFLAG_ROOT
kacr_removeignorecmd | Removes a Command to ignore | ADMFLAG_ROOT
kacr_addcvar | Adds a CVar to the check list | ADMFLAG_ROOT
kacr_removecvar | Removes a CVar from the check list | ADMFLAG_ROOT
#
Status Commands | Description | Adminflag
------------ | ------------- | -------------
kacr_status | Reports KACR's Status | ADMFLAG_GENERIC
kacr_net_status | Reports who has been checked | ADMFLAG_GENERIC
kacr_cvars_status | Shows the status of all in-game clients | ADMFLAG_GENERIC
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


I have just fixed a few things on the last Dev Version of KAC.
Ime still working on my own AC System, so dont exspect huge Changes here, i either will merge this Someday into my own AC or just do little Fixes.

SMAC and KAC are outdated, VAC dosent do its Job, NoCheatz-4 is discontinued and Community Projects are often small and pretty unstable.
I hope this Plugin will help some Server Owners.

Since i havent implemented an Updater yet (or renewed the old one), watch this Project on GitHub so you will be informed about Updates.

![How to watch](https://help.github.com/assets/images/help/notifications/watcher_picker.gif)
