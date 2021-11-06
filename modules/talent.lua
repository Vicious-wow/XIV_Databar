local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local TalentModule = xb:NewModule("TalentModule", 'AceEvent-3.0')

function TalentModule:GetName()
  return TALENTS;
end

-- Skin Support for ElvUI/TukUI
-- Make sure to disable "Tooltip" in the Skins section of ElvUI together with
-- unchecking "Use ElvUI for tooltips" in XIV options to not have ElvUI fuck with tooltips
function TalentModule:SkinFrame(frame, name)
	if self.useElvUI then
		if frame.StripTextures then
			frame:StripTextures()
		end
		if frame.SetTemplate then
			frame:SetTemplate("Transparent")
		end

		local close = _G[name.."CloseButton"] or frame.CloseButton
		if close and close.SetAlpha then
			if ElvUI then
				ElvUI[1]:GetModule('Skins'):HandleCloseButton(close)
			end

			if Tukui and Tukui[1] and Tukui[1].SkinCloseButton then
				Tukui[1].SkinCloseButton(close)
			end
			close:SetAlpha(1)
		end
	end
end

function TalentModule:OnInitialize()
  self.LTip=LibStub('LibQTip-1.0')
  self.currentSpecID = 0
  self.currentLootSpecID = 0
  self.specCoords = {
    [1] = { 0.00, 0.25, 0, 1 },
    [2] = { 0.25, 0.50, 0, 1 },
    [3] = { 0.50, 0.75, 0, 1 },
    [4] = { 0.75, 1.00, 0, 1 }
  }
  self.extraPadding = (xb.constants.popupPadding * 3)
  self.optionTextExtra = 4
  self.specButtons = {}
  self.lootSpecButtons = {}
  self.classIcon = xb.constants.mediaPath..'spec\\'..xb.constants.playerClass
  self.useElvUI = xb.db.profile.general.useElvUI and (IsAddOnLoaded('ElvUI') or IsAddOnLoaded('Tukui'))
end

function TalentModule:OnEnable()
  if not xb.db.profile.modules.talent.enabled then self:Disable() return end
  self.currentSpecID = GetSpecialization() --returns 5 for newly created characters in shadowlands
  if self.currentSpecID == 5 then self:Disable() return end
  self.currentLootSpecID = GetLootSpecialization()
  if self.talentFrame == nil then
    self.talentFrame = CreateFrame("FRAME", "talentFrame", xb:GetFrame('bar'))
    xb:RegisterFrame('talentFrame', self.talentFrame)
  end
  self.talentFrame:Show()

  self:CreateFrames()
  self:RegisterFrameEvents()
  self:Refresh()
end

function TalentModule:OnDisable()
  if self.talentFrame and self.talentFrame:IsVisible() then
	self.talentFrame:Hide()
  end
  self:UnregisterEvent('TRADE_SKILL_UPDATE')
  self:UnregisterEvent('SPELLS_CHANGED')
  self:UnregisterEvent('UNIT_SPELLCAST_STOP')
  self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED')
  self:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
  self:UnregisterEvent('PLAYER_LOOT_SPEC_UPDATED')
end

