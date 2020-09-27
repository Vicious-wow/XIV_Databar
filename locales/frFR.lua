local AddOnName, Engine = ...;
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale(AddOnName, "frFR", false, false);
if not L then return end

L['Modules'] = "Modules";
L['Left-Click'] = "Clic gauche";
L['Right-Click'] = "Clic droit";
L['k'] = true; -- short for 1000
L['M'] = "m"; -- short for 1000000
L['B'] = "M"; -- short for 1000000000
L['L'] = true; -- For the local ping
L['W'] = "M"; -- For the world ping

-- General
L["Positioning"] = "Positionnement";
L['Bar Position'] = "Position de la barre";
L['Top'] = "Haut";
L['Bottom'] = "Bas";
L['Bar Color'] = "Couleur de la barre";
L['Use Class Color for Bar'] = "Utiliser la couleur de classe pour la barre";
L["Miscellaneous"] = "Divers";
L['Hide Bar in combat'] = "Cacher la barre en combat";
L['Bar Padding'] = "Décalage de la barre";
L['Module Spacing'] = "Espacement des modules";
L['Hide order hall bar'] = "Cacher la barre du hall de classe";
L['Use ElvUI for tooltips'] = "Utiliser ElvUI pour les info-bulles";

-- Positioning Options
L['Positioning Options'] = "Options de positionnement";
L['Horizontal Position'] = "Horizontal";
L['Bar Width'] = "Longueur de la barre";
L['Left'] = "Aligné à gauche";
L['Center'] = "Centrer";
L['Right'] = "Aligné à droite";

-- Media
L['Font'] = "Police";
L['Small Font Size'] = "Taille de la petite police";
L['Text Style'] = "Style du texte";

-- Text Colors
L["Colors"] = "Couleurs";
L['Text Colors'] = "Couleurs du texte";
L['Normal'] = "Normale";
L['Use Class Color for Text'] = "Utiliser la couleur de classe pour le texte";
L['Only the alpha can be set with the color picker'] = "Seul l'alpha peut être réglé avec la sélection de couleur";
L['Inactive'] = "Inactif";
L['Use Class Colors for Hover'] = "Utiliser la couleur de classe lors du survol";
L['Hover'] = "Survol";

-------------------- MODULES ---------------------------

L['Micromenu'] = "Micro menu";
L['Show Social Tooltips'] = "Montrer les bulles de contacts";
L['Main Menu Icon Right Spacing'] = "Décalage à droite du micro menu";
L['Icon Spacing'] = "Espacement des icônes";
L["Hide BNet App Friends"] = "Masquer amis BNet applications";
L['Open Guild Page'] = "Ouvrir la page de guilde";
L['No Tag'] = "Aucun Tag";
L['Whisper BNet'] = "Chuchoter BNet";
L['Whisper Character'] = "Chuchoter le personnage";
L['Hide Social Text'] = "Cacher le texte des contacts";
L['Social Text Offset'] = "Décalage du texte social";
L["GMOTD in Tooltip"] = "Afficher le message de guilde dans la bulle";
L["Modifier for friend invite"] = "Touche modifieuse pour inviter un contact";
L['Show/Hide Buttons'] = "Montrer/Cacher les boutons";
L['Show Menu Button'] = "Montrer le bouton Menu";
L['Show Chat Button'] = "Montrer le bouton Tchat";
L['Show Guild Button'] = "Montrer le bouton Guilde";
L['Show Social Button'] = "Montrer le bouton Contacts";
L['Show Character Button'] = "Montrer le bouton Personnage";
L['Show Spellbook Button'] = "Montrer le bouton Grimoire";
L['Show Talents Button'] = "Montrer le bouton Talents";
L['Show Achievements Button'] = "Montrer le bouton Haut-faits";
L['Show Quests Button'] = "Montrer le bouton Quêtes";
L['Show LFG Button'] = "Montrer le bouton RDG";
L['Show Journal Button'] = "Montrer le bouton Journal";
L['Show PVP Button'] = "Montrer le bouton PVP";
L['Show Pets Button'] = "Montrer le bouton Mascottes";
L['Show Shop Button'] = "Montrer le bouton Boutique";
L['Show Help Button'] = "Montrer le bouton Aide";

L['Always Show Item Level'] = "Toujours montrer le niveau d'objet";
L['Minimum Durability to Become Active'] = "Activation au minimum de durabilité";
L['Maximum Durability to Show Item Level'] = "Durabilité maximum pour montrer le niveau d'item";

L['Master Volume'] = "Volume principal";
L["Volume step"] = "Incrément de volume";

L['Time Format'] = "Format de l'heure";
L['Use Server Time'] = "Utiliser l'heure du serveur";
L['New Event!'] = "Nouvel événement";
L['Local Time'] = "Heure locale";
L['Realm Time'] = "Heure du royaume";
L['Open Calendar'] = "Ouvrir le calendrier";
L['Open Clock'] = "Ouvrir l'horloge";
L['Hide Event Text'] = "Cacher le texte d'événement";

L['Travel'] = "Voyage";
L['Port Options'] = "Options de téléportation";
L['Ready'] = "Prêt";
L['Travel Cooldowns'] = "Temps de recharge des voyages";
L['Change Port Option'] = "Option de changement de la téléportation";

L['Always Show Silver and Copper'] = "Toujours montrer l'argent et le cuivre";
L['Shorten Gold'] = "Raccourcir le montant d'or";
L['Toggle Bags'] = "Ouvrir/Fermer les sacs";
L['Session Total'] = "Total sur la session";
L['Daily Total'] = "Total quotidien";
L['Gold rounded values'] = "Valeurs arrondies au po";

L['Show XP Bar Below Max Level'] = "Montrer la barre d'XP quand le niveau max n'est pas atteint";
L['Use Class Colors for XP Bar'] = "Utiliser la couleur de classe pour la barre d'XP";
L['Show Tooltips'] = "Montrer les bulles";
L['Text on Right'] = "Texte à droite";
L['Currency Select'] = "Sélection de la monnaie";
L['First Currency'] = "Première monnaie";
L['Second Currency'] = "Seconde monnaie";
L['Third Currency'] = "Troisième monnaie";
L['Rested'] = "Reposé";

L['Show World Ping'] = "Montrer la latence monde";
L['Number of Addons To Show'] = "Nombre d'addon à lister";
L['Addons to Show in Tooltip'] = "Addon à lister dans la bulle";
L['Show All Addons in Tooltip with Shift'] = "Lister tous les addons avec Maj";
L['Memory Usage'] = "Utilisation mémoire";
L['Garbage Collect'] = "Nettoyer la mémoire";
L['Cleaned'] = "Nettoyé";

L['Use Class Colors'] = "Utiliser les couleurs de classe";
L['Cooldowns'] = "Temps de recharge";
L['Toggle Profession Frame'] = 'Afficher le cadre de la profession';
L['Toggle Profession Spellbook'] = 'afficher le livre de sorts de la profession';

L['Set Specialization'] = "Choix de la spécialisation";
L['Set Loot Specialization'] = "Spécialisation du butin";
L['Current Specialization'] = "Spécialisation actuelle";
L['Current Loot Specialization'] = "Spécialisation du butin actuelle";
L['Talent Minimum Width'] = "Longueur minimum";
L['Open Artifact'] = "Ouvrir l'Arme Prodigieuse";
L['Remaining'] = "Restant";
L['Available Ranks'] = "Rangs disponibles";
L['Artifact Knowledge'] = "Connaissance de l'arme prodigieuse";

L['Coordinates'] = "Coordonnées";
