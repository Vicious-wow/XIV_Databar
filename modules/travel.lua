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
    142542, -- Tome of Town Portal                    - Diablo 20th Anniversary
     54452, -- Ethereal Portal                        - TCG
     93672, -- Dark Portal                            - TCG
    169064, -- Mountebank's Colorful Cloak            - Mechagon
    142298, -- Astonishingly Scarlet Slippers         - Return to Karazhan
     28585, -- Ruby Slippers                          - Karazhan
    163045, -- Headless Horseman's Hearthstone        - Hallows Eve
    165669, -- Lunar Elder's Hearthstone              - Lunar Festival
    165670, -- Peddlefeet's Hearthstone               - Love is in the Air
    165802, -- Noble Gardener's Hearthstone           - Noblegarden
    166746, -- Fire Eater's Hearthstone               - Midsummer Fire Festival
    166747, -- Brewfest Reveler's Hearthstone         - Brewfest
    162973, -- Greatfather Winter's Hearthstone       - Winter Veil
    168907, -- Holographic Digitalization Hearthstone - Mechagon
    172179, -- Eternal Traveler's Hearthstone         - Shadowlands Epic Edition
     40582, -- Death Knight's Scourgestone            - Death Knight Starting Experience
     64488, -- The Innkeeper's Daughter               - Archaeology Toy
       556, -- Astral Recall                          - Shaman Ability
      6948, -- Hearthstone                            - Base Item
     44315, -- Scroll of Recall 3                     - Inscription
     44314, -- Scroll of Recall 2                     - Inscription, shaky after lvl 70
     37118, -- Scroll of Recall 1                     - Inscription, shaky after lvl 40
  }
  -- Get a count of elements for Hearthstone-like items
  self.hearthstonesSize = 0
  for _ in pairs(self.hearthstones) do self.hearthstonesSize = self.hearthstonesSize + 1 end

  -- Get a count of elements for Ports
  self.portOptionsSize = 0
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
    self.hearthFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
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
  self.hearthButton = self.hearthButton or CreateFrame('BUTTON', "hearthButton", self.hearthFrame, "SecureActionButtonTemplate")
  self.hearthIcon = self.hearthIcon or self.hearthButton:CreateTexture(nil, 'OVERLAY')
  self.hearthText = self.hearthText or self.hearthButton:CreateFontString(nil, 'OVERLAY')

  self.portButton = self.portButton or CreateFrame('BUTTON', "portButton", self.hearthFrame, "SecureActionButtonTemplate")
  self.portIcon = self.portIcon or self.portButton:CreateTexture(nil, 'OVERLAY')
  self.portText = self.portText or self.portButton:CreateFontString(nil, 'OVERLAY')

  self.portPopup = self.portPopup or CreateFrame('BUTTON', "portPopup", self.portButton, BackdropTemplateMixin and "BackdropTemplate")
  local backdrop = GameTooltip:GetBackdrop()
  if backdrop and (not self.useElvUI) then
    self.portPopup:SetBackdrop(backdrop)
    self.portPopup:SetBackdropColor(GameTooltip:GetBackdropColor())
    self.portPopup:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
  end
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
      TravelModule:UpdatePortOptions()
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
    TravelModule:UpdateHearthButton()
  end)

  self.hearthButton:SetScript('OnLeave', function()
    TravelModule:UpdateHearthButton()
  end)

  self.portButton:SetScript('OnEnter', function()
    TravelModule:UpdatePortOptions()
    TravelModule:UpdatePortButton()
    self:ShowTooltip()
  end)

  self.portButton:SetScript('OnLeave', function()
    TravelModule:UpdatePortButton()
    GameTooltip:Hide()
  end)
end

