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
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#define TRANSLATIONS


//- Defined Translations -//

#define KACR_LOADED "KACR_LOADED"
#define KACR_BANNED "KACR_BANNED"
#define KACR_GBANNED "KACR_GBANNED"
#define KACR_VACBANNED "KACR_VACBANNED"
#define KACR_KCMDSPAM "KACR_KCMDSPAM"
#define KACR_ADDCMDUSAGE "KACR_ADDCMDUSAGE"
#define KACR_ADDCMDSUCCESS "KACR_ADDCMDSUCCESS"
#define KACR_ADDCMDFAILURE "KACR_ADDCMDFAILURE"
#define KACR_REMCMDUSAGE "KACR_REMCMDUSAGE"
#define KACR_REMCMDSUCCESS "KACR_REMCMDSUCCESS"
#define KACR_REMCMDFAILURE "KACR_REMCMDFAILURE"
#define KACR_ADDIGNCMDUSAGE "KACR_ADDIGNCMDUSAGE"
#define KACR_ADDIGNCMDSUCCESS "KACR_ADDIGNCMDSUCCESS"
#define KACR_ADDIGNCMDFAILURE "KACR_ADDIGNCMDFAILURE"
#define KACR_REMIGNCMDUSAGE "KACR_REMIGNCMDUSAGE"
#define KACR_REMIGNCMDSUCCESS "KACR_REMIGNCMDSUCCESS"
#define KACR_REMIGNCMDFAILURE "KACR_REMIGNCMDFAILURE"
#define KACR_FAILEDTOREPLY "KACR_FAILEDTOREPLY"
#define KACR_FAILEDAUTH "KACR_FAILEDAUTH"
#define KACR_CLIENTCORRUPT "KACR_CLIENTCORRUPT"
#define KACR_REMOVEPLUGINS "KACR_REMOVEPLUGINS"
#define KACR_HASPLUGIN "KACR_HASPLUGIN"
#define KACR_MUTED "KACR_MUTED"
#define KACR_HASNOTEQUAL "KACR_HASNOTEQUAL"
#define KACR_SHOULDEQUAL "KACR_SHOULDEQUAL"
#define KACR_HASNOTGREATER "KACR_HASNOTGREATER"
#define KACR_SHOULDGREATER "KACR_SHOULDGREATER"
#define KACR_HASNOTLESS "KACR_HASNOTLESS"
#define KACR_SHOULDLESS "KACR_SHOULDLESS"
#define KACR_HASNOTBOUND "KACR_HASNOTBOUND"
#define KACR_SHOULDBOUND "KACR_SHOULDBOUND"
#define KACR_BANIP "KACR_BANIP"
#define KACR_ADDCVARUSAGE "KACR_ADDCVARUSAGE"
#define KACR_REMCVARUSAGE "KACR_REMCVARUSAGE"
#define KACR_REMCVARSUCCESS "KACR_REMCVARSUCCESS"
#define KACR_REMCVARFAILED "KACR_REMCVARFAILED"
#define KACR_ADDCVARBADNAME "KACR_ADDCVARBADNAME"
#define KACR_ADDCVARBADCOMP "KACR_ADDCVARBADCOMP"
#define KACR_ADDCVARBADACT "KACR_ADDCVARBADACT"
#define KACR_ADDCVARBADBOUND "KACR_ADDCVARBADBOUND"
#define KACR_ADDCVAREXISTS "KACR_ADDCVAREXISTS"
#define KACR_ADDCVARSUCCESS "KACR_ADDCVARSUCCESS"
#define KACR_ADDCVARFAILED "KACR_ADDCVARFAILED"
#define KACR_CHANGENAME "KACR_CHANGENAME"
#define KACR_CBANNED "KACR_CBANNED"
#define KACR_STATUSREPORT "KACR_STATUSREPORT"
#define KACR_ON "KACR_ON"
#define KACR_OFF "KACR_OFF"
#define KACR_DISABLED "KACR_DISABLED"
#define KACR_ERROR "KACR_ERROR"
#define KACR_NOREPORT "KACR_NOREPORT"
#define KACR_TRANSLATEMOD "KACR_TRANSLATEMOD"
#define KACR_RCONPREVENT "KACR_RCONPREVENT"
#define KACR_NETMOD "KACR_NETMOD"
#define KACR_UNABLETOCONTACT "KACR_UNABLETOCONTACT"
#define KACR_EYEMOD "KACR_EYEMOD"
#define KACR_ANTIWH "KACR_ANTIWH"
#define KACR_NOSDKHOOK "KACR_NOSDKHOOK"
#define KACR_CVARS "KACR_CVARS"
#define KACR_CMDMOD "KACR_CMDMOD"
#define KACR_CMDSPAM "KACR_CMDSPAM"
#define KACR_CLIENTMOD "KACR_CLIENTMOD"
#define KACR_CLIENTBALANCE "KACR_CLIENTBALANCE"
#define KACR_CLIENTANTIRESPAWN "KACR_CLIENTANTIRESPAWN"
#define KACR_CLIENTNAMEPROTECT "KACR_CLIENTNAMEPROTECT"
#define KACR_AUTOASSIGNED "KACR_AUTOASSIGNED"
#define KACR_SAYBLOCK "KACR_SAYBLOCK"
#define KACR_FORCEDREVAL "KACR_FORCEDREVAL"
#define KACR_CANNOTREVAL "KACR_CANNOTREVAL"

Handle g_hLanguages = INVALID_HANDLE;

