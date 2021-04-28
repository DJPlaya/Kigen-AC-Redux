// Copyright (C) 2007-2011 CodingDirect LLC
// This File is licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details
// All Changes to the original Code are licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details


//- Compiler Settings -//

#pragma newdecls optional
#pragma dynamic 655360 // 2560kb // 29.5.20 - 1780996(1.8)-1827984(1.10) bytes required - I know this MUCH for a Plugin, but do mind that this is nothing compared to only 1 GB of Memory!

#define DEBUG // Debugging for nightly Builds TODO


//- Includes -//

#include <sdktools>
#undef REQUIRE_EXTENSIONS 
#include <sdkhooks>
#define REQUIRE_EXTENSIONS
#include <smlib_kacr> // Copyright (C) SMLIB Contributors // This Include is licensed under GPLv3, see 'Licenses/License_SMLIB.txt' for Details
#include <autoexecconfig_kacr> // Copyright (C) 2013-2017 Impact // This Include is licensed under GPLv3, see 'Licenses/License_AutoExecConfig.txt' for Details
#include <kvizzle> // No Copyright Information found, developed by F2 > https://forums.alliedmods.net/member.php?u=48818
#undef REQUIRE_PLUGIN
#include <updater_kacr> // No Copyright Information found, developed by God-Tony > https://forums.alliedmods.net/member.php?u=6136
#include <materialadmin> // Copyright (C) SB-MaterialAdmin Contributors // This Include is licensed under GPLv3, see 'Licenses/GPLv3.txt' for Details
#include <ASteambot> // Copyright (C) ASteamBot Contributors // This Include is licensed under The MIT License, see 'Licenses/License_ASteambot.txt' for Details
#include <sourceirc> // Copyright (C) Azelphur and SourceIRC Contributers // This Include is licensed under GPLv3, see 'Licenses/License_SourceIRC.txt' for Details
#define REQUIRE_PLUGIN


//- Natives -//

// SourceBans++
native void SBPP_BanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason);
native void SBPP_ReportPlayer(int iReporter, int iTarget, const char[] sReason);

// Sourcebans 2.X
native void SBBanPlayer(client, target, time, char[] reason);
native void SB_ReportPlayer(int client, int target, const char[] reason);

native int AddTargetsToMenu2(Handle menu, int source_client, int flags); // TODO: Normally this dosent need to be done, but ive got some strange BUG with this #ref 273812


//- Defines -//

#define loop for(;;) // Unlimited Loop

#define PLUGIN_VERSION "1.0.0" // The Versioning is important for the Updater, it needs to be changed on every Release: TODO: Update the Compiler File todo this automatically
#define MAX_ENTITIES 2048 // Maximum networkable Entitys (Edicts), 2048 is hardcoded in the Engine

// Version
#if !defined DEBUG && SOURCEMOD_V_MAJOR == 1
 #if SOURCEMOD_V_MINOR >= 10 // 1.10
  #define UPDATE_URL "http://github.com/DJPlaya/Kigen-AC-Redux/tree/master/updatefile.1.10.txt"
 
 #elseif SOURCEMOD_V_MINOR >= 8 // 1.8 and 1.9
  #define UPDATE_URL "http://github.com/DJPlaya/Kigen-AC-Redux/tree/master/updatefile.1.8.txt"
  
 #else
  #define UPDATE_URL NULL_STRING
  
 #endif
#endif

// Action Defines
#define KACR_Action_Count 13 // 18.11.19 - 12+1 carryed

#define KACR_ActionID_Ban 1
#define KACR_ActionID_TimeBan 2
#define KACR_ActionID_ServerBan 3
#define KACR_ActionID_ServerTimeBan 4
#define KACR_ActionID_Kick 5
#define KACR_ActionID_Crash 6
#define KACR_ActionID_ReportSB 7
#define KACR_ActionID_ReportAdmins 8
#define KACR_ActionID_ReportSteamAdmins 9
#define KACR_ActionID_AskSteamAdmin 10
#define KACR_ActionID_Log 11
#define KACR_ActionID_ReportIRC 12

