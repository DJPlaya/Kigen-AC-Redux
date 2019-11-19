// Copyright (C) 2007-2011 CodingDirect LLC
// This File is Licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details


#define MAX_CONNECTIONS 128 // Sourcemod says their max is 65, but Source's max is up to 128

Handle g_hCVarClientEnable, g_hCVarClientAntiRespawn, g_hCVarClientNameProtect, g_hCVarClientAntiSpamConnect, g_hCVarClientAntiSpamConnectAction;
bool g_bClientEnable, g_bClientAntiRespawn;
int g_iClientNameProtect, g_iClientAntiSpamConnect, g_iClientAntiSpamConnectAction; 

StringMap g_hClientSpawned;
char g_sClientConnections[MAX_CONNECTIONS][64];
int g_iClientClass[MAXPLAYERS + 1] =  { -1, ... };
int g_iClientStatus, g_iClientAntiRespawnStatus, g_iClientNameProtectStatus;
bool g_bClientMapStarted;


//- Plugin Functions -//

public void Client_OnPluginStart()
{
	g_hCVarClientEnable = AutoExecConfig_CreateConVar("kacr_client_enable", "1", "Enable the Client Protection Module", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bClientEnable = GetConVarBool(g_hCVarClientEnable);
	
	if (g_hGame == Engine_CSS || g_hGame == Engine_CSGO)
	{
		g_hCVarClientAntiRespawn = AutoExecConfig_CreateConVar("kacr_client_antirejoin", "0", "This will prevent Clients from leaving the Game and then rejoining to Respawn", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
		g_bClientAntiRespawn = GetConVarBool(g_hCVarClientAntiRespawn);
		
		g_hClientSpawned = new StringMap();
		
		HookConVarChange(g_hCVarClientAntiRespawn, Client_AntiRespawnChange);
		
		HookEvent("player_spawn", Client_PlayerSpawn);
		HookEvent("player_death", Client_PlayerDeath);
		HookEvent("round_start", Client_RoundStart);
		HookEvent("round_end", Client_CleanEvent);
		
		RegConsoleCmd("joinclass", Client_JoinClass);
	}
	
	g_hCVarClientNameProtect = AutoExecConfig_CreateConVar("kacr_client_nameprotect_action", "1040", "Action(s) to take when someone has an invalid Name, Time Bans will be 1 min. Protects the Server from Crashes and Hacks (0 = Disabled)", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0);
	g_iClientNameProtect = GetConVarInt(g_hCVarClientNameProtect);
	//
	g_hCVarClientAntiSpamConnect = AutoExecConfig_CreateConVar("kacr_client_antispamconnect", "0", "Seconds to prevent someone from restablishing a Connection. 0 to disable", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 120.0);
	g_iClientAntiSpamConnect = GetConVarInt(g_hCVarClientAntiSpamConnect);
	g_hCVarClientAntiSpamConnectAction = AutoExecConfig_CreateConVar("kacr_client_antispamconnect_action", "1032", "Action(s) to take when someone does Spam Connect, Time Bans will be 1 min", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0);
	g_iClientAntiSpamConnectAction = GetConVarInt(g_hCVarClientAntiSpamConnectAction);
	
	if (g_bClientEnable)
	{
		g_iClientStatus = Status_Register(KACR_CLIENTMOD, KACR_ON);
		if (g_hGame == Engine_CSS)
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
		if (g_hGame == Engine_CSS)
			g_iClientAntiRespawnStatus = Status_Register(KACR_CLIENTANTIRESPAWN, KACR_DISABLED);
			
		g_iClientNameProtectStatus = Status_Register(KACR_CLIENTNAMEPROTECT, KACR_DISABLED);
	}
	
	HookConVarChange(g_hCVarClientEnable, Client_EnableChange);
	HookConVarChange(g_hCVarClientNameProtect, Client_NameProtectActionChange);
	HookConVarChange(g_hCVarClientAntiSpamConnect, Client_AntiSpamConnectChange);
	HookConVarChange(g_hCVarClientAntiSpamConnectAction, Client_AntiSpamConnectActionChange);
	
	RegConsoleCmd("autobuy", Client_Autobuy);
}


//- Commands -//

public Action Client_JoinClass(client, args)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn || !g_bClientMapStarted || !client || IsFakeClient(client) || GetClientTeam(client) < 2)
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
	if (!client)
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
		strcopy(g_sClientConnections[i], 64, "");
		
	if (g_hGame == Engine_CSS)
		Client_CleanEvent(INVALID_HANDLE, "", false);
}


//- Timers -//

