// Copyright (C) 2007-2011 CodingDirect LLC
// This File is Licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details

// Compiler Settings

#pragma newdecls optional
#pragma dynamic 393216 // 1536KB (1024+512) // 25.10.19 - 205924(1.8)-255224(1.10) bytes required - I know this MUCH for a Plugin, the normal Stack is 4KB! But do mind that this is nothing compared to only 1 GB of Memory!


//- Includes -//

#include <sdktools>
#undef REQUIRE_EXTENSIONS 
#include <sdkhooks>
#define REQUIRE_EXTENSIONS
#include <adminmenu> // Normally this dosent need to be included, but ive got some strange bug with the 1.10 Compiler
// #include <socket> // Required for the networking Module
#include <smlib_kacr> // Copyright (C) SMLIB Contributors // This Include is Licensed under GPLv3, see 'Licenses/License_SMLIB.txt' for Details
#include <autoexecconfig_kacr> //  Copyright (C) 2013-2017 Impact // This Include is Licensed under GPLv3, see 'Licenses/License_AutoExecConfig.txt' for Details 
#undef REQUIRE_PLUGIN
// #include <ASteambot> // Copyright (c) ASteamBot Contributors // This Include is Licensed under The MIT License, see 'Licenses/License_ASteambot.txt' for Details // BUG: Native "ASteambot_SendMesssage" was not found
#define REQUIRE_PLUGIN


//- Natives -//

// SourceBans++
native void SBPP_BanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason);
native void SBPP_ReportPlayer(int iReporter, int iTarget, const char[] sReason);

// Sourcebans 2.X
native void SBBanPlayer(client, target, time, char[] reason);
native void SB_ReportPlayer(int client, int target, const char[] reason);

//native AddTargetsToMenu2(Handle menu, source_client, flags); // TODO: Strange BUG in the 1.10 Compiler


//- Defines -//

#define PLUGIN_VERSION "0.1" // TODO: No versioning right now, we are on a Rolling Release Cycle

#define loop for(;;) // Unlimited Loop

#define KACR_Action_Count 13 // 18.11.19 - 12+1 carry Bit
#define KACR_Action_Ban 1
#define KACR_Action_TimeBan 2
#define KACR_Action_ServerBan 3
#define KACR_Action_ServerTimeBan 4
#define KACR_Action_Kick 5
#define KACR_Action_Crash 6
#define KACR_Action_ReportSB 7
#define KACR_Action_ReportAdmins 8
#define KACR_Action_ReportSteamAdmins 9
#define KACR_Action_AskSteamAdmin 10
#define KACR_Action_Log 11
#define KACR_Action_ReportIRC 12


//- Global Variables -//

Handle g_hValidateTimer[MAXPLAYERS + 1];
Handle g_hClearTimer, g_hCVar_Version;
EngineVersion g_hGame;

StringMap g_hCLang[MAXPLAYERS + 1];
StringMap g_hSLang, g_hDenyArray;

bool g_bConnected[MAXPLAYERS + 1]; // I use these instead of the natives because they are cheaper to call
bool g_bAuthorized[MAXPLAYERS + 1]; // When I need to check on a client's state.  Natives are very taxing on
bool g_bInGame[MAXPLAYERS + 1]; // system resources as compared to these. - Kigen
bool g_bIsAdmin[MAXPLAYERS + 1];
bool g_bIsFake[MAXPLAYERS + 1];
bool g_bSourceBans, g_bSourceBansPP, g_bASteambot, g_bMapStarted;


//- KACR Modules -// Note that the ordering of these Includes is important

#include "kigen-ac_redux/translations.sp"	// Translations Module - NEEDED FIRST
#include "kigen-ac_redux/client.sp"			// Client Module
#include "kigen-ac_redux/commands.sp"		// Commands Module
#include "kigen-ac_redux/cvars.sp"			// CVar Module
#include "kigen-ac_redux/eyetest.sp"		// Eye Test Module
#include "kigen-ac_redux/rcon.sp"			// RCON Module
#include "kigen-ac_redux/status.sp"			// Status Module
#include "kigen-ac_redux/stocks.sp"			// Stocks Module


public Plugin myinfo = 
{
	name = "Kigen's Anti-Cheat Redux", 
	author = "Playa (Formerly Max Krivanek)", 
	description = "An Universal Anti Cheat Solution compactible with most Source Engine Games", 
	version = PLUGIN_VERSION, 
	url = "github.com/DJPlaya/Kigen-AC-Redux"
};


