local addon, xb = ...
local _G = _G;
local L = xb.L;

local ReputationModule = xb:NewModule("ReputationModule", 'AceEvent-3.0')

function ReputationModule:GetName()
  return "reputation";
end

function ReputationModule:OnInitialize()
  self.frame = nil
  self.icon = nil
  self.text = nil
end

function ReputationModule:OnEnable()
  if self.frame == nil then
    self:CreateModuleFrame()
    self:RegisterEvents()
  else
    self.frame:Show()
    self:RegisterEvents()
  end
end

function ReputationModule:OnDisable()
  if self.frame then
    self.frame:Hide()
    self.frame:UnregisterAllEvents()
  end
end

function ReputationModule:CreateModuleFrame()
  self.frame=CreateFrame("BUTTON","reputationFrame", xb:GetFrame('bar'))
  xb:RegisterFrame('reputationFrame',self.frame)
  self.frame:EnableMouse(true)

  local relativeAnchorPoint = 'RIGHT'
  local xOffset = xb.db.profile.general.moduleSpacing
  local parentFrame = xb:GetFrame('currencyFrame')
  if not xb.db.profile.modules.currency.enabled then
    parentFrame=xb:GetFrame('clockFrame')
    if not xb.db.profile.modules.clock.enabled then
      parentFrame=xb:GetFrame('bar')
      relativeAnchorPoint = 'LEFT'
      xOffset = 0
    end
  end

  self.frame:SetPoint('LEFT', parentFrame, relativeAnchorPoint, xOffset, 0)

  self.icon = self.frame:CreateTexture(nil,"OVERLAY",nil,7)
  self.icon:SetPoint("LEFT")
  -- FIXME: Use a different icon
  self.icon:SetTexture(xb.constants.mediaPath.."datatexts\\sound")
  self.icon:SetVertexColor(xb:GetColor('normal'))

  self.text = self.frame:CreateFontString(nil, "OVERLAY")
  self.text:SetFont(xb:GetFont(xb.db.profile.text.fontSize))
  self.text:SetPoint("RIGHT", self.frame,2,0)
  self.text:SetTextColor(xb:GetColor('inactive'))
  self.text:SetText("Reputation")
end

function ReputationModule:BuildReputation()
  local numFactions = GetNumFactions()
  local factionIndex = 1

  if not xb.db.profile.reps then
    xb.db.profile.reps = {}
  end
  local reps = xb.db.profile.reps
  local header = ""

  while (factionIndex <= numFactions) do
    local name, desc, standingId, intMin, intMax, intValue, atWarWith, canToggleAtWar,
    isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(factionIndex)
    if isHeader then
      header = name
      if isCollapsed then
        ExpandFactionHeader(factionIndex)
        numFactions = GetNumFactions()
      end
    end

    local rep = {}

    if hasRep or not isHeader then
      local FACTION_BAR_MAXES = {
        [1] = 36000, -- Hated      -36000 - -6001
        [2] =  3000, -- Hostile     -6000 - -3001
        [3] =  3000, -- Unfriendly  -3000 - -   1
        [4] =  3000, -- Neutral         0 -  3000
        [5] =  6000, -- Friendly     3001 -  9000
        [6] = 12000, -- Honored      9001 - 21000
        [7] = 21000, -- Revered     21001 - 32000
        [8] = 10000, -- Exalted     32001 - 33000
      }
      local standingId = standingId
      local barVal = intValue
      local barMax = 0

      local standingTest = 4
      for i=standingTest,8 do
        if standingId > i then
          barVal = barVal - FACTION_BAR_MAXES[i]
          standingTest = standingTest + 1
        end
      end
      barMax = FACTION_BAR_MAXES[standingTest]

      rep = {
        name = name,
        standingId = standingId,
        intValue = intValue,
        intMax = intMax,
        barValue = barVal,
        barMax = barMax,
        isWatched = isWatched,
        group = header
      }

      if reps[factionID] then
        if reps[factionID].intValue ~= rep.intValue or reps[factionID].group ~= rep.group then
          reps[factionID] = rep
        end
      else
        reps[factionID] = rep
      end

      if isWatched then
        reps.watched = rep
      end
    end

    factionIndex = factionIndex + 1
  end

  xb.db.profile.reps = reps
end