function TalentModule:Refresh()
  if InCombatLockdown() then return end

  local db = xb.db.profile
  if self.talentFrame == nil then return end
  if not db.modules.talent.enabled then self:Disable() return end

  self.currentSpecID = GetSpecialization()
  self.currentLootSpecID = GetLootSpecialization()

  local iconSize = db.text.fontSize + db.general.barPadding
  local _, name, _ = GetSpecializationInfo(self.currentSpecID)
  local textHeight = db.text.fontSize

  self.specIcon:SetTexture(self.classIcon)
  self.specIcon:SetTexCoord(unpack(self.specCoords[self.currentSpecID]))

  self.specIcon:SetSize(iconSize, iconSize)
  self.specIcon:SetPoint('LEFT')
  self.specIcon:SetVertexColor(xb:GetColor('normal'))

  self.specText:SetFont(xb:GetFont(textHeight))
  self.specText:SetTextColor(xb:GetColor('normal'))
  self.specText:SetText(string.upper(name or ""))

  self.specText:SetPoint('LEFT', self.specIcon, 'RIGHT', 5, 0)

  self.lootSpecButtons[0].icon:SetTexture(self.classIcon)
  self.lootSpecButtons[0].icon:SetTexCoord(unpack(self.specCoords[self.currentSpecID]))

  self.specText:Show()

	self.specFrame:SetSize(iconSize + self.specText:GetWidth() + 5, xb:GetHeight())
  self.specFrame:SetPoint('LEFT')

  if self.specFrame:GetWidth() < db.modules.talent.minWidth then
    self.specFrame:SetWidth(db.modules.talent.minWidth)
  end

  self.talentFrame:SetSize(self.specFrame:GetWidth(), xb:GetHeight())
  local relativeAnchorPoint = 'LEFT'
  local xOffset = db.general.moduleSpacing
  local anchorFrame = xb:GetFrame('clockFrame')
  if not anchorFrame:IsVisible() and not db.modules.clock.enabled then
    if xb:GetFrame('tradeskillFrame'):IsVisible() then
      anchorFrame = xb:GetFrame('tradeskillFrame')
    elseif xb:GetFrame('currencyFrame'):IsVisible() then
      anchorFrame = xb:GetFrame('currencyFrame')
    else
      relativeAnchorPoint = 'RIGHT'
      xOffset = 0
    end
  end
  self.talentFrame:SetPoint('RIGHT', anchorFrame, relativeAnchorPoint, -(xOffset), 0)
  self:CreateSpecPopup()
  self:CreateLootSpecPopup()
end

function TalentModule:CreateFrames()
  self.specFrame = self.specFrame or CreateFrame('BUTTON', nil, self.talentFrame, 'SecureActionButtonTemplate')
  self.specIcon = self.specIcon or self.specFrame:CreateTexture(nil, 'OVERLAY')
  self.specText = self.specText or self.specFrame:CreateFontString(nil, 'OVERLAY')

  self.specPopup = self.specPopup or CreateFrame('BUTTON', 'SpecPopup', self.specFrame, BackdropTemplateMixin and 'BackdropTemplate')
  self.specPopup:SetFrameStrata('TOOLTIP')
  self.lootSpecPopup = self.lootSpecPopup or CreateFrame('BUTTON', 'LootPopup', self.specFrame, BackdropTemplateMixin and 'BackdropTemplate')
  self.lootSpecPopup:SetFrameStrata('TOOLTIP')

  local backdrop = TooltipBackdropTemplateMixin:GetBackdrop()
  if backdrop and (not self.useElvUI) then
    self.specPopup:SetBackdrop(backdrop)
    self.specPopup:SetBackdropColor(GameTooltip:GetBackdropColor())
    self.specPopup:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
    self.lootSpecPopup:SetBackdrop(backdrop)
    self.lootSpecPopup:SetBackdropColor(GameTooltip:GetBackdropColor())
    self.lootSpecPopup:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
  end

  self:CreateSpecPopup()
  self:CreateLootSpecPopup()
end

function TalentModule:RegisterFrameEvents()
  self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'Refresh')
  self:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', 'Refresh')
  self:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED', 'Refresh')

  self.specFrame:EnableMouse(true)
  self.specFrame:RegisterForClicks('AnyUp')

  self.specFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return end
    self.specText:SetTextColor(unpack(xb:HoverColors()))
    if xb.db.profile.modules.talent.showTooltip then
      if (not self.specPopup:IsVisible()) or (not self.lootSpecPopup:IsVisible()) then
        self:ShowTooltip()
      end
    end
  end)

  self.specFrame:SetScript('OnLeave', function()
    if InCombatLockdown() then return end
    local db = xb.db.profile
    self.specText:SetTextColor(xb:GetColor('normal'))
    if xb.db.profile.modules.talent.showTooltip then
      if self.LTip:IsAcquired("TalentTooltip") then
		    self.LTip:Release(self.LTip:Acquire("TalentTooltip"))
	    end
    end
  end)

  self.specFrame:SetScript('OnClick', function(_, button)
    if self.LTip:IsAcquired("TalentTooltip") then
	    self.LTip:Release(self.LTip:Acquire("TalentTooltip"))
    end

    if InCombatLockdown() then return end

    if button == 'LeftButton' then
      if not self.specPopup:IsVisible() then
        self.lootSpecPopup:Hide()
        self:CreateSpecPopup()
        self.specPopup:Show()
      else
        self.specPopup:Hide()
        if xb.db.profile.modules.talent.showTooltip then self:ShowTooltip() end
      end
    elseif button == 'RightButton' then
      if not self.lootSpecPopup:IsVisible() then
        self.specPopup:Hide()
        self:CreateLootSpecPopup()
        self.lootSpecPopup:Show()
      else
        self.lootSpecPopup:Hide()
        if xb.db.profile.modules.talent.showTooltip then self:ShowTooltip() end
      end
    end
  end)

  self:RegisterMessage('XIVBar_FrameHide', function(_, name)
    if name == 'clockFrame' then
      self:Refresh()
    end
  end)

  self:RegisterMessage('XIVBar_FrameShow', function(_, name)
    if name == 'clockFrame' then
      self:Refresh()
    end
  end)
