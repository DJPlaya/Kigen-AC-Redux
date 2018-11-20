/*
	Kigen's Anti-Cheat Eye Test Module
	Copyright (C) 2007-2011 CodingDirect LLC
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#define COMMANDS

//- Global Variables -//
Handle g_hBlockedCmds = INVALID_HANDLE;
Handle g_hIgnoredCmds = INVALID_HANDLE;
bool g_bCmdEnabled = true;
bool g_bLogCmds = false;
int g_iCmdSpam = 30;
int g_iCmdCount[MAXPLAYERS + 1] =  { 0, ... };
Handle g_hCountReset = INVALID_HANDLE;
Handle g_hCVarCmdEnable = INVALID_HANDLE;
Handle g_hCVarCmdSpam = INVALID_HANDLE;
Handle g_hCVarCmdLog = INVALID_HANDLE;
char g_sCmdLogPath[256];
int g_iCmdStatus;
int g_iCmdSpamStatus;

//- Plugin Functions -//

Commands_OnPluginStart()
{
	g_hCVarCmdEnable = CreateConVar("kac_cmds_enable", "1", "If the Commands Module of KAC is enabled.");
	g_bCmdEnabled = GetConVarBool(g_hCVarCmdEnable);
	
	g_hCVarCmdSpam = CreateConVar("kac_cmds_spam", "30", "Amount of commands in one second before kick.  0 for disable.");
	g_iCmdSpam = GetConVarInt(g_hCVarCmdSpam);
	
	g_hCVarCmdLog = CreateConVar("kac_cmds_log", "0", "Log command usage.  Use only for debugging purposes.");
	g_bLogCmds = GetConVarBool(g_hCVarCmdLog);
	
	HookConVarChange(g_hCVarCmdEnable, Commands_CmdEnableChange);
	HookConVarChange(g_hCVarCmdSpam, Commands_CmdSpamChange);
	HookConVarChange(g_hCVarCmdLog, Commands_CmdLogChange);
	
	//- Setup logging path -//
	for(new i = 0; ; i++)
	{
		BuildPath(Path_SM, g_sCmdLogPath, sizeof(g_sCmdLogPath), "logs/KACCmdLog_%d.log", i);
		if(!FileExists(g_sCmdLogPath))
			break;
	}
	
	if(g_bCmdEnabled)
	{
		g_iCmdStatus = Status_Register(KAC_CMDMOD, KAC_ON);
		if (!g_iCmdSpam)
			g_iCmdSpamStatus = Status_Register(KAC_CMDSPAM, KAC_OFF);
		else
			g_iCmdSpamStatus = Status_Register(KAC_CMDSPAM, KAC_ON);
	}
	
	else
	{
		g_iCmdStatus = Status_Register(KAC_CMDMOD, KAC_OFF);
		g_iCmdSpamStatus = Status_Register(KAC_CMDSPAM, KAC_DISABLED);
	}
	
	RegConsoleCmd("say", Commands_FilterSay);
	RegConsoleCmd("say_team", Commands_FilterSay);
	RegConsoleCmd("sm_menu", Commands_BlockExploit);
	
	HookEventEx("player_disconnect", Commands_EventDisconnect, EventHookMode_Pre)
}

Commands_OnAllPluginsLoaded()
{
	Handle f_hConCommand;
	char f_sName[64];
	bool f_bIsCommand, f_iFlags;
	
	g_hBlockedCmds = CreateTrie();
	g_hIgnoredCmds = CreateTrie();
	
	// Exploitable needed commands.  Sigh....
	RegConsoleCmd("ent_create", Commands_BlockEntExploit);
	RegConsoleCmd("ent_fire", Commands_BlockEntExploit);
	RegConsoleCmd("give", Commands_BlockEntExploit);
	
	//- Blocked Commands -// Note: True sets them to ban, false does not.
	SetTrieValue(g_hBlockedCmds, "ai_test_los", false);
	SetTrieValue(g_hBlockedCmds, "changelevel", true);
	SetTrieValue(g_hBlockedCmds, "cl_fullupdate", false);
	SetTrieValue(g_hBlockedCmds, "dbghist_addline", false);
	SetTrieValue(g_hBlockedCmds, "dbghist_dump", false);
	SetTrieValue(g_hBlockedCmds, "drawcross", false);
	SetTrieValue(g_hBlockedCmds, "drawline", false);
	SetTrieValue(g_hBlockedCmds, "dump_entity_sizes", false);
	SetTrieValue(g_hBlockedCmds, "dump_globals", false);
	SetTrieValue(g_hBlockedCmds, "dump_panels", false);
	SetTrieValue(g_hBlockedCmds, "dump_terrain", false);
	SetTrieValue(g_hBlockedCmds, "dumpcountedstrings", false);
	SetTrieValue(g_hBlockedCmds, "dumpentityfactories", false);
	SetTrieValue(g_hBlockedCmds, "dumpeventqueue", false);
	SetTrieValue(g_hBlockedCmds, "dumpgamestringtable", false);
	SetTrieValue(g_hBlockedCmds, "editdemo", false);
	SetTrieValue(g_hBlockedCmds, "endround", false);
	SetTrieValue(g_hBlockedCmds, "groundlist", false);
	SetTrieValue(g_hBlockedCmds, "listmodels", false);
	SetTrieValue(g_hBlockedCmds, "map_showspawnpoints", false);
	SetTrieValue(g_hBlockedCmds, "mem_dump", false);
	SetTrieValue(g_hBlockedCmds, "mp_dump_timers", false);
	SetTrieValue(g_hBlockedCmds, "npc_ammo_deplete", false);
	SetTrieValue(g_hBlockedCmds, "npc_heal", false);
	SetTrieValue(g_hBlockedCmds, "npc_speakall", false);
	SetTrieValue(g_hBlockedCmds, "npc_thinknow", false);
	SetTrieValue(g_hBlockedCmds, "physics_budget", false);
	SetTrieValue(g_hBlockedCmds, "physics_debug_entity", false);
	SetTrieValue(g_hBlockedCmds, "physics_highlight_active", false);
	SetTrieValue(g_hBlockedCmds, "physics_report_active", false);
	SetTrieValue(g_hBlockedCmds, "physics_select", false);
	SetTrieValue(g_hBlockedCmds, "q_sndrcn", true);
	SetTrieValue(g_hBlockedCmds, "report_entities", false);
	SetTrieValue(g_hBlockedCmds, "report_touchlinks", false);
	SetTrieValue(g_hBlockedCmds, "report_simthinklist", false);
	SetTrieValue(g_hBlockedCmds, "respawn_entities", false);
	SetTrieValue(g_hBlockedCmds, "rr_reloadresponsesystems", false);
	SetTrieValue(g_hBlockedCmds, "scene_flush", false);
	SetTrieValue(g_hBlockedCmds, "send_me_rcon", true);
	SetTrieValue(g_hBlockedCmds, "snd_digital_surround", false);
	SetTrieValue(g_hBlockedCmds, "snd_restart", false);
	SetTrieValue(g_hBlockedCmds, "soundlist", false);
	SetTrieValue(g_hBlockedCmds, "soundscape_flush", false);
	SetTrieValue(g_hBlockedCmds, "sv_benchmark_force_start", false);
	SetTrieValue(g_hBlockedCmds, "sv_findsoundname", false);
	SetTrieValue(g_hBlockedCmds, "sv_soundemitter_filecheck", false);
	SetTrieValue(g_hBlockedCmds, "sv_soundemitter_flush", false);
	SetTrieValue(g_hBlockedCmds, "sv_soundscape_printdebuginfo", false);
	SetTrieValue(g_hBlockedCmds, "wc_update_entity", false);
	
	if(g_iGame == GAME_L4D || g_iGame == GAME_L4D2)
	{
		SetTrieValue(g_hIgnoredCmds, "choose_closedoor", true);
		SetTrieValue(g_hIgnoredCmds, "choose_opendoor", true);
	}
	
	SetTrieValue(g_hIgnoredCmds, "buy", true);
	SetTrieValue(g_hIgnoredCmds, "buyammo1", true);
	SetTrieValue(g_hIgnoredCmds, "buyammo2", true);
	SetTrieValue(g_hIgnoredCmds, "use", true);
	
	if(g_bCmdEnabled)
		g_hCountReset = CreateTimer(1.0, Commands_CountReset, _, TIMER_REPEAT);
		
	else
		g_hCountReset = INVALID_HANDLE;
		
	// Leaving this in as a fall back incase game isn't compatible with the command listener.
	if(GetFeatureStatus(FeatureType_Capability, FEATURECAP_COMMANDLISTENER) != FeatureStatus_Available || !AddCommandListener(Commands_CommandListener))
	{
		f_hConCommand = FindFirstConCommand(f_sName, sizeof(f_sName), f_bIsCommand, f_iFlags);
		if(f_hConCommand == INVALID_HANDLE)
			SetFailState("Failed getting first ConCommand");
			
		do
		{
			if(!f_bIsCommand || StrEqual(f_sName, "sm"))
				continue;
				
			if(StrContains(f_sName, "es_") != -1 && !StrEqual(f_sName, "es_version"))
				RegConsoleCmd(f_sName, Commands_ClientCheck);
			else
				RegConsoleCmd(f_sName, Commands_SpamCheck);
				
		}
		
		while(FindNextConCommand(f_hConCommand, f_sName, sizeof(f_sName), f_bIsCommand, f_iFlags));
		
		CloseHandle(f_hConCommand);
	}
	
	RegAdminCmd("kac_addcmd", Commands_AddCmd, ADMFLAG_ROOT, "Adds a command to be blocked by KAC.");
	RegAdminCmd("kac_addignorecmd", Commands_AddIgnoreCmd, ADMFLAG_ROOT, "Adds a command to ignore on command spam.");
	RegAdminCmd("kac_removecmd", Commands_RemoveCmd, ADMFLAG_ROOT, "Removes a command from the block list.");
	RegAdminCmd("kac_removeignorecmd", Commands_RemoveIgnoreCmd, ADMFLAG_ROOT, "Remove a command to ignore.");
}

Commands_OnPluginEnd()
{
	if(g_hCountReset != INVALID_HANDLE)
		CloseHandle(g_hCountReset);
}

//- Events -//

public Action Commands_EventDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	char f_sReason[512], f_sTemp[512], f_sIP[64];
	int client, f_iLength;
	client = GetClientOfUserId(GetEventInt(event, "userid"));
	GetEventString(event, "reason", f_sReason, sizeof(f_sReason));
	GetEventString(event, "name", f_sTemp, sizeof(f_sTemp));
	f_iLength = strlen(f_sReason) + strlen(f_sTemp);
	GetEventString(event, "networkid", f_sTemp, sizeof(f_sTemp));
	f_iLength += strlen(f_sTemp);
	if(f_iLength > 235)
	{
		KAC_Log("Bad Disconnect Reason, Length '%d', \"%s\"", f_iLength, f_sReason);
		if(client)
		{
			GetClientIP(client, f_sIP, sizeof(f_sIP));
			KAC_Log("'%L'<%s> submitted a bad Disconnect and was banned", client, f_sIP);
			BanIdentity(f_sIP, 10080, BANFLAG_IP, "KAC: Disconnect Exploit"); // Prevent them from rejoining.
			if(GetClientAuthId(client, AuthId_Steam3, f_sTemp, sizeof(f_sTemp)))
			{
				KAC_Ban(client, 0, KAC_BANNED, "KAC: Disconnect Exploit");
				if(!g_bSourceBans && !g_bSourceBansPP)
					BanIdentity(f_sTemp, 0, BANFLAG_AUTHID, "KAC: Disconnect Exploit", "KAC");
			}
		}
		
		SetEventString(event, "reason", "Bad Disconnect Message");
		return Plugin_Continue;
	}
	
	f_iLength = strlen(f_sReason);
	
	for(int iCount; iCount < f_iLength; iCount++)
	{
		if(f_sReason[iCount] < 32)
		{
			if(f_sReason[iCount] != '\n')
			{
				KAC_Log("Bad Disconnect Reason, \"%s\", Lenght = %d", f_sReason, f_iLength);
				if(client)
				{
					GetClientIP(client, f_sIP, sizeof(f_sIP));
					KAC_Log("'%L'<%s> submitted a bad Disconnect. Possible Corruption or Attack", client, f_sIP);
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
	if(args != 2)
	{
		KAC_ReplyToCommand(client, KAC_ADDCMDUSAGE);
		return Plugin_Handled;
	}
	
	char f_sCmdName[64], f_sTemp[8];
	bool f_bBan;
	GetCmdArg(1, f_sCmdName, sizeof(f_sCmdName));
	
	GetCmdArg(2, f_sTemp, sizeof(f_sTemp));
	if(StringToInt(f_sTemp) != 0 || StrEqual(f_sTemp, "ban") || StrEqual(f_sTemp, "yes") || StrEqual(f_sTemp, "true"))
		f_bBan = true;
		
	else
		f_bBan = false;
		
	if(SetTrieValue(g_hBlockedCmds, f_sCmdName, f_bBan))
		KAC_ReplyToCommand(client, KAC_ADDCMDSUCCESS, f_sCmdName);
		
	else
		KAC_ReplyToCommand(client, KAC_ADDCMDFAILURE, f_sCmdName);
		
	return Plugin_Handled;
}

public Action Commands_AddIgnoreCmd(client, args)
{
	if(args != 1)
	{
		KAC_ReplyToCommand(client, KAC_ADDIGNCMDUSAGE);
		return Plugin_Handled;
	}
	
	char f_sCmdName[64];
	
	GetCmdArg(1, f_sCmdName, sizeof(f_sCmdName));
	
	if(SetTrieValue(g_hIgnoredCmds, f_sCmdName, true))
		KAC_ReplyToCommand(client, KAC_ADDIGNCMDSUCCESS, f_sCmdName);
		
	else
		KAC_ReplyToCommand(client, KAC_ADDIGNCMDFAILURE, f_sCmdName);
		
	return Plugin_Handled;
}

public Action Commands_RemoveCmd(client, args)
{
	if(args != 1)
	{
		KAC_ReplyToCommand(client, KAC_REMCMDUSAGE);
		return Plugin_Handled;
	}
	
	char f_sCmdName[64];
	GetCmdArg(1, f_sCmdName, sizeof(f_sCmdName));
	
	if(RemoveFromTrie(g_hBlockedCmds, f_sCmdName))
		KAC_ReplyToCommand(client, KAC_REMCMDSUCCESS, f_sCmdName);
		
	else
		KAC_ReplyToCommand(client, KAC_REMCMDFAILURE, f_sCmdName);
		
	return Plugin_Handled;
}

public Action Commands_RemoveIgnoreCmd(client, args)
{
	if(args != 1)
	{
		KAC_ReplyToCommand(client, KAC_REMIGNCMDUSAGE);
		return Plugin_Handled;
	}
	
	char f_sCmdName[64];
	GetCmdArg(1, f_sCmdName, sizeof(f_sCmdName));
	
	if(RemoveFromTrie(g_hIgnoredCmds, f_sCmdName))
		KAC_ReplyToCommand(client, KAC_REMIGNCMDSUCCESS, f_sCmdName);
		
	else
		KAC_ReplyToCommand(client, KAC_REMIGNCMDFAILURE, f_sCmdName);
		
	return Plugin_Handled;
}

//- Console Commands -//

public Action Commands_BlockExploit(client, args)
{
	if(args > 0)
	{
		char f_sArg[64];
		GetCmdArg(1, f_sArg, sizeof(f_sArg));
		if(StrEqual(f_sArg, "rcon_password"))
		{
			char f_sAuthID[64], f_sIP[64], f_sCmdString[256];
			GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID));
			GetClientIP(client, f_sIP, sizeof(f_sIP));
			GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
			KAC_Log("'%N'(ID: %s | IP: %s) was banned for Command Usage Violation of Command: sm_menu %s", client, f_sAuthID, f_sIP, f_sCmdString);
			KAC_Ban(client, 0, KAC_CBANNED, "KAC: Exploit Violation");
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action Commands_FilterSay(client, args)
{
	if(!g_bCmdEnabled)
		return Plugin_Continue;
		
	char f_sMsg[256], f_iLen, f_cChar;
	GetCmdArgString(f_sMsg, sizeof(f_sMsg));
	f_iLen = strlen(f_sMsg);
	
	for(int iCount = 0; iCount < f_iLen; iCount++)
	{
		f_cChar = f_sMsg[iCount];
		if(f_cChar < 32 && !IsCharMB(f_cChar))
		{
			KAC_ReplyToCommand(client, KAC_SAYBLOCK);
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

public Action Commands_BlockEntExploit(client, args)
{
	if(!client)
		return Plugin_Continue;
		
	if(!g_bInGame[client])
		return Plugin_Stop;
		
	if(!g_bCmdEnabled)
		return Plugin_Continue;
		
	char f_sCmd[512];
	GetCmdArgString(f_sCmd, sizeof(f_sCmd));
	
	if(strlen(f_sCmd) > 500)
		return Plugin_Stop; // Too long to process.
		
	// This looks ugly but i cannot think of something more Efficient
	if(StrContains(f_sCmd, "point_servercommand") != -1 || StrContains(f_sCmd, "point_clientcommand") != -1 || StrContains(f_sCmd, "logic_timer") != -1 || StrContains(f_sCmd, "quit") != -1 || StrContains(f_sCmd, "sm") != -1 || StrContains(f_sCmd, "quti") != -1 || StrContains(f_sCmd, "restart") != -1 || StrContains(f_sCmd, "alias") != -1 || StrContains(f_sCmd, "admin") != -1 || StrContains(f_sCmd, "ma_") != -1 || StrContains(f_sCmd, "rcon") != -1 || StrContains(f_sCmd, "sv_") != -1 || StrContains(f_sCmd, "mp_") != -1 || StrContains(f_sCmd, "meta") != -1 || StrContains(f_sCmd, "taketimer") != -1 || StrContains(f_sCmd, "logic_relay") != -1 || StrContains(f_sCmd, "logic_auto") != -1 || StrContains(f_sCmd, "logic_autosave") != -1 || StrContains(f_sCmd, "logic_branch") != -1 || StrContains(f_sCmd, "logic_case") != -1 || StrContains(f_sCmd, "logic_collision_pair") != -1 || StrContains(f_sCmd, "logic_compareto") != -1 || StrContains(f_sCmd, "logic_lineto") != -1 || StrContains(f_sCmd, "logic_measure_movement") != -1 || StrContains(f_sCmd, "logic_multicompare") != -1 || StrContains(f_sCmd, "logic_navigation") != -1)
	{
		if(g_bLogCmds)
		{
			char f_sCmdName[64];
			GetCmdArg(0, f_sCmdName, sizeof(f_sCmdName));
			LogToFileEx(g_sCmdLogPath, "%L attempted command: %s %s", client, f_sCmdName, f_sCmd);
		}
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action Commands_CommandListener(iClient, const char[] command, argc)
{
	if(!iClient || iClient == -1)
		return Plugin_Continue;
		
	if(g_bIsFake[iClient]) // We could have added this in the first Check but the Client index can be -1 and wont match any entry in the array
		return Plugin_Continue;
		
	if(!g_bInGame[iClient])
		return Plugin_Stop;
		
	if(!g_bCmdEnabled)
		return Plugin_Continue;
		
	bool f_bBan;
	char f_sCmd[64];
	
	strcopy(f_sCmd, sizeof(f_sCmd), command);
	StringToLower(f_sCmd);
	
	// Check to see if this person is command spamming.
	if (g_iCmdSpam != 0 && !GetTrieValue(g_hIgnoredCmds, f_sCmd, f_bBan) && (StrContains(f_sCmd, "es_") == -1 || StrEqual(f_sCmd, "es_version")) && g_iCmdCount[iClient]++ > g_iCmdSpam)
	{
		char f_sAuthID[64], f_sIP[64], f_sCmdString[128];
		GetClientAuthId(iClient, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID));
		GetClientIP(iClient, f_sIP, sizeof(f_sIP));
		GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
		KAC_Log("'%N'(ID: %s | IP: %s) was kicked for Command Spamming: %s %s", iClient, f_sAuthID, f_sIP, command, f_sCmdString);
		KAC_Kick(iClient, KAC_KCMDSPAM);
		
		return Plugin_Stop;
	}
	
	if(GetTrieValue(g_hBlockedCmds, f_sCmd, f_bBan))
	{
		if(f_bBan)
		{
			char f_sAuthID[64], f_sIP[64], f_sCmdString[256];
			GetClientAuthId(iClient, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID));
			GetClientIP(iClient, f_sIP, sizeof(f_sIP));
			GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
			KAC_Log("'%N'(ID: %s | IP: %s) was banned for Command Usage Violation of Command: %s %s", iClient, f_sAuthID, f_sIP, command, f_sCmdString);
			KAC_Ban(iClient, 0, KAC_CBANNED, "KAC: Command %s Violation", command);
		}
		
		return Plugin_Stop;
	}
	
	if(g_bLogCmds)
	{
		char f_sCmdString[256];
		GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
		LogToFileEx(g_sCmdLogPath, "%L used Command: %s %s", iClient, command, f_sCmdString);
	}
	
	return Plugin_Continue;
}

public Action Commands_ClientCheck(client, args)
{
	if(!client || g_bIsFake[client])
		return Plugin_Continue;
		
	if(!g_bInGame[client])
		return Plugin_Stop;
		
	if (!g_bCmdEnabled)
		return Plugin_Continue;
		
	char f_sCmd[64];
	bool f_bBan;
	GetCmdArg(0, f_sCmd, sizeof(f_sCmd));
	StringToLower(f_sCmd);
	
	if(GetTrieValue(g_hBlockedCmds, f_sCmd, f_bBan))
	{
		if(f_bBan)
		{
			char f_sAuthID[64], f_sIP[64], f_sCmdString[256];
			GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID));
			GetClientIP(client, f_sIP, sizeof(f_sIP));
			GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
			KAC_Log("'%N'(ID: %s | IP: %s) was banned for Command Usage Violation of Command: %s %s", client, f_sAuthID, f_sIP, f_sCmd, f_sCmdString);
			KAC_Ban(client, 0, KAC_CBANNED, "KAC: Command %s Violation", f_sCmd);
		}
		
		return Plugin_Stop;
	}
	
	if(g_bLogCmds)
	{
		char f_sCmdString[256];
		GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
		LogToFileEx(g_sCmdLogPath, "%L used Command: %s %s", client, f_sCmd, f_sCmdString);
	}
	
	return Plugin_Continue;
}

public Action Commands_SpamCheck(client, args)
{
	if(!client || g_bIsFake[client])
		return Plugin_Continue;
		
	if(!g_bInGame[client])
		return Plugin_Stop;
		
	if (!g_bCmdEnabled)
		return Plugin_Continue;
		
	bool f_bBan;
	char f_sCmd[64];
	GetCmdArg(0, f_sCmd, sizeof(f_sCmd)); // This command's name.
	StringToLower(f_sCmd);
	
	if(g_iCmdSpam != 0 && !GetTrieValue(g_hIgnoredCmds, f_sCmd, f_bBan) && g_iCmdCount[client]++ > g_iCmdSpam)
	{
		char f_sAuthID[64], f_sIP[64], f_sCmdString[128];
		GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID));
		GetClientIP(client, f_sIP, sizeof(f_sIP));
		GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
		KAC_Log("'%N'(ID: %s | IP: %s) was kicked for Command Spamming: %s %s", client, f_sAuthID, f_sIP, f_sCmd, f_sCmdString);
		KAC_Kick(client, KAC_KCMDSPAM);
		
		return Plugin_Stop;
	}
	
	if(GetTrieValue(g_hBlockedCmds, f_sCmd, f_bBan))
	{
		if(f_bBan)
		{
			char f_sAuthID[64], f_sIP[64], f_sCmdString[256];
			GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID));
			GetClientIP(client, f_sIP, sizeof(f_sIP));
			GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
			KAC_Log("'%N(ID: %s | IP: %s) was banned for Command Usage Violation of Command: %s %s", client, f_sAuthID, f_sIP, f_sCmd, f_sCmdString);
			KAC_Ban(client, 0, KAC_CBANNED, "KAC: Command '%s' Violation", f_sCmd);
		}
		
		return Plugin_Stop;
	}
	
	if(g_bLogCmds)
	{
		char f_sCmdString[256];
		GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
		LogToFileEx(g_sCmdLogPath, "'%L' used Command: %s %s", client, f_sCmd, f_sCmdString);
	}
	
	return Plugin_Continue;
}

//- Timers -//

public Action Commands_CountReset(Handle timer, any args)
{
	if(!g_bCmdEnabled)
	{
		g_hCountReset = INVALID_HANDLE;
		
		return Plugin_Stop;
	}
	for(int iCount = 1; iCount <= MaxClients; iCount++)
		g_iCmdCount[iCount] = 0;
		
	return Plugin_Continue;
}

//- Hooks -//

public Commands_CmdEnableChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	bool f_bEnabled = GetConVarBool(convar);
	if(f_bEnabled == g_bCmdEnabled)
		return;
		
	if(f_bEnabled)
	{
		if(g_hCountReset == INVALID_HANDLE)
			g_hCountReset = CreateTimer(1.0, Commands_CountReset, _, TIMER_REPEAT);
			
		g_bCmdEnabled = true;
		g_iCmdStatus = Status_Register(KAC_CMDMOD, KAC_ON);
			
		if(!g_iCmdSpam)
			g_iCmdSpamStatus = Status_Register(KAC_CMDSPAM, KAC_OFF);
			
		else
			g_iCmdSpamStatus = Status_Register(KAC_CMDSPAM, KAC_ON);
	}
	
	else if(!f_bEnabled)
	{
		if(g_hCountReset != INVALID_HANDLE)
			CloseHandle(g_hCountReset);
			
		g_hCountReset = INVALID_HANDLE;
		g_bCmdEnabled = false;
		Status_Report(g_iCmdStatus, KAC_OFF);
		Status_Report(g_iCmdSpamStatus, KAC_DISABLED);
	}
}

public void Commands_CmdSpamChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_iCmdSpam = GetConVarInt(convar);
	
	if(!g_bCmdEnabled)
		Status_Report(g_iCmdSpamStatus, KAC_DISABLED);
		
	else if(!g_iCmdSpam)
		Status_Report(g_iCmdSpamStatus, KAC_OFF);
		
	else
		Status_Report(g_iCmdSpamStatus, KAC_ON);
}

public void Commands_CmdLogChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bLogCmds = GetConVarBool(convar);
}