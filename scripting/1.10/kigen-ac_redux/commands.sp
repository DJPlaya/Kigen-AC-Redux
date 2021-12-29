// Copyright (C) 2007-2011 CodingDirect LLC
// This File is licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details
// All Changes to the original Code are licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details


//- Global Variables -//

ConVar g_hCVar_Cmds_Enable, g_hCVar_Cmds_Spam;
Handle g_hg_iSongCountReset;
StringMap g_hBlockedCmds, g_hIgnoredCmds;

#if defined DEBUG
 char g_sCmdLogPath[256];
#endif

int g_iCmdg_iSongCount[MAXPLAYERS + 1] =  { 0, ... };
int g_iCmdStatus, g_iCmdSpamStatus, g_iCmdSpam = 30;

bool g_bCmds_Enabled = true;


//- Plugin Functions -//

public void Commands_OnPluginStart()
{
	g_hCVar_Cmds_Enable = AutoExecConfig_CreateConVar("kacr_cmds_enable", "1", "If the Commands Module of KACR is enabled", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_bCmds_Enabled = g_hCVar_Cmds_Enable.BoolValue;
	
	g_hCVar_Cmds_Spam = AutoExecConfig_CreateConVar("kacr_cmds_spam", "30", "Amount of Commands in one Second before kick. 0 to disable", FCVAR_DONTRECORD | FCVAR_UNLOGGED | FCVAR_PROTECTED, true, 0.0, true, 120.0);
	g_iCmdSpam = g_hCVar_Cmds_Spam.IntValue;
	
	g_hCVar_Cmds_Enable.AddChangeHook(ConVarChanged_Cmds_Enable);
	g_hCVar_Cmds_Spam.AddChangeHook(ConVarChanged_Cmds_Spam);
	
	// Setup Debug logging Path
	#if defined DEBUG
	 for (int i = 0; ; i++)
	 {
	 	BuildPath(Path_SM, g_sCmdLogPath, sizeof(g_sCmdLogPath), "logs/KACR_CmdLog_%d.log", i);
	 	if (!FileExists(g_sCmdLogPath))
	 		break;
	 }
	#endif
	
	if (g_bCmds_Enabled)
	{
		g_iCmdStatus = Status_Register(KACR_CMDMOD, KACR_ON);
		if (!g_iCmdSpam)
			g_iCmdSpamStatus = Status_Register(KACR_CMDSPAM, KACR_OFF);
			
		else
			g_iCmdSpamStatus = Status_Register(KACR_CMDSPAM, KACR_ON);
	}
	
	else
	{
		g_iCmdStatus = Status_Register(KACR_CMDMOD, KACR_OFF);
		g_iCmdSpamStatus = Status_Register(KACR_CMDSPAM, KACR_DISABLED);
	}
	
	RegConsoleCmd("say", Commands_FilterSay);
	RegConsoleCmd("say_team", Commands_FilterSay);
	RegConsoleCmd("sm_menu", Commands_BlockExploit);
	
	HookEventEx("player_disconnect", Commands_EventDisconnect, EventHookMode_Pre);
}

public void Commands_OnPluginEnd()
{
	if (g_hg_iSongCountReset != INVALID_HANDLE)
		CloseHandle(g_hg_iSongCountReset);
}

public void Commands_OnAllPluginsLoaded()
{
	Handle f_hConCommand;
	char f_sName[64];
	bool f_bIsCommand, f_iFlags;
	
	g_hBlockedCmds = new StringMap();
	g_hIgnoredCmds = new StringMap();
	
	// Exploitable needed commands.  Sigh....
	RegConsoleCmd("ent_create", Commands_BlockEntExploit);
	RegConsoleCmd("ent_fire", Commands_BlockEntExploit);
	RegConsoleCmd("give", Commands_BlockEntExploit);
	
	// Blocked Commands // Note: True sets them to ban, false does not.
	g_hBlockedCmds.SetValue("ai_test_los", false);
	g_hBlockedCmds.SetValue("changelevel", true);
	g_hBlockedCmds.SetValue("cl_fullupdate", false);
	g_hBlockedCmds.SetValue("dbghist_addline", false);
	g_hBlockedCmds.SetValue("dbghist_dump", false);
	g_hBlockedCmds.SetValue("drawcross", false);
	g_hBlockedCmds.SetValue("drawline", false);
	g_hBlockedCmds.SetValue("dump_entity_sizes", false);
	g_hBlockedCmds.SetValue("dump_globals", false);
	g_hBlockedCmds.SetValue("dump_panels", false);
	g_hBlockedCmds.SetValue("dump_terrain", false);
	g_hBlockedCmds.SetValue("dumpg_iSongCountedstrings", false);
	g_hBlockedCmds.SetValue("dumpentityfactories", false);
	g_hBlockedCmds.SetValue("dumpeventqueue", false);
	g_hBlockedCmds.SetValue("dumpgamestringtable", false);
	g_hBlockedCmds.SetValue("editdemo", false);
	g_hBlockedCmds.SetValue("endround", false);
	g_hBlockedCmds.SetValue("groundlist", false);
	g_hBlockedCmds.SetValue("listmodels", false);
	g_hBlockedCmds.SetValue("map_showspawnpoints", false);
	g_hBlockedCmds.SetValue("mem_dump", false);
	g_hBlockedCmds.SetValue("mp_dump_timers", false);
	g_hBlockedCmds.SetValue("npc_ammo_deplete", false);
	g_hBlockedCmds.SetValue("npc_heal", false);
	g_hBlockedCmds.SetValue("npc_speakall", false);
	g_hBlockedCmds.SetValue("npc_thinknow", false);
	g_hBlockedCmds.SetValue("physics_budget", false);
	g_hBlockedCmds.SetValue("physics_debug_entity", false);
	g_hBlockedCmds.SetValue("physics_highlight_active", false);
	g_hBlockedCmds.SetValue("physics_report_active", false);
	g_hBlockedCmds.SetValue("physics_select", false);
	g_hBlockedCmds.SetValue("q_sndrcn", true);
	g_hBlockedCmds.SetValue("report_entities", false);
	g_hBlockedCmds.SetValue("report_touchlinks", false);
	g_hBlockedCmds.SetValue("report_simthinklist", false);
	g_hBlockedCmds.SetValue("respawn_entities", false);
	g_hBlockedCmds.SetValue("rr_reloadresponsesystems", false);
	g_hBlockedCmds.SetValue("scene_flush", false);
	g_hBlockedCmds.SetValue("send_me_rcon", true);
	g_hBlockedCmds.SetValue("snd_digital_surround", false);
	g_hBlockedCmds.SetValue("snd_restart", false);
	g_hBlockedCmds.SetValue("soundlist", false);
	g_hBlockedCmds.SetValue("soundscape_flush", false);
	g_hBlockedCmds.SetValue("sv_benchmark_force_start", false);
	g_hBlockedCmds.SetValue("sv_findsoundname", false);
	g_hBlockedCmds.SetValue("sv_soundemitter_filecheck", false);
	g_hBlockedCmds.SetValue("sv_soundemitter_flush", false);
	g_hBlockedCmds.SetValue("sv_soundscape_printdebuginfo", false);
	g_hBlockedCmds.SetValue("wc_update_entity", false);
	
	if (g_hGame == Engine_Left4Dead2 || g_hGame == Engine_Left4Dead)
	{
		g_hIgnoredCmds.SetValue("choose_closedoor", true);
		g_hIgnoredCmds.SetValue("choose_opendoor", true);
	}
	
	g_hIgnoredCmds.SetValue("buy", true);
	g_hIgnoredCmds.SetValue("buyammo1", true);
	g_hIgnoredCmds.SetValue("buyammo2", true);
	g_hIgnoredCmds.SetValue("use", true);
	
	if (g_bCmds_Enabled)
		g_hg_iSongCountReset = CreateTimer(1.0, Commands_g_iSongCountReset, _, TIMER_REPEAT);
		
	else
		g_hg_iSongCountReset = INVALID_HANDLE;
		
	// Leaving this in as a fall back incase game isn't compatible with the command listener.
	if (GetFeatureStatus(FeatureType_Capability, FEATURECAP_COMMANDLISTENER) != FeatureStatus_Available || !AddCommandListener(Commands_CommandListener))
	{
		f_hConCommand = FindFirstConCommand(f_sName, sizeof(f_sName), f_bIsCommand, f_iFlags);
		if (f_hConCommand == INVALID_HANDLE)
			KACR_Log(true, "[Critical] Failed getting first ConCommand");
			
		do
		{
			if (!f_bIsCommand || StrEqual(f_sName, "sm"))
				continue;
				
			if (StrContains(f_sName, "es_") != -1 && !StrEqual(f_sName, "es_version"))
				RegConsoleCmd(f_sName, Commands_ClientCheck);
				
			else
				RegConsoleCmd(f_sName, Commands_SpamCheck);
			
		}
		
		while (FindNextConCommand(f_hConCommand, f_sName, sizeof(f_sName), f_bIsCommand, f_iFlags));
		
		f_hConCommand.Close();
	}
	
	RegAdminCmd("kacr_addcmd", Commands_AddCmd, ADMFLAG_ROOT, "Adds a command to be blocked by KACR");
	RegAdminCmd("kacr_addignorecmd", Commands_AddIgnoreCmd, ADMFLAG_ROOT, "Adds a command to ignore on command spam");
	RegAdminCmd("kacr_removecmd", Commands_RemoveCmd, ADMFLAG_ROOT, "Removes a command from the block list");
	RegAdminCmd("kacr_removeignorecmd", Commands_RemoveIgnoreCmd, ADMFLAG_ROOT, "Remove a command to ignore");
}


//- Events -//

public Action Commands_EventDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	char f_sReason[512], f_sTemp[512], cIP[64];
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	GetEventString(event, "reason", f_sReason, sizeof(f_sReason));
	GetEventString(event, "name", f_sTemp, sizeof(f_sTemp));
	int f_iLength = strlen(f_sReason) + strlen(f_sTemp);
	GetEventString(event, "networkid", f_sTemp, sizeof(f_sTemp));
	f_iLength += strlen(f_sTemp);
	if (f_iLength > 235)
	{
		KACR_Log(false, "Bad Disconnect Reason, Length '%d', \"%s\"", f_iLength, f_sReason);
		if (client)
		{
			GetClientIP(client, cIP, sizeof(cIP));
			KACR_Log(false, "'%L'<%s> submitted a bad Disconnect Reason and was banned", client, cIP);
			KACR_Ban(client, 0, KACR_BANNED, "KACR: Disconnect Exploit");
		}
		
		SetEventString(event, "reason", "Bad Disconnect Message");
		return Plugin_Continue;
	}
	
	f_iLength = strlen(f_sReason);
	
	for (int ig_iSongCount; ig_iSongCount < f_iLength; ig_iSongCount++)
	{
		if (f_sReason[ig_iSongCount] < 32)
		{
			if (f_sReason[ig_iSongCount] != '\n')
			{
				KACR_Log(false, "Bad Disconnect Reason, \"%s\", Lenght = %d", f_sReason, f_iLength);
				if (client)
				{
					GetClientIP(client, cIP, sizeof(cIP));
					KACR_Log(false, "'%L'<%s> submitted a bad Disconnect. Possible Corruption or Attack", client, cIP);
				}
				
				SetEventString(event, "reason", "Bad Disconnect Message");
				return Plugin_Continue;
			}
		}
	}
	
	return Plugin_Continue;
}


