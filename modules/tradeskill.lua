local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local TradeskillModule = xb:NewModule("TradeskillModule", 'AceEvent-3.0')

function TradeskillModule:GetName()
  return TRADESKILLS;
end

function TradeskillModule:OnInitialize()
  self.profIcons = {
  	[164] = 'blacksmithing',
  	[165] = 'leatherworking',
  	[171] = 'alchemy',
  	[182] = 'herbalism',
  	[186] = 'mining',
  	[202] = 'engineering',
  	[333] = 'enchanting',
  	[755] = 'jewelcrafting',
  	[773] = 'inscription',
  	[197] = 'tailoring',
  	[393] = 'skinning'
  }
end

function TradeskillModule:OnEnable()
  if self.tradeskillFrame == nil then
    self.tradeskillFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
    xb:RegisterFrame('tradeskillFrame', self.tradeskillFrame)
  end

  self.tradeskillFrame:Show()

  local prof1, prof2, _ = GetProfessions()
  self.prof1 = prof1
  self.prof2 = prof2

  self:CreateFrames()
  self:RegisterFrameEvents()
  self:Refresh()
end

function TradeskillModule:OnDisable()
  self.tradeskillFrame:Hide()
  self:UnregisterEvent('TRADE_SKILL_UPDATE')
  self:UnregisterEvent('SPELLS_CHANGED')
  self:UnregisterEvent('UNIT_SPELLCAST_STOP')
end

function TradeskillModule:UpdateProfValues()
  if self.prof1 then
    local _, _, skill, cap, _ = GetProfessionInfo(self.prof1)
    self.firstProfBar:SetMinMaxValues(1, cap)
    self.firstProfBar:SetValue(skill)
  end

  if self.prof2 then
    local _, _, skill, cap, _ = GetProfessionInfo(self.prof2)
    self.secondProfBar:SetMinMaxValues(1, cap)
    self.secondProfBar:SetValue(skill)
  end
end

function TradeskillModule:Refresh()
  if InCombatLockdown() then
    self:UpdateProfValues()
    return
  end
  local db = xb.db.profile
  if self.tradeskillFrame == nil then return; end
  if not db.modules.tradeskill.enabled then return; end
  local iconSize = db.text.fontSize + db.general.barPadding

  local totalWidth = 0

  if self.prof1 then
    self:StyleTradeskillFrame('firstProf', self.prof1)
    totalWidth = totalWidth + self.firstProfFrame:GetWidth()
    self.firstProfFrame:SetPoint('LEFT')
  end

  if self.prof2 then
    self:StyleTradeskillFrame('secondProf', self.prof2)
    totalWidth = totalWidth + self.secondProfFrame:GetWidth()
    self.secondProfFrame:SetPoint('LEFT', self.firstProfFrame, 'RIGHT', 5, 0)
  end

  if self.prof1 or self.prof2 then

    self:UpdateProfValues()

    self.tradeskillFrame:SetSize(totalWidth, xb:GetHeight())

    --self.tradeskillFrame:SetSize(self.goldButton:GetSize())

    local relativeAnchorPoint = 'RIGHT'
    local xOffset = db.general.moduleSpacing
    if not xb:GetFrame('clockFrame'):IsVisible() then
      relativeAnchorPoint = 'LEFT'
      xOffset = 0
    end
    self.tradeskillFrame:SetPoint('LEFT', xb:GetFrame('clockFrame'), relativeAnchorPoint, xOffset, 0)
  else
    self.tradeskillFrame:Hide()
  end
end

