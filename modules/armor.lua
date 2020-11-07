local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local ArmorModule = xb:NewModule("ArmorModule", 'AceEvent-3.0')

function ArmorModule:GetName()
  return AUCTION_CATEGORY_ARMOR;
end

function ArmorModule:OnInitialize()
  self.iconPath = xb.constants.mediaPath..'datatexts\\repair'
  self.durabilityLowest = 0
  self.durabilityList = {
    [INVSLOT_HEAD] = { cur = 0, max = 0, pc = 0, text = HEADSLOT},
    [INVSLOT_SHOULDER] =  { cur = 0, max = 0, pc = 0, text = SHOULDERSLOT},
    [INVSLOT_CHEST] =  { cur = 0, max = 0, pc = 0, text = CHESTSLOT},
    [INVSLOT_WAIST] =  { cur = 0, max = 0, pc = 0, text = WAISTSLOT},
    [INVSLOT_LEGS] =  { cur = 0, max = 0, pc = 0, text = LEGSSLOT},
    [INVSLOT_FEET] =  { cur = 0, max = 0, pc = 0, text = FEETSLOT},
    [INVSLOT_WRIST] =  { cur = 0, max = 0, pc = 0, text = WRISTSLOT},
    [INVSLOT_HAND] =  { cur = 0, max = 0, pc = 0, text = HANDSSLOT},
    [INVSLOT_MAINHAND] =  { cur = 0, max = 0, pc = 0, text = MAINHANDSLOT},
    [INVSLOT_OFFHAND] =  { cur = 0, max = 0, pc = 0, text = SECONDARYHANDSLOT}
  }
  self.MapRects = { }
end

function ArmorModule:OnEnable()
  if self.armorFrame == nil then
    self.armorFrame = CreateFrame("FRAME", AUCTION_CATEGORY_ARMOR, xb:GetFrame('bar'))
    xb:RegisterFrame('armorFrame', self.armorFrame)
  end
  self.armorFrame:Show()
  self:CreateFrames()
  self:RegisterFrameEvents()
  self:RegisterCoordTicker()
  xb:Refresh()
end

function ArmorModule:OnDisable()
  self:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')
  self.armorFrame:Hide()
end

function ArmorModule:CreateFrames()
  self.armorButton = self.armorButton or CreateFrame('BUTTON', nil, self.armorFrame)
  self.armorIcon = self.armorIcon or self.armorButton:CreateTexture(nil, 'OVERLAY')
  self.armorText = self.armorText or self.armorButton:CreateFontString(nil, 'OVERLAY')
  self.coordText = self.coordText or self.armorButton:CreateFontString(nil, 'OVERLAY')
end

function ArmorModule:RegisterFrameEvents()
  self.armorButton:EnableMouse(true)
  self.armorButton:RegisterUnitEvent('UNIT_INVENTORY_CHANGED', 'player')

  self.armorButton:SetScript('OnEnter', function()
	if not InCombatLockdown() then
		ArmorModule:SetArmorColor()
    GameTooltip:SetOwner(ArmorModule.armorFrame, 'ANCHOR_'..xb.miniTextPosition)
    local r, g, b, _ = unpack(xb:HoverColors())
		GameTooltip:AddLine("|cFFFFFFFF[|r"..AUCTION_CATEGORY_ARMOR.."|cFFFFFFFF]|r", r, g, b)
		GameTooltip:AddLine(" ")
    for i,v in pairs(ArmorModule.durabilityList) do
      if v.max and v.max > 0 then
        local u20G, u20B = 1, 1
        if v.pc <= 20 then u20G, u20B = 0, 0 end
        GameTooltip:AddDoubleLine(v.text, string.format('%d/%d (%d%%)', v.cur, v.max, v.pc), r, g, b, 1, u20G, u20B)
		  end
		end
		GameTooltip:Show()
	end
  end)

  self.armorButton:SetScript('OnLeave', function()
	if not InCombatLockdown() then
		self:SetArmorColor()
		GameTooltip:Hide()
	end
  end)

  self.armorButton:SetScript('OnEvent', function(_, event)
    if event == 'UNIT_INVENTORY_CHANGED' then
      self:Refresh()
    end
  end)

  self:RegisterMessage('XIVBar_FrameHide', function(_, name)
    if name == 'microMenuFrame' then
      self:Refresh()
    end
  end)

  self:RegisterMessage('XIVBar_FrameShow', function(_, name)
    if name == 'microMenuFrame' then
      self:Refresh()
    end
  end)

  self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
end

function ArmorModule:RegisterCoordTicker()
  if xb.db.profile.modules.armor.showCoords then
    self.coordTicker = C_Timer.NewTicker(0.2, function()
      if InCombatLockdown() then return end
      self:UpdatePlayerCoordinates()
    end)
  end
end

function ArmorModule:SetArmorColor()
  local db = xb.db.profile
  if self.armorButton:IsMouseOver() then
    self.armorText:SetTextColor(unpack(xb:HoverColors()))
    self.coordText:SetTextColor(unpack(xb:HoverColors()))
  else
    self.armorText:SetTextColor(xb:GetColor('normal'))
    self.coordText:SetTextColor(xb:GetColor('normal'))
    -- check if the lowest durability armor piece is higher than the warning threshold
    if self.durabilityLowest > db.modules.armor.warningDurability then
      self.armorIcon:SetVertexColor(xb:GetColor('normal'))
    -- lowest durability armor piece is lower than the warning threshold, re-color armor icon red
    else
      self.armorIcon:SetVertexColor(1, 0, 0, 1)
    end
  end
