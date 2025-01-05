/*
	Based on Kigen's Anti-Cheat
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
#define MAX_ENTITIES 2048 // 2048 is hardcoded


//- Global Variables -//

Handle g_hEyeTimer, g_hCVarEyeEnable, g_hCVarAntiWall;
float g_vClientPos[MAXPLAYERS + 1][3], g_vClientEye[MAXPLAYERS + 1][3];
int g_iVelOff, g_iBaseVelOff, g_iEyeStatus, g_iAntiWHStatus;
int g_iWeaponOwner[MAX_ENTITIES];
bool g_bEyeEnabled, g_bAntiWall, g_bAntiWallDisabled = true;
bool g_bIsVisible[MAXPLAYERS + 1][MAXPLAYERS + 1];
bool g_bShouldProcess[MAXPLAYERS + 1], g_bHooked[MAXPLAYERS + 1];


//- Plugin Functions -//

Eyetest_OnPluginStart()
{
	/*if(hGame != Engine_CSGO && hGame != Engine_CSS && hGame != Engine_Insurgency && hGame != Engine_Left4Dead2 && hGame != Engine_HL2DM)
	{*/
	g_hCVarEyeEnable = AutoExecConfig_CreateConVar("kacr_eyes_enable", "1", "Enable the Eye Test detection Routine", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	Eyetest_EnableChange(g_hCVarEyeEnable, "", "");
	
	if (g_bEyeEnabled)
		g_iEyeStatus = Status_Register(KACR_EYEMOD, KACR_ON);
		
	else
		g_iEyeStatus = Status_Register(KACR_EYEMOD, KACR_OFF);
		
	HookConVarChange(g_hCVarEyeEnable, Eyetest_EnableChange);
	/*}
	
	else
		g_iEyeStatus = Status_Register(KACR_EYEMOD, KACR_DISABLED);*/
	
	if (GetMaxEntities() <= MAX_ENTITIES)
	{
		g_bAntiWallDisabled = false;
		g_iAntiWHStatus = Status_Register(KACR_ANTIWH, KACR_OFF);
		
		g_hCVarAntiWall = AutoExecConfig_CreateConVar("kacr_eyes_antiwall", "1", "Enable Anti-Wallhack", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
		
		Eyetest_AntiWallChange(g_hCVarAntiWall, "", "");
		
		HookConVarChange(g_hCVarAntiWall, Eyetest_AntiWallChange);
	}
	
	else // More possible Entitys then we set in the Plugin?!
	{
		g_iAntiWHStatus = Status_Register(KACR_ANTIWH, KACR_DISABLED);
		
		KACR_Log("[Error] The current Maximum of Entitys is set to %i, but the Server reported %i", MAX_ENTITIES, GetMaxEntities())
		PrintToServer("[Kigen-AC_Redux] The current Maximum of Entitys is set to %i, but the Server reported %i", MAX_ENTITIES, GetMaxEntities())
	}
	
	HookEvent("player_spawn", Eyetest_PlayerSpawn);
	HookEvent("player_death", Eyetest_PlayerDeath);
}

Eyetest_OnPluginEnd()
{
	if (g_bAntiWall)
		for (int i = 1; i <= MaxClients; i++)
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
			Status_Report(g_iAntiWHStatus, KACR_ERROR);
		}
	}
}


//- Timer -//

public Action Eyetest_Timer(Handle timer, any we)
{
	if (!g_bEyeEnabled)
	{
		g_hEyeTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	float f_vAngles[3], f_fX, f_fZ;
	char f_sIP[64];
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (g_bShouldProcess[iClient] && GetClientEyeAngles(iClient, f_vAngles))
		{
			f_fX = f_vAngles[0];
			f_fZ = f_vAngles[2];
			if (f_fX > 180.0)
				f_fX -= 360.0;
			
			if (f_fZ > 180.0)
				f_fZ -= 360.0;
			
			if (f_fX > 90.0 || f_fX < -90.0 || f_fZ > 90.0 || f_fZ < -90.0)
			{
				GetClientIP(iClient, f_sIP, sizeof(f_sIP));
				KACR_Log("'%L'<%s> was banned for cheating with their Eye Angles. Eye Angles: %f %f %f", iClient, f_sIP, f_fX, f_vAngles[1], f_fZ);
				KACR_Ban(iClient, 0, KACR_BANNED, "KACR: Eye Angles Violation");
			}
		}
	}
	
	return Plugin_Continue;
}


//- Hooks -//

public void Eyetest_EnableChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bEyeEnabled = GetConVarBool(convar);
	
	if (g_bEyeEnabled && g_hEyeTimer == INVALID_HANDLE)
	{
		g_hEyeTimer = CreateTimer(0.5, Eyetest_Timer, _, TIMER_REPEAT);
		Status_Report(g_iEyeStatus, KACR_ON);
	}
	
	else if (!g_bEyeEnabled && g_hEyeTimer != INVALID_HANDLE)
	{
		CloseHandle(g_hEyeTimer);
		g_hEyeTimer = INVALID_HANDLE;
		Status_Report(g_iEyeStatus, KACR_OFF);
	}
}

