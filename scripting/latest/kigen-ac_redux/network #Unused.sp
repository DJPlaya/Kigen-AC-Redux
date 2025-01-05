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

#define NETWORK

// TODO: Old Network version, to be replaced soon.


//- Global Variables -//

Handle g_hCVarNetEnabled, g_hCVarNetUseBanlist, g_hCVarNetUseUpdate, g_hUpdateFile, g_hSocket, g_hTimer, g_hVTimer;
bool g_bCVarNetEnabled = true, g_bCVarNetUseBanlist = true, g_bCVarNetUseUpdate = true;
bool g_bVCheckDone, InUpdate;
bool g_bChecked[MAXPLAYERS + 1] =  { false, ... };
int g_iInError = 0;
int g_iNetStatus, g_iCurrentMirror;
char g_sMirrors[][] =  { "kigenac.com", "nauc.info" };
char UpdatePath[256];


//- Plugin Functions -//

Network_OnPluginStart()
{
	g_hCVarNetEnabled = AutoExecConfig_CreateConVar("kacr_net_enable", "1", "Enable the Network module", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bCVarNetEnabled = GetConVarBool(g_hCVarNetEnabled);
	
	g_hCVarNetUseBanlist = AutoExecConfig_CreateConVar("kacr_net_usebanlist", "1", "Use the global banlist", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bCVarNetUseBanlist = GetConVarBool(g_hCVarNetUseBanlist);
	
	g_hCVarNetUseUpdate = AutoExecConfig_CreateConVar("kacr_net_autoupdate", "1", "Use the Auto-Update feature", FCVAR_DONTRECORD | FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_bCVarNetUseUpdate = GetConVarBool(g_hCVarNetUseUpdate);
	
	HookConVarChange(g_hCVarNetEnabled, Network_ConVarChange);
	HookConVarChange(g_hCVarNetUseBanlist, Network_ConVarChange);
	HookConVarChange(g_hCVarNetUseUpdate, Network_ConVarChange);
	
	g_hTimer = CreateTimer(5.0, Network_Timer, _, TIMER_REPEAT);
	if (g_bCVarNetEnabled)
		g_iNetStatus = Status_Register(KACR_NETMOD, KACR_ON);
		
	else
		g_iNetStatus = Status_Register(KACR_NETMOD, KACR_OFF);
		
	RegAdminCmd("kacr_net_status", Network_Checked, ADMFLAG_GENERIC, "Reports who has been checked");
}

Network_OnPluginEnd()
{
	if (g_hTimer != INVALID_HANDLE)
		CloseHandle(g_hTimer);
		
	if (g_hVTimer != INVALID_HANDLE)
		CloseHandle(g_hVTimer);
		
	if (g_hSocket != INVALID_HANDLE)
		CloseHandle(g_hSocket);
}


//- Client Functions -//

Network_OnClientDisconnect(client)
{
	g_bChecked[client] = false;
}


//- ConVar Functions -//

public void Network_ConVarChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	bool bNetEnabled = g_bCVarNetEnabled;
	
	g_bCVarNetUseBanlist = GetConVarBool(g_hCVarNetUseBanlist);
	g_bCVarNetUseUpdate = GetConVarBool(g_hCVarNetUseUpdate);
	
	if (!g_bCVarNetUseBanlist && !g_bCVarNetUseUpdate)
		g_bCVarNetEnabled = false;
		
	else
		g_bCVarNetEnabled = GetConVarBool(g_hCVarNetEnabled);
		
	if (g_bCVarNetEnabled && !bNetEnabled)
		Status_Report(g_iNetStatus, KACR_ON);
		
	else if (bNetEnabled)
		Status_Report(g_iNetStatus, KACR_OFF);
}


//- Commands -//

public Action Network_Checked(client, args)
{
	if (!g_bCVarNetEnabled || !g_bCVarNetUseBanlist)
	{
		// TODO: print error here
		KACR_ReplyToCommand(client, KACR_DISABLED);
		return Plugin_Handled;
	}
	
	if (args)
	{
		char sArg[64];
		GetCmdArg(1, sArg, sizeof(sArg));
		if (StrEqual(sArg, "revalidate"))
		{
			for (int i = 1; i <= MaxClients; i++)
				if (g_bInGame[i] && !g_bChecked[i])
				{
					KACR_ReplyToCommand(client, KACR_CANNOTREVAL);
					return Plugin_Handled;
				}
				
			for (int i = 1; i <= MaxClients; i++)
			g_bChecked[i] = false;
			
			KACR_ReplyToCommand(client, KACR_FORCEDREVAL);
			return Plugin_Handled;
		}
	}
	
	char sIP[64];
	for (int i = 1; i <= MaxClients; i++)
		if (g_bInGame[i] && GetClientIP(i, sIP, sizeof(sIP)))
			ReplyToCommand(client, "'%L'<%s>: %s", i, sIP, (g_bChecked[i]) ? "Checked" : "Waiting");
			
	return Plugin_Handled;
}


//- Timer Functions -//

public Action Network_Timer(Handle timer, any we)
{
	if (g_iInError > 0)
	{
		g_iInError--;
		return Plugin_Continue;
	}
	
	Handle hTemp;
	hTemp = g_hSocket;
	if (hTemp != INVALID_HANDLE)
	{
		g_hSocket = INVALID_HANDLE;
		CloseHandle(hTemp);
	}
	
	if (!g_bCVarNetEnabled)
		return Plugin_Continue;
		
	if (g_bCVarNetUseUpdate && !g_bVCheckDone) // If SourceMod is older than 1.3 we will not update.  But we will still check clients.
	{
		g_iInError = 12; // Wait 30 seconds.
		g_hSocket = SocketCreate(SOCKET_TCP, Network_OnSockErrVer);
		SocketConnect(g_hSocket, Network_OnSockConnVer, Network_OnSockRecvVer, Network_OnSockDiscVer, "master.kigenac.com", 9652);
		return Plugin_Continue;
	}
	
	if (!g_bCVarNetUseBanlist)
		return Plugin_Continue;
		
	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_bAuthorized[i] && !g_bChecked[i])
		{
			g_iInError = 1;
			g_hSocket = SocketCreate(SOCKET_TCP, Network_OnSocketError);
			SocketSetArg(g_hSocket, i);
			SocketConnect(g_hSocket, Network_OnSocketConnect, Network_OnSocketReceive, Network_OnSocketDisconnect, "master.kigenac.com", 9652);
			return Plugin_Continue;
		}
	}
	
	return Plugin_Continue;
}

