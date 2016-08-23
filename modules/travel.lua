local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local TravelModule = xb:NewModule("TravelModule", 'AceEvent-3.0')

function TravelModule:GetName()
  return L['Travel'];
end

function TravelModule:OnInitialize()
  self.iconPath = xb.constants.mediaPath..'datatexts\\repair'
  self.garrisonHearth = 110560
  self.hearthstones = {
    64488, -- Innkeeper's Daughter
    54452, -- Ethereal Portal
    93672, -- Dark Portal
    6948,  -- Hearthstone
    556,   -- Astral Recall
    28585, -- Ruby Slippers
    37118, -- Scroll of Recall 1
    44314, -- Scroll of Recall 2
    44315, -- Scroll of Recall 3
  }
  local compassName, _ = GetItemInfo(128353)
  self.portOptions = {
    -- dalaran rings, guild capes?
    {portId = 128353, text = compassName}, -- admiral's compass
    {portId = 140192, text = GetMapNameByID(1014)}, -- dalaran hearthstone
    {portId = self.garrisonHearth, text = GARRISON_LOCATION_TOOLTIP}, -- needs to be var for default options
  }

  if xb.constants.playerClass == 'DRUID' then
    if IsPlayerSpell(193753) then
      tinsert(self.portOptions, {portId = 193753, text = ORDER_HALL_DRUID})
    else
      tinsert(self.portOptions, {portId = 18960, text = GetMapNameByID(241)})
    end
  end

  if xb.constants.playerClass == 'DEATHKNIGHT' then
    tinsert(self.portOptions, {portId = 50977, text = ORDER_HALL_DEATHKNIGHT})
  end

  if xb.constants.playerClass == 'MAGE' then
    tinsert(self.portOptions, {portId = 193759, text = ORDER_HALL_MAGE})
  end

  if xb.constants.playerClass == 'MONK' then
    local portText = GetMapNameByID(809)
    if IsPlayerSpell(200617) then
      portText = ORDER_HALL_MONK
    end
    tinsert(self.portOptions, {portId = 193759, text = portText})
  end

  self.portButtons = {}
  self.extraPadding = (xb.constants.popupPadding * 3)
  self.optionTextExtra = 4
end

function TravelModule:OnEnable()
  if self.hearthFrame == nil then
    self.hearthFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
    xb:RegisterFrame('hearthFrame', self.hearthFrame)
  end
  self:CreateFrames()
  self:RegisterFrameEvents()
  self:Refresh()
end

function TravelModule:OnDisable()
end

function TravelModule:CreateFrames()
  self.hearthButton = self.hearthButton or CreateFrame('BUTTON', nil, self.hearthFrame, "SecureActionButtonTemplate")
  self.hearthIcon = self.hearthIcon or self.hearthButton:CreateTexture(nil, 'OVERLAY')
  self.hearthText = self.hearthText or self.hearthButton:CreateFontString(nil, 'OVERLAY')

  self.portButton = self.portButton or CreateFrame('BUTTON', nil, self.hearthFrame, "SecureActionButtonTemplate")
  self.portIcon = self.portIcon or self.portButton:CreateTexture(nil, 'OVERLAY')
  self.portText = self.portText or self.portButton:CreateFontString(nil, 'OVERLAY')

  self.portPopup = self.portPopup or CreateFrame('BUTTON', nil, self.portButton)
  self.popupTexture = self.popupTexture or self.portPopup:CreateTexture(nil, 'BACKGROUND')
end