Trans_OnPluginStart()
{
	Handle f_hTemp = INVALID_HANDLE;
	g_hLanguages = CreateTrie();
	
	// Load languages into the adt_trie.
	SetTrieValue(g_hLanguages, "en", any:CreateTrie());
	SetTrieValue(g_hLanguages, "fr", any:CreateTrie());
	SetTrieValue(g_hLanguages, "it", any:CreateTrie());
	SetTrieValue(g_hLanguages, "de", any:CreateTrie());
	
	
	//- English -//
	
	if(!GetTrieValue(g_hLanguages, "en", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
	{
		// SetFailState("Unable to create Language Tree for English"); // We do not want an AC to break, otherwise our Server would be unprotected :O
		KACR_PrintToServer("[Error][KACR] Unable to create Language Tree for English");
		KACR_Log("[Error] Unable to create Language Tree for English");
	}
		
	// Load the phrases into Translations.
	SetTrieString(f_hTemp, KACR_LOADED, "Kigen's Anti-Cheat Redux has been loaded successfully");
	SetTrieString(f_hTemp, KACR_BANNED, "You have been banned for a cheating infraction");
	SetTrieString(f_hTemp, KACR_GBANNED, "You are banned from all Kigen's Anti-Cheat Redux (KACR) protected servers. See https://djplaya.github.io/kigen-ac_redux for more information");
	SetTrieString(f_hTemp, KACR_VACBANNED, "This Kigen's Anti-Cheat Redux (KACR) protected server does not allow VALVe's Anti-Cheat (VAC) banned players");
	SetTrieString(f_hTemp, KACR_KCMDSPAM, "You have been kicked for command spamming");
	SetTrieString(f_hTemp, KACR_ADDCMDUSAGE, "Usage: kacr_addcmd <command name> <ban (1 or 0)>");
	SetTrieString(f_hTemp, KACR_ADDCMDSUCCESS, "You have successfully added %s to the command block list");
	SetTrieString(f_hTemp, KACR_ADDCMDFAILURE, "%s already exists in the command block list");
	SetTrieString(f_hTemp, KACR_REMCMDUSAGE, "Usage: kacr_removecmd <command name>");
	SetTrieString(f_hTemp, KACR_REMCMDSUCCESS, "You have successfully removed %s from the command block list");
	SetTrieString(f_hTemp, KACR_REMCMDFAILURE, "%s is not in the command block list");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDUSAGE, "Usage: kacr_addignorecmd <command name>");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDSUCCESS, "You have successfully added %s to the command ignore list");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDFAILURE, "%s already exists in the command ignore list.");
	SetTrieString(f_hTemp, KACR_REMIGNCMDUSAGE, "Usage: kacr_removeignorecmd <command name>");
	SetTrieString(f_hTemp, KACR_REMIGNCMDSUCCESS, "You have successfully removed %s from the command ignore list");
	SetTrieString(f_hTemp, KACR_REMIGNCMDFAILURE, "%s is not in the command ignore list");
	SetTrieString(f_hTemp, KACR_FAILEDTOREPLY, "Your client has failed to reply to a query in time. Please reconnect or restart your game");
	SetTrieString(f_hTemp, KACR_FAILEDAUTH, "Your client has failed to authorize in time. Please reconnect or restart your game");
	SetTrieString(f_hTemp, KACR_CLIENTCORRUPT, "Your client has become corrupted or is misconfigured. Please restart your game before reconnecting");
	SetTrieString(f_hTemp, KACR_REMOVEPLUGINS, "Please remove any third party plugins from your client before joining this server again");
	SetTrieString(f_hTemp, KACR_HASPLUGIN, "%N (%s) has a plugin running, returned %s");
	SetTrieString(f_hTemp, KACR_MUTED, "%N has been muted by Kigen's Anti-Cheat Redux");
	SetTrieString(f_hTemp, KACR_HASNOTEQUAL, "%N (%s) returned a bad value on %s (value %s, should be %s)");
	SetTrieString(f_hTemp, KACR_SHOULDEQUAL, "Your ConVar %s should equal %s but it was set to %s. Please correct this before rejoining");
	SetTrieString(f_hTemp, KACR_HASNOTGREATER, "%N (%s) has ConVar %s set to %s when it should be greater than or equal to %s");
	SetTrieString(f_hTemp, KACR_SHOULDGREATER, "Your ConVar %s should be greater than or equal to %s but was set to %s. Please correct this before rejoining");
	SetTrieString(f_hTemp, KACR_HASNOTLESS, "%N (%s) has ConVar %s set to %s when it should be less than or equal to %s");
	SetTrieString(f_hTemp, KACR_SHOULDLESS, "Your ConVar %s should be less than or equal to %s but was set to %s. Please correct this before rejoining");
	SetTrieString(f_hTemp, KACR_HASNOTBOUND, "%N (%s) has ConVar %s set to %s when it should be beteween %s and %f");
	SetTrieString(f_hTemp, KACR_SHOULDBOUND, "Your ConVar %s should be between %s and %f but was set to %s. Please correct this before rejoining");
	SetTrieString(f_hTemp, KACR_BANIP, "You were banned by the server");
	SetTrieString(f_hTemp, KACR_ADDCVARUSAGE, "Usage: kacr_addcvar <cvar name> <comparison type> <action> <value> <value2 if bound>");
	SetTrieString(f_hTemp, KACR_REMCVARUSAGE, "Usage: kacr_removecvar <cvar name>");
	SetTrieString(f_hTemp, KACR_REMCVARSUCCESS, "ConVar %s was successfully removed from the check list");
	SetTrieString(f_hTemp, KACR_REMCVARFAILED, "Unable to find ConVar %s in the check list");
	SetTrieString(f_hTemp, KACR_ADDCVARBADNAME, "The ConVar name \"%s\" is invalid and cannot be used");
	SetTrieString(f_hTemp, KACR_ADDCVARBADCOMP, "Unrecognized comparison type \"%s\", acceptable values: \"equal\", \"greater\", \"less\", \"between\", or \"strequal\"");
	SetTrieString(f_hTemp, KACR_ADDCVARBADACT, "Unrecognized action type \"%s\", acceptable values: \"warn\", \"mute\", \"kick\", or \"ban\"");
	SetTrieString(f_hTemp, KACR_ADDCVARBADBOUND, "Bound comparison type needs two values to compare with");
	SetTrieString(f_hTemp, KACR_ADDCVAREXISTS, "The ConVar %s already exists in the check list");
	SetTrieString(f_hTemp, KACR_ADDCVARSUCCESS, "Successfully added ConVar %s to the check list");
	SetTrieString(f_hTemp, KACR_ADDCVARFAILED, "Failed to add ConVar %s to the check list");
	SetTrieString(f_hTemp, KACR_CHANGENAME, "Please change your name");
	SetTrieString(f_hTemp, KACR_CBANNED, "You have been banned for a command usage violation");
	SetTrieString(f_hTemp, KACR_STATUSREPORT, "Kigen's Anti-Cheat Redux Status Report");
	SetTrieString(f_hTemp, KACR_ON, "On");
	SetTrieString(f_hTemp, KACR_OFF, "Off");
	SetTrieString(f_hTemp, KACR_DISABLED, "Disabled");
	SetTrieString(f_hTemp, KACR_ERROR, "Error");
	SetTrieString(f_hTemp, KACR_NOREPORT, "There is nothing to report.");
	SetTrieString(f_hTemp, KACR_TRANSLATEMOD, "Translations");
	SetTrieString(f_hTemp, KACR_RCONPREVENT, "RCON Crash Prevention");
	SetTrieString(f_hTemp, KACR_NETMOD, "Network");
	SetTrieString(f_hTemp, KACR_UNABLETOCONTACT, "Unable to contact the KACR Master");
	SetTrieString(f_hTemp, KACR_EYEMOD, "Eye Test");
	SetTrieString(f_hTemp, KACR_ANTIWH, "Anti-Wallhack");
	SetTrieString(f_hTemp, KACR_NOSDKHOOK, "Disabled; Unable to find SDKHooks.ext");
	SetTrieString(f_hTemp, KACR_CVARS, "CVars Detection");
	SetTrieString(f_hTemp, KACR_CMDMOD, "Command Protection");
	SetTrieString(f_hTemp, KACR_CMDSPAM, "Command Spam Protection");
	SetTrieString(f_hTemp, KACR_CLIENTMOD, "Client Module");
	SetTrieString(f_hTemp, KACR_CLIENTBALANCE, "Client Team Auto-Balance");
	SetTrieString(f_hTemp, KACR_CLIENTANTIRESPAWN, "Client Anti-Rejoin");
	SetTrieString(f_hTemp, KACR_CLIENTNAMEPROTECT, "Client Name Protection");
	SetTrieString(f_hTemp, KACR_AUTOASSIGNED, "[KACR] You have been Auto-Assigned to a team");
	SetTrieString(f_hTemp, KACR_SAYBLOCK, "[KACR] Your say has been blocked due to a invalid character");
	SetTrieString(f_hTemp, KACR_FORCEDREVAL, "[KACR] Forced revalidation on all connected players");
	SetTrieString(f_hTemp, KACR_CANNOTREVAL, "[KACR] Cannot force revalidation until all player have already been validated");
	
	
	//- French -//
	
	// Thank you to vintage for this translation. http://kigenac.com/memberlist.php?mode=viewprofile&u=1035
	if(!GetTrieValue(g_hLanguages, "fr", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
	{
		// SetFailState("Unable to create Language Tree for French"); // We do not want an AC to break, otherwise our Server would be unprotected :O
		KACR_PrintToServer("[Error][KACR] Unable to create Language Tree for French");
		KACR_Log("[Error] Unable to create Language Tree for French");
	}
		
	SetTrieString(f_hTemp, KACR_LOADED, "Kigen's Anti-Cheat Redux est opérationnel");
	SetTrieString(f_hTemp, KACR_BANNED, "Vous avez été banni pour cheat détecté");
	SetTrieString(f_hTemp, KACR_GBANNED, "Vous avez été banni de tous les serveurs protégés par Kigen's Anti-Cheat Redux (KACR). Voir https://djplaya.github.io/kigen-ac_redux pour plus d'informations");
	SetTrieString(f_hTemp, KACR_VACBANNED, "Ce serveur protégé par Kigen's Anti-Cheat Redux (KACR) n'autorise pas les joueurs bannis par VALVe's Anti-Cheat (VAC)");
	SetTrieString(f_hTemp, KACR_KCMDSPAM, "Vous avez été kické pour spam de commandes");
	SetTrieString(f_hTemp, KACR_ADDCMDUSAGE, "Usage: akcr_addcmd <nom de la commande> <ban (1 or 0)>");
	SetTrieString(f_hTemp, KACR_ADDCMDSUCCESS, "Vous avez correctement ajouté %s à la liste des commandes à surveiller");
	SetTrieString(f_hTemp, KACR_ADDCMDFAILURE, "%s existe déjà dans la liste des commandes à surveiller");
	SetTrieString(f_hTemp, KACR_REMCMDUSAGE, "Usage: kacr_removecmd <nom de la commande>");
	SetTrieString(f_hTemp, KACR_REMCMDSUCCESS, "Vous avez correctement retiré %s de la liste des commandes à surveiller");
	SetTrieString(f_hTemp, KACR_REMCMDFAILURE, "%s n'est pas dans la liste des commandes à surveiller");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDUSAGE, "Usage: kacr_addignorecmd <nom de la commande>");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDSUCCESS, "Vous avez correctement ajouté %s à la liste des commandes à ignorer");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDFAILURE, "%s existe déjà dans la liste des commandes à ignorer");
	SetTrieString(f_hTemp, KACR_REMIGNCMDUSAGE, "Usage: kacr_removeignorecmd <nom de la commande>");
	SetTrieString(f_hTemp, KACR_REMIGNCMDSUCCESS, "Vous avez correctement retiré %s de la liste des commandes à ignorer");
	SetTrieString(f_hTemp, KACR_REMIGNCMDFAILURE, "%s n'est pas dans la liste des commandes à ignorer");
	SetTrieString(f_hTemp, KACR_FAILEDTOREPLY, "Votre client n'a pas répondu à temps à une requête. Veuillez vous reconnecter ou redémarrer votre jeu");
	SetTrieString(f_hTemp, KACR_FAILEDAUTH, "Votre client n'a pas autorisé une requête. Veuillez vous reconnecter ou redémarrer votre jeu");
	SetTrieString(f_hTemp, KACR_CLIENTCORRUPT, "Votre client a été corrompu. Veuillez redémarrer votre jeu avant de vous reconnecter");
	SetTrieString(f_hTemp, KACR_REMOVEPLUGINS, "Veuillez supprimer les plugins tiers de votre client pour rejoindre ce serveur");
	SetTrieString(f_hTemp, KACR_HASPLUGIN, "%N (%s) a un plugin activé, renvoie: %s");
	SetTrieString(f_hTemp, KACR_MUTED, "%N a été rendu silencieux par Kigen's Anti-Cheat Redux");
	SetTrieString(f_hTemp, KACR_HASNOTEQUAL, "%N (%s) a renvoyé une mauvaise valeur pour %s (la valeur %s, devrait être %s)");
	SetTrieString(f_hTemp, KACR_SHOULDEQUAL, "Votre cvar %s devrait être égale à %s mais est réglée à %s. Veuillez corriger! Merci");
	SetTrieString(f_hTemp, KACR_HASNOTGREATER, "%N (%s) a la cvar %s réglée à %s alors qu'elle devrait être supérieure ou égale à %s");
	SetTrieString(f_hTemp, KACR_SHOULDGREATER, "Votre cvar %s devrait être supérieure ou égale à %s mais est réglée à %s. Veuillez corriger! Merci");
	SetTrieString(f_hTemp, KACR_HASNOTLESS, "%N (%s) a la cvar %s réglée à %s alors qu'elle devrait être inférieure ou égale à %s");
	SetTrieString(f_hTemp, KACR_SHOULDLESS, "Votre cvar %s devrait être inférieure ou égale à %s mais est réglée à %s. Veuillez corriger! Merci");
	SetTrieString(f_hTemp, KACR_HASNOTBOUND, "%N (%s) a la cvar %s réglée à %s walors qu'elle devrait être entre %s et %f");
	SetTrieString(f_hTemp, KACR_SHOULDBOUND, "Votre cvar %s devrait être entre %s et %f mais est réglée à %s. Veuillez corriger! Merci");
	SetTrieString(f_hTemp, KACR_BANIP, "Vous avez été banni par le serveur");
	SetTrieString(f_hTemp, KACR_ADDCVARUSAGE, "Usage: kacr_addcvar <nom de la cvar> <type de comparaison> <action> <value> <valeur2 si encadrement>");
	SetTrieString(f_hTemp, KACR_REMCVARUSAGE, "Usage: kacr_removecvar <nom de la cvar>");
	SetTrieString(f_hTemp, KACR_REMCVARSUCCESS, "La cvar %s a été retirée correctement de la liste de surveillance");
	SetTrieString(f_hTemp, KACR_REMCVARFAILED, "Impossible de trouver la cvar %s dans la liste de surveillance");
	SetTrieString(f_hTemp, KACR_ADDCVARBADNAME, "Le nom de la cvar \"%s\" n'est pas valide et ne peut être utilisé");
	SetTrieString(f_hTemp, KACR_ADDCVARBADCOMP, "Comparaison non reconnue \"%s\", valeurs acceptées: \"equal\", \"greater\", \"less\", \"between\", ou \"strequal\"");
	SetTrieString(f_hTemp, KACR_ADDCVARBADACT, "Action non reconnue \"%s\", valeurs acceptées: \"warn\", \"mute\", \"kick\", or \"ban\"");
	SetTrieString(f_hTemp, KACR_ADDCVARBADBOUND, "La comparaison d'encadrement nécessite deux valeurs pour être active");
	SetTrieString(f_hTemp, KACR_ADDCVAREXISTS, "La cvar %s existe déjà dans la liste de surveillance");
	SetTrieString(f_hTemp, KACR_ADDCVARSUCCESS, "La cvar %s a été correctement ajoutée à la liste de surveillance");
	SetTrieString(f_hTemp, KACR_ADDCVARFAILED, "La cvar %s n'a pu être ajoutée à la liste de surveillance");
	SetTrieString(f_hTemp, KACR_CHANGENAME, "Veuillez changer votre nom! SVP");
	SetTrieString(f_hTemp, KACR_CBANNED, "Vous avez été banni pour une violation d'usage de commande");
	SetTrieString(f_hTemp, KACR_STATUSREPORT, "Rapport de Kigen's Anti-Cheat Redux");
	SetTrieString(f_hTemp, KACR_ON, "On");
	SetTrieString(f_hTemp, KACR_OFF, "Off");
	SetTrieString(f_hTemp, KACR_DISABLED, "Désactivé");
	SetTrieString(f_hTemp, KACR_ERROR, "Erreur");
	SetTrieString(f_hTemp, KACR_NOREPORT, "Il n'y a rien à noter dans le rapport");
	SetTrieString(f_hTemp, KACR_TRANSLATEMOD, "Traductions");
	SetTrieString(f_hTemp, KACR_RCONPREVENT, "Prévention du crash RCON");
	SetTrieString(f_hTemp, KACR_NETMOD, "Network");
	SetTrieString(f_hTemp, KACR_UNABLETOCONTACT, "Impossible de contacter le server maître KACR");
	SetTrieString(f_hTemp, KACR_EYEMOD, "Eye Test");
	SetTrieString(f_hTemp, KACR_ANTIWH, "Anti-Wallhack");
	SetTrieString(f_hTemp, KACR_NOSDKHOOK, "Désactivé; Impossible de trouver SDKHooks.ext");
	SetTrieString(f_hTemp, KACR_CVARS, "Surveillance des CVars");
	SetTrieString(f_hTemp, KACR_CMDMOD, "Protection des Commandes");
	SetTrieString(f_hTemp, KACR_CMDSPAM, "Protection du spam de Commandes");
	SetTrieString(f_hTemp, KACR_CLIENTMOD, "Module Client");
	SetTrieString(f_hTemp, KACR_CLIENTBALANCE, "Client Team Auto-Balance");
	SetTrieString(f_hTemp, KACR_CLIENTANTIRESPAWN, "Client Anti-Rejoindre");
	SetTrieString(f_hTemp, KACR_CLIENTNAMEPROTECT, "Client Protection du Nom");
	SetTrieString(f_hTemp, KACR_AUTOASSIGNED, "[KACR] Vous avez rejoint automatiquement une team");
	SetTrieString(f_hTemp, KACR_SAYBLOCK, "[KACR] Vous ne pouvez plus écrire dû à un caractère non autorisé");
	SetTrieString(f_hTemp, KACR_FORCEDREVAL, "[KACR] Revalidation forcée sur tous les joueurs connectés");
	SetTrieString(f_hTemp, KACR_CANNOTREVAL, "[KACR] Revalidation impossible, tous les joueurs ont déjà été validés");
	
	
	//- Italian -//
	
	// Thank you to asterix for this translation. http://kigenac.com/memberlist.php?mode=viewprofile&u=116
	if(!GetTrieValue(g_hLanguages, "it", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
	{
		// SetFailState("Unable to create Language Tree for Italian"); // We do not want an AC to break, otherwise our Server would be unprotected :O
		KACR_PrintToServer("[Error][KACR] Unable to create Language Tree for Italian");
		KACR_Log("[Error] Unable to create Language Tree for Italian");
	}
		
	SetTrieString(f_hTemp, KACR_LOADED, "L'anticheats Kigen Redux è stato caricato con successo");
	SetTrieString(f_hTemp, KACR_BANNED, "Sei stato bannato per aver utilizzato dei trucchi");
	SetTrieString(f_hTemp, KACR_GBANNED, "Sei bannato da tutti i server protetti dall'anticheats Kigen Redux (KACR). Visita https://djplaya.github.io/kigen-ac_redux per ulteriori informazioni");
	SetTrieString(f_hTemp, KACR_VACBANNED, "I server protetti dall'anticheats Kigen Redux (KACR) non permettono l'ingresso ai giocatori bannati dall'anticheats della VALVE (VAC)");
	SetTrieString(f_hTemp, KACR_KCMDSPAM, "Se stato kikkato per spamming");
	SetTrieString(f_hTemp, KACR_ADDCMDUSAGE, "Utilizzo: kacr_addcmd <nome del comando> <ban (1 o 0)>");
	SetTrieString(f_hTemp, KACR_ADDCMDSUCCESS, "Sei stato aggiunto %s alla lista dei blocchi comandi");
	SetTrieString(f_hTemp, KACR_ADDCMDFAILURE, "%s già esistente nella lista dei blocchi comandi");
	SetTrieString(f_hTemp, KACR_REMCMDUSAGE, "Utilizzo: kacr_removecmd <nome del comando>");
	SetTrieString(f_hTemp, KACR_REMCMDSUCCESS, "Sei stato rimosso %s dalla lista dei comandi");
	SetTrieString(f_hTemp, KACR_REMCMDFAILURE, "%s non è nella lista dei blocchi comandi");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDUSAGE, "Utilizzo: kacr_addignorecmd <nome del comando>");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDSUCCESS, "Seistato aggiunto %s alla lista ignora");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDFAILURE, "%s esiste già nella lista ignora");
	SetTrieString(f_hTemp, KACR_REMIGNCMDUSAGE, "Utilizzo: kacr_removeignorecmd <nome del comando>");
	SetTrieString(f_hTemp, KACR_REMIGNCMDSUCCESS, "Sei stato rimosso %s dalla lista ignora");
	SetTrieString(f_hTemp, KACR_REMIGNCMDFAILURE, "%s non è trai comandi della lista ignora");
	SetTrieString(f_hTemp, KACR_FAILEDTOREPLY, "Il giocatore ha fallito nel rispondere in tempo a delle query. Per favore riconnetti o restarta il tuo gioco");
	SetTrieString(f_hTemp, KACR_FAILEDAUTH, "Il giocatore non è riuscito ad ottenere l'autorizzazione in tempo.Per favore riconnetti o restarta il tuo gioco");
	SetTrieString(f_hTemp, KACR_CLIENTCORRUPT, "Il giocatore sta per avere problemi di integrità. Per favore riconnetti o restarta il tuo gioco");
	SetTrieString(f_hTemp, KACR_REMOVEPLUGINS, "Per favore rimuovi tutti i terzi programmi dal tuo pc prima di collegarti nuovamente a questo server");
	SetTrieString(f_hTemp, KACR_HASPLUGIN, "%N (%s) ha un programma funzionante, risposta %s");
	SetTrieString(f_hTemp, KACR_MUTED, "%N è stato mutato dall'anticheats Kigen Redux");
	SetTrieString(f_hTemp, KACR_HASNOTEQUAL, "%N (%s) non corretta risposta del valore %s (valore %s, deve essere %s)");
	SetTrieString(f_hTemp, KACR_SHOULDEQUAL, "Il tuo valore %s deve essere uguale a %s invece è %s. Per favore modificalo prima di ricollegarti a questo server");
	SetTrieString(f_hTemp, KACR_HASNOTGREATER, "%N (%s) ha il valore %s è %s quando deve essere maggiore o uguale a %s");
	SetTrieString(f_hTemp, KACR_SHOULDGREATER, "Il tuo valore %s deve essere maggiore o uguale a %s invece è %s. Per favore modificalo prima di ricollegarti");
	SetTrieString(f_hTemp, KACR_HASNOTLESS, "%N (%s) ha il valore %s è %s quando deve essere inferiore o uguale a %s");
	SetTrieString(f_hTemp, KACR_SHOULDLESS, "Il tuo valore %s deve essere inferiore o uguale a %s invece è %s. Per favore modificalo prima di ricollegarti");
	SetTrieString(f_hTemp, KACR_HASNOTBOUND, "%N (%s) ha il valore %s a %s quando deve essere tra %s e %f");
	SetTrieString(f_hTemp, KACR_SHOULDBOUND, "Il tuo valore %s deve essere tra %s e %f invece è %s. Per favore modificalo prima di ricollegarti");
	SetTrieString(f_hTemp, KACR_BANIP, "Sei stato bannato dal server");
	SetTrieString(f_hTemp, KACR_ADDCVARUSAGE, "Utilizzo: kacr_addcvar <nome del cvar> <tipo del confronto> <azione> <valore> <valore2 se bindato>");
	SetTrieString(f_hTemp, KACR_REMCVARUSAGE, "Usage: kacr_removecvar <nome del cvar>");
	SetTrieString(f_hTemp, KACR_REMCVARSUCCESS, "Il cvar %s è stato rmisso dalla lista di controllo");
	SetTrieString(f_hTemp, KACR_REMCVARFAILED, "Impossibile trovare il cvar %s nella lista di controllo");
	SetTrieString(f_hTemp, KACR_ADDCVARBADNAME, "Il nome di questo cvar \"%s\" non è valido e non può essere utilizzato");
	SetTrieString(f_hTemp, KACR_ADDCVARBADCOMP, "Confronto non riconosciuto \"%s\", valore accettabile: \"uguale\", \"maggiore\", \"inferiore\", \"tra\", o \"strequal\"");
	SetTrieString(f_hTemp, KACR_ADDCVARBADACT, "Azione non riconosciuta \"%s\", valore accettabile: \"avvertimento\", \"mutare\", \"kick\", o \"bannare\"");
	SetTrieString(f_hTemp, KACR_ADDCVARBADBOUND, "Il confronto bindato necessita di due valori da confrontare");
	SetTrieString(f_hTemp, KACR_ADDCVAREXISTS, "Il cvar %s esiste già nella lista di controllo");
	SetTrieString(f_hTemp, KACR_ADDCVARSUCCESS, "Il cvar %s è stato aggiunto alla lista di controllo");
	SetTrieString(f_hTemp, KACR_ADDCVARFAILED, "Non si è riusciti ad aggiungere il cvar %s alla lista di controllo");
	SetTrieString(f_hTemp, KACR_CHANGENAME, "Per favore cambia il tuo nome");
	SetTrieString(f_hTemp, KACR_CBANNED, "Sei stato bannato per utilizzo proibito dei comandi");
	SetTrieString(f_hTemp, KACR_STATUSREPORT, "Kigen's Anti-Cheat Redux Status Report");
	SetTrieString(f_hTemp, KACR_ON, "On");
	SetTrieString(f_hTemp, KACR_OFF, "Off");
	SetTrieString(f_hTemp, KACR_DISABLED, "Disabilitato");
	SetTrieString(f_hTemp, KACR_ERROR, "Errore");
	SetTrieString(f_hTemp, KACR_NOREPORT, "Non c'è nulla da riportare");
	SetTrieString(f_hTemp, KACR_TRANSLATEMOD, "Traduzioni");
	SetTrieString(f_hTemp, KACR_RCONPREVENT, "RCON Prevenzione Crash");
	SetTrieString(f_hTemp, KACR_NETMOD, "Rete");
	SetTrieString(f_hTemp, KACR_UNABLETOCONTACT, "Impossibile contattare il KACR Master");
	SetTrieString(f_hTemp, KACR_EYEMOD, "Test visivo");
	SetTrieString(f_hTemp, KACR_ANTIWH, "Anti-Wallhack");
	SetTrieString(f_hTemp, KACR_NOSDKHOOK, "Disabilitato; Impossibile trovare SDKHooks.ext");
	SetTrieString(f_hTemp, KACR_CVARS, "CVars Controllo");
	SetTrieString(f_hTemp, KACR_CMDMOD, "Command Protezione");
	SetTrieString(f_hTemp, KACR_CMDSPAM, "Protezione Comando Spam");
	SetTrieString(f_hTemp, KACR_CLIENTMOD, "Modulo Giocatore");
	SetTrieString(f_hTemp, KACR_CLIENTBALANCE, "Auto-Balance team giocatori");
	SetTrieString(f_hTemp, KACR_CLIENTANTIRESPAWN, "Giocatori Anti-Rejoin");
	SetTrieString(f_hTemp, KACR_CLIENTNAMEPROTECT, "Protezione nomi giocatori");
	SetTrieString(f_hTemp, KACR_AUTOASSIGNED, "[KACR] Sei stato assegnato forzatamente ad un Team");
	SetTrieString(f_hTemp, KACR_SAYBLOCK, "[KACR] Il tuo testo è stato bloccato a causa di alcuni caratteri non validi");
	SetTrieString(f_hTemp, KACR_FORCEDREVAL, "[KACR] Convalida forzata di tutti i giocatori connessi");
	SetTrieString(f_hTemp, KACR_CANNOTREVAL, "[KACR] Non si può forzare la validazione dei giocatori finchè questi non siano stati tutti validati");
	
	
	//- German -//
	
	if(!GetTrieValue(g_hLanguages, "de", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
	{
		// SetFailState("Unable to create Language Tree for German"); // We do not want an AC to break, otherwise our Server would be unprotected :O
		KACR_PrintToServer("[Error][KACR] Unable to create Language Tree for German");
		KACR_Log("[Error] Unable to create Language Tree for German");
	}
	
	// Load the phrases into Translations.
	SetTrieString(f_hTemp, KACR_LOADED, "Kigen's Anti-Cheat Redux erfolgreich geladen");
	SetTrieString(f_hTemp, KACR_BANNED, "Du wurdest wegen aufgrund von cheating Versuchen verbannt");
	SetTrieString(f_hTemp, KACR_GBANNED, "Du wurdest von allen Kigen's Anti-Cheat Redux (KACR) geschützten Servern verbannt. Für weitere Infos, besuche: https://djplaya.github.io/kigen-ac_redux");
	SetTrieString(f_hTemp, KACR_VACBANNED, "Dieser Server ist durch Kigen's Anti-Cheat Redux (KACR) geschützt und erlaubt keine VALVe Anti-Cheat (VAC) gebannte Spieler");
	SetTrieString(f_hTemp, KACR_KCMDSPAM, "Du wurdest aufgrund von Kommando spamming gekickt");
	SetTrieString(f_hTemp, KACR_ADDCMDUSAGE, "Anwendung: kacr_addcmd <Kommando> <ban (1 or 0)>");
	SetTrieString(f_hTemp, KACR_ADDCMDSUCCESS, "Du hast erfolgreich %s zur Kommando Blacklist hinzugefügt");
	SetTrieString(f_hTemp, KACR_ADDCMDFAILURE, "%s befindet sich bereits in der Kommando Blacklist");
	SetTrieString(f_hTemp, KACR_REMCMDUSAGE, "Anwendung: kacr_removecmd <Kommando>");
	SetTrieString(f_hTemp, KACR_REMCMDSUCCESS, "Du hast erfolgreich %s von der Kommando Blacklist entfernt");
	SetTrieString(f_hTemp, KACR_REMCMDFAILURE, "%s ist nicht in der Kommando Blacklist");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDUSAGE, "Anwendung: kacr_addignorecmd <Kommando>");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDSUCCESS, "Du hast erfolgreich %s zur Spam Whitelist hinzugefügt");
	SetTrieString(f_hTemp, KACR_ADDIGNCMDFAILURE, "%s befindet sich bereits in der Spam Whitelist");
	SetTrieString(f_hTemp, KACR_REMIGNCMDUSAGE, "Anwendung: kacr_removeignorecmd <Kommando>");
	SetTrieString(f_hTemp, KACR_REMIGNCMDSUCCESS, "Du hast erfolgreich %s von der Spam Whitelist entfernt");
	SetTrieString(f_hTemp, KACR_REMIGNCMDFAILURE, "%s ist nicht in der Spam Whitelist");
	SetTrieString(f_hTemp, KACR_FAILEDTOREPLY, "Dein Spiel hat eine Anfrag nicht rechtzeitig bearbeitet. Bitte reconnecte oder starte dein Spiel neu");
	SetTrieString(f_hTemp, KACR_FAILEDAUTH, "Dein Spiel hat sich nicht rechtzeitig am Server angemeldet. Bitte reconnecte oder starte dein Spiel neu");
	SetTrieString(f_hTemp, KACR_CLIENTCORRUPT, "Dein Spiel is möglicherweise beschädigt oder falsch eingestellt. Bitte starte dein Spiel neu before du dich wieder verbindest");
	SetTrieString(f_hTemp, KACR_REMOVEPLUGINS, "Bitte entferne sämtliche Plugins von deinem Client bevor du dich erneut verbindest");
	SetTrieString(f_hTemp, KACR_HASPLUGIN, "%N (%s) hat ein Plugin am laufen, Rückgabe %s");
	SetTrieString(f_hTemp, KACR_MUTED, "%N wurde stumm geschaltet durch Kigen's Anti-Cheat Redux");
	SetTrieString(f_hTemp, KACR_HASNOTEQUAL, "%N (%s) hat ConVar %s auf einem falschen Wert (Wert %s, sollte %s sein)");
	SetTrieString(f_hTemp, KACR_SHOULDEQUAL, "Deine ConVar %s sollte %s sein, aber sie ist auf %s gesetzt. Bitte korrigiere das vor dem reconnecten");
	SetTrieString(f_hTemp, KACR_HASNOTGREATER, "%N (%s) hat ConVar %s auf %s, der Wert sollte allerdings größer oder gleich %s sein");
	SetTrieString(f_hTemp, KACR_SHOULDGREATER, "Deine ConVar %s sollte größer oder gleich %s sein, aber sie ist auf %s gesetzt. Bitte korrigiere das vor dem reconnecten");
	SetTrieString(f_hTemp, KACR_HASNOTLESS, "%N (%s) hat ConVar %s auf %s, der Wert sollte allerdings kleiner oder gleich %s sein");
	SetTrieString(f_hTemp, KACR_SHOULDLESS, "Deine ConVar %s sollte kleiner oder gleich %s sein, aber sie ist auf %s gesetzt. Bitte korrigiere das vor dem reconnecten");
	SetTrieString(f_hTemp, KACR_HASNOTBOUND, "%N (%s) hat ConVar %s auf %s, der Wert sollte allerdings zwischen %s und %f liegen");
	SetTrieString(f_hTemp, KACR_SHOULDBOUND, "Deine ConVar %s sollte zwischen %s und %f eingestellt sein, aber sie ist auf %s gesetzt. Bitte korrigiere das vor dem reconnecten");
	SetTrieString(f_hTemp, KACR_BANIP, "Du wurdest vom Server gebannt");
	SetTrieString(f_hTemp, KACR_ADDCVARUSAGE, "Anwendung: kacr_addcvar <CVar Name> <Vergleichstyp> <Aktionstyp> <Startwert> <Endwert when nötig>");
	SetTrieString(f_hTemp, KACR_REMCVARUSAGE, "Anwendung: kacr_removecvar <CVar Name>");
	SetTrieString(f_hTemp, KACR_REMCVARSUCCESS, "ConVar %s wurde von der Checkliste entfernt");
	SetTrieString(f_hTemp, KACR_REMCVARFAILED, "ConVar %s konnte nicht in der Checkliste gefunden werden");
	SetTrieString(f_hTemp, KACR_ADDCVARBADNAME, "Der ConVar Name \"%s\" ist ungültig un kann nicht verwendet werden");
	SetTrieString(f_hTemp, KACR_ADDCVARBADCOMP, "Ungültiger Vergleichstyp \"%s\", gültige Werte sind: \"equal\", \"greater\", \"less\", \"between\", oder \"strequal\"");
	SetTrieString(f_hTemp, KACR_ADDCVARBADACT, "Ungültiger Aktionstyp \"%s\", gültige Werte sind: \"warn\", \"mute\", \"kick\", oder \"ban\"");
	SetTrieString(f_hTemp, KACR_ADDCVARBADBOUND, "Dieser Vergleichstyp braucht einen Start und Endwert");
	SetTrieString(f_hTemp, KACR_ADDCVAREXISTS, "Die ConVar %s gibt es bereits in der Checkliste");
	SetTrieString(f_hTemp, KACR_ADDCVARSUCCESS, "Convar %s wurde der Checkliste hinzugefügt");
	SetTrieString(f_hTemp, KACR_ADDCVARFAILED, "ConVar %s konnte nicht der Checkliste hinzugefügt werden");
	SetTrieString(f_hTemp, KACR_CHANGENAME, "Bitte ändere deinen Namen");
	SetTrieString(f_hTemp, KACR_CBANNED, "Du wurdest wegen Kommando misbrauchs verbannt");
	SetTrieString(f_hTemp, KACR_STATUSREPORT, "Kigen's Anti-Cheat Redux Status Bericht");
	SetTrieString(f_hTemp, KACR_ON, "An");
	SetTrieString(f_hTemp, KACR_OFF, "Aus");
	SetTrieString(f_hTemp, KACR_DISABLED, "Deaktiviert");
	SetTrieString(f_hTemp, KACR_ERROR, "Fehler");
	SetTrieString(f_hTemp, KACR_NOREPORT, "Es gibt nichts zu berichten");
	SetTrieString(f_hTemp, KACR_TRANSLATEMOD, "Übersetzungen");
	SetTrieString(f_hTemp, KACR_RCONPREVENT, "RCON Crash Prevention");
	SetTrieString(f_hTemp, KACR_NETMOD, "Netzwerk");
	SetTrieString(f_hTemp, KACR_UNABLETOCONTACT, "Kann KACR Master Server nicht erreichen");
	SetTrieString(f_hTemp, KACR_EYEMOD, "Sicht Test");
	SetTrieString(f_hTemp, KACR_ANTIWH, "Anti-Wallhack");
	SetTrieString(f_hTemp, KACR_NOSDKHOOK, "Deaktiviert; Kann Erweiterung SDKHooks.ext nicht finden");
	SetTrieString(f_hTemp, KACR_CVARS, "CVar Überprüfung");
	SetTrieString(f_hTemp, KACR_CMDMOD, "Kommando Schutz");
	SetTrieString(f_hTemp, KACR_CMDSPAM, "Kommando Spam Schutz");
	SetTrieString(f_hTemp, KACR_CLIENTMOD, "Klient Modul");
	SetTrieString(f_hTemp, KACR_CLIENTBALANCE, "Klient Team Auto-Balance");
	SetTrieString(f_hTemp, KACR_CLIENTANTIRESPAWN, "Anti-Rejoin Schutz");
	SetTrieString(f_hTemp, KACR_CLIENTNAMEPROTECT, "Klient Namen Schutz");
	SetTrieString(f_hTemp, KACR_AUTOASSIGNED, "[KACR] Du wurdest automatisch einem Team zugewiesen");
	SetTrieString(f_hTemp, KACR_SAYBLOCK, "[KACR] Deine Nachricht wurde blockiert, da sie ungültige Zeichen enthält");
	SetTrieString(f_hTemp, KACR_FORCEDREVAL, "[KACR] Erzwungene Überprüfung aller verbundenen Spieler");
	SetTrieString(f_hTemp, KACR_CANNOTREVAL, "[KACR] Eine Überprüfung kann nicht gestartet werden bis alle Spieler fertig geprüft wurden");
}