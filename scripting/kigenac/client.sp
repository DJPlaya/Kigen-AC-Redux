/*
    Kigen's Anti-Cheat Client Module
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

#define MAX_CONNECTIONS 100

new Handle:g_hCVarClientEnable = INVALID_HANDLE;
new Handle:g_hCVarClientAntiRespawn = INVALID_HANDLE;
new Handle:g_hCVarClientNameProtect = INVALID_HANDLE;
new Handle:g_hCVarClientAntiSpamConnect = INVALID_HANDLE;
new bool:g_bClientEnable = true;
new bool:g_bClientAntiRespawn = false;
new bool:g_bClientNameProtect = true;
new Float:g_fClientAntiSpamConnect = 0.0;
new g_iClientStatus;
new g_iClientAntiRespawnStatus;
new g_iClientNameProtectStatus;
// new g_iClientAntiSpamConnectStatus;
new Handle:g_hClientSpawned = INVALID_HANDLE;
new g_iClientClass[MAXPLAYERS + 1] =  { -1, ... };
new String:g_sClientConnections[MAX_CONNECTIONS][64];
new bool:g_bClientMapStarted = false;

//- Plugin Functions -//

Client_OnPluginStart()
{
	g_hCVarClientEnable = CreateConVar("kac_client_enable", "1", "Enable the Client Protection module.");
	g_bClientEnable = GetConVarBool(g_hCVarClientEnable);
	
	if (g_iGame == GAME_CSS)
	{
		g_hCVarClientAntiRespawn = CreateConVar("kac_client_antirejoin", "0", "This will prevent people from leaving the game then rejoining to respawn.");
		g_bClientAntiRespawn = GetConVarBool(g_hCVarClientAntiRespawn);
		
		g_hClientSpawned = CreateTrie();
		
		HookConVarChange(g_hCVarClientAntiRespawn, Client_AntiRespawnChange);
		
		HookEvent("player_spawn", Client_PlayerSpawn);
		HookEvent("player_death", Client_PlayerDeath);
		HookEvent("round_start", Client_RoundStart);
		HookEvent("round_end", Client_CleanEvent);
		
		RegConsoleCmd("joinclass", Client_JoinClass);
	}
	
	g_hCVarClientNameProtect = CreateConVar("kac_client_nameprotect", "1", "This will protect the server from name crashes and hacks.");
	g_bClientNameProtect = GetConVarBool(g_hCVarClientNameProtect);
	
	g_hCVarClientAntiSpamConnect = CreateConVar("kac_client_antispamconnect", "0", "Seconds to prevent someone from restablishing a connection. 0 to disable.");
	g_fClientAntiSpamConnect = GetConVarFloat(g_hCVarClientAntiSpamConnect);
	
	if (g_bClientEnable)
	{
		g_iClientStatus = Status_Register(KAC_CLIENTMOD, KAC_ON);
		if (g_iGame == GAME_CSS)
		{
			if (g_bClientAntiRespawn)
				g_iClientAntiRespawnStatus = Status_Register(KAC_CLIENTANTIRESPAWN, KAC_ON);
			else
				g_iClientAntiRespawnStatus = Status_Register(KAC_CLIENTANTIRESPAWN, KAC_OFF);
		}
		if (g_bClientNameProtect)
			g_iClientNameProtectStatus = Status_Register(KAC_CLIENTNAMEPROTECT, KAC_ON);
		else
			g_iClientNameProtectStatus = Status_Register(KAC_CLIENTNAMEPROTECT, KAC_OFF);
	}
	else
	{
		g_iClientStatus = Status_Register(KAC_CLIENTMOD, KAC_OFF);
		if (g_iGame == GAME_CSS)
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

public Action:Client_JoinClass(client, args)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn || !g_bClientMapStarted || !client || IsFakeClient(client) || GetClientTeam(client) < 2)
		return Plugin_Continue;
	
	new String:f_sAuthID[64], String:f_sTemp[64], f_iTemp;
	if (!GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID))) // GetClientAuthString(client, f_sAuthID, sizeof(f_sAuthID))
		return Plugin_Continue;
	
	if (!GetTrieValue(g_hClientSpawned, f_sAuthID, f_iTemp))
		return Plugin_Continue;
	
	GetCmdArgString(f_sTemp, sizeof(f_sTemp));
	
	g_iClientClass[client] = StringToInt(f_sTemp);
	if (g_iClientClass[client] < 0)
		g_iClientClass[client] = 0;
	
	FakeClientCommandEx(client, "spec_mode");
	return Plugin_Handled;
}

public Action:Client_Autobuy(client, args)
{
	if (!client)
		return Plugin_Continue;
	
	decl String:f_sAutobuy[256], String:f_sArg[64], i, t;
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

//- Map -//
Client_OnMapStart()
{
	
}

Client_OnMapEnd()
{
	g_bClientMapStarted = false;
	
	for(new i = 0; i < MAX_CONNECTIONS; i++)
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

public Action:Client_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn)
		return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid")), String:f_sAuthID[64];
	if (!client || GetClientTeam(client) < 2 || !GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID))) // GetClientAuthString(client, f_sAuthID, sizeof(f_sAuthID))
		return Plugin_Continue;
	
	RemoveFromTrie(g_hClientSpawned, f_sAuthID);
	
	return Plugin_Continue
}

public Action:Client_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bClientEnable || !g_bClientAntiRespawn)
		return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid")), String:f_sAuthID[64];
	if (!client || !GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID))) // GetClientAuthString(client, f_sAuthID, sizeof(f_sAuthID))
		return Plugin_Continue;
	
	SetTrieValue(g_hClientSpawned, f_sAuthID, true);
	
	return Plugin_Continue
}

public Action:Client_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bClientMapStarted = true;
}

public Action:Client_CleanEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	CloseHandle(g_hClientSpawned);
	g_hClientSpawned = CreateTrie();
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_bInGame[i] && g_iClientClass[i] != -1)
		{
			FakeClientCommandEx(i, "joinclass %d", g_iClientClass[i]);
			g_iClientClass[i] = -1;
		}
	}
}

bool:Client_OnClientConnect(client, String:rejectmsg[], size)
{
	if (!g_bClientEnable)
		return true;
	
	if (g_fClientAntiSpamConnect > 0.0)
	{
		new String:f_sClientIP[64];
		
		GetClientIP(client, f_sClientIP, sizeof(f_sClientIP));
		
		for (new i = 0; i < MAX_CONNECTIONS; i++)
		{
			if (StrEqual(g_sClientConnections[i], f_sClientIP))
			{
				Format(rejectmsg, size, "Please wait one minute before retrying to connect");
				BanIdentity(f_sClientIP, 1, BANFLAG_IP, "Spam Connecting"); // We do not want this hooked, so no source.
				return false;
			}
		}
		
		for (new i = 0; i < MAX_CONNECTIONS; i++)
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
		new String:f_sName[64], String:f_cChar, f_iSize, f_bWhiteSpace = true;
		GetClientName(client, f_sName, sizeof(f_sName));
		
		f_iSize = strlen(f_sName);
		
		if (f_iSize < 1 || f_sName[0] == '&')
		{
			Format(rejectmsg, size, "Please change your name");
			return false;
		}
		
		for (new i = 0; i < f_iSize; i++)
		{
			f_cChar = f_sName[i];
			if (!IsCharSpace(f_cChar))
				f_bWhiteSpace = false;
			
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

public OnClientSettingsChanged(client)
{
	if (!g_bClientEnable || !g_bClientNameProtect || IsFakeClient(client))
		return;
	
	new String:f_sName[64], String:f_sAuthID[64], String:f_sIP[64], String:f_cChar, f_iSize, f_bWhiteSpace = true;
	GetClientName(client, f_sName, sizeof(f_sName));
	GetClientAuthId(client, AuthId_Steam3, f_sAuthID, sizeof(f_sAuthID)) // GetClientAuthString(client, f_sAuthID, sizeof(f_sAuthID));
	GetClientIP(client, f_sIP, sizeof(f_sIP));
	
	f_iSize = strlen(f_sName);
	
	if (f_iSize == 0)
	{
		KAC_Log("%s (ID: %s | IP: %s) was kicked for having a blank name (unconnected).", f_sName, f_sAuthID, f_sIP);
		KAC_Kick(client, KAC_CHANGENAME);
		return;
	}
	
	if (f_sName[0] == '&')
	{
		KAC_Kick(client, KAC_CHANGENAME);
		return;
	}
	
	for (new i = 0; i < f_iSize; i++)
	{
		f_cChar = f_sName[i];
		if (!IsCharSpace(f_cChar))
			f_bWhiteSpace = false;
		
		if (IsCharMB(f_cChar))
		{
			i++;
			if (f_cChar == 194 && f_sName[i] == 160)
			{
				KAC_Kick(client, KAC_CHANGENAME);
				return;
			}
		}
		else if (f_cChar < 32)
		{
			KAC_Kick(client, KAC_CHANGENAME);
			return;
		}
	}
	
	if (f_bWhiteSpace)
	{
		KAC_Kick(client, KAC_CHANGENAME);
		return;
	}
}

public Client_EnableChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_bClientEnable = GetConVarBool(convar);
	if (g_bClientEnable)
	{
		Status_Report(g_iClientStatus, KAC_ON);
		if (g_iGame == GAME_CSS)
		{
			if (g_bClientAntiRespawn)
				Status_Report(g_iClientAntiRespawnStatus, KAC_ON);
			else
				Status_Report(g_iClientAntiRespawnStatus, KAC_OFF);
		}
		if (g_bClientNameProtect)
			Status_Report(g_iClientNameProtectStatus, KAC_ON);
		else
			Status_Report(g_iClientNameProtectStatus, KAC_OFF);
	}
	else
	{
		Status_Report(g_iClientStatus, KAC_OFF);
		if (g_iGame == GAME_CSS)
			Status_Report(g_iClientAntiRespawnStatus, KAC_DISABLED);
		Status_Report(g_iClientNameProtectStatus, KAC_DISABLED);
	}
}

public Client_AntiRespawnChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_bClientAntiRespawn = GetConVarBool(convar);
	if (g_bClientEnable)
	{
		if (g_bClientAntiRespawn)
			Status_Report(g_iClientAntiRespawnStatus, KAC_ON);
		else
			Status_Report(g_iClientAntiRespawnStatus, KAC_OFF);
	}
}

public Client_NameProtectChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_bClientNameProtect = GetConVarBool(convar);
	if (g_bClientEnable)
	{
		if (g_bClientNameProtect)
			Status_Report(g_iClientNameProtectStatus, KAC_ON);
		else
			Status_Report(g_iClientNameProtectStatus, KAC_OFF);
	}
}

public Client_AntiSpamConnectChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_fClientAntiSpamConnect = GetConVarFloat(convar);
}

//- EoF -//
