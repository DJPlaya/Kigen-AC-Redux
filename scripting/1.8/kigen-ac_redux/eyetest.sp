// Copyright (C) 2007-2011 CodingDirect LLC
// This File is licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details
// All Changes to the original Code are licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details


//- Defines -//

#define POINT_ALMOST_VISIBLE 0.75
#define POINT_MID_VISIBLE 0.6


//- Global Variables -//

Handle g_hEyeTimer;
ConVar g_hCVar_AntiWall, g_hCVar_EyetestAction;
float g_vClientPos[MAXPLAYERS + 1][3], g_vClientEye[MAXPLAYERS + 1][3];
int g_iVelOff, g_iBaseVelOff, g_iEyeStatus, g_iAntiWHStatus, g_iEyetestAction;
int g_iWeaponOwner[MAX_ENTITIES];
bool g_bAntiWall, g_bAntiWallDisabled = true;
bool g_bIsVisible[MAXPLAYERS + 1][MAXPLAYERS + 1];
bool g_bShouldProcess[MAXPLAYERS + 1], g_bHooked[MAXPLAYERS + 1];


//- Plugin Functions -//

public void Eyetest_OnPluginStart()
{
	if(g_hGame == Engine_CSGO || g_hGame == Engine_CSS || g_hGame == Engine_Insurgency || g_hGame == Engine_Left4Dead2 || g_hGame == Engine_HL2DM)
	{
		g_hCVar_EyetestAction = AutoExecConfig_CreateConVar("kacr_eyes_action", "1025", "Action(s) to take when someone does uses Aimbots, Time Bans will be 2 Weeks", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0);
		g_hCVar_AntiWall = AutoExecConfig_CreateConVar("kacr_eyes_antiwall", "1", "Enable Anti-Wallhack", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0, true, 1.0);
	}
	
	else // We dont know the Game, so we disable the Eyecheck by default
	{
		g_hCVar_EyetestAction = AutoExecConfig_CreateConVar("kacr_eyes_action", "1040", "Action(s) to take when someone does uses Aimbots, Time Bans will be 2 Weeks", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0);
		g_hCVar_AntiWall = AutoExecConfig_CreateConVar("kacr_eyes_antiwall", "0", "Enable Anti-Wallhack", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0, true, 1.0);
	}
	g_iEyetestAction = g_hCVar_EyetestAction.IntValue;
	
	ConVarChanged_Eyetest_Action(g_hCVar_EyetestAction, "", "");
	g_hCVar_EyetestAction.AddChangeHook(ConVarChanged_Eyetest_Action);
	
	if (g_iEyetestAction > 0)
		g_iEyeStatus = Status_Register(KACR_EYEMOD, KACR_ON);
		
	else
		g_iEyeStatus = Status_Register(KACR_EYEMOD, KACR_OFF);
		
	ConVarChanged_Eyetest_AntiWall(g_hCVar_AntiWall, "", "");
	g_hCVar_AntiWall.AddChangeHook(ConVarChanged_Eyetest_AntiWall);
	
	g_bAntiWallDisabled = false;
	g_iAntiWHStatus = Status_Register(KACR_ANTIWH, KACR_OFF);
	
	HookEvent("player_spawn", Eyetest_PlayerSpawn);
	HookEvent("player_death", Eyetest_PlayerDeath);
}

public void Eyetest_OnPluginEnd()
{
	if (g_bAntiWall)
		for (int i = 1; i <= MaxClients; i++)
			if (g_bHooked[i])
				SDKUnhook(i, SDKHook_SetTransmit, Eyetest_Transmit);
				
	if (g_hEyeTimer != INVALID_HANDLE)
		CloseHandle(g_hEyeTimer);
}


//- Clients -//

public void Eyetest_OnClientPutInServer(client)
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