end

function TalentModule:CreateSpecPopup()
  if not self.specPopup then return; end

  local db = xb.db.profile
  local iconSize = db.text.fontSize + db.general.barPadding
  self.specOptionString = self.specOptionString or self.specPopup:CreateFontString(nil, 'OVERLAY')
  self.specOptionString:SetFont(xb:GetFont(db.text.fontSize + self.optionTextExtra))
  local r, g, b, _ = unpack(xb:HoverColors())
  self.specOptionString:SetTextColor(r, g, b, 1)
  self.specOptionString:SetText(L['Set Specialization'])
  self.specOptionString:SetPoint('TOP', 0, -(xb.constants.popupPadding))
  self.specOptionString:SetPoint('CENTER')

  local popupWidth = self.specPopup:GetWidth()
  local popupHeight = xb.constants.popupPadding + db.text.fontSize + self.optionTextExtra
  local changedWidth = false
  for i = 1, GetNumSpecializations() do
    if self.specButtons[i] == nil then

      local _, name, _ = GetSpecializationInfo(i)
      local button = CreateFrame('BUTTON', nil, self.specPopup)
      local buttonText = button:CreateFontString(nil, 'OVERLAY')
      local buttonIcon = button:CreateTexture(nil, 'OVERLAY')

      buttonIcon:SetTexture(self.classIcon)
      buttonIcon:SetTexCoord(unpack(self.specCoords[i]))
      buttonIcon:SetSize(iconSize, iconSize)
      buttonIcon:SetPoint('LEFT')
      buttonIcon:SetVertexColor(xb:GetColor('normal'))

      buttonText:SetFont(xb:GetFont(db.text.fontSize))
      buttonText:SetTextColor(xb:GetColor('normal'))
      buttonText:SetText(name)
      buttonText:SetPoint('LEFT', buttonIcon, 'RIGHT', 5, 0)
      local textWidth = iconSize + 5 + buttonText:GetStringWidth()

      button:SetID(i)
      button:SetSize(textWidth, iconSize)
      button.isSettable = true

      button:EnableMouse(true)
      button:RegisterForClicks('AnyUp')

      button:SetScript('OnEnter', function()
        buttonText:SetTextColor(r, g, b, 1)
      end)

      button:SetScript('OnLeave', function()
        buttonText:SetTextColor(xb:GetColor('normal'))
      end)

      button:SetScript('OnClick', function(self, button)
        if InCombatLockdown() then return; end
        if button == 'LeftButton' then
          SetSpecialization(self:GetID())
        end
        TalentModule.specPopup:Hide()
      end)

      self.specButtons[i] = button

      if textWidth > popupWidth then
        popupWidth = textWidth
        changedWidth = true
      end
    end -- if nil
  end -- for ipairs portOptions
  for portId, button in pairs(self.specButtons) do
    if button.isSettable then
      button:SetPoint('LEFT', xb.constants.popupPadding, 0)
      button:SetPoint('TOP', 0, -(popupHeight + xb.constants.popupPadding))
      button:SetPoint('RIGHT')
      popupHeight = popupHeight + xb.constants.popupPadding + db.text.fontSize
    else
      button:Hide()
    end
  end -- for id/button in portButtons
  if changedWidth then
    popupWidth = popupWidth + self.extraPadding
  end

  if popupWidth < self.specFrame:GetWidth() then
    popupWidth = self.specFrame:GetWidth()
  end

  if popupWidth < (self.specOptionString:GetStringWidth()  + self.extraPadding) then
    popupWidth = (self.specOptionString:GetStringWidth()  + self.extraPadding)
  end
  self.specPopup:SetSize(popupWidth, popupHeight + xb.constants.popupPadding)

  local popupPadding = xb.constants.popupPadding
  if db.general.barPosition == 'TOP' then
    popupPadding = -(popupPadding)
  end

  self.specPopup:ClearAllPoints()
  self.specPopup:SetPoint(db.general.barPosition, self.specFrame, xb.miniTextPosition, 0, 0)
  self:SkinFrame(self.specPopup, "SpecToolTip")
  self.specPopup:Hide()
