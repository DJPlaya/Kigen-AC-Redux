// Copyright (C) 2018-now KACR Contributers
// This File is Licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details

// New Module with an KV based Configuration System
// This Module may can carry other Config Systems, or display them in a better way

// TODO: Create KV File based Config System, Support DB Based storage

#define KACR_SETTINGS_COUNT 32; // TODO

StringMap g_hConfig[KACR_SETTINGS_COUNT]; // Configuration Cache, y=ConfigID, x=ConfigString|Value|Default|Min|Max
// 1......TODO
/* # copy Layout

Profile1.Pausereports

Profile1.Client.Enable
Profile1.Client.AntirejoinEnable
Profile1.Client.NameprotectAction
Profile1.Client.Antispamconnect.Enable
Profile1.Client.Antispamconnect.Action

Profile1.Commands.Enable
Profile1.Commands.Spamlimit

Profile1.CVars.Enable

Profile1.Eyetest.Enable
Profile1.Eyetest.Action
Profile1.Eyetest.AntiwallhackEnable

Profile1.Rcon.CrashpreventionEnable

Profile1.Security.Cvars
Profile1.Security.Entities

#TODO
Profile1.Debug

*/


public Config_OnPluginStart()
{
	//TODO
	RegAdminCmd("kacr_config_reload", Config_Reload_Cmd, ADMFLAG_GENERIC, "Reload the KeyValue Configuration File");
	RegAdminCmd("kacr_config", Config_Cmd, ADMFLAG_ROOT, "Use with an Settings Path to view or adjust the Setting (Usage: kacr_config <Path> <Value to set or nothing to view its current Value>)"
	
	Config_LoadConfig();
}

Config_LoadConfig()
{
	if (!FileExists("addons/sourcemod/data/KACR/Config.kv.cfg"))
	{
		KACR_Log(false, "[Info] No Configuration File found, a new one got created using default Values");
		Handle hKV = KvizCreate() // TODO create KV entrys
		if(!KvizSetUInt64())
			KACR_Log(false, "[Error] Couldent create first Config Entry")
			return Plugin_Handled;
	}
	
	else
	{
		Handle hKV = KvizCreateFromFile("Plugins", "addons/sourcemod/data/KACR/Config.kv.cfg");
		char cKVEntry[8];
		//TODO
			
			
		//KvizSetString(hKV, "mapsync", "kigen-ac_redux.lifetime") && KvizToFile(hKV, "plugin_settings.cfg", "kigen-ac_redux.lifetime"))
		
		KvizClose(hKV);
	}
	
	// TODO: Include File Error Check and recreation
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
	
	char cPath[64], cValue[256];
	
	GetCmdArg(1, cPath, sizeof(cPath));
	GetCmdArg(2, cValue, sizeof(cValue));
	switch(view_as<bool>(cValue))
	{
		case 0: // View/Get
		{
			char cOutput[64];
			if (!KvizGetUInt64(g_hKV, cOutput, "Error", cPath))
				ReplyToCommand("[Kigen AC Redux] Couldent find the given Index: %s", cPath);
				
			else
				ReplyToCommand(iClient, "[Kigen AC Redux] Config Value: %s", cOutput);
		}
		
		case 1: // Set
		{
			char cOutput[64];
			
			if (!KvizGetString(g_hKV, cOutput, "Error", cPath))
				ReplyToCommand("[Kigen AC Redux] Couldent find the given Index: %s", cPath);
			
		}
		
		default:
			ReplyToCommand(iClient, "[Kigen AC Redux] Usage: kacr_config <Config Path> <Value to set or nothing to view the current Value>");
	}
	
	return Plugin_Handled;
}