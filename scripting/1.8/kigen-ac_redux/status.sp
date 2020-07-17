// Copyright (C) 2007-2011 CodingDirect LLC
// This File is Licensed under GPLv3, see 'Licenses/License_KAC.txt' for Details


#define CELL_MODULENAME 0
#define CELL_MODULESTATUS 1

Handle g_hStatusArray;

public void Status_OnPluginStart()
{
	g_hStatusArray = CreateArray(32);
	
	RegAdminCmd("kacr_status", Status_Cmd, ADMFLAG_GENERIC, "Reports KACR's Status");
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

public Action Status_Cmd(const iClient, const iArgs)
{
	Handle hBuffer;
	char cTemp1[256], cTemp2[64], cTemp3[64];
	
	int iArraySize = GetArraySize(g_hStatusArray);
	KACR_ReplyToCommand(iClient, KACR_STATUSREPORT);
	if (!iArraySize)
	{
		KACR_ReplyToCommand(iClient, KACR_NOREPORT);
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