#define KACR_Action_Ban 1
#define KACR_Action_TimeBan 2
#define KACR_Action_ServerBan 4
#define KACR_Action_ServerTimeBan 8
#define KACR_Action_Kick 16
#define KACR_Action_Crash 32
#define KACR_Action_ReportSB 64
#define KACR_Action_ReportAdmins 128
#define KACR_Action_ReportSteamAdmins 256
#define KACR_Action_AskSteamAdmin 512
#define KACR_Action_Log 1024
#define KACR_Action_ReportIRC 2048


//- Global Variables -//

Handle g_hValidateTimer[MAXPLAYERS + 1];
Handle g_hClearTimer, g_hCVar_Version, g_hCVar_PauseReports;
EngineVersion g_hGame;
StringMap g_hCLang[MAXPLAYERS + 1];
StringMap g_hSLang, g_hDenyArray;

int g_iLastCheatReported[MAXPLAYERS + 1] = -3600; // This is for per Frame/Timed AC Checks, we do not want to spam the Log nor the Admins with Reports, so we save the last Time Someone was reported. We do set this to -3600 (1h), so the Time Check works properly even if the Server just has started #ref 395723
int g_iPauseReports; // Wait this long till we report/log a Client again

// Its more Resource efficient to store the data instead of grabbing it over and over again
bool g_bConnected[MAXPLAYERS + 1], g_bAuthorized[MAXPLAYERS + 1], g_bInGame[MAXPLAYERS + 1], g_bIsAdmin[MAXPLAYERS + 1], g_bIsFake[MAXPLAYERS + 1];
bool g_bSourceBansPP, g_bSBMaterialAdmin, g_bSourceBans, g_bASteambot, g_bSourceIRC, g_bMapStarted;

public Plugin myinfo = 
{
	name = "Kigen's Anti-Cheat Redux", 
	author = "Playa (Formerly Max Krivanek)", 
	description = "An Universal Anti Cheat Solution compatible with most Source Engine Games", 
	version = PLUGIN_VERSION, 
	url = "github.com/DJPlaya/Kigen-AC-Redux"
};


//- KACR Modules -// Note that the ordering of these Includes is important

#include "kigen-ac_redux/translations.sp"	// Translations Module - NEEDED FIRST
#include "kigen-ac_redux/client.sp"			// Client Module
#include "kigen-ac_redux/commands.sp"		// Commands Module
#include "kigen-ac_redux/cvars.sp"			// CVar Module
#include "kigen-ac_redux/eyetest.sp"		// Eye Test Module
#include "kigen-ac_redux/rcon.sp"			// RCON Module
#include "kigen-ac_redux/security.sp"		// Server Security Module
#include "kigen-ac_redux/status.sp"			// Status Module
#include "kigen-ac_redux/stocks.sp"			// Stocks Module


//- Plugin, Native Config Functions -//

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] cError, iMaxSize)
{
	//- SDKHooks -//
	MarkNativeAsOptional("SDKHook");
	MarkNativeAsOptional("SDKUnhook");
	//- Updater -//
	MarkNativeAsOptional("Updater_AddPlugin");
	//- Sourcebans++ -//
	MarkNativeAsOptional("SBPP_BanPlayer");
	MarkNativeAsOptional("SBPP_ReportPlayer");
	//- SB Material Admin -// TODO BUG should be done in the include, or?
	//MarkNativeAsOptional("MAOffBanPlayer");
	//MarkNativeAsOptional("MABanPlayer");
	//MarkNativeAsOptional("MALog");
	//- Sourcebans 2.X -//
	MarkNativeAsOptional("SBBanPlayer");
	MarkNativeAsOptional("SB_ReportPlayer");
	//- ASteambot -//
	MarkNativeAsOptional("ASteambot_RegisterModule");
	MarkNativeAsOptional("ASteambot_RemoveModule");
	MarkNativeAsOptional("ASteambot_SendMessage");
	MarkNativeAsOptional("ASteambot_IsConnected");
	//- SourceIRC -//
	MarkNativeAsOptional("IRC_MsgFlaggedChannels"); // Other Natives are marked as optional in the Include
	//- Adminmenu -// TODO: Normally this dosent need to be done, but ive got some strange BUG with this #ref 273812
	MarkNativeAsOptional("AddTargetsToMenu2");
}

