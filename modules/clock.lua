local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------
if not cfg.clock.show then return end

local hour, minu = 0,0
local AmPmTimeText = ""

local clockFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
clockFrame:SetSize(32, 32)
clockFrame:SetPoint("CENTER")
clockFrame:EnableMouse(true)
clockFrame:RegisterForClicks("AnyUp")

local clockText = clockFrame:CreateFontString(nil, "OVERLAY")
clockText:SetFont(cfg.text.font, cfg.SXframe:GetHeight()-4)
clockText:SetPoint("LEFT")
clockText:SetTextColor(unpack(cfg.color.normal))

local amText = clockFrame:CreateFontString(nil, "OVERLAY")
amText:SetFont(cfg.text.font, cfg.text.normalFontSize)
amText:SetPoint("RIGHT")
amText:SetTextColor(unpack(cfg.color.inactive))

local calendarText = clockFrame:CreateFontString(nil, "OVERLAY")
calendarText:SetFont(cfg.text.font, cfg.text.smallFontSize)
calendarText:SetPoint("CENTER", clockFrame, "TOP")
if cfg.core.position ~= "BOTTOM" then
	calendarText:SetPoint("CENTER", clockFrame, "BOTTOM")
end
calendarText:SetTextColor(unpack(cfg.color.normal))

local elapsed = 0
clockFrame:SetScript('OnUpdate', function(self, e)
	elapsed = elapsed + e
	if elapsed >= 1 then
		hour, minu = GetGameTime()
		if minu < 10 then minu = ("0"..minu) end
		if ( GetCVarBool("timeMgrUseLocalTime") ) then
			if ( GetCVarBool("timeMgrUseMilitaryTime") ) then
				clockText:SetText(date("%H:%M"))
				amText:SetText("")	
			else
				clockText:SetText(date("%I:%M"))
				amText:SetText(date("%p"))		
			end			
		else
			if ( GetCVarBool("timeMgrUseMilitaryTime") ) then
				clockText:SetText(hour..":"..minu)
				amText:SetText("")	
			else
				if hour > 12 then 
					hour = hour - 12
					hour = ("0"..hour)
					AmPmTimeText = "PM"
				else 
					AmPmTimeText = "AM"
				end
				clockText:SetText(hour..":"..minu)
				amText:SetText(AmPmTimeText)		
			end			

		end
		if (CalendarGetNumPendingInvites() > 0) then
			calendarText:SetText(string.format("%s  (|cffffff00%i|r)", "New Event!", (CalendarGetNumPendingInvites())))
		else
			calendarText:SetText("")
		end
		clockFrame:SetWidth(clockText:GetStringWidth() + amText:GetStringWidth())
		clockFrame:SetPoint("CENTER", cfg.SXframe)
		elapsed = 0
	end
end)

--[[

--]]

clockFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	clockText:SetTextColor(unpack(cfg.color.hover))
	if cfg.clock.showTooltip then
	hour, minu = GetGameTime()
	if minu < 10 then minu = ("0"..minu) end
	GameTooltip:SetOwner(clockFrame, cfg.tooltipPos)
	GameTooltip:AddLine("[|cff6699FFClock|r]")
	GameTooltip:AddLine(" ")
	if ( GetCVarBool("timeMgrUseLocalTime") ) then
		GameTooltip:AddDoubleLine("Realm Time", hour..":"..minu, 1, 1, 0, 1, 1, 1)
	else
		GameTooltip:AddDoubleLine("Local Time", date("%H:%M"), 1, 1, 0, 1, 1, 1)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("<Left-click>", "Open Calendar", 1, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("<Right-click>", "Open Clock", 1, 1, 0, 1, 1, 1)
	GameTooltip:Show()
	end	
end)

clockFrame:SetScript("OnLeave", function() if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end clockText:SetTextColor(unpack(cfg.color.normal)) end)

clockFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleCalendar()
	elseif button == "RightButton" then 
		ToggleTimeManager()
	end
end)