local addon, xb = ...
local _G = _G;
local L = xb.L;

local CoordinatesModule = xb:NewModule("CoordinatesModule", 'AceEvent-3.0')
local ticker = nil

function CoordinatesModule:GetName()
  return "coordinates";
end

function CoordinatesModule:OnInitialize()
  self.frame = nil
  self.icon = nil
  self.text = nil
  self.tooltip = nil
end

function CoordinatesModule:OnEnable()
  if self.frame == nil then
    self:CreateModuleFrame()
    self:RegisterEvents()
  else
    self.frame:Show()
    self:RegisterEvents()
  end
  if true and self.tooltip == nil then
    self.tooltip = GameTooltip
  end
  ticker = C_Timer.NewTicker(1,function() self:Coordinates_Update_value() end)
end

function CoordinatesModule:OnDisable()
  if self.frame then
    self.frame:Hide()
    self.frame:UnregisterAllEvents()
  end
  ticker:Cancel()
end

function CoordinatesModule:CreateModuleFrame()
  self.frame=CreateFrame("BUTTON","coordinatesFrame", xb:GetFrame('bar'))
  xb:RegisterFrame('coordinatesFrame',self.frame)
  self.frame:EnableMouse(true)
  self.frame:RegisterForClicks("AnyUp")

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

function CoordinatesModule:GetCoordinates()
  local map = C_Map.GetBestMapForUnit("player")
  local posX, posY = 0, 0
  if map then
    local position = C_Map.GetPlayerMapPosition(map, "player")
    if position then
      posX, posY = position:GetXY()
      posX = string.format("%.1f", posX * 100)
      posY = string.format("%.1f", posY * 100)
      if string.find(posX,'.') == nil then
        posX = posX .. ".0"
      end
      if string.find(posY,'.') == nil then
        posY = posY .. ".0"
      end
    end
  end

  return posX .. ", " .. posY
end

function CoordinatesModule:RegisterEvents()
  self.frame:SetScript("OnEnter", function()
    if InCombatLockdown() then return end
    self.icon:SetVertexColor(xb:GetColor('hover'))
    self.text:SetTextColor(xb:GetColor('hover'))
    if true then
      self.tooltip:Show()
    end
  end)

  self.frame:SetScript("OnClick", function(self, button, down)
    if not WorldMapFrame:IsVisible() then
      WorldMapFrame:Show()
    else
      WorldMapFrame:Hide()
    end
  end)

  self.frame:SetScript("OnLeave", function()
    self.icon:SetVertexColor(xb:GetColor('normal'))
    self.text:SetTextColor(xb:GetColor('inactive'))
    if true then
      self.tooltip:Hide()
    end
  end)
end

function CoordinatesModule:Refresh()
  if not xb.db.profile.modules.coordinates.enabled then self:Disable(); return; end

  if not self.frame and xb.db.profile.modules.coordinates.enabled then
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

function CoordinatesModule:Coordinates_Update_value()
  local coordinates = self:GetCoordinates()

	if self.text and self.frame then
    self.text:SetText(coordinates)
		self.frame:SetSize(self.text:GetStringWidth()+18, 16)
	end

  if true then
    if xb.db.profile.general.barPosition == "TOP" then
      self.tooltip:SetOwner(self.frame, "ANCHOR_BOTTOM")
    else
      self.tooltip:SetOwner(self.frame, "ANCHOR_TOP")
    end
    self.tooltip:AddLine("[|cff6699FFLocation|r]")
    self.tooltip:AddLine(" ")
    self.tooltip:AddDoubleLine("<"..'Zone'..">", "|cffffffff"..GetZoneText().."|r")
    self.tooltip:AddDoubleLine("<"..'Subzone'..">", "|cffffffff"..GetSubZoneText().."|r")
    self.tooltip:AddDoubleLine("<"..'Coordinates'..">", "|cffffffff"..coordinates.."|r")
  end
end

function CoordinatesModule:GetDefaultOptions()
  return self:GetName(), {
      enabled = false
    }
end

function CoordinatesModule:GetConfig()
  return {
    name = L['Coordinates'],
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.coordinates.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.coordinates.enabled = val
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