function TravelModule:UpdatePortOptions()
  if not self:PlayerIsIdle() then return; end

  -- CURRENT
  -- Warlords Admiral's Compass -> Garrison Shipyard
  -- Legion Dalaran Hearthstone -> Dalaran
  -- Warlords Garrison Hearthstone
  -- Legion Order Hall Teleports
  --  DK gets early (Death Gate)
  --  Druid gets early (Teleport: Moonglade/Dreamwalk)
  --  Monk gets early (Zen Pilgrimage)
  -- Mage Teleports

  -- PROPOSED
  --  TelePortals
  --   Legion Order Hall Teleports
  --    DK Death Gate
  --    Druid Moonglade/Dreamwalk
  --    Monk Zen Pilgrimage
  --   Mage Teleports
  --  Home Teleports
  --   Admiral's Compass
  --   Dalaran Hearthstone
  --   Garrison Hearthstone

  -- Home Teleports
  -- Handles Mikeprod/XIV_Databar#27
  local itemIDs = {
    140192, -- Dalaran Hearthstone             - Dalaran, Broken Isles - Legion  - Lvl 100
    139599, -- Empowered Ring of the Kirin Tor - Dalaran, Broken Isles - Legion
    128353, -- Admiral's Compass               - Garrison Shipyard     - WoD     - Lvl 100
     40586, -- Band of the Kirin Tor           - Dalaran, Northrend    - WotLK   - Lvl 80
     44934, -- Loop
     44935, -- Ring
     40585, -- Signet
     45688, -- Inscribed Band
     45689, -- Inscribed Loop
     45690, -- Inscribed Ring
     45691, -- Inscribed Signet
     48954, -- Etched Band
     48955, -- Etched Loop
     48956, -- Etched Ring
     48957, -- Etched Signet
     51560, -- Runed Band
     51558, -- Runed Loop
     51559, -- Runed Ring
     51557, -- Runed Signet
     52251, -- Jaina's Locket
     65360, -- Stormwind Guild Cloak           - Epic     - Lvl 35     - Cata    - Guild:Master Crafter - Craft 500 Epics iLvl >= 108 (Lvl 85)
     63206, -- Stormwind Guild Cloak           - Rare     - Lvl 35     - Vanilla - Guild:Honored Reputation
     63352, -- Stormwind Guild Cloak           - Uncommon - Lvl 35     - SLands  - Guild:A Class Act - Max Lvl on all classes (Lvl 60)
     65274, -- Orgrimmar Guild Cloak           - Epic
     63207, -- Orgrimmar Guild Cloak           - Rare
     63353, -- Orgrimmar Guild Cloak           - Uncommon
  }
  for _, itemID in pairs(itemIDs) do
    self:AddPortOption(itemID)
  end

  -- Garrison Hearthstone
  self:AddPortOption({ portId = self.garrisonHearth, spellLabel = GARRISON_LOCATION_TOOLTIP })

  -- DK
  --  Death Gate (55)
  -- Druid
  --  Dreamwalk (98)/Moonglade (14)
  -- Mage
  --  Teleport (17)
  --   Hall of the Guardian (98)
  -- Monk
  --  Zen Pilgrimage (20)
  --   Updated Zen Pilgrimage (98)

  local spellID = 0
  local spellIDs = {}
  -- Death Knight
  spellID = 50977 -- Death Gate
  if xb.constants.playerClass == 'DEATHKNIGHT' and self:IsUsable(spellID) then
    self:AddPortOption({ portId = spellID, spellLabel = ORDER_HALL_DEATHKNIGHT })
  end

  -- Druid
  -- Druid not getting Moonglade as a menu option or in Travel Cooldowns tooltip
  if xb.constants.playerClass == 'DRUID' then
    spellID = 193753 -- Dreamwalk
    if (not self.portOptions or not self.portOptions[spellID]) and self:IsUsable(spellID) then
      self:AddPortOption({ portId = spellID, spellLabel = ORDER_HALL_DRUID })
    else
      -- Dreamwalk not available
      spellID = 18960 -- Teleport: Moonglade
      if (not self.portOptions or not self.portOptions[spellID]) and self:IsUsable(spellID) then
        self:AddPortOption(spellID)
      end
    end
  end

  -- Mage
  spellID = 193759 -- Teleport: Hall of the Guardian
  if xb.constants.playerClass == 'MAGE' then
    self:AddPortOption({ portId = spellID, spellLabel = ORDER_HALL_MAGE })
    spellIDs = {
      -- Alliance
        3565, -- Darnassus
       32271, -- Exodar
        3562, -- Ironforge
        3561, -- Stormwind
       49359, -- Theramore

      -- Horde
        3567, -- Orgrimmar
       32272, -- Silvermoon
        3566, -- Thunder Bluff
        3563, -- Undercity
       49358, -- Stonard

      -- Neutral
       53140, -- Dalaran - Northrend
       33690, -- Shattrath - Alliance
       35715, -- Shattrath - Horde
       88342, -- Tol Barad - Alliance
       88344, -- Tol Barad - Horde
      120145, -- Dalaran Crater

      -- Pandaria
      132621, -- Alliance Shrine
      132627, -- Horde Shrine

      -- Ashran
      176248, -- Alliance
      176242, -- Horde

      -- Neutral
      224869, -- Dalaran - Broken Isles

      -- BfA
      281403, -- Alliance
      281404, -- Horde
    }
    for _, spellID in pairs(spellIDs) do
      self:AddPortOption(spellID)
    end
  end

  -- Monk
  if xb.constants.playerClass == 'MONK' then
    spellIDs = {
      [1] = 126892, -- Base Zen Pilgrimage
      [2] = 293866, -- Zen Pilgrimage - Return
      [3] = 200617, -- Upgraded Zen Pilgrimage
    }
    local mapID = 379 -- Kun-Lai Summit
    local kls = C_Map.GetMapInfo(mapID)
    local zone = GetZoneText()
    local portText = ""

    -- Base Zen Pilgrimage
    spellID = spellIDs[1]

    -- Upgraded Zen Pilgrimage
    if self:IsUsable(spellIDs[3]) then
      spellID = spellIDs[3]
      portText = ORDER_HALL_MONK
    end

    self:AddPortOption({ portId = spellID, spellLabel = portText })
  end
