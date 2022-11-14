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
    6948,   -- Hearthstone
    64488,  -- Innkeeper's Daughter
    28585,  -- Ruby Slippers
    54452,  -- Ethereal Portal
    93672,  -- Dark Portal
    142542, -- Tome of Town Portal
    163045, -- Headless Horseman's Hearthstone
    162973, -- Greatfather Winter's Hearthstone
    165669, -- Lunar Elder's Hearthstone
    165670, -- Peddlefeet's Lovely Hearthstone
    165802, -- Noble Gardener's Hearthstone
    166746, -- Fire Eater's Hearthstone
    166747, -- Brewfest Reveler's Hearthstone
    40582,  -- Scourgestone (Death Knight Starting Campaign)
    172179, -- Eternal Traveler's Hearthstone
    184353, -- Kyrian Hearthstone
    182773, -- Necrolord Hearthstone
    180290, -- Night Fae Hearthstone
    183716, -- Venthyr Sinstone
    142543, -- Scroll of Town Portal
    37118,  -- Scroll of Recall 1
    44314,  -- Scroll of Recall 2
    44315,  -- Scroll of Recall 3
    556,    -- Astral Recall
    168907, -- Holographic Digitalization Hearthstone
    142298, -- Astonishingly Scarlet Slippers
  }

  self.portButtons = {}
  self.extraPadding = (xb.constants.popupPadding * 3)
  self.optionTextExtra = 4
end

-- Skin Support for ElvUI/TukUI
-- Make sure to disable "Tooltip" in the Skins section of ElvUI together with
-- unchecking "Use ElvUI for tooltips" in XIV options to not have ElvUI fuck with tooltips
function TravelModule:SkinFrame(frame, name)
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

function TravelModule:OnEnable()
  if self.hearthFrame == nil then
    self.hearthFrame = CreateFrame('FRAME', "TravelModule", xb:GetFrame('bar'))
    xb:RegisterFrame('travelFrame', self.hearthFrame)
  end
  self.useElvUI = xb.db.profile.general.useElvUI and (IsAddOnLoaded('ElvUI') or IsAddOnLoaded('Tukui'))
  self.hearthFrame:Show()
  self:CreateFrames()
  self:RegisterFrameEvents()
  self:Refresh()
end

function TravelModule:OnDisable()
  self.hearthFrame:Hide()
  self:UnregisterEvent('SPELLS_CHANGED')
  self:UnregisterEvent('BAG_UPDATE_DELAYED')
  self:UnregisterEvent('HEARTHSTONE_BOUND')
end

function TravelModule:CreateFrames()
  self.hearthButton = self.hearthButton or CreateFrame('BUTTON', 'hearthButton', self.hearthFrame, 'SecureActionButtonTemplate')
  self.hearthIcon = self.hearthIcon or self.hearthButton:CreateTexture(nil, 'OVERLAY')
  self.hearthText = self.hearthText or self.hearthButton:CreateFontString(nil, 'OVERLAY')

  self.portButton = self.portButton or CreateFrame('BUTTON', 'portButton', self.hearthFrame, 'SecureActionButtonTemplate')
  self.portIcon = self.portIcon or self.portButton:CreateTexture(nil, 'OVERLAY')
  self.portText = self.portText or self.portButton:CreateFontString(nil, 'OVERLAY')

  local template = (TooltipBackdropTemplateMixin and "TooltipBackdropTemplate") or (BackdropTemplateMixin and "BackdropTemplate")
  self.portPopup = self.portPopup or CreateFrame('BUTTON', 'portPopup', self.portButton, template)
  self.portPopup:SetFrameStrata("TOOLTIP")

  if TooltipBackdropTemplateMixin then
    self.portPopup.layoutType = GameTooltip.layoutType
    NineSlicePanelMixin.OnLoad(self.portPopup.NineSlice)

    if GameTooltip.layoutType then
      self.portPopup.NineSlice:SetCenterColor(GameTooltip.NineSlice:GetCenterColor())
      self.portPopup.NineSlice:SetBorderColor(GameTooltip.NineSlice:GetBorderColor())
    end
  else
    local backdrop = GameTooltip:GetBackdrop()
    if backdrop and (not self.useElvUI) then
      self.portPopup:SetBackdrop(backdrop)
      self.portPopup:SetBackdropColor(GameTooltip:GetBackdropColor())
      self.portPopup:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
    end
  end
