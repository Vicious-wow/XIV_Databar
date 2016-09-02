local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------
if not cfg.micromenu.show then return end
---------------------------------------------
-- GAME MENU
---------------------------------------------

PlayerFrame.name:SetFont("Interface\\AddOns\\oUF_Drk\\media\\BigNoodleTitling.ttf", 11, "THINOUTLINE")
TargetFrame.name:SetFont("Interface\\AddOns\\oUF_Drk\\media\\BigNoodleTitling.ttf", 11, "THINOUTLINE")

local isBeautiful = IsAddOnLoaded("Blizzard_RaidUI") --!Beautycase check

if isBeautiful then
	subframes.name:SetFont("Interface\\AddOns\\oUF_Drk\\media\\BigNoodleTitling.ttf",11,"THINOUTLINE")
end


local gameMenuFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
gameMenuFrame:SetSize(32, 32)
gameMenuFrame:SetPoint("LEFT",2,0)
gameMenuFrame:EnableMouse(true)
gameMenuFrame:RegisterForClicks("AnyUp")
local gameMenuIcon = gameMenuFrame:CreateTexture(nil,"OVERLAY",nil,7)
gameMenuIcon:SetPoint("CENTER")
gameMenuIcon:SetTexture(cfg.mediaFolder.."microbar\\menu")
gameMenuIcon:SetVertexColor(unpack(cfg.color.normal))

gameMenuFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	gameMenuIcon:SetVertexColor(unpack(cfg.color.hover))
end)

gameMenuFrame:SetScript("OnLeave", function() gameMenuIcon:SetVertexColor(unpack(cfg.color.normal)) end)

gameMenuFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleFrame(GameMenuFrame)
	elseif button == "RightButton" then
		if IsShiftKeyDown() then ReloadUI()
		elseif IsAltKeyDown() then
			if cfg.useConfig then
				--if cfg.SXconfigFrame:IsShown() then
				ToggleFrame(cfg.SXconfigFrame)
				--else
				--ToggleFrame(cfg.SXconfigFrame)
				--end
			end
		else ToggleFrame(AddonList) end
	end
end)

---------------------------------------------
-- CHARACTER FRAME
---------------------------------------------

local characterFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
characterFrame:SetSize(32, 32)
characterFrame:SetPoint("LEFT",174,0)
characterFrame:EnableMouse(true)
characterFrame:RegisterForClicks("AnyUp")
local characterFrameIcon = characterFrame:CreateTexture(nil,"OVERLAY",nil,7)
characterFrameIcon:SetAllPoints()
characterFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\char")
characterFrameIcon:SetVertexColor(unpack(cfg.color.normal))

characterFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	characterFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

characterFrame:SetScript("OnLeave", function() characterFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

characterFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleCharacter("PaperDollFrame")
	end
end)

---------------------------------------------
-- SPELLS
---------------------------------------------

local spellFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
spellFrame:SetSize(32, 32)
spellFrame:SetPoint("LEFT",characterFrame,"RIGHT",4,0)
spellFrame:EnableMouse(true)
spellFrame:RegisterForClicks("AnyUp")
local spellFrameIcon = spellFrame:CreateTexture(nil,"OVERLAY",nil,7)
spellFrameIcon:SetSize(32,32)
spellFrameIcon:SetPoint("CENTER")
spellFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\spell")
spellFrameIcon:SetVertexColor(unpack(cfg.color.normal))

spellFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	spellFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

spellFrame:SetScript("OnLeave", function() spellFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

spellFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleFrame(SpellBookFrame)
	end
end)

---------------------------------------------
-- TALENT
---------------------------------------------

local talentFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
talentFrame:SetSize(32, 32)
talentFrame:SetPoint("LEFT",spellFrame,"RIGHT",4,0)
talentFrame:EnableMouse(true)
talentFrame:RegisterForClicks("AnyUp")
local talentFrameIcon = talentFrame:CreateTexture(nil,"OVERLAY",nil,7)
talentFrameIcon:SetSize(32,32)
talentFrameIcon:SetPoint("CENTER")
talentFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\talent")
talentFrameIcon:SetVertexColor(unpack(cfg.color.normal))

talentFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	talentFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

talentFrame:SetScript("OnLeave", function() talentFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

talentFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		TalentMicroButton:Click()
	end
end)

---------------------------------------------
-- ACHIV
---------------------------------------------

local achievementFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
achievementFrame:SetSize(32, 32)
achievementFrame:SetPoint("LEFT",talentFrame,"RIGHT",4,0)
achievementFrame:EnableMouse(true)
achievementFrame:RegisterForClicks("AnyUp")
local achievementFrameIcon = achievementFrame:CreateTexture(nil,"OVERLAY",nil,7)
achievementFrameIcon:SetSize(32,32)
achievementFrameIcon:SetPoint("CENTER")
achievementFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\ach")
achievementFrameIcon:SetVertexColor(unpack(cfg.color.normal))

achievementFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	achievementFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

achievementFrame:SetScript("OnLeave", function() achievementFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

achievementFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		securecall(ToggleAchievementFrame)
	end
end)

---------------------------------------------
-- QUEST
---------------------------------------------

local questFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
questFrame:SetSize(32, 32)
questFrame:SetPoint("LEFT",achievementFrame,"RIGHT",4,0)
questFrame:EnableMouse(true)
questFrame:RegisterForClicks("AnyUp")
local questFrameIcon = questFrame:CreateTexture(nil,"OVERLAY",nil,7)
questFrameIcon:SetSize(32,32)
questFrameIcon:SetPoint("CENTER")
questFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\quest")
questFrameIcon:SetVertexColor(unpack(cfg.color.normal))

questFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	questFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

questFrame:SetScript("OnLeave", function() questFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

questFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		QuestLogMicroButton:Click()
	end
end)

---------------------------------------------
-- LFG
---------------------------------------------

local lfgFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
lfgFrame:SetSize(32, 32)
lfgFrame:SetPoint("LEFT",questFrame,"RIGHT",4,0)
lfgFrame:EnableMouse(true)
lfgFrame:RegisterForClicks("AnyUp")
local lfgFrameIcon = lfgFrame:CreateTexture(nil,"OVERLAY",nil,7)
lfgFrameIcon:SetSize(32,32)
lfgFrameIcon:SetPoint("CENTER")
lfgFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\lfg")
lfgFrameIcon:SetVertexColor(unpack(cfg.color.normal))

lfgFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	lfgFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

lfgFrame:SetScript("OnLeave", function() lfgFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

lfgFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		securecall(PVEFrame_ToggleFrame, 'GroupFinderFrame')
	end
end)

---------------------------------------------
-- ADVENTURE GUIDE
---------------------------------------------

local adventureFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
adventureFrame:SetSize(32, 32)
adventureFrame:SetPoint("LEFT",lfgFrame,"RIGHT",4,0)
adventureFrame:EnableMouse(true)
adventureFrame:RegisterForClicks("AnyUp")
local adventureFrameIcon = adventureFrame:CreateTexture(nil,"OVERLAY",nil,7)
adventureFrameIcon:SetSize(32,32)
adventureFrameIcon:SetPoint("CENTER")
adventureFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\journal")
adventureFrameIcon:SetVertexColor(unpack(cfg.color.normal))

adventureFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	adventureFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

adventureFrame:SetScript("OnLeave", function() adventureFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

adventureFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		EJMicroButton:Click()
	end
end)

---------------------------------------------
-- PvP
---------------------------------------------

local pvpFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
pvpFrame:SetSize(32, 32)
pvpFrame:SetPoint("LEFT",adventureFrame,"RIGHT",4,0)
pvpFrame:EnableMouse(true)
pvpFrame:RegisterForClicks("AnyUp")
local pvpFrameIcon = pvpFrame:CreateTexture(nil,"OVERLAY",nil,7)
pvpFrameIcon:SetSize(32,32)
pvpFrameIcon:SetPoint("CENTER")
pvpFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\pvp")
pvpFrameIcon:SetVertexColor(unpack(cfg.color.normal))

pvpFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	pvpFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

pvpFrame:SetScript("OnLeave", function() pvpFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

pvpFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		securecall(PVEFrame_ToggleFrame, 'PVPUIFrame', HonorFrame)
	end
end)

---------------------------------------------
-- MOUNTS
---------------------------------------------

local mountFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
mountFrame:SetSize(32, 32)
mountFrame:SetPoint("LEFT",pvpFrame,"RIGHT",4,0)
mountFrame:EnableMouse(true)
mountFrame:RegisterForClicks("AnyUp")
local mountFrameIcon = mountFrame:CreateTexture(nil,"OVERLAY",nil,7)
mountFrameIcon:SetSize(32,32)
mountFrameIcon:SetPoint("CENTER")
mountFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\pet")
mountFrameIcon:SetVertexColor(unpack(cfg.color.normal))

mountFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	mountFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

mountFrame:SetScript("OnLeave", function() mountFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

mountFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		securecall(ToggleCollectionsJournal, 1)
	end
end)

---------------------------------------------
-- SHOP
---------------------------------------------

local shopFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
shopFrame:SetSize(32, 32)
shopFrame:SetPoint("LEFT",mountFrame,"RIGHT",4,0)
shopFrame:EnableMouse(true)
shopFrame:RegisterForClicks("AnyUp")
local shopFrameIcon = shopFrame:CreateTexture(nil,"OVERLAY",nil,7)
shopFrameIcon:SetSize(32,32)
shopFrameIcon:SetPoint("CENTER")
shopFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\shop")
shopFrameIcon:SetVertexColor(unpack(cfg.color.normal))

shopFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	shopFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

shopFrame:SetScript("OnLeave", function() shopFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

shopFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		StoreMicroButton:Click()
	end
end)

---------------------------------------------
-- HELP
---------------------------------------------

local helpFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
helpFrame:SetSize(32, 32)
helpFrame:SetPoint("LEFT",shopFrame,"RIGHT",4,0)
helpFrame:EnableMouse(true)
helpFrame:RegisterForClicks("AnyUp")
local helpFrameIcon = helpFrame:CreateTexture(nil,"OVERLAY",nil,7)
helpFrameIcon:SetSize(32,32)
helpFrameIcon:SetPoint("CENTER")
helpFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\help")
helpFrameIcon:SetVertexColor(unpack(cfg.color.normal))

helpFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	helpFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

helpFrame:SetScript("OnLeave", function() helpFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

helpFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		securecall(ToggleHelpFrame)
	end
end)
