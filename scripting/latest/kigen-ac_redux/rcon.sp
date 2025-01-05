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

#define RCON

Handle g_hRCONCrash;
bool g_bRCONPreventEnabled;
int g_iMinFail = 5;
int g_iMaxFail = 20;
int g_iMinFailTime = 30;
int g_iRCONStatus;


//- Plugin Functions -//

RCON_OnPluginStart()
{
	if (hGame != Engine_CSGO && hGame != Engine_CSS && hGame != Engine_DODS && hGame != Engine_TF2 && hGame != Engine_HL2DM) // VALVe finally fixed the crash in OB.  Disable for security so that brute forcing a password is worthless
	{
		g_hRCONCrash = AutoExecConfig_CreateConVar("kacr_rcon_crashprevent", "0", "Enable RCON Crash Prevention", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
		g_bRCONPreventEnabled = GetConVarBool(g_hRCONCrash);
		
		HookConVarChange(g_hRCONCrash, RCON_CrashPrevent);
		
		if (g_bRCONPreventEnabled)
			g_iRCONStatus = Status_Register(KACR_RCONPREVENT, KACR_ON);
			
		else
			g_iRCONStatus = Status_Register(KACR_RCONPREVENT, KACR_OFF);
	}
	
	else
		g_iRCONStatus = Status_Register(KACR_RCONPREVENT, KACR_OFF);
}

/*RCON_OnPluginEnd()
{
}*/

/*RCON_OnMap()
{
}*/


//- Hooks -//

public void RCON_CrashPrevent(Handle convar, const char[] oldValue, const char[] newValue)
{
	bool f_bEnable = GetConVarBool(convar);
	if (f_bEnable == g_bRCONPreventEnabled)
		return;
		
	if (f_bEnable)
	{
		Handle f_hConVar;
		f_hConVar = FindConVar("sv_rcon_minfailuretime");
		if (f_hConVar != INVALID_HANDLE)
		{
			g_iMinFailTime = GetConVarInt(f_hConVar);
			SetConVarBounds(f_hConVar, ConVarBound_Upper, true, 1.0);
			SetConVarInt(f_hConVar, 1); // Setting this so we don't track these failures longer than we need to. - Kigen
		}
		
		f_hConVar = FindConVar("sv_rcon_minfailures");
		if (f_hConVar != INVALID_HANDLE)
		{
			g_iMinFail = GetConVarInt(f_hConVar);
			SetConVarBounds(f_hConVar, ConVarBound_Upper, true, 9999999.0);
			SetConVarBounds(f_hConVar, ConVarBound_Lower, true, 9999999.0);
			SetConVarInt(f_hConVar, 9999999);
		}
		
		f_hConVar = FindConVar("sv_rcon_maxfailures");
		if (f_hConVar != INVALID_HANDLE)
		{
			g_iMaxFail = GetConVarInt(f_hConVar);
			SetConVarBounds(f_hConVar, ConVarBound_Upper, true, 9999999.0);
			SetConVarBounds(f_hConVar, ConVarBound_Lower, true, 9999999.0);
			SetConVarInt(f_hConVar, 9999999);
		}
		
		g_bRCONPreventEnabled = true;
		Status_Report(g_iRCONStatus, KACR_ON);
	}
	
	else
	{
		Handle f_hConVar;
		f_hConVar = FindConVar("sv_rcon_minfailuretime");
		if (f_hConVar != INVALID_HANDLE)
		{
			SetConVarBounds(f_hConVar, ConVarBound_Upper, false);
			SetConVarInt(f_hConVar, g_iMinFailTime); // Setting this so we don't track these failures longer than we need to. - Kigen
		}
		
		f_hConVar = FindConVar("sv_rcon_minfailures");
		if (f_hConVar != INVALID_HANDLE)
		{
			SetConVarBounds(f_hConVar, ConVarBound_Upper, true, 20.0);
			SetConVarBounds(f_hConVar, ConVarBound_Lower, true, 1.0);
			SetConVarInt(f_hConVar, g_iMinFail);
		}
		
		f_hConVar = FindConVar("sv_rcon_maxfailures");
		if (f_hConVar != INVALID_HANDLE)
		{
			SetConVarBounds(f_hConVar, ConVarBound_Upper, true, 20.0);
			SetConVarBounds(f_hConVar, ConVarBound_Lower, true, 1.0);
			SetConVarInt(f_hConVar, g_iMaxFail);
		}
		
		g_bRCONPreventEnabled = false;
		Status_Report(g_iRCONStatus, KACR_OFF);
	}
} 