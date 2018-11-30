/*
	Kigen's Anti-Cheat
	Copyright (C) 2007-2011 CodingDirect LLC
	No Copyright (i guess) 2018 FunForBattle
	
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

#define CLIENT

#define MAX_CONNECTIONS 128

Handle g_hCVarClientEnable, g_hCVarClientAntiRespawn, g_hCVarClientNameProtect, g_hCVarClientAntiSpamConnect;
bool g_bClientEnable = true, g_bClientNameProtect = true;
bool g_bClientAntiRespawn;
float g_fClientAntiSpamConnect = 0.0;
int g_iClientStatus, g_iClientAntiRespawnStatus, g_iClientNameProtectStatus;
// int g_iClientAntiSpamConnectStatus;
Handle g_hClientSpawned;
int g_iClientClass[MAXPLAYERS + 1] =  { -1, ... };
char g_sClientConnections[MAX_CONNECTIONS][64];
bool g_bClientMapStarted;

//- Plugin Functions -//

Client_OnPluginStart()
{
	g_hCVarClientEnable = CreateConVar("kac_client_enable", "1", "Enable the Client Protection Module");
	g_bClientEnable = GetConVarBool(g_hCVarClientEnable);
	
	if(g_iGame == GAME_CSS || g_iGame == GAME_CSGO)
	{
		g_hCVarClientAntiRespawn = CreateConVar("kac_client_antirejoin", "0", "This will prevent Clients from leaving the Game then rejoining to Respawn");
		g_bClientAntiRespawn = GetConVarBool(g_hCVarClientAntiRespawn);
		
		g_hClientSpawned = CreateTrie();
		
		HookConVarChange(g_hCVarClientAntiRespawn, Client_AntiRespawnChange);
		
		HookEvent("player_spawn", Client_PlayerSpawn);
		HookEvent("player_death", Client_PlayerDeath);
		HookEvent("round_start", Client_RoundStart);
		HookEvent("round_end", Client_CleanEvent);
		
		RegConsoleCmd("joinclass", Client_JoinClass);
	}
	
	g_hCVarClientNameProtect = CreateConVar("kac_client_nameprotect", "1", "This will protect the Server from name Crashes and Hacks");
	g_bClientNameProtect = GetConVarBool(g_hCVarClientNameProtect);
	
	g_hCVarClientAntiSpamConnect = CreateConVar("kac_client_antispamconnect", "0", "Seconds to prevent someone from restablishing a Connection. 0 to disable", _, true, 0.0, true, 60.0);
	g_fClientAntiSpamConnect = GetConVarFloat(g_hCVarClientAntiSpamConnect);
	
	if(g_bClientEnable)
	{
		g_iClientStatus = Status_Register(KAC_CLIENTMOD, KAC_ON);
		if(g_iGame == GAME_CSS)
		{
			if(g_bClientAntiRespawn)
				g_iClientAntiRespawnStatus = Status_Register(KAC_CLIENTANTIRESPAWN, KAC_ON);
				
			else
				g_iClientAntiRespawnStatus = Status_Register(KAC_CLIENTANTIRESPAWN, KAC_OFF);
		}
		
		if(g_bClientNameProtect)
			g_iClientNameProtectStatus = Status_Register(KAC_CLIENTNAMEPROTECT, KAC_ON);
			
		else
			g_iClientNameProtectStatus = Status_Register(KAC_CLIENTNAMEPROTECT, KAC_OFF);
	}
	
	else
	{
		g_iClientStatus = Status_Register(KAC_CLIENTMOD, KAC_OFF);
		if(g_iGame == GAME_CSS)
			g_iClientAntiRespawnStatus = Status_Register(KAC_CLIENTANTIRESPAWN, KAC_DISABLED);
			
		g_iClientNameProtectStatus = Status_Register(KAC_CLIENTNAMEPROTECT, KAC_DISABLED);
	}
	
	HookConVarChange(g_hCVarClientEnable, Client_EnableChange);
	HookConVarChange(g_hCVarClientNameProtect, Client_NameProtectChange);
	HookConVarChange(g_hCVarClientAntiSpamConnect, Client_AntiSpamConnectChange);
	
	RegConsoleCmd("autobuy", Client_Autobuy);
}

/*Client_OnPluginEnd()
{
}*/

//- Commands -//

