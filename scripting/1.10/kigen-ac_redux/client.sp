// Copyright (C) 2007-2011 CodingDirect LLC
// This File is Licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details


#define MAX_CONNECTIONS 128 // Sourcemod says their official max is 65, but Source's max is up to 128

Handle g_hCVar_Client_Enable, g_hCVar_ClientAntiRespawn, g_hCVar_Client_NameProtect_Action, g_hCVar_Client_AntiSpamConnect, g_hCVar_Client_AntiSpamConnect_Action;
bool g_bClientEnable, g_bClientAntiRespawn;
int g_iClientNameProtect, g_iClientAntiSpamConnect, g_iClientAntiSpamConnectAction; 

StringMap g_hClientSpawned;
char g_cClientConnections[MAX_CONNECTIONS][64];
int g_iClientClass[MAXPLAYERS + 1] =  { -1, ... };
int g_iClientStatus, g_iClientAntiRespawnStatus, g_iClientNameProtectStatus;
bool g_bClientMapStarted;


//- Plugin Functions -//

public void Client_OnPluginStart()
{
	g_hCVar_Client_Enable = AutoExecConfig_CreateConVar("kacr_client_enable", "1", "Enable the Client Protection Module", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bClientEnable = GetConVarBool(g_hCVar_Client_Enable);
	
	if (g_hGame == Engine_CSS || g_hGame == Engine_CSGO)
	{
		g_hCVar_ClientAntiRespawn = AutoExecConfig_CreateConVar("kacr_client_antirejoin", "1", "This will prevent Clients from leaving the Game and then rejoining to Respawn", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
		g_bClientAntiRespawn = GetConVarBool(g_hCVar_ClientAntiRespawn);
		
		g_hClientSpawned = new StringMap();
		
		HookConVarChange(g_hCVar_ClientAntiRespawn, ConVarChanged_Client_AntiRespawn);
		
		HookEvent("player_spawn", Client_PlayerSpawn);
		HookEvent("player_death", Client_PlayerDeath);
		HookEvent("round_start", Client_RoundStart);
		HookEvent("round_end", Client_CleanEvent);
		
		RegConsoleCmd("joinclass", Client_JoinClass);
	}
	
	g_hCVar_Client_NameProtect_Action = AutoExecConfig_CreateConVar("kacr_client_nameprotect_action", "1040", "Action(s) to take when someone has an invalid Name, Time Bans will be 1 min. Protects the Server from Crashes and Hacks", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0);
	g_iClientNameProtect = GetConVarInt(g_hCVar_Client_NameProtect_Action);
	//
	g_hCVar_Client_AntiSpamConnect = AutoExecConfig_CreateConVar("kacr_client_antispamconnect", "15", "Seconds to prevent Someone from reestablishing a Connection. This will also set the Time for 'kacr_client_antispamconnect_action', Round down to whole Minutes (0 = Disabled)", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 120.0);
	g_iClientAntiSpamConnect = GetConVarInt(g_hCVar_Client_AntiSpamConnect);
	g_hCVar_Client_AntiSpamConnect_Action = AutoExecConfig_CreateConVar("kacr_client_antispamconnect_action", "1032", "Action(s) to take when someone does Spam Connect, Bantimes will be set with 'kacr_client_antispamconnect'", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0);
	g_iClientAntiSpamConnectAction = GetConVarInt(g_hCVar_Client_AntiSpamConnect_Action);
	
	if (g_bClientEnable)
	{
		g_iClientStatus = Status_Register(KACR_CLIENTMOD, KACR_ON);
		if (g_hGame == Engine_CSS || g_hGame == Engine_CSGO)
		{
			if (g_bClientAntiRespawn)
				g_iClientAntiRespawnStatus = Status_Register(KACR_CLIENTANTIRESPAWN, KACR_ON);
				
			else
				g_iClientAntiRespawnStatus = Status_Register(KACR_CLIENTANTIRESPAWN, KACR_OFF);
		}
		
		if (g_iClientNameProtect)
			g_iClientNameProtectStatus = Status_Register(KACR_CLIENTNAMEPROTECT, KACR_ON);
			
		else
			g_iClientNameProtectStatus = Status_Register(KACR_CLIENTNAMEPROTECT, KACR_OFF);
	}
	
	else
	{
		g_iClientStatus = Status_Register(KACR_CLIENTMOD, KACR_OFF);
		if (g_hGame == Engine_CSS || g_hGame == Engine_CSGO)
			g_iClientAntiRespawnStatus = Status_Register(KACR_CLIENTANTIRESPAWN, KACR_DISABLED);
			
		g_iClientNameProtectStatus = Status_Register(KACR_CLIENTNAMEPROTECT, KACR_DISABLED);
	}
	
	HookConVarChange(g_hCVar_Client_Enable, ConVarChanged_Client_Enable);
	HookConVarChange(g_hCVar_Client_NameProtect_Action, ConVarChanged_Client_NameProtectAction);
	HookConVarChange(g_hCVar_Client_AntiSpamConnect, ConVarChanged_Client_AntiSpamConnect);
	HookConVarChange(g_hCVar_Client_AntiSpamConnect_Action, ConVarChanged_Client_AntiSpamConnectAction);
	
	RegConsoleCmd("autobuy", Client_Autobuy);
}


//- Commands -//

public Action Client_JoinClass(client, args)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn || !g_bClientMapStarted || client < 1 || IsFakeClient(client) || GetClientTeam(client) < 2)
		return Plugin_Continue;
		
	char f_sAuthID[64], f_sTemp[64];
	int f_iTemp;
	if (!GetClientAuthId(client, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID)))
		return Plugin_Continue;
		
	if (!g_hClientSpawned.GetValue(f_sAuthID, f_iTemp))
		return Plugin_Continue;
		
	GetCmdArgString(f_sTemp, sizeof(f_sTemp));
	
	g_iClientClass[client] = StringToInt(f_sTemp);
	if (g_iClientClass[client] < 0)
		g_iClientClass[client] = 0;
		
	FakeClientCommandEx(client, "spec_mode");
	
	return Plugin_Handled;
}