//- Plugin and Config Functions -//

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, err_max)
{
	MarkNativeAsOptional("SDKHook");
	MarkNativeAsOptional("SDKUnhook");
	MarkNativeAsOptional("SBPP_BanPlayer");
	MarkNativeAsOptional("SBPP_ReportPlayer");
	MarkNativeAsOptional("SBBanPlayer");
	MarkNativeAsOptional("SB_ReportPlayer");
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_hDenyArray = new StringMap();
	g_hGame = GetEngineVersion(); // Identify the game
	
	AutoExecConfig_SetFile("Kigen-AC_Redux"); // Set which file to write Cvars to
	
	//- Module Calls -//
	Status_OnPluginStart();
	Client_OnPluginStart()
	Commands_OnPluginStart();
	CVars_OnPluginStart();
	Eyetest_OnPluginStart();
	RCON_OnPluginStart();
	Trans_OnPluginStart();
	
	//- Get server language -//
	char f_sLang[8];
	GetLanguageInfo(GetServerLanguage(), f_sLang, sizeof(f_sLang));
	if (!g_hLanguages.GetValue(f_sLang, any:g_hSLang)) // If we can't find the server's Language revert to English. - Kigen
		g_hLanguages.GetValue("en", any:g_hSLang);
		
	g_hClearTimer = CreateTimer(14400.0, KACR_ClearTimer, _, TIMER_REPEAT); // Clear the Deny Array every 4 hours.
	
	AutoExecConfig_ExecuteFile(); // Execute the Config
	AutoExecConfig_CleanFile(); // Cleanup the Config (slow process)
	
	g_hCVar_Version = CreateConVar("kacr_version", PLUGIN_VERSION, "KACR Plugin Version (do not touch)", FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_UNLOGGED); // "notify" - So that we appear on Server Tracking Sites, "sponly" because we do not want Chat Messages about this CVar caused by "notify", "dontrecord" - So that we don't get saved to the Auto cfg, "unlogged" - Because changes of this CVar dosent need to be logged
	
	SetConVarString(g_hCVar_Version, PLUGIN_VERSION); // TODO: Is this really needed?
	HookConVarChange(g_hCVar_Version, ConVarChanged_Version); // Made, so no one touches the Version
	
	KACR_PrintToServer(KACR_LOADED);
}

public void OnPluginEnd()
{
	Commands_OnPluginEnd();
	Eyetest_OnPluginEnd();
	Trans_OnPluginEnd();
	
	// ASteambot_RemoveModule();
	
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		g_bConnected[iClient] = false;
		g_bAuthorized[iClient] = false;
		g_bInGame[iClient] = false;
		g_bIsAdmin[iClient] = false;
		g_hCLang[iClient] = g_hSLang;
		g_bShouldProcess[iClient] = false;
		
		if (g_hValidateTimer[iClient] != INVALID_HANDLE)
			CloseHandle(g_hValidateTimer[iClient]);
			
		CVars_OnClientDisconnect(iClient);
	}
	
	if (g_hClearTimer != INVALID_HANDLE)
		CloseHandle(g_hClearTimer);
}

public void OnAllPluginsLoaded()
{
	char cReason[256], cAuthID[64];
	
	if (FindPluginByFile("sbpp_main.smx"))
		g_bSourceBansPP = true;
		
	else if (FindPluginByFile("sourcebans.smx"))
		g_bSourceBans = true;
		
	else // Rare but possible, someone unloaded SB and we would still think its active :O
	{
		g_bSourceBansPP = false;
		g_bSourceBans = false;
	}
	
	if(g_bSourceBansPP && g_bSourceBans)
		KACR_Log("[Warning] Sourcebans++ and Sourcebans 2.X are installed at the same Time! This can Result in Problems, KACR will only use SB++ for now");
		
	if (LibraryExists("ASteambot"))
	{
		// ASteambot_RegisterModule("KACR"); // BUG: Native "ASteambot_SendMesssage" was not found
		g_bASteambot = true;
	}
	
	else
		g_bASteambot = false;
		
		
	//- Module Calls -//
	Commands_OnAllPluginsLoaded();
	
	//- Late load stuff -//
	for (int ig_iSongCount = 1; ig_iSongCount <= MaxClients; ig_iSongCount++)
	{
		if (IsClientConnected(ig_iSongCount))
		{
			if (!OnClientConnect(ig_iSongCount, cReason, sizeof(cReason))) // Check all Clients because were late
				continue;
				
			if (IsClientAuthorized(ig_iSongCount) && GetClientAuthId(ig_iSongCount, AuthId_Steam2, cAuthID, sizeof(cAuthID)))
			{
				OnClientAuthorized(ig_iSongCount, cAuthID);
				OnClientPostAdminCheck(ig_iSongCount);
			}
			
			if (IsClientInGame(ig_iSongCount))
				OnClientPutInServer(ig_iSongCount);
		}
	}
}