public Action Client_JoinClass(client, args)
{
	if(!g_bClientEnable || !g_bClientAntiRespawn || !g_bClientMapStarted || !client || IsFakeClient(client) || GetClientTeam(client) < 2)
		return Plugin_Continue;
		
	char f_sAuthID[64], f_sTemp[64];
	int f_iTemp;
	if(!GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID)))
		return Plugin_Continue;
		
	if(!GetTrieValue(g_hClientSpawned, f_sAuthID, f_iTemp))
		return Plugin_Continue;
		
	GetCmdArgString(f_sTemp, sizeof(f_sTemp));
	
	g_iClientClass[client] = StringToInt(f_sTemp);
	if(g_iClientClass[client] < 0)
			g_iClientClass[client] = 0;
			
	FakeClientCommandEx(client, "spec_mode");
	
	return Plugin_Handled;
}

public Action Client_Autobuy(client, args)
{
	if(!client)
		return Plugin_Continue;
		
	char f_sAutobuy[256], f_sArg[64];
	int i, t;
	
	GetClientInfo(client, "cl_autobuy", f_sAutobuy, sizeof(f_sAutobuy));
	
	if(strlen(f_sAutobuy) > 255)
		return Plugin_Stop;
		
	i = 0;
	t = BreakString(f_sAutobuy, f_sArg, sizeof(f_sArg));
	while(t != -1)
	{
		if(strlen(f_sArg) > 30)
			return Plugin_Stop;
			
		i += t;
		t = BreakString(f_sAutobuy[i], f_sArg, sizeof(f_sArg));
	}
	
	if(strlen(f_sArg) > 30)
		return Plugin_Stop;
		
	return Plugin_Continue;
}

//- Map -//
/*Client_OnMapStart() // Currently unused
{
	
}*/

Client_OnMapEnd()
{
	g_bClientMapStarted = false;
	
	for(int i = 0; i < MAX_CONNECTIONS; i++)
		strcopy(g_sClientConnections[i], 64, "");
		
	if(g_iGame == GAME_CSS)
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
	if(!g_bClientEnable || !g_bClientAntiRespawn)
		return Plugin_Continue;
		
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	char f_sAuthID[64];
	if(!client || GetClientTeam(client) < 2 || !GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID)))
		return Plugin_Continue;
		
	RemoveFromTrie(g_hClientSpawned, f_sAuthID);
	
	return Plugin_Continue
}

public Action Client_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if(!g_bClientEnable || !g_bClientAntiRespawn)
		return Plugin_Continue;
		
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	char f_sAuthID[64];
	if(!client || !GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID)))
		return Plugin_Continue;
		
	SetTrieValue(g_hClientSpawned, f_sAuthID, true);
	
	return Plugin_Continue
}

public Action Client_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	g_bClientMapStarted = true;
}

public Action Client_CleanEvent(Handle event, const char[] name, bool dontBroadcast)
{
	CloseHandle(g_hClientSpawned);
	g_hClientSpawned = CreateTrie();
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(g_bInGame[i] && g_iClientClass[i] != -1)
		{
			FakeClientCommandEx(i, "joinclass %d", g_iClientClass[i]);
			g_iClientClass[i] = -1;
		}
	}
}

bool Client_OnClientConnect(client, char[] rejectmsg, size)
{
	if(!g_bClientEnable)
		return true;
		
	if(g_fClientAntiSpamConnect > 0.0)
	{
		char f_sClientIP[64];
		
		GetClientIP(client, f_sClientIP, sizeof(f_sClientIP));
		
		for(int i = 0; i < MAX_CONNECTIONS; i++)
		{
			if(StrEqual(g_sClientConnections[i], f_sClientIP))
			{
				Format(rejectmsg, size, "Please wait one minute before retrying to connect");
				BanIdentity(f_sClientIP, 1, BANFLAG_IP, "Spam Connecting"); // We do not want this hooked, so no source.
				return false;
			}
		}
		
		for(int i = 0; i < MAX_CONNECTIONS; i++)
		{
			if(g_sClientConnections[i][0] == '\0')
			{
				strcopy(g_sClientConnections[i], 64, f_sClientIP);
				CreateTimer(g_fClientAntiSpamConnect, Client_AntiSpamConnectTimer, i);
				break;
			}
		}
	}
	
	if(g_bClientNameProtect)
	{
		char f_sName[64], f_cChar;
		int f_iSize;
		bool f_bWhiteSpace = true;
		
		GetClientName(client, f_sName, sizeof(f_sName));
		
		f_iSize = strlen(f_sName);
		
		if(f_iSize < 1 || f_sName[0] == '&')
		{
			Format(rejectmsg, size, "Please change your name");
			return false;
		}
		
		for(int i = 0; i < f_iSize; i++)
		{
			f_cChar = f_sName[i];
			if(!IsCharSpace(f_cChar))
				f_bWhiteSpace = false;
				
			if(IsCharMB(f_cChar))
			{
				i++;
				if(f_cChar == 194 && f_sName[i] == 160)
				{
					Format(rejectmsg, size, "Please change your name");
					return false;
				}
			}
			
			else if(f_cChar < 32)
			{
				Format(rejectmsg, size, "Please change your name");
				return false;
			}
		}
		
		if(f_bWhiteSpace)
		{
			Format(rejectmsg, size, "Please change your name");
			return false;
		}
		
	}
	
	return true;
}

