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

#define STATUS

#define CELL_MODULENAME 0
#define CELL_MODULESTATUS 1

Handle g_hStatusArray;

Status_OnPluginStart()
{
	g_hStatusArray = CreateArray(32);
	
	RegAdminCmd("kacr_status", Status_Status, ADMFLAG_GENERIC, "Reports KACR's Status");
}

/*Status_OnPluginEnd()
{
}*/

Status_Register(char[] f_sName, char[] f_sStatus)
{
	Handle f_hArray = CreateArray(64);
	PushArrayString(f_hArray, f_sName);
	PushArrayString(f_hArray, f_sStatus);
	return PushArrayCell(g_hStatusArray, f_hArray);
}

Status_Report(f_iId, char[] f_sStatus)
{
	Handle f_hArray = GetArrayCell(g_hStatusArray, f_iId);
	SetArrayString(f_hArray, CELL_MODULESTATUS, f_sStatus);
}

/*stock Status_Unregister(f_iId)
{
	RemoveFromArray(g_hStatusArray, f_iId);
}*/

public Action Status_Status(client, args)
{
	Handle f_hTemp;
	char f_sBuff[256], f_sTemp[64], f_sTemp2[64];
	
	int f_iCount = GetArraySize(g_hStatusArray)
	KACR_ReplyToCommand(client, KACR_STATUSREPORT);
	if (!f_iCount)
	{
		KACR_ReplyToCommand(client, KACR_NOREPORT);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < f_iCount; i++)
	{
		f_hTemp = GetArrayCell(g_hStatusArray, i);
		GetArrayString(f_hTemp, CELL_MODULENAME, f_sTemp, sizeof(f_sTemp));
		KACR_Translate(client, f_sTemp, f_sBuff, sizeof(f_sBuff));
		GetArrayString(f_hTemp, CELL_MODULESTATUS, f_sTemp, sizeof(f_sTemp));
		KACR_Translate(client, f_sTemp, f_sTemp2, sizeof(f_sTemp2));
		StrCat(f_sBuff, sizeof(f_sBuff), ": ");
		StrCat(f_sBuff, sizeof(f_sBuff), f_sTemp2);
		ReplyToCommand(client, f_sBuff);
	}
	
	return Plugin_Handled;
} 