public void OnPluginStart()
{
	g_hDenyArray = new StringMap();
	g_hGame = GetEngineVersion(); // Identify the game
	
	AutoExecConfig_SetFile("Kigen-AC_Redux"); // Set which file to write Cvars to
	
	//- Module Calls -//
	Status_OnPluginStart();
	Security_OnPluginStart();
	Client_OnPluginStart();
	Commands_OnPluginStart();
	CVars_OnPluginStart();
	Eyetest_OnPluginStart();
	RCON_OnPluginStart();
	Trans_OnPluginStart();
	
	//- Get server language -//
	char f_sLang[8];
	GetLanguageInfo(GetServerLanguage(), f_sLang, sizeof(f_sLang));
	if (!g_hLanguages.GetValue(f_sLang, g_hSLang)) // If we can't find the server's Language revert to English. - Kigen
		g_hLanguages.GetValue("en", g_hSLang);
		
	g_hClearTimer = CreateTimer(14400.0, KACR_ClearTimer, _, TIMER_REPEAT); // Clear the Deny Array every 4 hours.
	
	AutoExecConfig_ExecuteFile(); // Execute the Config
	AutoExecConfig_CleanFile(); // Cleanup the Config (slow process)
	
	g_hCVar_Version = CreateConVar("kacr_version", PLUGIN_VERSION, "KACR Plugin Version (do not touch)", FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_UNLOGGED | FCVAR_DEMO | FCVAR_PROTECTED); // "notify" - So that we appear on Server Tracking Sites, "sponly" because we do not want Chat Messages about this CVar caused by "notify", "unlogged" - Because changes of this CVar dosent need to be logged, "demo" - So we get saved to Demos for later potential Cheat Analysis, "protected" - So no one can abuse Bugs in old Versions or bypass Limits set by CVars
	
	g_hCVar_PauseReports = AutoExecConfig_CreateConVar("kacr_pausereports", "120", "Once a cheating Player has been Reported/Logged, wait this many Seconds before reporting/logging him again. (0 = Always do Report/Log)", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0, true, 3600.0);
	g_iPauseReports = 60 * GetConVarInt(g_hCVar_PauseReports);
	
	HookConVarChange(g_hCVar_Version, ConVarChanged_Version); // Made, so no one touches the Version
	HookConVarChange(g_hCVar_PauseReports, ConVarChanged_PauseReports);
	
	KACR_PrintTranslatedToServer(KACR_LOADED);
	
	#if defined DEBUG
	 KACR_Log(false, "[Warning] You are running an early Version of Kigen AC Redux, please be aware that it may not run stable");
	 
	 RegAdminCmd("kacr_debug_action", Debug_Action_Cmd, ADMFLAG_ROOT, "For debugging purposes only! Usage: kacr_debug_action <Client ID> <Action ID>");
	 RegAdminCmd("kacr_debug_arrays", Debug_Arrays_CMD, ADMFLAG_ROOT, "For debugging purposes only! Prints some internal Arrays and DataMaps"); 
	#endif
}

public void OnPluginEnd()
{
	Commands_OnPluginEnd();
	Eyetest_OnPluginEnd();
	Trans_OnPluginEnd();
	
	if (g_bASteambot)
		ASteambot_RemoveModule();
		
	if (g_bSourceIRC)
		IRC_CleanUp();
		
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		g_bConnected[iClient] = false;
		g_bAuthorized[iClient] = false;
		g_bInGame[iClient] = false;
		g_bIsAdmin[iClient] = false;
		g_iLastCheatReported[iClient] = -3600; // 1h
		g_hCLang[iClient] = g_hSLang;
		g_bShouldProcess[iClient] = false;
		
		if (g_hValidateTimer[iClient] != INVALID_HANDLE)
			CloseHandle(g_hValidateTimer[iClient]);
			
		CVars_OnClientDisconnect(iClient);
	}
	
	if (g_hClearTimer != INVALID_HANDLE)
		CloseHandle(g_hClearTimer);
}

public void OnGameFrame()
{
	Security_OnGameFrame();
	Eyetest_OnGameFrame();
}

