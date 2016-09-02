local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------
if not cfg.currency.show then return end

local iconPos = "RIGHT"
local textPos = "LEFT"

if cfg.currency.textOnRight then
	iconPos = "LEFT"
	textPos = "RIGHT"
end

local currencyFrame = CreateFrame("Frame",nil, cfg.SXframe)
currencyFrame:SetPoint("LEFT", cfg.SXframe, "CENTER", 340,0)
currencyFrame:SetSize(16, 16)

---------------------------------------------
-- XP BAR
---------------------------------------------
local xpFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
xpFrame:SetPoint("LEFT", cfg.SXframe, "CENTER", 350,0)
xpFrame:SetSize(16, 16)
xpFrame:EnableMouse(true)
xpFrame:RegisterForClicks("AnyUp")

local xpIcon = xpFrame:CreateTexture(nil,"OVERLAY",nil,7)
xpIcon:SetSize(16, 16)
xpIcon:SetPoint("LEFT")
xpIcon:SetTexture(cfg.mediaFolder.."datatexts\\exp")
xpIcon:SetVertexColor(unpack(cfg.color.normal))

local xpText = xpFrame:CreateFontString(nil, "OVERLAY")
xpText:SetFont(cfg.text.font, cfg.text.normalFontSize)
xpText:SetPoint("RIGHT",xpFrame,2,0 )
xpText:SetTextColor(unpack(cfg.color.normal))

local xpStatusbar = CreateFrame("StatusBar", nil, xpFrame)
xpStatusbar:SetStatusBarTexture(1,1,1)
xpStatusbar:SetStatusBarColor(unpack(cfg.color.normal))
xpStatusbar:SetPoint("TOPLEFT", xpText, "BOTTOMLEFT",0,-2)

local xpStatusbarBG = xpStatusbar:CreateTexture(nil,"BACKGROUND",nil,7)
xpStatusbarBG:SetPoint("TOPLEFT", xpText, "BOTTOMLEFT",0,-2)
xpStatusbarBG:SetColorTexture(unpack(cfg.color.inactive))

xpFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	xpIcon:SetVertexColor(unpack(cfg.color.hover))
	xpStatusbar:SetStatusBarColor(unpack(cfg.color.hover))
	if not cfg.currency.showTooltip then return end
	local mxp = UnitXPMax("player")
	local xp = UnitXP("player")
	local nxp = mxp - xp
	local rxp = GetXPExhaustion()
	local name, standing, minrep, maxrep, value = GetWatchedFactionInfo()

	if cfg.core.position ~= "BOTTOM" then
		GameTooltip:SetOwner(xpStatusbar, cfg.tooltipPos)
	else
		GameTooltip:SetOwner(xpFrame, cfg.tooltipPos)
	end

	GameTooltip:AddLine("[|cff6699FFExperience Bar|r]")
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(COMBAT_XP_GAIN, format(cfg.SVal(xp)).."|cffffd100/|r"..format(cfg.SVal(mxp)).." |cffffd100/|r "..floor((xp/mxp)*1000)/10 .."%",NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
	GameTooltip:AddDoubleLine(NEED, format(cfg.SVal(nxp)).." |cffffd100/|r "..floor((nxp/mxp)*1000)/10 .."%",NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
	if rxp then
		GameTooltip:AddDoubleLine(TUTORIAL_TITLE26, format(cfg.SVal(rxp)) .." |cffffd100/|r ".. floor((rxp/mxp)*1000)/10 .."%", NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
	end
	GameTooltip:Show()
end)

xpFrame:SetScript("OnLeave", function()
	xpIcon:SetVertexColor(unpack(cfg.color.normal))
	xpStatusbar:SetStatusBarColor(unpack(cfg.color.normal))
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
end)

---------------------------------------------
-- REROLL
---------------------------------------------
local rerollFrame = CreateFrame("BUTTON",nil, currencyFrame)
rerollFrame:SetPoint("LEFT")
rerollFrame:SetSize(16, 16)
rerollFrame:EnableMouse(true)
rerollFrame:RegisterForClicks("AnyUp")

local rerollIcon = rerollFrame:CreateTexture(nil,"OVERLAY",nil,7)
rerollIcon:SetSize(16, 16)
rerollIcon:SetPoint(iconPos)
rerollIcon:SetTexture(cfg.mediaFolder.."datatexts\\reroll")
rerollIcon:SetVertexColor(unpack(cfg.color.inactive))

local rerollText = rerollFrame:CreateFontString(nil, "OVERLAY")
rerollText:SetFont(cfg.text.font, cfg.text.normalFontSize)
--rerollText:SetPoint(iconPos,rerollIcon,textPos,-2,0)
rerollText:SetPoint(textPos)
rerollText:SetTextColor(unpack(cfg.color.inactive))

rerollFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	rerollIcon:SetVertexColor(unpack(cfg.color.hover))
	if not cfg.currency.showTooltip then return end
	GameTooltip:SetOwner(currencyFrame, cfg.tooltipPos)
	GameTooltip:AddLine("[|cff6699FFReroll|r]")
	GameTooltip:AddLine(" ")
	local SoIFname, SoIFamount, SoIFicon, SoIFearnedThisWeek, SoIFweeklyMax, SoIFtotalMax, SoIFisDiscovered = GetCurrencyInfo(1129)
	if SoIFamount > 0 then
		GameTooltip:AddLine(SoIFname,1,1,0)
		GameTooltip:AddDoubleLine("|cffffff00Weekly: |cffffffff"..SoIFearnedThisWeek.."|cffffff00/|cffffffff"..SoIFweeklyMax, "|cffffff00Total: |cffffffff"..SoIFamount.."|cffffff00/|cffffffff"..SoIFtotalMax)
	else
		local SoTFname, SoTFamount, SoTFicon, SoTFearnedThisWeek, SoTFweeklyMax, SoTFtotalMax, SoTFisDiscovered = GetCurrencyInfo(994)
		if SoTFamount > 0 then
			GameTooltip:AddDoubleLine(SoTFname, "|cffffff00Total: |cffffffff"..SoTFamount.."|cffffff00/|cffffffff"..SoTFtotalMax)
		end
	end
	GameTooltip:Show()
end)

rerollFrame:SetScript("OnLeave", function()
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
	rerollIcon:SetVertexColor(unpack(cfg.color.inactive))
end)

rerollFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleCharacter("TokenFrame")
	end
end)