public Action Eyetest_Timer(Handle timer) // TODO #36: This Check is only useful for very simpel Aimbots that do aim at targets that are out of the regular Players Aim
{
	if (g_iEyetestAction <= 0)
	{
		g_hEyeTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	float f_vAngles[3]/*, f_fX, f_fZ*/;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (g_bShouldProcess[iClient] && GetClientEyeAngles(iClient, f_vAngles))
		{
			//f_fX = f_vAngles[0];
			//f_fZ = f_vAngles[2];
			//if (f_fX > 180.0)
			//	f_fX -= 360.0;
			f_vAngles[0] > 180.0 ? (f_vAngles[0] -= 360.0) : f_vAngles[0];
			//if (f_fZ > 180.0)
			//	f_fZ -= 360.0;
			f_vAngles[2] > 180.0 ? (f_vAngles[2] -= 360.0) : f_vAngles[2];
			
			if (f_vAngles[0] > 90.0 || f_vAngles[0] < -90.0 || f_vAngles[2] > 90.0 || f_vAngles[2] < -90.0)
				KACR_Action(iClient, g_iEyetestAction, 20160, KACR_BANNED, "KACR: Eye Angles Violation: %f %f %f", f_vAngles[0], f_vAngles[1], f_vAngles[2]);
		}
	}
	
	return Plugin_Continue;
}


//- ConVar Hooks -//

public void ConVarChanged_Eyetest_Action(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_iEyetestAction = StringToInt(newValue);
	
	if (g_iEyetestAction > 0 && g_hEyeTimer == INVALID_HANDLE)
	{
		g_hEyeTimer = CreateTimer(0.5, Eyetest_Timer, _, TIMER_REPEAT);
		Status_Report(g_iEyeStatus, KACR_ON);
	}
	
	else if (g_iEyetestAction <= 0 && g_hEyeTimer != INVALID_HANDLE)
	{
		CloseHandle(g_hEyeTimer);
		// g_hEyeTimer = INVALID_HANDLE; // Not needed?
		Status_Report(g_iEyeStatus, KACR_OFF);
	}
}

