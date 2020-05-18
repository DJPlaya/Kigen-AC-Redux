// Copyright (C) 2007-2011 CodingDirect LLC
// This File is Licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details


Handle g_hCVar_RCON_CrashPrevent;
bool g_bRCONPreventEnabled;
int g_iMinFail = 5;
int g_iMaxFail = 20;
int g_iMinFailTime = 30;
int g_iRCONStatus;


//- Plugin Functions -//

public void RCON_OnPluginStart()
{
	if (g_hGame != Engine_CSGO && g_hGame != Engine_CSS && g_hGame != Engine_DODS && g_hGame != Engine_TF2 && g_hGame != Engine_HL2DM) // VALVe finally fixed the crash in OB.  Disable for security so that brute forcing a password is worthless
	{
		g_hCVar_RCON_CrashPrevent = AutoExecConfig_CreateConVar("kacr_rcon_crashprevent", "0", "Enable RCON Crash Prevention", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
		g_bRCONPreventEnabled = GetConVarBool(g_hCVar_RCON_CrashPrevent);
		
		HookConVarChange(g_hCVar_RCON_CrashPrevent, ConVarChanged_RCON_CrashPrevent);
		
		if (g_bRCONPreventEnabled)
			g_iRCONStatus = Status_Register(KACR_RCONPREVENT, KACR_ON);
			
		else
			g_iRCONStatus = Status_Register(KACR_RCONPREVENT, KACR_OFF);
	}
	
	else
		g_iRCONStatus = Status_Register(KACR_RCONPREVENT, KACR_OFF);
}


//- Hooks -//

public void ConVarChanged_RCON_CrashPrevent(Handle convar, const char[] oldValue, const char[] newValue)
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