end

function TravelModule:RegisterFrameEvents()
  self:RegisterEvent('SPELLS_CHANGED', 'Refresh')
  self:RegisterEvent('BAG_UPDATE_DELAYED', 'Refresh')
  self:RegisterEvent('HEARTHSTONE_BOUND', 'Refresh')

  self.hearthButton:EnableMouse(true)
  self.hearthButton:RegisterForClicks('AnyUp', 'AnyDown')
  self.hearthButton:SetAttribute('type', 'macro')

  self.portButton:EnableMouse(true)
  self.portButton:RegisterForClicks("AnyUp", "AnyDown")
  self.portButton:SetAttribute('*type1', 'macro')
  self.portButton:SetAttribute('*type2', 'portFunction')

  self.portPopup:EnableMouse(true)
  self.portPopup:RegisterForClicks('RightButtonUp')

  self.portButton.portFunction = self.portButton.portFunction or function()
    if TravelModule.portPopup:IsVisible() then
      TravelModule.portPopup:Hide()
      self:ShowTooltip()
    else
      TravelModule:CreatePortPopup()
      TravelModule.portPopup:Show()
      GameTooltip:Hide()
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
    if InCombatLockdown() then return end
    self:ShowTooltip()
  end)

  self.portButton:SetScript('OnLeave', function()
    TravelModule:SetPortColor()
    GameTooltip:Hide()
  end)
end

function TravelModule:UpdatePortOptions()
  if not self.portOptions then
    self.portOptions = {}
  end
  if IsUsableItem(128353) and not self.portOptions[128353] then
    self.portOptions[128353] = {portId = 128353, text = GetItemInfo(128353)} -- admiral's compass
  end
  if IsUsableItem(140192) and not self.portOptions[140192] then
    self.portOptions[140192] = {portId = 140192, text = GetItemInfo(140192)} -- dalaran hearthstone
  end
  if IsUsableItem(self.garrisonHearth) and not self.portOptions[self.garrisonHearth] then
    self.portOptions[self.garrisonHearth] = {portId = self.garrisonHearth, text = GARRISON_LOCATION_TOOLTIP} -- needs to be var for default options
  end

  if xb.constants.playerClass == 'DRUID' then
    if IsPlayerSpell(193753) then
      if not self.portOptions[193753] then
        self.portOptions[193753] = {portId = 193753, text = ORDER_HALL_DRUID}
      end
    else
      if not self.portOptions[18960] then
        self.portOptions[18960] = {portId = 18960, text = C_Map.GetMapInfo(1471).name}
      end
    end
  end

  if xb.constants.playerClass == 'DEATHKNIGHT' and not self.portOptions[50977] then
    self.portOptions[50977] = {portId = 50977, text = ORDER_HALL_DEATHKNIGHT}
  end

  if xb.constants.playerClass == 'MAGE' and not self.portOptions[193759] then
    self.portOptions[193759] = {portId = 193759, text = ORDER_HALL_MAGE}
  end

  if xb.constants.playerClass == 'MONK' and not self.portOptions[193759] then
    local portText = C_Map.GetMapInfo(809)
    if IsPlayerSpell(200617) then
      portText = ORDER_HALL_MONK
    end
    self.portOptions[193759] = {portId = 193759, text = portText}
  end
end

function TravelModule:FormatCooldown(cdTime)
  if cdTime <= 0 then
    return L['Ready']
  end
  local hours = string.format("%02.f", math.floor(cdTime / 3600))
  local minutes = string.format("%02.f", math.floor(cdTime / 60 - (hours * 60)))
  local seconds = string.format("%02.f", math.floor(cdTime - (hours * 3600) - (minutes * 60)))
  local retString = ''
  if tonumber(hours) ~= 0 then
    retString = hours..':'
  end
  if tonumber(minutes) ~= 0 or tonumber(hours) ~= 0 then
    retString = retString..minutes..':'
  end
  return retString..seconds
end

