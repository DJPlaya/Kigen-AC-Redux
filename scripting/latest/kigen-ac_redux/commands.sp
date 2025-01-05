/*
	Based on Kigen's Anti-Cheat
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

Handle g_hCountReset, g_hCVarCmdEnable, g_hCVarCmdSpam, g_hCVarCmdLog;
StringMap g_hBlockedCmds, g_hIgnoredCmds;

char g_sCmdLogPath[256];

bool g_bCmdEnabled = true, g_bLogCmds;

int g_iCmdCount[MAXPLAYERS + 1] =  { 0, ... };
int g_iCmdStatus, g_iCmdSpamStatus, g_iCmdSpam = 30;


//- Plugin Functions -//

Commands_OnPluginStart()
{
	g_hCVarCmdEnable = AutoExecConfig_CreateConVar("kacr_cmds_enable", "1", "If the Commands Module of KACR is enabled", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bCmdEnabled = GetConVarBool(g_hCVarCmdEnable);
	
	g_hCVarCmdSpam = AutoExecConfig_CreateConVar("kacr_cmds_spam", "30", "Amount of Commands in one Second before kick. 0 to disable", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 120.0);
	g_iCmdSpam = GetConVarInt(g_hCVarCmdSpam);
	
	g_hCVarCmdLog = AutoExecConfig_CreateConVar("kacr_cmds_log", "0", "Log Command Usage. Use only for debugging Purposes", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bLogCmds = GetConVarBool(g_hCVarCmdLog);
	
	HookConVarChange(g_hCVarCmdEnable, Commands_CmdEnableChange);
	HookConVarChange(g_hCVarCmdSpam, Commands_CmdSpamChange);
	HookConVarChange(g_hCVarCmdLog, Commands_CmdLogChange);
	
	// Setup logging Path
	for (int i = 0; ; i++)
	{
		BuildPath(Path_SM, g_sCmdLogPath, sizeof(g_sCmdLogPath), "logs/KACR_CmdLog_%d.log", i);
		if (!FileExists(g_sCmdLogPath))
			break;
	}
	
	if (g_bCmdEnabled)
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
	
	HookEventEx("player_disconnect", Commands_EventDisconnect, EventHookMode_Pre)
}

Commands_OnAllPluginsLoaded()
{
	Handle f_hConCommand;
	char cConVar[64];
	bool f_bIsCommand, f_iFlags;
	
	g_hBlockedCmds = new StringMap(); // CreateTrie();
	g_hIgnoredCmds = new StringMap(); // CreateTrie();
	
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
	g_hBlockedCmds.SetValue("dumpcountedstrings", false);
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
	
	if (hGame == Engine_Left4Dead || hGame == Engine_Left4Dead2)
	{
		g_hIgnoredCmds.SetValue("choose_closedoor", true);
		g_hIgnoredCmds.SetValue("choose_opendoor", true);
	}
	
	g_hIgnoredCmds.SetValue("buy", true);
	g_hIgnoredCmds.SetValue("buyammo1", true);
	g_hIgnoredCmds.SetValue("buyammo2", true);
	g_hIgnoredCmds.SetValue("use", true);
	
	if (g_bCmdEnabled)
		g_hCountReset = CreateTimer(1.0, Commands_CountReset, _, TIMER_REPEAT);
		
	else
		g_hCountReset = INVALID_HANDLE;
		
	// Leaving this in as a fall back incase game isn't compatible with the command listener.
	if (GetFeatureStatus(FeatureType_Capability, FEATURECAP_COMMANDLISTENER) != FeatureStatus_Available || !AddCommandListener(Commands_CommandListener))
	{
		f_hConCommand = FindFirstConCommand(cConVar, sizeof(cConVar), f_bIsCommand, f_iFlags);
		if (f_hConCommand == INVALID_HANDLE)
			SetFailState("Failed getting first ConCommand");
			
		do
		{
			if (!f_bIsCommand || StrEqual(cConVar, "sm"))
				continue;
				
			if (StrContains(cConVar, "es_") != -1 && !StrEqual(cConVar, "es_version"))
				RegConsoleCmd(cConVar, Commands_ClientCheck);
				
			else
				RegConsoleCmd(cConVar, Commands_SpamCheck);
			
		}
		
		while (FindNextConCommand(f_hConCommand, cConVar, sizeof(cConVar), f_bIsCommand, f_iFlags));
		
		CloseHandle(f_hConCommand);
	}
	
	RegAdminCmd("kacr_addcmd", Commands_AddCmd, ADMFLAG_ROOT, "Adds a command to be blocked by KACR");
	RegAdminCmd("kacr_addignorecmd", Commands_AddIgnoreCmd, ADMFLAG_ROOT, "Adds a command to ignore on command spam");
	RegAdminCmd("kacr_removecmd", Commands_RemoveCmd, ADMFLAG_ROOT, "Removes a command from the block list");
	RegAdminCmd("kacr_removeignorecmd", Commands_RemoveIgnoreCmd, ADMFLAG_ROOT, "Remove a command to ignore");
}

Commands_OnPluginEnd()
{
	if (g_hCountReset != INVALID_HANDLE)
		CloseHandle(g_hCountReset);
}


//- Events -//

public Action Commands_EventDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	char f_sReason[512], f_sTemp[512], f_sIP[64];
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	GetEventString(event, "reason", f_sReason, sizeof(f_sReason));
	GetEventString(event, "name", f_sTemp, sizeof(f_sTemp));
	int f_iLength = strlen(f_sReason) + strlen(f_sTemp);
	GetEventString(event, "networkid", f_sTemp, sizeof(f_sTemp));
	f_iLength += strlen(f_sTemp);
	if (f_iLength > 235)
	{
		KACR_Log("Bad Disconnect Reason, Length '%d', \"%s\"", f_iLength, f_sReason);
		if (client)
		{
			GetClientIP(client, f_sIP, sizeof(f_sIP));
			KACR_Log("'%L'<%s> submitted a bad Disconnect Reason and was banned", client, f_sIP);
			KACR_Ban(client, 0, KACR_BANNED, "KACR: Disconnect Exploit");
		}
		
		SetEventString(event, "reason", "Bad Disconnect Message");
		return Plugin_Continue;
	}
	
	f_iLength = strlen(f_sReason);
	
	for (int iCount; iCount < f_iLength; iCount++)
	{
		if (f_sReason[iCount] < 32)
		{
			if (f_sReason[iCount] != '\n')
			{
				KACR_Log("Bad Disconnect Reason, \"%s\", Lenght = %d", f_sReason, f_iLength);
				if (client)
				{
					GetClientIP(client, f_sIP, sizeof(f_sIP));
					KACR_Log("'%L'<%s> submitted a bad Disconnect. Possible Corruption or Attack", client, f_sIP);
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
		KACR_ReplyToCommand(client, KACR_ADDCMDUSAGE);
		return Plugin_Handled;
	}
	
	char f_sCmdName[64], f_sTemp[8];
	bool f_bBan;
	GetCmdArg(1, f_sCmdName, sizeof(f_sCmdName));
	
	GetCmdArg(2, f_sTemp, sizeof(f_sTemp));
	if (StringToInt(f_sTemp) != 0 || StrEqual(f_sTemp, "ban") || StrEqual(f_sTemp, "yes") || StrEqual(f_sTemp, "true"))
		f_bBan = true;
		
	else
		f_bBan = false;
		
	if (g_hBlockedCmds.SetValue(f_sCmdName, f_bBan))
		KACR_ReplyToCommand(client, KACR_ADDCMDSUCCESS, f_sCmdName);
		
	else
		KACR_ReplyToCommand(client, KACR_ADDCMDFAILURE, f_sCmdName);
		
	return Plugin_Handled;
}

public Action Commands_AddIgnoreCmd(client, args)
{
	if (args != 1)
	{
		KACR_ReplyToCommand(client, KACR_ADDIGNCMDUSAGE);
		return Plugin_Handled;
	}
	
	char f_sCmdName[64];
	
	GetCmdArg(1, f_sCmdName, sizeof(f_sCmdName));
	
	if (g_hIgnoredCmds.SetValue(f_sCmdName, true))
		KACR_ReplyToCommand(client, KACR_ADDIGNCMDSUCCESS, f_sCmdName);
		
	else
		KACR_ReplyToCommand(client, KACR_ADDIGNCMDFAILURE, f_sCmdName);
		
	return Plugin_Handled;
}

public Action Commands_RemoveCmd(client, args)
{
	if (args != 1)
	{
		KACR_ReplyToCommand(client, KACR_REMCMDUSAGE);
		return Plugin_Handled;
	}
	
	char f_sCmdName[64];
	GetCmdArg(1, f_sCmdName, sizeof(f_sCmdName));
	
	if (g_hBlockedCmds.Remove(f_sCmdName))
		KACR_ReplyToCommand(client, KACR_REMCMDSUCCESS, f_sCmdName);
		
	else
		KACR_ReplyToCommand(client, KACR_REMCMDFAILURE, f_sCmdName);
		
	return Plugin_Handled;
}

public Action Commands_RemoveIgnoreCmd(client, args)
{
	if (args != 1)
	{
		KACR_ReplyToCommand(client, KACR_REMIGNCMDUSAGE);
		return Plugin_Handled;
	}
	
	char f_sCmdName[64];
	GetCmdArg(1, f_sCmdName, sizeof(f_sCmdName));
	
	if (g_hIgnoredCmds.Remove(f_sCmdName))
		KACR_ReplyToCommand(client, KACR_REMIGNCMDSUCCESS, f_sCmdName);
		
	else
		KACR_ReplyToCommand(client, KACR_REMIGNCMDFAILURE, f_sCmdName);
		
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
			char f_sIP[64], f_sCmdString[256];
			GetClientIP(client, f_sIP, sizeof(f_sIP));
			GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
			KACR_Log("'%L'<%s> was banned for Command Usage Violation of Command: sm_menu %s", client, f_sIP, f_sCmdString);
			KACR_Ban(client, 0, KACR_CBANNED, "KACR: Exploit Violation");
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

public Action Commands_FilterSay(client, args)
{
	if (!g_bCmdEnabled)
		return Plugin_Continue;
		
	char f_sMsg[256], f_iLen, f_cChar;
	GetCmdArgString(f_sMsg, sizeof(f_sMsg));
	f_iLen = strlen(f_sMsg);
	
	for (int iCount = 0; iCount < f_iLen; iCount++)
	{
		f_cChar = f_sMsg[iCount];
		if (f_cChar < 32 && !IsCharMB(f_cChar))
		{
			KACR_ReplyToCommand(client, KACR_SAYBLOCK);
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

public Action Commands_BlockEntExploit(client, args)
{
	if (client < 1)
		return Plugin_Continue;
		
	if (!g_bInGame[client])
		return Plugin_Stop;
		
	if (!g_bCmdEnabled)
		return Plugin_Continue;
		
	char f_sCmd[512];
	GetCmdArgString(f_sCmd, sizeof(f_sCmd));
	
	if (strlen(f_sCmd) > 500)
		return Plugin_Stop; // Too long to process.
		
	// This looks ugly but i cannot think of something more efficient
	if (StrContains(f_sCmd, "point_servercommand") != -1 || StrContains(f_sCmd, "point_clientcommand") != -1 || StrContains(f_sCmd, "logic_timer") != -1 || StrContains(f_sCmd, "quit") != -1 || StrContains(f_sCmd, "sm") != -1 || StrContains(f_sCmd, "quti") != -1 || StrContains(f_sCmd, "restart") != -1 || StrContains(f_sCmd, "alias") != -1 || StrContains(f_sCmd, "admin") != -1 || StrContains(f_sCmd, "ma_") != -1 || StrContains(f_sCmd, "rcon") != -1 || StrContains(f_sCmd, "sv_") != -1 || StrContains(f_sCmd, "mp_") != -1 || StrContains(f_sCmd, "meta") != -1 || StrContains(f_sCmd, "taketimer") != -1 || StrContains(f_sCmd, "logic_relay") != -1 || StrContains(f_sCmd, "logic_auto") != -1 || StrContains(f_sCmd, "logic_autosave") != -1 || StrContains(f_sCmd, "logic_branch") != -1 || StrContains(f_sCmd, "logic_case") != -1 || StrContains(f_sCmd, "logic_collision_pair") != -1 || StrContains(f_sCmd, "logic_compareto") != -1 || StrContains(f_sCmd, "logic_lineto") != -1 || StrContains(f_sCmd, "logic_measure_movement") != -1 || StrContains(f_sCmd, "logic_multicompare") != -1 || StrContains(f_sCmd, "logic_navigation") != -1)
	{
		if (g_bLogCmds)
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
	if (!g_bCmdEnabled)
		return Plugin_Continue;
		
	if (iClient < 1)
		return Plugin_Continue;
		
	if (g_bIsFake[iClient]) // We could have added this in the first Check but the Client index can be -1 and wont match any entry in the array
		return Plugin_Continue;
		
	if (!g_bInGame[iClient]) // && iClient != 0)
		return Plugin_Stop;
		
	bool f_bBan;
	char f_sCmd[64];
	
	strcopy(f_sCmd, sizeof(f_sCmd), command);
	StringToLower(f_sCmd);
	
	// Check to see if this person is command spamming.
	if (g_iCmdSpam != 0 && !g_hIgnoredCmds.GetValue(f_sCmd, f_bBan) && (StrContains(f_sCmd, "es_") == -1 || StrEqual(f_sCmd, "es_version")) && g_iCmdCount[iClient]++ > g_iCmdSpam)
	{
		char f_sIP[64], f_sCmdString[128];
		GetClientIP(iClient, f_sIP, sizeof(f_sIP));
		GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
		KACR_Log("'%L'<%s> was kicked for Command Spamming: %s %s", iClient, f_sIP, command, f_sCmdString);
		KACR_Kick(iClient, KACR_KCMDSPAM);
		return Plugin_Stop;
	}
	
	if (g_hBlockedCmds.GetValue(f_sCmd, f_bBan))
	{
		if (f_bBan)
		{
			char f_sIP[64], f_sCmdString[256];
			GetClientIP(iClient, f_sIP, sizeof(f_sIP));
			GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
			KACR_Log("'%L'<%s> was banned for Command Usage Violation of Command: %s %s", iClient, f_sIP, command, f_sCmdString);
			KACR_Ban(iClient, 0, KACR_CBANNED, "KACR: Command %s Violation", command);
		}
		
		return Plugin_Stop;
	}
	
	if (g_bLogCmds)
	{
		char f_sIP[64], f_sCmdString[256];
		GetClientIP(iClient, f_sIP, sizeof(f_sIP));
		GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
		LogToFileEx(g_sCmdLogPath, "'%L'<%s> used Command: %s %s", iClient, f_sIP, command, f_sCmdString);
	}
	
	return Plugin_Continue;
}

public Action Commands_ClientCheck(client, args)
{
	if (client < 1 || g_bIsFake[client])
		return Plugin_Continue;
		
	if (!g_bInGame[client])
		return Plugin_Stop;
		
	if (!g_bCmdEnabled)
		return Plugin_Continue;
		
	char f_sCmd[64];
	bool f_bBan;
	GetCmdArg(0, f_sCmd, sizeof(f_sCmd));
	StringToLower(f_sCmd);
	
	if (g_hBlockedCmds.GetValue(f_sCmd, f_bBan))
	{
		if (f_bBan)
		{
			char f_sIP[64], f_sCmdString[256];
			GetClientIP(client, f_sIP, sizeof(f_sIP));
			GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
			KACR_Log("'%L'<%s> was banned for Command Usage Violation of Command: %s %s", client, f_sIP, f_sCmd, f_sCmdString);
			KACR_Ban(client, 0, KACR_CBANNED, "KACR: Command %s Violation", f_sCmd);
		}
		
		return Plugin_Stop;
	}
	
	if (g_bLogCmds)
	{
		char f_sIP[64], f_sCmdString[256];
		GetClientIP(client, f_sIP, sizeof(f_sIP));
		GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
		LogToFileEx(g_sCmdLogPath, "'%L'<%s> used Command: %s %s", client, f_sIP, f_sCmd, f_sCmdString);
	}
	
	return Plugin_Continue;
}

public Action Commands_SpamCheck(client, args)
{
	if (client < 1 || g_bIsFake[client])
		return Plugin_Continue;
		
	if (!g_bInGame[client])
		return Plugin_Stop;
		
	if (!g_bCmdEnabled)
		return Plugin_Continue;
		
	bool f_bBan;
	char f_sCmd[64];
	GetCmdArg(0, f_sCmd, sizeof(f_sCmd)); // This command's name.
	StringToLower(f_sCmd);
	
	if (g_iCmdSpam != 0 && !g_hIgnoredCmds.GetValue(f_sCmd, f_bBan) && g_iCmdCount[client]++ > g_iCmdSpam)
	{
		char f_sIP[64], f_sCmdString[128];
		GetClientIP(client, f_sIP, sizeof(f_sIP));
		GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
		KACR_Log("'%L'<%s> was kicked for Command Spamming: %s %s", client, f_sIP, f_sCmd, f_sCmdString);
		KACR_Kick(client, KACR_KCMDSPAM);
		return Plugin_Stop;
	}
	
	if (g_hBlockedCmds.GetValue(f_sCmd, f_bBan))
	{
		if (f_bBan)
		{
			char f_sIP[64], f_sCmdString[256];
			GetClientIP(client, f_sIP, sizeof(f_sIP));
			GetCmdArgString(f_sCmdString, sizeof(f_sCmdString));
			KACR_Log("'%L'<%s> was banned for Command Usage Violation of Command: %s %s", client, f_sIP, f_sCmd, f_sCmdString);
			KACR_Ban(client, 0, KACR_CBANNED, "KACR: Command '%s' Violation", f_sCmd);
		}
		
		return Plugin_Stop;
	}
	
	if (g_bLogCmds)
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
	if (!g_bCmdEnabled)
	{
		g_hCountReset = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	for (int iCount = 1; iCount <= MaxClients; iCount++)
		g_iCmdCount[iCount] = 0;
		
	return Plugin_Continue;
}


//- Hooks -//

public void Commands_CmdEnableChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	bool f_bEnabled = GetConVarBool(convar);
	if (f_bEnabled == g_bCmdEnabled)
		return;
		
	if (f_bEnabled)
	{
		if (g_hCountReset == INVALID_HANDLE)
			g_hCountReset = CreateTimer(1.0, Commands_CountReset, _, TIMER_REPEAT);
			
		g_bCmdEnabled = true;
		g_iCmdStatus = Status_Register(KACR_CMDMOD, KACR_ON);
		
		if (!g_iCmdSpam)
			g_iCmdSpamStatus = Status_Register(KACR_CMDSPAM, KACR_OFF);
			
		else
			g_iCmdSpamStatus = Status_Register(KACR_CMDSPAM, KACR_ON);
	}
	
	else if (!f_bEnabled)
	{
		if (g_hCountReset != INVALID_HANDLE)
			CloseHandle(g_hCountReset);
			
		g_hCountReset = INVALID_HANDLE;
		g_bCmdEnabled = false;
		Status_Report(g_iCmdStatus, KACR_OFF);
		Status_Report(g_iCmdSpamStatus, KACR_DISABLED);
	}
}

public void Commands_CmdSpamChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_iCmdSpam = GetConVarInt(convar);
	
	if (!g_bCmdEnabled)
		Status_Report(g_iCmdSpamStatus, KACR_DISABLED);
		
	else if (!g_iCmdSpam)
		Status_Report(g_iCmdSpamStatus, KACR_OFF);
		
	else
		Status_Report(g_iCmdSpamStatus, KACR_ON);
}

public void Commands_CmdLogChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bLogCmds = GetConVarBool(convar);
} 