//- Admin Commands -//

public Action Commands_AddCmd(client, args)
{
	if (args != 2)
	{
		KACR_ReplyTranslatedToCommand(client, KACR_ADDCMDUSAGE);
		return Plugin_Handled;
	}
	
	char cCmdName[64], f_sTemp[8];
	bool f_bBan;
	GetCmdArg(1, cCmdName, sizeof(cCmdName));
	
	GetCmdArg(2, f_sTemp, sizeof(f_sTemp));
	if (StringToInt(f_sTemp) != 0 || StrEqual(f_sTemp, "ban") || StrEqual(f_sTemp, "yes") || StrEqual(f_sTemp, "true"))
		f_bBan = true;
		
	else
		f_bBan = false;
		
	if (g_hBlockedCmds.SetValue(cCmdName, f_bBan))
		KACR_ReplyTranslatedToCommand(client, KACR_ADDCMDSUCCESS, cCmdName);
		
	else
		KACR_ReplyTranslatedToCommand(client, KACR_ADDCMDFAILURE, cCmdName);
		
	return Plugin_Handled;
}

public Action Commands_AddIgnoreCmd(client, args)
{
	if (args != 1)
	{
		KACR_ReplyTranslatedToCommand(client, KACR_ADDIGNCMDUSAGE);
		return Plugin_Handled;
	}
	
	char cCmdName[64];
	
	GetCmdArg(1, cCmdName, sizeof(cCmdName));
	
	if (g_hIgnoredCmds.SetValue(cCmdName, true))
		KACR_ReplyTranslatedToCommand(client, KACR_ADDIGNCMDSUCCESS, cCmdName);
		
	else
		KACR_ReplyTranslatedToCommand(client, KACR_ADDIGNCMDFAILURE, cCmdName);
		
	return Plugin_Handled;
}

