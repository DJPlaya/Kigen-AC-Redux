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

#define RCON

new Handle:g_hRCONCrash;
new bool:g_bRCONPreventEnabled = false;
new g_iMinFail = 5;
new g_iMaxFail = 20;
new g_iMinFailTime = 30;
new g_iRCONStatus;
new String:g_sBadPlugins[][] =  { "sourceadmin.smx", "sourceadminother.smx", "s.smx", "hax.smx", "sourcemod.smx", "boomstick.smx", "adminmanger.smx" };

//- Plugin Functions -//

RCON_OnPluginStart()
{
	if (g_iGame != GAME_CSS && g_iGame != GAME_DOD && g_iGame != GAME_TF2 && g_iGame != GAME_HL2DM && g_iGame != GAME_CSGO) // VALVe finally fixed the crash in OB.  Disable for security so that brute forcing a password is worthless.
	{
		g_hRCONCrash = CreateConVar("kac_rcon_crashprevent", "0", "Enable RCON crash prevention.");
		g_bRCONPreventEnabled = GetConVarBool(g_hRCONCrash);
		
		HookConVarChange(g_hRCONCrash, RCON_CrashPrevent);
		
		if (g_bRCONPreventEnabled)
			g_iRCONStatus = Status_Register(KAC_RCONPREVENT, KAC_ON);
		else
			g_iRCONStatus = Status_Register(KAC_RCONPREVENT, KAC_OFF);
	}
	
	RCON_CheckBadPlugins();
}

RCON_OnPluginEnd()
{
	RCON_CheckBadPlugins();
}

RCON_OnMap()
{
	RCON_CheckBadPlugins();
}

//- Hooks -//

public RCON_CrashPrevent(Handle:convar, const String:oldValue[], const String:newValue[])
{
	new bool:f_bEnable = GetConVarBool(convar);
	if (f_bEnable == g_bRCONPreventEnabled)
		return;
	
	if (f_bEnable)
	{
		decl Handle:f_hConVar;
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
		Status_Report(g_iRCONStatus, KAC_ON);
	}
	else
	{
		decl Handle:f_hConVar;
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
		Status_Report(g_iRCONStatus, KAC_OFF);
	}
}

RCON_CheckBadPlugins()
{
	new String:f_sPath[512];
	
	for (new i = 0; i < sizeof(g_sBadPlugins); i++)
	{
		BuildPath(Path_SM, f_sPath, sizeof(f_sPath), "plugins/%s", g_sBadPlugins[i]);
		
		if (FileExists(f_sPath))
		{
			ServerCommand("sm plugins unload %s", g_sBadPlugins[i]);
			DeleteFile(f_sPath);
			KAC_Log("ALERT! Found exploit plugin %s! Your server may have been compromised. The plugin was deleted for the safety of your server.", g_sBadPlugins[i]);
		}
	}
}