public void ConVarChanged_Eyetest_AntiWall(ConVar hConVar, const char[] oldValue, const char[] newValue)
{
	bool f_bEnabled = hConVar.BoolValue;
	
	if (f_bEnabled == g_bAntiWall)
		return;
		
	if (f_bEnabled)
	{
		if (!LibraryExists("sdkhooks"))
		{
			Status_Report(g_iAntiWHStatus, KACR_NOSDKHOOK);
			KACR_Log(false, "[Error] SDKHooks is not running, cannot enable Anti-Wall");
			hConVar.IntValue = 0;
			return;
		}
		
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && !g_bHooked[i]) // We do not use the Client Arrays here since its OnPluginStart and the Players may havent been checked // TODO: is that correct?
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


//- Event Hooks -//

public Action Eyetest_PlayerSpawn(Handle hEvent, const char[] cName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (iClient && GetClientTeam(iClient) > 1)
	{
		if (!IsFakeClient(iClient))
			g_bShouldProcess[iClient] = true;
			
		if (g_bAntiWall && !g_bHooked[iClient])
			Eyetest_Hook(iClient);
	}
}

public Action Eyetest_PlayerDeath(Handle hEvent, const char[] cName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (iClient)
	{
		g_bShouldProcess[iClient] = false;
		if (g_bAntiWall && g_bHooked[iClient])
			Eyetest_Unhook(iClient);
	}
}


//- Weapon/Item Hooks -//

public void Eyetest_OnEntityCreated(iEntity, const char[] cClassname)
{
	if (!g_bAntiWallDisabled && iEntity > MaxClients && iEntity < MAX_ENTITIES)
		g_iWeaponOwner[iEntity] = 0;
}

public void OnEntityDestroyed(iEntity)
{
	if (!g_bAntiWallDisabled && iEntity > MaxClients && iEntity < MAX_ENTITIES)
		g_iWeaponOwner[iEntity] = 0;
}

public Action Eyetest_WeaponTransmit(iEntity, iClient)
{
	if (!g_bAntiWall || iClient < 1 || iClient > MaxClients || g_bIsVisible[g_iWeaponOwner[iEntity]][iClient])
		return Plugin_Continue;
		
	return Plugin_Stop;
}

public Action Eyetest_Equip(client, weapon) // The Player Picked up a Weapon? Lets bind the Entity ID to the Player ID
{
	if (g_iWeaponOwner[weapon] == 0) // The Weapon has no owner yet?
	{
		g_iWeaponOwner[weapon] = client;
		SDKHook(weapon, SDKHook_SetTransmit, Eyetest_WeaponTransmit);
	}
}

public Action Eyetest_Drop(client, weapon)
{
	if (weapon > 0 && g_iWeaponOwner[weapon] > 0) // Is a Player linked to the Entity? Else we do not Care // Check if the Weapon exists first, it may got deleted in the same Frame, Bugfix for #37
	{
		g_iWeaponOwner[weapon] = 0;
		SDKUnhook(weapon, SDKHook_SetTransmit, Eyetest_WeaponTransmit);
	}
}


//- Eyetest Checks -//

public void Eyetest_OnGameFrame()
{
	if (g_bAntiWall)
	{
		float f_vVelocity[3], f_vTempVec[3], f_fTickTime;
		f_fTickTime = GetTickInterval() * 2; // This should solve #47 for now, we now do calculate twice of the Position, still needs to be tested: TODO BUG?
		for (int i = 1; i <= MaxClients; i++)
		{
			if (g_bHooked[i])
			{
				GetEntDataVector(i, g_iVelOff, f_vVelocity);
				if (GetEntityFlags(i) & FL_BASEVELOCITY)
				{
					if (!Entity_IsValid(i))
					{
						GetEntDataVector(i, g_iBaseVelOff, f_vTempVec);
						AddVectors(f_vVelocity, f_vTempVec, f_vVelocity);
					}
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
}

// public Eyetest_Prethink(client)
// {
// TODO: Test for Bhop hacks here #5
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

stock bool IsInRange(const float fStart[3], const float fEnd[3])
{
	TR_TraceRayFilter(fStart, fEnd, MASK_OPAQUE, RayType_EndPoint, Eyetest_TraceFilter);
	
	return TR_GetFraction() > 0.0;
}

stock bool IsPointAlmostVisible(const float fStart[3], const float fEnd[3])
{
	TR_TraceRayFilter(fStart, fEnd, MASK_OPAQUE, RayType_EndPoint, Eyetest_TraceFilter);
	
	return TR_GetFraction() > POINT_ALMOST_VISIBLE;
}

stock bool IsPointVisible(const float fStart[3], const float fEnd[3])
{
	TR_TraceRayFilter(fStart, fEnd, MASK_OPAQUE, RayType_EndPoint, Eyetest_TraceFilter);
	
	return TR_GetFraction() == 1.0;
}

Eyetest_Hook(iClient)
{
	g_bHooked[iClient] = true;
	SDKHook(iClient, SDKHook_SetTransmit, Eyetest_Transmit);
	// SDKHook(iClient, SDKHook_PreThink, Eyetest_Prethink);
	SDKHook(iClient, SDKHook_WeaponEquip, Eyetest_Equip);
	SDKHook(iClient, SDKHook_WeaponDrop, Eyetest_Drop);
}

Eyetest_Unhook(iClient)
{
	g_bHooked[iClient] = false;
	SDKUnhook(iClient, SDKHook_SetTransmit, Eyetest_Transmit);
	// SDKUnhook(iClient, SDKHook_PreThink, Eyetest_Prethink);
	SDKUnhook(iClient, SDKHook_WeaponEquip, Eyetest_Equip);
	SDKUnhook(iClient, SDKHook_WeaponDrop, Eyetest_Drop);
}