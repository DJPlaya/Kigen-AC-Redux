// Copyright (C) 2007-2011 CodingDirect LLC
// This File is licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details
// All Changes to the original Code are licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details


//- Global Variables -//

ConVar g_hCVar_RCON_CrashPrevent;
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
		g_hCVar_RCON_CrashPrevent = AutoExecConfig_CreateConVar("kacr_rcon_crashprevent", "0", "Enable RCON Crash Prevention", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0, true, 1.0);
		g_bRCONPreventEnabled = g_hCVar_RCON_CrashPrevent.BoolValue;
		
		g_hCVar_RCON_CrashPrevent.AddChangeHook(ConVarChanged_RCON_CrashPrevent);
		
		if (g_bRCONPreventEnabled)
			g_iRCONStatus = Status_Register(KACR_RCONPREVENT, KACR_ON);
			
		else
			g_iRCONStatus = Status_Register(KACR_RCONPREVENT, KACR_OFF);
	}
	
	else
		g_iRCONStatus = Status_Register(KACR_RCONPREVENT, KACR_OFF);
}


//- ConVar Hooks -//

public void ConVarChanged_RCON_CrashPrevent(ConVar hConVar, const char[] oldValue, const char[] newValue)
{
	bool f_bEnable = hConVar.BoolValue;
	if (f_bEnable == g_bRCONPreventEnabled)
		return;
		
	if (f_bEnable)
	{
		ConVar f_hConVar;
		f_hConVar = FindConVar("sv_rcon_minfailuretime");
		if (f_hConVar != INVALID_HANDLE)
		{
			g_iMinFailTime = f_hConVar.IntValue;
			f_hConVar.SetBounds(ConVarBound_Upper, true, 1.0);
			f_hConVar.IntValue = 1; // Setting this so we don't track these failures longer than we need to. - Kigen
		}
		
		f_hConVar = FindConVar("sv_rcon_minfailures");
		if (f_hConVar != INVALID_HANDLE)
		{
			g_iMinFail = f_hConVar.IntValue;
			f_hConVar.SetBounds(ConVarBound_Upper, true, 9999999.0);
			f_hConVar.SetBounds(ConVarBound_Lower, true, 9999999.0);
			f_hConVar.IntValue = 9999999;
		}
		
		f_hConVar = FindConVar("sv_rcon_maxfailures");
		if (f_hConVar != INVALID_HANDLE)
		{
			g_iMaxFail = f_hConVar.IntValue;
			f_hConVar.SetBounds(ConVarBound_Upper, true, 9999999.0);
			f_hConVar.SetBounds(ConVarBound_Lower, true, 9999999.0);
			f_hConVar.IntValue = 9999999;
		}
		
		g_bRCONPreventEnabled = true;
		Status_Report(g_iRCONStatus, KACR_ON);
	}
	
	else
	{
		ConVar f_hConVar;
		f_hConVar = FindConVar("sv_rcon_minfailuretime");
		if (f_hConVar != INVALID_HANDLE)
		{
			f_hConVar.SetBounds(ConVarBound_Upper, false);
			f_hConVar.IntValue = g_iMinFailTime; // Setting this so we don't track these failures longer than we need to. - Kigen
		}
		
		f_hConVar = FindConVar("sv_rcon_minfailures");
		if (f_hConVar != INVALID_HANDLE)
		{
			f_hConVar.SetBounds(ConVarBound_Upper, true, 20.0);
			f_hConVar.SetBounds(ConVarBound_Lower, true, 1.0);
			f_hConVar.IntValue = g_iMinFail;
		}
		
		f_hConVar = FindConVar("sv_rcon_maxfailures");
		if (f_hConVar != INVALID_HANDLE)
		{
			f_hConVar.SetBounds(ConVarBound_Upper, true, 20.0);
			f_hConVar.SetBounds(ConVarBound_Lower, true, 1.0);
			f_hConVar.IntValue = g_iMaxFail;
		}
		
		g_bRCONPreventEnabled = false;
		Status_Report(g_iRCONStatus, KACR_OFF);
	}
}