end

function TalentModule:CreateLootSpecPopup()
  if not self.lootSpecPopup then return; end

  local db = xb.db.profile
  local iconSize = db.text.fontSize + db.general.barPadding
  self.lootSpecOptionString = self.lootSpecOptionString or self.lootSpecPopup:CreateFontString(nil, 'OVERLAY')
  self.lootSpecOptionString:SetFont(xb:GetFont(db.text.fontSize + self.optionTextExtra))
  local r, g, b, _ = unpack(xb:HoverColors())
  self.lootSpecOptionString:SetTextColor(r, g, b, 1)
  self.lootSpecOptionString:SetText(L['Set Loot Specialization'])
  self.lootSpecOptionString:SetPoint('TOP', 0, -(xb.constants.popupPadding))
  self.lootSpecOptionString:SetPoint('CENTER')

  local popupWidth = self.lootSpecPopup:GetWidth()
  local popupHeight = xb.constants.popupPadding + db.text.fontSize + self.optionTextExtra
  local changedWidth = false
  for i = 0, GetNumSpecializations() do
    if self.lootSpecButtons[i] == nil then
      local specId = i
      local name = ''
      if i == 0 then
        name = L['Current Specialization'];
        specId = self.currentSpecID
      else
        _, name, _ = GetSpecializationInfo(i)
      end
      local button = CreateFrame('BUTTON', nil, self.lootSpecPopup)
      local buttonText = button:CreateFontString(nil, 'OVERLAY')
      local buttonIcon = button:CreateTexture(nil, 'OVERLAY')

      buttonIcon:SetTexture(self.classIcon)
      buttonIcon:SetTexCoord(unpack(self.specCoords[specId]))
      buttonIcon:SetSize(iconSize, iconSize)
      buttonIcon:SetPoint('LEFT')
      buttonIcon:SetVertexColor(xb:GetColor('normal'))

      buttonText:SetFont(xb:GetFont(db.text.fontSize))
      buttonText:SetTextColor(xb:GetColor('normal'))
      buttonText:SetText(name)
      buttonText:SetPoint('LEFT', buttonIcon, 'RIGHT', 5, 0)
      local textWidth = iconSize + 5 + buttonText:GetStringWidth()

      button:SetID(i)
      button:SetSize(textWidth, iconSize)
      button.isSettable = true
      button.text = buttonText
      button.icon = buttonIcon

      button:EnableMouse(true)
      button:RegisterForClicks('AnyUp')

      button:SetScript('OnEnter', function()
        buttonText:SetTextColor(r, g, b, 1)
      end)

      button:SetScript('OnLeave', function()
        buttonText:SetTextColor(xb:GetColor('normal'))
      end)

      button:SetScript('OnClick', function(self, button)
        if InCombatLockdown() then return; end
        if button == 'LeftButton' then
          local id = 0
          local name = ''
          if self:GetID() ~= 0 then
            id, name = GetSpecializationInfo(self:GetID())
          else
            name = GetSpecializationInfo(GetSpecialization())
          end
          SetLootSpecialization(id)
        end
        TalentModule.lootSpecPopup:Hide()
      end)

      self.lootSpecButtons[i] = button

      if textWidth > popupWidth then
        popupWidth = textWidth
        changedWidth = true
      end
    end -- if nil
  end -- for ipairs portOptions
  for portId, button in pairs(self.lootSpecButtons) do
    if button.isSettable then
      button:SetPoint('LEFT', xb.constants.popupPadding, 0)
      button:SetPoint('TOP', 0, -(popupHeight + xb.constants.popupPadding))
      button:SetPoint('RIGHT')
      popupHeight = popupHeight + xb.constants.popupPadding + db.text.fontSize
    else
      button:Hide()
    end
  end -- for id/button in portButtons
  if changedWidth then
    popupWidth = popupWidth + self.extraPadding
  end

  if popupWidth < self.specFrame:GetWidth() then
    popupWidth = self.specFrame:GetWidth()
  end

  if popupWidth < (self.lootSpecOptionString:GetStringWidth()  + self.extraPadding) then
    popupWidth = (self.lootSpecOptionString:GetStringWidth()  + self.extraPadding)
  end
  self.lootSpecPopup:SetSize(popupWidth, popupHeight + xb.constants.popupPadding)

  local popupPadding = xb.constants.popupPadding
  if db.general.barPosition == 'TOP' then
    popupPadding = -(popupPadding)
  end

  self.lootSpecPopup:ClearAllPoints()
  self.lootSpecPopup:SetPoint(db.general.barPosition, self.specFrame, xb.miniTextPosition, 0, 0)
  self:SkinFrame(self.lootSpecPopup, "LootSpecToolTip")
  self.lootSpecPopup:Hide()
