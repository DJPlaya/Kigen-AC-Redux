// Copyright (C) 2018-now KACR Contributers
// This File is Licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details

// TODO: Check version before downloading with an web query
// TODO Uncomment lines with: .ref Update


//- Plugin Functions -//

Update_OnPluginStart()
{
	RegAdminCmd("kacr_update", Update_Command, ADMFLAG_ROOT, "Forces KACR to check for Updates");
	
	CreateTimer(360.0, Update_Timer);
	
	//- Reset Load Params to Default -//
}

public Action Update_Command(const iClient, const iArgs)
{
	ReplyToCommand(iClient, "[Kigen AC Redux] Checking for Updates, this may take a Minute...");
	
	switch (Update_Validate())
	{
		case 0: // Up To Date
			ReplyToCommand(iClient, "[Kigen AC Redux] i am allready up to Date");
			
		case 1: // Failed to Update
			ReplyToCommand(iClient, "[Kigen AC Redux] Failed to download Update");
			
		case 2: // Updated Succesfully
		{
			KACR_Log("[Info] Succesfully updated KACR, activating next Mapchange");
			ReplyToCommand(iClient, "[Kigen AC Redux] Succesfully updated KACR, activating next Mapchange");
		}
	}
	
	if(!RemoveDir("addons/sourcemod/data/KACR/Update"))
	{
		KACR_Log("[Error] Failed to delete Temp Data, you should delete 'addons/sourcemod/data/KACR/Update' manually");
		ReplyToCommand(iClient, "[Kigen AC Redux] Failed to delete Temp Data, you should delete 'addons/sourcemod/data/KACR/Update' manually");
	}
	
	return Plugin_Handled;
}

public Update_Timer(Handle hTimer)
{
	Update_Validate();
}


/*
* Checks if the currently installed Version matches the latest one and updates if not so
* 
* @return	0 = UpToDate, 1 = Failed to Update, 2 = Updated
*/
int Update_Validate()
{
	if(!Update_Download()) // Failed
		return 1; // Valid, no further Actions taken
		
	char cBuffer1[PLATFORM_MAX_PATH], cBuffer2[PLATFORM_MAX_PATH], cPluginPath[PLATFORM_MAX_PATH];
	
	GetPluginFilename(INVALID_HANDLE, cBuffer1, PLATFORM_MAX_PATH);
	Format(cPluginPath, PLATFORM_MAX_PATH, "addons/sourcemod/plugins/%s", cBuffer1);
	System2_GetFileCRC32(cBuffer2, cBuffer1, PLATFORM_MAX_PATH); // Reuse of cBuffer1
	
	if (!System2_GetFileCRC32("addons/sourcemod/data/KACR/Update/kigen-ac_redux.smx", cBuffer2, PLATFORM_MAX_PATH)) // Reuse of cBuffer2
	{
		KACR_Log(false, "[Error] Failed to Update, Downloaded File could not be verified");
		return 1;
	}
	
	if(StrEqual(cBuffer1, cBuffer2)) // Identical Files
		return 0;
		
	else // Not UpToDate, Updating now
	{
		if(Update_Install(cPluginPath))
			return 2;
			
		else
			return 1;
	}
}

/*
* Downloads the latest Version
* Dont forget to delete that Dir once you dont need it anymore
* 
* @return	True if the Download was succesfull
*/
bool Update_Download()
{
	// System2_Check7ZIP() // Nah, for that small size??
	// TODO: LOOP
	
	System2FTPRequest ftpRequest = new System2FTPRequest(FtpResponseCallback, "ftp://#.#/open/KACR/Update/#/kigen-ac_redux.smx")
	ftpRequest.SetPort(21);
	ftpRequest.SetAuthentication("username", "password");
	ftpRequest.SetProgressCallback(FtpProgressCallback);
	ftpRequest.CreateMissingDirs = true;
	ftpRequest.SetOutputFile("addons/sourcemod/data/KACR/Update/###TODO###");
	ftpRequest.StartRequest();
	
	if(Failed)
	{
		KACR_Log("[Error] Failed to Download a Update");
		return false;
	}
	
	else
		return true;
}