public Action Network_VTimer(Handle timer, any we)
{
	g_hVTimer = INVALID_HANDLE;
	g_bVCheckDone = false;
	return Plugin_Stop;
}


//- Socket Functions -//

public void Network_OnSockDiscVer(Handle socket, any we)
{
	if (!g_bVCheckDone)
		g_iInError = 12;
		
	g_hSocket = INVALID_HANDLE;
	CloseHandle(socket);
}

public void Network_OnSockErrVer(Handle socket, const errorType, const errorNum, any we)
{
	if (!g_bVCheckDone)
		g_iInError = 12;
		
	g_hSocket = INVALID_HANDLE;
	Status_Report(g_iNetStatus, KACR_UNABLETOCONTACT);
	CloseHandle(socket);
}

public void Network_OnSockConnVer(Handle socket, any we)
{
	if (!SocketIsConnected(socket))
	{
		g_iInError = 12;
		g_hSocket = INVALID_HANDLE;
		Status_Report(g_iNetStatus, KACR_UNABLETOCONTACT);
		CloseHandle(socket);
		return;
	}
	
	char buff[15];
	Format(buff, sizeof(buff), "_UPDATE");
	SocketSend(socket, buff, strlen(buff) + 1); // Send that \0!
	Status_Report(g_iNetStatus, KACR_ON);
	return;
}

