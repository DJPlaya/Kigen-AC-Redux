// Copyright (C) 2018-now KACR Contributers
// This File is Licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details

// New Module with an KV based Configuration System
// This Module may can carry other Config Systems, or display them in a better way



public Updater_OnPluginUpdated() // TODO: Report to Admins once the Translations changed
{
	if (FileExists("addons/sourcemod/configs/plugin_settings.cfg"))
	{
		Handle hKV = KvizCreateFromFile("Plugins", "addons/sourcemod/configs/plugin_settings.cfg");
		char cKVEntry[8];
		bool bIncluded; // Is KACR or every Plugin set to reload once updated?
		
		//- Global Settings -//
		KvizGetStringExact(hKV, cKVEntry, sizeof(cKVEntry), "*.lifetime");
		if (StrEqual(cKVEntry, "mapsync"))
			#
			
			
		//KvizSetString(hKV, "mapsync", "kigen-ac_redux.lifetime") && KvizToFile(hKV, "plugin_settings.cfg", "kigen-ac_redux.lifetime"))
		
		KvizClose(hKV);
	}
	
	else
		KACR_Log(false, "###");
}