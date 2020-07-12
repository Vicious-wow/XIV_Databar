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

  local firstProfID = 0
  local secondProfID = 0

  self:CreateFrames()
  self:RegisterFrameEvents()
  self:Refresh()
end

function TradeskillModule:OnDisable()
  self.tradeskillFrame:Hide()
  self:UnregisterEvent('TRADE_SKILL_DETAILS_UPDATE')
  self:UnregisterEvent('SPELLS_CHANGED')
  self:UnregisterEvent('UNIT_SPELLCAST_STOP')
end

function TradeskillModule:UpdateProfValues()
  --update profession indexes before anything else or receive a million bugs when (un)learning professions
  self.prof1, self.prof2, _ = GetProfessions() --this is the most important line in the entire fucking module

  --if prof1 doesn't exist, the player hasn't learned any profession and thus the tradeskillFrame is hidden
  if not self.prof1 then
    self.tradeskillFrame:Hide()
    return
  end

  --player has at least one profession, setting first one. show tradeskillFrame because it might've been hidden before
  self.tradeskillFrame:Show()
  local _, _, skill1, cap1, _ = GetProfessionInfo(self.prof1)
  self.firstProfBar:SetMinMaxValues(1, cap1)
  self.firstProfBar:SetValue(skill1)

  --if prof2 doesn't exist, hide the secondProfFrame 
  if not self.prof2 then
    self.secondProfFrame:Hide()
    return
  end

  --player has two profession, setting second one. show secondProfFrame because it might've been hidden before
  self.secondProfFrame:Show()
  local _, _, skill2, cap2, _ = GetProfessionInfo(self.prof2)
  self.secondProfBar:SetMinMaxValues(1, cap2)
  self.secondProfBar:SetValue(skill2)
end

function TradeskillModule:Refresh()
  --don't refresh anything while in combat because why the fuck would you?
  if InCombatLockdown() then return end
  --do this before updating prof values or get rekt by bugs because refresh triggers a thousand times before anything is even loaded
  if self.tradeskillFrame == nil then return end
  --similar reasons for the line above apply here
  local db = xb.db.profile
  if not db.modules.tradeskill.enabled then self:Disable() return end

  --update before doing anything here mister addon creator. if we have no professions, why the fuck would we refresh anything?
  self:UpdateProfValues()
  --get the hell out of this function if we have no professions
  if not self.prof1 then return end

  --prepare tradeskillFrame bar width and profession icon size
  local iconSize = db.text.fontSize + db.general.barPadding
  local totalWidth = 0

  --setting width and position for profession 1 frame
  self:StyleTradeskillFrame('firstProf', self.prof1)
  totalWidth = totalWidth + self.firstProfFrame:GetWidth()
  self.firstProfFrame:SetPoint('LEFT')

  -- setting width and position for profession 2 frame if it exists, otherwise its frame is hidden anyway
  if self.prof2 then
    self:StyleTradeskillFrame('secondProf', self.prof2)
    totalWidth = totalWidth + self.secondProfFrame:GetWidth()
    self.secondProfFrame:SetPoint('LEFT', self.firstProfFrame, 'RIGHT', 5, 0)
  end

  --final touches on our precious tradeskillFrame
  self.tradeskillFrame:SetSize(totalWidth, xb:GetHeight())
  local relativeAnchorPoint = 'RIGHT'
  local xOffset = db.general.moduleSpacing
  if not xb:GetFrame('clockFrame'):IsVisible() then
    relativeAnchorPoint = 'LEFT'
    xOffset = 0
  end
  self.tradeskillFrame:SetPoint('LEFT', xb:GetFrame('clockFrame'), relativeAnchorPoint, xOffset, 0)
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

  self[framePrefix..'ID'] = skillLine

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
end

function TradeskillModule:CreateFrames()
  self.firstProfFrame = self.firstProfFrame or CreateFrame("BUTTON", nil, self.tradeskillFrame)
  self.firstProfIcon = self.firstProfIcon or self.firstProfFrame:CreateTexture(nil, 'OVERLAY')
  self.firstProfText = self.firstProfText or self.firstProfFrame:CreateFontString(nil, 'OVERLAY')
  self.firstProfBar = self.firstProfBar or CreateFrame('STATUSBAR', nil, self.firstProfFrame)
  self.firstProfBarBg = self.firstProfBarBg or self.firstProfBar:CreateTexture(nil, 'BACKGROUND')

  self.secondProfFrame = self.secondProfFrame or CreateFrame("BUTTON", nil, self.tradeskillFrame)
  self.secondProfIcon = self.secondProfIcon or self.secondProfFrame:CreateTexture(nil, 'OVERLAY')
  self.secondProfText = self.secondProfText or self.secondProfFrame:CreateFontString(nil, 'OVERLAY')
  self.secondProfBar = self.secondProfBar or CreateFrame('STATUSBAR', nil, self.secondProfFrame)
  self.secondProfBarBg = self.secondProfBarBg or self.secondProfBar:CreateTexture(nil, 'BACKGROUND')
end

function TradeskillModule:SetProfScripts(framePrefix)
  self[framePrefix..'Frame']:SetScript('OnMouseDown', function()
    local _, _, _, _, _, openSkillLine, _ = C_TradeSkillUI.GetTradeSkillLine()
    if openSkillLine == self[framePrefix..'ID'] then C_TradeSkillUI.CloseTradeSkill() return end
      C_TradeSkillUI.OpenTradeSkill(self[framePrefix..'ID'])
  end)

  self[framePrefix..'Frame']:SetScript('OnEnter', function()
    if InCombatLockdown() then return end
    self[framePrefix..'Text']:SetTextColor(unpack(xb:HoverColors()))
    if xb.db.profile.modules.tradeskill.showTooltip then
      self:ShowTooltip()
    end
  end)

  self[framePrefix..'Frame']:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    local db = xb.db.profile
    self[framePrefix..'Text']:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    if xb.db.profile.modules.tradeskill.showTooltip then
      GameTooltip:Hide()
    end
  end)
end

function TradeskillModule:RegisterFrameEvents()
  self.tradeskillFrame:SetScript('OnEvent', function() self:Refresh() end)
  self.tradeskillFrame:RegisterEvent('TRADE_SKILL_DETAILS_UPDATE')
  self.tradeskillFrame:RegisterEvent('SPELLS_CHANGED')
  self.tradeskillFrame:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')

  self:SetProfScripts('firstProf')
  self:SetProfScripts('secondProf')

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
  --lol wtf is happening here. more "bugfixes"?
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
