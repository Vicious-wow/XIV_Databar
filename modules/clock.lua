local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local ClockModule = xb:NewModule("ClockModule", 'AceEvent-3.0')

function ClockModule:GetName()
  return TIMEMANAGER_TITLE;
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
  self.clockFrame:Show()
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

  if InCombatLockdown() then
    self:SetClockColor()
    return
  end

  self.clockText:SetFont(xb:GetFont(db.modules.clock.fontSize))
  self:SetClockColor()

  self.clockFrame:SetSize(self.clockText:GetStringWidth(), self.clockText:GetStringHeight())
  self.clockFrame:SetPoint('CENTER')

  self.clockTextFrame:SetSize(self.clockText:GetStringWidth(), self.clockText:GetStringHeight())
  self.clockTextFrame:SetPoint('CENTER')

  self.clockText:SetPoint('CENTER')

  self.eventText:SetFont(xb:GetFont(db.text.smallFontSize))
  self.eventText:SetPoint('CENTER', self.clockText, xb.miniTextPosition)
  if xb.db.profile.modules.clock.hideEventText then
    self.eventText:Hide()
  end
end

function ClockModule:CreateFrames()
  self.clockTextFrame = self.clockTextFrame or CreateFrame("BUTTON", nil, self.clockFrame)
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

      if not xb.db.profile.modules.clock.hideEventText then
        local eventInvites = CalendarGetNumPendingInvites()
        if eventInvites > 0 then
          ClockModule.eventText:SetText(string.format("%s  (|cffffff00%i|r)", L['New Event!'], eventInvites))
        end
      end

      ClockModule:Refresh()
      ClockModule.elapsed = 0
    end
  end)

  self.clockTextFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    ClockModule:SetClockColor()
    GameTooltip:SetOwner(ClockModule.clockTextFrame, 'ANCHOR_'..xb.miniTextPosition)
    GameTooltip:AddLine("[|cff6699FF"..TIMEMANAGER_TITLE.."|r]")
    GameTooltip:AddLine(" ")
    local clockTime = nil
    local ttTimeText = ''
    if xb.db.profile.modules.clock.serverTime then
      clockTime = time()
      ttTimeText = L['Local Time'];
    else
      clockTime = GetServerTime()
      ttTimeText = L['Realm Time'];
    end
    GameTooltip:AddDoubleLine(ttTimeText, date(ClockModule.timeFormats[xb.db.profile.modules.clock.timeFormat], clockTime), 1, 1, 0, 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine('<'..L['Left-Click']..'>', L['Open Calendar'], 1, 1, 0, 1, 1, 1)
    GameTooltip:AddDoubleLine('<'..L['Right-Click']..'>', L['Open Clock'], 1, 1, 0, 1, 1, 1)
    GameTooltip:Show()
  end)

  self.clockTextFrame:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    ClockModule:SetClockColor()
    GameTooltip:Hide()
  end)

  self.clockTextFrame:SetScript('OnClick', function(_, button)
    if InCombatLockdown() then return; end
    if button == 'LeftButton' then
      ToggleCalendar()
    elseif button == 'RightButton' then
      ToggleTimeManager()
    end
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
      serverTime = false,
      hideEventText = false
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
        set = function(_, val)
          xb.db.profile.modules.clock.enabled = val
          if val then
            self:Enable()
          else
            self:Disable()
          end
        end,
        width = "full",
        hidden = true
      },
      useServerTime = {
        name = L['Use Server Time'],
        order = 1,
        type = "toggle",
        get = function() return xb.db.profile.modules.clock.serverTime; end,
        set = function(_, val) xb.db.profile.modules.clock.serverTime = val; end
      },
      hideEventText = {
        name = L['Hide Event Text'],
        order = 2,
        type = "toggle",
        get = function() return xb.db.profile.modules.clock.hideEventText; end,
        set = function(_, val) xb.db.profile.modules.clock.hideEventText = val; end
      },
      timeFormat = {
        name = L['Time Format'],
        order = 3,
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
        name = FONT_SIZE,
        type = 'range',
        order = 4,
        min = 10,
        max = 20,
        step = 1,
        get = function() return xb.db.profile.modules.clock.fontSize; end,
        set = function(info, val) xb.db.profile.modules.clock.fontSize = val; self:Refresh(); end
      }
    }
  }
end
