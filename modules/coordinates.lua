-- load globals
local addon, xb = ...
local _G = _G
local L = xb.L

-- declare object
local CoordinatesModule = xb:NewModule("CoordinatesModule", "AceEvent-3.0")

-- we need to update on a ticker as opposed to game events # CHECKME
local ticker = nil

-- Return internal module name
function CoordinatesModule:GetInternalName()
  return "coordinates"
end

-- OnInit
function CoordinatesModule:OnInitialize()
  -- reset whole frame
  -- reset bar icon
  -- reset bar text
  -- reset parent module name
  -- reset hover tooltip
  self.frame = nil
  self.icon = nil
  self.text = nil
  self.parentModuleName = nil
  -- Tooltip # CHECKME
  self.tooltip = nil
end

-- When setting is set to Enable
function CoordinatesModule:OnEnable()
  -- Create frame
  self:CreateModuleFrame()
  -- Show frame
  self.frame:Show()
  -- Register local events
  self:RegisterEvents()
  -- Update parent frame
  self.parentModuleName = self:GetParentModuleName()
  -- Update frame
  self:UpdateModuleFramePosition()
  -- Create tooltip # CHECKME
  self:CreateTooltip()

  -- Start ticker # CHECKME
  ticker = C_Timer.NewTicker(1, function() self:UpdateModuleValue() end)
end

-- When setting is set to Disable
function CoordinatesModule:OnDisable()
  -- If we have a frame
  if self.frame then
    -- Hide the frame
    self.frame:Hide()
    -- Unregister local events
    self.frame:UnregisterAllEvents()
    -- Destroy frame
    self.frame = nil
  end

  -- If we have a tooltip # CHECKME
  if self.tooltip then
    -- Hide the tooltip
    self.tooltip:Hide()
    -- Destroy tooltip
    self.tooltip = nil
  end

  -- Cancel ticker # CHECKME
  ticker:Cancel()
end

-- Create module frame
function CoordinatesModule:CreateModuleFrame()
  -- GTFO if it's already made
  if self.frame ~= nil then return end

  -- Create frame
  -- Register frame
  -- Enable mouse interactions
  self.frame = CreateFrame("BUTTON", self:GetInternalName() .. "Frame", xb:GetFrame("bar"))
  xb:RegisterFrame(self:GetInternalName() .. "Frame", self.frame)
  self.frame:EnableMouse(true)

  -- Register for mouse clicks # CHECKME
  self.frame:RegisterForClicks("AnyUp")

  -- Update frame position
  self:UpdateModuleFramePosition()

  -- Set icon
  self.icon = self.frame:CreateTexture(nil, "OVERLAY", nil, 7)
  self.icon:SetPoint("LEFT")
  -- FIXME: Use a different icon
  self.icon:SetTexture(xb.constants.mediaPath .. "datatexts\\sound")
  self.icon:SetVertexColor(xb:GetColor("normal"))

  -- Set text
  self.text = self.frame:CreateFontString(nil, "OVERLAY")
  self.text:SetFont(xb:GetFont(xb.db.profile.text.fontSize))
  self.text:SetPoint("RIGHT", self.frame, 2, 0)
  self.text:SetTextColor(xb:GetColor("inactive"))
  self.text:SetText(L[string.gsub(self:GetInternalName(), "^%l", string.upper)])
end

-- Get and return parent module frame name
function CoordinatesModule:GetParentModuleName()
  local parentFrame = nil
  local testFrame = nil

  -- Get module info from core
  -- Module frame names follow pattern of: moduleName .. "Frame"
  -- #CHECKME for proper list of module names
  local moduleList = "middle"
  local moduleNames = xb.db.profile.modulePos[moduleList]
  local countIndex = 0
  for _ in pairs(moduleNames) do countIndex = countIndex + 1 end

  local startIndex = ((moduleList == "right") and 1 or countIndex)
  local endIndex = ((moduleList == "right") and countIndex or 1)
  local stepIndex = ((moduleList == "right") and 1 or -1)

  local moduleKey = ""
  local frameName = ""

  for i = startIndex, endIndex, stepIndex do
    moduleKey = moduleNames[i]
    if moduleKey ~= self:GetInternalName() then
      frameName = moduleKey .. ((moduleKey == "bar") and "" or "Frame")
      testFrame = xb:GetFrame(frameName)
      print("Checking Frame: " .. frameName)
      -- If this current test succeeds
      -- If this current test is visible
      -- This is our parent frame
      if testFrame ~= nil and testFrame:IsVisible() then
        parentFrame = frameName
        break
      end
    end
  end

  if parentFrame ~= nil then
    print("Parent Frame: " .. parentFrame)
  end

  return parentFrame
end

-- Reset position of frame
function CoordinatesModule:UpdateModuleFramePosition()
  local relativeAnchorPoint = "RIGHT"
  local xOffset = xb.db.profile.general.moduleSpacing

  local parentFrame = self:GetParentModuleName()
  if parentFrame ~= nil then
    if parentFrame == "barFrame" then
      relativeAnchorPoint = "LEFT"
      xOffset = 0
    end
  end

  if parentFrame ~= nil then
    parentFrame = xb:GetFrame(parentFrame)
    self.frame:SetPoint("LEFT", parentFrame, relativeAnchorPoint, xOffset, 0)
  end
