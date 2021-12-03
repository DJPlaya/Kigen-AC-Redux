// Copyright (C) 2018-now KACR Contributers
// This File is Licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details

// New Module with an KV based Configuration System
// This Module may can carry other Config Systems, or display them in a better way

// TODO: Create KV File based Config System
// TODO: precreate profile0 for default values and avoid changes

#define KACR_SETTINGS_COUNT 32; // TODO

StringMap g_hConfig[KACR_SETTINGS_COUNT]; // Configuration Cache, y=ConfigID, x=ConfigString|Value|Default|Min|Max
// 1......TODO
/* # copy Layout

Profile1.Pausereports
#Profile1.Prefix - Prefix shown before Messages from this Plugin - '[Kigen AC Redux] '

Profile1.Client.Enable
Profile1.Client.AntiRejoinEnable
Profile1.Client.NameProtectAction
Profile1.Client.AntiSpamConnect.Enable
Profile1.Client.AntiSpamConnect.Action

Profile1.Commands.Enable
Profile1.Commands.SpamLimit

Profile1.CVars.Enable

Profile1.Eyetest.Enable
Profile1.Eyetest.Action
Profile1.Eyetest.AntiWallhackEnable

Profile1.Rcon.CrashPreventionEnable

Profile1.Security.Cvars
Profile1.Security.Entities

#TODO
Profile1.Debug

*/
Handle g_hCVar_ConfigProfile;
int g_iConfigProfile;


public Config_OnPluginStart()
{
	g_hCVar_ConfigProfile = CreateConVar("kacr_config_profile", "0", "Configuration Profile to use for KACR. Please mind that all other Settings are stored in 'data/KACR/Config.kv.cfg' (0 = Use Default Values)", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0);
	
	// TODO just one CVar for setting the Profile, write information in cvar description about the actual location of the settings
	
	//TODO
	RegAdminCmd("kacr_config_reload", Config_Reload_Cmd, ADMFLAG_GENERIC, "Reload the KeyValue Configuration File");
	RegAdminCmd("kacr_config", Config_Cmd, ADMFLAG_ROOT, "Use with an Settings Path to view or adjust the Setting (Usage: kacr_config <Path> <Value to set or nothing to view its current Value>)"
	
	Config_LoadConfig();
}

Config_LoadConfig()
{
	if (!FileExists("addons/sourcemod/data/KACR/Config.kv.cfg"))
	{
		KeyValues hKV = new KeyValues("Variables");
		KvizCreate() // TODO create KV entrys
		if(!KvizSetUInt64())
			KACR_Log(false, "[Error] Couldent create first Config Entry")
			return Plugin_Handled;
			
		KACR_Log(false, "[Info] No Configuration File found, a new one got created using default Values");
	}
	
	else
	{
		ImportFromFile()
		Handle hKV;
		if (!hKV.ImportFromFile("addons/sourcemod/data/KACR/Config.kv.cfg"))
			KACR_Log(true, "[Critical] couldent read Settings from 'addons/sourcemod/data/KACR/Config.kv.cfg'")
		
		char cKVEntry[8];
		//TODO
			
			
		//KvizSetString(hKV, "mapsync", "kigen-ac_redux.lifetime") && KvizToFile(hKV, "plugin_settings.cfg", "kigen-ac_redux.lifetime"))
		
		KvizClose(hKV);
	}
	
	// TODO: Include File Error Check and recreation
}

Config_GetKV(char cKey[]) // Get
{
	char cOutput[64];
	
	if (!KvGetString(g_hKV cKey, cOutput, sizeof(cOutput))
	{
		KACR_Log(false, "[Error] Failed to get KV Entry");
		return false; // Failed
	}
	
	return cOutput; // Success
}

Config_SetKV(char cKey[], char cKey[]) // Set
{
	if (!KvSetString(g_hKV, cKey, cValue))
	{
		KACR_Log(false, "[Error] Failed to set KV Entry");
		return false; // Failed
	}
	
	return true; // Success
}


//- Commands -//

Config_Reload_Cmd(iClient, iArgs)
{
	Config_LoadConfig();
	return Plugin_Handled;
}

Config_Cmd(iClient, iArgs)
{
	if (!GetCmdArgs() && GetCmdArgs() < 3)
	{
		ReplyToCommand(iClient, "[Kigen AC Redux] Usage: kacr_config <Config Path> <Value to set or nothing to view the current Value>");
		return Plugin_Handled;
	}
	
	char cKey[64], cValue[256];
	
	GetCmdArg(1, cKey, sizeof(cKey));
	GetCmdArg(2, cValue, sizeof(cValue));
	
	if(!view_as<bool>(cValue)) // View/Get
		ReplyToCommand(iClient, "[Kigen AC Redux] The Value of '%s' is: %s", cKey, Config_GetKV(cValue));
		
	else
	{
		Config_SetKV(cKey, cValue);
		ReplyToCommand(iClient, "[Kigen AC Redux] The Value of '%s' was set to: %s", cKey, cValue);
	}
	
	return Plugin_Handled;
}