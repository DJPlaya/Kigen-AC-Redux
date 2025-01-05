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

#define CLIENT

#define MAX_CONNECTIONS 128

Handle g_hCVarClientEnable, g_hCVarClientAntiRespawn, g_hCVarClientNameProtect, g_hCVarClientAntiSpamConnect;
bool g_bClientEnable, g_bClientNameProtect, g_bClientAntiRespawn;
float g_fClientAntiSpamConnect = 0.0;

StringMap g_hClientSpawned;
char g_sClientConnections[MAX_CONNECTIONS][64];
int g_iClientClass[MAXPLAYERS + 1] =  { -1, ... };
int g_iClientStatus, g_iClientAntiRespawnStatus, g_iClientNameProtectStatus; // int g_iClientAntiSpamConnectStatus;
bool g_bClientMapStarted;


//- Plugin Functions -//

Client_OnPluginStart()
{
	g_hCVarClientEnable = AutoExecConfig_CreateConVar("kacr_client_enable", "1", "Enable the Client Protection Module", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bClientEnable = GetConVarBool(g_hCVarClientEnable);
	
	if (hGame == Engine_CSS || hGame == Engine_CSGO)
	{
		g_hCVarClientAntiRespawn = AutoExecConfig_CreateConVar("kacr_client_antirejoin", "1", "This will prevent Clients from leaving the Game and then rejoining to Respawn", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
		g_bClientAntiRespawn = GetConVarBool(g_hCVarClientAntiRespawn);
		
		g_hClientSpawned = new StringMap();
		
		HookConVarChange(g_hCVarClientAntiRespawn, Client_AntiRespawnChange);
		
		HookEvent("player_spawn", Client_PlayerSpawn);
		HookEvent("player_death", Client_PlayerDeath);
		HookEvent("round_start", Client_RoundStart);
		HookEvent("round_end", Client_RoundEnd);
		
		RegConsoleCmd("joinclass", Client_JoinClass);
	}
	
	g_hCVarClientNameProtect = AutoExecConfig_CreateConVar("kacr_client_nameprotect", "1", "This will protect the Server from name Crashes and Hacks", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bClientNameProtect = GetConVarBool(g_hCVarClientNameProtect);
	
	g_hCVarClientAntiSpamConnect = AutoExecConfig_CreateConVar("kacr_client_antispamconnect", "15", "Seconds to prevent someone from restablishing a Connection. 0 to disable", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 120.0);
	g_fClientAntiSpamConnect = GetConVarFloat(g_hCVarClientAntiSpamConnect);
	
	if (g_bClientEnable)
	{
		g_iClientStatus = Status_Register(KACR_CLIENTMOD, KACR_ON);
		if (hGame == Engine_CSS || hGame == Engine_CSGO)
		{
			if (g_bClientAntiRespawn)
				g_iClientAntiRespawnStatus = Status_Register(KACR_CLIENTANTIRESPAWN, KACR_ON);
				
			else
				g_iClientAntiRespawnStatus = Status_Register(KACR_CLIENTANTIRESPAWN, KACR_OFF);
		}
		
		if (g_bClientNameProtect)
			g_iClientNameProtectStatus = Status_Register(KACR_CLIENTNAMEPROTECT, KACR_ON);
			
		else
			g_iClientNameProtectStatus = Status_Register(KACR_CLIENTNAMEPROTECT, KACR_OFF);
	}
	
	else
	{
		g_iClientStatus = Status_Register(KACR_CLIENTMOD, KACR_OFF);
		if (hGame == Engine_CSS || hGame == Engine_CSGO)
			g_iClientAntiRespawnStatus = Status_Register(KACR_CLIENTANTIRESPAWN, KACR_DISABLED);
			
		g_iClientNameProtectStatus = Status_Register(KACR_CLIENTNAMEPROTECT, KACR_DISABLED);
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


//- Map Hooks -//
/*Client_OnMapStart() // Currently unused
{
	
}*/

Client_OnMapEnd()
{
	g_bClientMapStarted = false;
	
	for (int i = 0; i < MAX_CONNECTIONS; i++)
		strcopy(g_sClientConnections[i], 64, "");
		
	if (hGame == Engine_CSS || hGame == Engine_CSGO)
		Client_CleanEvent();
}


//- Timers -//

public Action Client_AntiSpamConnectTimer(Handle hTimer, any iClient)
{
	strcopy(g_sClientConnections[iClient], 64, "");
	return Plugin_Stop;
}


//- Hooks -//

public Action Client_PlayerSpawn(Event hEvent, const char[] cName, bool bDontBroadcast)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn)
		return Plugin_Continue;
		
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	char f_sAuthID[64];
	if (client <= 0 || GetClientTeam(client) < 2 || !GetClientAuthId(client, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID)))
		return Plugin_Continue;
		
	g_hClientSpawned.Remove(f_sAuthID);
	
	return Plugin_Continue
}

public Action Client_PlayerDeath(Event hEvent, const char[] cName, bool bDontBroadcast)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn)
		return Plugin_Continue;
		
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	char f_sAuthID[64];
	if (client <= 0 || !GetClientAuthId(client, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID)))
		return Plugin_Continue;
		
	g_hClientSpawned.SetValue(f_sAuthID, true);
	
	return Plugin_Continue
}

