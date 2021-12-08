// Copyright (C) 2018-now KACR Contributers
// This File is Licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details


/*
New Module, Fix exploits and abusable stuff

|-Security modul
 |"memorypatch" and similar modules for memory bug patching on the line
 |integrate status module features
 |convar or config for the entity checks
 |Integrate optionally > https://forums.alliedmods.net/showthread.php?t=184270
*/


//- Global Variables -//

ConVar g_hCVar_SecurityCVars, g_hCVar_SecurityEntities, g_hCVar_sv_cheats, g_hCVar_sv_allowupload;

bool g_bSecurityCVars, g_bSecurityEntities, g_bSecurityCVars_sv_cheats, g_bSecurityCVars_sv_allowupload;


//- Plugin Functions -//

public void Security_OnPluginStart()
{
	// ConVars
	
	g_hCVar_SecurityCVars = AutoExecConfig_CreateConVar("kacr_security_cvars", "1", "Enable limiting exploitable ConVars (0 = False, 1 = True)", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_hCVar_SecurityEntities = AutoExecConfig_CreateConVar("kacr_security_entities", "1", "Enable limiting Entities and Map related Feature (may break interactive Maps) (0 = False, 1 = True)", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0, true, 1.0);
	
	// Security Checks
	
	if (GetMaxEntities() > MAX_ENTITIES) // I know this is a bit overkill, still we want to be on the safe Side // AskPluginLoad may be called before Mapstart, so we check this once we do load
		KACR_Log(true, "[Critical] The Server has more Entitys available then the Plugin can handle, Report this Error immediately");
		
	// Hooks
	
	g_hCVar_SecurityCVars.AddChangeHook(ConVarChanged_Security_CVars);
	g_hCVar_SecurityEntities.AddChangeHook(ConVarChanged_Security_Entities);
	
	g_hCVar_sv_cheats = FindConVar("sv_cheats");
	if (g_hCVar_sv_cheats == INVALID_HANDLE)
	{
		g_bSecurityCVars_sv_cheats = false;
		KACR_Log(false, "[Error] Failed to find ConVar 'sv_cheats' CVar security Check disabled");
	}
	
	if (g_hGame != Engine_CSGO && g_hGame != Engine_CSS && g_hGame != Engine_DODS && g_hGame != Engine_TF2 && g_hGame != Engine_HL2DM) // Older Engines may be exploitable true sv_allowupload
	{
		g_hCVar_sv_allowupload = FindConVar("sv_allowupload");
		if (g_hCVar_sv_allowupload == INVALID_HANDLE)
		{
			g_bSecurityCVars_sv_allowupload = false;
			KACR_Log(false, "[Error] Failed to find ConVar 'sv_allowupload', CVar security Check disabled");
		}
		
		KACR_Log(false, "[Info] KACR disabled 'sv_allowupload' because your Game isent listed as secure, this will disable Sprays. If you believe this is an Mistake, fill in an Bug Report");
	}
}

public void Security_OnGameFrame()
{
	if (g_bSecurityCVars)
	{
		if (g_bSecurityCVars_sv_cheats)
			if (g_hCVar_sv_cheats.IntValue != 0)
				g_hCVar_sv_cheats.IntValue = 0;
				
		if (g_bSecurityCVars_sv_allowupload)
			if (g_hCVar_sv_allowupload.IntValue != 0)
				g_hCVar_sv_allowupload.IntValue = 0;
	}
}

public void Security_OnConfigsExecuted() // This dosent belong into cvars because that is for client vars only // TODO: Move sv_cheats to here
{
	if (!g_bSecurityCVars)
		return;
		
	// Prevent Speeds
	ConVar hConVar = FindConVar("sv_max_usercmd_future_ticks"); // Prevent Speedhacks
	if (hConVar) // != INVALID_HANDLE
	{
		if (hConVar.IntValue > 8)// The Value of 1 is outdated, CSS and CSGO do have 8 as default Value - 5.20
		{
			KACR_Log(false, "[Info] 'sv_max_usercmd_future_ticks' was set to '%i' which is a risky Value, re-setting it to its default '8'", hConVar.IntValue);
			hConVar.IntValue = 8;
		}
	}
}


//- Map/Entity Hooks -//

public void Security_OnEntityCreated(iEntity, const char[] cClassname)
{
	if (g_bSecurityEntities)
		if(StrEqual(cClassname, "point_servercommand", false))
			AcceptEntityInput(iEntity, "kill"); // TODO: BUG: Can the Input trigger other VScript actions???
}


//- ConVar Hooks -//

public void ConVarChanged_Security_CVars(ConVar hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bSecurityCVars = hConVar.BoolValue;
}

public void ConVarChanged_Security_Entities(ConVar hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bSecurityEntities = hConVar.BoolValue;
}