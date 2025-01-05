/*
	Based on Kigen's Anti-Cheat
	Copyright (C) 2007-2011 CodingDirect LLC
	
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

StringMap g_hLanguages;

Trans_OnPluginStart()
{
	StringMap f_hTemp = new StringMap();
	g_hLanguages = new StringMap();
	
	// Load languages into the Map
	g_hLanguages.SetValue("en", any:new StringMap()); // English
	g_hLanguages.SetValue("fr", any:new StringMap()); // French
	g_hLanguages.SetValue("it", any:new StringMap()); // Italian
	g_hLanguages.SetValue("de", any:new StringMap()); // German
	g_hLanguages.SetValue("he", any:new StringMap()); // Hebrew
	
	//- English -// Done by Kigen
	if (!g_hLanguages.GetValue("en", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
	{
		// SetFailState("Unable to create Language Hashmap for English"); // We do not want an AC to break, otherwise our Server would be unprotected :O
		KACR_PrintToServer("[Error][KACR] Unable to create Language Hashmap for English");
		KACR_Log("[Error] Unable to create Language Hashmap for English");
	}
	
	// Load the phrases into Translations.
	f_hTemp.SetString(KACR_LOADED, "Kigen's Anti-Cheat Redux has been loaded successfully");
	f_hTemp.SetString(KACR_BANNED, "You have been banned for a cheating infraction");
	f_hTemp.SetString(KACR_GBANNED, "You are banned from all Kigen's Anti-Cheat Redux (KACR) protected servers. See https://djplaya.github.io/kigen-ac_redux for more information");
	f_hTemp.SetString(KACR_VACBANNED, "This Kigen's Anti-Cheat Redux (KACR) protected server does not allow VALVe's Anti-Cheat (VAC) banned players");
	f_hTemp.SetString(KACR_KCMDSPAM, "You have been kicked for command spamming");
	f_hTemp.SetString(KACR_ADDCMDUSAGE, "Usage: kacr_addcmd <command name> <ban (1 or 0)>");
	f_hTemp.SetString(KACR_ADDCMDSUCCESS, "You have successfully added %s to the command block list");
	f_hTemp.SetString(KACR_ADDCMDFAILURE, "%s already exists in the command block list");
	f_hTemp.SetString(KACR_REMCMDUSAGE, "Usage: kacr_removecmd <command name>");
	f_hTemp.SetString(KACR_REMCMDSUCCESS, "You have successfully removed %s from the command block list");
	f_hTemp.SetString(KACR_REMCMDFAILURE, "%s is not in the command block list");
	f_hTemp.SetString(KACR_ADDIGNCMDUSAGE, "Usage: kacr_addignorecmd <command name>");
	f_hTemp.SetString(KACR_ADDIGNCMDSUCCESS, "You have successfully added %s to the command ignore list");
	f_hTemp.SetString(KACR_ADDIGNCMDFAILURE, "%s already exists in the command ignore list.");
	f_hTemp.SetString(KACR_REMIGNCMDUSAGE, "Usage: kacr_removeignorecmd <command name>");
	f_hTemp.SetString(KACR_REMIGNCMDSUCCESS, "You have successfully removed %s from the command ignore list");
	f_hTemp.SetString(KACR_REMIGNCMDFAILURE, "%s is not in the command ignore list");
	f_hTemp.SetString(KACR_FAILEDTOREPLY, "Your client has failed to reply to a query in time. Please reconnect or restart your game");
	f_hTemp.SetString(KACR_FAILEDAUTH, "Your client has failed to authorize in time. Please reconnect or restart your game");
	f_hTemp.SetString(KACR_CLIENTCORRUPT, "Your client has become corrupted or is misconfigured. Please restart your game before reconnecting");
	f_hTemp.SetString(KACR_REMOVEPLUGINS, "Please remove any third party plugins from your client before joining this server again");
	f_hTemp.SetString(KACR_HASPLUGIN, "'%L'<%s> has a plugin running, returned %s");
	f_hTemp.SetString(KACR_MUTED, "%N has been muted by Kigen's Anti-Cheat Redux");
	f_hTemp.SetString(KACR_HASNOTEQUAL, "'%L'<%s> returned a bad value on %s (value %s, should be %s)");
	f_hTemp.SetString(KACR_SHOULDEQUAL, "Your ConVar %s should equal %s but it was set to %s. Please correct this before rejoining");
	f_hTemp.SetString(KACR_HASNOTGREATER, "'%L'<%s> has ConVar %s set to %s when it should be greater than or equal to %s");
	f_hTemp.SetString(KACR_SHOULDGREATER, "Your ConVar %s should be greater than or equal to %s but was set to %s. Please correct this before rejoining");
	f_hTemp.SetString(KACR_HASNOTLESS, "'%L'<%s> has ConVar %s set to %s when it should be less than or equal to %s");
	f_hTemp.SetString(KACR_SHOULDLESS, "Your ConVar %s should be less than or equal to %s but was set to %s. Please correct this before rejoining");
	f_hTemp.SetString(KACR_HASNOTBOUND, "'%L'<%s> has ConVar %s set to %s when it should be beteween %s and %f");
	f_hTemp.SetString(KACR_SHOULDBOUND, "Your ConVar %s should be between %s and %f but was set to %s. Please correct this before rejoining");
	f_hTemp.SetString(KACR_BANIP, "You were banned by the server");
	f_hTemp.SetString(KACR_ADDCVARUSAGE, "Usage: kacr_addcvar <cvar name> <comparison type> <action> <value> <value2 if bound>");
	f_hTemp.SetString(KACR_REMCVARUSAGE, "Usage: kacr_removecvar <cvar name>");
	f_hTemp.SetString(KACR_REMCVARSUCCESS, "ConVar %s was successfully removed from the check list");
	f_hTemp.SetString(KACR_REMCVARFAILED, "Unable to find ConVar %s in the check list");
	f_hTemp.SetString(KACR_ADDCVARBADNAME, "The ConVar name \"%s\" is invalid and cannot be used");
	f_hTemp.SetString(KACR_ADDCVARBADCOMP, "Unrecognized comparison type \"%s\", acceptable values: \"equal\", \"greater\", \"less\", \"between\" or \"strequal\"");
	f_hTemp.SetString(KACR_ADDCVARBADACT, "Unrecognized action type \"%s\", acceptable values: \"warn\", \"mute\", \"kick\" or \"ban\"");
	f_hTemp.SetString(KACR_ADDCVARBADBOUND, "Bound comparison type needs two values to compare with");
	f_hTemp.SetString(KACR_ADDCVAREXISTS, "The ConVar %s already exists in the check list");
	f_hTemp.SetString(KACR_ADDCVARSUCCESS, "Successfully added ConVar %s to the check list");
	f_hTemp.SetString(KACR_ADDCVARFAILED, "Failed to add ConVar %s to the check list");
	f_hTemp.SetString(KACR_CHANGENAME, "Please change your name");
	f_hTemp.SetString(KACR_CBANNED, "You have been banned for a command usage violation");
	f_hTemp.SetString(KACR_STATUSREPORT, "Kigen's Anti-Cheat Redux Status Report");
	f_hTemp.SetString(KACR_ON, "On");
	f_hTemp.SetString(KACR_OFF, "Off");
	f_hTemp.SetString(KACR_DISABLED, "Disabled");
	f_hTemp.SetString(KACR_ERROR, "Error");
	f_hTemp.SetString(KACR_NOREPORT, "There is nothing to report");
	f_hTemp.SetString(KACR_TRANSLATEMOD, "Translations");
	f_hTemp.SetString(KACR_RCONPREVENT, "RCON Crash Prevention");
	f_hTemp.SetString(KACR_NETMOD, "Network");
	f_hTemp.SetString(KACR_UNABLETOCONTACT, "Unable to contact the KACR Master");
	f_hTemp.SetString(KACR_EYEMOD, "Eye Test");
	f_hTemp.SetString(KACR_ANTIWH, "Anti-Wallhack");
	f_hTemp.SetString(KACR_NOSDKHOOK, "Disabled; Unable to find SDKHooks.ext");
	f_hTemp.SetString(KACR_CVARS, "CVars Detection");
	f_hTemp.SetString(KACR_CMDMOD, "Command Protection");
	f_hTemp.SetString(KACR_CMDSPAM, "Command Spam Protection");
	f_hTemp.SetString(KACR_CLIENTMOD, "Client Module");
	f_hTemp.SetString(KACR_CLIENTBALANCE, "Client Team Auto-Balance");
	f_hTemp.SetString(KACR_CLIENTANTIRESPAWN, "Client Anti-Rejoin");
	f_hTemp.SetString(KACR_CLIENTNAMEPROTECT, "Client Name Protection");
	f_hTemp.SetString(KACR_AUTOASSIGNED, "[KACR] You have been Auto-Assigned to a team");
	f_hTemp.SetString(KACR_SAYBLOCK, "[KACR] Your say has been blocked due to a invalid character");
	f_hTemp.SetString(KACR_FORCEDREVAL, "[KACR] Forced revalidation on all connected players");
	f_hTemp.SetString(KACR_CANNOTREVAL, "[KACR] Cannot force revalidation until all player have already been validated");
	
	
	//- French -// Thanks to Vintage > http://kigenac.com/memberlist.php?mode=viewprofile&u=1035
	if (!g_hLanguages.GetValue("fr", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
	{
		// SetFailState("Unable to create Language Hashmap for French"); // We do not want an AC to break, otherwise our Server would be unprotected :O
		KACR_PrintToServer("[Error][KACR] Unable to create Language Hashmap for French");
		KACR_Log("[Error] Unable to create Language Hashmap for French");
	}
	
	f_hTemp.SetString(KACR_LOADED, "Kigen's Anti-Cheat Redux est opérationnel");
	f_hTemp.SetString(KACR_BANNED, "Vous avez été banni pour cheat détecté");
	f_hTemp.SetString(KACR_GBANNED, "Vous avez été banni de tous les serveurs protégés par Kigen's Anti-Cheat Redux (KACR). Voir https://djplaya.github.io/kigen-ac_redux pour plus d'informations");
	f_hTemp.SetString(KACR_VACBANNED, "Ce serveur protégé par Kigen's Anti-Cheat Redux (KACR) n'autorise pas les joueurs bannis par VALVe's Anti-Cheat (VAC)");
	f_hTemp.SetString(KACR_KCMDSPAM, "Vous avez été kické pour spam de commandes");
	f_hTemp.SetString(KACR_ADDCMDUSAGE, "Usage: akcr_addcmd <nom de la commande> <ban (1 or 0)>");
	f_hTemp.SetString(KACR_ADDCMDSUCCESS, "Vous avez correctement ajouté %s à la liste des commandes à surveiller");
	f_hTemp.SetString(KACR_ADDCMDFAILURE, "%s existe déjà dans la liste des commandes à surveiller");
	f_hTemp.SetString(KACR_REMCMDUSAGE, "Usage: kacr_removecmd <nom de la commande>");
	f_hTemp.SetString(KACR_REMCMDSUCCESS, "Vous avez correctement retiré %s de la liste des commandes à surveiller");
	f_hTemp.SetString(KACR_REMCMDFAILURE, "%s n'est pas dans la liste des commandes à surveiller");
	f_hTemp.SetString(KACR_ADDIGNCMDUSAGE, "Usage: kacr_addignorecmd <nom de la commande>");
	f_hTemp.SetString(KACR_ADDIGNCMDSUCCESS, "Vous avez correctement ajouté %s à la liste des commandes à ignorer");
	f_hTemp.SetString(KACR_ADDIGNCMDFAILURE, "%s existe déjà dans la liste des commandes à ignorer");
	f_hTemp.SetString(KACR_REMIGNCMDUSAGE, "Usage: kacr_removeignorecmd <nom de la commande>");
	f_hTemp.SetString(KACR_REMIGNCMDSUCCESS, "Vous avez correctement retiré %s de la liste des commandes à ignorer");
	f_hTemp.SetString(KACR_REMIGNCMDFAILURE, "%s n'est pas dans la liste des commandes à ignorer");
	f_hTemp.SetString(KACR_FAILEDTOREPLY, "Votre client n'a pas répondu à temps à une requête. Veuillez vous reconnecter ou redémarrer votre jeu");
	f_hTemp.SetString(KACR_FAILEDAUTH, "Votre client n'a pas autorisé une requête. Veuillez vous reconnecter ou redémarrer votre jeu");
	f_hTemp.SetString(KACR_CLIENTCORRUPT, "Votre client a été corrompu. Veuillez redémarrer votre jeu avant de vous reconnecter");
	f_hTemp.SetString(KACR_REMOVEPLUGINS, "Veuillez supprimer les plugins tiers de votre client pour rejoindre ce serveur");
	f_hTemp.SetString(KACR_HASPLUGIN, "'%L'<%s> a un plugin activé, renvoie: %s");
	f_hTemp.SetString(KACR_MUTED, "%N a été rendu silencieux par Kigen's Anti-Cheat Redux");
	f_hTemp.SetString(KACR_HASNOTEQUAL, "'%L'<%s> a renvoyé une mauvaise valeur pour %s (la valeur %s, devrait être %s)");
	f_hTemp.SetString(KACR_SHOULDEQUAL, "Votre cvar %s devrait être égale à %s mais est réglée à %s. Veuillez corriger! Merci");
	f_hTemp.SetString(KACR_HASNOTGREATER, "'%L'<%s> a la cvar %s réglée à %s alors qu'elle devrait être supérieure ou égale à %s");
	f_hTemp.SetString(KACR_SHOULDGREATER, "Votre cvar %s devrait être supérieure ou égale à %s mais est réglée à %s. Veuillez corriger! Merci");
	f_hTemp.SetString(KACR_HASNOTLESS, "'%L'<%s> a la cvar %s réglée à %s alors qu'elle devrait être inférieure ou égale à %s");
	f_hTemp.SetString(KACR_SHOULDLESS, "Votre cvar %s devrait être inférieure ou égale à %s mais est réglée à %s. Veuillez corriger! Merci");
	f_hTemp.SetString(KACR_HASNOTBOUND, "'%L'<%s> a la cvar %s réglée à %s walors qu'elle devrait être entre %s et %f");
	f_hTemp.SetString(KACR_SHOULDBOUND, "Votre cvar %s devrait être entre %s et %f mais est réglée à %s. Veuillez corriger! Merci");
	f_hTemp.SetString(KACR_BANIP, "Vous avez été banni par le serveur");
	f_hTemp.SetString(KACR_ADDCVARUSAGE, "Usage: kacr_addcvar <nom de la cvar> <type de comparaison> <action> <value> <valeur2 si encadrement>");
	f_hTemp.SetString(KACR_REMCVARUSAGE, "Usage: kacr_removecvar <nom de la cvar>");
	f_hTemp.SetString(KACR_REMCVARSUCCESS, "La cvar %s a été retirée correctement de la liste de surveillance");
	f_hTemp.SetString(KACR_REMCVARFAILED, "Impossible de trouver la cvar %s dans la liste de surveillance");
	f_hTemp.SetString(KACR_ADDCVARBADNAME, "Le nom de la cvar \"%s\" n'est pas valide et ne peut être utilisé");
	f_hTemp.SetString(KACR_ADDCVARBADCOMP, "Comparaison non reconnue \"%s\", valeurs acceptées: \"equal\", \"greater\", \"less\", \"between\" ou \"strequal\"");
	f_hTemp.SetString(KACR_ADDCVARBADACT, "Action non reconnue \"%s\", valeurs acceptées: \"warn\", \"mute\", \"kick\" or \"ban\"");
	f_hTemp.SetString(KACR_ADDCVARBADBOUND, "La comparaison d'encadrement nécessite deux valeurs pour être active");
	f_hTemp.SetString(KACR_ADDCVAREXISTS, "La cvar %s existe déjà dans la liste de surveillance");
	f_hTemp.SetString(KACR_ADDCVARSUCCESS, "La cvar %s a été correctement ajoutée à la liste de surveillance");
	f_hTemp.SetString(KACR_ADDCVARFAILED, "La cvar %s n'a pu être ajoutée à la liste de surveillance");
	f_hTemp.SetString(KACR_CHANGENAME, "Veuillez changer votre nom! SVP");
	f_hTemp.SetString(KACR_CBANNED, "Vous avez été banni pour une violation d'usage de commande");
	f_hTemp.SetString(KACR_STATUSREPORT, "Rapport de Kigen's Anti-Cheat Redux");
	f_hTemp.SetString(KACR_ON, "On");
	f_hTemp.SetString(KACR_OFF, "Off");
	f_hTemp.SetString(KACR_DISABLED, "Désactivé");
	f_hTemp.SetString(KACR_ERROR, "Erreur");
	f_hTemp.SetString(KACR_NOREPORT, "Il n'y a rien à noter dans le rapport");
	f_hTemp.SetString(KACR_TRANSLATEMOD, "Traductions");
	f_hTemp.SetString(KACR_RCONPREVENT, "Prévention du crash RCON");
	f_hTemp.SetString(KACR_NETMOD, "Network");
	f_hTemp.SetString(KACR_UNABLETOCONTACT, "Impossible de contacter le server maître KACR");
	f_hTemp.SetString(KACR_EYEMOD, "Eye Test");
	f_hTemp.SetString(KACR_ANTIWH, "Anti-Wallhack");
	f_hTemp.SetString(KACR_NOSDKHOOK, "Désactivé; Impossible de trouver SDKHooks.ext");
	f_hTemp.SetString(KACR_CVARS, "Surveillance des CVars");
	f_hTemp.SetString(KACR_CMDMOD, "Protection des Commandes");
	f_hTemp.SetString(KACR_CMDSPAM, "Protection du spam de Commandes");
	f_hTemp.SetString(KACR_CLIENTMOD, "Module Client");
	f_hTemp.SetString(KACR_CLIENTBALANCE, "Client Team Auto-Balance");
	f_hTemp.SetString(KACR_CLIENTANTIRESPAWN, "Client Anti-Rejoindre");
	f_hTemp.SetString(KACR_CLIENTNAMEPROTECT, "Client Protection du Nom");
	f_hTemp.SetString(KACR_AUTOASSIGNED, "[KACR] Vous avez rejoint automatiquement une team");
	f_hTemp.SetString(KACR_SAYBLOCK, "[KACR] Vous ne pouvez plus écrire dû à un caractère non autorisé");
	f_hTemp.SetString(KACR_FORCEDREVAL, "[KACR] Revalidation forcée sur tous les joueurs connectés");
	f_hTemp.SetString(KACR_CANNOTREVAL, "[KACR] Revalidation impossible, tous les joueurs ont déjà été validés");
	
	
	//- Italian -// Thanks to Asterix > http://kigenac.com/memberlist.php?mode=viewprofile&u=116
	if (!g_hLanguages.GetValue("it", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
	{
		// SetFailState("Unable to create Language Hashmap for Italian"); // We do not want an AC to break, otherwise our Server would be unprotected :O
		KACR_PrintToServer("[Error][KACR] Unable to create Language Hashmap for Italian");
		KACR_Log("[Error] Unable to create Language Hashmap for Italian");
	}
	
	f_hTemp.SetString(KACR_LOADED, "L'anticheats Kigen Redux è stato caricato con successo");
	f_hTemp.SetString(KACR_BANNED, "Sei stato bannato per aver utilizzato dei trucchi");
	f_hTemp.SetString(KACR_GBANNED, "Sei bannato da tutti i server protetti dall'anticheats Kigen Redux (KACR). Visita https://djplaya.github.io/kigen-ac_redux per ulteriori informazioni");
	f_hTemp.SetString(KACR_VACBANNED, "I server protetti dall'anticheats Kigen Redux (KACR) non permettono l'ingresso ai giocatori bannati dall'anticheats della VALVE (VAC)");
	f_hTemp.SetString(KACR_KCMDSPAM, "Se stato kikkato per spamming");
	f_hTemp.SetString(KACR_ADDCMDUSAGE, "Utilizzo: kacr_addcmd <nome del comando> <ban (1 o 0)>");
	f_hTemp.SetString(KACR_ADDCMDSUCCESS, "Sei stato aggiunto %s alla lista dei blocchi comandi");
	f_hTemp.SetString(KACR_ADDCMDFAILURE, "%s già esistente nella lista dei blocchi comandi");
	f_hTemp.SetString(KACR_REMCMDUSAGE, "Utilizzo: kacr_removecmd <nome del comando>");
	f_hTemp.SetString(KACR_REMCMDSUCCESS, "Sei stato rimosso %s dalla lista dei comandi");
	f_hTemp.SetString(KACR_REMCMDFAILURE, "%s non è nella lista dei blocchi comandi");
	f_hTemp.SetString(KACR_ADDIGNCMDUSAGE, "Utilizzo: kacr_addignorecmd <nome del comando>");
	f_hTemp.SetString(KACR_ADDIGNCMDSUCCESS, "Seistato aggiunto %s alla lista ignora");
	f_hTemp.SetString(KACR_ADDIGNCMDFAILURE, "%s esiste già nella lista ignora");
	f_hTemp.SetString(KACR_REMIGNCMDUSAGE, "Utilizzo: kacr_removeignorecmd <nome del comando>");
	f_hTemp.SetString(KACR_REMIGNCMDSUCCESS, "Sei stato rimosso %s dalla lista ignora");
	f_hTemp.SetString(KACR_REMIGNCMDFAILURE, "%s non è trai comandi della lista ignora");
	f_hTemp.SetString(KACR_FAILEDTOREPLY, "Il giocatore ha fallito nel rispondere in tempo a delle query. Per favore riconnetti o restarta il tuo gioco");
	f_hTemp.SetString(KACR_FAILEDAUTH, "Il giocatore non è riuscito ad ottenere l'autorizzazione in tempo.Per favore riconnetti o restarta il tuo gioco");
	f_hTemp.SetString(KACR_CLIENTCORRUPT, "Il giocatore sta per avere problemi di integrità. Per favore riconnetti o restarta il tuo gioco");
	f_hTemp.SetString(KACR_REMOVEPLUGINS, "Per favore rimuovi tutti i terzi programmi dal tuo pc prima di collegarti nuovamente a questo server");
	f_hTemp.SetString(KACR_HASPLUGIN, "'%L'<%s> ha un programma funzionante, risposta %s");
	f_hTemp.SetString(KACR_MUTED, "%N è stato mutato dall'anticheats Kigen Redux");
	f_hTemp.SetString(KACR_HASNOTEQUAL, "'%L'<%s> non corretta risposta del valore %s (valore %s, deve essere %s)");
	f_hTemp.SetString(KACR_SHOULDEQUAL, "Il tuo valore %s deve essere uguale a %s invece è %s. Per favore modificalo prima di ricollegarti a questo server");
	f_hTemp.SetString(KACR_HASNOTGREATER, "'%L'<%s> ha il valore %s è %s quando deve essere maggiore o uguale a %s");
	f_hTemp.SetString(KACR_SHOULDGREATER, "Il tuo valore %s deve essere maggiore o uguale a %s invece è %s. Per favore modificalo prima di ricollegarti");
	f_hTemp.SetString(KACR_HASNOTLESS, "'%L'<%s> ha il valore %s è %s quando deve essere inferiore o uguale a %s");
	f_hTemp.SetString(KACR_SHOULDLESS, "Il tuo valore %s deve essere inferiore o uguale a %s invece è %s. Per favore modificalo prima di ricollegarti");
	f_hTemp.SetString(KACR_HASNOTBOUND, "'%L'<%s> ha il valore %s a %s quando deve essere tra %s e %f");
	f_hTemp.SetString(KACR_SHOULDBOUND, "Il tuo valore %s deve essere tra %s e %f invece è %s. Per favore modificalo prima di ricollegarti");
	f_hTemp.SetString(KACR_BANIP, "Sei stato bannato dal server");
	f_hTemp.SetString(KACR_ADDCVARUSAGE, "Utilizzo: kacr_addcvar <nome del cvar> <tipo del confronto> <azione> <valore> <valore2 se bindato>");
	f_hTemp.SetString(KACR_REMCVARUSAGE, "Usage: kacr_removecvar <nome del cvar>");
	f_hTemp.SetString(KACR_REMCVARSUCCESS, "Il cvar %s è stato rmisso dalla lista di controllo");
	f_hTemp.SetString(KACR_REMCVARFAILED, "Impossibile trovare il cvar %s nella lista di controllo");
	f_hTemp.SetString(KACR_ADDCVARBADNAME, "Il nome di questo cvar \"%s\" non è valido e non può essere utilizzato");
	f_hTemp.SetString(KACR_ADDCVARBADCOMP, "Confronto non riconosciuto \"%s\", valore accettabile: \"uguale\", \"maggiore\", \"inferiore\", \"tra\" o \"strequal\"");
	f_hTemp.SetString(KACR_ADDCVARBADACT, "Azione non riconosciuta \"%s\", valore accettabile: \"avvertimento\", \"mutare\", \"kick\" o \"bannare\"");
	f_hTemp.SetString(KACR_ADDCVARBADBOUND, "Il confronto bindato necessita di due valori da confrontare");
	f_hTemp.SetString(KACR_ADDCVAREXISTS, "Il cvar %s esiste già nella lista di controllo");
	f_hTemp.SetString(KACR_ADDCVARSUCCESS, "Il cvar %s è stato aggiunto alla lista di controllo");
	f_hTemp.SetString(KACR_ADDCVARFAILED, "Non si è riusciti ad aggiungere il cvar %s alla lista di controllo");
	f_hTemp.SetString(KACR_CHANGENAME, "Per favore cambia il tuo nome");
	f_hTemp.SetString(KACR_CBANNED, "Sei stato bannato per utilizzo proibito dei comandi");
	f_hTemp.SetString(KACR_STATUSREPORT, "Kigen's Anti-Cheat Redux Status Report");
	f_hTemp.SetString(KACR_ON, "On");
	f_hTemp.SetString(KACR_OFF, "Off");
	f_hTemp.SetString(KACR_DISABLED, "Disabilitato");
	f_hTemp.SetString(KACR_ERROR, "Errore");
	f_hTemp.SetString(KACR_NOREPORT, "Non c'è nulla da riportare");
	f_hTemp.SetString(KACR_TRANSLATEMOD, "Traduzioni");
	f_hTemp.SetString(KACR_RCONPREVENT, "RCON Prevenzione Crash");
	f_hTemp.SetString(KACR_NETMOD, "Rete");
	f_hTemp.SetString(KACR_UNABLETOCONTACT, "Impossibile contattare il KACR Master");
	f_hTemp.SetString(KACR_EYEMOD, "Test visivo");
	f_hTemp.SetString(KACR_ANTIWH, "Anti-Wallhack");
	f_hTemp.SetString(KACR_NOSDKHOOK, "Disabilitato; Impossibile trovare SDKHooks.ext");
	f_hTemp.SetString(KACR_CVARS, "CVars Controllo");
	f_hTemp.SetString(KACR_CMDMOD, "Command Protezione");
	f_hTemp.SetString(KACR_CMDSPAM, "Protezione Comando Spam");
	f_hTemp.SetString(KACR_CLIENTMOD, "Modulo Giocatore");
	f_hTemp.SetString(KACR_CLIENTBALANCE, "Auto-Balance team giocatori");
	f_hTemp.SetString(KACR_CLIENTANTIRESPAWN, "Giocatori Anti-Rejoin");
	f_hTemp.SetString(KACR_CLIENTNAMEPROTECT, "Protezione nomi giocatori");
	f_hTemp.SetString(KACR_AUTOASSIGNED, "[KACR] Sei stato assegnato forzatamente ad un Team");
	f_hTemp.SetString(KACR_SAYBLOCK, "[KACR] Il tuo testo è stato bloccato a causa di alcuni caratteri non validi");
	f_hTemp.SetString(KACR_FORCEDREVAL, "[KACR] Convalida forzata di tutti i giocatori connessi");
	f_hTemp.SetString(KACR_CANNOTREVAL, "[KACR] Non si può forzare la validazione dei giocatori finchè questi non siano stati tutti validati");
	
	
	//- German -// Done by Playa
	if (!g_hLanguages.GetValue("de", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
	{
		// SetFailState("Unable to create Language Hashmap for German"); // We do not want an AC to break, otherwise our Server would be unprotected :O
		KACR_PrintToServer("[Error][KACR] Unable to create Language Hashmap for German");
		KACR_Log("[Error] Unable to create Language Hashmap for German");
	}
	
	// Load the phrases into Translations.
	f_hTemp.SetString(KACR_LOADED, "Kigen's Anti-Cheat Redux erfolgreich geladen");
	f_hTemp.SetString(KACR_BANNED, "Du wurdest wegen aufgrund von cheating Versuchen verbannt");
	f_hTemp.SetString(KACR_GBANNED, "Du wurdest von allen Kigen's Anti-Cheat Redux (KACR) geschützten Servern verbannt. Für weitere Infos, besuche: https://djplaya.github.io/kigen-ac_redux");
	f_hTemp.SetString(KACR_VACBANNED, "Dieser Server ist durch Kigen's Anti-Cheat Redux (KACR) geschützt und erlaubt keine VALVe Anti-Cheat (VAC) gebannte Spieler");
	f_hTemp.SetString(KACR_KCMDSPAM, "Du wurdest aufgrund von Kommando spamming gekickt");
	f_hTemp.SetString(KACR_ADDCMDUSAGE, "Anwendung: kacr_addcmd <Kommando> <ban (1 or 0)>");
	f_hTemp.SetString(KACR_ADDCMDSUCCESS, "Du hast erfolgreich %s zur Kommando Blacklist hinzugefügt");
	f_hTemp.SetString(KACR_ADDCMDFAILURE, "%s befindet sich bereits in der Kommando Blacklist");
	f_hTemp.SetString(KACR_REMCMDUSAGE, "Anwendung: kacr_removecmd <Kommando>");
	f_hTemp.SetString(KACR_REMCMDSUCCESS, "Du hast erfolgreich %s von der Kommando Blacklist entfernt");
	f_hTemp.SetString(KACR_REMCMDFAILURE, "%s ist nicht in der Kommando Blacklist");
	f_hTemp.SetString(KACR_ADDIGNCMDUSAGE, "Anwendung: kacr_addignorecmd <Kommando>");
	f_hTemp.SetString(KACR_ADDIGNCMDSUCCESS, "Du hast erfolgreich %s zur Spam Whitelist hinzugefügt");
	f_hTemp.SetString(KACR_ADDIGNCMDFAILURE, "%s befindet sich bereits in der Spam Whitelist");
	f_hTemp.SetString(KACR_REMIGNCMDUSAGE, "Anwendung: kacr_removeignorecmd <Kommando>");
	f_hTemp.SetString(KACR_REMIGNCMDSUCCESS, "Du hast erfolgreich %s von der Spam Whitelist entfernt");
	f_hTemp.SetString(KACR_REMIGNCMDFAILURE, "%s ist nicht in der Spam Whitelist");
	f_hTemp.SetString(KACR_FAILEDTOREPLY, "Dein Spiel hat eine Anfrag nicht rechtzeitig bearbeitet. Bitte reconnecte oder starte dein Spiel neu");
	f_hTemp.SetString(KACR_FAILEDAUTH, "Dein Spiel hat sich nicht rechtzeitig am Server angemeldet. Bitte reconnecte oder starte dein Spiel neu");
	f_hTemp.SetString(KACR_CLIENTCORRUPT, "Dein Spiel is möglicherweise beschädigt oder falsch eingestellt. Bitte starte dein Spiel neu before du dich wieder verbindest");
	f_hTemp.SetString(KACR_REMOVEPLUGINS, "Bitte entferne sämtliche Plugins von deinem Client bevor du dich erneut verbindest");
	f_hTemp.SetString(KACR_HASPLUGIN, "'%L'<%s> hat ein Plugin am laufen, Rückgabe %s");
	f_hTemp.SetString(KACR_MUTED, "%N wurde stumm geschaltet durch Kigen's Anti-Cheat Redux");
	f_hTemp.SetString(KACR_HASNOTEQUAL, "'%L'<%s> hat ConVar %s auf einem falschen Wert (Wert %s, sollte %s sein)");
	f_hTemp.SetString(KACR_SHOULDEQUAL, "Deine ConVar %s sollte %s sein, aber sie ist auf %s gesetzt. Bitte korrigiere das vor dem reconnecten");
	f_hTemp.SetString(KACR_HASNOTGREATER, "'%L'<%s> hat ConVar %s auf %s, der Wert sollte allerdings größer oder gleich %s sein");
	f_hTemp.SetString(KACR_SHOULDGREATER, "Deine ConVar %s sollte größer oder gleich %s sein, aber sie ist auf %s gesetzt. Bitte korrigiere das vor dem reconnecten");
	f_hTemp.SetString(KACR_HASNOTLESS, "'%L'<%s> hat ConVar %s auf %s, der Wert sollte allerdings kleiner oder gleich %s sein");
	f_hTemp.SetString(KACR_SHOULDLESS, "Deine ConVar %s sollte kleiner oder gleich %s sein, aber sie ist auf %s gesetzt. Bitte korrigiere das vor dem reconnecten");
	f_hTemp.SetString(KACR_HASNOTBOUND, "'%L'<%s> hat ConVar %s auf %s, der Wert sollte allerdings zwischen %s und %f liegen");
	f_hTemp.SetString(KACR_SHOULDBOUND, "Deine ConVar %s sollte zwischen %s und %f eingestellt sein, aber sie ist auf %s gesetzt. Bitte korrigiere das vor dem reconnecten");
	f_hTemp.SetString(KACR_BANIP, "Du wurdest vom Server gebannt");
	f_hTemp.SetString(KACR_ADDCVARUSAGE, "Anwendung: kacr_addcvar <CVar Name> <Vergleichstyp> <Aktionstyp> <Startwert> <Endwert when nötig>");
	f_hTemp.SetString(KACR_REMCVARUSAGE, "Anwendung: kacr_removecvar <CVar Name>");
	f_hTemp.SetString(KACR_REMCVARSUCCESS, "ConVar %s wurde von der Checkliste entfernt");
	f_hTemp.SetString(KACR_REMCVARFAILED, "ConVar %s konnte nicht in der Checkliste gefunden werden");
	f_hTemp.SetString(KACR_ADDCVARBADNAME, "Der ConVar Name \"%s\" ist ungültig un kann nicht verwendet werden");
	f_hTemp.SetString(KACR_ADDCVARBADCOMP, "Ungültiger Vergleichstyp \"%s\", gültige Werte sind: \"equal\", \"greater\", \"less\", \"between\" oder \"strequal\"");
	f_hTemp.SetString(KACR_ADDCVARBADACT, "Ungültiger Aktionstyp \"%s\", gültige Werte sind: \"warn\", \"mute\", \"kick\" oder \"ban\"");
	f_hTemp.SetString(KACR_ADDCVARBADBOUND, "Dieser Vergleichstyp braucht einen Start und Endwert");
	f_hTemp.SetString(KACR_ADDCVAREXISTS, "Die ConVar %s gibt es bereits in der Checkliste");
	f_hTemp.SetString(KACR_ADDCVARSUCCESS, "Convar %s wurde der Checkliste hinzugefügt");
	f_hTemp.SetString(KACR_ADDCVARFAILED, "ConVar %s konnte nicht der Checkliste hinzugefügt werden");
	f_hTemp.SetString(KACR_CHANGENAME, "Bitte ändere deinen Namen");
	f_hTemp.SetString(KACR_CBANNED, "Du wurdest wegen Kommando misbrauchs verbannt");
	f_hTemp.SetString(KACR_STATUSREPORT, "Kigen's Anti-Cheat Redux Status Bericht");
	f_hTemp.SetString(KACR_ON, "An");
	f_hTemp.SetString(KACR_OFF, "Aus");
	f_hTemp.SetString(KACR_DISABLED, "Deaktiviert");
	f_hTemp.SetString(KACR_ERROR, "Fehler");
	f_hTemp.SetString(KACR_NOREPORT, "Es gibt nichts zu berichten");
	f_hTemp.SetString(KACR_TRANSLATEMOD, "Übersetzungen");
	f_hTemp.SetString(KACR_RCONPREVENT, "RCON Crash Prevention");
	f_hTemp.SetString(KACR_NETMOD, "Netzwerk");
	f_hTemp.SetString(KACR_UNABLETOCONTACT, "Kann KACR Master Server nicht erreichen");
	f_hTemp.SetString(KACR_EYEMOD, "Sicht Test");
	f_hTemp.SetString(KACR_ANTIWH, "Anti-Wallhack");
	f_hTemp.SetString(KACR_NOSDKHOOK, "Deaktiviert; Kann Erweiterung SDKHooks.ext nicht finden");
	f_hTemp.SetString(KACR_CVARS, "CVar Überprüfung");
	f_hTemp.SetString(KACR_CMDMOD, "Kommando Schutz");
	f_hTemp.SetString(KACR_CMDSPAM, "Kommando Spam Schutz");
	f_hTemp.SetString(KACR_CLIENTMOD, "Klient Modul");
	f_hTemp.SetString(KACR_CLIENTBALANCE, "Klient Team Auto-Balance");
	f_hTemp.SetString(KACR_CLIENTANTIRESPAWN, "Anti-Rejoin Schutz");
	f_hTemp.SetString(KACR_CLIENTNAMEPROTECT, "Klient Namen Schutz");
	f_hTemp.SetString(KACR_AUTOASSIGNED, "[KACR] Du wurdest automatisch einem Team zugewiesen");
	f_hTemp.SetString(KACR_SAYBLOCK, "[KACR] Deine Nachricht wurde blockiert, da sie ungültige Zeichen enthält");
	f_hTemp.SetString(KACR_FORCEDREVAL, "[KACR] Erzwungene Überprüfung aller verbundenen Spieler");
	f_hTemp.SetString(KACR_CANNOTREVAL, "[KACR] Eine Überprüfung kann nicht gestartet werden bis alle Spieler fertig geprüft wurden");
	
	
	//- Hebrew -// Thanks to Shazero Sicario > Discord: WildGamer.net#4916
	if (!g_hLanguages.GetValue("he", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
	{
		// SetFailState("Unable to create Language Hashmap for Hebrew"); // We do not want an AC to break, otherwise our Server would be unprotected :O
		KACR_PrintToServer("[Error][KACR] Unable to create Language Hashmap for Hebrew");
		KACR_Log("[Error] Unable to create Language Hashmap for Hebrew");
	}
	
	// Load the phrases into Translations.
	f_hTemp.SetString(KACR_LOADED, "האנטי ציט של קיגאן נטען בהצלחה");
	f_hTemp.SetString(KACR_BANNED, "הורחקת בגין שימוש בתוכנות צד-3");
	f_hTemp.SetString(KACR_GBANNED, "https://djplaya.github.io/kigen-ac_redux: הורקת מכל השרתים המשתמשים באנטי ציט של קיגאן לעוד מידע כנסו ללניק");
	f_hTemp.SetString(KACR_VACBANNED, "(VAC)האני ציט של קיגאן לא מאפשר לVALVE לתת הרחקה");
	f_hTemp.SetString(KACR_KCMDSPAM, "קיבלת קיק על הספאמת פקודה באופן חוזר");
	f_hTemp.SetString(KACR_ADDCMDUSAGE, "שימוש: kacr_addcmd <command name> <ban (1 or 0)>");
	f_hTemp.SetString(KACR_ADDCMDSUCCESS, "הוספת בהצלחה %s לרשימת הפקודות");
	f_hTemp.SetString(KACR_ADDCMDFAILURE, "%s כבר קיים ברשימת הפקודות");
	f_hTemp.SetString(KACR_REMCMDUSAGE, "שימוש: kacr_removecmd <command name>");
	f_hTemp.SetString(KACR_REMCMDSUCCESS, "הסרת בהצלחה את %s מרשימת הפקודות");
	f_hTemp.SetString(KACR_REMCMDFAILURE, "%s אינו נמצא ברשימת הפקודות");
	f_hTemp.SetString(KACR_ADDIGNCMDUSAGE, "שימוש: kacr_addignorecmd <command name>");
	f_hTemp.SetString(KACR_ADDIGNCMDSUCCESS, "הוספת בהצלחה את %s לרשימת הסניון");
	f_hTemp.SetString(KACR_ADDIGNCMDFAILURE, "%s כבר קיים ברשימת הסניון");
	f_hTemp.SetString(KACR_REMIGNCMDUSAGE, "שימוש: kacr_removeignorecmd <command name>");
	f_hTemp.SetString(KACR_REMIGNCMDSUCCESS, "הסרת בהצלחה את %s מרשימת הסינון");
	f_hTemp.SetString(KACR_REMIGNCMDFAILURE, "%s לא נמצא ברשימת הסינון");
	f_hTemp.SetString(KACR_FAILEDTOREPLY, "המשתמש שלך אינו נענה למשחק אנא התחבר מחדש או הפעל מחדש את המשחק");
	f_hTemp.SetString(KACR_FAILEDAUTH, "המשתמש שלך כשל להתחבר .אנא התחבר מחדש או הפעל מחדש את המשחק");
	f_hTemp.SetString(KACR_CLIENTCORRUPT, "המשתמש שלך נפגם או שהוא מוגדר בצורה שגויה. הפעל מחדש את המשחק לפני שתתחבר מחדש");
	f_hTemp.SetString(KACR_REMOVEPLUGINS, "אנא תמחק תוכנות צד-3 לפני התחברות לשרת, רק אחרי המחיקה תוכל להתחבר לשרת");
	f_hTemp.SetString(KACR_HASPLUGIN, "'%L'<%s> משתמש בתוכנת פלאגין, חוזר %s");
	f_hTemp.SetString(KACR_MUTED, "%N הושתק על ידי האנטי ציט");
	f_hTemp.SetString(KACR_HASNOTEQUAL, "'%L'<%s> החזיר ערך שלילי %s (הערך %s, אמור להיות %s)");
	f_hTemp.SetString(KACR_SHOULDEQUAL, "הקונבאר שלך %s אמור להיות %s אבל הוא שונה ל %s אנא תקן זאת לפני הצטרפות לשרת");
	f_hTemp.SetString(KACR_HASNOTGREATER, "'%L'<%s> הקונבאר של %s שונה ל %s כשהוא אמור להיות %s");
	f_hTemp.SetString(KACR_SHOULDGREATER, "הקונבאר שלך %s אמור להיות גדול או שווה ל %s אבל הוא שונה ל %s. אנא תקן זאת לפני הצטרפות לשרת");
	f_hTemp.SetString(KACR_HASNOTLESS, "'%L'<%s> הקונבאר של %s שונה ל %s כאשר הוא אמור להיות שווה ל %s");
	f_hTemp.SetString(KACR_SHOULDLESS, "הקונבאר שלך %אמור להיות שווה או נמוך מ %s אבל הוא שונה ל %s. אנא תקן זאת לפני הצטרפות לשרת");
	f_hTemp.SetString(KACR_HASNOTBOUND, "'%L'<%s> הקונבאר %s שונה ל  %s כאשר זה צריך להיות %s ו %f");
	f_hTemp.SetString(KACR_SHOULDBOUND, "הקונבאר שלך %s אמור להיות בין  %s ל %f אבל הוא שונה ל %s. אנא תקן זאת לפני הצטרפות לשרת");
	f_hTemp.SetString(KACR_BANIP, "הורחקת מן השרת");
	f_hTemp.SetString(KACR_ADDCVARUSAGE, "שימוש: kacr_addcvar <cvar name> <comparison type> <action> <value> <value2 if bound>");
	f_hTemp.SetString(KACR_REMCVARUSAGE, "שימוש: kacr_removecvar <cvar name>");
	f_hTemp.SetString(KACR_REMCVARSUCCESS, "קונבאר %s הוסר בהצלחה מרשימת הבדיקה");
	f_hTemp.SetString(KACR_REMCVARFAILED, "לא ניצן למצוא את הקונבאר %s ברשימת הבדיקה");
	f_hTemp.SetString(KACR_ADDCVARBADNAME, "שמו של הקונבאר \"%s\" אינו חוקי ולא ניתן לשימוש");
	f_hTemp.SetString(KACR_ADDCVARBADCOMP, "סוג השוואה לא מזוהה \"%s\", ערכים מקובלים: \"equal\", \"greater\", \"less\", \"between\" או \"strequal\"");
	f_hTemp.SetString(KACR_ADDCVARBADACT, "סוג פעולה לא מזוהה \"%s\", ערכים מקובלים: \"warn\", \"mute\", \"kick\" או \"ban\"");
	f_hTemp.SetString(KACR_ADDCVARBADBOUND, "סגנון השוואת גבולות זקוק ל2 ערכים לביצוע הפעולה");
	f_hTemp.SetString(KACR_ADDCVAREXISTS, "הקונבאר  %s כבר קיים ברשימה");
	f_hTemp.SetString(KACR_ADDCVARSUCCESS, "הקונבאר הוסף בהצלחה %s לרשימת הבדיקה");
	f_hTemp.SetString(KACR_ADDCVARFAILED, "נכשל ניסון צירוף הקונבאר %s לרשימת הבדיקה");
	f_hTemp.SetString(KACR_CHANGENAME, "אנא שנה את שם המשתמש שלך");
	f_hTemp.SetString(KACR_CBANNED, "הורחקת על הפרת שימוש בפקודה");
	f_hTemp.SetString(KACR_STATUSREPORT, "דוח מצב של האנטי ציט");
	f_hTemp.SetString(KACR_ON, "פועל");
	f_hTemp.SetString(KACR_OFF, "כבוי");
	f_hTemp.SetString(KACR_DISABLED, "מושבת");
	f_hTemp.SetString(KACR_ERROR, "שגיאה");
	f_hTemp.SetString(KACR_NOREPORT, "איו על מה לדווח");
	f_hTemp.SetString(KACR_TRANSLATEMOD, "תרגומים");
	f_hTemp.SetString(KACR_RCONPREVENT, "RCON מניעת התרסקות");
	f_hTemp.SetString(KACR_NETMOD, "רשת");
	f_hTemp.SetString(KACR_UNABLETOCONTACT, "לא היה ניתן לתקשר עם KACR Master");
	f_hTemp.SetString(KACR_EYEMOD, "בדיקת עיניים");
	f_hTemp.SetString(KACR_ANTIWH, "אנטי-וולהאק");
	f_hTemp.SetString(KACR_NOSDKHOOK, "הושבת; לא ניתן היה למצוא את ה SDKHooks.ext");
	f_hTemp.SetString(KACR_CVARS, "CVars איתור");
	f_hTemp.SetString(KACR_CMDMOD, "הגנת פקודות");
	f_hTemp.SetString(KACR_CMDSPAM, "הגנת על פקודות ספאם");
	f_hTemp.SetString(KACR_CLIENTMOD, "מודל משתמש");
	f_hTemp.SetString(KACR_CLIENTBALANCE, "מאזן אוטומטי של הקבוצות");
	f_hTemp.SetString(KACR_CLIENTANTIRESPAWN, "ניגוד הצטרפויות חוזרות");
	f_hTemp.SetString(KACR_CLIENTNAMEPROTECT, "הגנה על השם ");
	f_hTemp.SetString(KACR_AUTOASSIGNED, "[KACR] הוקצתה אוטומטית לצוות");
	f_hTemp.SetString(KACR_SAYBLOCK, "[KACR] הסיבה שלך נחסמה בשל תו לא חוקי");
	f_hTemp.SetString(KACR_FORCEDREVAL, "[KACR] חידוש אימות בכפייה על כל השחקנים המחוברים");
	f_hTemp.SetString(KACR_CANNOTREVAL, "[KACR] א ניתן לאלץ את ההתאמה עד שכל שחקן כבר אומת");
} 