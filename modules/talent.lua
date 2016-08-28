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

  self.currentSpecID = GetSpecialization()
  self.currentLootSpecID = GetLootSpecialization()

  local iconSize = db.text.fontSize + db.general.barPadding
  local _, name, _ = GetSpecializationInfo(self.currentSpecID)


  --local textHeight = floor((xb:GetHeight() - 4) / 2) -- This will be useful once we add artifact info
  local textHeight = db.text.fontSize
  self.specIcon:SetTexture(self.classIcon)
  self.specIcon:SetTexCoord(unpack(self.specCoords[self.currentSpecID]))

  self.specIcon:SetSize(iconSize, iconSize)
  self.specIcon:SetPoint('LEFT')
  self.specIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

  self.specText:SetFont(xb:GetFont(textHeight))
  self.specText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  self.specText:SetText(string.upper(name))

  self.specText:SetPoint('LEFT', self.specIcon, 'RIGHT', 5, 0)

  self.lootSpecButtons[0].icon:SetTexture(self.classIcon)
  self.lootSpecButtons[0].icon:SetTexCoord(unpack(self.specCoords[self.currentSpecID]))
  --[[
  if skill == cap then
    self.specText:SetPoint('LEFT', self.specIcon, 'RIGHT', 5, 0)
  else
    self.specText:SetPoint('TOPLEFT', self.specIcon, 'TOPRIGHT', 5, 0)
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
  end]]--
  self.specFrame:SetSize(iconSize + self.specText:GetStringWidth() + 5, xb:GetHeight())
  self.specFrame:SetPoint('LEFT')

  self.talentFrame:SetSize(self.specFrame:GetWidth(), xb:GetHeight())

  self.specPopup:SetPoint('BOTTOM', self.specFrame, 'TOP', 0, xb.constants.popupPadding)
  self.specPopupTexture:SetColorTexture(db.color.barColor.r, db.color.barColor.g, db.color.barColor.b, db.color.barColor.a)
  self.specPopupTexture:SetAllPoints()
  self.specPopup:Hide()

  self.lootSpecPopup:SetPoint('BOTTOM', self.specFrame, 'TOP', 0, xb.constants.popupPadding)
  self.lootSpecPopupTexture:SetColorTexture(db.color.barColor.r, db.color.barColor.g, db.color.barColor.b, db.color.barColor.a)
  self.lootSpecPopupTexture:SetAllPoints()
  self.lootSpecPopup:Hide()

  local relativeAnchorPoint = 'LEFT'
  local xOffset = db.general.moduleSpacing
  if not xb:GetFrame('clockFrame'):IsVisible() then
    relativeAnchorPoint = 'RIGHT'
    xOffset = 0
  end
  self.talentFrame:SetPoint('RIGHT', xb:GetFrame('clockFrame'), relativeAnchorPoint, -(xOffset), 0)
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

  self.specFrame:EnableMouse(true)
  self.specFrame:RegisterForClicks('AnyUp')

  self.specFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    self.specText:SetTextColor(unpack(xb:HoverColors()))
    if xb.db.profile.modules.tradeskill.showTooltip then
      self:ShowTooltip()
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
    if button == 'LeftButton' then
      if not InCombatLockdown() then
        if self.specPopup:IsVisible() then
          self.specPopup:Hide()
        else
          self.lootSpecPopup:Hide()
          self.specPopup:Show()
        end
      end
    end

    if button == 'RightButton' then
      if not InCombatLockdown() then
        if self.lootSpecPopup:IsVisible() then
          self.lootSpecPopup:Hide()
        else
          self.specPopup:Hide()
          self.lootSpecPopup:Show()
        end
      end
    end
  end)

  --[[
  self.talentFrame:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
  self.talentFrame:SetScript('OnEvent', function(_, event)
    if event == 'UNIT_SPELLCAST_STOP' then
      self:Refresh()
    end
  end)


  self.firstProfFrame:SetAttribute('*type1', 'spell')
  self.firstProfFrame:SetAttribute('unit', 'player')

  self.secondProfFrame:EnableMouse(true)
  self.secondProfFrame:RegisterForClicks('AnyUp')

  self.secondProfFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    self.secondProfText:SetTextColor(unpack(xb:HoverColors()))
    if xb.db.profile.modules.tradeskill.showTooltip then
      self:ShowTooltip()
    end
  end)
  self.secondProfFrame:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    local db = xb.db.profile
    self.secondProfText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    if xb.db.profile.modules.tradeskill.showTooltip then
      GameTooltip:Hide()
    end
  end)
  self.secondProfFrame:SetAttribute('*type1', 'spell')
  self.secondProfFrame:SetAttribute('unit', 'player')

  self.talentFrame:EnableMouse(true)
  self.talentFrame:SetScript('OnEnter', function()
    if xb.db.profile.modules.tradeskill.showTooltip then
      self:ShowTooltip()
    end
  end)
  self.talentFrame:SetScript('OnLeave', function()
    if xb.db.profile.modules.tradeskill.showTooltip then
      GameTooltip:Hide()
    end
  end)]]--

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
end

function TalentModule:ShowTooltip()
  return
  --[[
  GameTooltip:SetOwner(self.talentFrame, 'ANCHOR_'..xb.miniTextPosition)
  GameTooltip:AddLine("[|cff6699FF"..L['Cooldowns'].."|r]")
  GameTooltip:AddLine(" ")

  local recipeIds = C_TradeSkillUI.GetAllRecipeIDs()

  GameTooltip:AddLine(" ")
  GameTooltip:AddDoubleLine('<'..L['Left-Click']..'>', L['Toggle Currency Frame'], 1, 1, 0, 1, 1, 1)
  GameTooltip:Show()]]--
end

function TalentModule:GetDefaultOptions()
  return 'talent', {
      enabled = true,
      barCC = false,
      showTooltip = true
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
      }
    }
  }
end