function TravelModule:SetHearthColor()
  if InCombatLockdown() then return; end

  local db = xb.db.profile
  if self.hearthButton:IsMouseOver() then
    self.hearthText:SetTextColor(unpack(xb:HoverColors()))
  else
    self.hearthIcon:SetVertexColor(xb:GetColor('normal'))
    local hearthName = ''
    local hearthActive = true
    for i,v in ipairs(self.hearthstones) do
      if (PlayerHasToy(v) or IsUsableItem(v)) then
        if GetItemCooldown(v) == 0 then
          hearthName, _ = GetItemInfo(v)
          if hearthName ~= nil then
            hearthActive = true
            self.hearthButton:SetAttribute("macrotext", "/cast "..hearthName)
            break
          end
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
    if not hearthActive then
      self.hearthIcon:SetVertexColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
      self.hearthText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    else
      self.hearthText:SetTextColor(xb:GetColor('normal'))
    end
  end --else
end

function TravelModule:SetPortColor()
  if InCombatLockdown() then return; end

  local db = xb.db.profile
  local v = xb.db.char.portItem.portId

  if not (self:IsUsable(v)) then
    v = self:FindFirstOption()
    v = v.portId
    if not (self:IsUsable(v)) then
      --self.portButton:Hide()
      return
    end
  end

  if self.portButton:IsMouseOver() then
    self.portText:SetTextColor(unpack(xb:HoverColors()))
  else
    local hearthname = ''
    local hearthActive = false
    if (PlayerHasToy(v) or IsUsableItem(v)) then
      if GetItemCooldown(v) == 0 then
        hearthName, _ = GetItemInfo(v)
        if hearthName ~= nil then
          hearthActive = true
          self.portButton:SetAttribute("macrotext", "/cast "..hearthName)
        end
      end
    end -- if toy/item
    if IsPlayerSpell(v) then
      if GetSpellCooldown(v) == 0 then
        hearthName, _ = GetSpellInfo(v)
        if hearthName ~= nil then
          hearthActive = true
          self.portButton:SetAttribute("macrotext", "/cast "..hearthName)
        end
      end
    end -- if is spell

    if not hearthActive then
      self.portIcon:SetVertexColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
      self.portText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    else
      self.portIcon:SetVertexColor(xb:GetColor('normal'))
      self.portText:SetTextColor(xb:GetColor('normal'))
    end
  end --else
end

