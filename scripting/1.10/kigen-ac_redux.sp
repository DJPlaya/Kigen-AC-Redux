/*
	Kigen's Anti-Cheat
	Copyright (C) 2007-2011 CodingDirect LLC
	No Copyright (i guess) 2018-2019 FunForBattle
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


//- Compiler Options -//

#pragma newdecls optional


//- Includes -//

#include <sdktools>
#undef REQUIRE_EXTENSIONS 
#include <sdkhooks>
#define REQUIRE_EXTENSIONS
// #include <socket> // Required for the networking Module // Outdated TODO
#include <smlib_kacr>
#include <autoexecconfig_kacr>


//- Natives -//

native void SBBanPlayer(client, target, time, char[] reason); // Sourcebans
native void SBPP_BanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason); // SourceBans++


//- Defines -//

#define PLUGIN_VERSION "0.1"


//- Global Variables -//

Handle g_hValidateTimer[MAXPLAYERS + 1];
Handle g_hClearTimer, g_hCVarVersion;
EngineVersion hGame;

StringMap g_hCLang[MAXPLAYERS + 1];
StringMap g_hSLang, g_hDenyArray;

bool g_bConnected[MAXPLAYERS + 1]; // I use these instead of the natives because they are cheaper to call
bool g_bAuthorized[MAXPLAYERS + 1]; // when I need to check on a client's state.  Natives are very taxing on
bool g_bInGame[MAXPLAYERS + 1]; // system resources as compared to these. - Kigen
bool g_bIsAdmin[MAXPLAYERS + 1];
bool g_bIsFake[MAXPLAYERS + 1];
bool g_bSourceBans, g_bSourceBansPP, g_bMapStarted;


//- KACR Modules -// Note: The that ordering of these Includes is imporant

#include "kigen-ac_redux/translations.sp"	// Translations Module - NEEDED FIRST
#include "kigen-ac_redux/client.sp"			// Client Module
#include "kigen-ac_redux/commands.sp"		// Commands Module
#include "kigen-ac_redux/cvars.sp"			// CVar Module
#include "kigen-ac_redux/eyetest.sp"		// Eye Test Module
// #include "kigen-ac_redux/network.sp"		// Network Module // OUTDATED
#include "kigen-ac_redux/rcon.sp"			// RCON Module
#include "kigen-ac_redux/status.sp"			// Status Module
#include "kigen-ac_redux/stocks.sp"			// Stocks Module


public Plugin myinfo = 
{
	name = "Kigen's Anti-Cheat Redux", 
	author = "Playa", 
	description = "An Universal Anti Cheat Solution compactible with most Source Engine Games", 
	version = PLUGIN_VERSION, 
	url = "github.com/DJPlaya/Kigen-AC-Redux"
};


//- Plugin Functions -//

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, err_max)
{
	MarkNativeAsOptional("SDKHook");
	MarkNativeAsOptional("SDKUnhook");
	MarkNativeAsOptional("SBBanPlayer");
	MarkNativeAsOptional("SBPP_BanPlayer");
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	Handle f_hTemp;
	char f_sLang[8];
	
	g_hDenyArray = new StringMap();
	hGame = GetEngineVersion(); // Identify the game
	
	AutoExecConfig_SetFile("Kigen-AC_Redux"); // Set which file to write Cvars to
	
	//- Module Calls -//
	Status_OnPluginStart();
	Client_OnPluginStart()
	Commands_OnPluginStart();
	CVars_OnPluginStart();
	Eyetest_OnPluginStart();
	// Network_OnPluginStart(); // OUTDATED
	RCON_OnPluginStart();
	Trans_OnPluginStart();
	
	//- Get server language -//
	GetLanguageInfo(GetServerLanguage(), f_sLang, sizeof(f_sLang));
	if (!g_hLanguages.GetValue(f_sLang, any:g_hSLang)) // If we can't find the server's Language revert to English. - Kigen
		g_hLanguages.GetValue("en", any:g_hSLang);
		
	g_hClearTimer = CreateTimer(14400.0, KACR_ClearTimer, _, TIMER_REPEAT); // Clear the Deny Array every 4 hours.
	
	//- Prevent Speeds -//
	f_hTemp = FindConVar("sv_max_usercmd_future_ticks");
	if (f_hTemp != INVALID_HANDLE)
		SetConVarInt(f_hTemp, 1);
	
	AutoExecConfig_ExecuteFile(); // Execute the Config
	AutoExecConfig_CleanFile(); // Cleanup the Config (slow process)
	
	g_hCVarVersion = CreateConVar("kacr_version", PLUGIN_VERSION, "Kigen Anti Cheat Redux Plugin Version (do not touch)", FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_UNLOGGED); // "notify" - So that we appear on Server Tracking Sites, "sponly" because we do not want Chat Messages about this CVar caused by "notify", "dontrecord" - So that we don't get saved to the Auto cfg, "unlogged" - Because changes of this CVar dosent need to be logged
	
	SetConVarString(g_hCVarVersion, PLUGIN_VERSION); // TODO: Is this really needed?
	HookConVarChange(g_hCVarVersion, VersionChange); // TODO: HMMM? Propably related to the old Updater System
	
	KACR_PrintToServer(KACR_LOADED);
}

public void OnAllPluginsLoaded()
{
	char f_sReason[256], f_sAuthID[64];
	
	if (FindPluginByFile("sbpp_main.smx"))
		g_bSourceBansPP = true;
		
	else if (FindPluginByFile("sourcebans.smx"))
		g_bSourceBans = true;
		
	else // Rare but possible, someone unloaded SB and we would still think its active :O
	{
		g_bSourceBansPP = false;
		g_bSourceBans = false;
	}
	
	//- Module Calls -//
	Commands_OnAllPluginsLoaded();
	
	//- Late load stuff -//
	for (int iCount = 1; iCount <= MaxClients; iCount++)
	{
		if (IsClientConnected(iCount))
		{
			if (!OnClientConnect(iCount, f_sReason, sizeof(f_sReason))) // TODO: Is this really needed?
			{
				KickClient(iCount, "%s", f_sReason);
				continue;
			}
			
			if (IsClientAuthorized(iCount) && GetClientAuthId(iCount, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID)))
			{
				OnClientAuthorized(iCount, f_sAuthID);
				OnClientPostAdminCheck(iCount);
			}
			
			if (IsClientInGame(iCount))
				OnClientPutInServer(iCount);
		}
	}
}

public void OnPluginEnd()
{
	// Client_OnPluginEnd(); // Currently unused
	Commands_OnPluginEnd();
	Eyetest_OnPluginEnd();
	// Network_OnPluginEnd(); // OUTDATED
	// RCON_OnPluginEnd(); // Currently unused
	// Status_OnPluginEnd(); // Currently unused
	
	for (int iClient = 0; iClient <= MaxClients; iClient++)
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

//- Map Functions -//

public void OnMapStart()
{
	g_bMapStarted = true;
	CVars_CreateNewOrder();
	// Client_OnMapStart(); // Currently unused 
	// RCON_OnMap(); // Currently unused
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	Client_OnMapEnd();
	// RCON_OnMap(); // Currently unused
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
	char f_sReason[256];
	if (g_hDenyArray.GetString(auth, f_sReason, sizeof(f_sReason)))
	{
		KickClient(client, "%s", f_sReason);
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
	
	g_bConnected[client] = false;
	g_bAuthorized[client] = false;
	g_bInGame[client] = false;
	g_bIsAdmin[client] = false;
	g_bIsFake[client] = false;
	g_hCLang[client] = g_hSLang;
	g_bShouldProcess[client] = false;
	g_bHooked[client] = false;
	
	for (int iCount = 1; iCount <= MaxClients; iCount++)
	if (g_bConnected[iCount] && (!IsClientConnected(iCount) || IsFakeClient(iCount)))
		OnClientDisconnect(iCount);
		
	f_hTemp = g_hValidateTimer[client];
	g_hValidateTimer[client] = INVALID_HANDLE;
	if (f_hTemp != INVALID_HANDLE)
		CloseHandle(f_hTemp);
		
	CVars_OnClientDisconnect(client);
	// Network_OnClientDisconnect(client); // OUTDATED
}

//- Timers -//

public Action KACR_ValidateTimer(Handle timer, any client)
{
	g_hValidateTimer[client] = INVALID_HANDLE;
	
	if (!g_bInGame[client] || g_bAuthorized[client])
		return Plugin_Stop;
		
	KACR_Kick(client, KACR_FAILEDAUTH);
	return Plugin_Stop;
}

public Action KACR_ClearTimer(Handle timer, any nothing)
{
	g_hDenyArray.Clear();
}

//- ConVar Hook -//

public void VersionChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (!StrEqual(newValue, PLUGIN_VERSION))
		SetConVarString(g_hCVarVersion, PLUGIN_VERSION);
} 