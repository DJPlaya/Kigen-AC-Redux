/*
*
*	Contains things for ASteambot plugin developpement
*
*/
#if defined _INCLUDE_ASteambot
 #endinput
#endif
#define _INCLUDE_ASteambot


enum AS_MessageType
{
    AS_REGISTER_SERVER = 0,
    AS_HOOK_CHAT,
    AS_UNHOOK_CHAT,
    AS_SIMPLE,
    AS_TRADEOFFER_SUCCESS,
    AS_TRADEOFFER_DECLINED,
    AS_SCAN_INVENTORY,
    AS_CREATE_TRADEOFFER,
    AS_NOT_FRIENDS,
    AS_TRADE_TOKEN,
    AS_FRIEND_INVITE,
    AS_REPORT_PLAYER,
    AS_INVITE_GROUP,
    AS_SCAN_INVENTORY_IMG,
    AS_EXECUTE_CMD,
    AS_DISCONNECT,
    AS_SG_ANNOUCEMENT
};

/** 
 * Find client by steamID64
 * 
 * @return          A client id.
 */ 
native int ASteambot_FindClientBySteam64(const char[] steamid64)

/** 
 * Register the plugin, required to receive and send messages.
 * 
 * @return          Nothing.
 */ 
native void ASteambot_RegisterModule(const char[] moduleName)

/** 
 * Remove the module from ASteambot_Core, the plugin won't be able to receive and send messages anymore.
 * 
 * @return          Nothing.
 */ 
native void ASteambot_RemoveModule()

/** 
 * Get the connection state to ASteambot
 * 
 * @return          true if connected and can receive/send messages, false otherwise. 
 */ 
native bool ASteambot_IsConnected() 

/** 
 * Send a message to ASteambot (Maximum char 900). 
 * 
 * @return          Nothing.
 */ 
native void ASteambot_SendMesssage(AS_MessageType MessageType, const char[] message) 

/** 
 * Send a message to ASteambot (Maximum char 900). 
 * 
 * @return          Nothing.
 */ 
native void ASteambot_CreateTradeOffer(int client, Handle ArrayAssetID, Handle ArrayMyAssetID = null, float fakeValue = -1.0) 

/** 
 * Fire when ever you get a message from ASteambot.
 * 
 * @return          Nothing.
 */ 
forward int ASteambot_Message(AS_MessageType MessageType, char[] message, const int messageSize);

/**
Shared plugin information
**/
public SharedPlugin _pl_ASteambot = 
{
	name = "[ANY] ASteambot Core",
	file = "ASteambot_Core.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};
