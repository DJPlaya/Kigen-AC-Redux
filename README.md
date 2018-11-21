# Kigen Anti Cheat Redux
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d02e2cc3856043a1a2b8277834f54bd5)](https://app.codacy.com/app/DJPlaya/kigen-ac-pub?utm_source=github.com&utm_medium=referral&utm_content=DJPlaya/kigen-ac-pub&utm_campaign=Badge_Grade_Dashboard)

|-Requires
 |Sockets 3.0.1+
 
 |-Optional
  |Sourcebans
  |Sourcebans++


|-Commands
 |kac_addcmd // Adds a Command to be blocked by KAC (ADMFLAG_ROOT)
 |kac_addignorecmd // Adds a Command to to ignore on Command spam (ADMFLAG_ROOT)
 |kac_removecmd // Removes a Command from the Block List (ADMFLAG_ROOT)
 |kac_removeignorecmd // Removes a Command to ignore (ADMFLAG_ROOT)
 |kac_addcvar // Adds a CVar to the check list (ADMFLAG_ROOT)
 |kac_removecvar // Removes a CVar from the check list (ADMFLAG_ROOT)
 
-|Status Commands
 |kac_status // Reports KAC's Status (ADMFLAG_GENERIC)
 |sm_kac_status // Reports KAC's Status (ADMFLAG_GENERIC)
 |kac_net_status // Reports who has been checked (ADMFLAG_GENERIC)
 |kac_cvars_status // Shows the status of all in-game clients (ADMFLAG_GENERIC)


|-CVars
-|Note: A config File will be automatically created
 |kac_version // KAC Plugin Version (do not touch)
 |kac_client_enable 1/0 // Enable the Client Protection Module
 |kac_client_antirejoin 1/0 // (CSS/CSGO only) This will prevent people from leaving the game then rejoining to respawn
 |kac_client_nameprotect 1/0 // This will protect the Server from name Crashes and Hacks
 |kac_client_antispamconnect 0-60 // Seconds to prevent someone from restablishing a Connection. 0 to disable
 |kac_net_enable 1/0 // Enable the Network Module
 |kac_cvars_enable 1/0 // Enable the CVar checking Module
 |kac_rcon_crashprevent 1/0 // Enable RCON Crash Prevention
 |kac_eyes_enable 1/0 // Enable the Eye Test detection Routine
 |kac_eyes_antiwall 1/0 // Enable Anti-Wallhack
 |kac_cmds_enable 1/0 // If the Commands Module of KAC is enabled
 |kac_cmds_spam 0-120 // Amount of Commands in one Second before Kick. 0 to disable
 |kac_cmds_log 1/0 // Log Command Usage. Use only for debugging Purposes


I have just fixed a few things on the last Dev Version of KAC.
Ime still working on my own AC System, so dont exspect huge Changes here, i either will merge this Someday into my own AC or just do little Fixes.

SMAC and KAC are outdated, VAC dosent do its Job, NoCheatz-4 is discontinued and Community Projects are often small and pretty unstable.
I hope this Plugin will help some Server Owners.

Since i havent implemented an Updater yet (or renewed the old one), watch this Project on GitHub so you will be informed about Updates.
> https://help.github.com/assets/images/help/notifications/watcher_picker.gif
