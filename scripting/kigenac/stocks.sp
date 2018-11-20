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

#define STOCKS

stock KAC_Translate(client, char[] trans, char[] dest, maxlen)
{
	if (client)
		GetTrieString(g_hCLang[client], trans, dest, maxlen);
		
	else
		GetTrieString(g_hSLang, trans, dest, maxlen);
}

stock KAC_ReplyToCommand(client, const char[] trans, any:...)
{
	decl String:f_sBuffer[256], String:f_sFormat[256];
	if (!client)
		GetTrieString(g_hSLang, trans, f_sFormat, sizeof(f_sFormat));
	else
		GetTrieString(g_hCLang[client], trans, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 3);
	ReplyToCommand(client, "[Kigen-AC] %s", f_sBuffer);
}

stock KAC_PrintToServer(const char[] trans, any:...)
{
	char f_sBuffer[256], f_sFormat[256];
	GetTrieString(g_hSLang, trans, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 2);
	PrintToServer("[Kigen-AC] %s", f_sBuffer);
}

stock KAC_PrintToChat(client, const char[] trans, any:...)
{
	char f_sBuffer[256], f_sFormat[256];
	GetTrieString(g_hCLang[client], trans, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 3);
	PrintToChat(client, "[Kigen-AC] %s", f_sBuffer);
}

stock KAC_PrintToChatAdmins(const char[] trans, any:...)
{
	char f_sBuffer[256], f_sFormat[256];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(g_bIsAdmin[i])
		{
			GetTrieString(g_hCLang[i], trans, f_sFormat, sizeof(f_sFormat));
			VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 2);
			PrintToChat(i, "[Kigen-AC] %s", f_sBuffer);
		}
	}
}

stock KAC_PrintToChatAll(const char[] trans, any:...)
{
	char f_sBuffer[256], f_sFormat[256];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(g_bInGame[i])
		{
			GetTrieString(g_hCLang[i], trans, f_sFormat, sizeof(f_sFormat));
			VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 2);
			PrintToChat(i, "[Kigen-AC] %s", f_sBuffer);
		}
	}
}

stock KAC_Kick(client, const char[] trans, any:...)
{
	decl String:f_sBuffer[256], String:f_sFormat[256];
	GetTrieString(g_hCLang[client], trans, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 3);
	KickClient(client, "%s", f_sBuffer);
	OnClientDisconnect(client); // Do this since the client is no longer useful to us. - Kigen
}

stock KAC_Ban(client, time, const String:trans[], const String:format[], any:...)
{
	new String:f_sBuffer[256], String:f_sEReason[256];
	GetTrieString(g_hCLang[client], trans, f_sEReason, sizeof(f_sEReason));
	VFormat(f_sBuffer, sizeof(f_sBuffer), format, 5);
	if(g_bSourceBans)
		SBBanPlayer(0, client, time, f_sBuffer);
		
	else if(g_bSourceBansPP)
		SBPP_BanPlayer(0, client, time, f_sBuffer); // Admin 0 is the Server in SBPP, this id CAN be created or edited manually in the Database to show Admin Name "Server" on the Webpanel
		
	else
		BanClient(client, time, BANFLAG_AUTO, f_sBuffer, f_sEReason, "KAC");
	OnClientDisconnect(client); // Bashats!
}

//- Global Private Functions -//

KAC_Log(const char[] format, any ...)
{
	char f_sBuffer[256], f_sPath[256];
	VFormat(f_sBuffer, sizeof(f_sBuffer), format, 2);
	BuildPath(Path_SM, f_sPath, sizeof(f_sPath), "logs/KAC.log");
	LogMessage("%s", f_sBuffer);
	LogToFileEx(f_sPath, "%s", f_sBuffer);
}

stock StringToLower(char[] f_sInput)
{
	int f_iSize = strlen(f_sInput);
	for (new i = 0; i < f_iSize; i++)
	f_sInput[i] = CharToLower(f_sInput[i]);
}