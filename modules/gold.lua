local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local GoldModule = xb:NewModule("GoldModule", 'AceEvent-3.0')

function GoldModule:GetName()
  return L['Gold'];
end

function GoldModule:OnInitialize()

end

function GoldModule:OnEnable()
  if self.goldFrame == nil then
    self.goldFrame = CreateFrame("FRAME", nil, xb:GetFrame('hearthFrame'))
    xb:RegisterFrame('goldFrame', self.goldFrame)
  end
  if xb.db.factionrealm[xb.constants.playerName] == nil then
    xb.db.factionrealm[xb.constants.playerName] = {currentMoney = GetMoney()}
  else
    xb.db.factionrealm[xb.constants.playerName].currentMoney = GetMoney()
  end

  self:CreateFrames()
  self:RegisterFrameEvents()
  self:Refresh()
end

function GoldModule:OnDisable()
  self.goldFrame:Hide()
  self:UnregisterEvent('PLAYER_MONEY')
  self:UnregisterEvent('BAG_UPDATE')
end

function GoldModule:Refresh()
  local db = xb.db.profile
  if self.goldFrame == nil then return; end
  if not db.modules.gold.enabled then return; end

  if InCombatLockdown() then
    self.goldText:SetText(self:FormatCoinText(GetMoney()))
    if db.modules.gold.showFreeBagSpace then
      local freeSpace = 0
      for i = 0, 4 do
        freeSpace = freeSpace + GetContainerNumFreeSlots(i)
      end
      self.bagText:SetText('('..tostring(freeSpace)..')')
    end
    return
  end

  local iconSize = db.text.fontSize + db.general.barPadding
  self.goldIcon:SetTexture(xb.constants.mediaPath..'datatexts\\gold')
  self.goldIcon:SetSize(iconSize, iconSize)
  self.goldIcon:SetPoint('LEFT')
  self.goldIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

  self.goldText:SetFont(xb:GetFont(db.text.fontSize))
  self.goldText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  self.goldText:SetText(self:FormatCoinText(GetMoney()))
  self.goldText:SetPoint('LEFT', self.goldIcon, 'RIGHT', 5, 0)

  local bagWidth = 0
  if db.modules.gold.showFreeBagSpace then
    local freeSpace = 0
    for i = 0, 4 do
      freeSpace = freeSpace + GetContainerNumFreeSlots(i)
    end
    self.bagText:SetFont(xb:GetFont(db.text.fontSize))
    self.bagText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    self.bagText:SetText('('..tostring(freeSpace)..')')
    self.bagText:SetPoint('LEFT', self.goldText, 'RIGHT', 5, 0)
    bagWidth = self.bagText:GetStringWidth()
  else
    self.bagText:SetText('')
    self.bagText:SetSize(0, 0)
  end

  self.goldButton:SetSize(self.goldText:GetStringWidth() + iconSize + 10 + bagWidth, iconSize)
  self.goldButton:SetPoint('LEFT')

  self.goldFrame:SetSize(self.goldButton:GetSize())
  self.goldFrame:SetPoint('RIGHT', self.goldFrame:GetParent(), 'LEFT', -(db.general.moduleSpacing), 0)
end

function GoldModule:CreateFrames()
  self.goldButton = self.goldButton or CreateFrame("BUTTON", nil, self.goldFrame)
  self.goldIcon = self.goldIcon or self.goldButton:CreateTexture(nil, 'OVERLAY')
  self.goldText = self.goldText or self.goldButton:CreateFontString(nil, "OVERLAY")
  self.bagText = self.bagText or self.goldButton:CreateFontString(nil, "OVERLAY")
end

function GoldModule:RegisterFrameEvents()

  self.goldButton:EnableMouse(true)
  self.goldButton:RegisterForClicks("AnyUp")

  self:RegisterEvent('PLAYER_MONEY')
  self:RegisterEvent('BAG_UPDATE', 'Refresh')

  self.goldButton:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    self.goldText:SetTextColor(unpack(xb:HoverColors()))
    self.bagText:SetTextColor(unpack(xb:HoverColors()))

    GameTooltip:SetOwner(GoldModule.goldFrame, 'ANCHOR_'..xb.miniTextPosition)
    GameTooltip:AddLine("[|cff6699FF"..L['Gold'].."|r - |cff82c5ff"..xb.constants.playerFactionLocal.." "..xb.constants.playerRealm.."|r]")
    GameTooltip:AddLine(" ")

    local totalGold = 0
    for charName, goldData in pairs(xb.db.factionrealm) do
      GameTooltip:AddDoubleLine(charName, GoldModule:FormatCoinText(goldData.currentMoney), 1, 1, 0, 1, 1, 1)
      totalGold = totalGold + goldData.currentMoney
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(L['Total'], GoldModule:FormatCoinText(totalGold), 1, 1, 0, 1, 1, 1)
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
  end)
end

function GoldModule:PLAYER_MONEY()
  xb.db.factionrealm[xb.constants.playerName].currentMoney = GetMoney()
  self:Refresh()
end

function GoldModule:FormatCoinText(money)
  local showSC = xb.db.profile.modules.gold.showSmallCoins
  local shortThousands = xb.db.profile.modules.gold.shortThousands
  local g, s, c = self:SeparateCoins(money)
  local formattedString = ''
  if g > 0 then
    formattedString = '%s'..GOLD_AMOUNT_SYMBOL
    if g > 1000 and shortThousands then
      g = floor(abs(g / 1000))
      formattedString = '%s'..FIRST_NUMBER_CAP_NO_SPACE..GOLD_AMOUNT_SYMBOL
    end
  end
  if s > 0 and (g < 1 or showSC) then
    if g > 1 then
      formattedString = formattedString..' '
    end
    formattedString = formattedString..'%d'..SILVER_AMOUNT_SYMBOL
  end
  if c > 0 and (s < 1 or showSC) then
    if g > 1 or s > 1 then
      formattedString = formattedString..' '
    end
    formattedString = formattedString..'%d'..COPPER_AMOUNT_SYMBOL
  end

  return string.format(formattedString, BreakUpLargeNumbers(g), s, c)
end
function GoldModule:SeparateCoins(money)
  local gold, silver, copper = floor(abs(money / 10000)), floor(abs(mod(money / 100, 100))), floor(abs(mod(money, 100)))
  return gold, silver, copper
end

function GoldModule:GetDefaultOptions()
  return 'gold', {
      enabled = true,
      showSmallCoins = false,
      showFreeBagSpace = true,
      shortThousands = false
    }
end

function GoldModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.gold.enabled; end,
        set = function(_, val) xb.db.profile.modules.gold.enabled = val; self:Refresh(); end,
        width = "full"
      },
      showSmallCoins = {
        name = L['Always Show Silver and Copper'],
        order = 1,
        type = "toggle",
        get = function() return xb.db.profile.modules.gold.showSmallCoins; end,
        set = function(_, val) xb.db.profile.modules.gold.showSmallCoins = val; self:Refresh(); end
      },
      showFreeBagSpace = {
        name = L['Show Free Bag Space'],
        order = 1,
        type = "toggle",
        get = function() return xb.db.profile.modules.gold.showFreeBagSpace; end,
        set = function(_, val) xb.db.profile.modules.gold.showFreeBagSpace = val; self:Refresh(); end
      },
      shortThousands = {
        name = L['Shorten Gold'],
        order = 1,
        type = "toggle",
        get = function() return xb.db.profile.modules.gold.shortThousands; end,
        set = function(_, val) xb.db.profile.modules.gold.shortThousands = val; self:Refresh(); end
      }
    }
  }
end