function TravelModule:CreatePortPopup()
  if not self.portPopup then return; end

  local db = xb.db.profile
  self.portOptionString = self.portOptionString or self.portPopup:CreateFontString(nil, 'OVERLAY')
  self.portOptionString:SetFont(xb:GetFont(db.text.fontSize + self.optionTextExtra))
  local r, g, b, _ = unpack(xb:HoverColors())
  self.portOptionString:SetTextColor(r, g, b, 1)
  self.portOptionString:SetText(L['Port Options'])
  self.portOptionString:SetPoint('TOP', 0, -(xb.constants.popupPadding))
  self.portOptionString:SetPoint('CENTER')

  local popupWidth = self.portPopup:GetWidth()
  local popupHeight = xb.constants.popupPadding + db.text.fontSize + self.optionTextExtra
  local changedWidth = false
  for i, v in pairs(self.portOptions) do
    if self.portButtons[v.portId] == nil then
      if IsUsableItem(v.portId) or IsPlayerSpell(v.portId) then
        local button = CreateFrame('BUTTON', nil, self.portPopup)
        local buttonText = button:CreateFontString(nil, 'OVERLAY')

        buttonText:SetFont(xb:GetFont(db.text.fontSize))
        buttonText:SetTextColor(xb:GetColor('normal'))
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
          buttonText:SetTextColor(xb:GetColor('normal'))
        end)

        button:SetScript('OnLeave', function()
          buttonText:SetTextColor(xb:GetColor('normal'))
        end)

        button:SetScript('OnClick', function(self)
          xb.db.char.portItem = self.portItem
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

  if not xb.db.profile.modules.travel.enabled then self:Disable(); return; end
  if InCombatLockdown() then
    self.hearthText:SetText(GetBindLocation())
    self.portText:SetText(xb.db.char.portItem.text)
    self:SetHearthColor()
    self:SetPortColor()
    return
  end

  self:UpdatePortOptions()

  local db = xb.db.profile
  --local iconSize = (xb:GetHeight() / 2)
  local iconSize = db.text.fontSize + db.general.barPadding

  self.hearthText:SetFont(xb:GetFont(db.text.fontSize))
  self.hearthText:SetText(GetBindLocation())

  self.hearthButton:SetSize(self.hearthText:GetWidth() + iconSize + db.general.barPadding, xb:GetHeight())
  self.hearthButton:SetPoint("RIGHT")

  self.hearthText:SetPoint("RIGHT")

  self.hearthIcon:SetTexture(xb.constants.mediaPath..'datatexts\\hearth')
  self.hearthIcon:SetSize(iconSize, iconSize)

  self.hearthIcon:SetPoint("RIGHT", self.hearthText, "LEFT", -(db.general.barPadding), 0)

  self:SetHearthColor()

  self.portText:SetFont(xb:GetFont(db.text.fontSize))
  self.portText:SetText(xb.db.char.portItem.text)

  self.portButton:SetSize(self.portText:GetWidth() + iconSize + db.general.barPadding, xb:GetHeight())
  self.portButton:SetPoint("LEFT", -(db.general.barPadding), 0)

  self.portText:SetPoint("RIGHT")

  self.portIcon:SetTexture(xb.constants.mediaPath..'datatexts\\garr')
  self.portIcon:SetSize(iconSize, iconSize)

  self.portIcon:SetPoint("RIGHT", self.portText, "LEFT", -(db.general.barPadding), 0)

  self:SetPortColor()

  self:CreatePortPopup()

  local popupPadding = xb.constants.popupPadding
  local popupPoint = 'BOTTOM'
  local relPoint = 'TOP'
  if db.general.barPosition == 'TOP' then
    popupPadding = -(popupPadding)
    popupPoint = 'TOP'
    relPoint = 'BOTTOM'
  end

  self.portPopup:ClearAllPoints()
  self.portPopup:SetPoint(popupPoint, self.portButton, relPoint, 0, 0)
  self:SkinFrame(self.portPopup, "SpecToolTip")
  self.portPopup:Hide()

  local totalWidth = self.hearthButton:GetWidth() + db.general.barPadding
  self.portButton:Show()
  if self.portButton:IsVisible() then
    totalWidth = totalWidth + self.portButton:GetWidth()
  end
  self.hearthFrame:SetSize(totalWidth, xb:GetHeight())
  self.hearthFrame:SetPoint("RIGHT", -(db.general.barPadding), 0)
  self.hearthFrame:Show()
end

function TravelModule:ShowTooltip()
  if not self.portPopup:IsVisible() then
    GameTooltip:SetOwner(self.portButton, 'ANCHOR_'..xb.miniTextPosition)
    GameTooltip:ClearLines()
    local r, g, b, _ = unpack(xb:HoverColors())
    GameTooltip:AddLine("|cFFFFFFFF[|r"..L['Travel Cooldowns'].."|cFFFFFFFF]|r", r, g, b)
    for i, v in pairs(self.portOptions) do
      if IsUsableItem(v.portId) or IsPlayerSpell(v.portId) then
        if IsUsableItem(v.portId) then
          local _, cd, _ = GetItemCooldown(v.portId)
          local cdString = self:FormatCooldown(cd)
          GameTooltip:AddDoubleLine(v.text, cdString, r, g, b, 1, 1, 1)
        end
        if IsPlayerSpell(v.portId) then
          local _, cd, _ = GetSpellCooldown(v.portId)
          local cdString = self:FormatCooldown(cd)
          GameTooltip:AddDoubleLine(v.text, cdString, r, g, b, 1, 1, 1)
        end
      end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine('<'..L['Right-Click']..'>', L['Change Port Option'], r, g, b, 1, 1, 1)
    GameTooltip:Show()
  end
end

function TravelModule:FindFirstOption()
  local firstItem = {portId = 140192, text = GetItemInfo(140192)}
  if self.portOptions then
    for k,v in pairs(self.portOptions) do
      if self:IsUsable(v.portId) then
        firstItem = v
        break
      end
    end
  end
  return firstItem
end

function TravelModule:IsUsable(id)
  return IsUsableItem(id) or IsPlayerSpell(id)
end

function TravelModule:GetDefaultOptions()
  local firstItem = self:FindFirstOption()
  xb.db.char.portItem = xb.db.char.portItem or firstItem
  return 'travel', {
    enabled = true
  }
end

function TravelModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.travel.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.travel.enabled = val
          if val then
            self:Enable()
          else
            self:Disable()
          end
        end,
        width = "full"
      }
    }
  }
end
