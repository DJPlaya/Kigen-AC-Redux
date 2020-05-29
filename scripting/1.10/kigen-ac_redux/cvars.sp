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

#define CVARS

// Array Index Documentation
// Arrays that come from g_hCVars are index like below.
// 1. CVar Name
// 2. Comparison Type
// 3. CVar Handle - If this is defined then the engine will ignore the Comparison Type and Values as this should be only for FCVAR_REPLICATED CVars.
// 4. Action Type - Determines what action the engine takes.
// 5. Value - The value that the cvar is expected to have.
// 6. Value 2 - Only used as the high bound for COMP_BOUND.
// 7. Important - Defines the importance of the CVar in the ordering of the checks.
// 8. Was Changed - Defines if this CVar was changed recently.


//- Global CVARS Defines -//

#define CELL_NAME	0
#define CELL_COMPTYPE	1
#define CELL_HANDLE	2
#define CELL_ACTION	3
#define CELL_VALUE	4
#define CELL_VALUE2	5
#define CELL_ALT	6
#define CELL_PRIORITY	7
#define CELL_CHANGED	8

#define ACTION_WARN	0 // Warn Admins
#define ACTION_MOTD	1 // Display MOTD with Alternate URL
#define ACTION_MUTE	2 // Mute the player.
#define ACTION_KICK	3 // Kick the player.
#define ACTION_BAN	4 // Ban the player.

#define COMP_EQUAL	0 // CVar should equal
#define COMP_GREATER	1 // CVar should be equal to or greater than
#define COMP_LESS	2 // CVar should be equal to or less than
#define COMP_BOUND	3 // CVar should be in-between two numbers.
#define COMP_STRING	4 // Cvar should string equal.
#define COMP_NONEXIST	5 // CVar shouldn't exist.

#define PRIORITY_NORMAL	0
#define PRIORITY_MEDIUM	1
#define PRIORITY_HIGH	3


//- Global CVARS Variables -//

Handle g_hCVarCVarsEnabled, g_hCVars;
Handle g_hCurrentQuery[MAXPLAYERS + 1], g_hReplyTimer[MAXPLAYERS + 1], g_hPeriodicTimer[MAXPLAYERS + 1];
StringMap g_hCVarIndex;

char g_sQueryResult[][] =  { "Okay", "Not found", "Not valid", "Protected" };

int g_iCurrentIndex[MAXPLAYERS + 1] =  { 0, ... }, g_iRetryAttempts[MAXPLAYERS + 1] =  { 0, ... };
int g_iSize = 0, g_iCVarsStatus;

bool g_bCVarsEnabled = true;


//- Plugin Functions -//