FtpProgressCallback(System2FTPRequest hRequest, int dlTotal, int dlNow);
{
	if (bSuccess)
	{
		char cFile[PLATFORM_MAX_PATH];
		request.GetInputFile(cFile, sizeof(cFile));
		PrintToServer("[Info][KACR] Downloading File '%s'(%iMB) with %iMB/sec", cFile, dlTotal * 1048576, dlNow * 1048576);
	}
}

FtpResponseCallback(bool bSuccess, const char[] cError, System2FTPRequest hRequest, System2FTPResponse hResponse)
{
	if (bSuccess)
	{
		char cFile[PLATFORM_MAX_PATH];
		hRequest.GetInputFile(cFile, sizeof(cFile));
		PrintToServer("[Info][KACR] Succesfully downloaded File '%s'(%iMB) with an average of %iMB/Sec", cFile, hResponse.DownloadSize * 1048576, hResponse.DownloadSpeed * 1048576);
	}
	
	else
	{
		PrintToServer("[Error][KACR] Downloading File '%s' got aborted with Error '%s'", cFile, cError);
		KACR_Log("[Error] Downloading File '%s' got aborted with Error '%s'", cFile, cError);
	}
}

/*
* Installs the Update by replacing the File and registering the Plugin Restart on Mapchange.
*
* @param	cPluginPath	Full Plugin Path to update to.
* return	True if the Download was succesfull
*/
bool Update_Install(char cPluginPath[PLATFORM_MAX_PATH])
{
	if (RenameFile(cPluginPath, "addons/sourcemod/data/KACR/Update/kigen-ac_redux.smx"))
	{
		Update_InitPluginReload();
		return true;
	}
	
	else // Failed
	{
		KACR_Log(false, "[Error] Failed to replace Plugin File in order to update");
		return false;
	}
}

Update_InitPluginReload()
{
	if (FileExists("addons/sourcemod/configs/plugin_settings.cfg"))
	{
		Handle hKV = KvizCreateFromFile("Plugins", "addons/sourcemod/configs/plugin_settings.cfg");
		char cKVEntry[8];
		bool bIncluded; // Is KACR or every Plugin set to reload once updated?
		
		//- Global Settings -//
		KvizGetStringExact(hKV, cKVEntry, sizeof(cKVEntry), "*.lifetime");
		if (StrEqual(cKVEntry, "mapsync"))
			bIncluded = true;
			
		//- KACR specific Settings -//
		KvizGetStringExact(hKV, cKVEntry, sizeof(cKVEntry), "kigen-ac_redux.lifetime");
		if (StrEqual(cKVEntry, "mapsync"))
			bIncluded = true;
			
		else if (StrEqual(cKVEntry, "lifetime")) // Just to be sure
			bIncluded = false;
			
		//- Set the Plugin to reload on Mapchange -//
		if (!bIncluded) // Not Set to reload on mapsync, changing that now!
		{
			if (KvizSetString(hKV, "mapsync", "kigen-ac_redux.lifetime") && KvizToFile(hKV, "plugin_settings.cfg", "kigen-ac_redux.lifetime"))
			{
				KACR_Log(false, "[Info] Writing 'plugin_settings.cfg' to automatically reload KACR when updated on Mapchange");
				KACR_Log(false, "[Info] Update successful, KACR will load the Update next Mapchange"); // Included, KACR will reload on Mapchange
			}
			
			else // Failed
				KACR_Log(false, "[Warning] Couldent write 'plugin_settings.cfg', KACR will update on the next Restart"); // We could reload ourself, but this would interrupt the Protection and thats what we do not want to happen
		}
		
		else // Included, KACR will reload on Mapchange
			KACR_Log(false, "[Info] Update successful, KACR will load the Update next Mapchange");
			
		KvizClose(hKV);
	}
	
	else // Default Settings, KACR will reload on Mapchange
		KACR_Log(false, "[Info] Update successful, KACR will load the Update next Mapchange");
}


//- GoD-Tony Updater -//

public Action Updater_OnPluginDownloading()
{
	KACR_Log(false, "[Info] Update found, downloading it now...");
	return Plugin_Continue;
}

public void Updater_OnPluginUpdated() // TODO: Report to Admins once the Translations changed
{
	Update_InitPluginReload();
}