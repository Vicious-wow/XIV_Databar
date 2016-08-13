local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local ClockModule = xb:NewModule("ClockModule")

function ClockModule:GetName()
  return L['Clock'];
end

function ClockModule:OnInitialize()
  if IsWindowsClient() then
    self.timeFormats = {
      twelveAmPm = '%I:%M %p',
      twelveNoAm = '%I:%M',
      twelveAmNoZero = '%#I:%M %p',
      twelveNoAmNoZero = '%#I:%M',
      twoFour = '%#H:%M',
      twoFourNoZero = '%H:%M',
    }
  else
    self.timeFormats = {
      twelveAmPm = '%I:%M %p',
      twelveNoAm = '%I:%M',
      twelveAmNoZero = '%l:%M %p',
      twelveNoAmNoZero = '%l:%M',
      twoFour = '%R',
      twoFourNoZero = '%k:%M',
    }
  end

  self.exampleTimeFormats = {
    twelveAmPm = '08:00 AM (12 Hour)',
    twelveNoAm = '08:00 (12 Hour)',
    twelveAmNoZero = '8:00 AM (12 Hour)',
    twelveNoAmNoZero = '8:00 (12 Hour)',
    twoFour = '08:00 (24 Hour)',
    twoFourNoZero = '8:00 (24 Hour)'
  }

  self.elapsed = 0

  self.functions = {}
end

function ClockModule:OnEnable()
  if self.clockFrame == nil then
    self.clockFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
    xb:RegisterFrame('clockFrame', self.clockFrame)
  end
  self.elapsed = 0
  self:CreateFrames()
  self:CreateClickFunctions()
  self:RegisterFrameEvents()
  self:Refresh()
end

function ClockModule:OnDisable()
  self.clockFrame:Hide()
end

function ClockModule:Refresh()
  local db = xb.db.profile
  if self.clockFrame == nil then return; end
  if not db.modules.clock.enabled then return; end

  --self.clockText:SetAllPoints()
  self.clockText:SetFont(xb.LSM:Fetch(xb.LSM.MediaType.FONT, db.text.font), db.modules.clock.fontSize)
  ClockModule:SetClockColor()
  --self.clockFrame:SetSize(self.clockText:GetStringWidth(), self.clockText:GetStringHeight())
  self.clockFrame:SetSize(100, 30)
  self.clockFrame:SetPoint('CENTER', self.clockFrame:GetParent())
  self.clockTextFrame:SetSize(self.clockText:GetStringWidth(), self.clockText:GetStringHeight())
  self.clockTextFrame:SetPoint('CENTER')
  self.clockText:SetPoint('CENTER')
end

function ClockModule:CreateFrames()
  self.clockTextFrame = self.clockTextFrame or CreateFrame("BUTTON", 'XIV_ClockTextFrame', self.clockFrame)
  self.clockText = self.clockText or self.clockTextFrame:CreateFontString(nil, "OVERLAY")
  self.eventText = self.eventText or self.clockTextFrame:CreateFontString(nil, "OVERLAY")
end

function ClockModule:RegisterFrameEvents()

  self.clockTextFrame:EnableMouse(true)
  self.clockTextFrame:RegisterForClicks("AnyUp")

  self.clockFrame:SetScript("OnUpdate", function(self, elapsed)
    ClockModule.elapsed = ClockModule.elapsed + elapsed
    if ClockModule.elapsed >= 1 then
      local clockTime = nil
      if xb.db.profile.modules.clock.serverTime then
        clockTime = GetServerTime()
      else
        clockTime = time()
      end
      local dateString = date(ClockModule.timeFormats[xb.db.profile.modules.clock.timeFormat], clockTime)
      ClockModule.clockText:SetText(dateString)
      ClockModule:Refresh()
      ClockModule.elapsed = 0
    end
  end)

  self.clockTextFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    ClockModule:SetClockColor()
  end)

  self.clockTextFrame:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    ClockModule:SetClockColor()
  end)
end

function ClockModule:SetClockColor()
  local db = xb.db.profile
  if self.clockTextFrame:IsMouseOver() then
    self.clockText:SetTextColor(unpack(xb:HoverColors()))
  else
    self.clockText:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
  end
end

function ClockModule:UnregisterFrameEvents()
end

function ClockModule:CreateClickFunctions()
end

function ClockModule:GetDefaultOptions()
  return 'clock', {
      enabled = true,
      timeFormat = 'twelveAmPm',
      fontSize = 20,
      serverTime = false
    }
end

function ClockModule:GetConfig()
  local timeFormatOptions = self.exampleTimeFormats
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.clock.enabled; end,
        set = function(_, val) xb.db.profile.modules.clock.enabled = val; end,
        width = "full"
      },
      enable = {
        name = L['Use Server Time'],
        order = 1,
        type = "toggle",
        get = function() return xb.db.profile.modules.clock.serverTime; end,
        set = function(_, val) xb.db.profile.modules.clock.serverTime = val; end
      },
      timeFormat = {
        name = L['Time Format'],
        order = 2,
        type = "select",
        values = { --TODO: WTF is with this not accepting a variable?
          twelveAmPm = '08:00 AM (12 Hour)',
          twelveNoAm = '08:00 (12 Hour)',
          twelveAmNoZero = '8:00 AM (12 Hour)',
          twelveNoAmNoZero = '8:00 (12 Hour)',
          twoFour = '08:00 (24 Hour)',
          twoFourNoZero = '8:00 (24 Hour)'
        },
        style = "dropdown",
        get = function() return xb.db.profile.modules.clock.timeFormat; end,
        set = function(info, val) xb.db.profile.modules.clock.timeFormat = val; self:Refresh(); end
      },
      fontSize = {
        name = L['Font Size'],
        type = 'range',
        order = 3,
        min = 10,
        max = 20,
        step = 1,
        get = function() return xb.db.profile.modules.clock.fontSize; end,
        set = function(info, val) xb.db.profile.modules.clock.fontSize = val; self:Refresh(); end
      }
    }
  }
end