---------------------------------------------
-- HONOR
---------------------------------------------

local honorFrame = CreateFrame("BUTTON",nil, currencyFrame)
honorFrame:SetPoint("LEFT",rerollFrame,"RIGHT",2,0)
honorFrame:SetSize(16, 16)
honorFrame:EnableMouse(true)
honorFrame:RegisterForClicks("AnyUp")

local honorIcon = honorFrame:CreateTexture(nil,"OVERLAY",nil,7)
honorIcon:SetSize(16, 16)
honorIcon:SetPoint(iconPos)
honorIcon:SetTexture(cfg.mediaFolder.."datatexts\\honor")
honorIcon:SetVertexColor(unpack(cfg.color.inactive))

local honorText = honorFrame:CreateFontString(nil, "OVERLAY")
honorText:SetFont(cfg.text.font, cfg.text.normalFontSize)
honorText:SetPoint(textPos)
honorText:SetTextColor(unpack(cfg.color.inactive))

honorFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	honorIcon:SetVertexColor(unpack(cfg.color.hover))
	if not cfg.currency.showTooltip then return end
	GameTooltip:SetOwner(currencyFrame, cfg.tooltipPos)
	GameTooltip:AddLine("[|cff6699FFHonor Level:|r"..UnitHonorLevel("player").."]")
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(concName,"|cffffff00Honor: |cffffffff"..UnitHonor("player").."|cffffff00/|cffffffff"..UnitHonorMax("player"))
	GameTooltip:Show()
end)

honorFrame:SetScript("OnLeave", function()
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
	honorIcon:SetVertexColor(unpack(cfg.color.inactive))
end)

honorFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleCharacter("TokenFrame")
	end
end)

---------------------------------------------
-- GARRISON RECOURCES
---------------------------------------------

local garrisonFrame = CreateFrame("BUTTON",nil, currencyFrame)
garrisonFrame:SetPoint("LEFT",honorFrame,"RIGHT",2,0)
garrisonFrame:SetSize(16, 16)
garrisonFrame:EnableMouse(true)
garrisonFrame:RegisterForClicks("AnyUp")

local garrisonIcon = garrisonFrame:CreateTexture(nil,"OVERLAY",nil,7)
garrisonIcon:SetSize(16, 16)
garrisonIcon:SetPoint(iconPos)
garrisonIcon:SetTexture(cfg.mediaFolder.."datatexts\\garres")
garrisonIcon:SetVertexColor(unpack(cfg.color.inactive))

local garrisonText = garrisonFrame:CreateFontString(nil, "OVERLAY")
garrisonText:SetFont(cfg.text.font, cfg.text.normalFontSize)
garrisonText:SetPoint(textPos)
garrisonText:SetTextColor(unpack(cfg.color.inactive))

garrisonFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	garrisonIcon:SetVertexColor(unpack(cfg.color.hover))
	if not cfg.currency.showTooltip then return end
	GameTooltip:SetOwner(currencyFrame, cfg.tooltipPos)
	GameTooltip:AddLine("[|cff6699FFGarrison Recources|r]")
	GameTooltip:AddLine(" ")
	local grName, grAmount, _, _, _, grTotalMax = GetCurrencyInfo(824)
	local oilName, oilAmount, _, _, _, oilTotalMax, oilIsDiscovered = GetCurrencyInfo(1101)
	local apexisName, apexisAmount = GetCurrencyInfo(823)
	local DICName, DICAmount, _, _, _, DICTotalMax = GetCurrencyInfo(980)

	GameTooltip:AddDoubleLine(grName, "|cffffffff"..format(cfg.SVal(grAmount)).."|cffffff00/|cffffffff"..format(cfg.SVal(grTotalMax)))
	if oilIsDiscovered then
		GameTooltip:AddDoubleLine(oilName, "|cffffffff"..format(cfg.SVal(oilAmount)).."|cffffff00/|cffffffff"..format(cfg.SVal(oilTotalMax)))
	end
	GameTooltip:AddDoubleLine(apexisName, "|cffffffff"..format(cfg.SVal(apexisAmount)))
	if DICAmount > 0 then
		GameTooltip:AddDoubleLine(DICName, "|cffffffff"..format(cfg.SVal(DICAmount)).."|cffffff00/|cffffffff"..format(cfg.SVal(DICTotalMax)))
	end
	GameTooltip:Show()
end)

garrisonFrame:SetScript("OnLeave", function()
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
	garrisonIcon:SetVertexColor(unpack(cfg.color.inactive))
end)

garrisonFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleCharacter("TokenFrame")
	end
end)


---------------------------------------------
-- FUNCTIONS
---------------------------------------------
local function updateXP(xp, mxp)
	if UnitLevel("player") == MAX_PLAYER_LEVEL or not cfg.currency.showXPbar then
		xpFrame:Hide()
		xpFrame:EnableMouse(false)
		currencyFrame:Show()
	else
		currencyFrame:Hide()
		xpFrame:Show()
		xpFrame:EnableMouse(true)
		xpStatusbar:SetMinMaxValues(0, mxp)
		xpStatusbar:SetValue(xp)
		xpText:SetText("LEVEL "..UnitLevel("player").." "..cfg.CLASS)
		xpFrame:SetSize(xpText:GetStringWidth()+18, 16)
		xpStatusbar:SetSize(xpText:GetStringWidth(),3)
		xpStatusbarBG:SetSize(xpText:GetStringWidth(),3)
	end
end

---------------------------------------------
-- EVENT HANDELING
---------------------------------------------

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("PLAYER_XP_UPDATE")
eventframe:RegisterEvent("PLAYER_LEVEL_UP")
eventframe:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
eventframe:RegisterEvent("CHAT_MSG_CURRENCY")
eventframe:RegisterEvent("TRADE_CURRENCY_CHANGED")
eventframe:RegisterEvent("MODIFIER_STATE_CHANGED")

eventframe:SetScript("OnEvent", function(this, event, arg1, arg2, arg3, arg4, ...)
	--if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_XP_UPDATE" or event == "PLAYER_LEVEL_UP" then
	if UnitLevel("player") ~= MAX_PLAYER_LEVEL and cfg.currency.showXPbar then
		mxp = UnitXPMax("player")
		xp = UnitXP("player")
		updateXP(xp, mxp)
		currencyFrame:Hide()
	else
		xpFrame:Hide()
	end

	if event == "MODIFIER_STATE_CHANGED" then
		if InCombatLockdown() then return end
		if arg1 == "LSHIFT" or arg1 == "RSHIFT" then
			if UnitLevel("player") == MAX_PLAYER_LEVEL or not cfg.currency.showXPbar then return end
			if arg2 == 1 then
				xpFrame:Hide()
				xpFrame:EnableMouse(false)
				currencyFrame:Show()
			elseif arg2 == 0 then
				currencyFrame:Hide()
				xpFrame:EnableMouse(true)
				xpFrame:Show()
			end
		end
	end




	-- reroll currency
	local SoIFname, SoIFamount, _, _, _, SoIFtotalMax, SoIFisDiscovered = GetCurrencyInfo(1129)
	if SoIFamount > 0 then
		rerollText:SetText(SoIFamount)
	else
		local SoTFname, SoTFamount, _, _, _, SoTFtotalMax, SoTFisDiscovered = GetCurrencyInfo(994)
		if SoTFamount > 0 then rerollText:SetText(SoTFamount) end
	end
	rerollFrame:SetSize(rerollText:GetStringWidth()+18, 16)

	-- honor currency
	honorText:SetText(UnitHonor("player"))
	honorFrame:SetSize(honorText:GetStringWidth()+18, 16)

	currencyFrame:SetSize(rerollFrame:GetWidth()+honorFrame:GetWidth()+6,16)

	-- garrison currency
	local grName, grAmount, _, grEarnedThisWeek, grWeeklyMax, grTotalMax, grIsDiscovered = GetCurrencyInfo(824)
	garrisonText:SetText(grAmount)
	garrisonFrame:SetSize(garrisonText:GetStringWidth()+18, 16)

	currencyFrame:SetSize(rerollFrame:GetWidth()+honorFrame:GetWidth()+garrisonFrame:GetWidth()+6,16)
end)