public void OnAllPluginsLoaded()
{
	char cReason[256], cAuthID[16];
	
	//- Library/Plugin Checks -//
	#if !defined DEBUG
	 if (LibraryExists("updater"))
	 	Updater_AddPlugin(UPDATE_URL);
	 	
	#endif
	
	if (LibraryExists("sourcebans++"))
		g_bSourceBansPP = true;
		
	if (LibraryExists("materialadmin")) // SB-Material Admin
		g_bSBMaterialAdmin = true;
		
	if (LibraryExists("sourcebans"))
		g_bSourceBans = true;
		
		KACR_CheckSBSystems();
		
	if (LibraryExists("ASteambot"))
	{
		ASteambot_RegisterModule("KACR");
		g_bASteambot = true;
	}
	
	if (LibraryExists("sourceirc"))
		g_bSourceIRC = true;
		
	//- Module Calls -//
	Commands_OnAllPluginsLoaded();
	
	//- Late load stuff -//
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsClientConnected(iClient))
		{
			if (!OnClientConnect(iClient, cReason, sizeof(cReason))) // Check all Clients because were late
				continue;
				
			if (IsClientAuthorized(iClient) && GetClientAuthId(iClient, AuthId_Steam2, cAuthID, sizeof(cAuthID)))
			{
				OnClientAuthorized(iClient, cAuthID);
				OnClientPostAdminCheck(iClient);
			}
			
			if (IsClientInGame(iClient))
				OnClientPutInServer(iClient);
		}
	}
}

public void OnConfigsExecuted()
{
	Security_OnConfigsExecuted();
}

public void OnLibraryAdded(const char[] cName)
{
	if (StrEqual(cName, "sourcebans++", false))
	{
		g_bSourceBansPP = true;
		KACR_CheckSBSystems();
	}
	
	else if (LibraryExists("materialadmin")) // SB-Material Admin
	{
		g_bSBMaterialAdmin = true;
		KACR_CheckSBSystems();
	}
	
	else if (StrEqual(cName, "sourcebans", false))
	{
		g_bSourceBans = true;
		KACR_CheckSBSystems();
	}
	
	else if (StrEqual(cName, "ASteambot", false) && !g_bASteambot) // Check so we do not register twice
	{
		ASteambot_RegisterModule("KACR");
		g_bASteambot = true;
	}
	
	else if (StrEqual(cName, "sourceirc", false))
		g_bSourceIRC = true;
		
	#if !defined DEBUG
	 else if (LibraryExists("updater"))
	 	Updater_AddPlugin(UPDATE_URL);
	 	
	#endif
}

public void OnLibraryRemoved(const char[] cName)
{
	if (StrEqual(cName, "sourcebans++", false))
		g_bSourceBansPP = false;
		
	else if (LibraryExists("materialadmin")) // SB-Material Admin
		g_bSBMaterialAdmin = false;
		
	else if (StrEqual(cName, "sourcebans", false))
		g_bSourceBans = false;
		
	else if (StrEqual(cName, "ASteambot", false))
		g_bASteambot = false;
		
	else if (StrEqual(cName, "sourceirc", false))
	{
		g_bSourceIRC = false;
		IRC_CleanUp();
	}
}


//- Updater -//

public Action Updater_OnPluginDownloading()
{
	KACR_Log(false, "[Info] Update found, downloading it now...");
	return Plugin_Continue;
}

public Updater_OnPluginUpdated() // TODO: Report to Admins once the Translations changed
{
	if (FileExists("addons/sourcemod/configs/plugin_settings.cfg"))
	{
		Handle hKV = KvizCreateFromFile("Plugins", "addons/sourcemod/configs/plugin_settings.cfg");
		char cKVEntry[8];
		bool bIncluded; // Is KACR or every Plugin set to reload once updated?
		
		//- Global Settings -//
		KvizGetStringExact(hKV, cKVEntry, sizeof(cKVEntry), "*.lifetime");
		if (StrEqual(cKVEntry, "mapsync"))
			bIncluded = true;
			
		//- KACR specific Settings -//
		KvizGetStringExact(hKV, cKVEntry, sizeof(cKVEntry), "kigen-ac_redux.lifetime");
		if (StrEqual(cKVEntry, "mapsync"))
			bIncluded = true;
			
		else if (StrEqual(cKVEntry, "lifetime")) // Just to be sure
			bIncluded = false;
			
		//- Set the Plugin to reload on Mapchange -//
		if (!bIncluded) // Not Set to reload on mapsync, changing that now!
		{
			if (KvizSetString(hKV, "mapsync", "kigen-ac_redux.lifetime") && KvizToFile(hKV, "plugin_settings.cfg", "kigen-ac_redux.lifetime"))
			{
				KACR_Log(false, "[Info] Writing 'plugin_settings.cfg' to automatically reload KACR when updated on Mapchange");
				KACR_Log(false, "[Info] Update successful, KACR will load the Update next Mapchange"); // Included, KACR will reload on Mapchange
			}
			
			else
				KACR_Log(false, "[Warning] Couldent write 'plugin_settings.cfg', KACR will update on the next Restart"); // We could reload ourself, but this would interrupt the Protection and thats what we do not want to happen
		}
		
		else // Included, KACR will reload on Mapchange
			KACR_Log(false, "[Info] Update successful, KACR will load the Update next Mapchange");
			
		KvizClose(hKV);
	}
	
	else // Default Settings, KACR will reload on Mapchange
		KACR_Log(false, "[Info] Update successful, KACR will load the Update next Mapchange");
}


