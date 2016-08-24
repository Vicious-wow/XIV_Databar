local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------
if not cfg.micromenu.show then return end

local chatFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
chatFrame:SetSize(32, 32)
chatFrame:SetPoint("LEFT",52,0)
chatFrame:EnableMouse(true)
chatFrame:RegisterForClicks("AnyUp")
local chatFrameIcon = chatFrame:CreateTexture(nil,"OVERLAY",nil,7)
chatFrameIcon:SetSize(32,32)
chatFrameIcon:SetPoint("CENTER")
chatFrameIcon:SetTexture(cfg.mediaFolder.."microbar\\chat")
chatFrameIcon:SetVertexColor(unpack(cfg.color.normal))
 
chatFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	chatFrameIcon:SetVertexColor(unpack(cfg.color.hover))
end)

chatFrame:SetScript("OnLeave", function() chatFrameIcon:SetVertexColor(unpack(cfg.color.normal)) end)

chatFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ChatMenu:SetScale(cfg.core.scale)
		ChatMenu:ClearAllPoints()
		if not ChatMenu:IsShown() then
		if cfg.core.position == "BOTTOM" then
			ChatMenu:SetPoint("BOTTOMLEFT", chatFrame, "TOPLEFT")
		else
			ChatMenu:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT")
		end
		ChatFrameMenuButton:Click()
		else ChatMenu:Hide() end
	end
end)
	

local guildFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
guildFrame:SetSize(32, 32)
guildFrame:SetPoint("LEFT",chatFrame,36,0)
guildFrame:EnableMouse(true)
guildFrame:RegisterForClicks("AnyUp")

local guildIcon = guildFrame:CreateTexture(nil,"OVERLAY",nil,7)
guildIcon:SetPoint("CENTER")
guildIcon:SetTexture(cfg.mediaFolder.."microbar\\guild")
guildIcon:SetVertexColor(unpack(cfg.color.normal))

local guildText = guildFrame:CreateFontString(nil, "OVERLAY")
guildText:SetFont(cfg.text.font, cfg.text.smallFontSize)
guildText:SetPoint("CENTER", guildFrame, "TOP")
if cfg.core.position ~= "BOTTOM" then
	guildText:SetPoint("CENTER", guildFrame, "BOTTOM")
end

local guildTextBG = guildFrame:CreateTexture(nil,"OVERLAY",nil,7)
guildTextBG:SetPoint("CENTER",guildText)
guildTextBG:SetColorTexture(unpack(cfg.color.barcolor))

guildFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	guildIcon:SetVertexColor(unpack(cfg.color.hover))
	if not cfg.micromenu.showTooltip then return end
if ( IsInGuild() ) then
	GameTooltip:SetOwner(guildFrame, cfg.tooltipPos)
	GameTooltip:AddLine("[|cff6699FFGuild|r]")
	GameTooltip:AddLine(" ")
	--------------------------

	guildList = {}
	guildName, guildRank, _ = GetGuildInfo("player")
	guildMotto = GetGuildRosterMOTD()
		
	GameTooltip:AddDoubleLine("Guild:", guildName, 1, 1, 0, 0, 1, 0)
	for i = 0, select(1, GetNumGuildMembers()) do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR = GetGuildRosterInfo(i)
		if ( online ) then
			if status == 0 then status = "" elseif status == 1 then status = "AFK" elseif status == 2 then status = "DND" end
		local cCol = string.format("%02X%02X%02X", RAID_CLASS_COLORS[classFileName].r*255, RAID_CLASS_COLORS[classFileName].g*255, RAID_CLASS_COLORS[classFileName].b*255)
		local lineL = string.format("%s |cff%s%s|r %s %s", level, cCol, name, status, note)
		local lineR = string.format("%s|cffffffff %s", isMobile and "|cffffff00[M]|r " or "", zone or "")
		GameTooltip:AddDoubleLine(lineL,lineR)
		end
	end
else
	--GameTooltip:AddLine("No Guild")
end
GameTooltip:AddLine(" ")
if ( IsInGuild() ) then GameTooltip:AddDoubleLine("<Left-click>", "Open Guild Page", 1, 1, 0, 1, 1, 1) end
-----------------------
GameTooltip:Show()
end)

guildFrame:SetScript("OnLeave", function() if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end guildIcon:SetVertexColor(unpack(cfg.color.normal)) end)

guildFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then 
		if ( IsInGuild() ) then
			ToggleGuildFrame()
			GuildFrameTab2:Click()
		else
			print"|cff6699FFSXUI|r: You are not in a guild"
		end
	end
end)

local friendFrame = CreateFrame("BUTTON",nil, cfg.SXframe)
friendFrame:SetSize(32, 32)
friendFrame:SetPoint("LEFT",guildFrame,36,0)
friendFrame:EnableMouse(true)
friendFrame:RegisterForClicks("AnyUp")

local friendIcon = friendFrame:CreateTexture(nil,"OVERLAY",nil,7)
friendIcon:SetSize(32,32)
friendIcon:SetPoint("CENTER")
friendIcon:SetTexture(cfg.mediaFolder.."microbar\\social")
friendIcon:SetVertexColor(unpack(cfg.color.normal))

local friendText = guildFrame:CreateFontString(nil, "OVERLAY")
friendText:SetFont(cfg.text.font, cfg.text.smallFontSize)
friendText:SetPoint("CENTER", friendFrame, "TOP")
if cfg.core.position ~= "BOTTOM" then
	friendText:SetPoint("CENTER", friendFrame, "BOTTOM")
