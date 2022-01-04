 // Copyright (C) 2018-now KACR Contributers
// This File is Licensed under GPLv3, see 'Licenses/License_KACR.txt' for Details

// Banlist checks to be done here
// Fake Lag and Stuff should also be checked here

//////////////
// TODO #Prune
//////////////

// ********** Fake Lag Detection based on Frames **********

int g_iRunCmdsPerSecond[MAXPLAYERS + 1];
int g_iBadSeconds[MAXPLAYERS + 1];
float g_fLastCheckTime[MAXPLAYERS + 1];
MoveType g_mLastMoveType[MAXPLAYERS + 1];

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon, int &iSubtype, int &iCmdnum, int &iTickcount, int &iSeed, int iMouse[2])
{
	float tickRate = 1.0 / GetTickInterval();
	g_iRunCmdsPerSecond[iClient]++;
	if (GetEngineTime() - g_fLastCheckTime[iClient] >= 1.0)
	{
		if (float(g_iRunCmdsPerSecond[iClient]) / tickRate <= 0.95)
			if (++g_iBadSeconds[iClient] >= 3)
				SetEntityMoveType(iClient, MOVETYPE_NONE);
				
		else
		{
			if (GetEntityMoveType(iClient) == MOVETYPE_NONE)
				SetEntityMoveType(iClient, g_mLastMoveType[iClient]);
				
			g_iBadSeconds[iClient] = 0;
		}
		
		g_fLastCheckTime[iClient] = GetEngineTime();
		g_iRunCmdsPerSecond[iClient] = 0;
	}
}

// ********** Fake Lag Detection based on Ping DFT **********

/*
// Compare Choke
GetClientAvgChoke(iClient NetFlow_Incoming);
GetClientAvgChoke(iClient, NetFlow_Outgoing);


GetClientAvgPackets(iClient, NetFlow_Both);

GetClientAvgData(iClient);
GetClientAvgLoss(iClient, NetFlow_Outgoing);
*/