public Action Client_AntiSpamConnectTimer(Handle timer, any i)
{
	strcopy(g_sClientConnections[i], 64, "");
	
	return Plugin_Stop;
}


//- Hooks -//

public Action Client_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn)
		return Plugin_Continue;
		
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	char f_sAuthID[64];
	if (!client || GetClientTeam(client) < 2 || !GetClientAuthId(client, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID)))
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
	if (!client || !GetClientAuthId(client, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID)))
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
	CloseHandle(g_hClientSpawned); // Really needed? We could just clear it? // TODO: Replace with 'g_hClientSpawned.Close()' once we dropped legacy support
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
	
	if (g_iClientAntiSpamConnect > 0)
	{
		for (int i = 0; i < MAX_CONNECTIONS; i++)
		{
			if (StrEqual(g_sClientConnections[i], f_sClientIP))
			{
				int iResult = g_iClientAntiSpamConnectAction;
				bool bActions[KACR_Action_Count] = KACR_ActionCheck(iResult);
				if(bActions[KACR_Action_Crash] || bActions[KACR_Action_AskSteamAdmin]) // Not Supported
				{
					KACR_Log("[Warning] 'kacr_client_antispamconnect_action' cannot be used with Action 32 or 512, running without them");
					if(bActions[KACR_Action_Crash])
						iResult = iResult - 32;
						
					if(bActions[KACR_Action_AskSteamAdmin])
						iResult = iResult  - 512;
				}
				
				if(bActions[KACR_Action_Kick]) // We do refuse the Client, so we cannot kick him or somethin
					iResult = iResult  - 16;
					
				if(bActions[KACR_Action_TimeBan] || bActions[KACR_Action_ServerBan] || bActions[KACR_Action_ServerTimeBan] || bActions[KACR_Action_ServerTimeBan] || bActions[KACR_Action_Kick]) // All of theese do also kick the Client so its equvivalent to refusing him
				{
					KACR_Action(iClient, iResult, 1, "Please wait a bit before retrying to connect", "[KACR] '%L' did Spam the Server with Connects", iClient) // 1 Min Time Ban
					return false;
				}
			}
		}
		
		for (int i = 0; i < MAX_CONNECTIONS; i++)
		{
			if (g_sClientConnections[i][0] == '\0')
			{
				strcopy(g_sClientConnections[i], 64, f_sClientIP);
				CreateTimer(view_as<float>(g_iClientAntiSpamConnect), Client_AntiSpamConnectTimer, i);
				
				break;
			}
		}
	}
	
	if (g_iClientNameProtect)
	{
		int iResult = g_iClientNameProtect;
		bool bActions[KACR_Action_Count] = KACR_ActionCheck(iResult);
		
		if(bActions[KACR_Action_Crash] || bActions[KACR_Action_AskSteamAdmin]) // Not Supported
		{
			KACR_Log("[Warning] 'kacr_client_antispamconnect_action' cannot be used with Action 32 or 512, running without them");
			if(bActions[KACR_Action_Crash])
				iResult = iResult - 32;
				
			if(bActions[KACR_Action_AskSteamAdmin])
				iResult = iResult  - 512;
		}
		
		if(bActions[KACR_Action_Kick]) // We do refuse the Client, so we cannot kick him or somethin
			iResult = iResult  - 16;
			
		if(bActions[KACR_Action_TimeBan] || bActions[KACR_Action_ServerBan] || bActions[KACR_Action_ServerTimeBan] || bActions[KACR_Action_ServerTimeBan] || bActions[KACR_Action_Kick]) // All of theese do also kick the Client so its equvivalent to refusing him
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
		char f_sIP[64];
		GetClientIP(iClient, f_sIP, sizeof(f_sIP));
		KACR_Kick(iClient, KACR_CHANGENAME);
		KACR_Log("'%L'<%s> was kicked for having a blank Name (unconnected)", iClient, f_sIP);
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

public void Client_EnableChange(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bClientEnable = GetConVarBool(hConVar);
	if (g_bClientEnable)
	{
		Status_Report(g_iClientStatus, KACR_ON);
		if (g_hGame == Engine_CSS)
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
		if (g_hGame == Engine_CSS)
			Status_Report(g_iClientAntiRespawnStatus, KACR_DISABLED);
			
		Status_Report(g_iClientNameProtectStatus, KACR_DISABLED);
	}
}

public void Client_AntiRespawnChange(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
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


public void Client_NameProtectActionChange(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
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

public void Client_AntiSpamConnectChange(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_iClientAntiSpamConnect = GetConVarInt(hConVar);
}

public void Client_AntiSpamConnectActionChange(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_iClientAntiSpamConnectAction = GetConVarInt(hConVar);
}