end

function TalentModule:ShowTooltip()
  if self.LTip:IsAcquired("TalentTooltip") then
	  self.LTip:Release(self.LTip:Acquire("TalentTooltip"))
  end
  local tooltip = self.LTip:Acquire("TalentTooltip",2,"LEFT","RIGHT")
  tooltip:SmartAnchorTo(self.talentFrame)
  local r, g, b, _ = unpack(xb:HoverColors())
  tooltip:AddHeader("|cFFFFFFFF[|r"..SPECIALIZATION.."|cFFFFFFFF]|r")
  tooltip:SetCellTextColor(1, 1, r, g, b, 1)
  tooltip:AddLine(" ")

  local name = ''
  if self.currentLootSpecID == 0 then
    _, name, _ = GetSpecializationInfo(self.currentSpecID)
  else
    _, name, _ = GetSpecializationInfoByID(self.currentLootSpecID)
  end
  tooltip:AddLine(L['Current Loot Specialization'], "|cFFFFFFFF"..name.."|r")
  tooltip:SetCellTextColor(tooltip:GetLineCount(), 1, r, g, b, 1)

  tooltip:AddLine(" ")
  tooltip:AddLine('<'..L['Left-Click']..'>', "|cFFFFFFFF"..L['Set Specialization'].."|r")
  tooltip:SetCellTextColor(tooltip:GetLineCount(), 1, r, g, b, 1)
  tooltip:AddLine('<'..L['Right-Click']..'>', "|cFFFFFFFF"..L['Set Loot Specialization'].."|r")
  tooltip:SetCellTextColor(tooltip:GetLineCount(), 1, r, g, b, 1)
  self:SkinFrame(tooltip, "TalentTooltip")
  tooltip:Show()
end

function TalentModule:GetDefaultOptions()
  return 'talent', {
      enabled = true,
      showTooltip = true,
      minWidth = 50
    }
end

function TalentModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.talent.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.talent.enabled = val
          if val then
            self:Enable()
          else
            self:Disable()
          end
        end,
        width = "full"
      },
      showTooltip = {
        name = L['Show Tooltips'],
        order = 1,
        type = "toggle",
        get = function() return xb.db.profile.modules.talent.showTooltip; end,
        set = function(_, val) xb.db.profile.modules.talent.showTooltip = val; self:Refresh(); end
      },
      minWidth = {
        name = L['Talent Minimum Width'],
        type = 'range',
        order = 2,
        min = 10,
        max = 200,
        step = 10,
        get = function() return xb.db.profile.modules.talent.minWidth; end,
        set = function(info, val) xb.db.profile.modules.talent.minWidth = val; self:Refresh(); end
      }
    }
  }
end