CVars_OnPluginStart()
{
	Handle f_hConCommand, f_hConVar;
	char cConVar[64];
	bool f_bIsCommand;
	int f_iFlags;
	
	g_hCVarCVarsEnabled = AutoExecConfig_CreateConVar("kacr_cvars_enable", "1", "Enable the CVar checking Module", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bCVarsEnabled = GetConVarBool(g_hCVarCVarsEnabled);
	
	HookConVarChange(g_hCVarCVarsEnabled, CVars_EnableChange);
	
	g_hCVars = CreateArray(64);
	g_hCVarIndex = new StringMap();
	
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
	
	if (hGame != Engine_CSGO)
		CVars_AddCVar("cl_particle_show_bbox", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
		
	else
		CVars_AddCVar("cl_particles_show_bbox", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
		
	CVars_AddCVar("cl_phys_timescale", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
	CVars_AddCVar("cl_showevents", COMP_EQUAL, ACTION_BAN, "0.0", 0.0, PRIORITY_NORMAL);
	
	if (hGame != Engine_Insurgency)
		CVars_AddCVar("fog_enable", COMP_EQUAL, ACTION_BAN, "1.0", 0.0, PRIORITY_NORMAL);
		
	else
		CVars_AddCVar("fog_enable", COMP_EQUAL, ACTION_KICK, "1.0", 0.0, PRIORITY_NORMAL);
		
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
	
	f_hConCommand = FindFirstConCommand(cConVar, sizeof(cConVar), f_bIsCommand, f_iFlags);
	if (f_hConCommand == INVALID_HANDLE)
		SetFailState("Failed getting first ConVar");
		
	do
	{
		if (!f_bIsCommand && (f_iFlags & FCVAR_REPLICATED))
		{
			f_hConVar = FindConVar(cConVar);
			if (f_hConVar == INVALID_HANDLE)
				continue;
				
			CVars_ReplicateConVar(f_hConVar);
			HookConVarChange(f_hConVar, CVars_Replicate);
		}
	}
	
	while (FindNextConCommand(f_hConCommand, cConVar, sizeof(cConVar), f_bIsCommand, f_iFlags));
	
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

CVars_OnClientDisconnect(client)
{
	Handle f_hTemp;
	
	g_iCurrentIndex[client] = 0;
	g_iRetryAttempts[client] = 0;
	
	f_hTemp = g_hPeriodicTimer[client];
	if (f_hTemp != INVALID_HANDLE)
	{
		g_hPeriodicTimer[client] = INVALID_HANDLE;
		CloseHandle(f_hTemp);
	}
	
	f_hTemp = g_hReplyTimer[client];
	if (f_hTemp != INVALID_HANDLE)
	{
		g_hReplyTimer[client] = INVALID_HANDLE;
		CloseHandle(f_hTemp);
	}
}


//- Admin Commands -//

public Action CVars_CmdStatus(iCmdCaller, args)
{
	if (iCmdCaller && !IsClientInGame(iCmdCaller))
		return Plugin_Handled;
		
	Handle f_hTemp;
	char f_sIP[64], f_sCVarName[64];
	
	for (int iClients = 1; iClients <= MaxClients; iClients++)
	if (g_bInGame[iClients])
	{
		GetClientIP(iClients, f_sIP, sizeof(f_sIP));
		f_hTemp = g_hCurrentQuery[iClients];
		if (f_hTemp == INVALID_HANDLE)
		{
			if (g_hPeriodicTimer[iClients] == INVALID_HANDLE)
			{
				KACR_Log("[Error] '%L'<%s> doesn't have a periodic Timer running and no active Queries", iClients, f_sIP);
				ReplyToCommand(iCmdCaller, "[Error][Kigen-AC_Redux] '%L'<%s> didn't have a periodic Timer running nor active Queries", iClients, f_sIP);
				g_hPeriodicTimer[iClients] = CreateTimer(0.1, CVars_PeriodicTimer, iClients);
				continue;
			}
			
			ReplyToCommand(iCmdCaller, "[Kigen-AC_Redux] '%L'<%s> is waiting for a new Query. Current Index: %d", iClients, f_sIP, g_iCurrentIndex[iClients]);
		}
		
		else
		{
			GetArrayString(f_hTemp, CELL_NAME, f_sCVarName, sizeof(f_sCVarName));
			ReplyToCommand(iCmdCaller, "[Kigen-AC_Redux] '%L'<%s> has active Query on %s. Current Index: %d. Retry Attempts: %d", iClients, f_sIP, f_sCVarName, g_iCurrentIndex[iClients], g_iRetryAttempts[iClients]);
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
	
	char f_sCVarName[64], f_sTemp[64], f_sValue[64], f_sIP[64];
	int f_iCompType, f_iAction;
	float f_fValue2;
	
	GetCmdArg(1, f_sCVarName, sizeof(f_sCVarName));
	
	GetCmdArg(2, f_sTemp, sizeof(f_sTemp));
	
	if (StrEqual(f_sTemp, "=") || StrEqual(f_sTemp, "equal"))
		f_iCompType = COMP_EQUAL;
		
	else if (StrEqual(f_sTemp, "<") || StrEqual(f_sTemp, "greater"))
		f_iCompType = COMP_GREATER;
		
	else if (StrEqual(f_sTemp, ">") || StrEqual(f_sTemp, "less"))
		f_iCompType = COMP_LESS;
		
	else if (StrEqual(f_sTemp, "bound") || StrEqual(f_sTemp, "between"))
		f_iCompType = COMP_BOUND;
		
	else if (StrEqual(f_sTemp, "strequal"))
		f_iCompType = COMP_STRING;
		
	else
	{
		KACR_ReplyToCommand(client, KACR_ADDCVARBADCOMP, f_sTemp);
		return Plugin_Handled;
	}
	
	if (f_iCompType == COMP_BOUND && args < 5)
	{
		KACR_ReplyToCommand(client, KACR_ADDCVARBADBOUND);
		return Plugin_Handled;
	}
	
	GetCmdArg(3, f_sTemp, sizeof(f_sTemp));
	
	if (StrEqual(f_sTemp, "warn"))
		f_iAction = ACTION_WARN;
		
	else if (StrEqual(f_sTemp, "motd"))
		f_iAction = ACTION_MOTD;
		
	else if (StrEqual(f_sTemp, "mute"))
		f_iAction = ACTION_MUTE;
		
	else if (StrEqual(f_sTemp, "kick"))
		f_iAction = ACTION_KICK;
		
	else if (StrEqual(f_sTemp, "ban"))
		f_iAction = ACTION_BAN;
		
	else
	{
		KACR_ReplyToCommand(client, KACR_ADDCVARBADACT, f_sTemp);
		return Plugin_Handled;
	}
	
	GetCmdArg(4, f_sValue, sizeof(f_sValue));
	
	if (f_iCompType == COMP_BOUND)
	{
		GetCmdArg(5, f_sTemp, sizeof(f_sTemp));
		f_fValue2 = StringToFloat(f_sTemp);
	}
	
	if (CVars_AddCVar(f_sCVarName, f_iCompType, f_iAction, f_sValue, f_fValue2, PRIORITY_NORMAL))
	{
		if (client)
		{
			GetClientIP(client, f_sIP, sizeof(f_sIP));
			KACR_Log("'%L'<%s> added Convar %s to the Check List", client, f_sIP, f_sCVarName);
		}
		
		KACR_ReplyToCommand(client, KACR_ADDCVARSUCCESS, f_sCVarName);
	}
	
	else
		KACR_ReplyToCommand(client, KACR_ADDCVARFAILED, f_sCVarName);
		
	return Plugin_Handled;
}

public Action CVars_CmdRemCVar(iClient, args)
{
	if (args != 1)
	{
		KACR_ReplyToCommand(iClient, KACR_REMCVARUSAGE);
		return Plugin_Handled;
	}
	
	char f_sCVarName[64];
	
	GetCmdArg(1, f_sCVarName, sizeof(f_sCVarName));
	
	if (CVars_RemoveCVar(f_sCVarName))
	{
		if (iClient)
		{
			char f_sIP[64];
			GetClientIP(iClient, f_sIP, sizeof(f_sIP));
			KACR_Log("'%L'<%s> removed Convar '%s' from the Check List.", iClient, f_sIP, f_sCVarName);
		}
		
		else
			KACR_Log("The Console removed Convar %s from the Check List.", f_sCVarName);
			
		KACR_ReplyToCommand(iClient, KACR_REMCVARSUCCESS, f_sCVarName);
	}
	
	else
		KACR_ReplyToCommand(iClient, KACR_REMCVARFAILED, f_sCVarName);
		
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
		
	char cConVar[64];
	Handle f_hCVar;
	int f_iIndex;
	
	if (g_iSize < 1)
	{
		PrintToServer("[Kigen-AC_Redux] Nothing in Convar List");
		CreateTimer(10.0, CVars_PeriodicTimer, client);
		return Plugin_Stop;
	}
	
	f_iIndex = g_iCurrentIndex[client]++;
	if (f_iIndex >= g_iSize)
	{
		f_iIndex = 0;
		g_iCurrentIndex[client] = 1;
	}
	
	f_hCVar = GetArrayCell(g_hCVars, f_iIndex);
	
	if (GetArrayCell(f_hCVar, CELL_CHANGED) == INVALID_HANDLE)
	{
		GetArrayString(f_hCVar, 0, cConVar, sizeof(cConVar));
		g_hCurrentQuery[client] = f_hCVar;
		QueryClientConVar(client, cConVar, CVars_QueryCallback, client);
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
		char cConVar[64];
		Handle f_hCVar;
		
		if (g_iSize < 1)
		{
			PrintToServer("[Kigen-AC_Redux] Nothing in Convar List");
			CreateTimer(10.0, CVars_PeriodicTimer, client);
			return Plugin_Stop;
		}
		
		f_hCVar = g_hCurrentQuery[client];
		
		if (GetArrayCell(f_hCVar, CELL_CHANGED) == INVALID_HANDLE)
		{
			GetArrayString(f_hCVar, 0, cConVar, sizeof(cConVar));
			QueryClientConVar(client, cConVar, CVars_QueryCallback, client);
			g_hReplyTimer[client] = CreateTimer(15.0, CVars_ReplyTimer, GetClientUserId(client)); // We'll wait 15 seconds for a reply.
		}
		
		else
			g_hPeriodicTimer[client] = CreateTimer(0.1, CVars_PeriodicTimer, client);
	}
	
	return Plugin_Stop;
}

public void CVars_ReplicateTimer(any f_hConVar)
{
	char cConVar[64];
	
	GetConVarName(f_hConVar, cConVar, sizeof(cConVar));
	if (g_bCVarsEnabled && StrEqual(cConVar, "sv_cheats") && GetConVarInt(f_hConVar) != 0)
		SetConVarInt(f_hConVar, 0);
		
	CVars_ReplicateConVar(f_hConVar);
}

public Action CVars_ReplicateCheck(Handle timer, any f_hIndex)
{
	SetArrayCell(f_hIndex, CELL_CHANGED, INVALID_HANDLE);
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
	
	char f_sCVarName[64], f_sIP[64], f_sValue[64], f_sAlternative[128];
	Handle f_hConVar, f_hTemp;
	int f_iCompType, f_iAction, f_iSize;
	float f_fValue2;
	bool f_bContinue;
	
	GetClientIP(client, f_sIP, sizeof(f_sIP));
	
	if (g_hPeriodicTimer[client] != INVALID_HANDLE)
		f_bContinue = false;
		
	else
		f_bContinue = true;
		
	f_hConVar = g_hCurrentQuery[client];
	
	// We weren't expecting a reply or convar we queried is no longer valid and we cannot find it.
	if (f_hConVar == INVALID_HANDLE && !g_hCVarIndex.GetValue(cvarName, f_hConVar))
	{
		if (g_hPeriodicTimer[client] == INVALID_HANDLE) // Client doesn't have active query or a timer active for them?  Ballocks!
			g_hPeriodicTimer[client] = CreateTimer(GetRandomFloat(0.5, 2.0), CVars_PeriodicTimer, client);
			
		return;
	}
	
	GetArrayString(f_hConVar, CELL_NAME, f_sCVarName, sizeof(f_sCVarName));
	
	// Make sure this query replied correctly.
	if (!StrEqual(cvarName, f_sCVarName)) // CVar not expected.
	{
		if (!g_hCVarIndex.GetValue(cvarName, f_hConVar)) // CVar doesn't exist in our list.
		{
			KACR_Log("Unknown CVar Reply: '%L'<%s> was kicked for a corrupted Return with Convar Name \"%s\" (expecting \"%s\") with Value \"%s\".", client, f_sIP, cvarName, f_sCVarName, cvarValue);
			KACR_Kick(client, KACR_CLIENTCORRUPT);
			return;
		}
		
		else
			f_bContinue = false;
			
		GetArrayString(f_hConVar, CELL_NAME, f_sCVarName, sizeof(f_sCVarName));
	}
	
	f_iCompType = GetArrayCell(f_hConVar, CELL_COMPTYPE);
	f_iAction = GetArrayCell(f_hConVar, CELL_ACTION);
	
	if (f_bContinue)
	{
		f_hTemp = g_hReplyTimer[client];
		g_hCurrentQuery[client] = INVALID_HANDLE;
		
		if (f_hTemp != INVALID_HANDLE)
		{
			g_hReplyTimer[client] = INVALID_HANDLE;
			CloseHandle(f_hTemp);
			g_iRetryAttempts[client] = 0;
		}
	}
	
	// Check if it should exist.
	if (f_iCompType == COMP_NONEXIST)
	{
		if (result != ConVarQuery_NotFound)
		{
			switch (f_iAction)
			{
				case ACTION_WARN:
				KACR_PrintToChatAdmins(KACR_HASPLUGIN, client, f_sIP, f_sCVarName);
				
				case ACTION_MOTD:
				{
					GetArrayString(f_hConVar, CELL_ALT, f_sAlternative, sizeof(f_sAlternative));
					ShowMOTDPanel(client, "", f_sAlternative);
				}
				
				case ACTION_MUTE:
				{
					KACR_PrintToChatAll(KACR_MUTED, client);
					ServerCommand("sm_mute #%d", GetClientUserId(client));
				}
				
				case ACTION_KICK:
				{
					KACR_Log("Plugin CVar return: '%L'<%s> was kicked for returning with Plugin ConVar \"%s\" (Value \"%s\", return %s)", client, f_sIP, cvarName, cvarValue, g_sQueryResult[result]);
					KACR_Kick(client, KACR_REMOVEPLUGINS);
					return;
				}
				
				case ACTION_BAN:
				{
					KACR_Log("Bad CVar return: '%L'<%s> has ConVar \"%s\" (Value \"%s\", return %s) when it shouldn't exist.", client, f_sIP, cvarName, cvarValue, g_sQueryResult[result]);
					KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar %s Violation", cvarName);
					
					return;
				}
			}
		}
		
		if (f_bContinue)
			g_hPeriodicTimer[client] = CreateTimer(GetRandomFloat(1.0, 3.0), CVars_PeriodicTimer, client);
			
		return;
	}
	
	if(result == ConVarQuery_NotFound) // Selfcheck so we can prevent Problems with missing Vars
	{
		int iCvarExistence, iActuallyUsefull;
		for (int iCount = 1; iCount <= MaxClients; iCount++)
			if(g_hPeriodicTimer[iCount] != INVALID_HANDLE) // Client is definitly valid and can be queried
			{
				QueryClientConVar(iCount, cvarName, CVars_Selfcheck_QueryCallback, iCvarExistence); // TODO ADD check for "Not Found"
				iActuallyUsefull++; // Better then checking the Contents of g_hPeriodicTimer
			}
			
		if(((iCvarExistence / iActuallyUsefull) * 100) < 80) // More then 80% dont have it
		{
			if(iActuallyUsefull < 8) // Real Clients, no Bots
			{
				//if(iActuallyUsefull > 2)
					// Error, received "Not Found" from '%i' of '%i' Clients('%d%') using '%s', iCvarExistence, iActuallyUsefull, ((iCvarExistence / iActuallyUsefull) * 100, cvarName // TODO Report Back here#27
					
				return;
			}
			
			else if(CVars_RemoveCVar(cvarName))
			{
				// Error, received "Not Found" from '%i' of '%i' Clients('%d%') using '%s', iCvarExistence, iActuallyUsefull, ((iCvarExistence / iActuallyUsefull) * 100, cvarName // TODO Report Back here#27
				KACR_Log("[Error] ConVar '%s' was reported as not existing by '%i' of '%i' Clients('%d%'). Removed that CVar from the Active Checkerlist.", cvarName, iCvarExistence, iActuallyUsefull, ((iCvarExistence / iActuallyUsefull) * 100)); // TODO: add "and reported the Error"
			}
			
			else // Failed to remove
			{
				// Error, received "Not Found" from '%i' of '%i' Clients('%d%') using '%s' but removing this ConVar failed!, iCvarExistence, iActuallyUsefull, ((iCvarExistence / iActuallyUsefull) * 100, cvarName // TODO Report Back here#27
				KACR_Log("[Error] ConVar '%s' was reported as not existing by '%i' of '%i' Clients('%d%'). Couldent remove this CVar from the Checkerlist.", cvarName, iCvarExistence, iActuallyUsefull, ((iCvarExistence / iActuallyUsefull) * 100)); // TODO: add "and reported the Error"
			}
			
			return;
		}
		
		return;
	}
	
	if (result != ConVarQuery_Okay) // ConVar should exist. // TODO: Add an CVar to decide
	{
		KACR_Log("Bad CVar Query Result: '%L'<%s> returned Query Result \"%s\" (expected Okay) on ConVar \"%s\" (Value \"%s\").", client, f_sIP, g_sQueryResult[result], cvarName, cvarValue);
		KickClient(client, "KACR: '%s' Violation (bad Query Result).", cvarName); // TODO: Add Translation
		// KACR_Ban(client, 0, KACR_BANNED, "KACR: '%s' Violation (bad Query Result).", cvarName);
		
		return;
	}
	
	// Check if the ConVar was recently changed.
	if (GetArrayCell(f_hConVar, CELL_CHANGED) != INVALID_HANDLE)
	{
		g_hPeriodicTimer[client] = CreateTimer(GetRandomFloat(1.0, 3.0), CVars_PeriodicTimer, client);
		return;
	}
	
	f_hTemp = GetArrayCell(f_hConVar, CELL_HANDLE);
	if (f_hTemp == INVALID_HANDLE || f_iCompType != COMP_EQUAL)
		GetArrayString(f_hConVar, CELL_VALUE, f_sValue, sizeof(f_sValue));
		
	else
		GetConVarString(f_hTemp, f_sValue, sizeof(f_sValue));
		
	if (f_iCompType == COMP_BOUND)
		f_fValue2 = GetArrayCell(f_hConVar, CELL_VALUE2);
		
	if (f_iCompType != COMP_STRING)
	{
		f_iSize = strlen(cvarValue);
		for (int i = 0; i < f_iSize; i++)
			if (!IsCharNumeric(cvarValue[i]) && cvarValue[i] != '.')
			{
				KACR_Log("Corrupted CVar Response: '%L'<%s> was kicked for returning a corrupted Value on '%s' (%s), Value set at \"%s\" (expected \"%s\").", client, f_sIP, f_sCVarName, cvarName, cvarValue, f_sValue);
				KACR_Kick(client, KACR_CLIENTCORRUPT);
				return;
			}
	}
	
	
	switch (f_iCompType)
	{
		case COMP_EQUAL:
		{
			if (StringToFloat(f_sValue) != StringToFloat(cvarValue))
			{
				switch (f_iAction)
				{
					case ACTION_WARN:
					KACR_PrintToChatAdmins(KACR_HASNOTEQUAL, client, f_sIP, f_sCVarName, cvarValue, f_sValue);
					
					case ACTION_MOTD:
					{
						GetArrayString(f_hConVar, CELL_ALT, f_sAlternative, sizeof(f_sAlternative));
						ShowMOTDPanel(client, "", f_sAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be \"%s\"", client, f_sIP, cvarName, cvarValue, f_sValue);
						KACR_Kick(client, KACR_SHOULDEQUAL, cvarName, f_sValue, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> has ConVar \"%s\" set to Value \"%s\" (should be \"%s\") when it should equal", client, f_sIP, cvarName, cvarValue, f_sValue);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar %s Violation", cvarName);
						
						return;
					}
				}
			}
		}
		
		case COMP_GREATER:
		{
			if (StringToFloat(f_sValue) > StringToFloat(cvarValue))
			{
				switch (f_iAction)
				{
					case ACTION_WARN:
					KACR_PrintToChatAdmins(KACR_HASNOTGREATER, client, f_sIP, f_sCVarName, cvarValue, f_sValue);
					
					case ACTION_MOTD:
					{
						GetArrayString(f_hConVar, CELL_ALT, f_sAlternative, sizeof(f_sAlternative));
						ShowMOTDPanel(client, "", f_sAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be greater than or equal to \"%s\"", client, f_sIP, cvarName, cvarValue, f_sValue);
						KACR_Kick(client, KACR_SHOULDGREATER, cvarName, f_sValue, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> has ConVar \"%s\" set to Value \"%s\" (should be \"%s\") when it should greater than or equal to", client, f_sIP, cvarName, cvarValue, f_sValue);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar %s Violation", cvarName);
						
						return;
					}
				}
			}
		}
		
		case COMP_LESS:
		{
			if (StringToFloat(f_sValue) < StringToFloat(cvarValue))
			{
				switch (f_iAction)
				{
					case ACTION_WARN:
					KACR_PrintToChatAdmins(KACR_HASNOTLESS, client, f_sIP, f_sCVarName, cvarValue, f_sValue);
					
					case ACTION_MOTD:
					{
						GetArrayString(f_hConVar, CELL_ALT, f_sAlternative, sizeof(f_sAlternative));
						ShowMOTDPanel(client, "", f_sAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be less than or equal to \"%s\"", client, f_sIP, cvarName, cvarValue, f_sValue);
						KACR_Kick(client, KACR_SHOULDLESS, cvarName, f_sValue, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> has Convar \"%s\" set to Value \"%s\" (should be \"%s\") when it should be less than or equal to", client, f_sIP, cvarName, cvarValue, f_sValue);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar '%s' Violation", cvarName);
						
						return;
					}
				}
			}
		}
		
		case COMP_BOUND:
		{
			if (StringToFloat(f_sValue) >= StringToFloat(cvarValue) && f_fValue2 <= StringToFloat(cvarValue))
			{
				switch (f_iAction)
				{
					case ACTION_WARN:
					KACR_PrintToChatAdmins(KACR_HASNOTBOUND, client, f_sIP, f_sCVarName, cvarValue, f_sValue, f_fValue2);
					
					case ACTION_MOTD:
					{
						GetArrayString(f_hConVar, CELL_ALT, f_sAlternative, sizeof(f_sAlternative));
						ShowMOTDPanel(client, "", f_sAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be between \"%s\" and \"%f\"", client, f_sIP, cvarName, cvarValue, f_sValue, f_fValue2);
						KACR_Kick(client, KACR_SHOULDBOUND, cvarName, f_sValue, f_fValue2, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> has ConVar \"%s\" set to Value \"%s\" when it should be between \"%s\" and \"%f\"", client, f_sIP, cvarName, cvarValue, f_sValue, f_fValue2);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar '%s' Violation", cvarName);
						
						return;
					}
				}
			}
		}
		
		case COMP_STRING:
		{
			if (!StrEqual(f_sValue, cvarValue))
			{
				switch (f_iAction)
				{
					case ACTION_WARN:
					KACR_PrintToChatAdmins(KACR_HASNOTEQUAL, client, f_sIP, f_sCVarName, cvarValue, f_sValue);
					
					case ACTION_MOTD:
					{
						GetArrayString(f_hConVar, CELL_ALT, f_sAlternative, sizeof(f_sAlternative));
						ShowMOTDPanel(client, "", f_sAlternative);
					}
					
					case ACTION_MUTE:
					{
						KACR_PrintToChatAll(KACR_MUTED, client);
						ServerCommand("sm_mute #%d", GetClientUserId(client));
					}
					
					case ACTION_KICK:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> was kicked for returning with ConVar \"%s\" set to Value \"%s\" when it should be \"%s\"", client, f_sIP, cvarName, cvarValue, f_sValue);
						KACR_Kick(client, KACR_SHOULDEQUAL, cvarName, f_sValue, cvarValue);
						return;
					}
					
					case ACTION_BAN:
					{
						KACR_Log("Bad CVar Response: '%L'<%s> has ConVar \"%s\" set to Value \"%s\" (should be \"%s\") when it should equal", client, f_sIP, cvarName, cvarValue, f_sValue);
						KACR_Ban(client, 0, KACR_BANNED, "KACR: ConVar '%s' Violation", cvarName);
						
						return;
					}
				}
			}
		}
	}
	
	if (f_bContinue)
		g_hPeriodicTimer[client] = CreateTimer(GetRandomFloat(0.5, 2.0), CVars_PeriodicTimer, client);
}

public void CVars_Selfcheck_QueryCallback(QueryCookie hCookie, iClient, ConVarQueryResult hResult, const char[] cCvarName, const char[] cCvarValue, any iCvarExistence)
{
	if (hResult != ConVarQuery_NotFound)
		iCvarExistence++;
		
	return;
}


//- Hooks -//

public void CVars_Replicate(Handle convar, const char[] oldvalue, const char[] newvalue)
{
	Handle f_hCVarIndex, f_hTimer;
	char cConVar[64];
	GetConVarName(convar, cConVar, sizeof(cConVar));
	if (g_hCVarIndex.GetValue(cConVar, f_hCVarIndex))
	{
		f_hTimer = GetArrayCell(f_hCVarIndex, CELL_CHANGED);
		if (f_hTimer != INVALID_HANDLE)
			CloseHandle(f_hTimer);
			
		f_hTimer = CreateTimer(30.0, CVars_ReplicateCheck, f_hCVarIndex);
		SetArrayCell(f_hCVarIndex, CELL_CHANGED, f_hTimer);
	}
	
	RequestFrame(CVars_ReplicateTimer, convar); //CreateTimer(0.1, CVars_ReplicateTimer, convar); // The delay is so that nothing interferes with the replication
}

public void CVars_EnableChange(Handle convar, const char[] oldValue, const char[] newValue)
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
* @param fValue1			Allowed Value Range
* @param fValue2			Allowed Value Range
* @param iImportance		Priority (PRIORITY_...)
* @param cAlternative		URL to show to the Player
*/
bool CVars_AddCVar(char[] cConVar, f_iComparisonType, f_iAction, const char[] f_sValue, float f_fValue2, f_iImportance, const char f_sAlternative[] = "")
{
	Handle f_hConVar = INVALID_HANDLE, f_hArray;
	
	f_hConVar = FindConVar(cConVar);
	if (f_hConVar != INVALID_HANDLE && (GetConVarFlags(f_hConVar) & FCVAR_REPLICATED) && (f_iComparisonType == COMP_EQUAL || f_iComparisonType == COMP_STRING))
		f_iComparisonType = COMP_EQUAL;
		
	else
		f_hConVar = INVALID_HANDLE;
		
	if (g_hCVarIndex.GetValue(cConVar, f_hArray)) // Check if CVar check already exists.
	{
		SetArrayString(f_hArray, CELL_NAME, cConVar); // Name			0
		SetArrayCell(f_hArray, CELL_COMPTYPE, f_iComparisonType); // Comparison Type	1
		SetArrayCell(f_hArray, CELL_HANDLE, f_hConVar); // CVar Handle		2
		SetArrayCell(f_hArray, CELL_ACTION, f_iAction); // Action Type		3
		SetArrayString(f_hArray, CELL_VALUE, f_sValue); // Value		4
		SetArrayCell(f_hArray, CELL_VALUE2, f_fValue2); // Value2		5
		SetArrayString(f_hArray, CELL_ALT, f_sAlternative); // Alternative Info	6
		// We will not change the priority.
		// Nor will we change the "changed" cell either.
	}
	
	else
	{
		f_hArray = CreateArray(64);
		PushArrayString(f_hArray, cConVar); // Name			0
		PushArrayCell(f_hArray, f_iComparisonType); // Comparison Type	1
		PushArrayCell(f_hArray, f_hConVar); // CVar Handle		2
		PushArrayCell(f_hArray, f_iAction); // Action Type		3
		PushArrayString(f_hArray, f_sValue); // Value		4
		PushArrayCell(f_hArray, f_fValue2); // Value2		5
		PushArrayString(f_hArray, f_sAlternative); // Alternative Info	6
		PushArrayCell(f_hArray, f_iImportance); // Importance		7
		PushArrayCell(f_hArray, INVALID_HANDLE); // Changed		8
		
		if (!g_hCVarIndex.SetValue(cConVar, f_hArray))
		{
			CloseHandle(f_hArray);
			KACR_Log("Unable to add ConVar to Trie Link List '%s'", cConVar);
			return false;
		}
		
		PushArrayCell(g_hCVars, f_hArray);
		g_iSize = GetArraySize(g_hCVars);
		
		if (f_iImportance != PRIORITY_NORMAL && g_bMapStarted)
			CVars_CreateNewOrder();
	}
	
	return true;
}

stock bool CVars_RemoveCVar(const char[] cConVar)
{
	Handle f_hConVar;
	int f_iIndex;
	
	if (!g_hCVarIndex.GetValue(cConVar, f_hConVar))
		return false;
		
	f_iIndex = FindValueInArray(g_hCVars, f_hConVar);
	if (f_iIndex == -1)
		return false;
		
	for (int i = 0; i <= MaxClients; i++)
	if (g_hCurrentQuery[i] == f_hConVar)
		g_hCurrentQuery[i] = INVALID_HANDLE;
		
	RemoveFromArray(g_hCVars, f_iIndex);
	g_hCVarIndex.Remove(cConVar);
	CloseHandle(f_hConVar);
	g_iSize = GetArraySize(g_hCVars);
	
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
		f_hCurrent = GetArrayCell(g_hCVars, i);
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
	
	ClearArray(g_hCVars);
	
	for (int i = 0; i < g_iSize; i++)
		PushArrayCell(g_hCVars, f_hOrder[i]);
		
	CloseHandle(f_hPHigh);
	CloseHandle(f_hPMedium);
	CloseHandle(f_hPNormal);
}

stock CVars_ReplicateConVar(Handle f_hConVar)
{
	char f_sCVarName[64], f_sValue[64];
	GetConVarName(f_hConVar, f_sCVarName, sizeof(f_sCVarName));
	GetConVarString(f_hConVar, f_sValue, sizeof(f_sValue));
	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_bConnected[i])
		{
			if (!IsClientConnected(i) || IsFakeClient(i))
				OnClientDisconnect(i);
				
			else if (!SendConVarValue(i, f_hConVar, f_sValue))
				continue; // KACR_Log("'%L' failed to accept replication of '%s' (Value: %s)", i, f_sCVarName, f_sValue); - This happens if the netchan isn't created yet, cvars will replicate once it is created.
		}
	}
} 