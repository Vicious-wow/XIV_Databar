local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local CurrencyModule = xb:NewModule("CurrencyModule", 'AceEvent-3.0', 'AceHook-3.0')

function CurrencyModule:GetName()
  return L['Currency'];
end

function CurrencyModule:OnInitialize()
  self.rerollItems = {
    697,  -- Elder Charm of Good Fortune
    752,  -- Mogu Rune of Fate
    776,  -- Warforged Seal
    994,  -- Seal of Tempered Fate
    1129, -- Seal of Inevitable Fate
    1273, -- Seal of Broken Fate
  }

  self.intToOpt = {
    [1] = 'currencyOne',
    [2] = 'currencyTwo',
    [3] = 'currencyThree'
  }

  self.curButtons = {}
  self.curIcons = {}
  self.curText = {}
end

function CurrencyModule:OnEnable()
  if self.currencyFrame == nil then
    self.currencyFrame = CreateFrame("FRAME", 'XIV_currencyFrame', xb:GetFrame('goldFrame'))
    xb:RegisterFrame('currencyFrame', self.currencyFrame)
  end

  self:CreateFrames()
  self:RegisterFrameEvents()
  self:Refresh()
end

function CurrencyModule:OnDisable()
  self.currencyFrame:Hide()
  self:UnregisterEvent('CURRENCY_DISPLAY_UPDATE')
  self:UnregisterEvent('PLAYER_XP_UPDATE')
  self:UnregisterEvent('PLAYER_LEVEL_UP')
end

