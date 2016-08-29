local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------
if not cfg.heartstone.show then return end

local garrOnHover = false
local hsOnHover = false

local teleportFrame = CreateFrame("Frame",nil, cfg.SXframe)
teleportFrame:SetPoint("RIGHT",-4,0)
teleportFrame:SetSize(16, 16)
---------------------------------------------------------------------
local HSFrame = CreateFrame("BUTTON","hsButton", teleportFrame, "SecureActionButtonTemplate")
HSFrame:SetPoint("RIGHT")
HSFrame:SetSize(16, 16)
HSFrame:EnableMouse(true)
HSFrame:RegisterForClicks("AnyUp")
HSFrame:SetAttribute("type", "macro")

local HSText = HSFrame:CreateFontString(nil, "OVERLAY")
HSText:SetFont(cfg.text.font, cfg.text.normalFontSize)
HSText:SetPoint("RIGHT")
HSText:SetTextColor(unpack(cfg.color.normal))

local HSIcon = HSFrame:CreateTexture(nil,"OVERLAY",nil,7)
HSIcon:SetSize(16, 16)
HSIcon:SetPoint("RIGHT", HSText,"LEFT",-2,0)
HSIcon:SetTexture(cfg.mediaFolder.."datatexts\\hearth")
HSIcon:SetVertexColor(unpack(cfg.color.normal))

HSFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	HSIcon:SetVertexColor(unpack(cfg.color.hover))
	if not cfg.heartstone.showTooltip then return end
	local startTime, duration = GetItemCooldown(6948)
	if startTime ~= 0 then
		local CDremaining = (startTime+duration)-GetTime()
		GameTooltip:SetOwner(teleportFrame, cfg.tooltipPos)
		GameTooltip:AddDoubleLine("Cooldown",SecondsToTime(CDremaining),1,1,0,1,1,1)
		GameTooltip:Show()
	end
	hsOnHover = true
end)

HSFrame:SetScript("OnLeave", function()
	hsOnHover = false
	if IsUsableItem(6948) and GetItemCooldown(6948) == 0 or IsPlayerSpell(556) and GetSpellCooldown(556) == 0 then
		HSIcon:SetVertexColor(unpack(cfg.color.normal))
	else
		HSIcon:SetVertexColor(unpack(cfg.color.inactive))
	end
end)

-- Change the button action before the click reaches it:
function HSFrame:ChangeAction(action)
     if InCombatLockdown() then return end -- can't change attributes in combat
     self:SetAttribute("macrotext", action)
end

HSFrame:SetScript("PreClick", function(self)
     if InCombatLockdown() then return end -- can't change attributes in combat

     -- Innkeeper's Daughter
     if PlayerHasToy(64488) and GetItemCooldown(64488) == 0 then
          local itemName, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(64488)
          return self:ChangeAction("/use " .. itemName)

     -- Hearthstone
     elseif IsUsableItem(6948) and GetItemCooldown(6948) == 0 then
          local itemName, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(6948)
          return self:ChangeAction("/use " .. itemName)

     -- Astral Recall
     elseif IsPlayerSpell(556) and GetSpellCooldown(556) == 0 then
          local spellName, _, spellIcon = GetSpellInfo(556)
          return self:ChangeAction("/cast " .. spellName)
     end

     local playerLevel = UnitLevel("player")

     if playerLevel > 70 and IsUsableItem(44315) and GetItemCooldown(44315) == 0 then
          return self:SetAttribute("macrotext", "/use Scroll of Recall III")

     elseif playerLevel > 40 and IsUsableItem(44314) and GetItemCooldown(44314) == 0 then
          return self:SetAttribute("macrotext", "/use Scroll of Recall II")

     elseif playerLevel <= 39 and IsUsableItem(37118) and GetItemCooldown(37118) == 0 then
          return self:SetAttribute("macrotext", "/use Scroll of Recall")

     end
end)
---------------------------------------------------------------------
local garrisonFrame = CreateFrame("BUTTON","garrisonButton", teleportFrame, "SecureActionButtonTemplate")
garrisonFrame:SetPoint("LEFT")
garrisonFrame:SetSize(16, 16)
garrisonFrame:EnableMouse(true)
garrisonFrame:RegisterForClicks("AnyUp")
garrisonFrame:SetAttribute("*type1", "macro")

-- Change the button action before the click reaches it:
function garrisonFrame:ChangeAction(action)
     if InCombatLockdown() then return end -- can't change attributes in combat
     self:SetAttribute("macrotext", action)
end

garrisonFrame:SetScript("PreClick", function(self)
     if InCombatLockdown() then return end -- can't change attributes in combat

	 if IsShiftKeyDown() then
		if IsUsableItem(128353) and GetItemCooldown(128353) == 0 then
			local itemName, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(128353)
			return self:ChangeAction("/use " .. itemName)
		end
	else
		if IsUsableItem(110560) and GetItemCooldown(110560) == 0 then
			local itemName, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(110560)
			return self:ChangeAction("/use " .. itemName)
		end
	end
end)


local garrisonIcon = garrisonFrame:CreateTexture(nil,"OVERLAY",nil,7)
garrisonIcon:SetSize(16, 16)
garrisonIcon:SetPoint("LEFT")
garrisonIcon:SetTexture(cfg.mediaFolder.."datatexts\\garr")
garrisonIcon:SetVertexColor(unpack(cfg.color.normal))