public Action Commands_RemoveCmd(client, args)
{
	if (args != 1)
	{
		KACR_ReplyTranslatedToCommand(client, KACR_REMCMDUSAGE);
		return Plugin_Handled;
	}
	
	char cCmdName[64];
	GetCmdArg(1, cCmdName, sizeof(cCmdName));
	
	if (g_hBlockedCmds.Remove(cCmdName))
		KACR_ReplyTranslatedToCommand(client, KACR_REMCMDSUCCESS, cCmdName);
		
	else
		KACR_ReplyTranslatedToCommand(client, KACR_REMCMDFAILURE, cCmdName);
		
	return Plugin_Handled;
}

public Action Commands_RemoveIgnoreCmd(client, args)
{
	if (args != 1)
	{
		KACR_ReplyTranslatedToCommand(client, KACR_REMIGNCMDUSAGE);
		return Plugin_Handled;
	}
	
	char cCmdName[64];
	GetCmdArg(1, cCmdName, sizeof(cCmdName));
	
	if (g_hIgnoredCmds.Remove(cCmdName))
		KACR_ReplyTranslatedToCommand(client, KACR_REMIGNCMDSUCCESS, cCmdName);
		
	else
		KACR_ReplyTranslatedToCommand(client, KACR_REMIGNCMDFAILURE, cCmdName);
		
	return Plugin_Handled;
}


