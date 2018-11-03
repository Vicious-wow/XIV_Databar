local addOnName, XB = ...;

local Clock = XB:RegisterModule(TIMEMANAGER_TITLE)

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT
local clock_config
local Bar, BarFrame
local clockFrame, clockText

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local e = 0
local function updateTime(elapsed)
  e = e + elapsed
  if e >= 1 then
    hour, minu = GetGameTime()--CF time on the current version
    if minu < 10 then minu = ("0"..minu) end
    if GetCVarBool("timeMgrUseLocalTime") then
     -- print("localTime used")
      if GetCVarBool("timeMgrUseMilitaryTime") then
       -- print("military")
        clockText:SetText(date("%H:%M")) 
      else
       -- print("no military")
        clockText:SetText(date("%I:%M").." "..date("%p"))
      end     
    else
     -- print("server time")
      if GetCVarBool("timeMgrUseMilitaryTime") then
        --print("military")
        clockText:SetText(hour..":"..minu)
      else
       -- print("no military")
        if hour > 12 then 
          hour = hour - 12
          hour = ("0"..hour)
          AmPmTimeText = "PM"
        else 
          AmPmTimeText = "AM"
        end
        clockText:SetText(hour..":"..minu.." "..AmPmTimeText)  
      end     

    end
    if (C_Calendar.GetNumPendingInvites() > 0) then
      --calendarText:SetText(string.format("%s  (|cffffff00%i|r)", "New Event!", (C_Calendar.GetNumPendingInvites())))
    else
      --calendarText:SetText("")
    end
    clockFrame:SetWidth(clockText:GetStringWidth()) --+ amText:GetStringWidth())
    clockFrame:SetPoint(Clock.settings.anchor, BarFrame)
    e = 0
  end
end

local function tooltip()
  if libTT:IsAcquired("ClockTooltip") then
    libTT:Release(libTT:Acquire("ClockTooltip"))
  end

  local tooltip = libTT:Acquire("ClockTooltip", 1)

  tooltip:SmartAnchorTo(clockFrame)
  tooltip:SetAutoHideDelay(.3, clockFrame)
  tooltip:AddHeader("[|cff6699FF"..TIMEMANAGER_TITLE.."|r]")
  tooltip:AddLine(" ")

  hour, minu = GetGameTime()
  if minu < 10 then minu = ("0"..minu) end
  if ( GetCVarBool("timeMgrUseLocalTime") ) then
    tooltip:AddLine("|cffffff00Realm Time: |r"..hour..":"..minu)
  else
    tooltip:AddLine("|cffffff00Local Time: |r"..date("%H:%M"))
  end
  tooltip:AddLine(" ")
  tooltip:AddLine("|cffffff00<Left-click>|r ".."Open Calendar")
  tooltip:AddLine("|cffffff00<Right-click>|r "..SHOW_CLOCK)
  tooltip:Show();

  XB:SkinTooltip(tooltip,"ClockTooltip")
end

local function refreshOptions()
  Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local clock_default = {
  profile = {
    enable = true,
    combatEn = false,
    lock = true,
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    anchor = "CENTER",
    color = {1,1,1,.75},
    hover = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
    hoverCC = not (XB.playerClass == "PRIEST"),
  }
}

----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Clock:OnInitialize()
  libTT = LibStub('LibQTip-1.0')
  self.db = XB.db:RegisterNamespace("Clock", clock_default)
    self.settings = self.db.profile
end

function Clock:OnEnable()
  Clock.settings.lock = Clock.settings.lock or not Clock.settings.lock --Locking frame if it was not locked on reload/relog
  refreshOptions()
  XB.Config:Register("Clock",clock_config)
  
  if self.settings.enable and not self:IsEnabled() then
    self:Enable()
  elseif not self.settings.enable and self:IsEnabled() then
    self:Disable()
  else
    self:CreateFrames()
  end
end

function Clock:OnDisable()
  
end


function Clock:CreateFrames()
  if not self.settings.enable then
    if clockFrame and clockFrame:IsVisible() then
      clockFrame:Hide()
    end
    return
  end
  
  local w,h,x,y,a,color,hover = self.settings.w,self.settings.h,self.settings.x,self.settings.y,self.settings.anchor,self.settings.color,self.settings.hover
  
  clockFrame = clockFrame or CreateFrame("BUTTON","Clock",BarFrame)
  clockFrame:SetSize(w, h)
  clockFrame:SetPoint(a,x,y)
  clockFrame:EnableMouse(true)
  clockFrame:RegisterForClicks("AnyUp")
  clockFrame:Show()
  
  clockText = clockText or clockFrame:CreateFontString(nil,"OVERLAY")
  clockText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf", h)
  clockText:SetPoint("LEFT")
  clockText:SetTextColor(unpack(color))
   
  clockFrame:SetScript("OnEnter", function()
    if InCombatLockdown() and not self.settings.combatEn then return end

    clockText:SetVertexColor(unpack(hover))
    tooltip()
  end)

  clockFrame:SetScript("OnLeave", function() 
    if InCombatLockdown() and not self.settings.combatEn then return end
    clockText:SetVertexColor(unpack(color))
  end)

  clockFrame:SetScript("OnClick", function(_,button,_)
    if InCombatLockdown() and not self.settings.combatEn then return end
    if button == "LeftButton" then
      ToggleCalendar()
    elseif button == "RightButton" then 
      ToggleTimeManager()
    end
  end)

  clockFrame:SetScript("OnUpdate", function(self, elapsed)
    updateTime(elapsed)
  end)

end
--[[local AddOnName, XIVBar = ...;
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
]]--