public Action Client_Autobuy(client, args)
{
	if (client < 1)
		return Plugin_Continue;
		
	char f_sAutobuy[256], f_sArg[64];
	int i, t;
	
	GetClientInfo(client, "cl_autobuy", f_sAutobuy, sizeof(f_sAutobuy));
	
	if (strlen(f_sAutobuy) > 255)
		return Plugin_Stop;
		
	i = 0;
	t = BreakString(f_sAutobuy, f_sArg, sizeof(f_sArg));
	while (t != -1)
	{
		if (strlen(f_sArg) > 30)
			return Plugin_Stop;
			
		i += t;
		t = BreakString(f_sAutobuy[i], f_sArg, sizeof(f_sArg));
	}
	
	if (strlen(f_sArg) > 30)
		return Plugin_Stop;
		
	return Plugin_Continue;
}

public void Client_OnMapEnd()
{
	g_bClientMapStarted = false;
	
	for (int i = 0; i < MAX_CONNECTIONS; i++)
		strcopy(g_cClientConnections[i], 64, "");
		
	if (g_hGame == Engine_CSS || g_hGame == Engine_CSGO)
		Client_CleanEvent(INVALID_HANDLE, "", false);
}


//- Timers -//

public Action Client_AntiSpamConnectTimer(Handle timer, any i)
{
	strcopy(g_cClientConnections[i], 64, "");
	
	return Plugin_Stop;
}


//- Hooks -//

public Action Client_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn)
		return Plugin_Continue;
		
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	char f_sAuthID[64];
	if (client < 1 || GetClientTeam(client) < 2 || !GetClientAuthId(client, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID)))
		return Plugin_Continue;
		
	g_hClientSpawned.Remove(f_sAuthID);
	
	return Plugin_Continue
}

public Action Client_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn)
		return Plugin_Continue;
		
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	char f_sAuthID[64];
	if (client < 1 || !GetClientAuthId(client, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID)))
		return Plugin_Continue;
		
	g_hClientSpawned.SetValue(f_sAuthID, true);
	
	return Plugin_Continue
}

public Action Client_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	g_bClientMapStarted = true;
}

public Action Client_CleanEvent(Handle event, const char[] name, bool dontBroadcast)
{
	CloseHandle(g_hClientSpawned); // Really needed? What does this even do?
	g_hClientSpawned = new StringMap();
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_bInGame[i] && g_iClientClass[i] != -1)
		{
			FakeClientCommandEx(i, "joinclass %d", g_iClientClass[i]);
			g_iClientClass[i] = -1;
		}
	}
}

