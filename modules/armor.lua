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
  self.durabilityAverage = 0
  self.durabilityList = {
    [INVSLOT_HEAD] = { cur = 0, max = 0, text = HEADSLOT},
    [INVSLOT_SHOULDER] =  { cur = 0, max = 0, text = SHOULDERSLOT},
    [INVSLOT_CHEST] =  { cur = 0, max = 0, text = CHESTSLOT},
    [INVSLOT_WAIST] =  { cur = 0, max = 0, text = WAISTSLOT},
    [INVSLOT_LEGS] =  { cur = 0, max = 0, text = LEGSSLOT},
    [INVSLOT_FEET] =  { cur = 0, max = 0, text = FEETSLOT},
    [INVSLOT_WRIST] =  { cur = 0, max = 0, text = WRISTSLOT},
    [INVSLOT_HAND] =  { cur = 0, max = 0, text = HANDSSLOT},
    [INVSLOT_MAINHAND] =  { cur = 0, max = 0, text = MAINHANDSLOT},
    [INVSLOT_OFFHAND] =  { cur = 0, max = 0, text = SECONDARYHANDSLOT}
  }
end

function ArmorModule:OnEnable()
  if self.armorFrame == nil then
    self.armorFrame = CreateFrame("FRAME", AUCTION_CATEGORY_ARMOR, xb:GetFrame('bar'))
    xb:RegisterFrame('armorFrame', self.armorFrame)
  end
  self.armorFrame:Show()
  self:CreateFrames()
  self:RegisterFrameEvents()
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
end

function ArmorModule:RegisterFrameEvents()
  self.armorButton:EnableMouse(true)
  self.armorButton:RegisterUnitEvent('UNIT_INVENTORY_CHANGED', 'player')

  self.armorButton:SetScript('OnEnter', function()
	if not InCombatLockdown() then
		ArmorModule:SetArmorColor()
		GameTooltip:SetOwner(ArmorModule.armorFrame, 'ANCHOR_'..xb.miniTextPosition)
		GameTooltip:AddLine("[|cff6699FF"..AUCTION_CATEGORY_ARMOR.."|r]")
		GameTooltip:AddLine(" ")
		for i,v in pairs(ArmorModule.durabilityList) do
		  if v.max ~= nil and v.max > 0 then
			local perc = floor((v.cur / v.max)  * 100)
			GameTooltip:AddDoubleLine(v.text, string.format('%d/%d (%d%%)', v.cur, v.max, perc), 1, 1, 0, 1, 1, 1)
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

function ArmorModule:SetArmorColor()
  local db = xb.db.profile
  if self.armorButton:IsMouseOver() then
    self.armorText:SetTextColor(unpack(xb:HoverColors()))
  else
    self.armorText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    if self.durabilityAverage >= db.modules.armor.durabilityMin then
      self.armorIcon:SetVertexColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    else
      self.armorIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
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

  self.armorFrame:SetSize(5 + iconSize + self.armorText:GetStringWidth(), xb:GetHeight())

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
  local total = 0
  local maxTotal = 0
  local db =  xb.db.profile.modules.armor
  local text = ''

  for i,v in pairs(self.durabilityList) do
    local curDur, maxDur = GetInventoryItemDurability(i)
    if curDur ~= nil and maxDur ~= nil then
      total = total + curDur
      maxTotal = maxTotal + maxDur
      v.cur = curDur
      v.max = maxDur
    end
  end
  self.durabilityAverage = floor((total / maxTotal) * 100)

  if self.durabilityAverage <= db.durabilityMax then
    text = text..self.durabilityAverage..'%'
  end

  if (self.durabilityAverage > db.durabilityMax) or db.alwaysShowIlvl then
    local _, equippedIlvl = GetAverageItemLevel()
    text = text..' '..floor(equippedIlvl)..' ilvl'
  end

  self.armorText:SetText(text)
end

function ArmorModule:GetDefaultOptions()
  return 'armor', {
      enabled = true,
      durabilityMin = 20,
      durabilityMax = 75,
      alwaysShowIlvl = true
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
      ilvlAlways = {
        name = L['Always Show Item Level'],
        order = 1,
        type = "toggle",
        get = function() return xb.db.profile.modules.armor.alwaysShowIlvl; end,
        set = function(_, val) xb.db.profile.modules.armor.alwaysShowIlvl = val; self:Refresh(); end
      },
      duraMin = {
        name = L['Minimum Durability to Become Active'],
        type = 'range',
        order = 2,
        min = 0,
        max = 100,
        step = 5,
        get = function() return xb.db.profile.modules.armor.durabilityMin; end,
        set = function(info, val) xb.db.profile.modules.armor.durabilityMin = val; self:Refresh(); end
      },
      duraMax = {
        name = L['Maximum Durability to Show Item Level'],
        type = 'range',
        order = 3,
        min = 0,
        max = 100,
        step = 5,
        get = function() return xb.db.profile.modules.armor.durabilityMax; end,
        set = function(info, val) xb.db.profile.modules.armor.durabilityMax = val; self:Refresh(); end
      }
    }
  }
end
