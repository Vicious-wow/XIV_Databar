local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------
if not cfg.system.show then return end

local onHover = false

 local memformat = function(number)
    if number > 1024 then
      return string.format("%.2f|r mb", (number / 1024))
    else
      return string.format("%.1f|r kb", floor(number))
    end
  end

local systemFrame = CreateFrame("Frame",nil, cfg.SXframe)
systemFrame:SetPoint("RIGHT", -350,0)
systemFrame:SetSize(120, 16)
---------------------------------------------------------------------

local addoncompare = function(a, b)
	return a.memory > b.memory
end

 local function systemBarOnEnter()
 if not cfg.system.showTooltip then return end
	GameTooltip:SetOwner(systemFrame, cfg.tooltipPos)
	GameTooltip:AddLine("[|cff6699FFPerformance|r]")
	GameTooltip:AddLine(" ")
	---------------------------------------------------
	local color = { r=1, g=1, b=0 }
    local blizz = collectgarbage("count")
    local addons = {}
    local enry, memory
    local total = 0
    local nr = 0
	local numberOfAddons = 0
    UpdateAddOnMemoryUsage()
	if IsShiftKeyDown() then
    GameTooltip:AddLine("Top "..cfg.system.addonListShift.." AddOns", 1,1,0)
	else
	GameTooltip:AddLine("Top "..cfg.system.addonList.." AddOns", 1,1,0)
	end
    GameTooltip:AddLine(" ")
    for i=1, GetNumAddOns(), 1 do
      if (GetAddOnMemoryUsage(i) > 0 ) then
        memory = GetAddOnMemoryUsage(i)
        entry = {name = GetAddOnInfo(i), memory = memory}
        table.insert(addons, entry)
        total = total + memory
      end
    end
    table.sort(addons, addoncompare)
    for _, entry in pairs(addons) do
		if IsShiftKeyDown() then
			numberOfAddons = cfg.system.addonListShift
		else
			numberOfAddons = cfg.system.addonList
		end
		if nr < numberOfAddons then
			GameTooltip:AddDoubleLine(entry.name, memformat(entry.memory), 1, 1, 0, 1, 1, 1)
			nr = nr+1
		end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Total", memformat(total), 1,1,0, 1,1,0)
    GameTooltip:AddDoubleLine("Total incl. Blizzard", memformat(blizz), 1,1,0, 1,1,0)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("<Left-click>", "Force garbage collection", 1, 1, 0, 1, 1, 1)
	if not IsShiftKeyDown() then
		GameTooltip:AddDoubleLine("<Shift-hold>", "Show |cffffff00"..cfg.system.addonListShift.."|r addons", 1, 1, 0, 1, 1, 1)
	end
	-------------------------------------------
	GameTooltip:Show()
end

local function systemBarOnLeave()
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
end

---------------------------------------------------------------------

local pingFrame = CreateFrame("BUTTON","SX_pingFrame", systemFrame)
pingFrame:SetPoint("CENTER")
pingFrame:SetSize(16, 16)
pingFrame:EnableMouse(true)
pingFrame:RegisterForClicks("AnyUp")

local pingIcon = pingFrame:CreateTexture(nil,"OVERLAY",nil,7)
pingIcon:SetSize(16, 16)
pingIcon:SetPoint("CENTER")
pingIcon:SetTexture(cfg.mediaFolder.."datatexts\\ping")
pingIcon:SetVertexColor(unpack(cfg.color.normal))

local pingText = pingFrame:CreateFontString(nil, "OVERLAY")
pingText:SetFont(cfg.text.font, cfg.text.normalFontSize)
pingText:SetPoint("LEFT", pingIcon,"RIGHT",2,0)
pingText:SetTextColor(unpack(cfg.color.normal))

pingFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	pingIcon:SetVertexColor(unpack(cfg.color.hover))
	onHover = true
	systemBarOnEnter()
end)

pingFrame:SetScript("OnLeave", function()
	pingIcon:SetVertexColor(unpack(cfg.color.normal))
	onHover = false
	systemBarOnLeave()
end)

pingFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		UpdateAddOnMemoryUsage()
		local before = gcinfo()
		collectgarbage()
		UpdateAddOnMemoryUsage()
		local after = gcinfo()
		print("|cff6699FFSXUI|r: Cleaned: |cffffff00"..memformat(before-after))
	elseif button == "RightButton" then
		ToggleFrame(VideoOptionsFrame)
	end
end)
---------------------------------------------------------------------
local fpsFrame = CreateFrame("BUTTON",nil, systemFrame)
fpsFrame:SetPoint("LEFT")
fpsFrame:SetSize(16, 16)
fpsFrame:EnableMouse(true)
fpsFrame:RegisterForClicks("AnyUp")

local fpsIcon = fpsFrame:CreateTexture(nil,"OVERLAY",nil,7)
fpsIcon:SetSize(16, 16)
fpsIcon:SetPoint("LEFT")
fpsIcon:SetTexture(cfg.mediaFolder.."datatexts\\fps")
fpsIcon:SetVertexColor(unpack(cfg.color.normal))

local fpsText = fpsFrame:CreateFontString(nil, "OVERLAY")
fpsText:SetFont(cfg.text.font, cfg.text.normalFontSize)
fpsText:SetPoint("LEFT", fpsIcon,"RIGHT",2,0)
fpsText:SetTextColor(unpack(cfg.color.normal))

fpsFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	fpsIcon:SetVertexColor(unpack(cfg.color.hover))
	onHover = true
	systemBarOnEnter()
end)

fpsFrame:SetScript("OnLeave", function()
	fpsIcon:SetVertexColor(unpack(cfg.color.normal))
	onHover = false
	systemBarOnLeave()
end)

fpsFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		UpdateAddOnMemoryUsage()
		local before = gcinfo()
		collectgarbage()
		UpdateAddOnMemoryUsage()
		local after = gcinfo()
		print("|cff6699FFSXUI|r: Cleaned: |cffffff00"..memformat(before-after))
	elseif button == "RightButton" then
		ToggleFrame(VideoOptionsFrame)
	end
end)
---------------------------------------------------------------------

local function SXUImemory()
local t = 0
UpdateAddOnMemoryUsage()
for i=1, GetNumAddOns(), 1 do
	t = t + GetAddOnMemoryUsage(i)
end
return cfg.memformat(t)

end

local function updatePerformanceText()
	local fps = floor(GetFramerate())
	local BWIn, BWOut, LCHome, LCWorld = GetNetStats()
  local pingString = LCHome.."ms";
  if cfg.system.showWorldPing then
    pingString = pingString.." "..LCWorld.."ms"
  end

	pingText:SetText(pingString)
	pingFrame:SetSize(pingText:GetStringWidth()+18, 16)
	fpsText:SetText(fps.."fps")
	fpsFrame:SetSize(fpsText:GetStringWidth()+18, 16)
	if onHover then
		systemBarOnEnter()
	end
end

local elapsed = 0
systemFrame:SetScript('OnUpdate', function(self, e)
	elapsed = elapsed + e
	if elapsed >= 1 then
		updatePerformanceText()
		elapsed = 0
	end
end)

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("MODIFIER_STATE_CHANGED")

eventframe:SetScript("OnEvent", function(this, event, arg1, arg2, arg3, arg4, ...)

if event == "MODIFIER_STATE_CHANGED" then
		if InCombatLockdown() then return end
		if arg1 == "LSHIFT" or arg1 == "RSHIFT" then
			if arg2 == 1 then
					if onHover then
		systemBarOnEnter()
	end
			elseif arg2 == 0 then
					if onHover then
		systemBarOnEnter()
	end
			end
		end
	end
end)
