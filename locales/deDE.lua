local AddOnName, Engine = ...;
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale(AddOnName, "deDE", false, false);
if not L then return end

L['Modules'] = "Module";
L['Left-Click'] = "Links-Klick";
L['Right-Click'] = "Rechts-Klick";

-- General
L["Positioning"] = true;
L['Bar Position'] = "Leistenposition";
L['Top'] = "Oben";
L['Bottom'] = "Unten";
L['Bar Color'] = "Leistenfarbe";
L['Use Class Color for Bar'] = "Benutze Klassenfarbe für Leiste";
L["Miscellaneous"] = true;
L['Bar Padding'] = "Leistenabstand";
L['Module Spacing'] = "Modulabstand";
L['Hide order hall bar'] = true;

-- Positioning Options
L['Positioning Options'] = "Positions-Optionen";
L['Horizontal Position'] = "Horizontale Position";
L['Bar Width'] = "Leistenbreite";
L['Left'] = "Links";
L['Center'] = "Mitte";
L['Right'] = "Rechts";

-- Media
L['Font'] = "Schriftart";
L['Small Font Size'] = "Kleine Schriftgröße";
L['Text Style'] = "Schriftstil";

-- Text Colors
L["Colors"] = "Farben";
L['Text Colors'] = "Textfarbe";
L['Normal'] = "Normal";
L['Inactive'] = "Inaktiv";
L["Use Class Color for Text"] = true;
L["Only the alpha can be set with the color picker"] = true;
L['Use Class Colors for Hover'] = "Benutze Klassenfarbe für Mouseover";
L['Hover'] = "Mouseover";

-------------------- MODULES ---------------------------

L['Micromenu'] = "Mikromenü";
L['Show Social Tooltips'] = "Social Tooltips anzeigen";
L['Main Menu Icon Right Spacing'] = "Hauptmenü Icon Abstand Rechts";
L['Icon Spacing'] = "Icon-Abstand";
L['Open Guild Page'] = true;
L['No Tag'] = true;
L['Whisper BNet'] = true;
L['Whisper Character'] = true;
L['Hide Social Text'] = "Social Text verstecken";
L["GMOTD in Tooltip"] = true;
L["Modifier for friend invite"] = true;
L['Show/Hide Buttons'] = true;
L['Show Menu Button'] = true;
L['Show Chat Button'] = true;
L['Show Guild Button'] = true;
L['Show Social Button'] = true;
L['Show Character Button'] = true;
L['Show Spellbook Button'] = true;
L['Show Talents Button'] = true;
L['Show Achievements Button'] = true;
L['Show Quests Button'] = true;
L['Show LFG Button'] = true;
L['Show Journal Button'] = true;
L['Show PVP Button'] = true;
L['Show Pets Button'] = true;
L['Show Shop Button'] = true;
L['Show Help Button'] = true;

L['Always Show Item Level'] = "Rüstungslevel immer anzeigen";
L['Minimum Durability to Become Active'] = "Minimale Haltbarkeit für Anzeige";
L['Maximum Durability to Show Item Level'] = "Maximale Haltbarkeit für Rüstungslevel-Anzeige";

L["Volume step"] = true;

L['Time Format'] = "Uhrzeit-Format";
L['Use Server Time'] = "Server-Zeit benutzen";
L['New Event!'] = "Neue Veranstaltung";
L['Local Time'] = "Lokale Zeit";
L['Realm Time'] = "Realm-Zeit";
L['Open Calendar'] = "Kalendar öffnen";
L['Open Clock'] = "Stoppuhr öffnen";
L['Hide Event Text'] = "Event-Text verstecken";

L['Travel'] = "Reise";
L['Port Options'] = "Port Optionen";
L['Ready'] = "Bereit";
L['Travel Cooldowns'] = "Reise-Abklingzeiten";
L['Change Port Option'] = "Port Optionen ändern";

L['Always Show Silver and Copper'] = "Silber und Kupfer immer anzeigen";
L['Shorten Gold'] = "Gold verkürzen";
L['Toggle Bags'] = "Taschen anzeigen";
L['Session Total'] = true;

L['Show XP Bar Below Max Level'] = "Erfahrungsleiste unter Levelcap anzeigen";
L['Use Class Colors for XP Bar'] = "Klassenfarbe für Erfahrungsleiste benutzen";
L['Show Tooltips'] = "Tooltips anzeigen";
L['Text on Right'] = "Text auf der rechten Seite";
L['Currency Select'] = "Währung auswählen";
L['First Currency'] = "Währung #1";
L['Second Currency'] = "Währung #2";
L['Third Currency'] = "Währung #3";
L['Rested'] = "Ausgeruht";

L['Show World Ping'] = "World-Ping anzeigen";
L['Number of Addons To Show'] = "Maximale Anzahl für Addon-Anzeige";
L['Addons to Show in Tooltip'] = true;
L['Show All Addons in Tooltip with Shift'] = "Alle Addons im Tooltip anzeigen via Shift";
L['Memory Usage'] = "Speichernutzung";
L['Garbage Collect'] = true;
L['Cleaned'] = "Aufgeräumt";

L['Use Class Colors'] = "Klassenfarben benutzen";
L['Cooldowns'] = "Abklingzeiten";

L['Set Specialization'] = "Spezialisierung auswählen";
L['Set Loot Specialization'] = "Beute-Spezialisierung auswählen";
L['Current Specialization'] = "Aktuelle Spezialisierung";
L['Current Loot Specialization'] = "Aktuelle Beute-Spezialisierung";
L['Talent Minimum Width'] = "Minimale Breite für Talente";
L['Remaining'] = "Ausbleibend";
L['Available Ranks'] = "Verfügbare Ränge";
L['Artifact Knowledge'] = "Artefaktwissen";
