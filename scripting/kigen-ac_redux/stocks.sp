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

#define STOCKS

/*
* Translates an String depending on the Clients Region
* 
* @param Client			Client UID.
* @param Translation	The Name of the Translation.
* @param Destination	The Destination String for the Output.
* @param Maxlenght		Maximum Lenght of the Destination String.
*/
stock KACR_Translate(client, char[] cTranslation, char[] cDestination, iMaxlenght)
{
	if(client)
		GetTrieString(g_hCLang[client], cTranslation, cDestination, iMaxlenght);
		
	else
		GetTrieString(g_hSLang, cTranslation, cDestination, iMaxlenght);
}

/*
* Sends an Command Reply to an Client
* 
* @param Client			Client UID.
* @param Translation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
stock KACR_ReplyToCommand(client, const char[] cTranslation, any ...)
{
	char f_sBuffer[256], f_sFormat[256];
	
	if(!client)
		GetTrieString(g_hSLang, cTranslation, f_sFormat, sizeof(f_sFormat));
		
	else
		GetTrieString(g_hCLang[client], cTranslation, f_sFormat, sizeof(f_sFormat));
		
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 3);
	ReplyToCommand(client, "[Kigen-AC_Redux] %s", f_sBuffer);
}

/*
* Sends an Translated Message to the Server Console
* 
* @param Translation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
stock KACR_PrintToServer(const char[] cTranslation, any ...)
{
	char f_sBuffer[256], f_sFormat[256];
	GetTrieString(g_hSLang, cTranslation, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 2);
	PrintToServer("[Kigen-AC_Redux] %s", f_sBuffer);
}

/*
* Sends an Translated Message to a Client
* 
* @param Client			Client UID.
* @param Translation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
stock KACR_PrintToChat(client, const char[] cTranslation, any ...)
{
	char f_sBuffer[256], f_sFormat[256];
	GetTrieString(g_hCLang[client], cTranslation, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 3);
	PrintToChat(client, "[Kigen-AC_Redux] %s", f_sBuffer);
}

/*
* Sends an Message to all Online Admins
* 
* @param Translation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
stock KACR_PrintToChatAdmins(const char[] cTranslation, any ...)
{
	char f_sBuffer[256], f_sFormat[256];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(g_bIsAdmin[i])
		{
			GetTrieString(g_hCLang[i], cTranslation, f_sFormat, sizeof(f_sFormat));
			VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 2);
			PrintToChat(i, "[Kigen-AC_Redux] %s", f_sBuffer);
		}
	}
}

/*
* Sends an Translated Message to all Clients
* 
* @param Translation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
stock KACR_PrintToChatAll(const char[] cTranslation, any ...)
{
	char f_sBuffer[256], f_sFormat[256];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(g_bInGame[i])
		{
			GetTrieString(g_hCLang[i], cTranslation, f_sFormat, sizeof(f_sFormat));
			VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 2);
			PrintToChat(i, "[Kigen-AC_Redux] %s", f_sBuffer);
		}
	}
}

/*
* Kicks an Client with an Translated Reason
* 
* @param Client			Client UID.
* @param Translation	The Name of the Translation.
* @param ...			Variable number of format parameters.
*/
stock KACR_Kick(iClient, const char[] cTranslation, any ...)
{
	char f_sBuffer[256], f_sFormat[256];
	GetTrieString(g_hCLang[iClient], cTranslation, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 3);
	KickClient(iClient, "%s", f_sBuffer);
	OnClientDisconnect(iClient); // Do this since the client is no longer useful to us. - Kigen
}

/*
* Bans an Client with an Translated Reason and time
* 
* @param Client			Client UID.
* @param Time			Bantime, 0 = Forever.
* @param Translation	The Name of the Translation.
* @param Reason			The Ban Reason.
* @param ...			Variable number of format parameters.
*/
stock KACR_Ban(client, time, const char[] cTranslation, const char[] cReason, any ...)
{
	char f_sBuffer[256], f_sEReason[256];
	GetTrieString(g_hCLang[client], cTranslation, f_sEReason, sizeof(f_sEReason));
	VFormat(f_sBuffer, sizeof(f_sBuffer), cReason, 5);
	if(g_bSourceBans)
		SBBanPlayer(0, client, time, f_sBuffer);
		
	else if(g_bSourceBansPP)
		SBPP_BanPlayer(0, client, time, f_sBuffer); // Admin 0 is the Server in SBPP, this ID CAN be created or edited manually in the Database to show Name "Server" on the Webpanel
		
	else
		BanClient(client, time, BANFLAG_AUTO, f_sBuffer, f_sEReason, "KACR");
		
	OnClientDisconnect(client); // Bashats!
}


//- Global Private Functions -//

/*
* Logs an Error Message
* 
* @param Text			Message to log.
* @param ...			Variable number of format parameters.
*/
KACR_Log(const char[] cText, any ...)
{
	char f_sBuffer[256], f_sPath[256];
	VFormat(f_sBuffer, sizeof(f_sBuffer), cText, 2);
	BuildPath(Path_SM, f_sPath, sizeof(f_sPath), "logs/KACR.log");
	LogMessage("%s", f_sBuffer);
	LogToFileEx(f_sPath, "%s", f_sBuffer);
}

/*
* Makes an String Lowercase
* 
* @param Text			String to Convert.
*/
stock StringToLower(char[] cText)
{
	int f_iSize = strlen(cText);
	for(new i = 0; i < f_iSize; i++)
		cText[i] = CharToLower(cText[i]);
}