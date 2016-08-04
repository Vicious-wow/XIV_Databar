local AddOnName, Engine = ...;
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale(AddOnName, "enUS", true, true);
if not L then return; end

L['Test'] = true;
L['Profiles'] = true;
L['Modules'] = true;