function TravelModule:RegisterFrameEvents()
  self:RegisterEvent('SPELLS_CHANGED', 'Refresh')
  self:RegisterEvent('BAG_UPDATE_DELAYED', 'Refresh')
  self:RegisterEvent('HEARTHSTONE_BOUND', 'Refresh')
  self.hearthButton:EnableMouse(true)
  self.hearthButton:RegisterForClicks("AnyUp")
  self.hearthButton:SetAttribute('type', 'macro')

  self.portButton:EnableMouse(true)
  self.portButton:RegisterForClicks("AnyUp")
  self.portButton:SetAttribute('*type1', 'macro')
  self.portButton:SetAttribute('*type2', 'portFunction')

  self.portPopup:EnableMouse(true)
  self.portPopup:RegisterForClicks('RightButtonUp')

  self.portButton.portFunction = self.portButton.portFunction or function()
    if TravelModule.portPopup:IsVisible() then
      TravelModule.portPopup:Hide()
    else
      TravelModule:CreatePortPopup()
      TravelModule.portPopup:Show()
    end
  end

  self.portPopup:SetScript('OnClick', function(self, button)
    if button == 'RightButton' then
      self:Hide()
    end
  end)

  self.hearthButton:SetScript('OnEnter', function()
    TravelModule:SetHearthColor()
  end)

  self.hearthButton:SetScript('OnLeave', function()
    TravelModule:SetHearthColor()
  end)

  self.portButton:SetScript('OnEnter', function()
    TravelModule:SetPortColor()
  end)

  self.portButton:SetScript('OnLeave', function()
    TravelModule:SetPortColor()
  end)
end

function TravelModule:SetHearthColor()
  if InCombatLockdown() then return; end

  local db = xb.db.profile
  if self.hearthButton:IsMouseOver() then
    self.hearthText:SetTextColor(unpack(xb:HoverColors()))
  else
    self.hearthIcon:SetVertexColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    local hearthName = ''
    local hearthActive = false
    for i,v in ipairs(self.hearthstones) do
      if (PlayerHasToy(v) or IsUsableItem(v)) then
        if GetItemCooldown(v) == 0 then
          hearthName, _ = GetItemInfo(v)
          hearthActive = true
          self.hearthButton:SetAttribute("macrotext", "/cast "..hearthName)
          break
        end
      end -- if toy/item
      if IsPlayerSpell(v) then
        if GetSpellCooldown(v) == 0 then
          hearthName, _ = GetSpellInfo(v)
          hearthActive = true
          self.hearthButton:SetAttribute("macrotext", "/cast "..hearthName)
        end
      end -- if is spell
    end -- for hearthstones
    if hearthActive then
      self.hearthIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
    end
    self.hearthText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  end --else
end

function TravelModule:SetPortColor()
  if InCombatLockdown() then return; end

  local db = xb.db.profile
  local v = db.modules.travel.portItem.portId

  if not (IsUsableItem(v) or IsPlayerSpell(v)) then
    self.portButton:Hide()
    return
  end

  if self.portButton:IsMouseOver() then
    self.portText:SetTextColor(unpack(xb:HoverColors()))
  else
    local hearthname = ''
    local hearthActive = false
    if (PlayerHasToy(v) or IsUsableItem(v)) then
      if GetItemCooldown(v) == 0 then
        hearthName, _ = GetItemInfo(v)
        hearthActive = true
        self.portButton:SetAttribute("macrotext", "/cast "..hearthName)
      end
    end -- if toy/item
    if IsPlayerSpell(v) then
      if GetSpellCooldown(v) == 0 then
        hearthName, _ = GetSpellInfo(v)
        hearthActive = true
        self.portButton:SetAttribute("macrotext", "/cast "..hearthName)
      end
    end -- if is spell

    if hearthActive then
      self.portIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
    else
      self.portIcon:SetVertexColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    end
    self.portText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  end --else
end