bool Client_OnClientConnect(iClient, char[] rejectmsg, size)
{
	if (!g_bClientEnable)
		return true;
		
	char f_sClientIP[64];
	GetClientIP(iClient, f_sClientIP, sizeof(f_sClientIP));
	
	if (g_iClientAntiSpamConnect > 0 && g_iClientAntiSpamConnectAction > 0)
	{
		for (int i = 0; i < MAX_CONNECTIONS; i++)
		{
			if (StrEqual(g_cClientConnections[i], f_sClientIP))
			{
				int iResult = g_iClientAntiSpamConnectAction;
				bool bActions[KACR_Action_Count];
				KACR_ActionCheck(iResult, bActions);
				if(bActions[KACR_ActionID_Crash] || bActions[KACR_ActionID_AskSteamAdmin]) // Not Supported
				{
					KACR_Log(false, "[Warning] 'kacr_client_antispamconnect_action' cannot be used with Action 32 or 512, running without them");
					if(bActions[KACR_ActionID_Crash])
						iResult -= KACR_Action_Crash;
						
					if(bActions[KACR_ActionID_AskSteamAdmin])
						iResult -= KACR_Action_AskSteamAdmin;
				}
				
				if(bActions[KACR_ActionID_Kick]) // We do refuse the Client, so we cannot kick him or somethin
					iResult -= KACR_Action_Kick;
					
				if(bActions[KACR_ActionID_TimeBan] || bActions[KACR_ActionID_ServerBan] || bActions[KACR_ActionID_ServerTimeBan] || bActions[KACR_ActionID_ServerTimeBan] || bActions[KACR_ActionID_Kick]) // All of theese do also kick the Client so its equvivalent to refusing him
				{
					KACR_Action(iClient, iResult, RoundToFloor(view_as<float>(g_iClientAntiSpamConnect) / 60), "Please wait a bit before retrying to connect", "[KACR] '%L' did Spam the Server with Connects", iClient); // We retrive the Time in Seconds, so we need to convert them to Minutes and make sure that its still a Integer
					return false;
				}
			}
		}
		
		for (int i = 0; i < MAX_CONNECTIONS; i++)
		{
			if (g_cClientConnections[i][0] == '\0')
			{
				strcopy(g_cClientConnections[i], 64, f_sClientIP);
				CreateTimer(view_as<float>(g_iClientAntiSpamConnect), Client_AntiSpamConnectTimer, i);
				
				break;
			}
		}
	}
	
	if (g_iClientNameProtect)
	{
		int iResult = g_iClientNameProtect;
		bool bActions[KACR_Action_Count];
		KACR_ActionCheck(iResult, bActions);
		
		if (bActions[KACR_ActionID_Crash]) // Not Supported
		{
			KACR_Log(false, "[Warning] 'kacr_client_nameprotect_action' cannot be used with Action 32 (Crash Client), running without them");
			iResult -= 32;
		}
		
		if (bActions[KACR_ActionID_AskSteamAdmin]) // Not Supported
		{
			KACR_Log(false, "[Warning] 'kacr_client_nameprotect_action' cannot be used with Action 512 (AskSteamAdmin), running without them");
			iResult = iResult  - 512;
		}
		
		if (bActions[KACR_ActionID_Kick]) // We do refuse the Client, so we cannot kick him or somethin
			iResult = iResult  - 16;
			
		if (bActions[KACR_ActionID_TimeBan] || bActions[KACR_ActionID_ServerBan] || bActions[KACR_ActionID_ServerTimeBan] || bActions[KACR_ActionID_ServerTimeBan] || bActions[KACR_ActionID_Kick]) // All of theese do also kick the Client so its equvivalent to refusing him
		{
			char f_sName[64], f_cChar;
			int f_iSize;
			bool f_bWhiteSpace = true;
			
			GetClientName(iClient, f_sName, sizeof(f_sName));
			f_iSize = strlen(f_sName);
			
			if (f_iSize == 0 || f_sName[0] == '&') // Blank name or &???
			{
				Format(rejectmsg, size, "Please change your Name");
				KACR_Action(iClient, iResult, 1, rejectmsg, "[KACR] '%L' tryed to connect with an invalid Name", iClient) // 1 Min Time Ban
				return false;
			}
			
			for (int i = 0; i < f_iSize; i++)
			{
				f_cChar = f_sName[i];
				if (!IsCharSpace(f_cChar))
					f_bWhiteSpace = false; // True if the entire Name is an Whitespace (there cant be Whitespaces after the Name)
					
				if (IsCharMB(f_cChar))
				{
					i++;
					if (f_cChar == 194 && f_sName[i] == 160)
					{
						Format(rejectmsg, size, "Please change your Name");
						KACR_Action(iClient, iResult, 1, rejectmsg, "[KACR] '%L' tryed to connect with an invalid Name", iClient) // 1 Min Time Ban
						return false;
					}
				}
				
				else if (f_cChar < 32)
				{
					Format(rejectmsg, size, "Please change your Name");
					KACR_Action(iClient, iResult, 1, rejectmsg, "[KACR] '%L' tryed to connect with an invalid Name", iClient) // 1 Min Time Ban
					return false;
				}
			}
			
			if (f_bWhiteSpace) // The entire Name is an Whitespace
			{
				Format(rejectmsg, size, "Please change your Name");
				KACR_Action(iClient, iResult, 1, rejectmsg, "[KACR] '%L' tryed to connect with an invalid Name", iClient) // 1 Min Time Ban
				return false;
			}
			
		}
		
		return true;
	}
	
	return true;
}

