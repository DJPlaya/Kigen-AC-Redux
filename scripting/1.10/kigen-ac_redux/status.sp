// Copyright (C) 2007-2011 CodingDirect LLC
// This File is licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details
// All Changes to the original Code are licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details


//- Defines -//

#define CELL_MODULENAME 0
#define CELL_MODULESTATUS 1


//- Global Variables -//

Handle g_hStatusArray;


//- Plugin Functions -//

public void Status_OnPluginStart()
{
	g_hStatusArray = CreateArray(32);
	
	RegAdminCmd("kacr_status", Status_Cmd, ADMFLAG_GENERIC, "Reports KACR's Status");
	
	if (g_bSourceIRC)
		IRC_RegAdminCmd("kacr_status", Status_SourceIRC_Cmd, ADMFLAG_GENERIC, "Reports KACR's Status"); // Possible BUG with the Name?? Keep this in Mind
}

Status_Register(const char[] cName, const char[] cStatus)
{
	Handle hArray = CreateArray(64);
	PushArrayString(hArray, cName);
	PushArrayString(hArray, cStatus);
	return PushArrayCell(g_hStatusArray, hArray);
}

Status_Report(const iID, const char[] cStatus)
{
	Handle hArray = GetArrayCell(g_hStatusArray, iID);
	SetArrayString(hArray, CELL_MODULESTATUS, cStatus);
}

/*stock Status_Unregister(f_iId)
{
	RemoveFromArray(g_hStatusArray, f_iId);
}*/

public Action Status_Cmd(const iClient, const iArgs) // #ref 805739 but with Translations
{
	Handle hBuffer;
	char cTemp1[256], cTemp2[64], cTemp3[64];
	
	int iArraySize = GetArraySize(g_hStatusArray);
	KACR_ReplyTranslatedToCommand(iClient, KACR_STATUSREPORT);
	if (!iArraySize)
	{
		KACR_ReplyTranslatedToCommand(iClient, KACR_NOREPORT);
		return Plugin_Handled;
	}
	
	for (int i; i < iArraySize; i++)
	{
		hBuffer = GetArrayCell(g_hStatusArray, i);
		GetArrayString(hBuffer, CELL_MODULENAME, cTemp2, sizeof(cTemp2));
		KACR_Translate(iClient, cTemp2, cTemp1, sizeof(cTemp1));
		GetArrayString(hBuffer, CELL_MODULESTATUS, cTemp2, sizeof(cTemp2));
		KACR_Translate(iClient, cTemp2, cTemp3, sizeof(cTemp3));
		StrCat(cTemp1, sizeof(cTemp1), ": ");
		StrCat(cTemp1, sizeof(cTemp1), cTemp3);
		ReplyToCommand(iClient, cTemp1);
	}
	
	return Plugin_Handled;
}

public Action Status_SourceIRC_Cmd(const char[] cNickname, const iArgs) // #ref 805739 but without Translations
{
	Handle hBuffer;
	char cTemp1[64], cTemp2[64];
	
	int iArraySize = GetArraySize(g_hStatusArray);
	IRC_ReplyToCommand(cNickname, "Kigen's Anti-Cheat Redux Status Report");
	if (!iArraySize)
	{
		IRC_ReplyToCommand(cNickname, "There is nothing to report");
		return Plugin_Handled;
	}
	
	for (int i; i < iArraySize; i++)
	{
		hBuffer = GetArrayCell(g_hStatusArray, i);
		GetArrayString(hBuffer, CELL_MODULENAME, cTemp1, sizeof(cTemp1));
		GetArrayString(hBuffer, CELL_MODULESTATUS, cTemp2, sizeof(cTemp2));
		StrCat(cTemp1, sizeof(cTemp1), ": ");
		StrCat(cTemp1, sizeof(cTemp1), cTemp2);
		IRC_ReplyToCommand(cNickname, cTemp1);
	}
	
	return Plugin_Handled;
}