function ReputationModule:RegisterEvents()
  self.frame:SetScript("OnEnter", function()
    if InCombatLockdown() then return end
    self.icon:SetVertexColor(xb:GetColor('hover'))
    self.text:SetTextColor(xb:GetColor('hover'))

    self:BuildReputation()
    local reps = xb.db.profile.reps

    if xb.db.profile.general.barPosition == "TOP" then
      GameTooltip:SetOwner(self.frame, "ANCHOR_BOTTOM")
    else
      GameTooltip:SetOwner(self.frame, "ANCHOR_TOP")
    end

    GameTooltip:AddLine("[|cff6699FFReputation|r]")
    GameTooltip:AddLine(" ")

    for factionID,rep in pairs(reps) do
      if (factionID ~= "watched") and (rep.group ~= "Inactive") and rep.standingId and rep.barValue then
        -- FIXME: Figure out how to do this conversion without hard-coding
        local FACTION_BAR_COLORS_HEX = {
          [1] = { r = "FF", g = "1A", b = "1A" }, -- Hated
          [2] = { r = "FF", g = "80", b = "40" }, -- Hostile
          [3] = { r = "FF", g = "B3", b = "4D" }, -- Unfriendly
          [4] = { r = "FF", g = "FF", b = "00" }, -- Neutral
          [5] = { r = "52", g = "AB", b = "00" }, -- Friendly
          [6] = { r = "00", g = "70", b = "1A" }, -- Honored
          [7] = { r = "A3", g = "35", b = "EE" }, -- Revered
          [8] = { r = "E6", g = "CC", b = "80" }, -- Exalted
        }

        local colors = FACTION_BAR_COLORS_HEX[rep.standingId]
        local color = "ff" .. colors.r .. colors.g .. colors.b
        local msg = rep.barValue .. " / " .. rep.barMax

        if standingId == 8 then
          msg = "Exalted"
        end

        GameTooltip:AddDoubleLine("<" .. rep.name .. ">", "|c" .. color .. msg .. "|r")
      end
    end
    GameTooltip:Show()
  end)

  self.frame:SetScript("OnClick", function(self, button, down)
    ToggleCharacter("ReputationFrame")
  end)

  self.frame:SetScript("OnLeave", function()
    self.icon:SetVertexColor(xb:GetColor('normal'))
    self.text:SetTextColor(xb:GetColor('inactive'))
    GameTooltip:Hide();
  end)

  self.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  self.frame:RegisterEvent("UPDATE_FACTION");
  self.frame:SetScript("OnEvent", function(self,event, ...)
    ReputationModule:Reputation_Update_Value()
  end)
end

function ReputationModule:Refresh()
  if not xb.db.profile.modules.reputation.enabled then self:Disable(); return; end

  if not self.frame and xb.db.profile.modules.reputation.enabled then
    self:Enable()
    return;
  end

  if self.frame then
    self.frame:Hide()
    local relativeAnchorPoint = 'RIGHT'
    local xOffset = xb.db.profile.general.moduleSpacing
    local parentFrame = xb:GetFrame('currencyFrame')
    if not xb.db.profile.modules.currency.enabled then
      parentFrame=xb:GetFrame('clockFrame')
      if not xb.db.profile.modules.clock.enabled then
        parentFrame=xb:GetFrame('bar')
        relativeAnchorPoint = 'LEFT'
        xOffset = 0
      end
    end
    self.frame:SetPoint('LEFT', parentFrame, relativeAnchorPoint, xOffset, 0)
    self.frame:Show()
  end
end
function ReputationModule:Reputation_Update_Value()
  if self.text and self.frame then
    self:BuildReputation()
    local reps = xb.db.profile.reps
    local rep = {}
    if reps.watched then
      rep = reps.watched
    end

    if rep.name and rep.barValue and rep.barMax then
      msg = rep.barValue .. " / " .. rep.barMax
      self.text:SetText(rep.name .. ": " .. msg)
    else
      self.text:SetText("No Watched Rep!")
    end
    self.frame:SetSize(self.text:GetStringWidth()+18, 16)
  end
end

function ReputationModule:GetDefaultOptions()
  return self:GetName(), {
      enabled = false
    }
end

function ReputationModule:GetConfig()
  return {
    name = L['Reputation'],
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.reputation.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.reputation.enabled = val
          if val then
            self:Enable();
          else
            self:Disable();
          end
        end,
        width = "full"
      }
    }
  }
end
