// Copyright (C) 2018-now KACR Contributers
// This File is Licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details

// Update Checks to be done here

int iFocus; // Who used the command?

Update_OnPluginStart()
{
	RegAdminCmd("kacr_update", Update_Command, ADMFLAG_ROOT, "Forces KACR to check for Updates");
	
	CreateTimer(360, Update_Timer);
}

public Action Update_Command(const iClient, const iArgs)
{
	iFocus = iClient;
	
	switch (Update_Validate())
	{
		case 0: // Up To Date
			ReplyToCommand(iFocus, "[KACR] i am allready up to Date");
			
		case 1: // Failed to Update
		
		case 2: // Updated Succesfully
		{
			CopyFile
			KACR_Log("[Info] Succesfully updated to Version ###TODO###");
			ReplyToCommand(iFocus, "[Info][KACR] Succesfully updated to Version ###TODO###");
		}
	}
	
	if(!RemoveDir("addons/sourcemod/data/KACR/Update"))
	{
		KACR_Log("[Error] Failed to delete Temp Data, you should delete 'addons/sourcemod/data/KACR/Update' manually");
		ReplyToCommand(iFocus, "[Error][Kigen-AC_Redux] Failed to delete Temp Data, you should delete 'addons/sourcemod/data/KACR/Update' manually");
	}
	
	return Plugin_Handled;
}

public Update_Timer(Handle hTimer)
{
	iFocus = 0; // The Timer executes all 6 Hours, the Chances are super low that exactly before that Time, someone used the Update Command
	if(!Update_Validate())
}


/*
* Checks if the currently installed Version matches the latest one
* 
* @return	0 = UpToDate, 1 = Failed to Update, 2 = Updated
*/
int Update_Validate()
{
	if(!Update_Download())
	{
		KACR_Log("[Error] Failed to download Update");
		ReplyToCommand(iFocus, "[Error] Failed to download Update");
		return 1; // Valid, no further Actions taken
	}
	
	char cBuffer1[PLATFORM_MAX_PATH], cBuffer2[PLATFORM_MAX_PATH], cBuffer3[PLATFORM_MAX_PATH]; // TODO: Optimize this Mess!
	System2_GetFileCRC32("addons/sourcemod/data/KACR/Update/kigen-ac_redux.smx", cBuffer1, PLATFORM_MAX_PATH);
	
	GetPluginFilename(INVALID_HANDLE, cBuffer2, PLATFORM_MAX_PATH);
	Format(cBuffer3, PLATFORM_MAX_PATH, "addons/sourcemod/plugins/%s", cBuffer2);
	System2_GetFileCRC32(cBuffer3, cBuffer2, PLATFORM_MAX_PATH);
	
	if(StrEqual(cBuffer1, cBuffer2)) // Identical
		return true;
		
	else // Not
		return 0;
}

/*
* Downloads the latest Version
* Dont forget to delete that Dir once you dont need it anymore
* 
* @return			True if the Download was succesfull
*/
Update_Download() // TODO: reply to command?
{
	// System2_Check7ZIP() // Nah, for that small size??
	// TODO: LOOP
	
	System2FTPRequest ftpRequest = new System2FTPRequest(FtpResponseCallback, "ftp://example.com/test.txt")
	ftpRequest.SetPort(21);
	ftpRequest.SetAuthentication("username", "password");
	ftpRequest.SetProgressCallback(FtpProgressCallback);
	ftpRequest.CreateMissingDirs = true;
	ftpRequest.SetOutputFile("addons/sourcemod/data/KACR/Update/###TODO###");
	ftpRequest.StartRequest();
	
	if(Failed)
	{
		KACR_Log("[Error] Failed to Update KACR");
		ReplyToCommand(iFocus, "[Error][KACR] Failed to Update KACR");
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
		PrintToServer("[Info][KACR] Downloaded File '%s'(%i mb) with %imb/sec", cFile, dlTotal * 1000000, dlNow * 1000000);
	}
}

FtpResponseCallback(bool bSuccess, const char[] cError, System2FTPRequest hRequest, System2FTPResponse hResponse)
{
	if (bSuccess)
	{
		char cFile[PLATFORM_MAX_PATH];
		request.GetInputFile(cFile, sizeof(cFile));
		PrintToServer("[Info][KACR] Succesfully downloaded File '%s'(%iMB) with an average of %iMB/Sec", cFile, response.DownloadSize * 1048576, response.DownloadSpeed * 1048576);
	}
	
	else
	{
		PrintToServer("[Error][KACR] Downloading File '%s' got aborted with Error '%s'", cFile, cError);
		KACR_Log("[Error] Downloading File '%s' got aborted with Error '%s'", cFile, cError);
	}
}