public void Eyetest_AntiWallChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	bool f_bEnabled = GetConVarBool(convar);
	
	if (!LibraryExists("sdkhooks"))
		Status_Report(g_iAntiWHStatus, KACR_NOSDKHOOK);
		
	if (f_bEnabled == g_bAntiWall)
		return;
		
	if (f_bEnabled)
	{
		if (!LibraryExists("sdkhooks"))
		{
			LogError("[Kigen-AC_Redux] SDKHooks is not running, cannot enable Anti-Wall");
			SetConVarInt(convar, 0);
			return;
		}
		
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && !IsFakeClient(i)) // g_bInGame[i] && !g_bIsFake[i]) - We do not use the Arrays here since its OnPluginStart and the Players may havent been checked. This can be fixed by populating the arrays OnPluginLoad TODO
				if (IsPlayerAlive(i) && !g_bHooked[i])
					Eyetest_Hook(i);
					
		Status_Report(g_iAntiWHStatus, KACR_ON);
	}
	
	else
	{
		for (int i = 1; i <= MaxClients; i++)
			if (g_bHooked[i])
				Eyetest_Unhook(i);
				
		Status_Report(g_iAntiWHStatus, KACR_OFF);
	}
	
	g_bAntiWall = f_bEnabled;
}

public void Eyetest_PlayerSpawn(Event hEvent, const char[] cName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	if (iClient && GetClientTeam(iClient) > 1)
	{
		if (!IsFakeClient(iClient))
			g_bShouldProcess[iClient] = true;
			
		if (g_bAntiWall && !g_bHooked[iClient])
			Eyetest_Hook(iClient);
	}
	
}

public void Eyetest_PlayerDeath(Event hEvent, const char[] cName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	if (iClient)
	{
		g_bShouldProcess[iClient] = false;
		if (g_bAntiWall && g_bHooked[iClient])
			Eyetest_Unhook(iClient);
	}
}

// Weapon stuff

public void OnEntityCreated(entity, const char[] classname)
{
	if (!g_bAntiWallDisabled && entity > MaxClients && entity < MAX_ENTITIES)
		g_iWeaponOwner[entity] = 0;
}

public void OnEntityDestroyed(entity)
{
	if (!g_bAntiWallDisabled && entity > MaxClients && entity < MAX_ENTITIES)
		g_iWeaponOwner[entity] = 0;
}

public Action Eyetest_WeaponTransmit(entity, client)
{
	if (!g_bAntiWall || client < 1 || client > MaxClients || g_bIsVisible[g_iWeaponOwner[entity]][client])
		return Plugin_Continue;
		
	return Plugin_Stop;
}

public void Eyetest_Equip(iClient, iWeapon) // The Player Picked up a Weapon? Lets bind the Entity ID to the Player ID
{
	if (g_iWeaponOwner[iWeapon] == 0) // The Weapon has no owner yet?
	{
		g_iWeaponOwner[iWeapon] = iClient;
		SDKHook(iWeapon, SDKHook_SetTransmit, Eyetest_WeaponTransmit);
	}
}

public void Eyetest_Drop(iClient, iWeapon)
{
	if (iWeapon > 0 && g_iWeaponOwner[iWeapon] > 0) // Is a Player linked to the Entity? Else we do not Care // Check if the Weapon exists first, it may got deleted in the same Frame, Bugfix for #37
	{
		g_iWeaponOwner[iWeapon] = 0;
		SDKUnhook(iWeapon, SDKHook_SetTransmit, Eyetest_WeaponTransmit);
	}
}

// Back to it.

public void OnGameFrame()
{
	if (!g_bAntiWall)
		return;
		
	float f_vVelocity[3], f_vTempVec[3], f_fTickTime;
	f_fTickTime = GetTickInterval();
	for (int i = 1; i <= MaxClients; i++)
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

public Action Eyetest_Transmit(entity, client)
{
	if (client < 1 || client > MaxClients)
		return Plugin_Continue;
		
	if (entity == client || !g_bShouldProcess[client] || GetClientTeam(entity) == GetClientTeam(client))
	{
		g_bIsVisible[entity][client] = true;
		return Plugin_Continue;
	}
	
	float f_vEyePos[3], f_vTargetOrigin[3];
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

public bool Eyetest_TraceFilter(entity, mask)
{
	return entity > MaxClients;
}


//- Private Functions -//

stock bool IsInRange(const float start[3], const float end[3])
{
	TR_TraceRayFilter(start, end, MASK_OPAQUE, RayType_EndPoint, Eyetest_TraceFilter);
	
	return TR_GetFraction() > 0.0;
}

stock bool IsPointAlmostVisible(const float start[3], const float end[3])
{
	TR_TraceRayFilter(start, end, MASK_OPAQUE, RayType_EndPoint, Eyetest_TraceFilter);
	
	return TR_GetFraction() > POINT_ALMOST_VISIBLE;
}

stock bool IsPointVisible(const float start[3], const float end[3])
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