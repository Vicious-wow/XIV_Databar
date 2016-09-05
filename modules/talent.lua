local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local TalentModule = xb:NewModule("TalentModule", 'AceEvent-3.0')

function TalentModule:GetName()
  return TALENTS;
end

function TalentModule:OnInitialize()
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
  self.LAD = LibStub('LibArtifactData-1.0')
  self.curArtifactId = 0
end

function TalentModule:OnEnable()
  if self.talentFrame == nil then
    self.talentFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
    xb:RegisterFrame('talentFrame', self.talentFrame)
  end
  self.talentFrame:Show()

  self.currentSpecID = GetSpecialization()
  self.currentLootSpecID = GetLootSpecialization()

  self:CreateFrames()
  self:RegisterFrameEvents()
  self.LAD:ForceUpdate()
  self:Refresh()
end

function TalentModule:OnDisable()
  self.talentFrame:Hide()
  self:UnregisterEvent('TRADE_SKILL_UPDATE')
  self:UnregisterEvent('SPELLS_CHANGED')
  self:UnregisterEvent('UNIT_SPELLCAST_STOP')
end

function TalentModule:Refresh()
  if InCombatLockdown() then return; end

  local db = xb.db.profile
  if self.talentFrame == nil then return; end
  if not db.modules.talent.enabled then return; end

  --local artifactId = 0
  local artifactId = self.LAD:GetActiveArtifactID() or 0

  self.currentSpecID = GetSpecialization()
  self.currentLootSpecID = GetLootSpecialization()

  local iconSize = db.text.fontSize + db.general.barPadding
  local _, name, _ = GetSpecializationInfo(self.currentSpecID)

  local textHeight = db.text.fontSize
  if artifactId > 0 then
    textHeight = floor((xb:GetHeight() - 4) / 2)
    self.curArtifactId = artifactId
  end
  self.specIcon:SetTexture(self.classIcon)
  self.specIcon:SetTexCoord(unpack(self.specCoords[self.currentSpecID]))

  self.specIcon:SetSize(iconSize, iconSize)
  self.specIcon:SetPoint('LEFT')
  self.specIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

  self.specText:SetFont(xb:GetFont(textHeight))
  self.specText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  self.specText:SetText(string.upper(name))

  if artifactId > 0 then
    self.specText:SetPoint('TOPLEFT', self.specIcon, 'TOPRIGHT', 5, 0)
  else
    self.specText:SetPoint('LEFT', self.specIcon, 'RIGHT', 5, 0)
  end

  self.lootSpecButtons[0].icon:SetTexture(self.classIcon)
  self.lootSpecButtons[0].icon:SetTexCoord(unpack(self.specCoords[self.currentSpecID]))

  if artifactId > 0 then
    self.specBar:SetStatusBarTexture(1, 1, 1)
    if db.modules.tradeskill.barCC then
      self.specBar:SetStatusBarColor(xb:GetClassColors())
    else
      self.specBar:SetStatusBarColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
    end
    self.specBar:SetSize(self.specText:GetStringWidth(), (iconSize - textHeight - 2))
    self.specBar:SetPoint('BOTTOMLEFT', self.specIcon, 'BOTTOMRIGHT', 5, 0)

    self.specBarBg:SetAllPoints()
    self.specBarBg:SetColorTexture(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    self:UpdateArtifactBar(artifactId)
  end
  self.specFrame:SetSize(iconSize + self.specText:GetStringWidth() + 5, xb:GetHeight())
  self.specFrame:SetPoint('LEFT')

  if self.specFrame:GetWidth() < db.modules.talent.minWidth then
    self.specFrame:SetWidth(db.modules.talent.minWidth)
  end

  if self.specBar:GetWidth() < db.modules.talent.minWidth then
    self.specBar:SetWidth(db.modules.talent.minWidth)
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

function TalentModule:UpdateArtifactBar(artifactId)
  --if true then return; end
  local _, artifactData = self.LAD:GetArtifactInfo(artifactId)
  self.specBar:SetMinMaxValues(0, artifactData.maxPower)
  self.specBar:SetValue(artifactData.power)
end

function TalentModule:CreateFrames()
  self.specFrame = self.specFrame or CreateFrame("BUTTON", nil, self.talentFrame, 'SecureActionButtonTemplate')
  self.specIcon = self.specIcon or self.specFrame:CreateTexture(nil, 'OVERLAY')
  self.specText = self.specText or self.specFrame:CreateFontString(nil, 'OVERLAY')
  self.specBar = self.specBar or CreateFrame('STATUSBAR', nil, self.specFrame)
  self.specBarBg = self.specBarBg or self.specBar:CreateTexture(nil, 'BACKGROUND')

  self.specPopup = self.specPopup or CreateFrame('BUTTON', nil, self.specFrame)
  self.specPopupTexture = self.specPopupTexture or self.specPopup:CreateTexture(nil, 'BACKGROUND')
  self.lootSpecPopup = self.lootSpecPopup or CreateFrame('BUTTON', nil, self.specFrame)
  self.lootSpecPopupTexture = self.lootSpecPopupTexture or self.lootSpecPopup:CreateTexture(nil, 'BACKGROUND')
  self:CreateSpecPopup()
  self:CreateLootSpecPopup()
end

function TalentModule:RegisterFrameEvents()

  self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'Refresh')
  self:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', 'Refresh')
  self:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED', 'Refresh')

  self:RegisterEvent('ARTIFACT_XP_UPDATE', function()
    self:UpdateArtifactBar(self.curArtifactId)
  end)

  self:RegisterEvent('UNIT_INVENTORY_CHANGED', 'Refresh')

  self.specFrame:EnableMouse(true)
  self.specFrame:RegisterForClicks('AnyUp')

  self.specFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    self.specText:SetTextColor(unpack(xb:HoverColors()))
    if xb.db.profile.modules.tradeskill.showTooltip then
      if ((not self.specPopup:IsVisible()) or (not self.lootSpecPopup:IsVisible())) then
        self:ShowTooltip()
      end
    end
  end)
  self.specFrame:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    local db = xb.db.profile
    self.specText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    if xb.db.profile.modules.tradeskill.showTooltip then
      GameTooltip:Hide()
    end
  end)
  self.specFrame:SetScript('OnClick', function(_, button)
    GameTooltip:Hide()
    if button == 'LeftButton' then
      if not InCombatLockdown() then
        if self.specPopup:IsVisible() then
          self.specPopup:Hide()
          if xb.db.profile.modules.tradeskill.showTooltip then
            self:ShowTooltip()
          end
        else
          self.lootSpecPopup:Hide()
          self:CreateSpecPopup()
          self.specPopup:Show()
        end
      end
    end

    if button == 'RightButton' then
      if not InCombatLockdown() then
        if self.lootSpecPopup:IsVisible() then
          self.lootSpecPopup:Hide()
          if xb.db.profile.modules.tradeskill.showTooltip then
            self:ShowTooltip()
          end
        else
          self.specPopup:Hide()
          self:CreateLootSpecPopup()
          self.lootSpecPopup:Show()
        end
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
  self.specOptionString:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
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
      buttonIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

      buttonText:SetFont(xb:GetFont(db.text.fontSize))
      buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
      buttonText:SetText(name)
      buttonText:SetPoint('LEFT', buttonIcon, 'RIGHT', 5, 0)
      local textWidth = iconSize + 5 + buttonText:GetStringWidth()

      button:SetID(i)
      button:SetSize(textWidth, iconSize)
      button.isSettable = true

      button:EnableMouse(true)
      button:RegisterForClicks('AnyUp')

      button:SetScript('OnEnter', function()
        buttonText:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
      end)

      button:SetScript('OnLeave', function()
        buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
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
  self.specPopupTexture:ClearAllPoints()
  self.specPopup:SetPoint(db.general.barPosition, self.specFrame, xb.miniTextPosition, 0, popupPadding)
  self.specPopupTexture:SetColorTexture(db.color.barColor.r, db.color.barColor.g, db.color.barColor.b, db.color.barColor.a)
  self.specPopupTexture:SetAllPoints()
  self.specPopup:Hide()
end

function TalentModule:CreateLootSpecPopup()
  if not self.lootSpecPopup then return; end

  local db = xb.db.profile
  local iconSize = db.text.fontSize + db.general.barPadding
  self.lootSpecOptionString = self.lootSpecOptionString or self.lootSpecPopup:CreateFontString(nil, 'OVERLAY')
  self.lootSpecOptionString:SetFont(xb:GetFont(db.text.fontSize + self.optionTextExtra))
  self.lootSpecOptionString:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
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
      buttonIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

      buttonText:SetFont(xb:GetFont(db.text.fontSize))
      buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
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
        buttonText:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
      end)

      button:SetScript('OnLeave', function()
        buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
      end)

      button:SetScript('OnClick', function(self, button)
        if InCombatLockdown() then return; end
        if button == 'LeftButton' then
          local id = 0
          if self:GetID() ~= 0 then
            id = GetSpecializationInfo(self:GetID())
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
  self.lootSpecPopupTexture:ClearAllPoints()
  self.lootSpecPopup:SetPoint(db.general.barPosition, self.specFrame, xb.miniTextPosition, 0, popupPadding)
  self.lootSpecPopupTexture:SetColorTexture(db.color.barColor.r, db.color.barColor.g, db.color.barColor.b, db.color.barColor.a)
  self.lootSpecPopupTexture:SetAllPoints()
  self.lootSpecPopup:Hide()
end

function TalentModule:ShowTooltip()
  GameTooltip:SetOwner(self.talentFrame, 'ANCHOR_'..xb.miniTextPosition)
  GameTooltip:AddLine("[|cff6699FF"..SPECIALIZATION.."|r]")
  GameTooltip:AddLine(" ")

  local name = ''
  if self.currentLootSpecID == 0 then
    _, name, _ = GetSpecializationInfo(self.currentSpecID)
  else
    _, name, _ = GetSpecializationInfoByID(self.currentLootSpecID)
  end
  GameTooltip:AddDoubleLine(L['Current Loot Specialization'], name, 1, 1, 0, 1, 1, 1)

  if self.curArtifactId > 0 then
    GameTooltip:AddLine(" ")
    local _, artifactData = self.LAD:GetArtifactInfo(self.curArtifactId)
    local knowLevel, knowMult = self.LAD:GetArtifactKnowledge()
    if knowLevel > 0 then
      GameTooltip:AddDoubleLine(L['Artifact Knowledge']..':', string.format('%d (x%d)', knowLevel, ((knowMult) - 1 * 100)), 1, 1, 0, 1, 1, 1)
      GameTooltip:AddLine(" ")
    end
    GameTooltip:AddDoubleLine(ARTIFACT_POWER..':', string.format('%d / %d (%d%%)', artifactData.power, artifactData.maxPower, floor((artifactData.power / artifactData.maxPower) * 100)), 1, 1, 0, 1, 1, 1)
    GameTooltip:AddDoubleLine(L['Remaining']..':', string.format('%d (%d%%)', artifactData.powerForNextRank, floor((artifactData.powerForNextRank / artifactData.maxPower) * 100)), 1, 1, 0, 1, 1, 1)
    if artifactData.numRanksPurchasable > 0 then
      GameTooltip:AddDoubleLine(L['Available Ranks']..':', string.format('%d', artifactData.numRanksPurchasable), 1, 1, 0, 1, 1, 1)
    end
  end

  GameTooltip:AddLine(" ")
  GameTooltip:AddDoubleLine('<'..L['Left-Click']..'>', L['Set Specialization'], 1, 1, 0, 1, 1, 1)
  GameTooltip:AddDoubleLine('<'..L['Right-Click']..'>', L['Set Loot Specialization'], 1, 1, 0, 1, 1, 1)
  GameTooltip:Show()
end

function TalentModule:GetDefaultOptions()
  return 'talent', {
      enabled = true,
      barCC = false,
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
      barCC = {
        name = L['Use Class Colors'],
        order = 2,
        type = "toggle",
        get = function() return xb.db.profile.modules.talent.barCC; end,
        set = function(_, val) xb.db.profile.modules.talent.barCC = val; self:Refresh(); end
      },
      showTooltip = {
        name = L['Show Tooltips'],
        order = 3,
        type = "toggle",
        get = function() return xb.db.profile.modules.talent.showTooltip; end,
        set = function(_, val) xb.db.profile.modules.talent.showTooltip = val; self:Refresh(); end
      },
      minWidth = {
        name = L['Talent Minimum Width'],
        type = 'range',
        order = 4,
        min = 10,
        max = 200,
        step = 10,
        get = function() return xb.db.profile.modules.talent.minWidth; end,
        set = function(info, val) xb.db.profile.modules.talent.minWidth = val; self:Refresh(); end
      }
    }
  }
end