function TravelModule:CreatePortPopup()
  if not self.portPopup then return; end

  local db = xb.db.profile
  self.portOptionString = self.portOptionString or self.portPopup:CreateFontString(nil, 'OVERLAY')
  self.portOptionString:SetFont(xb.LSM:Fetch(xb.LSM.MediaType.FONT, db.text.font), db.text.fontSize + self.optionTextExtra)
  self.portOptionString:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
  self.portOptionString:SetText(L['Port Options'])
  self.portOptionString:SetPoint('TOP', 0, -(xb.constants.popupPadding))
  self.portOptionString:SetPoint('CENTER')

  local popupWidth = self.portPopup:GetWidth()
  local popupHeight = xb.constants.popupPadding + db.text.fontSize + self.optionTextExtra
  local changedWidth = false
  for i, v in ipairs(self.portOptions) do
    if self.portButtons[v.portId] == nil then
      if IsUsableItem(v.portId) or IsPlayerSpell(v.portId) then
        local button = CreateFrame('BUTTON', nil, self.portPopup)
        local buttonText = button:CreateFontString(nil, 'OVERLAY')

        buttonText:SetFont(xb.LSM:Fetch(xb.LSM.MediaType.FONT, db.text.font), db.text.fontSize)
        buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
        buttonText:SetText(v.text)
        buttonText:SetPoint('LEFT')
        local textWidth = buttonText:GetStringWidth()

        button:SetID(v.portId)
        button:SetSize(textWidth, db.text.fontSize)
        button.isSettable = true
        button.portItem = v

        button:EnableMouse(true)
        button:RegisterForClicks('LeftButtonUp')

        button:SetScript('OnEnter', function()
          buttonText:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
        end)

        button:SetScript('OnLeave', function()
          buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
        end)

        button:SetScript('OnClick', function(self)
          xb.db.profile.modules.travel.portItem = self.portItem
          TravelModule:Refresh()
        end)

        self.portButtons[v.portId] = button

        if textWidth > popupWidth then
          popupWidth = textWidth
          changedWidth = true
        end
      end -- if usable item or spell
    else
      if not (IsUsableItem(v.portId) or IsPlayerSpell(v.portId)) then
        self.portButtons[v.portId].isSettable = false
      end
    end -- if nil
  end -- for ipairs portOptions
  for portId, button in pairs(self.portButtons) do
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

  if popupWidth < self.portButton:GetWidth() then
    popupWidth = self.portButton:GetWidth()
  end

  if popupWidth < (self.portOptionString:GetStringWidth()  + self.extraPadding) then
    popupWidth = (self.portOptionString:GetStringWidth()  + self.extraPadding)
  end
  self.portPopup:SetSize(popupWidth, popupHeight + xb.constants.popupPadding)
end

function TravelModule:Refresh()
  if self.hearthFrame == nil then return; end

  local db = xb.db.profile
  --local iconSize = (xb:GetHeight() / 2)
  local iconSize = db.text.fontSize + db.general.barPadding

  self.hearthText:SetFont(xb.LSM:Fetch(xb.LSM.MediaType.FONT, db.text.font), db.text.fontSize)
  self.hearthText:SetText(GetBindLocation())

  self.hearthButton:SetSize(self.hearthText:GetWidth() + iconSize + db.general.barPadding, xb:GetHeight())
  self.hearthButton:SetPoint("RIGHT")

  self.hearthText:SetPoint("RIGHT")

  self.hearthIcon:SetTexture(xb.constants.mediaPath..'datatexts\\hearth')
  self.hearthIcon:SetSize(iconSize, iconSize)

  self.hearthIcon:SetPoint("RIGHT", self.hearthText, "LEFT", -(db.general.barPadding), 0)

  self:SetHearthColor()

  self.portText:SetFont(xb.LSM:Fetch(xb.LSM.MediaType.FONT, db.text.font), db.text.fontSize)
  self.portText:SetText(db.modules.travel.portItem.text)

  self.portButton:SetSize(self.portText:GetWidth() + iconSize + db.general.barPadding, xb:GetHeight())
  self.portButton:SetPoint("LEFT", -(db.general.barPadding), 0)

  self.portText:SetPoint("RIGHT")

  self.portIcon:SetTexture(xb.constants.mediaPath..'datatexts\\garr')
  self.portIcon:SetSize(iconSize, iconSize)

  self.portIcon:SetPoint("RIGHT", self.portText, "LEFT", -(db.general.barPadding), 0)

  self:SetPortColor()

  self:CreatePortPopup()
  self.portPopup:SetPoint('BOTTOM', self.portButton, 'TOP', 0, xb.constants.popupPadding)
  local mainTexture = string.sub(xb.frames.bgTexture:GetTexture(), 7)
  self.popupTexture:SetColorTexture(xb:HexToRGBA(mainTexture))
  self.popupTexture:SetAllPoints()
  self.portPopup:Hide()

  local totalWidth = self.hearthButton:GetWidth() + db.general.barPadding
  if self.portButton:IsVisible() then
    totalWidth = totalWidth + self.portButton:GetWidth()
  end
  self.hearthFrame:SetSize(totalWidth, xb:GetHeight())
  self.hearthFrame:SetPoint("RIGHT", -(db.general.barPadding), 0)
end

function TravelModule:GetDefaultOptions()
  return 'travel', {
    portItem = {portId = 110560, text = GARRISON_LOCATION_TOOLTIP}
  }
end
