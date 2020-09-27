local AddOnName, Engine = ...;
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale(AddOnName, "deDE", false, false);
if not L then return end

L['Modules'] = "Module";
L['Left-Click'] = "Linksklick";
L['Right-Click'] = "Rechtsklick";
L['k'] = true; -- short for 1000
L['M'] = true; -- short for 1000000
L['B'] = true; -- short for 1000000000
L['L'] = true; -- For the local ping
L['W'] = true; -- For the world ping

-- General
L["Positioning"] = "Positionierung";
L['Bar Position'] = "Leistenposition";
L['Top'] = "Oben";
L['Bottom'] = "Unten";
L['Bar Color'] = "Leistenfarbe";
L['Use Class Color for Bar'] = "Benutze Klassenfarbe für Leiste";
L["Miscellaneous"] = "Verschiedenes";
L['Hide Bar in combat'] = "Verstecke die Leiste im Kampf";
L['Bar Padding'] = "Leistenabstand";
L['Module Spacing'] = "Abstand zwischen Modulen";
L['Hide order hall bar'] = "Verstecke Klassenhallenleiste";
L['Use ElvUI for tooltips'] = "Verwenden Sie ElvUI für QuickInfos";

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
L["Use Class Color for Text"] = "Benutze Klassenfarben für Texte";
L["Only the alpha can be set with the color picker"] = "Nur die Transparenz kann mit dem Farbwerkzeug gesetzt werden";
L['Use Class Colors for Hover'] = "Benutze Klassenfarbe für Mouseover";
L['Hover'] = "Mouseover";

-------------------- MODULES ---------------------------

L['Micromenu'] = "Mikromenü";
L['Show Social Tooltips'] = "Social Tooltips anzeigen";
L['Main Menu Icon Right Spacing'] = "Hauptmenü Icon Abstand Rechts";
L['Icon Spacing'] = "Icon-Abstand";
L["Hide BNet App Friends"] = true;
L['Open Guild Page'] = "Öffne Gildenfenster";
L['No Tag'] = "Keine Markierung";
L['Whisper BNet'] = "über BNet anflüstern";
L['Whisper Character'] = "Charakter anflüstern";
L['Hide Social Text'] = "Social Text verstecken";
L['Social Text Offset'] = "Social Text versetzen";
L["GMOTD in Tooltip"] = "Nachricht des Tages im Tooltip";
L["Modifier for friend invite"] = "Modifier um Freunde einzuladen";
L['Show/Hide Buttons'] = "Zeige/Verstecke Tasten";
L['Show Menu Button'] = "Zeige Menü Taste";
L['Show Chat Button'] = "Zeige Chat Taste";
L['Show Guild Button'] = "Zeige Gilden Taste";
L['Show Social Button'] = "Zeige Freunde Taste";
L['Show Character Button'] = "Zeige Charakter Taste";
L['Show Spellbook Button'] = "Zeige Zauberbuch Taste";
L['Show Talents Button'] = "Zeige Talent Taste";
L['Show Achievements Button'] = "Zeige Erfolg Taste";
L['Show Quests Button'] = "Zeige Quest Taste";
L['Show LFG Button'] = "Zeige LFG Taste";
L['Show Journal Button'] = "Zeige Journal Taste";
L['Show PVP Button'] = "Zeige PVP Taste";
L['Show Pets Button'] = "Zeige Haustier Taste";
L['Show Shop Button'] = "Zeige Shop Taste";
L['Show Help Button'] = "Zeige Hilfe Taste";

L['Always Show Item Level'] = "Gegenstandsstufe immer anzeigen";
L['Minimum Durability to Become Active'] = "Minimale Haltbarkeit für Anzeige";
L['Maximum Durability to Show Item Level'] = "Maximale Haltbarkeit für Gegenstandsstufe-Anzeige";

L['Master Volume'] = "Haupt-Lautstärke";
L["Volume step"] = "Lautstärken-Schritte";

L['Time Format'] = "Uhrzeit-Format";
L['Use Server Time'] = "Server-Zeit benutzen";
L['New Event!'] = "Neue Veranstaltung!";
L['Local Time'] = "Lokale Zeit";
L['Realm Time'] = "Realm-Zeit";
L['Open Calendar'] = "Kalendar öffnen";
L['Open Clock'] = "Stoppuhr öffnen";
L['Hide Event Text'] = "Event-Text verstecken";

L['Travel'] = "Reise";
L['Port Options'] = "Teleport-Optionen";
L['Ready'] = "Bereit";
L['Travel Cooldowns'] = "Reise-Abklingzeiten";
L['Change Port Option'] = "Teleport-Optionen ändern";

L['Always Show Silver and Copper'] = "Silber und Kupfer immer anzeigen";
L['Shorten Gold'] = "Gold abkürzen";
L['Toggle Bags'] = "Taschen anzeigen";
L['Session Total'] = "Sitzung total";
L['Daily Total'] = "Heute total";
L['Gold rounded values'] = "Gold runden";

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
L['Addons to Show in Tooltip'] = "Addons die im Tooltip angezeigt werden";
L['Show All Addons in Tooltip with Shift'] = "Alle Addons im Tooltip anzeigen via Shift";
L['Memory Usage'] = "Speichernutzung";
L['Garbage Collect'] = "Speicher säubern"; -- The expression "garbage collecor" only works in english
L['Cleaned'] = "Gesäubert";

L['Use Class Colors'] = "Klassenfarben benutzen";
L['Cooldowns'] = "Abklingzeiten";
L['Toggle Profession Frame'] = 'Berufsrahmen anzeigen';
L['Toggle Profession Spellbook'] = 'Zauberbuch für Berufe anzeigen';

L['Set Specialization'] = "Spezialisierung auswählen";
L['Set Loot Specialization'] = "Beute-Spezialisierung auswählen";
L['Current Specialization'] = "Aktuelle Spezialisierung";
L['Current Loot Specialization'] = "Aktuelle Beute-Spezialisierung";
L['Talent Minimum Width'] = "Minimale Breite für Talente";
L['Open Artifact'] = "Artefakt öffen";
L['Remaining'] = "Verbleibend";
L['Available Ranks'] = "Verfügbare Ränge";
L['Artifact Knowledge'] = "Artefaktwissen";

L['Speed'] = "Geschwindigkeit";