public void Client_RoundStart(Event hEvent, const char[] cName, bool bDontBroadcast)
{
	g_bClientMapStarted = true;
}

public void Client_RoundEnd(Handle hEvent, const char[] cName, bool bDontBroadcast)
{
	Client_CleanEvent();
}

bool Client_OnClientConnect(iClient, char[] rejectmsg, size)
{
	if (!g_bClientEnable)
		return true;
		
	if (g_fClientAntiSpamConnect > 0.0)
	{
		char f_sClientIP[64];
		
		GetClientIP(iClient, f_sClientIP, sizeof(f_sClientIP));
		
		for (int i = 0; i < MAX_CONNECTIONS; i++)
		{
			if (StrEqual(g_sClientConnections[i], f_sClientIP))
			{
				BanIdentity(f_sClientIP, 1, BANFLAG_IP, "Please wait one minute before retrying to connect"); // We do not want this hooked, so no source // Since its just a min ban, using SB/SBPP would be dump
				KACR_Log("'%L'<%s> was banned for 1 minute for spam connecting", iClient, f_sClientIP);
				return false;
			}
		}
		
		for (int i = 0; i < MAX_CONNECTIONS; i++)
		{
			if (g_sClientConnections[i][0] == '\0')
			{
				strcopy(g_sClientConnections[i], 64, f_sClientIP);
				CreateTimer(g_fClientAntiSpamConnect, Client_AntiSpamConnectTimer, i);
				break;
			}
		}
	}
	
	if (g_bClientNameProtect)
	{
		char f_sName[64], f_cChar;
		int f_iSize;
		bool f_bWhiteSpace = true;
		
		GetClientName(iClient, f_sName, sizeof(f_sName));
		
		f_iSize = strlen(f_sName);
		
		if (f_iSize < 1 || f_sName[0] == '&')
		{
			Format(rejectmsg, size, "Please change your name");
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
					Format(rejectmsg, size, "Please change your name");
					return false;
				}
			}
			
			else if (f_cChar < 32)
			{
				Format(rejectmsg, size, "Please change your name");
				return false;
			}
		}
		
		if (f_bWhiteSpace)
		{
			Format(rejectmsg, size, "Please change your name");
			return false;
		}
		
	}
	
	return true;
}

public void OnClientSettingsChanged(iClient)
{
	if (!g_bClientEnable || !g_bClientNameProtect || IsFakeClient(iClient))
		return;
		
	char f_sName[64];
	int f_iSize;
	bool f_bWhiteSpace = true;
	
	GetClientName(iClient, f_sName, sizeof(f_sName));
	
	f_iSize = strlen(f_sName);
	
	if (f_iSize == 0)
	{
		char f_sIP[64];
		GetClientIP(iClient, f_sIP, sizeof(f_sIP));
		KACR_Log("'%L'<%s> was kicked for having a blank Name (unconnected)", iClient, f_sIP);
		KACR_Kick(iClient, KACR_CHANGENAME);
		return;
	}
	
	if (f_sName[0] == '&')
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
	
	if (f_bWhiteSpace)
	{
		KACR_Kick(iClient, KACR_CHANGENAME);
		return;
	}
}

public void Client_EnableChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bClientEnable = GetConVarBool(convar);
	if (g_bClientEnable)
	{
		Status_Report(g_iClientStatus, KACR_ON);
		if (hGame == Engine_CSS || hGame == Engine_CSGO)
		{
			if (g_bClientAntiRespawn)
				Status_Report(g_iClientAntiRespawnStatus, KACR_ON);
				
			else
				Status_Report(g_iClientAntiRespawnStatus, KACR_OFF);
		}
		
		if (g_bClientNameProtect)
			Status_Report(g_iClientNameProtectStatus, KACR_ON);
			
		else
			Status_Report(g_iClientNameProtectStatus, KACR_OFF);
	}
	
	else
	{
		Status_Report(g_iClientStatus, KACR_OFF);
		if (hGame == Engine_CSS || hGame == Engine_CSGO)
			Status_Report(g_iClientAntiRespawnStatus, KACR_DISABLED);
			
		Status_Report(g_iClientNameProtectStatus, KACR_DISABLED);
	}
}

public void Client_AntiRespawnChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bClientAntiRespawn = GetConVarBool(convar);
	if (g_bClientEnable)
	{
		if (g_bClientAntiRespawn)
			Status_Report(g_iClientAntiRespawnStatus, KACR_ON);
			
		else
			Status_Report(g_iClientAntiRespawnStatus, KACR_OFF);
	}
}

public void Client_NameProtectChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bClientNameProtect = GetConVarBool(convar);
	if (g_bClientEnable)
	{
		if (g_bClientNameProtect)
			Status_Report(g_iClientNameProtectStatus, KACR_ON);
			
		else
			Status_Report(g_iClientNameProtectStatus, KACR_OFF);
	}
}

public void Client_AntiSpamConnectChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_fClientAntiSpamConnect = GetConVarFloat(convar);
}


//- Functions -//

public void Client_CleanEvent()
{
	CloseHandle(g_hClientSpawned); // Really needed? We could just clear it?
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