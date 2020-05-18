// Copyright (C) 2007-2011 CodingDirect LLC
// This File is Licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details


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
* Sends an Command Reply to an Client
* 
* @param iClient		Client UID.
* @param cTranslation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
KACR_ReplyToCommand(const iClient, const char[] cTranslation, any ...)
{
	char cBuffer[256], cFormat[256];
	
	if (iClient < 1)
		g_hSLang.GetString(cTranslation, cFormat, sizeof(cFormat));
		
	else
		g_hCLang[iClient].GetString(cTranslation, cFormat, sizeof(cFormat));
		
	VFormat(cBuffer, sizeof(cBuffer), cFormat, 3);
	ReplyToCommand(iClient, "[Kigen-AC_Redux] %s", cBuffer);
}

/*
* Sends an Translated Message to the Server Console
* 
* @param cTranslation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
KACR_PrintToServer(const char[] cTranslation, any ...)
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
KACR_PrintToChat(const iClient, const char[] cTranslation, any ...)
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
KACR_PrintToChatAdmins(const char[] cTranslation, any ...)
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
KACR_PrintToChatAll(const char[] cTranslation, any ...)
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

/*TODO: Change this in a future Version #26
* Logs an Message to a specific File and can Set the Plugin to failed
* 
* @param iType	Which Type of Message to log/which File to log to (0 = Errors and System Messages, 1 = Suspicions, 2 = Detected Violations, 3 = Actions Taken)
* @param bBreak	Set the Plugins State to failed.
* @param cText	Message to log.
* @param ...	Variable number of format parameters.
*/
/*KACR_Log(const iType, const bool bBreak, const char[] cText, any ...)
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

/*
* Makes an String Lowercase
* 
* @param cText	String to Convert.
*/
StringToLower(char[] cText)
{
	int iSize = strlen(cText);
	for (new i = 0; i < iSize; i++)
		cText[i] = CharToLower(cText[i]);
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


//- Action System -//

/*
	//i (index of something) / 2 ^ N = FloatMod(Sqr(i != 0.0), 0) (A php thingy 'll get on that later)
	
	float FloatMod(float num, float denom)
	{
	    return num - denom * RoundToFloor(num / denom);
	}
*/

/*
* Performens an specified Action
* Combine the Numbers like you desire
* 0 - Do nothing
* 1 - Ban (SB & SB++)
* 2 - Time Ban (SB & SB++) // TODO: Add Option to set the Time
* 4 - Server Ban (banned_ip.cfg or banned_user.cfg)
* 8 - Server Time Ban (banned_ip.cfg or banned_user.cfg) // TODO: Add Option to set the Time
* 16 - Kick
* 32 - Crash Client (May not work on any Game)
* 64 - Report to SB
* 128 - Report to online Admins
* 256 - Tell Admins on Steam about the Violation
* // TODO:512 - Ask an Steam User for Advice
* 1024 - Log to File
* // TODO:2048 - Tell about the Violation using SourceIRC
*
* @param iClient		Client UID.
* @param iAction		What todo with the Client.
* @param iTime			Bantime.
* @param cUserReason	Kickreason to display to the Client, can be a Translation starting with 'KACR_', leave blank to use cReason. 
* @param cReason		The Reason for the Action.
* @param ...			Variable Number of Format Parameters.
*/
KACR_Action(const iClient, const iAction, const iTime, const char[] cUserReason, const char[] cReason, any ...)
{
	// TODO: Add limit to Cvars
	// TODO: Make able to block specific Actions from outside?
	// TODO: Make re-runnable
	// TODO: Use KACR_ActionCheck in here
	// TODO: Integrate Compatibility Check for the Actions??
	
	if(iAction == 0) // 0 - Do nothing
		return;
		
	int iActionCheck = iAction; // We do not want to loose the initial Value, we need it later
	
	//- Log/Report Spam Protection -//
	bool bActions[KACR_Action_Count]; // TODO: Is this a correct Handover?
	KACR_ActionCheck(iAction); // TODO: Is this a correct Handover?
	
	if (bActions[KACR_ActionID_ReportSB] || bActions[KACR_ActionID_ReportAdmins] || bActions[KACR_ActionID_ReportSteamAdmins] || bActions[KACR_ActionID_AskSteamAdmin] || bActions[KACR_ActionID_Log] || bActions[KACR_ActionID_ReportIRC]) // We have an Array so we do not call the Actions toooo often, we do not want to spam the Logs nor the Admins nor SB with Reports
	{
		if (GetTickedTime() / 60 - g_fLastCheatReported[iClient] < g_fPauseReports) // We do / 60 so we convert the ticked Time from Seconds to Minutes // #ref 395723
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
			g_fLastCheatReported[iClient] = GetTickedTime() / 60; // We do not calculate with the Case that KACR_Action does fail, but thats fine
	}
	
	//- Reported Reasons -//
	char cReason2[256], cUserReason2[256];
	VFormat(cReason2, sizeof(cReason2), cReason, 4);
	
	if(StrContains(cUserReason, "KACR_")) // Is Translated
		KACR_Translate(iClient, cUserReason, cUserReason2, sizeof(cUserReason2));
		
	else if(strlen(cUserReason) == 0) // Is Blank
		strcopy(cUserReason2, sizeof(cUserReason2), cReason2);
		
	else // Is valid
		strcopy(cUserReason2, sizeof(cUserReason2), cUserReason);
		
	//- Actual Actions -// // Here the big Checker Block beginns, i wish i would be better in Math so i could design a Formula for this
	loop
	{
		if(iActionCheck < KACR_Action_ReportIRC)
			if(iActionCheck < KACR_Action_Log)
				if(iActionCheck < KACR_Action_AskSteamAdmin)
					if(iActionCheck < KACR_Action_ReportSteamAdmins)
						if(iActionCheck < KACR_Action_ReportAdmins)
							if(iActionCheck < KACR_Action_ReportSB)
								if(iActionCheck < KACR_Action_Crash)
									if(iActionCheck < KACR_Action_Kick)
										if(iActionCheck < KACR_Action_ServerTimeBan)
											if(iActionCheck < KACR_Action_ServerBan)
												if(iActionCheck < KACR_Action_TimeBan) // == 1
													if(iActionCheck < KACR_Action_Ban) // == 0, negative Values would be strange
														break;
														
													else // 1 - Ban (SB & SB++)
													{
														if (g_bSourceBansPP)
														{
															SBPP_BanPlayer(0, iClient, 0, cReason2); // Admin 0 is the Server in SBPP
															if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
																OnClientDisconnect(iClient); // Needed, will be executed in the main File
														}
														
														else if (g_bSourceBans)
														{
															SBBanPlayer(0, iClient, 0, cReason2);
															if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
																OnClientDisconnect(iClient); // Needed, will be executed in the main File
														}
														
														else
														{
															KACR_Log(false, "[Warning] An SourceBans Ban was called but SB isent installed, applying Server Ban instead");
															if(!BanClient(iClient, 0, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR")) // 1 Day
																KACR_Log(false, "[Error] Failed to Server Ban Client '%L', after an SB Ban also failed", iClient);
																
															else if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
																OnClientDisconnect(iClient); // Needed, will be executed in the main Filee
														}
														
														iActionCheck -= KACR_Action_Ban;
													}
													
												else // 2 - Time Ban (SB & SB++)
												{
													if (g_bSourceBansPP)
													{
														SBPP_BanPlayer(0, iClient, iTime, cReason2); // Admin 0 is the Server in SBPP, this ID CAN be created or edited manually in the Database to show Name "Server" on the Webpanel
														if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
															OnClientDisconnect(iClient); // Needed, will be executed in the main File
													}
													
													else if (g_bSourceBans)
													{
														SBBanPlayer(0, iClient, iTime, cReason2);
														if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
															OnClientDisconnect(iClient); // Needed, will be executed in the main File
													}
													
													else
													{
														KACR_Log(false, "[Warning] An Sourcebans Time Ban was called but SB isent installed, applying Server Time Ban instead");
														if(!BanClient(iClient, iTime, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR"))
															KACR_Log(false, "[Error] Failed to Server Time Ban Client '%L', after an SB Ban also failed", iClient);
															
														else if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
															OnClientDisconnect(iClient); // Needed, will be executed in the main File
													}
													
													iActionCheck -= KACR_Action_TimeBan;
												}
												
											else // 4 - Server Ban (banned_ip.cfg or banned_user.cfg)
											{
												if(!BanClient(iClient, 0, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR"))
													KACR_Log(false, "[Error] Failed to Server Ban Client '%L'", iClient);
													
												else if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
													OnClientDisconnect(iClient); // Needed, will be executed in the main File
													
												iActionCheck -= KACR_Action_ServerBan;
											}
											
										else // 8 - Server Time Ban
										{
											if(!BanClient(iClient, iTime, BANFLAG_AUTHID, cReason2, cUserReason2, "KACR")) // 1 Day
												KACR_Log(false, "[Error] Failed to Server Time Ban Client '%L'", iClient);
												
											else if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
												OnClientDisconnect(iClient); // Needed, will be executed in the main File
												
											iActionCheck -= KACR_Action_ServerTimeBan;
										}
										
									else // 16 - Kick
									{
										if(!KickClient(iClient, "%s", cUserReason2))
											KACR_Log(false, "[Error] Failed to kick Client '%L'", iClient);
											
										else if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger
											OnClientDisconnect(iClient); // Needed, will be executed in the main File
											
										iActionCheck -= KACR_Action_Kick;
									}
									
								else // 32 - Crash Client
								{
									if(g_bAdminmenu) 
										KACR_CrashClient(iClient, cUserReason2);
										// OnClientDisconnect(iClient); // Executed in the 'CrashClient_ErrorCheck'
										
									else
									{
										KACR_Log(false, "[Warning] An Client Crash was requested but Adminmenu isent installed, kicking him instead");
										if(!KickClient(iClient, "%s", cUserReason2))
											KACR_Log(false, "[Error] Failed to kick Client '%L', after crashing him also failed", iClient);
									}
									
									iActionCheck -= KACR_Action_Crash;
								}
								
							else // 64 - Report to SB
							{
								if (g_bSourceBansPP)
									SBPP_ReportPlayer(0, iClient, cReason);
									
								else if (g_bSourceBans)
									SB_ReportPlayer(0, iClient, cReason);
									
								else
									KACR_Log(false, "[Error] Tried to Report an Player to Sourcebans but it isent installed");
									
								iActionCheck -= KACR_Action_ReportSB;
							}
							
						else // 128 - Report to online Admins
						{
							// KACR_PrintToChatAdmins(###cTranslation###); // TODO: Match Reasons to find Translations
							
							for (int i = 1; i <= MaxClients; i++)
								if (g_bIsAdmin[i])
									PrintToChat(i, "[Kigen-AC_Redux] Reporting Client '%L' for doing '%s'", iClient, cReason2);
									
							iActionCheck -= KACR_Action_ReportAdmins;
						}
						
					else // 256 - Tell Admins on Steam about the Violation
					{
						if(g_bASteambot)
						{
							if(ASteambot_IsConnected()) // TODO: No Support for multiply Clients yet due to the 'Ask an Steam User over ASteambot for Advice' thingy which can only work with one person
								KACR_PrintToSteamAdmins("[KACR] Reporting Client '%L' for doing '%s'", iClient, cReason2);
								
							else
								KACR_Log(false, "[Error] Tried to Use ASteambot but it is not connected to its Backend");
						}
						
						else
							KACR_Log(false, "[Error] Tried to Use ASteambot but it isent running");
							
						iActionCheck -= KACR_Action_ReportSteamAdmins;
					}
					
				else // 512 - Ask an Steam User over ASteambot for Advice
				{
					if(g_bASteambot)
					{
						// BUG: Native "ASteambot_SendMesssage" was not found
						if(ASteambot_IsConnected())
						{ // 8.10.19 - 632 Chars, 900 is max so we can actually Send all in one MSG
							KACR_PrintToSteamAdmins("[KACR] Reporting Client '%L' for doing '%s'\n[KACR] Which Action should be taken for this Client?\n[KACR] Options available:\n[KACR] 0 - Dont do anything\n[KACR] 1 - Ban (SB & SB++)\n[KACR] 2 - Time Ban (SB & SB++)\n[KACR] 4 - Server Ban (banned_ip.cfg or banned_user.cfg)\n[KACR] 8 - Server Time Ban (banned_ip.cfg or banned_user.cfg)\n[KACR] 16 - Kick\n[KACR] 32 - Crash Client\n[KACR] 64 - Report to SB\n[KACR] 128 - Report to online Admins\n[KACR] 256 - Tell Admins on Steam about the Violation\n[KACR] 1024 - Log to File\n[KACR] 2048 - Tell about the Violation using SourceIRC[KACR] --------------------[KACR] Enter any Number from above to call an Action\n[KACR] You can also add up the Numbers to call multiply Actions"); // I know this is ugly, but i swear, there was no other Way
							
							// TODO: Ask if to display Actions
							// TODO: Implement better with the Report/Log Spam Protection
							// TODO: Warning, we must make this multithread! Else multiply reports could Result in the Plugin going weird
						}
						
						else
							KACR_Log(false, "[Error] Tried to Use ASteambot but it is not connected to its Backend");
					}
					
					else
						KACR_Log(false, "[Error] Tried to Use ASteambot but it isent running");
						
					iActionCheck -= KACR_Action_AskSteamAdmin;
				}
				
			else // 1024 - Log to File
			{
				char cClientIP[64];
				GetClientIP(iClient, cClientIP, sizeof(cClientIP));
				
				KACR_Log(false, "Logging Client '%L<%s>' for doing '%s'", iClient, cClientIP, cReason);
				
				// Checking all the Numbers to make a Proper Report
				int iActionLogCheck = iAction; // We could also directly use iAction, but we may will need it later soooooo
				if(iActionLogCheck < KACR_Action_ReportIRC)
					if(iActionLogCheck < KACR_Action_Log)
						if(iActionLogCheck < KACR_Action_AskSteamAdmin)
							if(iActionLogCheck < KACR_Action_ReportSteamAdmins)
								if(iActionLogCheck < KACR_Action_ReportAdmins)
									if(iActionLogCheck < KACR_Action_ReportSB)
										if(iActionLogCheck < KACR_Action_Crash)
											if(iActionLogCheck < KACR_Action_Kick)
												if(iActionLogCheck < KACR_Action_ServerTimeBan)
													if(iActionLogCheck < KACR_Action_ServerBan)
														if(iActionLogCheck < KACR_Action_TimeBan)
															if(iActionLogCheck < KACR_Action_Ban) // == 0, negative Values would be strange // 0 - Nothin
																break;
																
															else // == 1 // 1 - Ban (SB & SB++)
															{
																KACR_Log(false, "Logging Action 1: Banned Client '%L<%s>'", iClient, cClientIP);
																iActionLogCheck -= KACR_Action_Ban;
															}
															
														else // 2 - Time Ban (SB & SB++)
														{
															KACR_Log(false, "Logging Action 2: Time Banned Client '%L<%s>' for '%i' Minutes", iClient, cClientIP, iTime);
															iActionLogCheck -= KACR_Action_TimeBan;
														}
														
													else // 4 - Server Ban (banned_ip.cfg or banned_user.cfg)
													{
														KACR_Log(false, "Logging Action 4: Server Banned Client '%L<%s>'", iClient, cClientIP);
														iActionLogCheck -= KACR_Action_ServerBan;
													}
													
												else // 8 - Server Time Ban
												{
													KACR_Log(false, "Logging Action 8: Server Time Banned Client '%L<%s>' for '%i' Minutes", iClient, cClientIP, iTime);
													iActionLogCheck -= KACR_Action_ServerTimeBan;
												}
												
											else // 16 - Kick
											{
												KACR_Log(false, "Logging Action 16: Kicked Client '%L<%s>'", iClient, cClientIP);
												iActionLogCheck -= KACR_Action_Kick;
											}
											
										else // 32 - Crash Client
										{
											KACR_Log(false, "Logging Action 32: Crashed Client '%L<%s>'", iClient, cClientIP);
											iActionLogCheck -= KACR_Action_Crash;
										}
										
									else // 64 - Report to SB
									{
										KACR_Log(false, "Logging Action 64: Reportet Client '%L<%s>' to SourceBans", iClient, cClientIP);
										iActionLogCheck -= KACR_Action_ReportSB;
									}
									
								else // 128 - Report to online Admins
								{
									KACR_Log(false, "Logging Action 128: Reportet Client '%L<%s>' to all online Admins", iClient, cClientIP);
									iActionLogCheck -= KACR_Action_ReportAdmins;
								}
								
							else // 256 - Tell Admins on Steam about the Violation
							{
								KACR_Log(false, "Logging Action 256: Reportet Client '%L<%s>' to all Steam Admins", iClient, cClientIP);
								iActionLogCheck -= KACR_Action_ReportSteamAdmins;
							}
							
						else // 512 - Ask an Steam User over ASteambot for Advice
						{
							KACR_Log(false, "Logging Action 512: Asked on Steam what todo with Client '%L<%s>'", iClient, cClientIP);
							iActionLogCheck -= KACR_Action_AskSteamAdmin;
						}
						
					else // 1024 - Log to File
					{
						// DO ONOZ
						iActionLogCheck -= KACR_Action_Log;
					}
					
				else // 2048 - Tell about the Violation using SourceIRC
				{
					KACR_Log(false, "Logging Action 2048: Reportet Client '%L<%s>' to the specified IRC Channels", iClient, cClientIP);
					iActionLogCheck -= KACR_Action_ReportIRC;
					return;
				}
				
				iActionCheck -= KACR_Action_Log;
			}
			
		else // 2048 - Tell about the Violation using SourceIRC
		{
			iActionCheck -= KACR_Action_ReportIRC;
		}
	}
}

/*
* Lets a Client Crash, this Exploit requires Menus and UserMessages so it may work with Source SDK 2013 Games only
* If the Exploit fails, it will kick the Player instead
* 
* @param iClient	The Client you want to Crash.
* @param cReason	The Crash- or Kickreason shown to the Client.
*/
void KACR_CrashClient(const iClient, const char[] cReason)
{
	Menu hMenu = new Menu(CrashClient_MenuHandler);
	hMenu.SetTitle(cReason);
	AddTargetsToMenu2(hMenu, iClient, COMMAND_FILTER_CONNECTED | COMMAND_FILTER_NO_IMMUNITY); 
	hMenu.ExitButton = true;
	hMenu.Display(iClient, 30);
	
	// DataPack hData = CreateDataPack();
	DataPack hData = new DataPack(); // TODO: Works like that?
	if (!hData.WriteFloat(view_as<float>(iClient)))
		KACR_Log(false, "[Error] Failed to write Client Data in the crash Client Function, Report this Error to get it fixed");
		
	if (!hData.WriteString(cReason))
		KACR_Log(false, "[Error] Failed to write Ban Reason Data in the crash Client Function, Report this Error to get it fixed");
		
	RequestFrame(CrashClient_ErrorCheck, hData); // TODO: Is one Frame enought??
}

int CrashClient_MenuHandler(Menu hMenu, MenuAction hAction, const iClient, const iItem) // BUG: iClient is displayed as unused, and thats true, but i cant remove it and supressing the Warning... Nah
{
	if(hAction == MenuAction_Select)
	{
		char cInfo[10];
		hMenu.GetItem(iItem, cInfo, 10);
		
		// int userid = StringToInt(info);
		int iTarget = GetClientOfUserId(StringToInt(cInfo)); 
		if(Client_IsValid(iTarget, true) && Client_IsIngame(iTarget))
		{
			Handle hSayText = StartMessageOne("SayText2", iTarget);
			
			if(hSayText != null)
			{
				PbSetInt(hSayText, "ent_idx", iTarget);
				PbSetBool(hSayText, "chat", true);
				PbSetString(hSayText, "msg_name", "#");
				EndMessage();
			}
		}
	}
	
	else if(hAction == MenuAction_End)
		CloseHandle(hMenu); // TODO: Replace with 'hMenu.Close()' once we dropped legacy support
}

CrashClient_ErrorCheck(any hData)
{
	// hData.Reset();// ResetPack(hData); // TODO: Is the Focus at the second Entry after writing it??
	int iClient;
	char cReason[256];
	
	if (!(view_as<float>(iClient) = ReadPackFloat(hData))) // (!(view_as<float>(iClient) = ReadFloat(hData))) // TODO: Replace once we dropped legacy support
		KACR_Log(false, "[Error] Failed to read Client Data in the crash Client Function, Report this Error to get it fixed");
		
	if (!(ReadPackString(hData, cReason, sizeof(cReason)))) // (!hData.ReadString(cReason, sizeof(cReason)) // TODO: Replace once we dropped legacy support
		KACR_Log(false, "[Error] Failed to read Ban Reason Data in the crash Client Function, Report this Error to get it fixed");
		
	if(IsClientConnected(iClient))
	{
		if(KickClient(iClient, "%s", cReason))
			KACR_Log(false, "[Warning] Failed to crash Client '%L', he was kicked instead", iClient);
			
		else
			KACR_Log(false, "[Error] Failed to kick Client '%L', after crashing him before dident worked too! Report this Error to get it fixed", iClient);
	}
	
	else if(g_bAuthorized[iClient]) // Required for the OnClientConnect Trigger // TODO: Does the 1 Frame Delay will cause problems with our disconnect Functions?
		OnClientDisconnect(iClient); // Needed, will be executed in the main File
		
	CloseHandle(hData); // TODO: Replace with 'hData.Close()' once we dropped legacy support
}

/*
* Checks which Actions are required
* You will get an Bool Array as Handover, no return
* 
* @param iAction	Action ID Input.
*/
bool KACR_ActionCheck(int iAction) // I wish i would be better in Math so i could design a Formula for this
{
	bool bActions[KACR_Action_Count];
	loop
	{
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
									bActions[KACR_ActionID_Crash] = true;
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
	}
}