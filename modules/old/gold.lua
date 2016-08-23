local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------
if not cfg.gold.show then return end

local onHover = false

local function goldConverter(money)
	local g, s, c = abs(money/10000), abs(mod(money/100, 100)), abs(mod(money, 100))
	local cash
	if ( g < 1 ) then g = "" else g = string.format("|cffffffff%d|cffffd700g|r ", g) end
	if ( s < 1 ) then s = "" else s = string.format("|cffffffff%d|cffc7c7cfs|r ", s) end
	if ( c == 0 ) then c = "" else c = string.format("|cffffffff%d|cffeda55fc|r", c) end
	cash = string.format("%s%s%s", g, s, c)
	if money == 0 then cash = "|cffffffff0" end
	return cash
end

local playerName, playerFaction, playerRealm = UnitName("player"), UnitFactionGroup("player"), GetRealmName()

local positiveSign = "|cff00ff00+ "
local negativeSign = "|cffff0000- "

local goldFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
goldFrame:SetPoint("RIGHT",-270,0)
goldFrame:SetSize(16, 16)
goldFrame:EnableMouse(true)
goldFrame:RegisterForClicks("AnyUp")

 local function goldFrameOnEnter()
	if not cfg.gold.showTooltip then return end
	if not onHover then return end
	GameTooltip:SetOwner(goldFrame, cfg.tooltipPos)
	GameTooltip:AddLine("[|cff6699FFGold|r]")
	GameTooltip:AddLine(" ")
	---------------------------------------------------

	local gold = GetMoney()
	local logDate = ns.playerData.lastLoginDate

	local sessionGold = ns.playerData["money_on_session_start"]
	local sessionGoldIcon = ""
	sessionGold = sessionGold - gold

	if sessionGold < 0 then
		sessionGoldIcon = positiveSign
	elseif sessionGold > 0 then
		sessionGoldIcon = negativeSign
	else
	end

	local dayGold = ns.playerData["money_on_first_login_today"]
	local dayGoldIcon = ""
	dayGold = dayGold - gold

	if dayGold < 0 then
		dayGoldIcon = positiveSign
	elseif dayGold > 0 then
		dayGoldIcon = negativeSign
	else
	end


	local weekGold = ns.playerData["money_on_first_weekday"]
	local weekGoldIcon = ""
	weekGold = weekGold - gold

	if weekGold < 0 then
		weekGoldIcon = positiveSign
	elseif weekGold > 0 then
		weekGoldIcon = negativeSign
	else
	end


	local totalGold = 0
	for key, val in pairs(ns.realmData[playerFaction]) do
		for k, v in pairs(val) do
			if k == "money_on_log_out" then
				totalGold = totalGold + v
			end
		end
	end

	local realmDailyGold = 0
	for key, val in pairs(ns.realmData[playerFaction]) do
		for k, v in pairs(val) do
			if k == "money_on_first_login_today" then
				realmDailyGold = realmDailyGold + v
			end
		end
	end

	local realmDayGoldIcon = ""
	realmDailyGold = realmDailyGold - totalGold

	if realmDailyGold < 0 then
		realmDayGoldIcon = positiveSign
	elseif realmDailyGold > 0 then
		realmDayGoldIcon = negativeSign
	else
	end


	local realmWeeklyGold = 0
	for key, val in pairs(ns.realmData[playerFaction]) do
		for k, v in pairs(val) do
			if k == "money_on_first_weekday" then
				realmWeeklyGold = realmWeeklyGold + v
			end
		end
	end

	local realmWeekGoldIcon = ""
	realmWeeklyGold = realmWeeklyGold - totalGold

	if realmWeeklyGold < 0 then
		realmWeekGoldIcon = positiveSign
	elseif realmWeeklyGold > 0 then
		realmWeekGoldIcon = negativeSign
	else
	end

	GameTooltip:AddDoubleLine(playerName.."|r's Gold",format(goldConverter(gold)))
	GameTooltip:AddLine(" ")

	if IsShiftKeyDown() then
		GameTooltip:AddDoubleLine("Realm Daily Balance",realmDayGoldIcon..format(goldConverter(realmDailyGold)))
		GameTooltip:AddDoubleLine("Realm Weekly Balance",realmWeekGoldIcon..format(goldConverter(realmWeeklyGold)))
		GameTooltip:AddLine(" ")
	for key, val in pairs(ns.realmData[playerFaction]) do
		for k, v in pairs(val) do
			if k == "money_on_log_out" then
				GameTooltip:AddDoubleLine(key,format(goldConverter(v)))
			end
		end
	end

	else
		GameTooltip:AddDoubleLine("Session Balance",sessionGoldIcon..format(goldConverter(sessionGold)))
		GameTooltip:AddDoubleLine("Daily Balance",dayGoldIcon..format(goldConverter(dayGold)))
		GameTooltip:AddDoubleLine("Weekly Balance",weekGoldIcon..format(goldConverter(weekGold)))

	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Realm Gold","|cffffffff"..format(goldConverter(totalGold)))
	if not IsShiftKeyDown() then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("<Shift-hold>", "Show the |cffffff00"..playerRealm.." - "..playerFaction.."|r gold", 1, 1, 0, 1, 1, 1)
	end
	GameTooltip:Show()
 end

 local function freeSpaceBags()
	local freeSlots = 0
	for i=0, 4,1 do
		freeSlots = freeSlots+select(1,GetContainerNumFreeSlots(i))
	end
	return freeSlots