end

function TravelModule:FormatCooldown(cdTime)
  if cdTime ~= nil and cdTime <= 0 then
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

function TravelModule:AddPortOption(port)
  if not self:PlayerIsIdle() then return; end

  spellID = port
  spellMacro = ""
  spellLabel = ""
  -- If we've got a table, try to get the ID and Text
  if type(port) == "table" then
    if port.portId then
      spellID = port.portId
    end
    if port.spellLabel then
      spellLabel = port.spellLabel
    end
  end
  -- If we've got a Spell ID
  -- If we haven't saved it yet
  -- If it's usable
  if spellID and ((not self.portOptions) or (not self.portOptions[spellID])) and self:IsUsable(spellID) then
    -- If it's an Item
    if self:IsUsableItem(spellID) then
      -- Get the Item Name
      spellMacro = GetItemInfo(spellID)
    end
    -- If it's a Spell
    if self:IsUsableSpell(spellID) then
      -- Get the Spell Name
      spellMacro = GetSpellInfo(spellID)
    end

    if spellMacro ~= "" then
      if spellLabel == "" then
        spellLabel = spellMacro
      end
      -- Try to trim "Teleport" off of it
      local idx = string.find(spellLabel, ':')
      if idx then
        spellLabel = string.sub(spellLabel, idx + 1)
        local a = string.match(spellLabel, '^%s*()')
        local b = string.match(spellLabel, '()%s*$', a)
        spellLabel = string.sub(spellLabel, a, b-1)
      end

      if not self.portOptions then
        self.portOptions = {}
      end

      self.portOptions[spellID] = {
        activeObject = self:IsReady(spellID),
        portId = spellID,
        spellLabel = spellLabel,
        spellMacro = spellMacro
      }
      self.portOptionsSize = self.portOptionsSize + 1
    end
  end
end

function TravelModule:GetAvailableObject(objectIDs,objectSize)
  if not self:PlayerIsIdle() then return; end

  local hearthActive = false
  local hearthSpell = ""
  local hearthText = ""
  local v = nil

  for i=1, objectSize do
    v = objectIDs[i]
    if not hearthActive then
      if type(v) == "table" and v.portId ~= nil then
        v = v.portId
      end
      -- FIXME: Getting a Table without a portId
      if self:IsUsable(v) then
        -- If it's an Item or Toy
        if self:IsReadyItem(v) then
          hearthSpell = GetItemInfo(v)
          if hearthSpell then
            hearthActive = true
            hearthText = hearthSpell
            break
          else
            hearthSpell = "item:" .. v
            break
          end -- Couldn't get Name
        else -- Not an Item or Toy or isn't Ready
          -- If it's a Spell
          if self:IsReadySpell(v) then
            hearthSpell = GetSpellInfo(v)
            if hearthSpell then
              hearthActive = true
              hearthText = hearthSpell
              break
            end -- Couldn't get Name
          end -- Not a Spell or isn't Ready
        end -- Not an Item, Toy or Spell or isn't Ready
      end -- Not Usable
    end -- Haven't found an Active Hearth yet
  end -- Iterate through Hearthstone-like items

  local idx = string.find(hearthText, ':')
  if idx then
    hearthText = string.sub(hearthText, idx + 1)
    local a = string.match(hearthText, '^%s*()')
    local b = string.match(hearthText, '()%s*$', a)
    hearthText = string.sub(hearthText, a, b-1)
  end

  return { activeObject = hearthActive, portId = v, spellMacro = hearthSpell, spellLabel = hearthText }
