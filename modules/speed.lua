local addon, xb = ...
local _G = _G;
local L = xb.L;

local SpeedModule = xb:NewModule("SpeedModule", 'AceEvent-3.0')

function SpeedModule:GetName()
  return "speed";
end

function SpeedModule:OnInitialize()
  self.frame = nil
  self.icon = nil
  self.text = nil
end

function SpeedModule:OnEnable()
  if self.frame == nil then
    self:CreateModuleFrame()
    self:RegisterEvents()
  else
    self.frame:Show()
    self:RegisterEvents()
  end
end

function SpeedModule:OnDisable()
  if self.frame then
    self.frame:Hide()
    self.frame:UnregisterAllEvents()
  end
end

function SpeedModule:CreateModuleFrame()
  self.frame=CreateFrame("BUTTON","speedFrame", xb:GetFrame('bar'))
  xb:RegisterFrame('speedFrame',self.frame)
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
  self.text:SetText("Coordinates")
end

function SpeedModule:GetSpeed()
  local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
  return string.format("%d%%", currentSpeed / BASE_MOVEMENT_SPEED * 100)
end

function SpeedModule:RegisterEvents()
  self.frame:SetScript("OnEnter", function()
    if InCombatLockdown() then return end
    self.icon:SetVertexColor(xb:GetColor('hover'))
    self.text:SetTextColor(xb:GetColor('hover'))

    local speed = self:GetSpeed()

    if xb.db.profile.general.barPosition == "TOP" then
      GameTooltip:SetOwner(self.frame, "ANCHOR_BOTTOM")
    else
      GameTooltip:SetOwner(self.frame, "ANCHOR_TOP")
    end
    GameTooltip:AddLine("[|cff6699FFSpeed|r]")
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("<"..'Speed'..">", "|cffffffff"..speed.."|r")
    GameTooltip:Show()
  end)

  self.frame:SetScript("OnClick", function(self, button, down)
  end)

  self.frame:SetScript("OnLeave", function()
    self.icon:SetVertexColor(xb:GetColor('normal'))
    self.text:SetTextColor(xb:GetColor('inactive'))
    GameTooltip:Hide();
  end)

	self.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  self.frame:RegisterEvent("ZONE_CHANGED");
  self.frame:RegisterEvent("ZONE_CHANGED_INDOORS");
  self.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
  self.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
  self.frame:RegisterEvent("CVAR_UPDATE");
  self.frame:SetScript("OnEvent", function(self,event, ...)
    SpeedModule:Speed_Update_value()
  end)
end

function SpeedModule:Refresh()
  if not xb.db.profile.modules.speed.enabled then self:Disable(); return; end

  if not self.frame and xb.db.profile.modules.speed.enabled then
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
function SpeedModule:Speed_Update_value()
	if self.text and self.frame then
    local speed = self:GetSpeed()
    self.text:SetText(speed)
		self.frame:SetSize(self.text:GetStringWidth()+18, 16)
	end
end

function SpeedModule:GetDefaultOptions()
  return self:GetName(), {
      enabled = false
    }
end

function SpeedModule:GetConfig()
  return {
    name = L['Speed'],
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.speed.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.speed.enabled = val
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