function CurrencyModule:Refresh()
  local db = xb.db.profile
  if self.currencyFrame == nil then return; end
  if not db.modules.currency.enabled then return; end

  local iconSize = db.text.fontSize + db.general.barPadding
  for i = 1, 3 do
    self.curButtons[i]:Hide()
  end
  self.xpFrame:Hide()

  if xb.constants.playerLevel < MAX_PLAYER_LEVEL and db.modules.currency.showXPbar then
    --self.xpFrame = self.xpFrame or CreateFrame("BUTTON", nil, self.currencyFrame)

    local textHeight = floor((xb:GetHeight() - 4) / 2)
    self.xpIcon:SetTexture(xb.constants.mediaPath..'datatexts\\exp')
    self.xpIcon:SetSize(iconSize, iconSize)
    self.xpIcon:SetPoint('LEFT')
    self.xpIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

    self.xpText:SetFont(xb.LSM:Fetch(xb.LSM.MediaType.FONT, db.text.font), textHeight)
    self.xpText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    self.xpText:SetText(string.upper(LEVEL..' '..tostring(xb.constants.playerLevel)..' '..UnitClass('player')))
    self.xpText:SetPoint('TOPLEFT', self.xpIcon, 'TOPRIGHT', 5, 0)

    self.xpBar:SetStatusBarTexture(1, 1, 1)
    if db.modules.currency.xpBarCC then
      self.xpBar:SetStatusBarColor(xb:GetClassColors())
    else
      self.xpBar:SetStatusBarColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
    end
    self.xpBar:SetMinMaxValues(0, UnitXPMax('player'))
    self.xpBar:SetValue(UnitXP('player'))
    self.xpBar:SetSize(self.xpText:GetStringWidth(), (iconSize - textHeight - 2))
    self.xpBar:SetPoint('BOTTOMLEFT', self.xpIcon, 'BOTTOMRIGHT', 5, 0)

    self.xpBarBg:SetAllPoints()
    self.xpBarBg:SetColorTexture(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    --self.xpBar = self.xpBar or CreateFrame('STATUSBAR', nil, self.xpFrame)
    --self.xpBarBg = self.xpBarBg or self.xpBar:CreateTexture(nil, 'BACKGROUND')
    self.currencyFrame:SetSize(iconSize + self.xpText:GetStringWidth() + 5, xb:GetHeight())
    self.xpFrame:SetAllPoints()
    self.xpFrame:Show()
  else -- show xp bar/show currencies
    local iconsWidth = 0
    for i = 1, 3 do
      if db.modules.currency[self.intToOpt[i]] ~= '0' then
        iconsWidth = iconsWidth + self:StyleCurrencyFrame(tonumber(db.modules.currency[self.intToOpt[i]]), i)
      end
    end
    self.curButtons[1]:SetPoint('LEFT')
    self.curButtons[2]:SetPoint('LEFT', self.curButtons[1], 'RIGHT', 5, 0)
    self.curButtons[3]:SetPoint('LEFT', self.curButtons[2], 'RIGHT', 5, 0)
    self.currencyFrame:SetSize(iconsWidth, xb:GetHeight())
  end -- show currencies

  --self.currencyFrame:SetSize(self.goldButton:GetSize())
  self.currencyFrame:SetPoint('RIGHT', self.currencyFrame:GetParent(), 'LEFT', -(db.general.moduleSpacing), 0)
end

function CurrencyModule:StyleCurrencyFrame(curId, i)
  local db = xb.db.profile
  local iconSize = db.text.fontSize + db.general.barPadding
  local icon = xb.constants.mediaPath..'datatexts\\garres'
  if tContains(self.rerollItems, curId) then
    icon = xb.constants.mediaPath..'datatexts\\reroll'
  end
  local _, curAmount, _ = GetCurrencyInfo(curId)

  local iconPoint = 'RIGHT'
  local textPoint = 'LEFT'
  local padding = -5

  if xb.db.profile.modules.currency.textOnRight then
    iconPoint = 'LEFT'
    textPoint = 'RIGHT'
    padding = -(padding)
  end

  self.curIcons[i]:ClearAllPoints()
  self.curText[i]:ClearAllPoints()

  self.curIcons[i]:SetTexture(icon)
  self.curIcons[i]:SetSize(iconSize, iconSize)
  self.curIcons[i]:SetPoint(iconPoint)
  self.curIcons[i]:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

  self.curText[i]:SetFont(xb.LSM:Fetch(xb.LSM.MediaType.FONT, db.text.font), db.text.fontSize)
  self.curText[i]:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  self.curText[i]:SetText(curAmount)
  self.curText[i]:SetPoint(iconPoint, self.curIcons[i], textPoint, padding, 0)

  local buttonWidth = iconSize + self.curText[i]:GetStringWidth() + 5
  self.curButtons[i]:SetSize(buttonWidth, xb:GetHeight())
  self.curButtons[i]:Show()
  return buttonWidth
end

function CurrencyModule:CreateFrames()
  for i = 1, 3 do
    self.curButtons[i] = self.curButtons[i] or CreateFrame("BUTTON", nil, self.currencyFrame)
    self.curIcons[i] = self.curIcons[i] or self.curButtons[i]:CreateTexture(nil, 'OVERLAY')
    self.curText[i] = self.curText[i] or self.curButtons[i]:CreateFontString(nil, "OVERLAY")
    self.curButtons[i]:Hide()
  end

  self.xpFrame = self.xpFrame or CreateFrame("BUTTON", nil, self.currencyFrame)
  self.xpIcon = self.xpIcon or self.xpFrame:CreateTexture(nil, 'OVERLAY')
  self.xpText = self.xpText or self.xpFrame:CreateFontString(nil, 'OVERLAY')
  self.xpBar = self.xpBar or CreateFrame('STATUSBAR', nil, self.xpFrame)
  self.xpBarBg = self.xpBarBg or self.xpBar:CreateTexture(nil, 'BACKGROUND')
  self.xpFrame:Hide()
end

function CurrencyModule:RegisterFrameEvents()

  for i = 1, 3 do
    self.curButtons[i]:EnableMouse(true)
    self.curButtons[i]:RegisterForClicks("AnyUp")
    self.curButtons[i]:SetScript('OnEnter', function()
      if InCombatLockdown() then return; end
      self.curText[i]:SetTextColor(unpack(xb:HoverColors()))
      if xb.db.profile.modules.currency.showTooltip then
        self:ShowTooltip()
      end
    end)
    self.curButtons[i]:SetScript('OnLeave', function()
      if InCombatLockdown() then return; end
      local db = xb.db.profile
      self.curText[i]:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
      if xb.db.profile.modules.currency.showTooltip then
        GameTooltip:Hide()
      end
    end)
    self.curButtons[i]:SetScript('OnClick', function()
      if InCombatLockdown() then return; end
      ToggleCharacter('TokenFrame')
    end)
  end
  self:RegisterEvent('CURRENCY_DISPLAY_UPDATE', 'Refresh')
  self:RegisterEvent('PLAYER_XP_UPDATE', 'Refresh')
  self:RegisterEvent('PLAYER_LEVEL_UP', 'Refresh')
  --self:SecureHook('BackpackTokenFrame_Update', 'Refresh') -- Ugh, why is there no event for this?

  self.currencyFrame:EnableMouse(true)
  self.currencyFrame:SetScript('OnEnter', function()
    if xb.db.profile.modules.currency.showTooltip then
      self:ShowTooltip()
    end
  end)
  self.currencyFrame:SetScript('OnLeave', function()
    if xb.db.profile.modules.currency.showTooltip then
      GameTooltip:Hide()
    end
  end)

  self.xpFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    self.xpText:SetTextColor(unpack(xb:HoverColors()))
  end)

  self.xpFrame:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    local db = xb.db.profile
    self.xpText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  end)
  --[[
  self.goldButton:EnableMouse(true)
  self.goldButton:RegisterForClicks("AnyUp")

  self.goldButton:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    self.goldText:SetTextColor(unpack(xb:HoverColors()))
    self.bagText:SetTextColor(unpack(xb:HoverColors()))

    GameTooltip:SetOwner(CurrencyModule.goldFrame, 'ANCHOR_'..xb.miniTextPosition)
    GameTooltip:AddLine("[|cff6699FF"..L['Gold'].."|r - |cff82c5ff"..xb.constants.playerFactionLocal.." "..xb.constants.playerRealm.."|r]")
    GameTooltip:AddLine(" ")

    local totalGold = 0
    for charName, goldData in pairs(xb.db.factionrealm) do
      GameTooltip:AddDoubleLine(charName, CurrencyModule:FormatCoinText(goldData.currentMoney), 1, 1, 0, 1, 1, 1)
      totalGold = totalGold + goldData.currentMoney
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(L['Total'], CurrencyModule:FormatCoinText(totalGold), 1, 1, 0, 1, 1, 1)
    GameTooltip:AddDoubleLine('<'..L['Left-Click']..'>', L['Toggle Bags'], 1, 1, 0, 1, 1, 1)
    GameTooltip:Show()
  end)

  self.goldButton:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    local db = xb.db.profile
    self.goldText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    self.bagText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    GameTooltip:Hide()
  end)

  self.goldButton:SetScript('OnClick', function(_, button)
    if InCombatLockdown() then return; end
    ToggleAllBags()
  end)]]--