end

function TravelModule:GetAvailableHearth()
  if not self:PlayerIsIdle() then return; end

  local hearth = self:GetAvailableObject(self.hearthstones,self.hearthstonesSize)
  return { activeObject = hearth.activeObject, portId = hearth.portId, spellMacro = hearth.spellMacro, spellLabel = GetBindLocation() }
end

function TravelModule:SetHearthSpell(hearth)
  if not self:PlayerIsIdle() then return; end

  if hearth.activeObject then
    if hearth.spellMacro and hearth.spellMacro ~= "" then
      self.hearthButton:SetAttribute("macrotext", "/use " .. hearth.spellMacro)
    end
  end
end

function TravelModule:SetHearthText(hearth)
  if not self:PlayerIsIdle() then return; end

  if self.hearthText:GetFont() == nil then
    local db = xb.db.profile
    self.hearthText:SetFont(xb:GetFont(db.text.fontSize))
  end

  if hearth.activeObject and hearth.spellLabel then
    self.hearthText:SetText(hearth.spellLabel)
  end
end

function TravelModule:SetHearthColor(hearth)
  if not self:PlayerIsIdle() then return; end

  local db = xb.db.profile
  inactive = { db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a }
  active = { db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a }

  if self.hearthButton:IsMouseOver() then
    self.hearthText:SetTextColor(unpack(xb:HoverColors()))
  else
    self.hearthIcon:SetVertexColor(unpack(inactive))
    if hearth.activeObject and hearth.spellMacro then
      self.hearthIcon:SetVertexColor(unpack(active))
    end
    self.hearthText:SetTextColor(unpack(inactive))
  end
end

function TravelModule:UpdateHearthButton()
  if not self:PlayerIsIdle() then return; end

  local hearth = self:GetAvailableHearth()

  self:SetHearthSpell(hearth)
  self:SetHearthText(hearth)
  self:SetHearthColor(hearth)

  self:InitializePortButton(hearth)
end

function TravelModule:GetAvailablePort(v)
  if not self:PlayerIsIdle() then return; end

  local port = nil

  if not v or not self:IsReady(v) then
    port = xb.db.char.portItem
    v = port.portId
    if not v or not self:IsReady(v) then
      port = self:GetAvailableHearth()
      v = port.portId
    end
  end

  if port then
    if self.portOptionsSize <= 0 then
      port = self:GetAvailableObject(port, 1)
      for _, hId in pairs(self.hearthstones) do
        if port.portId == hId then
          port.spellLabel = GetBindLocation()
        end
      end
    end
  end

  return port
end

function TravelModule:SetPortSpell(port)
  if not self:PlayerIsIdle() then return; end

  if port.activeObject and port.spellMacro and port.spellMacro ~= "" then
    self.portButton:SetAttribute("macrotext", "/use " .. port.spellMacro)
  end
end

function TravelModule:SetPortText(port)
  if not self:PlayerIsIdle() then return; end

  if self.portText:GetFont() == nil then
    local db = xb.db.profile
    self.portText:SetFont(xb:GetFont(db.text.fontSize))
  end

  if port.spellLabel and port.spellLabel ~= "" and port.spellLabel ~= "your inn" then
    self.portText:SetText(port.spellLabel)
  end
end

function TravelModule:SetPortColorNew(port)
  if not self:PlayerIsIdle() then return; end

  local db = xb.db.profile
  inactive = { db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a }
  active = { db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a }

  if self.portButton:IsMouseOver() then
    self.portText:SetTextColor(unpack(xb:HoverColors()))
  else
    self.portIcon:SetVertexColor(unpack(inactive))
    if port.activeObject and port.spellMacro then
      self.portIcon:SetVertexColor(unpack(active))
    end
    self.portText:SetTextColor(unpack(inactive))
  end
end