//- Console Commands -//

public Action Commands_BlockExploit(client, args)
{
	if (args > 0)
	{
		char f_sArg[64];
		GetCmdArg(1, f_sArg, sizeof(f_sArg));
		if (StrEqual(f_sArg, "rcon_password"))
		{
			char cIP[64], cCmdString[256];
			GetClientIP(client, cIP, sizeof(cIP));
			GetCmdArgString(cCmdString, sizeof(cCmdString));
			KACR_Log(false, "'%L'<%s> was banned for Command Usage Violation of Command: sm_menu %s", client, cIP, cCmdString);
			KACR_Ban(client, 0, KACR_CBANNED, "KACR: Exploit Violation");
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

public Action Commands_FilterSay(iClient, iArgs)
{
	if (!g_bCmds_Enabled)
		return Plugin_Continue;
		
	char f_sMsg[256], f_iLen, f_cChar;
	GetCmdArgString(f_sMsg, sizeof(f_sMsg));
	f_iLen = strlen(f_sMsg);
	
	for (int ig_iSongCount = 0; ig_iSongCount < f_iLen; ig_iSongCount++)
	{
		f_cChar = f_sMsg[ig_iSongCount];
		if (f_cChar < 32 && !IsCharMB(f_cChar))
		{
			KACR_ReplyTranslatedToCommand(iClient, KACR_SAYBLOCK);
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

public Action Commands_BlockEntExploit(iClient, iArgs)
{
	if (iClient < 1)
		return Plugin_Continue;
		
	if (!g_bInGame[iClient])
		return Plugin_Stop;
		
	if (!g_bCmds_Enabled)
		return Plugin_Continue;
		
	char cCmd[512];
	GetCmdArgString(cCmd, sizeof(cCmd));
	
	if (strlen(cCmd) > 500)
		return Plugin_Stop; // No Command Calls should be this long, lets just stop it.
		
	// This looks ugly but i cannot think of something more efficient
	if (StrContains(cCmd, "point_servercommand") != -1 || StrContains(cCmd, "point_clientcommand") != -1 || StrContains(cCmd, "logic_timer") != -1 || StrContains(cCmd, "quit") != -1 || StrContains(cCmd, "sm") != -1 || StrContains(cCmd, "quti") != -1 || StrContains(cCmd, "restart") != -1 || StrContains(cCmd, "alias") != -1 || StrContains(cCmd, "admin") != -1 || StrContains(cCmd, "ma_") != -1 || StrContains(cCmd, "rcon") != -1 || StrContains(cCmd, "sv_") != -1 || StrContains(cCmd, "mp_") != -1 || StrContains(cCmd, "meta") != -1 || StrContains(cCmd, "taketimer") != -1 || StrContains(cCmd, "logic_relay") != -1 || StrContains(cCmd, "logic_auto") != -1 || StrContains(cCmd, "logic_autosave") != -1 || StrContains(cCmd, "logic_branch") != -1 || StrContains(cCmd, "logic_case") != -1 || StrContains(cCmd, "logic_collision_pair") != -1 || StrContains(cCmd, "logic_compareto") != -1 || StrContains(cCmd, "logic_lineto") != -1 || StrContains(cCmd, "logic_measure_movement") != -1 || StrContains(cCmd, "logic_multicompare") != -1 || StrContains(cCmd, "logic_navigation") != -1)
	{ // Invalid Input detected, lets deny that Command
		#if defined DEBUG
		 LogToFileEx(g_sCmdLogPath, "'%L' attempted to run Command: %s", iClient, cCmd);
		#endif
		// TODO: Add Action here and remove the logging Feature since you can use the logging of the Action System
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action Commands_CommandListener(iClient, const char[] cCommand, iArgs)
{
	if (!g_bCmds_Enabled)
		return Plugin_Continue;
		
	if (iClient < 1)
		return Plugin_Continue;
		
	if (g_bIsFake[iClient]) // We could have added this in the first Check but the Client index can be -1 and wont match any entry in the array
		return Plugin_Continue;
		
	if (!g_bInGame[iClient]) // && iClient != 0)
		return Plugin_Stop;
		
	bool bBan;
	char cCmd[64];
	
	strcopy(cCmd, sizeof(cCmd), cCommand);
	StringToLower(cCmd);
	
	// Check to see if this person is command spamming.
	if (g_iCmdSpam != 0 && !g_hIgnoredCmds.GetValue(cCmd, bBan) && (StrContains(cCmd, "es_") == -1 || StrEqual(cCmd, "es_version")) && g_iCmdg_iSongCount[iClient]++ > g_iCmdSpam)
	{
		char cIP[64], cCmdString[128];
		GetClientIP(iClient, cIP, sizeof(cIP));
		GetCmdArgString(cCmdString, sizeof(cCmdString));
		KACR_Log(false, "'%L'<%s> was kicked for Command Spamming: %s %s", iClient, cIP, cCommand, cCmdString);
		KACR_Kick(iClient, KACR_KCMDSPAM);
		return Plugin_Stop;
	}
	
	if (g_hBlockedCmds.GetValue(cCmd, bBan))
	{
		if (bBan)
		{
			char cIP[64], cCmdString[256];
			GetClientIP(iClient, cIP, sizeof(cIP));
			GetCmdArgString(cCmdString, sizeof(cCmdString));
			KACR_Log(false, "'%L'<%s> was banned for Command Usage Violation of Command: %s %s", iClient, cIP, cCommand, cCmdString);
			KACR_Ban(iClient, 0, KACR_CBANNED, "KACR: Command %s Violation", cCommand);
		}
		
		return Plugin_Stop;
	}
	
	#if defined DEBUG
	 char cCmdString[256];
	 GetCmdArgString(cCmdString, sizeof(cCmdString));
	 LogToFileEx(g_sCmdLogPath, "'%L' used Command '%s' with Args '%s'", iClient, cCommand, cCmdString);
	#endif
	
	return Plugin_Continue;
}

public Action Commands_ClientCheck(iClient, iArgs)
{
	if (iClient < 1 || g_bIsFake[iClient])
		return Plugin_Continue;
		
	if (!g_bInGame[iClient])
		return Plugin_Stop;
		
	if (!g_bCmds_Enabled)
		return Plugin_Continue;
		
	char cCmd[64];
	bool f_bBan;
	GetCmdArg(0, cCmd, sizeof(cCmd));
	StringToLower(cCmd);
	
	if (g_hBlockedCmds.GetValue(cCmd, f_bBan))
	{
		if (f_bBan)
		{
			char cIP[64], cCmdString[256];
			GetClientIP(iClient, cIP, sizeof(cIP));
			GetCmdArgString(cCmdString, sizeof(cCmdString));
			KACR_Log(false, "'%L'<%s> was banned for Command Usage Violation of Command: %s %s", iClient, cIP, cCmd, cCmdString);
			KACR_Ban(iClient, 0, KACR_CBANNED, "KACR: Command %s Violation", cCmd);
		}
		
		return Plugin_Stop;
	}
	
	#if defined DEBUG
	 char cCmdString[256];
	 GetCmdArgString(cCmdString, sizeof(cCmdString));
	 LogToFileEx(g_sCmdLogPath, "'%L' used Command '%s' with Args '%s'", iClient, cCmd, cCmdString);
	#endif
	
	return Plugin_Continue;
}

public Action Commands_SpamCheck(iClient, args)
{
	if (iClient < 1 || g_bIsFake[iClient])
		return Plugin_Continue;
		
	if (!g_bInGame[iClient])
		return Plugin_Stop;
		
	if (!g_bCmds_Enabled)
		return Plugin_Continue;
		
	bool f_bBan;
	char cCmd[64];
	GetCmdArg(0, cCmd, sizeof(cCmd)); // This command's name.
	StringToLower(cCmd);
	
	if (g_iCmdSpam != 0 && !g_hIgnoredCmds.GetValue(cCmd, f_bBan) && g_iCmdg_iSongCount[iClient]++ > g_iCmdSpam)
	{
		char cIP[64], cCmdString[128];
		GetClientIP(iClient, cIP, sizeof(cIP));
		GetCmdArgString(cCmdString, sizeof(cCmdString));
		KACR_Log(false, "'%L'<%s> was kicked for Command Spamming: %s %s", iClient, cIP, cCmd, cCmdString);
		KACR_Kick(iClient, KACR_KCMDSPAM);
		return Plugin_Stop;
	}
	
	if (g_hBlockedCmds.GetValue(cCmd, f_bBan))
	{
		if (f_bBan)
		{
			char cIP[64], cCmdString[256];
			GetClientIP(iClient, cIP, sizeof(cIP));
			GetCmdArgString(cCmdString, sizeof(cCmdString));
			KACR_Log(false, "'%L'<%s> was banned for Command Usage Violation of Command: %s %s", iClient, cIP, cCmd, cCmdString);
			KACR_Ban(iClient, 0, KACR_CBANNED, "KACR: Command '%s' Violation", cCmd);
		}
		
		return Plugin_Stop;
	}
	
	#if defined DEBUG
	 char cCmdString[256];
	 GetCmdArgString(cCmdString, sizeof(cCmdString));
	 LogToFileEx(g_sCmdLogPath, "'%L' used Command '%s' with Args '%s'", iClient, cCmd, cCmdString);
	#endif
	
	return Plugin_Continue;
}


//- Timers -//

public Action Commands_g_iSongCountReset(Handle timer, any args)
{
	if (!g_bCmds_Enabled)
	{
		g_hg_iSongCountReset = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	for (int ig_iSongCount = 1; ig_iSongCount <= MaxClients; ig_iSongCount++)
		g_iCmdg_iSongCount[ig_iSongCount] = 0;
		
	return Plugin_Continue;
}


//- ConVar Hooks -//

public void ConVarChanged_Cmds_Enable(ConVar convar, const char[] oldValue, const char[] newValue)
{
	bool f_bEnabled = convar.BoolValue;
	if (f_bEnabled == g_bCmds_Enabled)
		return;
		
	if (f_bEnabled)
	{
		if (g_hg_iSongCountReset == INVALID_HANDLE)
			g_hg_iSongCountReset = CreateTimer(1.0, Commands_g_iSongCountReset, _, TIMER_REPEAT);
			
		g_bCmds_Enabled = true;
		g_iCmdStatus = Status_Register(KACR_CMDMOD, KACR_ON);
		
		if (!g_iCmdSpam)
			g_iCmdSpamStatus = Status_Register(KACR_CMDSPAM, KACR_OFF);
			
		else
			g_iCmdSpamStatus = Status_Register(KACR_CMDSPAM, KACR_ON);
	}
	
	else if (!f_bEnabled)
	{
		if (g_hg_iSongCountReset != INVALID_HANDLE)
			CloseHandle(g_hg_iSongCountReset);
			
		g_hg_iSongCountReset = INVALID_HANDLE;
		g_bCmds_Enabled = false;
		Status_Report(g_iCmdStatus, KACR_OFF);
		Status_Report(g_iCmdSpamStatus, KACR_DISABLED);
	}
}

public void ConVarChanged_Cmds_Spam(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_iCmdSpam = convar.IntValue;
	
	if (!g_bCmds_Enabled)
		Status_Report(g_iCmdSpamStatus, KACR_DISABLED);
		
	else if (!g_iCmdSpam)
		Status_Report(g_iCmdSpamStatus, KACR_OFF);
		
	else
		Status_Report(g_iCmdSpamStatus, KACR_ON);
}