public void Network_OnSockRecvVer(Handle socket, char[] data, const size, any we)
{
	if (StrEqual(data, "_SEND"))
		SocketSend(socket, PLUGIN_VERSION, 7);
		
	else if (StrEqual(data, "_UPTODATE"))
	{
		g_bVCheckDone = true;
		g_hVTimer = CreateTimer(14400.0, Network_VTimer);
		if (SocketIsConnected(socket))
			SocketDisconnect(socket);
	}
	
	else if (StrContains(data, "_UPDATING") != -1)
	{
		if (SocketIsConnected(socket))
			SocketDisconnect(socket);
			
		char path[256], sTemp[64];
		g_iInError = 9999;
		LogMessage("Received that KACR is out of date, updating to newest version.");
		Format(UpdatePath, sizeof(UpdatePath), "%s", data[10]);
		GetPluginFilename(GetMyHandle(), sTemp, sizeof(sTemp));
		BuildPath(Path_SM, path, sizeof(path), "plugins\\disabled");
		if (!DirExists(path))
			if (!CreateDirectory(path, 0777))
			{
				LogError("Unable to create disabled folder.");
				Status_Report(g_iNetStatus, KACR_ERROR);
				return;
			}
			
		StrCat(path, sizeof(path), "\\");
		StrCat(path, sizeof(path), sTemp);
		DeleteFile(path);
		g_hUpdateFile = OpenFile(path, "ab"); // Set to ab to avoid issues with devicenull's patch for the upload exploit.
		if(g_hUpdateFile == INVALID_HANDLE)
		{
			LogError("Failed to create % s", path);
			Status_Report(g_iNetStatus, KACR_ERROR);
			return;
		}
		
		CloseHandle(g_hSocket);
		g_hSocket = SocketCreate(SOCKET_TCP, Network_OnSockErrDL);
		SocketConnect(g_hSocket, Network_OnSockConnDL, Network_OnSockRecvDL, Network_OnSockDiscDL, g_sMirrors[g_iCurrentMirror], 80);
	}
	
	else
	{
		LogError("Received unknown reply from KACR master during version check,  % s.", data);
		g_bVCheckDone = false;
		if(SocketIsConnected(socket))
			SocketDisconnect(socket);
			
		g_iInError = 6;
		Status_Report(g_iNetStatus, KACR_ERROR);
	}
}

public void Network_OnSockDiscDL(Handle socket, any we)
{
	if(!InUpdate)
	{
		g_iInError = 12;
		g_hSocket = INVALID_HANDLE;
		LogError("Disconnected from % s without getting update.", g_sMirrors[g_iCurrentMirror]);
		g_iCurrentMirror++;
		if(g_iCurrentMirror >= sizeof(g_sMirrors)) // Switch mirrors.
			g_iCurrentMirror = 0;
			
		Status_Report(g_iNetStatus, KACR_ERROR);
		CloseHandle(socket);
		CloseHandle(g_hUpdateFile);
		return;
	}
	
	FlushFile(g_hUpdateFile);
	CloseHandle(g_hUpdateFile);
	CloseHandle(socket);
	g_hSocket = INVALID_HANDLE;
	char path[256], path2[256];
	GetPluginFilename(GetMyHandle(), path, sizeof(path));
	BuildPath(Path_SM , path2, sizeof(path2), "plugins\\disabled\\ % s", path);
	BuildPath(Path_SM , path, sizeof(path), "plugins\\ % s", path);
	if(!DeleteFile(path))
	{
		LogError("Was unable to delete % s.", path);
		Status_Report(g_iNetStatus, KACR_ERROR);
		return;
	}
	
	if(!RenameFile(path, path2))
	{
		LogError("Was unable to rename % s to % s.", path2, path);
		Status_Report(g_iNetStatus, KACR_ERROR);
		return;
	}
	
	GetPluginFilename(GetMyHandle(), path, sizeof(path));
	path[strlen(path)-4] = '\0';
	InsertServerCommand("sm plugins reload % s", path);
	LogMessage("Update successful.");
}

public void Network_OnSockErrDL(Handle socket, const errorType, const errorNum, any we)
{
	g_iInError = 12;
	g_hSocket = INVALID_HANDLE;
	LogError("Error received during update:Failed to connect to % s.", g_sMirrors[g_iCurrentMirror]);
	Status_Report(g_iNetStatus, KACR_ERROR);
	g_iCurrentMirror++;
	
	if(g_iCurrentMirror >= sizeof(g_sMirrors)) // Switch mirrors.
		g_iCurrentMirror = 0;
		
	CloseHandle(socket);
	CloseHandle(g_hUpdateFile);
}