function TravelModule:UpdatePortButton(port)
  if not self:PlayerIsIdle() then return; end

  if port == nil then
    port = self:GetAvailablePort()
    if port == nil or self.portOptionsSize <= 0 then
      port = self:GetAvailableHearth()
    end
  end

  self:SetPortSpell(port)
  self:SetPortText(port)
  self:SetPortColorNew(port)
end

function TravelModule:InitializePortButton(hearth)
  -- print("Initializing Port Button!")

  if hearth == nil then
    hearth = TravelModule:GetAvailableHearth()
  end

  if hearth.activeObject and (TravelModule.portButton:GetAttribute("macrotext") == nil or TravelModule.portButton:GetAttribute("macrotext") == "" or TravelModule.portText:GetText() == nil or TravelModule.portText:GetText() == "" or TravelModule.portText:GetText() == "your inn") then
    TravelModule:UpdatePortButton(hearth)
  end
end

function TravelModule:SetPortColor()
  if not self:PlayerIsIdle() then return; end

  local db = xb.db.profile
  -- Figure out how this is set for default
  local v = xb.db.char.portItem.portId

  if not (self:IsReady(v)) then
    v = self:FindFirstOption()
    v = v.portId
    if not (self:IsReady(v)) then
      --self.portButton:Hide()
      return
    end
  end

  if self.portButton:IsMouseOver() then
    self.portText:SetTextColor(unpack(xb:HoverColors()))
  else
    self:UpdatePortButton(v)
  end --else
end

