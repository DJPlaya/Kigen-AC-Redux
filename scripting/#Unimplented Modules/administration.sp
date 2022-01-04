// Copyright (C) 2018-now KACR Contributers
// This File is Licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details

// TODO: Webinterface for Admins that manage Players Bans, Suspicion and similar. Suspicion information can be shown with graphics(for fake lake) and similar using the webui
// TODO: Register Menu Component in Adminmenu

//- Plugin Functions -//

Administration_OnPluginStart()
{
	RegAdminCmd("kacr", KACR_Cmd, ADMFLAG_BAN, "Open KACR Administration Menu");
}

public Action KACR_Cmd(const iClient, const iArgs)
{
	if (iClient < 1 || iClient > MaxClients) // Invalid Client
	{
		ReplyToCommand(iClient, "[KACR] This Command is only for Players");
		return Plugin_Handled;
	}
	
	ReplyToCommand(iClient, "[Kigen AC Redux] Checking for Updates, this may take a Minute...");
	
	Menu hMenu = CreateMenu(KACR_Menu);
	
	SetMenuTitle(hMenu, "KACR Administration Menu");
	
	// int g_i
	int iCountedReports;
	for (int iCount = 1; iCount <= MaxClients; iCount++)
		if(g_iLastCheatReported[iCount] != -3600) // We check if someone is Authorized too incase // Default Time(1h)
			iCountedReports++;
			ReplyToCommand(iClient, "'%N' was last reported %i Seconds ago", iCount, (RoundToNearest(GetTickedTime()) - g_iLastCheatReported[iClient]));
			
	Format(cBuffer, sizeof(cBuffer))
	AddMenuItem(hMenu, "", "Reports"); // Show Active Warnings or Messages here
	AddMenuItem(hMenu, "kacr_status", "Status");
	AddMenuItem(hMenu, "", "");
	AddMenuItem(hMenu, "", "");
	AddMenuItem(hMenu, "", "");
	
	
	DisplayMenu(menu, client, 30);
	
	return Plugin_Continue;
}

public int KACR_Menu(Menu hMenu, MenuAction hAction, const iClient, iItemNum)
{
	if (iItemNum == MenuAction_End)
		CloseHandle(menu);
	
	if (iItemNum == MenuAction_Select)
	{
		
		switch (iItemNum)
		{
			case 0:
			{
				for (int iCount = 1; iCount <= MaxClients; iCount++)
					if(g_iLastCheatReported[iCount] != -3600) // We check if someone is Authorized too incase // Default Time(1h)
						ReplyToCommand(iClient, "'%N' was last reported %i Seconds ago", iCount, (RoundToNearest(GetTickedTime()) - g_iLastCheatReported[iClient]));
			}
			
			case 1:
				Status_Cmd(iClient);
			
			case 2:
			
			case 3:
			
			case 4:
		}
	}
	
	return Plugin_Handled;
}
