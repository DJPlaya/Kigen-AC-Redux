/*
    Kigen's Anti-Cheat Eye Test Module
    Copyright (C) 2007-2011 CodingDirect LLC

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

#define EYETEST

#define POINT_ALMOST_VISIBLE 0.75
#define POINT_MID_VISIBLE 0.6
#define MAX_ENTITIES 4096

//- Global Variables -//

new bool:g_bEyeEnabled = false;
new bool:g_bAntiWall = false;
new Handle:g_hEyeTimer = INVALID_HANDLE;
new Handle:g_hCVarEyeEnable = INVALID_HANDLE;
new Handle:g_hCVarAntiWall = INVALID_HANDLE;
new bool:g_bIsVisible[MAXPLAYERS + 1][MAXPLAYERS + 1];
new bool:g_bShouldProcess[MAXPLAYERS + 1];
new bool:g_bHooked[MAXPLAYERS + 1];
new bool:g_bAntiWallDisabled = true;
new Float:g_vClientPos[MAXPLAYERS + 1][3];
new Float:g_vClientEye[MAXPLAYERS + 1][3];
new g_iVelOff;
new g_iBaseVelOff;
new g_iEyeStatus;
new g_iAntiWHStatus;
new g_iWeaponOwner[MAX_ENTITIES];

//- Plugin Functions -//

Eyetest_OnPluginStart()
{
	if (g_iGame != GAME_INS && g_iGame != GAME_CSS && g_iGame != GAME_L4D2 && g_iGame != GAME_HL2DM && g_iGame != GAME_CSGO)
	{
		g_hCVarEyeEnable = CreateConVar("kac_eyes_enable", "0", "Enable the eye test detection routine.");
		Eyetest_EnableChange(g_hCVarEyeEnable, "", "");
		
		if (g_bEyeEnabled)
			g_iEyeStatus = Status_Register(KAC_EYEMOD, KAC_ON);
		else
			g_iEyeStatus = Status_Register(KAC_EYEMOD, KAC_OFF);
		
		HookConVarChange(g_hCVarEyeEnable, Eyetest_EnableChange);
	}
	else
		g_iEyeStatus = Status_Register(KAC_EYEMOD, KAC_DISABLED);
	
	if (GetMaxEntities() < MAX_ENTITIES)
	{
		g_bAntiWallDisabled = false;
		g_iAntiWHStatus = Status_Register(KAC_ANTIWH, KAC_OFF);
		
		g_hCVarAntiWall = CreateConVar("kac_eyes_antiwall", "0", "Enable anti-wallhack");
		
		Eyetest_AntiWallChange(g_hCVarAntiWall, "", "");
		
		HookConVarChange(g_hCVarAntiWall, Eyetest_AntiWallChange);
	}
	else
		g_iAntiWHStatus = Status_Register(KAC_ANTIWH, KAC_DISABLED);
	
	HookEvent("player_spawn", Eyetest_PlayerSpawn);
	HookEvent("player_death", Eyetest_PlayerDeath);
}

Eyetest_OnPluginEnd()
{
	if (g_bAntiWall)
		for (new i = 1; i <= MaxClients; i++)
	if (g_bHooked[i])
		SDKUnhook(i, SDKHook_SetTransmit, Eyetest_Transmit);
	
	if (g_hEyeTimer != INVALID_HANDLE)
		CloseHandle(g_hEyeTimer);
}

//- Clients -//

Eyetest_OnClientPutInServer(client)
{
	if (!IsFakeClient(client) && IsPlayerAlive(client))
		g_bShouldProcess[client] = true;
	else
		g_bShouldProcess[client] = false;
	
	if (!g_bAntiWallDisabled && g_iVelOff < 1)
	{
		g_iVelOff = GetEntSendPropOffs(client, "m_vecVelocity[0]");
		g_iBaseVelOff = GetEntSendPropOffs(client, "m_vecBaseVelocity");
		
		if (g_iVelOff == -1 || g_iBaseVelOff == -1)
		{
			g_bAntiWallDisabled = true;
			g_bAntiWall = false;
			Status_Report(g_iAntiWHStatus, KAC_ERROR);
		}
	}
}

//- Timer -//

public Action:Eyetest_Timer(Handle:timer, any:we)
{
	if (!g_bEyeEnabled)
	{
		g_hEyeTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	decl Float:f_vAngles[3], Float:f_fX, Float:f_fZ, String:f_sAuthID[64], String:f_sIP[64];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_bShouldProcess[i] && GetClientEyeAngles(i, f_vAngles))
		{
			f_fX = f_vAngles[0];
			f_fZ = f_vAngles[2];
			if (f_fX > 180.0)
				f_fX -= 360.0;
			if (f_fZ > 180.0)
				f_fZ -= 360.0;
			if (f_fX > 90.0 || f_fX < -90.0 || f_fZ > 90.0 || f_fZ < -90.0)
			{
				GetClientAuthId(i, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID)) // GetClientAuthString(i, f_sAuthID, sizeof(f_sAuthID));
				GetClientIP(i, f_sIP, sizeof(f_sIP));
				KAC_Log("%N (ID: %s | IP: %s) was banned for cheating with their eye angles.  Eye Angles: %f %f %f", i, f_sAuthID, f_sIP, f_fX, f_vAngles[1], f_fZ);
				KAC_Ban(i, 0, KAC_BANNED, "KAC: Eye Angles Violation");
				#if defined PRIVATE
				Private_Ban(f_sAuthID, "%N (ID: %s | IP: %s) was banned for bad eye angles: %f %f %f.", i, f_sAuthID, f_sIP, f_fX, f_vAngles[1], f_fZ);
				#endif
			}
		}
	}
	return Plugin_Continue;
}

//- Hooks -//

public Eyetest_EnableChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_bEyeEnabled = GetConVarBool(convar);
	if (g_bEyeEnabled && g_hEyeTimer == INVALID_HANDLE)
	{
		g_hEyeTimer = CreateTimer(0.5, Eyetest_Timer, _, TIMER_REPEAT);
		Status_Report(g_iEyeStatus, KAC_ON);
	}
	else if (!g_bEyeEnabled && g_hEyeTimer != INVALID_HANDLE)
	{
		CloseHandle(g_hEyeTimer);
		g_hEyeTimer = INVALID_HANDLE;
		Status_Report(g_iEyeStatus, KAC_OFF);
	}
}

public Eyetest_AntiWallChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	new bool:f_bEnabled = GetConVarBool(convar);
	
	if (!LibraryExists("sdkhooks"))
		Status_Report(g_iAntiWHStatus, KAC_NOSDKHOOK);
	
	if (f_bEnabled == g_bAntiWall)
		return;
	
	if (f_bEnabled)
	{
		if (!LibraryExists("sdkhooks"))
		{
			LogError("SDKHooks is not running.  Cannot enable Anti-Wall.");
			SetConVarInt(convar, 0);
			return;
		}
		for (new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i) && !g_bHooked[i])
			Eyetest_Hook(i);
		
		Status_Report(g_iAntiWHStatus, KAC_ON);
	}
	else
	{
		for (new i = 1; i <= MaxClients; i++)
		if (g_bHooked[i])
			Eyetest_Unhook(i);
		
		Status_Report(g_iAntiWHStatus, KAC_OFF);
	}
	g_bAntiWall = f_bEnabled;
}

public Action:Eyetest_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client && GetClientTeam(client) > 1)
	{
		if (!IsFakeClient(client))
			g_bShouldProcess[client] = true;
		if (g_bAntiWall && !g_bHooked[client])
			Eyetest_Hook(client);
	}
}

public Action:Eyetest_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client)
	{
		g_bShouldProcess[client] = false;
		if (g_bAntiWall && g_bHooked[client])
			Eyetest_Unhook(client);
	}
}

// Weapon stuff

public OnEntityCreated(entity, const String:classname[])
{
	if (!g_bAntiWallDisabled && entity > MaxClients && entity < MAX_ENTITIES)
		g_iWeaponOwner[entity] = 0;
}

public OnEntityDestroyed(entity)
{
	if (!g_bAntiWallDisabled && entity > MaxClients && entity < MAX_ENTITIES)
		g_iWeaponOwner[entity] = 0;
}

public Action:Eyetest_WeaponTransmit(entity, client)
{
	if (!g_bAntiWall || client < 1 || client > MaxClients || g_bIsVisible[g_iWeaponOwner[entity]][client])
		return Plugin_Continue;
	
	return Plugin_Stop;
}

public Action:Eyetest_Equip(client, weapon)
{
	if (g_iWeaponOwner[weapon] == 0)
	{
		g_iWeaponOwner[weapon] = client;
		SDKHook(weapon, SDKHook_SetTransmit, Eyetest_WeaponTransmit);
	}
}

public Action:Eyetest_Drop(client, weapon)
{
	if (g_iWeaponOwner[weapon] != 0)
	{
		g_iWeaponOwner[weapon] = 0;
		SDKUnhook(weapon, SDKHook_SetTransmit, Eyetest_WeaponTransmit);
	}
}

// Back to it.

public OnGameFrame()
{
	if (!g_bAntiWall)
		return;
	
	decl Float:f_vVelocity[3], Float:f_vTempVec[3], Float:f_fTickTime;
	f_fTickTime = GetTickInterval();
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_bHooked[i])
		{
			GetEntDataVector(i, g_iVelOff, f_vVelocity);
			if (GetEntityFlags(i) & FL_BASEVELOCITY)
			{
				GetEntDataVector(i, g_iBaseVelOff, f_vTempVec);
				AddVectors(f_vVelocity, f_vTempVec, f_vVelocity);
			}
			ScaleVector(f_vVelocity, f_fTickTime);
			GetClientEyePosition(i, f_vTempVec);
			AddVectors(f_vTempVec, f_vVelocity, g_vClientEye[i]);
			GetClientAbsOrigin(i, f_vTempVec);
			AddVectors(f_vTempVec, f_vVelocity, g_vClientPos[i]);
			ChangeEdictState(i, g_iVelOff); // Mark as changed so we cause SetTransmit to be called but we don't cause a full update.
		}
	}
}

// public Eyetest_Prethink(client)
// {
// Test for Bhop hacks here.
// }

public Action:Eyetest_Transmit(entity, client)
{
	if (client < 1 || client > MaxClients)
		return Plugin_Continue;
	
	if (entity == client || !g_bShouldProcess[client] || GetClientTeam(entity) == GetClientTeam(client))
	{
		g_bIsVisible[entity][client] = true;
		return Plugin_Continue;
	}
	
	decl Float:f_vEyePos[3], Float:f_vTargetOrigin[3];
	f_vEyePos = g_vClientEye[client];
	f_vTargetOrigin = g_vClientPos[entity];
	
	if (IsInRange(f_vEyePos, f_vTargetOrigin))
	{
		// If origin is visible don't worry about doing the rest of the calculations.
		if (TR_GetFraction() > POINT_MID_VISIBLE)
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		// Around Origin
		f_vTargetOrigin[0] += 60.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		f_vTargetOrigin[1] += 60.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		f_vTargetOrigin[0] -= 120.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		f_vTargetOrigin[1] -= 120.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		f_vTargetOrigin[1] += 90.0;
		
		// Top of head
		f_vTargetOrigin[2] += 90.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		// Around head
		f_vTargetOrigin[0] += 60.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		f_vTargetOrigin[1] += 60.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		f_vTargetOrigin[0] -= 120.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		f_vTargetOrigin[1] -= 120.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
		
		f_vTargetOrigin[1] += 90.0;
		
		// Bottom of feet.
		f_vTargetOrigin[2] -= 180.0;
		
		if (IsPointAlmostVisible(f_vEyePos, f_vTargetOrigin))
		{
			g_bIsVisible[entity][client] = true;
			return Plugin_Continue;
		}
	}
	
	g_bIsVisible[entity][client] = false;
	return Plugin_Stop;
}

//- Trace Filter -//

public bool:Eyetest_TraceFilter(entity, mask)
{
	return entity > MaxClients;
}

//- Private Functions -//

stock bool:IsInRange(const Float:start[3], const Float:end[3])
{
	TR_TraceRayFilter(start, end, MASK_OPAQUE, RayType_EndPoint, Eyetest_TraceFilter);
	
	return TR_GetFraction() > 0.0;
}

stock bool:IsPointAlmostVisible(const Float:start[3], const Float:end[3])
{
	TR_TraceRayFilter(start, end, MASK_OPAQUE, RayType_EndPoint, Eyetest_TraceFilter);
	
	return TR_GetFraction() > POINT_ALMOST_VISIBLE;
}

stock bool:IsPointVisible(const Float:start[3], const Float:end[3])
{
	TR_TraceRayFilter(start, end, MASK_OPAQUE, RayType_EndPoint, Eyetest_TraceFilter);
	
	return TR_GetFraction() == 1.0;
}

Eyetest_Hook(client)
{
	g_bHooked[client] = true;
	SDKHook(client, SDKHook_SetTransmit, Eyetest_Transmit);
	// SDKHook(client, SDKHook_PreThink, Eyetest_Prethink);
	SDKHook(client, SDKHook_WeaponEquip, Eyetest_Equip);
	SDKHook(client, SDKHook_WeaponDrop, Eyetest_Drop);
}

Eyetest_Unhook(client)
{
	g_bHooked[client] = false;
	SDKUnhook(client, SDKHook_SetTransmit, Eyetest_Transmit);
	// SDKUnhook(client, SDKHook_PreThink, Eyetest_Prethink);
	SDKUnhook(client, SDKHook_WeaponEquip, Eyetest_Equip);
	SDKUnhook(client, SDKHook_WeaponDrop, Eyetest_Drop);
}

//- EoF -//