//- Map/Entity Hooks -//

public void OnMapStart()
{
	g_bMapStarted = true;
	CVars_CreateNewOrder();
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	Client_OnMapEnd();
}

public void OnEntityCreated(int iEntity, const char[] cClassname)
{
	Eyetest_OnEntityCreated(iEntity, cClassname);
	Security_OnEntityCreated(iEntity, cClassname);
}


//- Client Functions -//

public bool OnClientConnect(iClient, char[] rejectmsg, size)
{
	if (IsFakeClient(iClient)) // Bots suck.
	{
		g_bIsFake[iClient] = true;
		return true;
	}
	
	g_bConnected[iClient] = true;
	g_hCLang[iClient] = g_hSLang;
	
	return Client_OnClientConnect(iClient, rejectmsg, size);
}

public void OnClientAuthorized(iClient, const char[] cAuth)
{
	if (IsFakeClient(iClient)) // Bots are annoying...
		return;
		
	Handle f_hTemp;
	char cReason[256];
	if (g_hDenyArray.GetString(cAuth, cReason, sizeof(cReason)))
	{
		KickClient(iClient, "%s", cReason);
		OnClientDisconnect(iClient);
		return;
	}
	
	g_bAuthorized[iClient] = true;
	
	if (g_bInGame[iClient])
		g_hPeriodicTimer[iClient] = CreateTimer(0.1, CVars_PeriodicTimer, iClient);
		
	f_hTemp = g_hValidateTimer[iClient];
	g_hValidateTimer[iClient] = INVALID_HANDLE;
	
	if (f_hTemp != INVALID_HANDLE)
		CloseHandle(f_hTemp);
}

public void OnClientPutInServer(iClient)
{
	Eyetest_OnClientPutInServer(iClient); // Ok, we'll help them bots too.
	
	if (IsFakeClient(iClient)) // Death to them bots!
		return;
		
	g_bInGame[iClient] = true;
	
	if (!g_bAuthorized[iClient]) // Not authorized yet?!?
		g_hValidateTimer[iClient] = CreateTimer(10.0, KACR_ValidateTimer, iClient);
		
	else
		g_hPeriodicTimer[iClient] = CreateTimer(0.1, CVars_PeriodicTimer, iClient);
		
	char f_sLang[8];
	GetLanguageInfo(GetClientLanguage(iClient), f_sLang, sizeof(f_sLang));
	if (!g_hLanguages.GetValue(f_sLang, g_hCLang[iClient]))
		g_hCLang[iClient] = g_hSLang;
}

public void OnClientPostAdminCheck(iClient)
{
	if (IsFakeClient(iClient)) // Humans for the WIN!
		return;
		
	if ((GetUserFlagBits(iClient) & ADMFLAG_GENERIC))
		g_bIsAdmin[iClient] = true; // Generic Admin
}

public void OnClientDisconnect(iClient)
{
	// if ( IsFake aww, screw it. :P
	Handle hTemp;
	
	g_bConnected[iClient] = false;
	g_bAuthorized[iClient] = false;
	g_bInGame[iClient] = false;
	g_bIsAdmin[iClient] = false;
	g_bIsFake[iClient] = false;
	g_iLastCheatReported[iClient] = -3600; // 1h
	g_hCLang[iClient] = g_hSLang;
	g_bShouldProcess[iClient] = false;
	g_bHooked[iClient] = false;
	
	//OnClientDisconnect(iClient); // TODO: Test this out #ref 573823
	for (int iCount = 1; iCount <= MaxClients; iCount++) // TODO: Is this really needed #ref 573823
		if (g_bConnected[iCount] && (!IsClientConnected(iCount) || IsFakeClient(iCount)))
			OnClientDisconnect(iCount);
			
	hTemp = g_hValidateTimer[iClient];
	g_hValidateTimer[iClient] = INVALID_HANDLE;
	if (hTemp != INVALID_HANDLE)
		CloseHandle(hTemp);
		
	CVars_OnClientDisconnect(iClient);
}