end

function CurrencyModule:ShowTooltip()
  if xb.constants.playerLevel < MAX_PLAYER_LEVEL and xb.db.profile.modules.currency.showXPbar then return; end
  GameTooltip:SetOwner(self.currencyFrame, 'ANCHOR_'..xb.miniTextPosition)
  GameTooltip:AddLine("[|cff6699FF"..L['Currency'].."|r]")
  GameTooltip:AddLine(" ")

  for i = 1, 3 do
    if xb.db.profile.modules.currency[self.intToOpt[i]] ~= '0' then
      local curId = tonumber(xb.db.profile.modules.currency[self.intToOpt[i]])
      local name, count, _, _, _, totalMax, _, _ = GetCurrencyInfo(curId)
      GameTooltip:AddDoubleLine(name, string.format('%d/%d', count, totalMax), 1, 1, 0, 1, 1, 1)
    end
  end

  GameTooltip:AddLine(" ")
  GameTooltip:AddDoubleLine('<'..L['Left-Click']..'>', L['Toggle Currency Frame'], 1, 1, 0, 1, 1, 1)
  GameTooltip:Show()
end

function CurrencyModule:GetCurrencyOptions()
  local curOpts = {
    ['0'] = ''
  }
  for i = 1, GetCurrencyListSize() do
    local _, isHeader, _, isUnused = GetCurrencyListInfo(i)
    if not isHeader and not isUnused then
      local cL = GetCurrencyListLink(i)
      local colon, _ = strfind(cL, ':', 1, true)
      local pipeS, _ = strfind(cL, '|h', colon, true)
      local itemId = strsub(cL, colon + 1, pipeS - 1)
      local name, _ = GetCurrencyInfo(itemId)
      curOpts[tostring(itemId)] = name
    end
  end
  return curOpts