local garrisonText = garrisonFrame:CreateFontString(nil, "OVERLAY")
garrisonText:SetFont(cfg.text.font, cfg.text.normalFontSize)
garrisonText:SetPoint("LEFT", garrisonIcon,"RIGHT",2,0)
garrisonText:SetText("GARRISON")
garrisonText:SetTextColor(unpack(cfg.color.normal))

garrisonFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	local startTime, duration = GetItemCooldown(110560)
	if startTime ~= 0 then
		local CDremaining = (startTime+duration)-GetTime()
		GameTooltip:SetOwner(teleportFrame, cfg.tooltipPos)
		GameTooltip:AddDoubleLine("Cooldown",SecondsToTime(CDremaining),1,1,0,1,1,1)
		GameTooltip:Show()
	end
	garrisonIcon:SetVertexColor(unpack(cfg.color.hover))
	garrOnHover = true
end)

garrisonFrame:SetScript("OnLeave", function()
	garrOnHover = false
	if IsUsableItem(110560) and GetItemCooldown(110560) == 0 then
		garrisonIcon:SetVertexColor(unpack(cfg.color.normal))
	else
		garrisonIcon:SetVertexColor(unpack(cfg.color.inactive))
	end
	GameTooltip:Hide()
end)

local function hsHover()
local startTime, duration = GetItemCooldown(6948)
	if startTime ~= 0 then
		local CDremaining = (startTime+duration)-GetTime()
		GameTooltip:SetOwner(teleportFrame, cfg.tooltipPos)
		GameTooltip:AddDoubleLine("Cooldown",SecondsToTime(CDremaining),1,1,0,1,1,1)
		GameTooltip:Show()
	end
	HSIcon:SetVertexColor(unpack(cfg.color.hover))
end

local function garrHover()
local startTime, duration = GetItemCooldown(110560)
	if startTime ~= 0 then
		local CDremaining = (startTime+duration)-GetTime()
		GameTooltip:SetOwner(teleportFrame, cfg.tooltipPos)
		GameTooltip:AddDoubleLine("Cooldown",SecondsToTime(CDremaining),1,1,0,1,1,1)
		GameTooltip:Show()
	end
	garrisonIcon:SetVertexColor(unpack(cfg.color.hover))
end

local function updateTeleportText()
local playerLevel = UnitLevel("player")
	if PlayerHasToy(64488) and GetItemCooldown(64488) == 0
	or IsUsableItem(6948) and GetItemCooldown(6948) == 0
	or IsPlayerSpell(556) and GetSpellCooldown(556) == 0
    or playerLevel > 70 and IsUsableItem(44315) and GetItemCooldown(44315) == 0
    or playerLevel > 40 and IsUsableItem(44314) and GetItemCooldown(44314) == 0
    or playerLevel <= 39 and IsUsableItem(37118) and GetItemCooldown(37118) == 0
	then
		HSIcon:SetVertexColor(unpack(cfg.color.normal))
		HSText:SetTextColor(unpack(cfg.color.normal))
	else
		HSIcon:SetVertexColor(unpack(cfg.color.inactive))
		HSText:SetTextColor(unpack(cfg.color.inactive))
	end

	if IsUsableItem(110560) and GetItemCooldown(110560) == 0 then
		garrisonIcon:SetVertexColor(unpack(cfg.color.normal))
		garrisonText:SetTextColor(unpack(cfg.color.normal))
	else
		garrisonIcon:SetVertexColor(unpack(cfg.color.inactive))
		garrisonText:SetTextColor(unpack(cfg.color.inactive))
	end
end

local elapsed = 0
teleportFrame:SetScript('OnUpdate', function(self, e)
	elapsed = elapsed + e
	if elapsed >= 1 then
		updateTeleportText()
		if garrOnHover then garrHover() end
		if hsOnHover then hsHover() end
		elapsed = 0
	end
end)

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("BAG_UPDATE")
eventframe:RegisterEvent("HEARTHSTONE_BOUND")
eventframe:RegisterEvent("MODIFIER_STATE_CHANGED")

eventframe:SetScript("OnEvent", function(this, event, arg1, arg2, arg3, arg4, ...)
if InCombatLockdown() then return end

HSText:SetText(strupper(GetBindLocation()))
HSFrame:SetSize(HSText:GetStringWidth()+16, 16)


if IsUsableItem(110560) then
	garrisonFrame:Show()
else
	garrisonFrame:Hide()
end

if event == "MODIFIER_STATE_CHANGED" then
	if arg1 == "LSHIFT" or arg1 == "RSHIFT" then
		if arg2 == 1 then
			if IsUsableItem(128353) then
				garrisonText:SetText("SHIPYARD")
				garrisonIcon:SetTexture(cfg.mediaFolder.."datatexts\\shipcomp")
			end
		elseif arg2 == 0 then
			garrisonText:SetText("GARRISON")
			garrisonIcon:SetTexture(cfg.mediaFolder.."datatexts\\garr")
		end
	end
end
	garrisonFrame:SetSize(garrisonText:GetStringWidth()+16, 16)
	teleportFrame:SetSize(HSFrame:GetWidth()+garrisonFrame:GetWidth()+8, 16)
end)