public void OnConfigsExecuted() // TODO: Make this Part bigger // This dosent belong into cvars because that is for client vars only
{
	//- Prevent Speeds -//
	Handle hVar1 = FindConVar("sv_max_usercmd_future_ticks");
	if (hVar1) // != INVALID_HANDLE
	{
		if (GetConVarInt(hVar1) != 1) // TODO: Replace with 'hVar1.IntValue != 1' once we dropped legacy Support
		{
			KACR_Log("[Warning] 'sv_max_usercmd_future_ticks' was set to '%i' which is a risky Value, we have re-set it to '1'", GetConVarInt(hVar1)); // TODO: Replace with 'hVar1.IntValue' once we dropped legacy Support
			SetConVarInt(hVar1, 1); // TODO: Replace with 'hVar1.SetInt(...)' once we dropped legacy Support
		}
	}
}


//- Map Functions -//

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


//- Client Functions -//

public bool OnClientConnect(client, char[] rejectmsg, size)
{
	if (IsFakeClient(client)) // Bots suck.
	{
		g_bIsFake[client] = true;
		return true;
	}
	
	g_bConnected[client] = true;
	g_hCLang[client] = g_hSLang;
	
	return Client_OnClientConnect(client, rejectmsg, size);
}

public void OnClientAuthorized(client, const char[] auth)
{
	if (IsFakeClient(client)) // Bots are annoying...
		return;
		
	Handle f_hTemp;
	char cReason[256];
	if (g_hDenyArray.GetString(auth, cReason, sizeof(cReason)))
	{
		KickClient(client, "%s", cReason);
		OnClientDisconnect(client);
		return;
	}
	
	g_bAuthorized[client] = true;
	
	if (g_bInGame[client])
		g_hPeriodicTimer[client] = CreateTimer(0.1, CVars_PeriodicTimer, client);
		
	f_hTemp = g_hValidateTimer[client];
	g_hValidateTimer[client] = INVALID_HANDLE;
	
	if (f_hTemp != INVALID_HANDLE)
		CloseHandle(f_hTemp);
}

public void OnClientPutInServer(client)
{
	Eyetest_OnClientPutInServer(client); // Ok, we'll help them bots too.
	
	if (IsFakeClient(client)) // Death to them bots!
		return;
		
	char f_sLang[8];
	
	g_bInGame[client] = true;
	
	if (!g_bAuthorized[client]) // Not authorized yet?!?
		g_hValidateTimer[client] = CreateTimer(10.0, KACR_ValidateTimer, client);
		
	else
		g_hPeriodicTimer[client] = CreateTimer(0.1, CVars_PeriodicTimer, client);
		
	GetLanguageInfo(GetClientLanguage(client), f_sLang, sizeof(f_sLang));
	if (!g_hLanguages.GetValue(f_sLang, g_hCLang[client]))
		g_hCLang[client] = g_hSLang;
}

public void OnClientPostAdminCheck(client)
{
	if (IsFakeClient(client)) // Humans for the WIN!
		return;
		
	if ((GetUserFlagBits(client) & ADMFLAG_GENERIC))
		g_bIsAdmin[client] = true;
}

public void OnClientDisconnect(client)
{
	// if ( IsFake aww, screw it. :P
	Handle f_hTemp;
	
	f_hTemp = g_hValidateTimer[client];
	g_hValidateTimer[client] = INVALID_HANDLE;
	if (f_hTemp != INVALID_HANDLE)
		CloseHandle(f_hTemp);
		
	CVars_OnClientDisconnect(client);
}


//- Timers -//

public Action KACR_ValidateTimer(Handle timer, any client)
{
	g_hValidateTimer[client] = INVALID_HANDLE;
	
	if (!g_bInGame[client] || g_bAuthorized[client])
		return Plugin_Stop;
		
	KACR_Kick(client, KACR_FAILEDAUTH); // Failed to auth in-time
	return Plugin_Stop;
}

public Action KACR_ClearTimer(Handle timer, any nothing)
{
	g_hDenyArray.Clear();
}


//- ConVar Hook -//

public void ConVarChanged_Version(Handle hCvar, const char[] cOldValue, const char[] cNewValue)
{
	if (!StrEqual(cNewValue, PLUGIN_VERSION))
		SetConVarString(g_hCVar_Version, PLUGIN_VERSION);
}