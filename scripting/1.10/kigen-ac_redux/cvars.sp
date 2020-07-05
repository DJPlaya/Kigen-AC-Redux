// Copyright (C) 2007-2011 CodingDirect LLC
// This File is Licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details


// Array Index Documentation
// Arrays that come from g_hConVarArray are index like below.
// 1. CVar Name
// 2. Comparison Type
// 3. CVar Handle - If this is defined then the engine will ignore the Comparison Type and Values as this should be only for FCVAR_REPLICATED CVars.
// 4. Action Type - Determines what action the engine takes.
// 5. Value - The value that the cvar is expected to have.
// 6. Value 2 - Only used as the high bound for COMP_BOUND.
// 7. Important - Defines the importance of the CVar in the ordering of the checks.
// 8. Was Changed - Defines if this CVar was changed recently.


//- Global CVARS Defines -//

#define CELL_NAME 0
#define CELL_COMPTYPE 1
#define CELL_HANDLE 2
#define CELL_ACTION 3
#define CELL_VALUE 4
#define CELL_VALUE2 5
#define CELL_ALT 6
#define CELL_PRIORITY 7
#define CELL_CHANGED 8

#define ACTION_WARN 0 // Warn Admins
#define ACTION_MOTD 1 // Display MOTD with Alternate URL
#define ACTION_MUTE 2 // Mute the player.
#define ACTION_KICK 3 // Kick the player.
#define ACTION_BAN 4 // Ban the player.

#define COMP_EQUAL 0 // CVar should equal
#define COMP_GREATER 1 // CVar should be equal to or greater than
#define COMP_LESS 2 // CVar should be equal to or less than
#define COMP_BOUND 3 // CVar should be in-between two numbers.
#define COMP_STRING 4 // Cvar should string equal.
#define COMP_NONEXIST 5 // CVar shouldn't exist.

#define PRIORITY_NORMAL 0
#define PRIORITY_MEDIUM 1
#define PRIORITY_HIGH 3

//- Global CVARS Variables -//

Handle g_hCVar_CVars_Enable, g_hConVarArray;
Handle g_hCurrentQuery[MAXPLAYERS + 1], g_hReplyTimer[MAXPLAYERS + 1], g_hPeriodicTimer[MAXPLAYERS + 1];
StringMap g_hCVar_Index;

char g_cQueryResult[][] =  { "Okay", "Not found", "Not valid", "Protected" };

int g_iCurrentIndex[MAXPLAYERS + 1] =  { 0, ... }, g_iRetryAttempts[MAXPLAYERS + 1] =  { 0, ... };
int g_iSize = 0, g_iCVarsStatus;

bool g_bCVarsEnabled = true;


//- Plugin Functions -//