function TravelModule:CreatePortPopup()
  if not self:PlayerIsIdle() then return; end

  if self.portOptionsSize <= 0 then return; end

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
  for i, _ in pairs(self.portOptions) do
    local v = self.portOptions[i]
    if self.portButtons[v.portId] == nil then
      if self:IsUsable(v.portId) then
        local button = CreateFrame('BUTTON', nil, self.portPopup)
        local buttonText = button:CreateFontString(nil, 'OVERLAY')

        buttonText:SetFont(xb:GetFont(db.text.fontSize))
        buttonText:SetTextColor(unpack(inactive))
        if v.spellLabel then
          buttonText:SetText(v.spellLabel)
        end
        buttonText:SetPoint('LEFT')
        local textWidth = buttonText:GetStringWidth()

        button:SetID(v.portId)
        button:SetSize(textWidth, db.text.fontSize)
        button.isSettable = true
        button.portItem = v

        button:EnableMouse(true)
        button:RegisterForClicks('LeftButtonUp')

        button:SetScript('OnEnter', function()
          buttonText:SetTextColor(unpack(active))
        end)

        button:SetScript('OnLeave', function()
          buttonText:SetTextColor(unpack(inactive))
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
      end -- Not Usable
    else
      if not self:IsUsable(v.portId) then
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
  if not self:PlayerIsIdle() then return; end

  if self.hearthFrame == nil then return; end

  if not xb.db.profile.modules.travel.enabled then self:Disable(); return; end

  self:UpdatePortOptions()

  local db = xb.db.profile
  barcolor = { db.color.barColor.r, db.color.barColor.g, db.color.barColor.b, db.color.barColor.a }

  local iconSize = db.text.fontSize + db.general.barPadding

  self.hearthButton:SetSize(self.hearthText:GetWidth() + iconSize + db.general.barPadding, xb:GetHeight())
  self.hearthButton:SetPoint("RIGHT")

  self.hearthIcon:SetTexture(xb.constants.mediaPath..'datatexts\\hearth')
  self.hearthIcon:SetSize(iconSize, iconSize)
  self.hearthIcon:SetPoint("RIGHT", self.hearthText, "LEFT", -(db.general.barPadding), 0)

  self.hearthText:SetFont(xb:GetFont(db.text.fontSize))
  self.hearthText:SetPoint("RIGHT")
  self:UpdateHearthButton()

  self.portButton:SetSize(self.portText:GetWidth() + iconSize + db.general.barPadding, xb:GetHeight())
  self.portButton:SetPoint("LEFT", -(db.general.barPadding), 0)

  self.portIcon:SetTexture(xb.constants.mediaPath..'datatexts\\garr')
  self.portIcon:SetSize(iconSize, iconSize)
  self.portIcon:SetPoint("RIGHT", self.portText, "LEFT", -(db.general.barPadding), 0)

  self.portText:SetFont(xb:GetFont(db.text.fontSize))
  self.portText:SetPoint("RIGHT")
  if xb.db.char.portItem.spellLabel and xb.db.char.portItem.spellLabel ~= "" then
    self:UpdatePortButton(xb.db.char.portItem)
  end
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
  if not self:PlayerIsIdle() then return; end

  if not self.portPopup:IsVisible() then
    if self.portOptionsSize > 0 then
      GameTooltip:SetOwner(self.portButton, 'ANCHOR_'..xb.miniTextPosition)
      GameTooltip:ClearLines()
      local r, g, b, _ = unpack(xb:HoverColors())
      GameTooltip:AddLine("|cFFFFFFFF[|r"..L['Travel Cooldowns'].."|cFFFFFFFF]|r", r, g, b)
      for i, v in pairs(self.portOptions) do
        if self:IsUsable(v.portId) then
          local start = 0
          local cd = 0
          local time = GetTime()
          if self:IsUsableItem(v.portId) then
            start, cd, _ = GetItemCooldown(v.portId)
          end
          if self:IsUsableSpell(v.portId) then
            start, cd, _ = GetSpellCooldown(v.portId)
          end
          local cdString = self:FormatCooldown(start + cd - time)
          GameTooltip:AddDoubleLine(v.spellLabel, cdString, r, g, b, 1, 1, 1)
        end
      end
      GameTooltip:AddLine(" ")
      GameTooltip:AddDoubleLine('<'..L['Right-Click']..'>', L['Change Port Option'], r, g, b, 1, 1, 1)
      GameTooltip:Show()
    end
  end
end

function TravelModule:FindFirstOption()
  if not self:PlayerIsIdle() then return; end

  -- Default to Hearthstone
  local firstItemID = 6948 -- Hearthstone
  local firstItem = { portId = firstItemID, spellLabel = GetBindLocation() }
  local itemFound = false

  -- If we don't have Port Options, cycle through Hearthstones
  if not self.portOptions then
    if self.hearthstones then
      for i, v in ipairs(self.hearthstones) do
        local hearth = self.hearthstones[i]
        if self:IsReady(hearth) then
          firstItem["portId"] = hearth
          firstItem["spellMacro"] = "item:" .. hearth
          itemFound = true
          break
        end
      end
    end
  end

  -- If we didn't find a suitable item, cycle through Port Options
  if not itemFound then
    if self.portOptions then
      for i, v in ipairs(self.portOptions) do
        local port = self.portOptions[i]
        if self:IsReady(port.portId) then
          firstItem = port
          itemFound = true
          break
        end
      end
    end
  end

  -- If we still failed, default to Hearthstone and hope for the best

  return firstItem
end

-- True if Item or Toy
function TravelModule:IsUsableItem(id)
  if type(id) == "table" then
    id = id.portId
  end

  if id == nil then return false; end

  return IsUsableItem(id) or PlayerHasToy(id)
end

-- True if Item or Toy and is Ready
function TravelModule:IsReadyItem(id)
  return self:IsUsableItem(id) and GetItemCooldown(id) == 0
end

-- True if Spell
function TravelModule:IsUsableSpell(id)
  if type(id) == "table" then
    id = id.portId
  end

  if id == nil then return false; end
  return IsPlayerSpell(id)
end

-- True if Spell and is Ready
function TravelModule:IsReadySpell(id)
  return self:IsUsableSpell(id) and GetSpellCooldown(id) == 0
end

-- True if Item, Toy or Spell
function TravelModule:IsUsable(id)
  if id == nil then return false; end
  return self:IsUsableItem(id) or self:IsUsableSpell(id)
end

-- True if Item, Toy or Spell and is Ready
function TravelModule:IsReady(id)
  if id == nil then return false; end
  return self:IsReadyItem(id) or self:IsReadySpell(id)
end

-- Is player in combat?
function TravelModule:IsInCombat()
  return InCombatLockdown()
end

-- Is player casting?
function TravelModule:IsCasting()
  return UnitCastingInfo("player")
end

-- Is player channeling?
function TravelModule:IsChanneling()
  return UnitChannelInfo("player")
end

-- Are we doing nothing?
function TravelModule:PlayerIsIdle()
  return not (self:IsInCombat() or self:IsCasting() or self:IsChanneling())
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
