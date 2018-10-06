/*
    Kigen's Anti-Cheat Translations Module
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

#define TRANSLATIONS

// Defined Translations
#define KAC_LOADED "KAC_LOADED"
#define KAC_BANNED "KAC_BANNED"
#define KAC_GBANNED "KAC_GBANNED"
#define KAC_VACBANNED "KAC_VACBANNED"
#define KAC_KCMDSPAM "KAC_KCMDSPAM"
#define KAC_ADDCMDUSAGE "KAC_ADDCMDUSAGE"
#define KAC_ADDCMDSUCCESS "KAC_ADDCMDSUCCESS"
#define KAC_ADDCMDFAILURE "KAC_ADDCMDFAILURE"
#define KAC_REMCMDUSAGE "KAC_REMCMDUSAGE"
#define KAC_REMCMDSUCCESS "KAC_REMCMDSUCCESS"
#define KAC_REMCMDFAILURE "KAC_REMCMDFAILURE"
#define KAC_ADDIGNCMDUSAGE "KAC_ADDIGNCMDUSAGE"
#define KAC_ADDIGNCMDSUCCESS "KAC_ADDIGNCMDSUCCESS"
#define KAC_ADDIGNCMDFAILURE "KAC_ADDIGNCMDFAILURE"
#define KAC_REMIGNCMDUSAGE "KAC_REMIGNCMDUSAGE"
#define KAC_REMIGNCMDSUCCESS "KAC_REMIGNCMDSUCCESS"
#define KAC_REMIGNCMDFAILURE "KAC_REMIGNCMDFAILURE"
#define KAC_FAILEDTOREPLY "KAC_FAILEDTOREPLY"
#define KAC_FAILEDAUTH "KAC_FAILEDAUTH"
#define KAC_CLIENTCORRUPT "KAC_CLIENTCORRUPT"
#define KAC_REMOVEPLUGINS "KAC_REMOVEPLUGINS"
#define KAC_HASPLUGIN "KAC_HASPLUGIN"
#define KAC_MUTED "KAC_MUTED"
#define KAC_HASNOTEQUAL "KAC_HASNOTEQUAL"
#define KAC_SHOULDEQUAL "KAC_SHOULDEQUAL"
#define KAC_HASNOTGREATER "KAC_HASNOTGREATER"
#define KAC_SHOULDGREATER "KAC_SHOULDGREATER"
#define KAC_HASNOTLESS "KAC_HASNOTLESS"
#define KAC_SHOULDLESS "KAC_SHOULDLESS"
#define KAC_HASNOTBOUND "KAC_HASNOTBOUND"
#define KAC_SHOULDBOUND "KAC_SHOULDBOUND"
#define KAC_BANIP "KAC_BANIP"
#define KAC_ADDCVARUSAGE "KAC_ADDCVARUSAGE"
#define KAC_REMCVARUSAGE "KAC_REMCVARUSAGE"
#define KAC_REMCVARSUCCESS "KAC_REMCVARSUCCESS"
#define KAC_REMCVARFAILED "KAC_REMCVARFAILED"
#define KAC_ADDCVARBADNAME "KAC_ADDCVARBADNAME"
#define KAC_ADDCVARBADCOMP "KAC_ADDCVARBADCOMP"
#define KAC_ADDCVARBADACT "KAC_ADDCVARBADACT"
#define KAC_ADDCVARBADBOUND "KAC_ADDCVARBADBOUND"
#define KAC_ADDCVAREXISTS "KAC_ADDCVAREXISTS"
#define KAC_ADDCVARSUCCESS "KAC_ADDCVARSUCCESS"
#define KAC_ADDCVARFAILED "KAC_ADDCVARFAILED"
#define KAC_CHANGENAME "KAC_CHANGENAME"
#define KAC_CBANNED "KAC_CBANNED"
#define KAC_STATUSREPORT "KAC_STATUSREPORT"
#define KAC_ON "KAC_ON"
#define KAC_OFF "KAC_OFF"
#define KAC_DISABLED "KAC_DISABLED"
#define KAC_ERROR "KAC_ERROR"
#define KAC_NOREPORT "KAC_NOREPORT"
#define KAC_TRANSLATEMOD "KAC_TRANSLATEMOD"
#define KAC_RCONPREVENT "KAC_RCONPREVENT"
#define KAC_NETMOD "KAC_NETMOD"
#define KAC_UNABLETOCONTACT "KAC_UNABLETOCONTACT"
#define KAC_EYEMOD "KAC_EYEMOD"
#define KAC_ANTIWH "KAC_ANTIWH"
#define KAC_NOSDKHOOK "KAC_NOSDKHOOK"
#define KAC_CVARS "KAC_CVARS"
#define KAC_CMDMOD "KAC_CMDMOD"
#define KAC_CMDSPAM "KAC_CMDSPAM"
#define KAC_CLIENTMOD "KAC_CLIENTMOD"
#define KAC_CLIENTBALANCE "KAC_CLIENTBALANCE"
#define KAC_CLIENTANTIRESPAWN "KAC_CLIENTANTIRESPAWN"
#define KAC_CLIENTNAMEPROTECT "KAC_CLIENTNAMEPROTECT"
#define KAC_AUTOASSIGNED "KAC_AUTOASSIGNED"
#define KAC_SAYBLOCK "KAC_SAYBLOCK"
#define KAC_FORCEDREVAL "KAC_FORCEDREVAL"
#define KAC_CANNOTREVAL "KAC_CANNOTREVAL"

new Handle:g_hLanguages = INVALID_HANDLE;

Trans_OnPluginStart()
{
	new Handle:f_hTemp = INVALID_HANDLE;
	g_hLanguages = CreateTrie();
	
	// Load languages into the adt_trie.
	SetTrieValue(g_hLanguages, "en", any:CreateTrie());
	SetTrieValue(g_hLanguages, "fr", any:CreateTrie());
	SetTrieValue(g_hLanguages, "it", any:CreateTrie());
	
	//- English -//
	if (!GetTrieValue(g_hLanguages, "en", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
		SetFailState("Unable to create language tree for English");
	
	// Load the phrases into Translations.
	SetTrieString(f_hTemp, KAC_LOADED, "Kigen's Anti-Cheat has been loaded successfully.");
	SetTrieString(f_hTemp, KAC_BANNED, "You have been banned for a cheating infraction");
	SetTrieString(f_hTemp, KAC_GBANNED, "You are banned from all Kigen's Anti-Cheat (KAC) protected servers.  See http://www.kigenac.com/ for more information");
	SetTrieString(f_hTemp, KAC_VACBANNED, "This Kigen's Anti-Cheat (KAC) protected server does not allow VALVe's Anti-Cheat (VAC) banned players");
	SetTrieString(f_hTemp, KAC_KCMDSPAM, "You have been kicked for command spamming");
	SetTrieString(f_hTemp, KAC_ADDCMDUSAGE, "Usage: kac_addcmd <command name> <ban (1 or 0)>");
	SetTrieString(f_hTemp, KAC_ADDCMDSUCCESS, "You have successfully added %s to the command block list.");
	SetTrieString(f_hTemp, KAC_ADDCMDFAILURE, "%s already exists in the command block list.");
	SetTrieString(f_hTemp, KAC_REMCMDUSAGE, "Usage: kac_removecmd <command name>");
	SetTrieString(f_hTemp, KAC_REMCMDSUCCESS, "You have successfully removed %s from the command block list.");
	SetTrieString(f_hTemp, KAC_REMCMDFAILURE, "%s is not in the command block list.");
	SetTrieString(f_hTemp, KAC_ADDIGNCMDUSAGE, "Usage: kac_addignorecmd <command name>");
	SetTrieString(f_hTemp, KAC_ADDIGNCMDSUCCESS, "You have successfully added %s to the command ignore list.");
	SetTrieString(f_hTemp, KAC_ADDIGNCMDFAILURE, "%s already exists in the command ignore list.");
	SetTrieString(f_hTemp, KAC_REMIGNCMDUSAGE, "Usage: kac_removeignorecmd <command name>");
	SetTrieString(f_hTemp, KAC_REMIGNCMDSUCCESS, "You have successfully removed %s from the command ignore list.");
	SetTrieString(f_hTemp, KAC_REMIGNCMDFAILURE, "%s is not in the command ignore list.");
	SetTrieString(f_hTemp, KAC_FAILEDTOREPLY, "Your client has failed to reply to a query in time.  Please reconnect or restart your game");
	SetTrieString(f_hTemp, KAC_FAILEDAUTH, "Your client has failed to authorize in time.  Please reconnect or restart your game");
	SetTrieString(f_hTemp, KAC_CLIENTCORRUPT, "Your client has become corrupted.  Please restart your game before reconnecting");
	SetTrieString(f_hTemp, KAC_REMOVEPLUGINS, "Please remove any third party plugins from your client before joining this server again");
	SetTrieString(f_hTemp, KAC_HASPLUGIN, "%N (%s) has a plugin running, returned %s.");
	SetTrieString(f_hTemp, KAC_MUTED, "%N has been muted by Kigen's Anti-Cheat.");
	SetTrieString(f_hTemp, KAC_HASNOTEQUAL, "%N (%s) returned a bad value on %s (value %s, should be %s).");
	SetTrieString(f_hTemp, KAC_SHOULDEQUAL, "Your convar %s should equal %s but it was set to %s.  Please correct this before rejoining");
	SetTrieString(f_hTemp, KAC_HASNOTGREATER, "%N (%s) has convar %s set to %s when it should be greater than or equal to %s.");
	SetTrieString(f_hTemp, KAC_SHOULDGREATER, "Your convar %s should be greater than or equal to %s but was set to %s.  Please correct this before rejoining");
	SetTrieString(f_hTemp, KAC_HASNOTLESS, "%N (%s) has convar %s set to %s when it should be less than or equal to %s.");
	SetTrieString(f_hTemp, KAC_SHOULDLESS, "Your convar %s should be less than or equal to %s but was set to %s.  Please correct this before rejoining");
	SetTrieString(f_hTemp, KAC_HASNOTBOUND, "%N (%s) has convar %s set to %s when it should be beteween %s and %f.");
	SetTrieString(f_hTemp, KAC_SHOULDBOUND, "Your convar %s should be between %s and %f but was set to %s.  Please correct this before rejoining");
	SetTrieString(f_hTemp, KAC_BANIP, "You were banned by the server");
	SetTrieString(f_hTemp, KAC_ADDCVARUSAGE, "Usage: kac_addcvar <cvar name> <comparison type> <action> <value> <value2 if bound>");
	SetTrieString(f_hTemp, KAC_REMCVARUSAGE, "Usage: kac_removecvar <cvar name>");
	SetTrieString(f_hTemp, KAC_REMCVARSUCCESS, "ConVar %s was successfully removed from the check list.");
	SetTrieString(f_hTemp, KAC_REMCVARFAILED, "Unable to find ConVar %s in the check list.");
	SetTrieString(f_hTemp, KAC_ADDCVARBADNAME, "The ConVar name \"%s\" is invalid and cannot be used.");
	SetTrieString(f_hTemp, KAC_ADDCVARBADCOMP, "Unrecognized comparison type \"%s\", acceptable values: \"equal\", \"greater\", \"less\", \"between\", or \"strequal\".");
	SetTrieString(f_hTemp, KAC_ADDCVARBADACT, "Unrecognized action type \"%s\", acceptable values: \"warn\", \"mute\", \"kick\", or \"ban\".");
	SetTrieString(f_hTemp, KAC_ADDCVARBADBOUND, "Bound comparison type needs two values to compare with.");
	SetTrieString(f_hTemp, KAC_ADDCVAREXISTS, "The ConVar %s already exists in the check list.");
	SetTrieString(f_hTemp, KAC_ADDCVARSUCCESS, "Successfully added ConVar %s to the check list.");
	SetTrieString(f_hTemp, KAC_ADDCVARFAILED, "Failed to add ConVar %s to the check list.");
	SetTrieString(f_hTemp, KAC_CHANGENAME, "Please change your name");
	SetTrieString(f_hTemp, KAC_CBANNED, "You have been banned for a command usage violation");
	SetTrieString(f_hTemp, KAC_STATUSREPORT, "Kigen's Anti-Cheat Status Report");
	SetTrieString(f_hTemp, KAC_ON, "On");
	SetTrieString(f_hTemp, KAC_OFF, "Off");
	SetTrieString(f_hTemp, KAC_DISABLED, "Disabled");
	SetTrieString(f_hTemp, KAC_ERROR, "Error");
	SetTrieString(f_hTemp, KAC_NOREPORT, "There is nothing to report.");
	SetTrieString(f_hTemp, KAC_TRANSLATEMOD, "Translations");
	SetTrieString(f_hTemp, KAC_RCONPREVENT, "RCON Crash Prevention");
	SetTrieString(f_hTemp, KAC_NETMOD, "Network");
	SetTrieString(f_hTemp, KAC_UNABLETOCONTACT, "Unable to contact the KAC Master");
	SetTrieString(f_hTemp, KAC_EYEMOD, "Eye Test");
	SetTrieString(f_hTemp, KAC_ANTIWH, "Anti-Wallhack");
	SetTrieString(f_hTemp, KAC_NOSDKHOOK, "Disabled; Unable to find SDKHooks.ext");
	SetTrieString(f_hTemp, KAC_CVARS, "CVars Detection");
	SetTrieString(f_hTemp, KAC_CMDMOD, "Command Protection");
	SetTrieString(f_hTemp, KAC_CMDSPAM, "Command Spam Protection");
	SetTrieString(f_hTemp, KAC_CLIENTMOD, "Client Module");
	SetTrieString(f_hTemp, KAC_CLIENTBALANCE, "Client Team Auto-Balance");
	SetTrieString(f_hTemp, KAC_CLIENTANTIRESPAWN, "Client Anti-Rejoin");
	SetTrieString(f_hTemp, KAC_CLIENTNAMEPROTECT, "Client Name Protection");
	SetTrieString(f_hTemp, KAC_AUTOASSIGNED, "[KAC] You have been Auto-Assigned to a team.");
	SetTrieString(f_hTemp, KAC_SAYBLOCK, "[KAC] Your say has been blocked due to a invalid character.");
	SetTrieString(f_hTemp, KAC_FORCEDREVAL, "[KAC] Forced revalidation on all connected players.");
	SetTrieString(f_hTemp, KAC_CANNOTREVAL, "[KAC] Cannot force revalidation until all player have already been validated.");
	
	//- French -//
	// Thank you to vintage for this translation.  http://kigenac.com/memberlist.php?mode=viewprofile&u=1035
	if (!GetTrieValue(g_hLanguages, "fr", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
		SetFailState("Unable to create language tree for French");
	
	SetTrieString(f_hTemp, KAC_LOADED, "Kigen's Anti-Cheat est opérationnel.");
	SetTrieString(f_hTemp, KAC_BANNED, "Vous avez été banni pour cheat détecté");
	SetTrieString(f_hTemp, KAC_GBANNED, "Vous avez été banni de tous les serveurs protégés par Kigen's Anti-Cheat (KAC). Voir http://www.kigenac.com/ pour plus d'informations");
	SetTrieString(f_hTemp, KAC_VACBANNED, "Ce serveur protégé par Kigen's Anti-Cheat (KAC) n'autorise pas les joueurs bannis par VALVe's Anti-Cheat (VAC)");
	SetTrieString(f_hTemp, KAC_KCMDSPAM, "Vous avez été kické pour spam de commandes");
	SetTrieString(f_hTemp, KAC_ADDCMDUSAGE, "Usage: kac_addcmd <nom de la commande> <ban (1 or 0)>");
	SetTrieString(f_hTemp, KAC_ADDCMDSUCCESS, "Vous avez correctement ajouté %s à la liste des commandes à surveiller.");
	SetTrieString(f_hTemp, KAC_ADDCMDFAILURE, "%s existe déjà dans la liste des commandes à surveiller.");
	SetTrieString(f_hTemp, KAC_REMCMDUSAGE, "Usage: kac_removecmd <nom de la commande>");
	SetTrieString(f_hTemp, KAC_REMCMDSUCCESS, "Vous avez correctement retiré %s de la liste des commandes à surveiller.");
	SetTrieString(f_hTemp, KAC_REMCMDFAILURE, "%s n'est pas dans la liste des commandes à surveiller.");
	SetTrieString(f_hTemp, KAC_ADDIGNCMDUSAGE, "Usage: kac_addignorecmd <nom de la commande>");
	SetTrieString(f_hTemp, KAC_ADDIGNCMDSUCCESS, "Vous avez correctement ajouté %s à la liste des commandes à ignorer.");
	SetTrieString(f_hTemp, KAC_ADDIGNCMDFAILURE, "%s existe déjà dans la liste des commandes à ignorer.");
	SetTrieString(f_hTemp, KAC_REMIGNCMDUSAGE, "Usage: kac_removeignorecmd <nom de la commande>");
	SetTrieString(f_hTemp, KAC_REMIGNCMDSUCCESS, "Vous avez correctement retiré %s de la liste des commandes à ignorer.");
	SetTrieString(f_hTemp, KAC_REMIGNCMDFAILURE, "%s n'est pas dans la liste des commandes à ignorer.");
	SetTrieString(f_hTemp, KAC_FAILEDTOREPLY, "Votre client n'a pas répondu à temps à une requête. Veuillez vous reconnecter ou redémarrer votre jeu");
	SetTrieString(f_hTemp, KAC_FAILEDAUTH, "Votre client n'a pas autorisé une requête. Veuillez vous reconnecter ou redémarrer votre jeu");
	SetTrieString(f_hTemp, KAC_CLIENTCORRUPT, "Votre client a été corrompu. Veuillez redémarrer votre jeu avant de vous reconnecter");
	SetTrieString(f_hTemp, KAC_REMOVEPLUGINS, "Veuillez supprimer les plugins tiers de votre client pour rejoindre ce serveur");
	SetTrieString(f_hTemp, KAC_HASPLUGIN, "%N (%s) a un plugin activé, renvoie: %s.");
	SetTrieString(f_hTemp, KAC_MUTED, "%N a été rendu silencieux par Kigen's Anti-Cheat.");
	SetTrieString(f_hTemp, KAC_HASNOTEQUAL, "%N (%s) a renvoyé une mauvaise valeur pour %s (la valeur %s, devrait être %s).");
	SetTrieString(f_hTemp, KAC_SHOULDEQUAL, "Votre cvar %s devrait être égale à %s mais est réglée à %s. Veuillez corriger! Merci");
	SetTrieString(f_hTemp, KAC_HASNOTGREATER, "%N (%s) a la cvar %s réglée à %s alors qu'elle devrait être supérieure ou égale à %s.");
	SetTrieString(f_hTemp, KAC_SHOULDGREATER, "Votre cvar %s devrait être supérieure ou égale à %s mais est réglée à %s. Veuillez corriger! Merci");
	SetTrieString(f_hTemp, KAC_HASNOTLESS, "%N (%s) a la cvar %s réglée à %s alors qu'elle devrait être inférieure ou égale à %s.");
	SetTrieString(f_hTemp, KAC_SHOULDLESS, "Votre cvar %s devrait être inférieure ou égale à %s mais est réglée à %s. Veuillez corriger! Merci");
	SetTrieString(f_hTemp, KAC_HASNOTBOUND, "%N (%s) a la cvar %s réglée à %s walors qu'elle devrait être entre %s et %f.");
	SetTrieString(f_hTemp, KAC_SHOULDBOUND, "Votre cvar %s devrait être entre %s et %f mais est réglée à %s. Veuillez corriger! Merci");
	SetTrieString(f_hTemp, KAC_BANIP, "Vous avez été banni par le serveur");
	SetTrieString(f_hTemp, KAC_ADDCVARUSAGE, "Usage: kac_addcvar <nom de la cvar> <type de comparaison> <action> <value> <valeur2 si encadrement>");
	SetTrieString(f_hTemp, KAC_REMCVARUSAGE, "Usage: kac_removecvar <nom de la cvar>");
	SetTrieString(f_hTemp, KAC_REMCVARSUCCESS, "La cvar %s a été retirée correctement de la liste de surveillance.");
	SetTrieString(f_hTemp, KAC_REMCVARFAILED, "Impossible de trouver la cvar %s dans la liste de surveillance.");
	SetTrieString(f_hTemp, KAC_ADDCVARBADNAME, "Le nom de la cvar \"%s\" n'est pas valide et ne peut être utilisé.");
	SetTrieString(f_hTemp, KAC_ADDCVARBADCOMP, "Comparaison non reconnue \"%s\", valeurs acceptées: \"equal\", \"greater\", \"less\", \"between\", ou \"strequal\".");
	SetTrieString(f_hTemp, KAC_ADDCVARBADACT, "Action non reconnue \"%s\", valeurs acceptées: \"warn\", \"mute\", \"kick\", or \"ban\".");
	SetTrieString(f_hTemp, KAC_ADDCVARBADBOUND, "La comparaison d'encadrement nécessite deux valeurs pour être active.");
	SetTrieString(f_hTemp, KAC_ADDCVAREXISTS, "La cvar %s existe déjà dans la liste de surveillance.");
	SetTrieString(f_hTemp, KAC_ADDCVARSUCCESS, "La cvar %s a été correctement ajoutée à la liste de surveillance.");
	SetTrieString(f_hTemp, KAC_ADDCVARFAILED, "La cvar %s n'a pu être ajoutée à la liste de surveillance.");
	SetTrieString(f_hTemp, KAC_CHANGENAME, "Veuillez changer votre nom! SVP.");
	SetTrieString(f_hTemp, KAC_CBANNED, "Vous avez été banni pour une violation d'usage de commande");
	SetTrieString(f_hTemp, KAC_STATUSREPORT, "Rapport de Kigen's Anti-Cheat");
	SetTrieString(f_hTemp, KAC_ON, "On");
	SetTrieString(f_hTemp, KAC_OFF, "Off");
	SetTrieString(f_hTemp, KAC_DISABLED, "Désactivé");
	SetTrieString(f_hTemp, KAC_ERROR, "Erreur");
	SetTrieString(f_hTemp, KAC_NOREPORT, "Il n'y a rien à noter dans le rapport.");
	SetTrieString(f_hTemp, KAC_TRANSLATEMOD, "Traductions");
	SetTrieString(f_hTemp, KAC_RCONPREVENT, "Prévention du crash RCON");
	SetTrieString(f_hTemp, KAC_NETMOD, "Network");
	SetTrieString(f_hTemp, KAC_UNABLETOCONTACT, "Impossible de contacter le server maître KAC");
	SetTrieString(f_hTemp, KAC_EYEMOD, "Eye Test");
	SetTrieString(f_hTemp, KAC_ANTIWH, "Anti-Wallhack");
	SetTrieString(f_hTemp, KAC_NOSDKHOOK, "Désactivé; Impossible de trouver SDKHooks.ext");
	SetTrieString(f_hTemp, KAC_CVARS, "Surveillance des CVars");
	SetTrieString(f_hTemp, KAC_CMDMOD, "Protection des Commandes");
	SetTrieString(f_hTemp, KAC_CMDSPAM, "Protection du spam de Commandes");
	SetTrieString(f_hTemp, KAC_CLIENTMOD, "Module Client");
	SetTrieString(f_hTemp, KAC_CLIENTBALANCE, "Client Team Auto-Balance");
	SetTrieString(f_hTemp, KAC_CLIENTANTIRESPAWN, "Client Anti-Rejoindre");
	SetTrieString(f_hTemp, KAC_CLIENTNAMEPROTECT, "Client Protection du Nom");
	SetTrieString(f_hTemp, KAC_AUTOASSIGNED, "[KAC] Vous avez rejoint automatiquement une team.");
	SetTrieString(f_hTemp, KAC_SAYBLOCK, "[KAC] Vous ne pouvez plus écrire dû à un caractère non autorisé.");
	SetTrieString(f_hTemp, KAC_FORCEDREVAL, "[KAC] Revalidation forcée sur tous les joueurs connectés.");
	SetTrieString(f_hTemp, KAC_CANNOTREVAL, "[KAC] Revalidation impossible, tous les joueurs ont déjà été validés.");
	
	//- Italian -//
	// Thank you to asterix for this translation.  http://kigenac.com/memberlist.php?mode=viewprofile&u=116
	if (!GetTrieValue(g_hLanguages, "it", any:f_hTemp) || f_hTemp == INVALID_HANDLE)
		SetFailState("Unable to create language tree for Italian");
	
	SetTrieString(f_hTemp, KAC_LOADED, "L'anticheats Kigen è stato caricato con successo.");
	SetTrieString(f_hTemp, KAC_BANNED, "Sei stato bannato per aver utilizzato dei trucchi");
	SetTrieString(f_hTemp, KAC_GBANNED, "Sei bannato da tutti i server protetti dall'anticheats Kigen (KAC). Visita http://www.kigenac.com/ per ulteriori informazioni");
	SetTrieString(f_hTemp, KAC_VACBANNED, "I server protetti dall'anticheats Kigen (KAC) non permettono l'ingresso ai giocatori bannati dall'anticheats della VALVE (VAC)");
	SetTrieString(f_hTemp, KAC_KCMDSPAM, "Se stato kikkato per spamming");
	SetTrieString(f_hTemp, KAC_ADDCMDUSAGE, "Utilizzo: kac_addcmd <nome del comando> <ban (1 o 0)>");
	SetTrieString(f_hTemp, KAC_ADDCMDSUCCESS, "Sei stato aggiunto %s alla lista dei blocchi comandi.");
	SetTrieString(f_hTemp, KAC_ADDCMDFAILURE, "%s già esistente nella lista dei blocchi comandi.");
	SetTrieString(f_hTemp, KAC_REMCMDUSAGE, "Utilizzo: kac_removecmd <nome del comando>");
	SetTrieString(f_hTemp, KAC_REMCMDSUCCESS, "Sei stato rimosso %s dalla lista dei comandi.");
	SetTrieString(f_hTemp, KAC_REMCMDFAILURE, "%s non è nella lista dei blocchi comandi.");
	SetTrieString(f_hTemp, KAC_ADDIGNCMDUSAGE, "Utilizzo: kac_addignorecmd <nome del comando>");
	SetTrieString(f_hTemp, KAC_ADDIGNCMDSUCCESS, "Seistato aggiunto %s alla lista ignora.");
	SetTrieString(f_hTemp, KAC_ADDIGNCMDFAILURE, "%s esiste già nella lista ignora.");
	SetTrieString(f_hTemp, KAC_REMIGNCMDUSAGE, "Utilizzo: kac_removeignorecmd <nome del comando>");
	SetTrieString(f_hTemp, KAC_REMIGNCMDSUCCESS, "Sei stato rimosso %s dalla lista ignora.");
	SetTrieString(f_hTemp, KAC_REMIGNCMDFAILURE, "%s non è trai comandi della lista ignora.");
	SetTrieString(f_hTemp, KAC_FAILEDTOREPLY, "Il giocatore ha fallito nel rispondere in tempo a delle query. Per favore riconnetti o restarta il tuo gioco");
	SetTrieString(f_hTemp, KAC_FAILEDAUTH, "Il giocatore non è riuscito ad ottenere l'autorizzazione in tempo.Per favore riconnetti o restarta il tuo gioco");
	SetTrieString(f_hTemp, KAC_CLIENTCORRUPT, "Il giocatore sta per avere problemi di integrità. Per favore riconnetti o restarta il tuo gioco");
	SetTrieString(f_hTemp, KAC_REMOVEPLUGINS, "Per favore rimuovi tutti i terzi programmi dal tuo pc prima di collegarti nuovamente a questo server");
	SetTrieString(f_hTemp, KAC_HASPLUGIN, "%N (%s) ha un programma funzionante, risposta %s.");
	SetTrieString(f_hTemp, KAC_MUTED, "%N è stato mutato dall'anticheats Kigen.");
	SetTrieString(f_hTemp, KAC_HASNOTEQUAL, "%N (%s) non corretta risposta del valore %s (valore %s, deve essere %s).");
	SetTrieString(f_hTemp, KAC_SHOULDEQUAL, "Il tuo valore %s deve essere uguale a %s invece è %s. Per favore modificalo prima di ricollegarti a questo server");
	SetTrieString(f_hTemp, KAC_HASNOTGREATER, "%N (%s) ha il valore %s è %s quando deve essere maggiore o uguale a %s.");
	SetTrieString(f_hTemp, KAC_SHOULDGREATER, "Il tuo valore %s deve essere maggiore o uguale a %s invece è %s. Per favore modificalo prima di ricollegarti");
	SetTrieString(f_hTemp, KAC_HASNOTLESS, "%N (%s) ha il valore %s è %s quando deve essere inferiore o uguale a %s.");
	SetTrieString(f_hTemp, KAC_SHOULDLESS, "Il tuo valore %s deve essere inferiore o uguale a %s invece è %s. Per favore modificalo prima di ricollegarti");
	SetTrieString(f_hTemp, KAC_HASNOTBOUND, "%N (%s) ha il valore %s a %s quando deve essere tra %s e %f.");
	SetTrieString(f_hTemp, KAC_SHOULDBOUND, "Il tuo valore %s deve essere tra %s e %f invece è %s. Per favore modificalo prima di ricollegarti");
	SetTrieString(f_hTemp, KAC_BANIP, "Sei stato bannato dal server");
	SetTrieString(f_hTemp, KAC_ADDCVARUSAGE, "Utilizzo: kac_addcvar <nome del cvar> <tipo del confronto> <azione> <valore> <valore2 se bindato>");
	SetTrieString(f_hTemp, KAC_REMCVARUSAGE, "Usage: kac_removecvar <nome del cvar>");
	SetTrieString(f_hTemp, KAC_REMCVARSUCCESS, "Il cvar %s è stato rmisso dalla lista di controllo");
	SetTrieString(f_hTemp, KAC_REMCVARFAILED, "Impossibile trovare il cvar %s nella lista di controllo.");
	SetTrieString(f_hTemp, KAC_ADDCVARBADNAME, "Il nome di questo cvar \"%s\" non è valido e non può essere utilizzato.");
	SetTrieString(f_hTemp, KAC_ADDCVARBADCOMP, "Confronto non riconosciuto \"%s\", valore accettabile: \"uguale\", \"maggiore\", \"inferiore\", \"tra\", o \"strequal\".");
	SetTrieString(f_hTemp, KAC_ADDCVARBADACT, "Azione non riconosciuta \"%s\", valore accettabile: \"avvertimento\", \"mutare\", \"kick\", o \"bannare\".");
	SetTrieString(f_hTemp, KAC_ADDCVARBADBOUND, "Il confronto bindato necessita di due valori da confrontare.");
	SetTrieString(f_hTemp, KAC_ADDCVAREXISTS, "Il cvar %s esiste già nella lista di controllo.");
	SetTrieString(f_hTemp, KAC_ADDCVARSUCCESS, "Il cvar %s è stato aggiunto alla lista di controllo.");
	SetTrieString(f_hTemp, KAC_ADDCVARFAILED, "Non si è riusciti ad aggiungere il cvar %s alla lista di controllo.");
	SetTrieString(f_hTemp, KAC_CHANGENAME, "Per favore cambia il tuo nome");
	SetTrieString(f_hTemp, KAC_CBANNED, "Sei stato bannato per utilizzo proibito dei comandi");
	SetTrieString(f_hTemp, KAC_STATUSREPORT, "Kigen's Anti-Cheat Status Report");
	SetTrieString(f_hTemp, KAC_ON, "On");
	SetTrieString(f_hTemp, KAC_OFF, "Off");
	SetTrieString(f_hTemp, KAC_DISABLED, "Disabilitato");
	SetTrieString(f_hTemp, KAC_ERROR, "Errore");
	SetTrieString(f_hTemp, KAC_NOREPORT, "Non c'è nulla da riportare.");
	SetTrieString(f_hTemp, KAC_TRANSLATEMOD, "Traduzioni");
	SetTrieString(f_hTemp, KAC_RCONPREVENT, "RCON Prevenzione Crash");
	SetTrieString(f_hTemp, KAC_NETMOD, "Rete");
	SetTrieString(f_hTemp, KAC_UNABLETOCONTACT, "Impossibile contattare il KAC Master");
	SetTrieString(f_hTemp, KAC_EYEMOD, "Test visivo");
	SetTrieString(f_hTemp, KAC_ANTIWH, "Anti-Wallhack");
	SetTrieString(f_hTemp, KAC_NOSDKHOOK, "Disabilitato; Impossibile trovare SDKHooks.ext");
	SetTrieString(f_hTemp, KAC_CVARS, "CVars Controllo");
	SetTrieString(f_hTemp, KAC_CMDMOD, "Command Protezione");
	SetTrieString(f_hTemp, KAC_CMDSPAM, "Protezione Comando Spam");
	SetTrieString(f_hTemp, KAC_CLIENTMOD, "Modulo Giocatore");
	SetTrieString(f_hTemp, KAC_CLIENTBALANCE, "Auto-Balance team giocatori");
	SetTrieString(f_hTemp, KAC_CLIENTANTIRESPAWN, "Giocatori Anti-Rejoin");
	SetTrieString(f_hTemp, KAC_CLIENTNAMEPROTECT, "Protezione nomi giocatori");
	SetTrieString(f_hTemp, KAC_AUTOASSIGNED, "[KAC] Sei stato assegnato forzatamente ad un Team.");
	SetTrieString(f_hTemp, KAC_SAYBLOCK, "[KAC] Il tuo testo è stato bloccato a causa di alcuni caratteri non validi.");
	SetTrieString(f_hTemp, KAC_FORCEDREVAL, "[KAC] Convalida forzata di tutti i giocatori connessi.");
	SetTrieString(f_hTemp, KAC_CANNOTREVAL, "[KAC] Non si può forzare la validazione dei giocatori finchè questi non siano stati tutti validati");
}

stock KAC_Translate(client, String:trans[], String:dest[], maxlen)
{
	if (client)
		GetTrieString(g_hCLang[client], trans, dest, maxlen);
	else
		GetTrieString(g_hSLang, trans, dest, maxlen);
}

stock KAC_ReplyToCommand(client, const String:trans[], any:...)
{
	decl String:f_sBuffer[256], String:f_sFormat[256];
	if (!client)
		GetTrieString(g_hSLang, trans, f_sFormat, sizeof(f_sFormat));
	else
		GetTrieString(g_hCLang[client], trans, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 3);
	ReplyToCommand(client, "%s", f_sBuffer);
}

stock KAC_PrintToServer(const String:trans[], any:...)
{
	decl String:f_sBuffer[256], String:f_sFormat[256];
	GetTrieString(g_hSLang, trans, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 2);
	PrintToServer("%s", f_sBuffer);
}

stock KAC_PrintToChat(client, const String:trans[], any:...)
{
	decl String:f_sBuffer[256], String:f_sFormat[256];
	GetTrieString(g_hCLang[client], trans, f_sFormat, sizeof(f_sFormat));
	VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 3);
	PrintToChat(client, "%s", f_sBuffer);
}

stock KAC_PrintToChatAdmins(const String:trans[], any:...)
{
	decl String:f_sBuffer[256], String:f_sFormat[256];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_bIsAdmin[i])
		{
			GetTrieString(g_hCLang[i], trans, f_sFormat, sizeof(f_sFormat));
			VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 2);
			PrintToChat(i, "%s", f_sBuffer);
		}
	}
}

stock KAC_PrintToChatAll(const String:trans[], any:...)
{
	decl String:f_sBuffer[256], String:f_sFormat[256];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_bInGame[i])
		{
			GetTrieString(g_hCLang[i], trans, f_sFormat, sizeof(f_sFormat));
			VFormat(f_sBuffer, sizeof(f_sBuffer), f_sFormat, 2);
			PrintToChat(i, "%s", f_sBuffer);
		}
	}
}

stock KAC_Kick(client, const String:trans[], any:...)
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