end

function ArmorModule:Refresh()
  if self.armorFrame == nil then return; end
  if not xb.db.profile.modules.armor.enabled then self:Disable(); return; end

  if InCombatLockdown() then
    self:UpdateDurabilityText()
    return
  end

  local iconSize = xb:GetHeight()
  self.armorIcon:SetTexture(self.iconPath)
  --self.armorIcon:SetSize(iconSize, iconSize)
  self.armorIcon:SetPoint('LEFT')

  self.armorText:SetFont(xb:GetFont(xb.db.profile.text.fontSize))
  self:UpdateDurabilityText()
  self.armorText:SetPoint('LEFT', self.armorIcon, 'RIGHT', 5, 0)

  self.coordText:SetFont(xb:GetFont(xb.db.profile.text.fontSize))
  self.coordText:SetPoint('LEFT', self.armorText, 'RIGHT', 5, 0)

  if (self.coordTicker or self.coordTicker:IsCancelled()) and xb.db.profile.modules.armor.showCoords then
    self:RegisterCoordTicker()
  end

  self.armorFrame:SetSize(5 + iconSize + self.armorText:GetStringWidth() + self.coordText:GetStringWidth(), xb:GetHeight())

  self.armorButton:SetAllPoints()

  local relativeAnchorPoint = 'RIGHT'
  local xOffset = xb.db.profile.general.moduleSpacing

  local parentFrame = xb:GetFrame('microMenuFrame');
  if not xb.db.profile.modules.microMenu.enabled then
	parentFrame = self.armorFrame:GetParent()
    relativeAnchorPoint = 'LEFT'
    xOffset = 0
  end

  self.armorFrame:ClearAllPoints()
  self.armorFrame:SetPoint('LEFT', parentFrame, relativeAnchorPoint, xOffset, 0)
  self:SetArmorColor()
end

function ArmorModule:UPDATE_INVENTORY_DURABILITY()
  self:Refresh()
end

function ArmorModule:UpdateDurabilityText()
  local db =  xb.db.profile.modules.armor
  local text = ''
  local lowest = 101 -- store the most broken armor piece's percentage

  for i,v in pairs(self.durabilityList) do
    local curDur, maxDur = GetInventoryItemDurability(i)
    if curDur and maxDur then
      v.cur = curDur
      v.max = maxDur
      v.pc = math.floor((curDur / maxDur) * 100)
      if v.pc < lowest then lowest = v.pc end
    end
  end

  self.durabilityLowest = lowest

  -- this is the check for the warning threshold 
  if self.durabilityLowest <= db.warningDurability then
    text = '|cFFFF0000' .. text .. self.durabilityLowest .. '%|r'
  else
    text = text .. self.durabilityLowest .. '%'
  end

  -- add the equipped ilvl of the player in format "12.3"
  if db.showIlvl then
    local _, equippedIlvl = GetAverageItemLevel()
    text = text .. ' ' .. math.floor(equippedIlvl) .. ' ilvl'
  end

  self.armorText:SetText(text)
end

function ArmorModule:UpdatePlayerCoordinates()
  if not xb.db.profile.modules.armor.showCoords then
    self.coordTicker:Cancel()
    self.coordText:Hide()
    return
  end
  
  self.coordText:Show()
  local map_id = C_Map.GetBestMapForUnit('player')
  if not map_id then return end

  local rects = self.MapRects[map_id]
  if not rects then
    rects = { }
    local _, topleft = C_Map.GetWorldPosFromMapPos(map_id, CreateVector2D(0, 0))
    local _, bottomright = C_Map.GetWorldPosFromMapPos(map_id, CreateVector2D(1, 1))
    bottomright:Subtract(topleft)
    rects = { topleft.x, topleft.y, bottomright.x, bottomright.y }
    self.MapRects[map_id] = rects
  end

  local x, y = UnitPosition('player')
  if not x then return end
  x = floor(((x - rects[1]) / rects[3]) * 10000) / 100
  y = floor(((y - rects[2]) / rects[4]) * 10000) / 100

  self.coordText:SetText(y .. ', ' .. x)
end

function ArmorModule:GetDefaultOptions()
  return 'armor', {
      enabled = true,
      warningDurability = 20,
      showIlvl = true,
      showCoords = false
    }
end

function ArmorModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.armor.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.armor.enabled = val
          if val then
            self:Enable()
          else
            self:Disable()
			xb:Refresh()
          end
        end
      },
      duraMin = {
        name = L['Durability Warning Threshold'],
        type = 'range',
        order = 1,
        min = 0,
        max = 100,
        step = 5,
        get = function() return xb.db.profile.modules.armor.warningDurability; end,
        set = function(info, val) xb.db.profile.modules.armor.warningDurability = val; self:Refresh(); end
      },
      ilvlShow = {
        name = L['Show Item Level'],
        order = 2,
        type = "toggle",
        get = function() return xb.db.profile.modules.armor.showIlvl; end,
        set = function(_, val) xb.db.profile.modules.armor.showIlvl = val; self:Refresh(); end
      },
      coordShow = {
        name = L['Show Coordinates'],
        order = 3,
        type = "toggle",
        get = function() return xb.db.profile.modules.armor.showCoords; end,
        set = function(_, val) xb.db.profile.modules.armor.showCoords = val; self:Refresh(); end
      }
    }
  }
end
