local AddOnName, Engine = ...;
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale(AddOnName, "enUS", true, false);

L['General'] = true;
L['Text'] = true;

L['Modules'] = true;

-- General
L['Bar Position'] = true;
L['Top'] = true;
L['Bottom'] = true;
L['Bar Color'] = true;

-- Media
L['Font'] = true;
L['Font Size'] = true;
L['Small Font Size'] = true;

-- Text Colors
L['Text Colors'] = true;
L['Normal'] = true;
L['Inactive'] = true;
L['Use Class Colors for Hover'] = true;
L['Hover'] = true;




-------------------- MODULES ---------------------------
L['Test Module'] = true;

L['Micromenu'] = true;
L['Show Social Tooltips'] = true;
L['Main Menu Icon Right Spacing'] = true;
L['Icon Spacing'] = true;