public OnClientSettingsChanged(client)
{
	if(!g_bClientEnable || !g_bClientNameProtect || IsFakeClient(client))
		return;
		
	char f_sName[64], f_sAuthID[64], f_sIP[64], f_cChar;
	int f_iSize;
	bool f_bWhiteSpace = true;
	
	GetClientName(client, f_sName, 64);
	GetClientAuthId(client, AuthId_Steam3, f_sAuthID, 64);
	GetClientIP(client, f_sIP, 64);
	
	f_iSize = strlen(f_sName);
	
	if(f_iSize == 0)
	{
		KAC_Log("'%s'(ID: %s | IP: %s) was kicked for having a blank Name (unconnected)", f_sName, f_sAuthID, f_sIP);
		KAC_Kick(client, KAC_CHANGENAME);
		return;
	}
	
	if(f_sName[0] == '&')
	{
		KAC_Kick(client, KAC_CHANGENAME);
		return;
	}
	
	for(int i = 0; i < f_iSize; i++)
	{
		f_cChar = f_sName[i];
		if(!IsCharSpace(f_cChar))
			f_bWhiteSpace = false;
			
		if(IsCharMB(f_cChar))
		{
			i++;
			if(f_cChar == 194 && f_sName[i] == 160)
			{
				KAC_Kick(client, KAC_CHANGENAME);
				return;
			}
		}
		else if(f_cChar < 32)
		{
			KAC_Kick(client, KAC_CHANGENAME);
			return;
		}
	}
	
	if(f_bWhiteSpace)
	{
		KAC_Kick(client, KAC_CHANGENAME);
		return;
	}
}

public Client_EnableChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bClientEnable = GetConVarBool(convar);
	if(g_bClientEnable)
	{
		Status_Report(g_iClientStatus, KAC_ON);
		if(g_iGame == GAME_CSS)
		{
			if(g_bClientAntiRespawn)
				Status_Report(g_iClientAntiRespawnStatus, KAC_ON);
				
			else
				Status_Report(g_iClientAntiRespawnStatus, KAC_OFF);
		}
		
		if(g_bClientNameProtect)
			Status_Report(g_iClientNameProtectStatus, KAC_ON);
			
		else
			Status_Report(g_iClientNameProtectStatus, KAC_OFF);
	}
	
	else
	{
		Status_Report(g_iClientStatus, KAC_OFF);
		if(g_iGame == GAME_CSS)
			Status_Report(g_iClientAntiRespawnStatus, KAC_DISABLED);
			
		Status_Report(g_iClientNameProtectStatus, KAC_DISABLED);
	}
}

public Client_AntiRespawnChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bClientAntiRespawn = GetConVarBool(convar);
	if(g_bClientEnable)
	{
		if(g_bClientAntiRespawn)
			Status_Report(g_iClientAntiRespawnStatus, KAC_ON);
			
		else
			Status_Report(g_iClientAntiRespawnStatus, KAC_OFF);
	}
}

public Client_NameProtectChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bClientNameProtect = GetConVarBool(convar);
	if(g_bClientEnable)
	{
		if(g_bClientNameProtect)
			Status_Report(g_iClientNameProtectStatus, KAC_ON);
			
		else
			Status_Report(g_iClientNameProtectStatus, KAC_OFF);
	}
}

public Client_AntiSpamConnectChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_fClientAntiSpamConnect = GetConVarFloat(convar);
}