end

local friendTextBG = guildFrame:CreateTexture(nil,"OVERLAY",nil,7)
friendTextBG:SetColorTexture(unpack(cfg.color.barcolor))


friendFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	friendIcon:SetVertexColor(unpack(cfg.color.hover))
	if not cfg.micromenu.showTooltip then return end
	local totalBNet, numBNetOnline = BNGetNumFriends()
	if numBNetOnline then
	GameTooltip:SetOwner(friendFrame, cfg.tooltipPos)
	GameTooltip:AddLine("[|cff6699FFSocial|r]")
	GameTooltip:AddLine(" ")
	--------------------------
	local onlineBnetFriends = false
	for j = 1, BNGetNumFriends() do
		local BNid, BNname, battleTag, _, toonname, toonid, client, online, lastonline, isafk, isdnd, broadcast, note = BNGetFriendInfo(j)
		if ( online ) then
			
			if (not battleTag) then battleTag = "[noTag]" end
			local status = ""
			
			local statusIcon = "Interface\\FriendsFrame\\StatusIcon-Online.blp"
			if ( isafk ) then 
				statusIcon = "Interface\\FriendsFrame\\StatusIcon-Away.blp"
				status = "(AFK)"
			end
			if  ( isdnd ) == "D3" then
				statusIcon = "Interface\\FriendsFrame\\StatusIcon-DnD.blp"
				status = "(DND)"
			end
			
			local gameIcon = "Interface\\Icons\\INV_Misc_QuestionMark.blp"
			if client == "App" then 
				gameIcon = "Interface\\FriendsFrame\\Battlenet-Battleneticon.blp"
				client = "Bnet"
			elseif client == "D3" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-D3icon.blp"
				client = "Diablo III"
			elseif client == "Hero" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-HotSicon.blp"
				client = "Hero of the Storm"
			elseif client == "S2" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-Sc2icon.blp"
				client = "Starcraft 2"
			elseif client == "WoW" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-WoWicon.blp"
			elseif client == "WTCG" then
				gameIcon = "Interface\\FriendsFrame\\Battlenet-WTCGicon.blp"
				client = "Heartstone"
			end
			if client == "WoW" then 
				toonname = ("(|cffecd672"..toonname.."|r)")
			else
				toonname = "" 
			end
			
			if not note then
			note = ""
			else
			note = ("(|cffecd672"..note.."|r)")
			end
			
			local lineL = string.format("|T%s:16|t|cff82c5ff %s|r %s",statusIcon, BNname, note)
			local lineR = string.format("%s %s |T%s:16|t",toonname, client or "",  gameIcon)
			GameTooltip:AddDoubleLine(lineL,lineR)
			onlineBnetFriends = true
		end
	end
	
if onlineBnetFriends then GameTooltip:AddLine(" ") end

local onlineFriends = false
	for i = 1, GetNumFriends() do
		local name, lvl, class, area, online, status, note = GetFriendInfo(i)
		if ( online ) then
			local status = ""
			local statusIcon = "Interface\\FriendsFrame\\StatusIcon-Online.blp"
			if ( isafk ) then 
				statusIcon = "Interface\\FriendsFrame\\StatusIcon-Away.blp"
				status = "(AFK)"
			end
			if  ( isdnd ) == "D3" then
				statusIcon = "Interface\\FriendsFrame\\StatusIcon-DnD.blp"
				status = "(DND)"
			end
			local lineL = string.format("|T%s:16|t %s, lvl:%s %s", statusIcon, name, lvl, class)
			local lineR = string.format("%s", area or "")
			GameTooltip:AddDoubleLine(lineL,lineR)
			onlineFriends = true
		end
	end
if onlineFriends then GameTooltip:AddLine(" ") end
GameTooltip:AddDoubleLine("<Left-click>", "Open Friends List", 1, 1, 0, 1, 1, 1)
-----------------------
GameTooltip:Show()
end
end)

friendFrame:SetScript("OnLeave", function() if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end friendIcon:SetVertexColor(unpack(cfg.color.normal)) end)

friendFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		ToggleFriendsFrame()
	end
end)

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")

eventframe:RegisterEvent("FRIENDLIST_UPDATE")
eventframe:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
eventframe:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")

eventframe:RegisterEvent("GUILD_ROSTER_UPDATE")
eventframe:RegisterEvent("GUILD_TRADESKILL_UPDATE")
eventframe:RegisterEvent("GUILD_MOTD")
eventframe:RegisterEvent("GUILD_NEWS_UPDATE")
eventframe:RegisterEvent("PLAYER_GUILD_UPDATE")

eventframe:SetScript("OnEvent", function(self,event, ...)
	local numOnline = ""
	if IsInGuild() then
		_, numOnline, _ = GetNumGuildMembers()
	end
	guildText:SetText(numOnline)
	guildTextBG:SetSize(guildText:GetWidth()+4,guildText:GetHeight()+2)
	guildTextBG:SetPoint("CENTER",guildText)
	
	local totalBNet, numBNetOnline = BNGetNumFriends()
	friendText:SetText(numBNetOnline)
	
	if numBNetOnline == 0 then
		friendText:SetText("")
	else
		
	end
	friendTextBG:SetSize(friendText:GetWidth()+4,friendText:GetHeight()+2)
	friendTextBG:SetPoint("CENTER",friendText)
	
end)