function TradeskillModule:StyleTradeskillFrame(framePrefix, profIndex)
  local db = xb.db.profile
  local iconSize = db.text.fontSize + db.general.barPadding
  local name, _, skill, cap, _, spellOffset, skillLine, _ = GetProfessionInfo(profIndex)
  local icon = xb.constants.mediaPath..'profession\\'..self.profIcons[skillLine]

  local textHeight = floor((xb:GetHeight() - 4) / 2)
  if skill == cap then
    textHeight = db.text.fontSize
  end

  local barHeight = (iconSize - textHeight - 2)
  if barHeight < 2 then
    barHeight = 2
  end

  self[framePrefix..'Icon']:SetTexture(icon)
  self[framePrefix..'Icon']:SetSize(iconSize, iconSize)
  self[framePrefix..'Icon']:SetPoint('LEFT')
  self[framePrefix..'Icon']:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

  self[framePrefix..'Text']:SetFont(xb:GetFont(textHeight))
  self[framePrefix..'Text']:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  self[framePrefix..'Text']:SetText(string.upper(name))

  if skill == cap then
    self[framePrefix..'Text']:SetPoint('LEFT', self[framePrefix..'Icon'], 'RIGHT', 5, 0)
  else
    self[framePrefix..'Text']:SetPoint('TOPLEFT', self[framePrefix..'Icon'], 'TOPRIGHT', 5, 0)
    self[framePrefix..'Bar']:SetStatusBarTexture(1, 1, 1)
    if db.modules.tradeskill.barCC then
      self[framePrefix..'Bar']:SetStatusBarColor(xb:GetClassColors())
    else
      self[framePrefix..'Bar']:SetStatusBarColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
    end
    self[framePrefix..'Bar']:SetSize(self[framePrefix..'Text']:GetStringWidth(), barHeight)
    self[framePrefix..'Bar']:SetPoint('BOTTOMLEFT', self[framePrefix..'Icon'], 'BOTTOMRIGHT', 5, 0)

    self[framePrefix..'BarBg']:SetAllPoints()
    self[framePrefix..'BarBg']:SetColorTexture(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  end
  self[framePrefix..'Frame']:SetSize(iconSize + self[framePrefix..'Text']:GetStringWidth() + 5, xb:GetHeight())

  local spellName, subSpellName = GetSpellBookItemName(spellOffset + 1, BOOKTYPE_PROFESSION)
  self[framePrefix..'Frame']:SetAttribute('spell', spellName) --- While this is usually the type of thing I'd put into RegisterFrameEvents(), I need it to update
end

function TradeskillModule:CreateFrames()
  self.firstProfFrame = self.firstProfFrame or CreateFrame("BUTTON", nil, self.tradeskillFrame, 'SecureActionButtonTemplate')
  self.firstProfIcon = self.firstProfIcon or self.firstProfFrame:CreateTexture(nil, 'OVERLAY')
  self.firstProfText = self.firstProfText or self.firstProfFrame:CreateFontString(nil, 'OVERLAY')
  self.firstProfBar = self.firstProfBar or CreateFrame('STATUSBAR', nil, self.firstProfFrame)
  self.firstProfBarBg = self.firstProfBarBg or self.firstProfBar:CreateTexture(nil, 'BACKGROUND')

  self.secondProfFrame = self.secondProfFrame or CreateFrame("BUTTON", nil, self.tradeskillFrame, 'SecureActionButtonTemplate')
  self.secondProfIcon = self.secondProfIcon or self.secondProfFrame:CreateTexture(nil, 'OVERLAY')
  self.secondProfText = self.secondProfText or self.secondProfFrame:CreateFontString(nil, 'OVERLAY')
  self.secondProfBar = self.secondProfBar or CreateFrame('STATUSBAR', nil, self.secondProfFrame)
  self.secondProfBarBg = self.secondProfBarBg or self.secondProfBar:CreateTexture(nil, 'BACKGROUND')
end

function TradeskillModule:RegisterFrameEvents()

  self:RegisterEvent('TRADE_SKILL_UPDATE', 'Refresh')
  self:RegisterEvent('SPELLS_CHANGED', 'Refresh')
  self.tradeskillFrame:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
  self.tradeskillFrame:SetScript('OnEvent', function(_, event)
    if event == 'UNIT_SPELLCAST_STOP' then
      self:Refresh()
    end
  end)

  self.firstProfFrame:EnableMouse(true)
  self.firstProfFrame:RegisterForClicks('AnyUp')

  self.firstProfFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    self.firstProfText:SetTextColor(unpack(xb:HoverColors()))
    if xb.db.profile.modules.tradeskill.showTooltip then
      self:ShowTooltip()
    end
  end)
  self.firstProfFrame:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    local db = xb.db.profile
    self.firstProfText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    if xb.db.profile.modules.tradeskill.showTooltip then
      GameTooltip:Hide()
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

  self.tradeskillFrame:EnableMouse(true)
  self.tradeskillFrame:SetScript('OnEnter', function()
    if xb.db.profile.modules.tradeskill.showTooltip then
      self:ShowTooltip()
    end
  end)
  self.tradeskillFrame:SetScript('OnLeave', function()
    if xb.db.profile.modules.tradeskill.showTooltip then
      GameTooltip:Hide()
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

function TradeskillModule:ShowTooltip()
  return
  --[[
  GameTooltip:SetOwner(self.tradeskillFrame, 'ANCHOR_'..xb.miniTextPosition)
  GameTooltip:AddLine("[|cff6699FF"..L['Cooldowns'].."|r]")
  GameTooltip:AddLine(" ")

  local recipeIds = C_TradeSkillUI.GetAllRecipeIDs()

  GameTooltip:AddLine(" ")
  GameTooltip:AddDoubleLine('<'..L['Left-Click']..'>', BINDING_NAME_TOGGLECURRENCY, 1, 1, 0, 1, 1, 1)
  GameTooltip:Show()]]--
end

function TradeskillModule:GetDefaultOptions()
  return 'tradeskill', {
      enabled = true,
      barCC = false,
      showTooltip = true
    }
end

function TradeskillModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.tradeskill.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.tradeskill.enabled = val
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
        get = function() return xb.db.profile.modules.tradeskill.barCC; end,
        set = function(_, val) xb.db.profile.modules.tradeskill.barCC = val; self:Refresh(); end
      },
      showTooltip = {
        name = L['Show Tooltips'],
        order = 3,
        type = "toggle",
        get = function() return xb.db.profile.modules.tradeskill.showTooltip; end,
        set = function(_, val) xb.db.profile.modules.tradeskill.showTooltip = val; self:Refresh(); end
      }
    }
  }
end