//- Timers -//

public Action KACR_ValidateTimer(Handle hTimer, any iClient)
{
	g_hValidateTimer[iClient] = INVALID_HANDLE;
	
	if (!g_bInGame[iClient] || g_bAuthorized[iClient])
		return Plugin_Stop;
		
	KACR_Kick(iClient, KACR_FAILEDAUTH); // Failed to auth in-time
	return Plugin_Stop;
}

public Action KACR_ClearTimer(Handle hTimer)
{
	g_hDenyArray.Clear();
}


//- ConVar Hooks -//

public void ConVarChanged_Version(Handle hCvar, const char[] cOldValue, const char[] cNewValue)
{
	if (!StrEqual(cNewValue, PLUGIN_VERSION))
		SetConVarString(g_hCVar_Version, PLUGIN_VERSION);
}

public void ConVarChanged_PauseReports(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_iPauseReports = 60 * GetConVarInt(g_hCVar_PauseReports); // Mins to Seconds
}


//- Commands -//

#if defined DEBUG
 Action Debug_Action_Cmd(const iCallingClient, const iArgs)
 {
 	//- Error Checks -//
 	if (iArgs < 2)
 	{
 		ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] Too few Arguments, Usage: kacr_debug_action <Client ID> <Action ID>");
 		return Plugin_Handled;
 	}
 	
 	else if (iArgs > 2)
 	{
 		ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] Too many Arguments, Usage: kacr_debug_action <Client ID> <Action ID>");
 		return Plugin_Handled;
 	}
 	
 	//- Vars -//
 	char cTarget[3], cAction[8], cActionsTaken[256];
 	GetCmdArg(1, cTarget, 3);
 	GetCmdArg(2, cAction, 8);
 	int iTarget = StringToInt(cTarget);
 	int iAction = StringToInt(cAction);
 	
 	if (!g_bAuthorized[iTarget] || g_bIsFake[iTarget])
 	{
 		ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] The specified Client is not valid")
 		return Plugin_Handled;
 	}
 	
 	//- Actions -//
 	KACR_Action(iTarget, iAction, 5, "[Debug] Kick Reason Test", "[Debug] Execution Reason Test");
 	bool bActions[KACR_Action_Count]; // TODO: Is this a correct Handover?
 	KACR_ActionCheck(iAction, bActions); // TODO: Is this a correct Handover?
 	Format(cActionsTaken, sizeof(cActionsTaken), "[Debug][Kigen AC Redux] Applied the following Action(s) on '%N': ", iTarget);
 	
 	//- Reply Back with Actions taken -//
 	if (bActions[KACR_ActionID_Ban])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Ban, ");
 		
 	if (bActions[KACR_ActionID_TimeBan])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Time Ban, ");
 		
 	if (bActions[KACR_ActionID_ServerBan])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Server Ban, ");
 		
 	if (bActions[KACR_ActionID_ServerTimeBan])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Server Time Ban, ");
 		
 	if (bActions[KACR_ActionID_Kick])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Kick, ");
 		
 	if (bActions[KACR_ActionID_Crash])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Crash, ");
 		
 	if (bActions[KACR_ActionID_ReportSB])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Reported to SB, ");
 		
 	if (bActions[KACR_ActionID_ReportAdmins])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Reported to Admins, ");
 		
 	if (bActions[KACR_ActionID_ReportSteamAdmins])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Reported to Steam Admins, ");
 		
 	if (bActions[KACR_ActionID_AskSteamAdmin])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Asked Steam Admin(s) what todo, ");
 		
 	if (bActions[KACR_ActionID_Log])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Logged Actions, ");
 		
 	if (bActions[KACR_ActionID_ReportIRC])
 		StrCat(cActionsTaken, sizeof(cActionsTaken), "Reported to IRC, ");
 		
 	String_Trim(cActionsTaken, cActionsTaken, sizeof(cActionsTaken), ", ");
 	ReplyToCommand(iCallingClient, cActionsTaken);
 	
 	return Plugin_Handled;
 }