end

function CurrencyModule:GetDefaultOptions()
  return 'currency', {
      enabled = true,
      showXPbar = true,
      xpBarCC = false,
      showTooltip = true,
      textOnRight = true,
      currencyOne = '0',
      currencyTwo = '0',
      currencyThree = '0'
    }
end

function CurrencyModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.currency.enabled; end,
        set = function(_, val) xb.db.profile.modules.currency.enabled = val; self:Refresh(); end,
        width = "full"
      },
      showXPbar = {
        name = L['Show XP Bar Below Max Level'],
        order = 1,
        type = "toggle",
        get = function() return xb.db.profile.modules.currency.showXPbar; end,
        set = function(_, val) xb.db.profile.modules.currency.showXPbar = val; self:Refresh(); end
      },
      xpBarCC = {
        name = L['Use Class Colors for XP Bar'],
        order = 2,
        type = "toggle",
        get = function() return xb.db.profile.modules.currency.xpBarCC; end,
        set = function(_, val) xb.db.profile.modules.currency.xpBarCC = val; self:Refresh(); end,
        disabled = function() return not xb.db.profile.modules.currency.showXPbar end
      },
      showTooltip = {
        name = L['Show Tooltips'],
        order = 3,
        type = "toggle",
        get = function() return xb.db.profile.modules.currency.showTooltip; end,
        set = function(_, val) xb.db.profile.modules.currency.showTooltip = val; self:Refresh(); end
      },
      textOnRight = {
        name = L['Text on Right'],
        order = 4,
        type = "toggle",
        get = function() return xb.db.profile.modules.currency.textOnRight; end,
        set = function(_, val) xb.db.profile.modules.currency.textOnRight = val; self:Refresh(); end
      },
      currency = {
        type = 'group',
        name = L['Currency Select'],
        order = 5,
        inline = true,
        --disabled = function() return (xb.constants.playerLevel < MAX_PLAYER_LEVEL and xb.db.profile.modules.currency.showXPbar); end, -- keep around in case
        args = {
          currencyOne = {
            name = L['First Currency'], -- DROPDOWN, GoldModule:GetCurrencyOptions
            type = "select",
            order = 1,
            values = function() return self:GetCurrencyOptions(); end,
            style = "dropdown",
            get = function() return xb.db.profile.modules.currency.currencyOne; end,
            set = function(info, value) xb.db.profile.modules.currency.currencyOne = value; self:Refresh(); end,
          },
          currencyTwo = {
            name = L['Second Currency'], -- DROPDOWN, GoldModule:GetCurrencyOptions
            type = "select",
            order = 2,
            values = function() return self:GetCurrencyOptions(); end,
            style = "dropdown",
            get = function() return xb.db.profile.modules.currency.currencyTwo; end,
            set = function(info, value) xb.db.profile.modules.currency.currencyTwo = value; self:Refresh(); end,
          },
          currencyThree = {
            name = L['Third Currency'], -- DROPDOWN, GoldModule:GetCurrencyOptions
            type = "select",
            order = 3,
            values = function() return self:GetCurrencyOptions(); end,
            style = "dropdown",
            get = function() return xb.db.profile.modules.currency.currencyThree; end,
            set = function(info, value) xb.db.profile.modules.currency.currencyThree = value; self:Refresh(); end,
          }
        }
      }
    }
  }
end