public void Network_OnSockConnDL(Handle socket, any we)
{
	if(!SocketIsConnected(socket))
	{
		LogError("Disconnect on connect to % s", g_sMirrors[g_iCurrentMirror]);
		g_iInError = 12;
		Status_Report(g_iNetStatus, KACR_ERROR);
		g_iCurrentMirror++;
		if(g_iCurrentMirror > sizeof(g_sMirrors)) // Switch mirrors.
			g_iCurrentMirror = 0;
			
		g_hSocket = INVALID_HANDLE;
		CloseHandle(socket);
		CloseHandle(g_hUpdateFile);
		return;
	}
	
	char buff[512];
	Format(buff, sizeof(buff), "GET % s HTTP / 1.0\r\nHost: % s\r\nConnection:close\r\n\r\n", UpdatePath, g_sMirrors[g_iCurrentMirror]);
	SocketSend(socket, buff);
	LogMessage("Connected to % s website, requesting update file.", g_sMirrors[g_iCurrentMirror]);
	Status_Report(g_iNetStatus, KACR_ON);
	return;
}

public void Network_OnSockRecvDL(Handle socket, char[] data, const size, any we)
{
	int pos = 0;
	if(!InUpdate)
	{
		pos = StrContains(data, "\r\n\r\n");
		if(pos == -1)
			return;
			
		pos += 4;
		InUpdate = true;
	}
	
	for(int i=pos; i<size; i++)
		WriteFileCell(g_hUpdateFile, _:data[i], 1);
}


public void Network_OnSocketConnect(Handle socket, any client)
{
	if(!SocketIsConnected(socket))
		return;
		
	char sAuthID[64];
	if(!g_bAuthorized[client] || !GetClientAuthId(client, AuthId_Steam2, sAuthID, sizeof(sAuthID)))
		SocketDisconnect(socket);
		
	else
		SocketSend(socket, sAuthID, strlen(sAuthID)+1); // Send that \0! - Kigen
		
	Status_Report(g_iNetStatus, KACR_ON);
	return;
}

public void Network_OnSocketDisconnect(Handle socket, any client)
{
	if(socket == g_hSocket)
		g_hSocket = INVALID_HANDLE;
		
	CloseHandle(socket);
	return;
}

public void Network_OnSocketReceive(Handle socket, char[] data, const size, any client) 
{
	if(socket == INVALID_HANDLE || !g_bAuthorized[client])
		return;
		
	g_bChecked[client] = true;
	if(StrEqual(data, "_BAN"))
	{
		char sAuthID[64], sIP[64], sBuffer[256];
		GetClientAuthId(client, AuthId_Steam2, sAuthID, sizeof(sAuthID));
		KACR_Translate(client, KACR_GBANNED, sBuffer, sizeof(sBuffer));
		g_hDenyArray.SetString(sAtuhID, sBuffer);
		GetClientIP(iClient sIP, sizeof(sIP));
		KACR_Log("'%L' <  % s > is on the KACR global Banlist.", client, sIP);
		KACR_Kick(client, KACR_GBANNED);
	}
	
	else if(StrEqual(data, "_OK"))
	{
		// sigh here.
	}
	
	else
	{
		g_bChecked[client] = false;
		char sIP[64];
		GetClientIP(client, sIP, sizeof(sIP));
		KACR_Log("[Error] Got unknown Reply from KACR master Server for Client'%L' <  % s > .Data: % s", client, sIP, data);
		Status_Report(g_iNetStatus, KACR_ERROR);
	}
	
	if(SocketIsConnected(socket))
		SocketDisconnect(socket);
}

public void Network_OnSocketError(Handle socket, const errorType, const errorNum, any client)
{
	if(socket == INVALID_HANDLE)
		return;
		
	// LogError("Socket Error:eT: % d, eN,  % d, c,  % d", errorType, errorNum, client);
	if(g_hSocket == socket)
		g_hSocket = INVALID_HANDLE;
		
	Status_Report(g_iNetStatus, KACR_UNABLETOCONTACT);
	CloseHandle(socket);
}