public void CVars_OnPluginStart()
{
	Handle f_hConCommand, hConVar;
	char f_sName[64];
	bool f_bIsCommand;
	int f_iFlags;
	
	g_hCVar_CVars_Enable = AutoExecConfig_CreateConVar("kacr_cvars_enable", "1", "Enable the CVar checking Module", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bCVarsEnabled = GetConVarBool(g_hCVar_CVars_Enable);
	
	HookConVarChange(g_hCVar_CVars_Enable, ConVarChanged_CVars_Enable);
	
	g_hConVarArray = CreateArray(64);
	g_hCVar_Index = new StringMap();
	
	// High Priority // Note: We kick them out before hand because we don't want to have to ban them.
	CVars_AddCVar("0penscript", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("bat_version", COMP_NONEXIST, ACTION_KICK, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("beetlesmod_version", COMP_NONEXIST, ACTION_KICK, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("est_version", COMP_NONEXIST, ACTION_KICK, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("eventscripts_ver", COMP_NONEXIST, ACTION_KICK, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("fm_attackmode", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("lua_open", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("Lua-Engine", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("mani_admin_plugin_version", COMP_NONEXIST, ACTION_KICK, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("ManiAdminHacker", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("ManiAdminTakeOver", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("metamod_version", COMP_NONEXIST, ACTION_KICK, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("openscript", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("openscript_version", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("runnscript", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("SmAdminTakeover", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("sourcemod_version", COMP_NONEXIST, ACTION_KICK, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("tb_enabled", COMP_NONEXIST, ACTION_BAN, "0.0", 0.0, PRIORITY_HIGH);
	CVars_AddCVar("zb_version", COMP_NONEXIST, ACTION_KICK, "0.0", 0.0, PRIORITY_HIGH);
	
	// Medium Priority // Note: Now the client should be clean of any third party server side plugins.  Now we can start really checking.
	CVars_AddCVar("sv_cheats", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_MEDIUM);
	CVars_AddCVar("sv_consistency", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_MEDIUM);
	CVars_AddCVar("sv_gravity", COMP_EQUAL, ACTION_BAN, "800.0", 0.0, PRIORITY_MEDIUM);
	CVars_AddCVar("r_drawothermodels", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_MEDIUM);
	
	// Normal Priority //
	CVars_AddCVar("cl_clock_correction", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("cl_leveloverview", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("cl_overdraw_test", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	
	if (g_hGame != Engine_CSGO)
		CVars_AddCVar("cl_particle_show_bbox", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
		
	else
		CVars_AddCVar("cl_particles_show_bbox", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL); // TODO: Outdated in CSS? cl_particles_show_bbox
		
	CVars_AddCVar("cl_phys_timescale", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("cl_showevents", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	
	if (g_hGame == Engine_Insurgency)
		CVars_AddCVar("fog_enable", COMP_EQUAL, ACTION_KICK, "1.0", 0.0, PRIORITY_NORMAL);
		
	else
		CVars_AddCVar("fog_enable", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
		
	CVars_AddCVar("host_timescale", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("mat_dxlevel", COMP_GREATER, ACTION_KICK, "80.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("mat_fillrate", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("mat_measurefillrate", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("mat_proxy", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("mat_showlowresimage", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("mat_wireframe", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("mem_force_flush", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("snd_show", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("snd_visualize", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_aspectratio", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_colorstaticprops", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_DispWalkable", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_DrawBeams", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawbrushmodels", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawclipbrushes", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawdecals", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawentities", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawmodelstatsoverlay", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawopaqueworld", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawparticles", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawrenderboxes", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawskybox", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_drawtranslucentworld", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_shadowwireframe", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_skybox", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("r_visocclusion", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("vcollide_wireframe", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("cl_cmdrate", COMP_GREATER, ACTION_KICK, "1.0", 1.0, PRIORITY_NORMAL); // There is an Exploit with the CVar beeing filled with Chars #44, if it has chars, it cant be greater than 0.0
	
	
	//- Replication Protection -//
	
	f_hConCommand = FindFirstConCommand(f_sName, sizeof(f_sName), f_bIsCommand, f_iFlags);
	if (f_hConCommand == INVALID_HANDLE)
		KACR_Log(true, "[Critical] Failed getting first ConVar");
		
	do
	{
		if (!f_bIsCommand && (f_iFlags & FCVAR_REPLICATED))
		{
			hConVar = FindConVar(f_sName);
			if (hConVar == INVALID_HANDLE)
				continue;
				
			CVars_ReplicateConVar(hConVar);
			HookConVarChange(hConVar, CVars_Replicate);
		}
	}
	
	while (FindNextConCommand(f_hConCommand, f_sName, sizeof(f_sName), f_bIsCommand, f_iFlags));
	
	CloseHandle(f_hConCommand);
	
	// Register Admin Commands
	RegAdminCmd("kacr_addcvar", CVars_CmdAddCVar, ADMFLAG_ROOT, "Adds a CVar to the Checklist");
	RegAdminCmd("kacr_removecvar", CVars_CmdRemCVar, ADMFLAG_ROOT, "Removes a CVar from the Checklist");
	RegAdminCmd("kacr_cvars_status", CVars_CmdStatus, ADMFLAG_GENERIC, "Shows the Status of all in-game Clients");
	
	if (g_bCVarsEnabled)
		g_iCVarsStatus = Status_Register(KACR_CVARS, KACR_ON);
		
	else
		g_iCVarsStatus = Status_Register(KACR_CVARS, KACR_OFF);
}


//- Client Commands -//

public void CVars_OnClientDisconnect(client)
{
	Handle hTemp;
	
	g_iCurrentIndex[client] = 0;
	g_iRetryAttempts[client] = 0;
	
	hTemp = g_hPeriodicTimer[client];
	if (hTemp != INVALID_HANDLE)
	{
		g_hPeriodicTimer[client] = INVALID_HANDLE;
		CloseHandle(hTemp);
	}
	
	hTemp = g_hReplyTimer[client];
	if (hTemp != INVALID_HANDLE)
	{
		g_hReplyTimer[client] = INVALID_HANDLE;
		CloseHandle(hTemp);
	}
}


//- Admin Commands -//

public Action CVars_CmdStatus(iCmdCaller, args)
{
	if (iCmdCaller && !IsClientInGame(iCmdCaller))
		return Plugin_Handled;
		
	Handle hTemp;
	char cIP[64], cCVarName[64];
	
	for (int iClients = 1; iClients <= MaxClients; iClients++)
	if (g_bInGame[iClients])
	{
		GetClientIP(iClients, cIP, sizeof(cIP));
		hTemp = g_hCurrentQuery[iClients];
		if (hTemp == INVALID_HANDLE)
		{
			if (g_hPeriodicTimer[iClients] == INVALID_HANDLE)
			{
				KACR_Log(false, "[Warning] '%L'<%s> doesn't have a periodic Timer running and no active Queries", iClients, cIP);
				ReplyToCommand(iCmdCaller, "[Kigen AC Redux] '%L'<%s> dosen't have a periodic Timer running nor active Queries", iClients, cIP);
				g_hPeriodicTimer[iClients] = CreateTimer(0.1, CVars_PeriodicTimer, iClients);
				continue;
			}
			
			ReplyToCommand(iCmdCaller, "[Kigen AC Redux] '%L'<%s> is waiting for a new Query. Current Index: %d", iClients, cIP, g_iCurrentIndex[iClients]);
		}
		
		else
		{
			GetArrayString(hTemp, CELL_NAME, cCVarName, sizeof(cCVarName));
			ReplyToCommand(iCmdCaller, "[Kigen AC Redux] '%L'<%s> has active Query on %s. Current Index: %d. Retry Attempts: %d", iClients, cIP, cCVarName, g_iCurrentIndex[iClients], g_iRetryAttempts[iClients]);
		}
	}
	
	return Plugin_Handled;
}

public Action CVars_CmdAddCVar(client, args)
{
	if (args != 4 && args != 5)
	{
		KACR_ReplyToCommand(client, KACR_ADDCVARUSAGE);
		return Plugin_Handled;
	}
	
	char cCVarName[64], f_sTemp[64], cValue[64], cIP[64];
	int iCompType, iAction;
	float fValue2;
	
	GetCmdArg(1, cCVarName, sizeof(cCVarName));
	
	GetCmdArg(2, f_sTemp, sizeof(f_sTemp));
	
	if (StrEqual(f_sTemp, "=") || StrEqual(f_sTemp, "equal"))
		iCompType = COMP_EQUAL;
		
	else if (StrEqual(f_sTemp, "<") || StrEqual(f_sTemp, "greater"))
		iCompType = COMP_GREATER;
		
	else if (StrEqual(f_sTemp, ">") || StrEqual(f_sTemp, "less"))
		iCompType = COMP_LESS;
		
	else if (StrEqual(f_sTemp, "bound") || StrEqual(f_sTemp, "between"))
		iCompType = COMP_BOUND;
		
	else if (StrEqual(f_sTemp, "strequal"))
		iCompType = COMP_STRING;
		
	else
	{
		KACR_ReplyToCommand(client, KACR_ADDCVARBADCOMP, f_sTemp);
		return Plugin_Handled;
	}
	
	if (iCompType == COMP_BOUND && args < 5)
	{
		KACR_ReplyToCommand(client, KACR_ADDCVARBADBOUND);
		return Plugin_Handled;
	}
	
	GetCmdArg(3, f_sTemp, sizeof(f_sTemp));
	
	if (StrEqual(f_sTemp, "warn"))
		iAction = ACTION_WARN;
		
	else if (StrEqual(f_sTemp, "motd"))
		iAction = ACTION_MOTD;
		
	else if (StrEqual(f_sTemp, "mute"))
		iAction = ACTION_MUTE;
		
	else if (StrEqual(f_sTemp, "kick"))
		iAction = ACTION_KICK;
		
	else if (StrEqual(f_sTemp, "ban"))
		iAction = ACTION_BAN;
		
	else
	{
		KACR_ReplyToCommand(client, KACR_ADDCVARBADACT, f_sTemp);
		return Plugin_Handled;
	}
	
	GetCmdArg(4, cValue, sizeof(cValue));
	
	if (iCompType == COMP_BOUND)
	{
		GetCmdArg(5, f_sTemp, sizeof(f_sTemp));
		fValue2 = StringToFloat(f_sTemp);
	}
	
	if (CVars_AddCVar(cCVarName, iCompType, iAction, cValue, fValue2, PRIORITY_NORMAL))
	{
		if (client)
		{
			GetClientIP(client, cIP, sizeof(cIP));
			KACR_Log(false, "'%L'<%s> added Convar %s to the Check List", client, cIP, cCVarName);
		}
		
		KACR_ReplyToCommand(client, KACR_ADDCVARSUCCESS, cCVarName);
	}
	
	else
		KACR_ReplyToCommand(client, KACR_ADDCVARFAILED, cCVarName);
		
	return Plugin_Handled;
}

public Action CVars_CmdRemCVar(iClient, args)
{
	if (args != 1)
	{
		KACR_ReplyToCommand(iClient, KACR_REMCVARUSAGE);
		return Plugin_Handled;
	}
	
	char cCVarName[64];
	
	GetCmdArg(1, cCVarName, sizeof(cCVarName));
	
	if (CVars_RemoveCVar(cCVarName))
	{
		if (iClient)
		{
			char cIP[64];
			GetClientIP(iClient, cIP, sizeof(cIP));
			KACR_Log(false, "'%L'<%s> removed Convar '%s' from the Check List.", iClient, cIP, cCVarName);
		}
		
		else
			KACR_Log(false, "The Console removed Convar %s from the Check List.", cCVarName);
			
		KACR_ReplyToCommand(iClient, KACR_REMCVARSUCCESS, cCVarName);
	}
	
	else
		KACR_ReplyToCommand(iClient, KACR_REMCVARFAILED, cCVarName);
		
	return Plugin_Handled;
}


//- Timers -//

public Action CVars_PeriodicTimer(Handle timer, any client)
{
	if (g_hPeriodicTimer[client] == INVALID_HANDLE)
		return Plugin_Stop;
		
	if (!g_bCVarsEnabled)
	{
		g_hPeriodicTimer[client] = CreateTimer(60.0, CVars_PeriodicTimer, client);
		return Plugin_Stop;
	}
	
	g_hPeriodicTimer[client] = INVALID_HANDLE;
	
	if (!g_bConnected[client])
		return Plugin_Stop;
		
	char f_sName[64];
	Handle f_hCVar;
	int f_iIndex;
	
	if (g_iSize < 1)
	{
		KACR_Log(false, "[Warning] Nothing in the ConVar List")
		CreateTimer(10.0, CVars_PeriodicTimer, client);
		return Plugin_Stop;
	}
	
	f_iIndex = g_iCurrentIndex[client]++;
	if (f_iIndex >= g_iSize)
	{
		f_iIndex = 0;
		g_iCurrentIndex[client] = 1;
	}
	
	f_hCVar = GetArrayCell(g_hConVarArray, f_iIndex);
	
	if (GetArrayCell(f_hCVar, CELL_CHANGED) == INVALID_HANDLE)
	{
		GetArrayString(f_hCVar, 0, f_sName, sizeof(f_sName));
		g_hCurrentQuery[client] = f_hCVar;
		QueryClientConVar(client, f_sName, CVars_QueryCallback, client);
		g_hReplyTimer[client] = CreateTimer(30.0, CVars_ReplyTimer, GetClientUserId(client)); // We'll wait 30 seconds for a reply.
	}
	
	else
		g_hPeriodicTimer[client] = CreateTimer(0.1, CVars_PeriodicTimer, client);
		
	return Plugin_Stop;
}

public Action CVars_ReplyTimer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client < 1 || g_hReplyTimer[client] == INVALID_HANDLE)
		return Plugin_Stop;
		
	g_hReplyTimer[client] = INVALID_HANDLE;
	if (!g_bCVarsEnabled || !g_bConnected[client] || g_hPeriodicTimer[client] != INVALID_HANDLE)
		return Plugin_Stop;
		
	if (g_iRetryAttempts[client]++ > 3)
		KACR_Kick(client, KACR_FAILEDTOREPLY);
		
	else
	{
		char f_sName[64];
		Handle f_hCVar;
		
		if (g_iSize < 1)
		{
			KACR_Log(false, "[Warning] Nothing in the ConVar List")
			CreateTimer(10.0, CVars_PeriodicTimer, client);
			return Plugin_Stop;
		}
		
		f_hCVar = g_hCurrentQuery[client];
		
		if (GetArrayCell(f_hCVar, CELL_CHANGED) == INVALID_HANDLE)
		{
			GetArrayString(f_hCVar, 0, f_sName, sizeof(f_sName));
			QueryClientConVar(client, f_sName, CVars_QueryCallback, client);
			g_hReplyTimer[client] = CreateTimer(15.0, CVars_ReplyTimer, GetClientUserId(client)); // We'll wait 15 seconds for a reply.
		}
		
		else
			g_hPeriodicTimer[client] = CreateTimer(0.1, CVars_PeriodicTimer, client);
	}
	
	return Plugin_Stop;
}

public void CVars_ReplicateTimer(any hConVar)
{
	char f_sName[64];
	
	GetConVarName(hConVar, f_sName, sizeof(f_sName));
	if (g_bCVarsEnabled && StrEqual(f_sName, "sv_cheats") && GetConVarInt(hConVar) != 0) // TODO: This does not belong here #43
		SetConVarInt(hConVar, 0);
		
	CVars_ReplicateConVar(hConVar);
}

public Action CVars_ReplicateCheck(Handle timer, any hIndex)
{
	SetArrayCell(hIndex, CELL_CHANGED, INVALID_HANDLE);
	return Plugin_Stop;
}


//- ConVar Query Reply -//

public void CVars_QueryCallback(QueryCookie cookie, client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (!g_bConnected[client])
		return;
		
	if (!g_bCVarsEnabled)
	{
		if (g_hPeriodicTimer[client] == INVALID_HANDLE)
			g_hPeriodicTimer[client] = CreateTimer(60.0, CVars_PeriodicTimer, client);
			
		return;
	}
	
	char cCVarName[64], cIP[64], cValue[64], cAlternative[128];
	Handle hConVar, hTemp;
	int iCompType, iAction, iSize;
	float fValue2;
	bool bContinue;
	
	GetClientIP(client, cIP, sizeof(cIP));
	
	if (g_hPeriodicTimer[client] != INVALID_HANDLE)
		bContinue = false;
		
	else
		bContinue = true;
		
	hConVar = g_hCurrentQuery[client];
	
	// We weren't expecting a reply or convar we queried is no longer valid and we cannot find it.
	if (hConVar == INVALID_HANDLE && !g_hCVar_Index.GetValue(cvarName, hConVar))
	{
		if (g_hPeriodicTimer[client] == INVALID_HANDLE) // Client doesn't have active query or a timer active for them?  Ballocks!
			g_hPeriodicTimer[client] = CreateTimer(GetRandomFloat(0.5, 2.0), CVars_PeriodicTimer, client);
			
		return;
	}
	
	GetArrayString(hConVar, CELL_NAME, cCVarName, sizeof(cCVarName));
	
	// Make sure this query replied correctly.
	if (!StrEqual(cvarName, cCVarName)) // CVar not expected.
	{
		if (!g_hCVar_Index.GetValue(cvarName, hConVar)) // CVar doesn't exist in our list.
		{
			KACR_Log(false, "Unknown CVar Reply: '%L'<%s> was kicked for a corrupted Return with Convar Name \"%s\" (expecting \"%s\") with Value \"%s\".", client, cIP, cvarName, cCVarName, cvarValue);
			KACR_Kick(client, KACR_CLIENTCORRUPT);
			return;
		}
		
		else
			bContinue = false;
			
		GetArrayString(hConVar, CELL_NAME, cCVarName, sizeof(cCVarName));
	}
	
	iCompType = GetArrayCell(hConVar, CELL_COMPTYPE);
	iAction = GetArrayCell(hConVar, CELL_ACTION);
	
	if (bContinue)
	{
		hTemp = g_hReplyTimer[client];
		g_hCurrentQuery[client] = INVALID_HANDLE;
		
		if (hTemp != INVALID_HANDLE)
		{
			g_hReplyTimer[client] = INVALID_HANDLE;
			CloseHandle(hTemp);
			g_iRetryAttempts[client] = 0;
		}
	}
	
	// Check if it should exist.
	if (iCompType == COMP_NONEXIST)
	{
		if (result != ConVarQuery_NotFound)
		{
			switch (iAction)
			{
				case ACTION_WARN:
					KACR_PrintToChatAdmins(KACR_HASPLUGIN, client, cIP, cCVarName);
					
				case ACTION_MOTD:
				{
					GetArrayString(hConVar, CELL_ALT, cAlternative, sizeof(cAlternative));
					ShowMOTDPanel(client, "", cAlternative);
				}
				
				case ACTION_MUTE:
				{
					KACR_PrintToChatAll(KACR_MUTED, client);
					ServerCommand("sm_mute #%d", GetClientUserId(client));
				}
				
				case ACTION_KICK:
				{
					KACR_Log(false, "Plugin CVar return: '%L'<%s> was kicked for returning with Plugin ConVar \"%s\" (Value \"%s\", return %s)", client, cIP, cvarName, cvarValue, g_cQueryResult[result]);
					KACR_Kick(client, KACR_REMOVEPLUGINS);
					return;
				}
				
				case ACTION_BAN:
				{
					KACR_Log(false, "Bad CVar return: '%L'<%s> has ConVar \"%s\" (Value \"%s\", return %s) when it shouldn't exist.", client, cIP, cvarName, cvarValue, g_cQueryResult[result]);
					KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar %s Violation", cvarName);
					
					return;
				}
			}
		}
		
		if (bContinue)
			g_hPeriodicTimer[client] = CreateTimer(GetRandomFloat(1.0, 3.0), CVars_PeriodicTimer, client);
			
		return;
	}
	
	if (result != ConVarQuery_Okay) // ConVar should exist. // TODO: Add an CVar to decide
	{
		KACR_Log(false, "Bad CVar Query Result: '%L'<%s> returned Query Result \"%s\" (expected Okay) on ConVar \"%s\" (Value \"%s\").", client, cIP, g_cQueryResult[result], cvarName, cvarValue);
		KickClient(client, "KACR: '%s' Violation (bad Query Result).", cvarName); // TODO: Add Translation
		// KACR_Ban(client, 0, KACR_BANNED, "KACR: '%s' Violation (bad Query Result).", cvarName);
		
		return;
	}
	
	// Check if the ConVar was recently changed.
	if (GetArrayCell(hConVar, CELL_CHANGED) != INVALID_HANDLE)
	{
		g_hPeriodicTimer[client] = CreateTimer(GetRandomFloat(1.0, 3.0), CVars_PeriodicTimer, client);
		return;
	}
	
	hTemp = GetArrayCell(hConVar, CELL_HANDLE);
	if (hTemp == INVALID_HANDLE || iCompType != COMP_EQUAL)
		GetArrayString(hConVar, CELL_VALUE, cValue, sizeof(cValue));
		
	else
		GetConVarString(hTemp, cValue, sizeof(cValue));
		
	if (iCompType == COMP_BOUND)
		fValue2 = GetArrayCell(hConVar, CELL_VALUE2);
		
	if (iCompType != COMP_STRING)
	{
		iSize = strlen(cvarValue);
		for (int i = 0; i < iSize; i++)
			if (!IsCharNumeric(cvarValue[i]) && cvarValue[i] != '.')
			{
				KACR_Log(false, "Corrupted CVar Response: '%L'<%s> was kicked for returning a corrupted Value on '%s' (%s), Value set at \"%s\" (expected \"%s\").", client, cIP, cCVarName, cvarName, cvarValue, cValue);
				KACR_Kick(client, KACR_CLIENTCORRUPT);
				return;
			}
	}
	
	
	switch (iCompType)
	{
		case COMP_EQUAL:
		{
			if (StringToFloat(cValue) != StringToFloat(cvarValue))
			{
				switch (iAction)
				{
					case ACTION_WARN:
						KACR_PrintToChatAdmins(KACR_HASNOTEQUAL, client, cIP, cCVarName, cvarValue, cValue);
						
					case ACTION_MOTD:
					{
						GetArrayString(hConVar, CELL_ALT, cAlternative, sizeof(cAlternative));
						ShowMOTDPanel(client, "", cAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be \"%s\"", client, cIP, cvarName, cvarValue, cValue);
						KACR_Kick(client, KACR_SHOULDEQUAL, cvarName, cValue, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> has ConVar \"%s\" set to Value \"%s\" (should be \"%s\") when it should equal", client, cIP, cvarName, cvarValue, cValue);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar %s Violation", cvarName);
						
						return;
					}
				}
			}
		}
		
		case COMP_GREATER:
		{
			if (StringToFloat(cValue) > StringToFloat(cvarValue))
			{
				switch (iAction)
				{
					case ACTION_WARN:
						KACR_PrintToChatAdmins(KACR_HASNOTGREATER, client, cIP, cCVarName, cvarValue, cValue);
						
					case ACTION_MOTD:
					{
						GetArrayString(hConVar, CELL_ALT, cAlternative, sizeof(cAlternative));
						ShowMOTDPanel(client, "", cAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be greater than or equal to \"%s\"", client, cIP, cvarName, cvarValue, cValue);
						KACR_Kick(client, KACR_SHOULDGREATER, cvarName, cValue, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> has ConVar \"%s\" set to Value \"%s\" (should be \"%s\") when it should greater than or equal to", client, cIP, cvarName, cvarValue, cValue);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar %s Violation", cvarName);
						
						return;
					}
				}
			}
		}
		
		case COMP_LESS:
		{
			if (StringToFloat(cValue) < StringToFloat(cvarValue))
			{
				switch (iAction)
				{
					case ACTION_WARN:
						KACR_PrintToChatAdmins(KACR_HASNOTLESS, client, cIP, cCVarName, cvarValue, cValue);
						
					case ACTION_MOTD:
					{
						GetArrayString(hConVar, CELL_ALT, cAlternative, sizeof(cAlternative));
						ShowMOTDPanel(client, "", cAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be less than or equal to \"%s\"", client, cIP, cvarName, cvarValue, cValue);
						KACR_Kick(client, KACR_SHOULDLESS, cvarName, cValue, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> has Convar \"%s\" set to Value \"%s\" (should be \"%s\") when it should be less than or equal to", client, cIP, cvarName, cvarValue, cValue);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar '%s' Violation", cvarName);
						
						return;
					}
				}
			}
		}
		
		case COMP_BOUND:
		{
			if (StringToFloat(cValue) >= StringToFloat(cvarValue) && fValue2 <= StringToFloat(cvarValue))
			{
				switch (iAction)
				{
					case ACTION_WARN:
						KACR_PrintToChatAdmins(KACR_HASNOTBOUND, client, cIP, cCVarName, cvarValue, cValue, fValue2);
						
					case ACTION_MOTD:
					{
						GetArrayString(hConVar, CELL_ALT, cAlternative, sizeof(cAlternative));
						ShowMOTDPanel(client, "", cAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be between \"%s\" and \"%f\"", client, cIP, cvarName, cvarValue, cValue, fValue2);
						KACR_Kick(client, KACR_SHOULDBOUND, cvarName, cValue, fValue2, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> has ConVar \"%s\" set to Value \"%s\" when it should be between \"%s\" and \"%f\"", client, cIP, cvarName, cvarValue, cValue, fValue2);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar '%s' Violation", cvarName);
						
						return;
					}
				}
			}
		}
		
		case COMP_STRING:
		{
			if (!StrEqual(cValue, cvarValue))
			{
				switch (iAction)
				{
					case ACTION_WARN:
						KACR_PrintToChatAdmins(KACR_HASNOTEQUAL, client, cIP, cCVarName, cvarValue, cValue);
						
					case ACTION_MOTD:
					{
						GetArrayString(hConVar, CELL_ALT, cAlternative, sizeof(cAlternative));
						ShowMOTDPanel(client, "", cAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be \"%s\"", client, cIP, cvarName, cvarValue, cValue);
						KACR_Kick(client, KACR_SHOULDEQUAL, cvarName, cValue, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log(false, "Bad CVar Response: '%L'<%s> has ConVar \"%s\" set to Value \"%s\" (should be \"%s\") when it should equal", client, cIP, cvarName, cvarValue, cValue);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar '%s' Violation", cvarName);
						
						return;
					}
				}
			}
		}
	}
	
	if (bContinue)
		g_hPeriodicTimer[client] = CreateTimer(GetRandomFloat(0.5, 2.0), CVars_PeriodicTimer, client);
}


//- Hook -//

public void CVars_Replicate(Handle convar, const char[] oldvalue, const char[] newvalue)
{
	Handle f_hCVarIndex, f_hTimer;
	char f_sName[64];
	GetConVarName(convar, f_sName, sizeof(f_sName));
	if (g_hCVar_Index.GetValue(f_sName, f_hCVarIndex))
	{
		f_hTimer = GetArrayCell(f_hCVarIndex, CELL_CHANGED);
		if (f_hTimer != INVALID_HANDLE)
			CloseHandle(f_hTimer);
			
		f_hTimer = CreateTimer(30.0, CVars_ReplicateCheck, f_hCVarIndex);
		SetArrayCell(f_hCVarIndex, CELL_CHANGED, f_hTimer);
	}
	
	RequestFrame(CVars_ReplicateTimer, convar); // CreateTimer(0.1, CVars_ReplicateTimer, convar); // The delay is so that nothing interferes with the replication
}

public void ConVarChanged_CVars_Enable(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bCVarsEnabled = GetConVarBool(convar);
	if (g_bCVarsEnabled)
		Status_Report(g_iCVarsStatus, KACR_ON);
		
	else
		Status_Report(g_iCVarsStatus, KACR_OFF);
}


//- Private Functions -//

/*
* Adds an Cvar to the Checklist
* 
* @param cCvar				Cvar to check for
* @param iComparisonType	How to compare (COMP_...)
* @param iAction			What todo when detected
* @param cValue			Allowed Value Range
* @param fValue2			Allowed Value Range
* @param iImportance		Priority (PRIORITY_...)
* @param cAlternative		URL to show to the Player
*/
bool CVars_AddCVar(char[] f_sName, f_iComparisonType, iAction, const char[] cValue, float fValue2, f_iImportance, const char cAlternative[] = "")
{
	Handle hConVar, hArray;
	
	hConVar = FindConVar(f_sName);
	if (hConVar != INVALID_HANDLE && (GetConVarFlags(hConVar) & FCVAR_REPLICATED) && (f_iComparisonType == COMP_EQUAL || f_iComparisonType == COMP_STRING))
		f_iComparisonType = COMP_EQUAL;
		
	else
		hConVar = INVALID_HANDLE;
		
	if (g_hCVar_Index.GetValue(f_sName, hArray)) // Check if CVar check already exists.
	{
		SetArrayString(hArray, CELL_NAME, f_sName); // Name			0
		SetArrayCell(hArray, CELL_COMPTYPE, f_iComparisonType); // Comparison Type	1
		SetArrayCell(hArray, CELL_HANDLE, hConVar); // CVar Handle		2
		SetArrayCell(hArray, CELL_ACTION, iAction); // Action Type		3
		SetArrayString(hArray, CELL_VALUE, cValue); // Value		4
		SetArrayCell(hArray, CELL_VALUE2, fValue2); // Value2		5
		SetArrayString(hArray, CELL_ALT, cAlternative); // Alternative Info	6
		// We will not change the priority.
		// Nor will we change the "changed" cell either.
	}
	
	else
	{
		hArray = CreateArray(64);
		PushArrayString(hArray, f_sName); // Name			0
		PushArrayCell(hArray, f_iComparisonType); // Comparison Type	1
		PushArrayCell(hArray, hConVar); // CVar Handle		2
		PushArrayCell(hArray, iAction); // Action Type		3
		PushArrayString(hArray, cValue); // Value		4
		PushArrayCell(hArray, fValue2); // Value2		5
		PushArrayString(hArray, cAlternative); // Alternative Info	6
		PushArrayCell(hArray, f_iImportance); // Importance		7
		PushArrayCell(hArray, INVALID_HANDLE); // Changed		8
		
		if (!g_hCVar_Index.SetValue(f_sName, hArray))
		{
			CloseHandle(hArray);
			KACR_Log(false, "[Error] Unable to add ConVar to Hashmap Link List '%s'", f_sName);
			return false;
		}
		
		PushArrayCell(g_hConVarArray, hArray);
		g_iSize = GetArraySize(g_hConVarArray);
		
		if (f_iImportance != PRIORITY_NORMAL && g_bMapStarted)
			CVars_CreateNewOrder();
	}
	
	return true;
}

stock bool CVars_RemoveCVar(char[] f_sName)
{
	Handle hConVar;
	int f_iIndex;
	
	if (!g_hCVar_Index.GetValue(f_sName, hConVar))
		return false;
		
	f_iIndex = FindValueInArray(g_hConVarArray, hConVar);
	if (f_iIndex == -1)
		return false;
		
	for (int i = 0; i <= MaxClients; i++)
	if (g_hCurrentQuery[i] == hConVar)
		g_hCurrentQuery[i] = INVALID_HANDLE;
		
	RemoveFromArray(g_hConVarArray, f_iIndex);
	g_hCVar_Index.Remove(f_sName);
	CloseHandle(hConVar);
	g_iSize = GetArraySize(g_hConVarArray);
	
	return true;
}

stock CVars_CreateNewOrder()
{
	Handle f_hPHigh, f_hPMedium, f_hPNormal, f_hCurrent;
	new Handle:f_hOrder[g_iSize]; // TODO: IDK how to convert this to the new syntax
	int f_iHigh, f_iMedium, f_iNormal, f_iTemp, f_iCurrent;
	
	f_hPHigh = CreateArray(64);
	f_hPMedium = CreateArray(64);
	f_hPNormal = CreateArray(64);
	
	// Get priorities.
	for (int i = 0; i < g_iSize; i++)
	{
		f_hCurrent = GetArrayCell(g_hConVarArray, i);
		f_iTemp = GetArrayCell(f_hCurrent, CELL_PRIORITY);
		if (f_iTemp == PRIORITY_NORMAL)
			PushArrayCell(f_hPNormal, f_hCurrent);
			
		else if (f_iTemp == PRIORITY_MEDIUM)
			PushArrayCell(f_hPMedium, f_hCurrent);
			
		else if (f_iTemp == PRIORITY_HIGH)
			PushArrayCell(f_hPHigh, f_hCurrent);
	}
	
	f_iHigh = GetArraySize(f_hPHigh) - 1;
	f_iMedium = GetArraySize(f_hPMedium) - 1;
	f_iNormal = GetArraySize(f_hPNormal) - 1;
	
	// Start randomizing!
	while (f_iHigh > -1)
	{
		f_iTemp = GetRandomInt(0, f_iHigh);
		f_hOrder[f_iCurrent++] = GetArrayCell(f_hPHigh, f_iTemp);
		RemoveFromArray(f_hPHigh, f_iTemp);
		f_iHigh--;
	}
	
	while (f_iMedium > -1)
	{
		f_iTemp = GetRandomInt(0, f_iMedium);
		f_hOrder[f_iCurrent++] = GetArrayCell(f_hPMedium, f_iTemp);
		RemoveFromArray(f_hPMedium, f_iTemp);
		f_iMedium--;
	}
	
	while (f_iNormal > -1)
	{
		f_iTemp = GetRandomInt(0, f_iNormal);
		f_hOrder[f_iCurrent++] = GetArrayCell(f_hPNormal, f_iTemp);
		RemoveFromArray(f_hPNormal, f_iTemp);
		f_iNormal--;
	}
	
	ClearArray(g_hConVarArray);
	
	for (int i = 0; i < g_iSize; i++)
		PushArrayCell(g_hConVarArray, f_hOrder[i]);
		
	CloseHandle(f_hPHigh);
	CloseHandle(f_hPMedium);
	CloseHandle(f_hPNormal);
}

stock CVars_ReplicateConVar(Handle hConVar)
{
	char cCVarName[64], cValue[64];
	GetConVarName(hConVar, cCVarName, sizeof(cCVarName));
	GetConVarString(hConVar, cValue, sizeof(cValue));
	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_bConnected[i])
		{
			if (!IsClientConnected(i) || IsFakeClient(i))
				OnClientDisconnect(i);
				
			else if (!SendConVarValue(i, hConVar, cValue))
				continue; // KACR_Log(false, "'%L' failed to accept replication of '%s' (Value: %s)", i, cCVarName, cValue); // This happens if the netchan isn't created yet, cvars will replicate once it is created.
		}
	}
}