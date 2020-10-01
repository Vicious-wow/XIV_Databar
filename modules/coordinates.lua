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
    self:UpdateModuleFrame()
  end
  self:CreateTooltip()
  ticker = C_Timer.NewTicker(1,function() self:Coordinates_Update_value() end)
end

function CoordinatesModule:OnDisable()
  if self.frame then
    self.frame:Hide()
    self.frame:UnregisterAllEvents()
    self.frame = nil
  end
  if self.tooltip then
    self.tooltip:Hide()
    self.tooltip = nil
  end
  ticker:Cancel()
end

function CoordinatesModule:UpdateModuleFrame()
  local relativeAnchorPoint = 'RIGHT'
  local xOffset = xb.db.profile.general.moduleSpacing

  local moduleInfo = {
    { "tradeskill", "tradeskillFrame" },
    { "currency", "currencyFrame" },
    { "clock", "clockFrame" },
    { "bar", "bar" }
  }
  local count = 0
  for _ in pairs(moduleInfo) do count = count + 1 end

  local moduleKey = ""
  local lastModuleKey = ""
  local frameName = ""
  local parentFrame = nil

  for i=1,count do
    moduleKey = moduleInfo[i][1]
    frameName = moduleInfo[i][2]
    parentFrame = xb:GetFrame(frameName)
    if (xb.db.profile.modules[lastModuleKey] and xb.db.profile.modules[lastModuleKey].enabled) or parentFrame ~= nil then
      break
    end
    lastModuleKey = moduleKey
  end
  if moduleKey == "bar" then
    relativeAnchorPoint = 'LEFT'
    xOffset = 0
  end

  self.frame:SetPoint('LEFT', parentFrame, relativeAnchorPoint, xOffset, 0)
end

function CoordinatesModule:CreateModuleFrame()
  self.frame=CreateFrame("BUTTON","coordinatesFrame", xb:GetFrame('bar'))
  xb:RegisterFrame('coordinatesFrame',self.frame)
  self.frame:EnableMouse(true)
  self.frame:RegisterForClicks("AnyUp")

  self:UpdateModuleFrame()

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
    if xb.db.profile.modules.coordinates.showTooltip then
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
    if xb.db.profile.modules.coordinates.showTooltip then
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
    self:UpdateModuleFrame()
    self.frame:Show()
  end
end

function CoordinatesModule:CreateTooltip()
  if xb.db.profile.modules.coordinates.showTooltip and CoordinatesModule.tooltip == nil then
    CoordinatesModule.tooltip = GameTooltip
  end
end

function CoordinatesModule:Coordinates_Update_value()
  local coordinates = self:GetCoordinates()

	if self.text and self.frame then
    self.text:SetText(coordinates)
		self.frame:SetSize(self.text:GetStringWidth()+18, 16)
	end

  if xb.db.profile.modules.coordinates.showTooltip then
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
      },
      showTooltip = {
        name = "Show Tooltip",
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.coordinates.showTooltip; end,
        set = function(_, val)
          xb.db.profile.modules.coordinates.showTooltip = val
          if val then
            self:CreateTooltip()
          else
            self.tooltip = nil
          end
        end
      }
    }
  }
 end
