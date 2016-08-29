local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------
if not cfg.talent.show then return end

local currentSpec = 0 -- from 1-4
local currentSpecID, currentSpecName = 0,0 --global id
local lootspecid = 0
local id, name = 0,0

local talentFrame = CreateFrame("Frame",'SX_TalentFrame', cfg.SXframe)
talentFrame:SetPoint("RIGHT", cfg.SXframe, "CENTER", -110,0)
talentFrame:SetSize(16, 16)
---------------------------------------------
-- LOOTSPEC FRAME
---------------------------------------------
local lootSpecFrame = CreateFrame("BUTTON",'SX_LootSpecFrame', talentFrame)
if cfg.core.position ~= "BOTTOM" then
	lootSpecFrame:SetPoint("TOP", talentFrame, "BOTTOM", 0,-6)
else
	lootSpecFrame:SetPoint("BOTTOM", talentFrame, "TOP", 0,8)
end
lootSpecFrame:RegisterForClicks("AnyUp")
lootSpecFrame:Hide()
lootSpecFrame:EnableMouse(true)

lootSpecFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "RightButton" then
		lootSpecFrame:Hide()
	end
end)

local lootSpecText = lootSpecFrame:CreateFontString(nil, "OVERLAY")
lootSpecText:SetFont(cfg.text.font, cfg.text.normalFontSize)
lootSpecText:SetPoint("TOP")
lootSpecText:SetText("LOOT SPECIALIZATION")
lootSpecText:SetTextColor(unpack(cfg.color.normal))

local defaultLootTypeButton = CreateFrame("BUTTON",nil, lootSpecFrame)
defaultLootTypeButton:SetSize(lootSpecText:GetStringWidth(),cfg.text.normalFontSize)
defaultLootTypeButton:SetPoint("CENTER",lootSpecText)
defaultLootTypeButton:EnableMouse(true)
defaultLootTypeButton:RegisterForClicks("AnyUp")

defaultLootTypeButton:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		if GetLootSpecialization() ~= 0 then
			SetLootSpecialization(0)
			print("|cffffff00Loot Specialization set to: Current Specialization")
			lootSpecFrame:Hide()
		end
	elseif button == "RightButton" then
		lootSpecFrame:Hide()
	end
end)

local lootSpectBG = lootSpecFrame:CreateTexture(nil,"OVERLAY",nil,7)
lootSpectBG:SetPoint("TOP")
lootSpectBG:SetColorTexture(unpack(cfg.color.barcolor))
globalLootSpecFrame = lootSpecFrame

---------------------------------------------
-- SPEC CHANGE FRAME
---------------------------------------------
local specFrame = CreateFrame("BUTTON",'SX_SpecFrame', talentFrame)
if cfg.core.position ~= "BOTTOM" then
	specFrame:SetPoint("TOP", talentFrame, "BOTTOM", 0,-6)
else
	specFrame:SetPoint("BOTTOM", talentFrame, "TOP", 0,8)
end
specFrame:RegisterForClicks("AnyUp")
specFrame:Hide()
specFrame:EnableMouse(true)

specFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "RightButton" then
		specFrame:Hide()
	end
end)

local specText = specFrame:CreateFontString(nil, "OVERLAY")
specText:SetFont(cfg.text.font, cfg.text.normalFontSize)
specText:SetPoint("TOP")
specText:SetText("SET SPECIALIZATION")
specText:SetTextColor(unpack(cfg.color.normal))

local specBG = specFrame:CreateTexture(nil,"OVERLAY",nil,7)
specBG:SetPoint("TOP")
specBG:SetColorTexture(unpack(cfg.color.barcolor))
globalSpecFrame = specFrame

---------------------------------------------
-- PRIMARY SPEC FRAME
---------------------------------------------

local primarySpecFrame = CreateFrame("BUTTON",nil, talentFrame)
primarySpecFrame:SetPoint("RIGHT")
primarySpecFrame:SetSize(16, 16)
primarySpecFrame:EnableMouse(true)
primarySpecFrame:RegisterForClicks("AnyUp")

local primarySpecText = primarySpecFrame:CreateFontString(nil, "OVERLAY")
primarySpecText:SetFont(cfg.text.font, cfg.text.normalFontSize)
primarySpecText:SetPoint("RIGHT")
primarySpecText:SetTextColor(unpack(cfg.color.normal))

local primarySpecIcon = primarySpecFrame:CreateTexture(nil,"OVERLAY",nil,7)
primarySpecIcon:SetSize(16, 16)
primarySpecIcon:SetPoint("RIGHT", primarySpecText,"LEFT",-2,0)
primarySpecIcon:SetVertexColor(unpack(cfg.color.normal))

primarySpecFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	GameTooltip:SetOwner(talentFrame, cfg.tooltipPos)
	currentSpec = GetSpecialization()
	currentSpecID, currentSpecName = GetSpecializationInfo(currentSpec)
	lootspecid = GetLootSpecialization()
	if lootspecid == 0 then lootspecid = currentSpecID end
	id, name = GetSpecializationInfoByID(lootspecid)
	GameTooltip:AddLine("|cffffffffLoot is currently set to |cffffff00"..name.."|cffffffff spec")
	GameTooltip:AddDoubleLine("<Left-Click>", "Change spec", 1, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("<Right-Click>", "Change lootspec", 1, 1, 0, 1, 1, 1)
	primarySpecIcon:SetVertexColor(unpack(cfg.color.hover))
	GameTooltip:Show()
end)

primarySpecFrame:SetScript("OnLeave", function()
	if GetActiveSpecGroup() == 1 then
		primarySpecIcon:SetVertexColor(unpack(cfg.color.normal))
	else
		primarySpecIcon:SetVertexColor(unpack(cfg.color.inactive))
	end
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
end)

primarySpecFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		if globalSpecFrame:IsShown() then
			globalSpecFrame:Hide()
		else
			if globalLootSpecFrame:IsShown() then
				globalLootSpecFrame:Hide()
			end
			globalSpecFrame:Show()
		end
	elseif button == "RightButton" then
		if globalLootSpecFrame:IsShown() then
			globalLootSpecFrame:Hide()
		else
			if globalSpecFrame:IsShown() then
				globalSpecFrame:Hide()
			end
			globalLootSpecFrame:Show()
		end
	end
end)
---------------------------------------------------------------------

local function createLootSpecButtons()
for index = 1,4 do
	local id, name = GetSpecializationInfo(index)
	if ( name ) then
		lootSpecFrame:SetSize(lootSpecText:GetStringWidth()+16, (index+1)*18)
		lootSpectBG:SetSize(lootSpecFrame:GetSize())
		currentSpecID, currentSpecName = GetSpecializationInfo(index)

		local lootSpecButton = CreateFrame("BUTTON",nil, lootSpecFrame)
		lootSpecButton:SetPoint("TOPLEFT", lootSpecText, 0, index*-18)
		lootSpecButton:SetSize(16, 16)
		lootSpecButton:EnableMouse(true)
		lootSpecButton:RegisterForClicks("AnyUp")


		local lootSpecbuttonText = lootSpecButton:CreateFontString(nil, "OVERLAY")
		lootSpecbuttonText:SetFont(cfg.text.font, cfg.text.smallFontSize)
		lootSpecbuttonText:SetPoint("RIGHT")
		if currentSpecName then currentSpecName = string.upper(currentSpecName) end
		lootSpecbuttonText:SetText(currentSpecName)

		local lootSpecbuttonIcon = lootSpecButton:CreateTexture(nil,"OVERLAY",nil,7)
		lootSpecbuttonIcon:SetSize(16, 16)
		lootSpecbuttonIcon:SetPoint("LEFT")
		lootSpecbuttonIcon:SetTexture(cfg.mediaFolder.."spec\\"..cfg.CLASS)
		lootSpecbuttonIcon:SetTexCoord(unpack(cfg.specCoords[index]))

		local id = GetSpecializationInfo(index)
		if GetLootSpecialization() == id then
			lootSpecbuttonText:SetTextColor(unpack(cfg.color.normal))
			lootSpecbuttonIcon:SetVertexColor(unpack(cfg.color.normal))
		else
			lootSpecbuttonText:SetTextColor(unpack(cfg.color.inactive))
			lootSpecbuttonIcon:SetVertexColor(unpack(cfg.color.inactive))
		end
		lootSpecButton:SetSize(lootSpecbuttonText:GetStringWidth()+18,16)

		lootSpecButton:SetScript("OnEnter", function() if InCombatLockdown() then return end lootSpecbuttonIcon:SetVertexColor(unpack(cfg.color.hover)) end)
		lootSpecButton:SetScript("OnLeave", function()
			local id = GetSpecializationInfo(index)
			if GetLootSpecialization() == id then
				lootSpecbuttonText:SetTextColor(unpack(cfg.color.normal))
				lootSpecbuttonIcon:SetVertexColor(unpack(cfg.color.normal))
			else
				lootSpecbuttonText:SetTextColor(unpack(cfg.color.inactive))
				lootSpecbuttonIcon:SetVertexColor(unpack(cfg.color.inactive))
			end
		end)

		lootSpecButton:SetScript("OnClick", function(self, button, down)
			if InCombatLockdown() then return end
			if button == "LeftButton" then
				if IsShiftKeyDown() then
					SetSpecialization(index)
				else
					local id = GetSpecializationInfo(index)
					SetLootSpecialization(id)
					lootSpecbuttonText:SetTextColor(unpack(cfg.color.normal))
					lootSpecbuttonIcon:SetVertexColor(unpack(cfg.color.normal))
				end
				lootSpecFrame:Hide()
			elseif button == "RightButton" then
				lootSpecFrame:Hide()
			end
		end)
	end