#endif


// TODO: BUG: last reported isent correct
#if defined DEBUG
 Action Debug_Arrays_CMD(const iCallingClient, const iArgs) // This is ugly, but it does the Job
 {
 	ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] Printing some Array/DataMap Entrys:");
 	//
 	ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] Connected Players");
 	for (int iClient = 1; iClient <= MaxClients; iClient++)
 		ReplyToCommand(iCallingClient, "%i is %s", iClient, g_bConnected[iClient] ? "connected" : "not connected");
 	//
 	ReplyToCommand(iCallingClient, "--------------------");
 	ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] Authorized Players");
 	for (int iClient = 1; iClient <= MaxClients; iClient++)
 		if(g_bAuthorized[iClient])
 			ReplyToCommand(iCallingClient, "%N is %s", iClient, g_bAuthorized[iClient] ? "authorized" : "not authorized");
 	//
 	ReplyToCommand(iCallingClient, "--------------------");
 	ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] Ingame Players");
 	for (int iClient = 1; iClient <= MaxClients; iClient++)
 		if(g_bAuthorized[iClient])
 			ReplyToCommand(iCallingClient, "%N is %s", iClient, g_bInGame[iClient] ? "In-Game" : "not In-Game");
 	//
 	ReplyToCommand(iCallingClient, "--------------------");
 	ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] Admins");
 	for (int iClient = 1; iClient <= MaxClients; iClient++)
 		if(g_bAuthorized[iClient])
 			ReplyToCommand(iCallingClient, "%N is%s", iClient, g_bIsAdmin[iClient] ? " an Admin" : "n't an Admin");
 	//
 	ReplyToCommand(iCallingClient, "--------------------");
 	ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] Clients Processed by the Eyecheck?");
 	for (int iClient = 1; iClient <= MaxClients; iClient++)
 		if(g_bAuthorized[iClient])
 			ReplyToCommand(iCallingClient, "%N should %s by the Eyecheck", iClient, g_bShouldProcess[iClient] ? "be proceeded" : "not be proceeded");
 	//
 	ReplyToCommand(iCallingClient, "--------------------");
 	ReplyToCommand(iCallingClient, "[Debug][Kigen AC Redux] Last Time Players where Reported");
 	for (int iClient = 1; iClient <= MaxClients; iClient++)
 		if(g_bAuthorized[iClient])
 			ReplyToCommand(iCallingClient, "%N was last reported %i Seconds ago", iClient, (RoundToNearest(GetTickedTime()) - g_iLastCheatReported[iClient]));
 			
 	return Plugin_Handled;
 }
#endif


//- Functions -//

/*
* Checks wether multiply Sourcebans Versions are installed
*/
KACR_CheckSBSystems()
{
	if (g_bSourceBansPP && g_bSBMaterialAdmin) // Only SB++ will be called since it always executes with an if check before SB-MA and SB, so its totally failsafe
	{
		KACR_Log(false, "[Warning] Sourcebans++ and SB-MaterialAdmin are installed at the same Time! This can Result in Problems, KACR will only use SB++ for now");
		MALog(MA_LogConfig, "[Warning] Sourcebans++ and SB-MaterialAdmin are installed at the same Time! This can Result in Problems, KACR will only use SB++ for now"); // There is no description for the Log type, i hope thats correct ref. 392749
	}
	
	else if (g_bSourceBansPP && g_bSourceBans)
		KACR_Log(false, "[Warning] Sourcebans++ and Sourcebans 2.X are installed at the same Time! This can Result in Problems, KACR will only use SB++ for now");
		
	else if(g_bSBMaterialAdmin && g_bSourceBans) 
	{
		KACR_Log(false, "[Warning] SB-MaterialAdmin and Sourcebans 2.X are installed at the same Time! This can Result in Problems, KACR will only use SB-MaterialAdmin for now");
		MALog(MA_LogConfig, "[Warning] SB-MaterialAdmin and Sourcebans 2.X are installed at the same Time! This can Result in Problems, KACR will only use SB-MaterialAdmin for now"); // There is no description for the Log type, i hope thats correct ref. 392749
	}
}