/*
* Tests whether the Clients Name is good or bad
*
* @param iClient		Client UID.
* @return				True if the Name is Valid, False if not
*/
/*bool CheckClientName(int iCLient) // TODO: Implement this to outsource the Client_OnClientConnect Checks
{
	return true;
}*/

public void OnClientSettingsChanged(iClient)
{
	if (!g_bClientEnable || !g_iClientNameProtect || IsFakeClient(iClient))
		return;
		
	char f_sName[64];
	int f_iSize;
	bool f_bWhiteSpace = true;
	
	GetClientName(iClient, f_sName, sizeof(f_sName));
	
	f_iSize = strlen(f_sName);
	
	if (f_iSize == 0) // Blank Name
	{
		char cIP[64];
		GetClientIP(iClient, cIP, sizeof(cIP));
		KACR_Kick(iClient, KACR_CHANGENAME);
		KACR_Log(false, "'%L'<%s> was kicked for having a blank Name (unconnected)", iClient, cIP);
		return;
	}
	
	if (f_sName[0] == '&') // &???
	{
		KACR_Kick(iClient, KACR_CHANGENAME);
		return;
	}
	
	char f_cChar;
	for (int i = 0; i < f_iSize; i++)
	{
		f_cChar = f_sName[i];
		if (!IsCharSpace(f_cChar))
			f_bWhiteSpace = false; // True if the entire Name is an Whitespace (there cant be Whitespaces after the Name)
			
		if (IsCharMB(f_cChar))
		{
			i++;
			if (f_cChar == 194 && f_sName[i] == 160)
			{
				KACR_Kick(iClient, KACR_CHANGENAME);
				return;
			}
		}
		
		else if (f_cChar < 32)
		{
			KACR_Kick(iClient, KACR_CHANGENAME);
			return;
		}
	}
	
	if (f_bWhiteSpace) // The entire Name is an Whitespace
	{
		KACR_Kick(iClient, KACR_CHANGENAME);
		return;
	}
}

public void ConVarChanged_Client_Enable(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bClientEnable = GetConVarBool(hConVar);
	if (g_bClientEnable)
	{
		Status_Report(g_iClientStatus, KACR_ON);
		if (g_hGame == Engine_CSS || g_hGame == Engine_CSGO)
		{
			if (g_bClientAntiRespawn)
				Status_Report(g_iClientAntiRespawnStatus, KACR_ON);
				
			else
				Status_Report(g_iClientAntiRespawnStatus, KACR_OFF);
		}
		
		if (g_iClientNameProtect)
			Status_Report(g_iClientNameProtectStatus, KACR_ON);
			
		else
			Status_Report(g_iClientNameProtectStatus, KACR_OFF);
	}
	
	else
	{
		Status_Report(g_iClientStatus, KACR_OFF);
		if (g_hGame == Engine_CSS || g_hGame == Engine_CSGO)
			Status_Report(g_iClientAntiRespawnStatus, KACR_DISABLED);
			
		Status_Report(g_iClientNameProtectStatus, KACR_DISABLED);
	}
}

public void ConVarChanged_Client_AntiRespawn(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bClientAntiRespawn = GetConVarBool(hConVar);
	if (g_bClientEnable)
	{
		if (g_bClientAntiRespawn)
			Status_Report(g_iClientAntiRespawnStatus, KACR_ON);
			
		else
			Status_Report(g_iClientAntiRespawnStatus, KACR_OFF);
	}
}


public void ConVarChanged_Client_NameProtectAction(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_iClientNameProtect = GetConVarInt(hConVar);
	if (g_bClientEnable)
	{
		if (g_iClientNameProtect)
			Status_Report(g_iClientNameProtectStatus, KACR_ON);
			
		else
			Status_Report(g_iClientNameProtectStatus, KACR_OFF);
	}
}

public void ConVarChanged_Client_AntiSpamConnect(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_iClientAntiSpamConnect = GetConVarInt(hConVar);
}

public void ConVarChanged_Client_AntiSpamConnectAction(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_iClientAntiSpamConnectAction = GetConVarInt(hConVar);
}