end

local goldIcon = goldFrame:CreateTexture(nil,"OVERLAY",nil,7)
goldIcon:SetPoint("LEFT",goldFrame,17,0)
goldIcon:SetTexture(cfg.mediaFolder.."datatexts\\gold")
goldIcon:SetVertexColor(unpack(cfg.color.normal))

local goldText = goldFrame:CreateFontString(nil, "OVERLAY")
goldText:SetFont(cfg.text.font, cfg.text.normalFontSize)
goldText:SetPoint("LEFT", goldIcon,15,0)
goldText:SetTextColor(unpack(cfg.color.normal))

local spaceText = goldFrame:CreateFontString(nil,"OVERLAY")
spaceText:SetPoint("LEFT", goldIcon,-17,0)
spaceText:SetFont(cfg.text.font, cfg.text.normalFontSize)

goldFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	goldIcon:SetVertexColor(unpack(cfg.color.hover))
	onHover = true
	goldFrameOnEnter()
end)

goldFrame:SetScript("OnLeave", function() if ( GameTooltip:IsShown() ) then GameTooltip:Hide() onHover = false end goldIcon:SetVertexColor(unpack(cfg.color.normal)) end)

goldFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		OpenAllBags()
	elseif button == "RightButton" then
		CloseAllBags()
	end
end)

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("PLAYER_MONEY")
eventframe:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
eventframe:RegisterEvent("SEND_MAIL_COD_CHANGED")
eventframe:RegisterEvent("PLAYER_TRADE_MONEY")
eventframe:RegisterEvent("TRADE_MONEY_CHANGED")
eventframe:RegisterEvent("TRADE_CLOSED")
eventframe:RegisterEvent("MODIFIER_STATE_CHANGED")
eventframe:RegisterEvent("BAG_UPDATE")

eventframe:SetScript("OnEvent", function(this, event, arg1, arg2, arg3, arg4, ...)

	goldFrameOnEnter()
	if event == "MODIFIER_STATE_CHANGED" then
		if InCombatLockdown() then return end
		if arg1 == "LSHIFT" or arg1 == "RSHIFT" then
			if arg2 == 1 then
				goldFrameOnEnter()
			elseif arg2 == 0 then
				goldFrameOnEnter()
			end
		end
	end

	if event=="BAG_UPDATE" and cfg.gold.showFreeBagSpace then
		spaceText:SetText("("..freeSpaceBags()..")")
	end


	local gold = GetMoney()

	ns.playerData["money_on_log_out"] = gold

	local g, s, c = abs(gold/10000), abs(mod(gold/100, 100)), abs(mod(gold, 100))

	if g > 1 then
		goldText:SetText(floor(g).."g")
	elseif s > 1 then
		goldText:SetText(floor(s).."s")
	else
		goldText:SetText(floor(c).."c")
	end
	if gold == 0 then goldText:SetText("0") end


	goldFrame:SetSize(goldText:GetStringWidth()+18, 16)
end)