end
end

---------------------------------------------------------------------

local function createSpecButtons()
	local curSpec = GetSpecialization()
	for index = 1,GetNumSpecializations() do
		local id, name = GetSpecializationInfo(index)
		if ( name ) then
			specFrame:SetSize(specText:GetStringWidth()+16, (index+1)*18)
			specBG:SetSize(specFrame:GetSize())
			currentSpecID, currentSpecName = GetSpecializationInfo(index)

			local specButton = CreateFrame("BUTTON",nil, specFrame)
			specButton:SetPoint("TOPLEFT", specText, 0, index*-18)
			specButton:SetSize(16, 16)
			specButton:EnableMouse(true)
			specButton:RegisterForClicks("AnyUp")

			local specButtonText = specButton:CreateFontString(nil, "OVERLAY")
			specButtonText:SetFont(cfg.text.font, cfg.text.smallFontSize)
			specButtonText:SetPoint("RIGHT")
			if currentSpecName then currentSpecName = string.upper(currentSpecName) end
			specButtonText:SetText(currentSpecName)

			local specButtonIcon = specButton:CreateTexture(nil,"OVERLAY",nil,7)
			specButtonIcon:SetSize(16, 16)
			specButtonIcon:SetPoint("LEFT")
			specButtonIcon:SetTexture(cfg.mediaFolder.."spec\\"..cfg.CLASS)
			specButtonIcon:SetTexCoord(unpack(cfg.specCoords[index]))

			--local id = GetSpecializationInfo(index)
			if GetSpecialization() == index then
				specButtonText:SetTextColor(unpack(cfg.color.normal))
				specButtonIcon:SetVertexColor(unpack(cfg.color.normal))
			else
				specButtonText:SetTextColor(unpack(cfg.color.inactive))
				specButtonIcon:SetVertexColor(unpack(cfg.color.inactive))
			end
			specButton:SetSize(specButtonText:GetStringWidth()+18,16)

			specButton:SetScript("OnEnter", function() if InCombatLockdown() then return end specButtonIcon:SetVertexColor(unpack(cfg.color.hover)) end)
			specButton:SetScript("OnLeave", function()
				local id = GetSpecializationInfo(index)
				if GetSpecialization() == id then
					specButtonText:SetTextColor(unpack(cfg.color.normal))
					specButtonIcon:SetVertexColor(unpack(cfg.color.normal))
				else
					specButtonText:SetTextColor(unpack(cfg.color.inactive))
					specButtonIcon:SetVertexColor(unpack(cfg.color.inactive))
				end
			end)

			specButton:SetScript("OnClick", function(self, button, down)
				if InCombatLockdown() then return end
				if button == "LeftButton" then
					SetSpecialization(index)
					specFrame:Hide()
				elseif button == "RightButton" then
					specFrame:Hide()
				end
			end)
		end
	end
end

---------------------------------------------
-- EVENTS
---------------------------------------------

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
eventframe:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventframe:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
eventframe:RegisterEvent("PLAYER_REGEN_DISABLED")

eventframe:SetScript("OnEvent", function(self,event, ...)
	if event == ("PLAYER_ENTERING_WORLD") then
		createSpecButtons()
		createLootSpecButtons()
	end
	if event == ("PLAYER_REGEN_DISABLED") then
		if lootSpecFrame:IsShown() then
			lootSpecFrame:Hide()
		end
		if specFrame:IsShown() then
			specFrame:Hide()
		end
	end

	local primarySpec = GetSpecialization(false, false, 1)
	if primarySpec ~= nil then
		local id, name = GetSpecializationInfo(primarySpec)
		if name then name = string.upper(name) end
		--name = string.upper(name)
		primarySpecText:SetText(name)
		primarySpecIcon:SetTexture(cfg.mediaFolder.."spec\\"..cfg.CLASS)
		primarySpecIcon:SetTexCoord(unpack(cfg.specCoords[primarySpec]))
		primarySpecFrame:SetSize(primarySpecText:GetStringWidth()+18, 16)
		primarySpecFrame:Show()
		primarySpecFrame:EnableMouse(true)
	else
		primarySpecFrame:Hide()
		primarySpecFrame:EnableMouse(false)
	end
	primarySpecIcon:SetVertexColor(unpack(cfg.color.normal))
	primarySpecText:SetTextColor(unpack(cfg.color.normal))
	talentFrame:SetSize((primarySpecFrame:GetWidth()), 16)
end)