end

-- Register local events
-- Hover colors; tooltip # CHECKME
-- Click events
function CoordinatesModule:RegisterEvents()
  self.frame:SetScript(
    "OnEnter",
    function()
      if InCombatLockdown() then
        return
      end
      self.icon:SetVertexColor(xb:GetColor("hover"))
      self.text:SetTextColor(xb:GetColor("hover"))
      -- Show tooltip # CHECKME
      if xb.db.profile.modules[self:GetInternalName()].showTooltip then
        self.tooltip:Show()
      end
    end
  )

  self.frame:SetScript(
    "OnLeave",
    function()
      self.icon:SetVertexColor(xb:GetColor("normal"))
      self.text:SetTextColor(xb:GetColor("inactive"))
      -- Hide tooltip # CHECKME
      if xb.db.profile.modules[self:GetInternalName()].showTooltip then
        self.tooltip:Hide()
      end
    end
  )

  -- Custom click event # CHECKME
  self.frame:SetScript(
    "OnClick",
    function(self, button, down)
      if not WorldMapFrame:IsVisible() then
        WorldMapFrame:Show()
      else
        WorldMapFrame:Hide()
      end
    end
  )

  -- If a module frame is hidden, refresh
  -- Check against last known Parent Module
  self:RegisterMessage(
    "XIVBar_FrameHide",
    function(_, name)
      if name == self.parentModuleName then
        self:Refresh()
      end
    end
  )

  -- If a module frame is shown, refresh
  -- Check against *current* Parent Module
  self:RegisterMessage(
    "XIVBar_FrameShow",
    function(_, name)
      self.parentModuleName = self:GetParentModuleName()
      if name == self.parentModuleName then
        self:Refresh()
      end
    end
  )
end

-- Create tooltip # CHECKME
function CoordinatesModule:CreateTooltip()
  if xb.db.profile.modules[self:GetInternalName()].showTooltip and CoordinatesModule.tooltip == nil then
    CoordinatesModule.tooltip = GameTooltip
  end
end

-- Do the hard work for the bar text
function CoordinatesModule:GetCoordinates()
  local map = C_Map.GetBestMapForUnit("player")
  local posX, posY = "0.0", "0.0"
  if map then
    local position = C_Map.GetPlayerMapPosition(map, "player")
    if position then
      posX, posY = position:GetXY()
      posX = string.format("%.1f", posX * 100)
      posY = string.format("%.1f", posY * 100)
    end
  end
  if string.find(posX, ".") == nil then
    posX = posX .. ".0"
  end
  if string.find(posY, ".") == nil then
    posY = posY .. ".0"
  end

  return posX .. ", " .. posY
end

-- Do the harder work for the bar text and tooltip
function CoordinatesModule:UpdateModuleValue()
  local coordinates = self:GetCoordinates()

  -- Set bar text and frame width
  if self.text and self.frame then
    self.text:SetText(coordinates)
    self.frame:SetSize(self.text:GetStringWidth() + 18, 16)
  end

  -- Set tooltip
  if xb.db.profile.modules[self:GetInternalName()].showTooltip then
    self.tooltip:SetOwner(self.frame, "ANCHOR_" .. ((xb.db.profile.general.barPosition == "TOP") and "BOTTOM" or "TOP"))
    local title = "[|cff6699FF" .. L["Location"] .. "|r]"
    self.tooltip:AddLine(title)
    self.tooltip:AddLine(" ")
    self.tooltip:AddDoubleLine("<" .. L["Zone"] .. ">", "|cffffffff" .. GetZoneText() .. "|r")
    self.tooltip:AddDoubleLine("<" .. L["Subzone"] .. ">", "|cffffffff" .. GetSubZoneText() .. "|r")
    self.tooltip:AddDoubleLine("<" .. L["Coordinates"] .. ">", "|cffffffff" .. coordinates .. "|r")
  end
end

-- Refresh everything
function CoordinatesModule:Refresh()
  -- GTFO if we're not enabled
  if not xb.db.profile.modules[self:GetInternalName()].enabled then self:Disable() return end

  -- If there's no frame, run Enabled script
  if not self.frame and xb.db.profile.modules[self:GetInternalName()].enabled then self:Enable() return end

  -- If we've got a frame, hide it, reposition it, show it again
  if self.frame then
    self.frame:Hide()
    self:UpdateModuleFramePosition()
    self.frame:Show()
  end
end

-- Set default module options
-- Default to disabled
function CoordinatesModule:GetDefaultOptions()
  return self:GetInternalName(), {
    enabled = false
  }
end

-- Set Interface Options
function CoordinatesModule:GetConfig()
  return {
    name = L[string.gsub(self:GetInternalName(), "^%l", string.upper)],
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules[self:GetInternalName()].enabled end,
        set = function(_, val)
          xb.db.profile.modules[self:GetInternalName()].enabled = val
          if val then
            self:Enable()
          else
            self:Disable()
          end
        end,
        width = "full"
      },
      showTooltip = {
        name = "Show Tooltip",
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules[self:GetInternalName()].showTooltip end,
        set = function(_, val)
          xb.db.profile.modules[self:GetInternalName()].showTooltip = val
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
