local AddonName, Engine = ...;

local LibStub = LibStub;
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale(AddonName, "enUS", true, false); ---@class XIV_DatabarLocale

L['Modules'] = true;
L['Left-Click'] = true;
L['Right-Click'] = true;
L['k'] = true; -- short for 1000
L['M'] = true; -- short for 1000000
L['B'] = true; -- short for 1000000000
L['L'] = true; -- For the local ping
L['W'] = true; -- For the world ping


-- General
L["Positioning"] = true;
L['Bar Position'] = true;
L['Top'] = true;
L['Bottom'] = true;
L['Bar Color'] = true;
L['Use Class Color for Bar'] = true;
L["Miscellaneous"] = true;
L['Hide Bar in combat'] = true;
L['Bar Padding'] = true;
L['Module Spacing'] = true;
L['Hide order hall bar'] = true;
L['Use ElvUI for tooltips'] = true;

-- Positioning Options
L['Positioning Options'] = true;
L['Horizontal Position'] = true;
L['Bar Width'] = true;
L['Left'] = true;
L['Center'] = true;
L['Right'] = true;

-- Media
L['Font'] = true;
L['Small Font Size'] = true;
L['Text Style'] = true;

-- Text Colors
L["Colors"] = true;
L['Text Colors'] = true;
L['Normal'] = true;
L['Inactive'] = true;
L["Use Class Color for Text"] = true;
L["Only the alpha can be set with the color picker"] = true;
L['Use Class Colors for Hover'] = true;
L['Hover'] = true;

-------------------- MODULES ---------------------------

L['Micromenu'] = true;
L['Show Social Tooltips'] = true;
L['Main Menu Icon Right Spacing'] = true;
L['Icon Spacing'] = true;
L["Hide BNet App Friends"] = true;
L['Open Guild Page'] = true;
L['No Tag'] = true;
L['Whisper BNet'] = true;
L['Whisper Character'] = true;
L['Hide Social Text'] = true;
L['Social Text Offset'] = true;
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
L['No Info'] = true;
L['Classic'] = true;
L['Alliance'] = true;
L['Horde'] = true;

L['Durability Warning Threshold'] = true;
L['Show Item Level'] = true;
L['Show Coordinates'] = true;

L['Master Volume'] = true;
L["Volume step"] = true;

L['Time Format'] = true;
L['Use Server Time'] = true;
L['New Event!'] = true;
L['Local Time'] = true;
L['Realm Time'] = true;
L['Open Calendar'] = true;
L['Open Clock'] = true;
L['Hide Event Text'] = true;

L['Travel'] = true;
L['Port Options'] = true;
L['Ready'] = true;
L['Travel Cooldowns'] = true;
L['Change Port Option'] = true;

L['Always Show Silver and Copper'] = true;
L['Shorten Gold'] = true;
L['Toggle Bags'] = true;
L['Session Total'] = true;
L['Daily Total'] = true;
L['Gold rounded values'] = true;

L['Show XP Bar Below Max Level'] = true;
L['Use Class Colors for XP Bar'] = true;
L['Show Tooltips'] = true;
L['Text on Right'] = true;
L['Currency Select'] = true;
L['First Currency'] = true;
L['Second Currency'] = true;
L['Third Currency'] = true;
L['Rested'] = true;

L['Show World Ping'] = true;
L['Number of Addons To Show'] = true;
L['Addons to Show in Tooltip'] = true;
L['Show All Addons in Tooltip with Shift'] = true;
L['Memory Usage'] = true;
L['Garbage Collect'] = true;
L['Cleaned'] = true;

L['Use Class Colors'] = true;
L['Cooldowns'] = true;
L['Toggle Profession Frame'] = true;
L['Toggle Profession Spellbook'] = true;

L['Set Specialization'] = true;
L['Set Loot Specialization'] = true;
L['Current Specialization'] = true;
L['Current Loot Specialization'] = true;
L['Talent Minimum Width'] = true;
L['Open Artifact'] = true;
L['Remaining'] = true;
L['Available Ranks'] = true;
L['Artifact Knowledge'] = true;
