local addOnName, XB = ...;

local Social = XB:RegisterModule("Social")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT
local social_config
local Bar,BarFrame
local groupFrame,chatFrame,chatFrameIcon,guildFrame,guildIcon,guildText,guildTextBG,socialFrame,socialIcon,socialText,socialTextBG

local MOBILE_ONLINE_ICON = "Interface\\ChatFrame\\UI-ChatIcon-ArmoryChat";
local MOBILE_BUSY_ICON = "Interface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile";
local MOBILE_AWAY_ICON = "Interface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile";

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function chatClick(self, button)
	if InCombatLockdown() and not Social.settings.chat.combatEn then return end
	if button == "LeftButton" then
		if Social.settings.chat.anchorBar then
			ChatMenu:ClearAllPoints()
			if Bar.settings.anchor:find("BOTTOM") then
				ChatMenu:SetPoint("BOTTOMLEFT", chatFrame, "TOPLEFT")
			elseif Bar.settings.anchor:find("TOP") then
				ChatMenu:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT")
			else
				if Bar.settings.y > 0 then
					ChatMenu:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT")
				elseif Bar.settings.y <= 0 then
					ChatMenu:SetPoint("BOTTOMLEFT", chatFrame, "TOPLEFT")
				else
					--Should not end up here
					XB:Print("Please open an issue concerning the chat module")
				end
			end
		else
			ChatFrameMenu_UpdateAnchorPoint()
		end

		if ChatMenu:IsVisible() then
			ChatMenu:Hide()
		else
			ChatFrame_OpenMenu()
		end
	end
end

local function splitLongLine(text,maxLetters)
	maxLetters = maxLetters or 250
	local result = {}
	repeat
		local lettersNow = maxLetters
		local utf8pos = 1
		local textLen = string.len(text)

		while true do
			local char = text:sub(utf8pos,utf8pos)
			local c = char:byte()
			local lastPos = utf8pos

			if c > 0 and c <= 127 then
				utf8pos = utf8pos + 1
			elseif c >= 194 and c <= 223 then
				utf8pos = utf8pos + 2
			elseif c >= 224 and c <= 239 then
				utf8pos = utf8pos + 3
			elseif c >= 240 and c <= 244 then
				utf8pos = utf8pos + 4
			else
				utf8pos = utf8pos + 1
			end

				lettersNow = lettersNow - 1

			if lettersNow == 0 then
				break
			elseif utf8pos >= textLen then
				break
			end
		end
		result[#result + 1] = string.sub(text,1,utf8pos-1)
		text = string.sub(text,utf8pos)
	until string.len(text) < maxLetters
	if string.len(text) > 0 then
		result[#result + 1] = text
	end
	return result
end

local function getStatusIcon(online,isMobile,status)
	if online then
		if status == 0 then
			return FRIENDS_TEXTURE_ONLINE
		elseif status == 1 then
			return FRIENDS_TEXTURE_AFK
		elseif status == 2 then
			return FRIENDS_TEXTURE_DND
		end
	elseif isMobile then
		if status == 1 then
			return MOBILE_AWAY_ICON
		elseif status == 2 then
			return MOBILE_BUSY_ICON
		else
			return MOBILE_ONLINE_ICON
		end
	else
		return FRIENDS_TEXTURE_OFFLINE
	end
end

local function getGuildyInfo(opt,guildPlayer)
	--1st column displays status, level and name
	local col1 = (opt.status and guildPlayer.status or "")..(opt.level and guildPlayer.level or "")
	col1 = col1 == "" and col1..(opt.name and guildPlayer.name or "") or col1.." "..(opt.name and guildPlayer.name or "")
	--3rd column displays the note / officer note if any
	local col3
	if opt.note and guildPlayer.note[1] ~= "" then
		col3 = " "..guildPlayer.note[1]
	elseif guildPlayer.note[1] == "" then
		col3 = ""
	end
	if opt.officerNote and guildPlayer.note[2] ~= "" then
		col3 = col3 == "" and " "..guildPlayer.note[2] or col3.." / "..guildPlayer.note[2]
	end
	--4th column displays the rank(rankindex)
	local col4
	if opt.rank then
		col4 = " "..guildPlayer.rank[2]
	elseif opt.rankIndex then
		col4 = ""
	end
	if opt.rankIndex then
		col4 = col4 == "" and " "..guildPlayer.rank[1] or col4.." ("..guildPlayer.rank[1]..")"
	end
	--5th column displays achievements (#rank)
	local col5
	if opt.achievementPoints then
		col5 = " "..guildPlayer.achievement[1]
	elseif opt.achievementRank then
		col5 = ""
	end
	if opt.achievementRank then
		col5 = col5 == "" and " "..guildPlayer.achievement[2] or col5.." (#"..guildPlayer.achievement[2]..")"
	end

	return col1,col3,col4,col5
end

local function guildTooltip()
	if libTT:IsAcquired("GuildTooltip") then
		libTT:Release(libTT:Acquire("GuildTooltip"))
	end

	if ( IsInGuild() ) then
		GuildRoster()
		local guildName, guildRank, _ = GetGuildInfo("player")
		local guildMotto = GetGuildRosterMOTD()
		local numOnline = select(3,GetNumGuildMembers())
		local opt = Social.settings.guild.tooltipOpt

		local tooltip = libTT:Acquire("GuildTooltip", 1)
		tooltip:SmartAnchorTo(guildFrame)
		tooltip:SetAutoHideDelay(.5, guildFrame)
		tooltip:SetCellMarginH(0)
		tooltip:EnableMouse(true)

		tooltip:AddLine("[|cff6699FF"..guildName.."|r]")
		-- Add columns for further info
		if opt.zone then
			tooltip:AddColumn()
		end
		if opt.note or opt.officerNote then
			tooltip:AddColumn()
		end
		if opt.rank or opt.rankIndex then
			tooltip:AddColumn()
		end
		if opt.achievementPoints or achievementRank then
			tooltip:AddColumn()
		end
		if opt.reputation then
			tooltip:AddColumn()
		end

		-- Taking care of the GMOTD
		if guildMotto ~= "" and opt.gmotd then
			tooltip:AddLine(" ")
			local nbCol = tooltip:GetColumnCount()
			local splitMotto = splitLongLine(guildMotto,opt.splitThresh)

			if #splitMotto > nbCol then
				for i=1,#splitMotto,nbCol do
					local partMotto,k={},0
					for j=i,i+nbCol do
						partMotto[k+1] = splitMotto[j]
						k = k+1
					end
					tooltip:AddLine(unpack(partMotto))
					tooltip:SetLineTextColor(tooltip:GetLineCount(),0,1,0)
				end
			else
				tooltip:AddLine(unpack(splitMotto))
				tooltip:SetLineTextColor(tooltip:GetLineCount(),0,1,0)
			end
		end

		-- Guildies list
		if numOnline > 0 then
			tooltip:AddLine(" ")
			guildTooltipSelect = nil
			for i = 1, select(1, GetNumGuildMembers()) do
				local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, guildRep = GetGuildRosterInfo(i)

				if online or isMobile then
					local statusIcon = getStatusIcon(online,isMobile,status)
					local formatedStatusIcon,formatedName,formatedRep = statusIcon == MOBILE_ONLINE_ICON and "|T"..statusIcon..":16:16:0:0:16:16:0:16:0:16:73:177:73|t" or "|T"..statusIcon..":16|t",WrapTextInColorCode(name,select(4,GetClassColor(class:gsub(" ",""):upper()))),getglobal("FACTION_STANDING_LABEL"..guildRep)
					local formatedLevel = tostring(level):len() == 3 and tostring(level) or (tostring(level):len() == 2 and " "..level or "  "..level)

					local guildPlayer = {
						status = formatedStatusIcon,
						name = formatedName,
						rank = {rankIndex,rank},
						level = formatedLevel,
						note = {note,officernote},
						achievement = {achievementPoints,achievementRank},
						zone = zone,
						reputation = formatedRep
					}
					local col1,col3,col4,col5 = getGuildyInfo(opt,guildPlayer)

					tooltip:AddLine(col1,opt.zone and guildPlayer.zone or nil,col3,col4, col5, opt.reputation and guildPlayer.reputation or nil)
					tooltip:SetLineScript(tooltip:GetLineCount(),"OnEnter",function() end)
					tooltip:SetLineScript(tooltip:GetLineCount(),"OnLeave",function() end)
					tooltip:SetLineScript(tooltip:GetLineCount(),"OnMouseUp",function(self,_,button)
						--Whisp func
						local modifierW = opt.whispMod == 1 or (opt.whispMod == 2 and IsShiftKeyDown or (opt.whispMod == 3 and IsAltKeyDown or IsControlKeyDown))
						local clickW = opt.whispClick == 1 and "LeftButton" or "RightButton"
						if type(modifierW)=="function" then
							if modifierW() and button == clickW then
								ChatFrame_OpenChat(SLASH_SMART_WHISPER1.." "..name.." "); return
							end
						else
							if not IsModifierKeyDown() and button == clickW then
								ChatFrame_OpenChat(SLASH_SMART_WHISPER1.." "..name.." "); return
							end
						end
						--Invite func
						local modifierI = opt.invMod == 1 or (opt.invMod == 2 and IsShiftKeyDown or (opt.invMod == 3 and IsAltKeyDown or IsControlKeyDown))
						local clickI = opt.invClick == 1 and "LeftButton" or "RightButton"
						if type(modifierI)=="function" then
							if modifierI() and button == clickI then
								InviteUnit(name); return
							end
						else
							if not IsModifierKeyDown() and button == clickI then
								InviteUnit(name); return
							end
						end
					end)
				end
			end
			tooltip:AddLine(" ")
			tooltip:AddLine("|cffffff00<"..(opt.whispMod==1 and XB.mouseButtons[opt.whispClick] or XB.modifiers[opt.whispMod].."+"..XB.mouseButtons[opt.whispClick])..">|r |cffffffffWhisper Character|r")
			tooltip:AddLine("|cffffff00<"..(opt.invMod==1 and XB.mouseButtons[opt.invClick] or XB.modifiers[opt.invMod].."+"..XB.mouseButtons[opt.invClick])..">|r |cffffffff"..CALENDAR_INVITELIST_INVITETORAID.."|r")
			XB:SkinTooltip(tooltip,"GuildTooltip")
			tooltip:Show()
		end
	else
		local tooltip = libTT:Acquire("GuildTooltip",1)
		tooltip:SmartAnchorTo(guildFrame)
		tooltip:SetAutoHideDelay(.3, guildFrame)
		tooltip:AddLine("[|cff6699FFNo Guild|r]")
		XB:SkinTooltip(tooltip,"GuildTooltip")
		tooltip:Show()
	end
end

local function ClassColourCode(class,table)
	local initialClass = class
    for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
        if class == v then
            class = k
            break
        end
    end
	if class == initialClass then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
			if class == v then
				class = k
				break
			end
		end
	end
	if table then
		return RAID_CLASS_COLORS[class]
	else
		return string.format("|c%s", RAID_CLASS_COLORS[class].colorStr)
	end
end

local function socialTooltip()
	--TODO: better rendering of the tooltip content + add zone and level to BTag toon
	if libTT:IsAcquired("SocialTooltip") then
		libTT:Release(libTT:Acquire("SocialTooltip"))
	end

	local tooltip = libTT:Acquire("SocialTooltip", 1)
	tooltip:SmartAnchorTo(socialFrame)
	tooltip:SetAutoHideDelay(.5, socialFrame)
	tooltip:SetCellMarginH(0)
	tooltip:EnableMouse(true)
	
	tooltip:AddLine("[|cff6699FFSocial|r]")
	tooltip:AddLine(" ")
	--------------------------
	local onlineBnetFriends = false
	for j = 1, BNGetNumFriends() do
		local BNid, BNname, battleTag, _, toonname, toonid, client, online, lastonline, isafk, isdnd, broadcast, note = BNGetFriendInfo(j)
		toonname = BNet_GetValidatedCharacterName(toonname,battleTag,client)
		local class = toonid and select(8, BNGetGameAccountInfo(toonid)) or ""
		--groupe par jeu
		
		if ( online ) then
			battleTag = battleTag or "[noBTag]"
			
			local statusIcon
			if isafk then 
				statusIcon = getStatusIcon(true,false,1)
			elseif isdnd then
				statusIcon = getStatusIcon(true,false,2)
			else
				statusIcon = getStatusIcon(true,false,0)
			end
			
			local gameIcon = "Interface\\Icons\\INV_Misc_QuestionMark.blp"
			if client == BNET_CLIENT_APP then 
				gameIcon = XB.gameIcons.app
			elseif client == BNET_CLIENT_D3 then
				gameIcon = XB.gameIcons.d3
			elseif client == BNET_CLIENT_HEROES then
				gameIcon = XB.gameIcons.hots
			elseif client == BNET_CLIENT_S2 then
				gameIcon = XB.gameIcons.sc2
			elseif client == BNET_CLIENT_WOW then
				gameIcon = XB.gameIcons.wow
			elseif client == BNET_CLIENT_WTCG then
				gameIcon = XB.gameIcons.hs
			elseif client == BNET_CLIENT_OVERWATCH then
				gameIcon = XB.gameIcons.overwatch
			end
			--[[ if client == "WoW" then 
				toonname = ("(|cffecd672"..toonname.."|r)")
			else
				toonname = "" 
			end ]]
			
			if not note or note == "" then
				note = ""
			else
				note = ("(|cffecd672"..note.."|r)")
			end
			
			local lineL = string.format("|T%s:16|t|T%s:16|t|cff82c5ff %s|r %s",statusIcon,gameIcon, BNname, note)
			local lineR = class ~= "" and (CanCooperateWithGameAccount(toonid) and ClassColourCode(class)..toonname.."|r" or FRIENDS_OTHER_NAME_COLOR_CODE..toonname.."|r") or ""
			tooltip:AddLine(lineL.." "..lineR)
			tooltip:SetLineScript(tooltip:GetLineCount(),"OnEnter",function() end)
			tooltip:SetLineScript(tooltip:GetLineCount(),"OnLeave",function() end)
			onlineBnetFriends = true
		end
	end
	
	if onlineBnetFriends then tooltip:AddLine(" ") end

	local onlineFriends = false
		for i = 1, GetNumFriends() do
			local name, lvl, class, area, online, status, note = GetFriendInfo(i)
			if ( online ) then
				local statusIcon
				if status == CHAT_FLAG_AFK then 
					statusIcon = getStatusIcon(true,false,1)
				elseif status == CHAT_FLAG_DND then
					statusIcon = getStatusIcon(true,false,2)
				else
					statusIcon = getStatusIcon(true,false,0)
				end
				local classColor = select(4,GetClassColor(class:gsub(" ",""):upper()))
				local lineL = string.format("|T%s:16|t %s %s", statusIcon, WrapTextInColorCode(name,classColor), WrapTextInColorCode(string.format(FRIENDS_LEVEL_TEMPLATE, lvl, class),classColor))
				local lineR = string.format("%s", area or "")
				tooltip:AddLine(lineL.." "..lineR)
				tooltip:SetLineScript(tooltip:GetLineCount(),"OnEnter",function() end)
				tooltip:SetLineScript(tooltip:GetLineCount(),"OnLeave",function() end)
				onlineFriends = true
			end
		end
	if onlineFriends then tooltip:AddLine(" ") end
	tooltip:AddLine("<Left-click> Open Friends List")
	-----------------------
	tooltip:Show()
end

local function refreshOptions()
	Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()

	local opt = social_config.general.args
	opt.posX.min = -round(BarFrame:GetWidth())
	opt.posX.max = round(BarFrame:GetWidth())
	opt.posY.min = -round(BarFrame:GetHeight())
	opt.posY.max = round(BarFrame:GetHeight())
	opt.width.max = round(BarFrame:GetWidth())
	opt.height.max = round(BarFrame:GetHeight())

	opt = social_config.chat.args.general.args
	opt.posX.min = -Social.settings.w + Social.settings.chat.w
	opt.posX.max = Social.settings.w - Social.settings.chat.w
	opt.posY.min = -Social.settings.h + Social.settings.chat.h
	opt.posY.max = Social.settings.h - Social.settings.chat.h
	opt.width.max = Social.settings.w
	opt.height.max = Social.settings.h

	social_config.guild.args.posX.min = -Social.settings.w + Social.settings.guild.w
	social_config.guild.args.posX.max = Social.settings.w - Social.settings.guild.w
	social_config.guild.args.posY.min = -Social.settings.h + Social.settings.guild.h
	social_config.guild.args.posY.max = Social.settings.h - Social.settings.guild.h
	social_config.guild.args.width.max = Social.settings.w
	social_config.guild.args.height.max = Social.settings.h
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local social_default = {
	profile = {
		enable = true,
		lock = true,
		x = 52,
		y = 0,
		w = 104,
		h = 32,
		anchor = "LEFT",
		combatEn = false,
		tooltip = false,
		color = {1,1,1,.75},
		colorCC = false,
		hover = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
		hoverCC = not (XB.playerClass == "PRIEST"),
		chat = {
			enable = true,
			x = 0,
			y = 0,
			w = 32,
			h = 32,
			anchor = "LEFT",
			combatEn = false,
			color = {1,1,1,.75},
			colorCC = false,
			hover = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
			hoverCC = not (XB.playerClass == "PRIEST"),
			anchorBar = true
		},
		guild = {
			enable = true,
			x = 36,
			y = 0,
			w = 32,
			h = 32,
			anchor = "LEFT",
			combatEn = false,
			tooltip = true,
			color = {1,1,1,.75},
			colorCC = false,
			hover = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
			hoverCC = not (XB.playerClass == "PRIEST"),
			tooltipOpt = {
				gmotd = false,
				guildName = false,
				status = true,
				level = true,
				name = true,
				note = true,
				officerNote = false,
				zone = true,
				rank = false,
				rankIndex = false,
				achievementPoints = false,
				achievementRank = false,
				reputation = false,
				splitThresh = 40,
				whispMod = 1,
				whispClick = 1,
				invMod = 2,
				invClick = 1
			}
		},
		social = {
			enable = true,
			x = 72,
			y = 0,
			w = 32,
			h = 32,
			anchor = "LEFT",
			combatEn = false,
			tooltip = true,
			color = {1,1,1,.75},
			colorCC = false,
			hover = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
			hoverCC = not (XB.playerClass == "PRIEST"),
		}
	}
}

social_config = {
	title = {
		type = "description",
		name = "|cff64b4ffSocial module",
		fontSize = "large",
		order = 0
	},
	desc = {
		type = "description",
		name = "Options for the social module",
		fontSize = "medium",
		order = 1
	},
	general = {
		name = "General",
		type = "group",
		order = 1,
		args = {
			enable = {
				name = "Enable",
				type = "toggle",
				desc = "Enable the social module",
				get = function() return Social.settings.enable end,
				set = function(_,val) Social.settings.enable = val; Social:Update() end,
				order = 1
			},
			lock = {
				name = "Unlock",
				type = "toggle",
				desc = "(Un)locks the frame in order to position it by moving it with your mouse",
				get = function() return Social.settings.lock end,
				set = function(_,val) Social.settings.lock = val; Social:Update("group") end,
				order = 2
			},
			posX = {
				name = "X position",
				type = "range",
				min = 0,
				max = 1,
				step = 1,
				get = function() return Social.settings.x end,
				set = function(_,val) Social.settings.x = val; Social:Update("group") end,
				order = 3
			},
			posY = {
				name = "Y position",
				type = "range",
				min = 0,
				max = 1,
				step = 1,
				get = function() return Social.settings.y end,
				set = function(_,val) Social.settings.y = val; Social:Update("group") end,
				order = 4
			},
			width = {
				name = "Width",
				type = "range",
				min = 1,
				max = 2,
				step = 1,
				get = function() return Social.settings.w end,
				set = function(_,val) Social.settings.w = val; Social:Update("group") end,
				order = 5
			},
			height = {
				name = "Height",
				type = "range",
				min = 1,
				max = 2,
				step = 1,
				get = function() return Social.settings.h end,
				set = function(_,val) Social.settings.h = val; Social:Update("group") end,
				order = 6
			},
			anchor = {
				name = "Anchor",
				type = "select",
				width = "double",
				values = XB.validAnchors,
				get = function() return Social.settings.anchor end,
				set = function(_,val) Social.settings.anchor = val; Social:Update("group") end,
				order = 7
			},
			colors = {
				name = "|cff64b4ffColors",
				type = "group",
				inline = true,
				args = {
					descColors = {
						name = "The following color options set up the color for all the module icons",
						type = "description",
						fontSize = "medium",
						order = 1
					},
					color = {
						name = "Icon Color",
						type = "color",
						hasAlpha = true,
						get = function() return unpack(Social.settings.color) end,
						set = function(_,r,g,b,a)
							if not Social.settings.colorCC then
								Social.settings.color = {r,g,b,a};
							else
								local cr,cg,cb = GetClassColor(XB.playerClass)
								Social.settings.color = {cr,cg,cb,a}
							end
						end,
						order = 2
					},
					colorCC = {
						name = "Class color ",
						type = "toggle",
						desc = "Only the alpha can be set with the color picker",
						get = function() return Social.settings.colorCC end,
						set = function(_,val)
							Social.settings.colorCC = val
							if val then
								local r,g,b = GetClassColor(XB.playerClass);
								Social.settings.color = {r,g,b,Social.settings.color[4]}
							end
						end,
						order = 3
					},
					hover = {
						name = "Hover color",
						type = "color",
						hasAlpha = true,
						get = function() return unpack(Social.settings.hover) end,
						set = function(_,r,g,b,a)
							if not Social.settings.hoverCC then
								Social.settings.hover = {r,g,b,a};
							else
								local cr,cg,cb = GetClassColor(XB.playerClass)
								Social.settings.hover = {cr,cg,cb,a}
							end
						end,
						order = 4
					},
					hoverCC  = {
						name = "Class color",
						type = "toggle",
						desc = "Only the alpha can be set with the color picker",
						get = function() return Social.settings.hoverCC end,
						set = function(_,val)
							Social.settings.hoverCC = val
							if val then
								local r,g,b = GetClassColor(XB.playerClass);
								Social.settings.hover = {r,g,b,Social.settings.hover[4]}
							end
						end,
						order = 5
					}
				}
			}
		}
	},
	chat = {
		name = "Chat Button",
		type = "group",
		order = 2,
		childGroups = "tab",
		args = {
			general = {
				name = "General",
				type = "group",
				order = 1,
				args = {
					enable = {
						name = "Enable",
						type = "toggle",
						get = function() return Social.settings.chat.enable end,
						set = function(_,val) Social.settings.chat.enable = val; Social:Update("chat") end,
						order = 1
					},
					anchorFrame ={
						name = "Anchor",
						type = "select",
						values = XB.validAnchors,
						get = function() return Social.settings.chat.anchor end,
						set = function(_,val) Social.settings.chat.anchor = val; Social:Update("chat") end,
						order = 2
					},
					posX = {
						name = "X position",
						type = "range",
						min = 0,
						max = 1,
						step = 1,
						get = function() return Social.settings.chat.x end,
						set = function(_,val) Social.settings.chat.x = val; Social:Update("chat") end,
						order = 3
					},
					posY = {
						name = "Y position",
						type = "range",
						min = 0,
						max = 1,
						step = 1,
						get = function() return Social.settings.chat.y end,
						set = function(_,val) Social.settings.chat.y = val; Social:Update("chat") end,
						order = 4
					},
					width = {
						name = "Width",
						type = "range",
						min = 1,
						max = 2,
						step = 1,
						get = function() return Social.settings.chat.w end,
						set = function(_,val) Social.settings.chat.w = val; Social:Update("chat") end,
						order = 5
					},
					height = {
						name = "Height",
						type = "range",
						min = 1,
						max = 2,
						step = 1,
						get = function() return Social.settings.chat.h end,
						set = function(_,val) Social.settings.chat.h = val; Social:Update("chat") end,
						order = 6
					}
				}
			},
			colors = {
				name = "Icon color",
				type = "group",
				order = 2,
				args = {
					color = {
						name = "Icon Color",
						type = "color",
						hasAlpha = true,
						get = function() return unpack(Social.settings.chat.color) end,
						set = function(_,r,g,b,a)
							if not Social.settings.chat.colorCC then
								Social.settings.chat.color = {r,g,b,a};
							else
								local cr,cg,cb = GetClassColor(XB.playerClass)
								Social.settings.chat.color = {cr,cg,cb,a}
							end
							Social:Update("chat")
						end,
						order = 7
					},
					colorCC = {
						name = "Class color ",
						type = "toggle",
						desc = "Only the alpha can be set with the color picker",
						get = function() return Social.settings.chat.colorCC end,
						set = function(_,val)
							Social.settings.chat.colorCC = val
							if val then
								local r,g,b = GetClassColor(XB.playerClass);
								Social.settings.chat.color = {r,g,b,Social.settings.chat.color[4]}
							end
							Social:Update("chat")
						end,
						order = 8
					},
					hover = {
						name = "Hover color",
						type = "color",
						hasAlpha = true,
						get = function() return unpack(Social.settings.chat.hover) end,
						set = function(_,r,g,b,a)
							if not Social.settings.chat.hoverCC then
								Social.settings.chat.hover = {r,g,b,a};
							else
								local cr,cg,cb = GetClassColor(XB.playerClass)
								Social.settings.chat.hover = {cr,cg,cb,a}
							end
							Social:Update("chat")
						end,
						order = 9
					},
					hoverCC = {
						name = "Class color",
						type = "toggle",
						desc = "Only the alpha can be set with the color picker",
						get = function() return Social.settings.chat.hoverCC end,
						set = function(_,val)
							Social.settings.chat.hoverCC = val
							if val then
								local r,g,b = GetClassColor(XB.playerClass);
								Social.settings.chat.hover = {r,g,b,Social.settings.chat.hover[4]}
							end
							Social:Update("chat")
						end,
						order = 10
					}
				}
			},
			miscellaneous = {
				name = "Miscellaneous",
				type = "group",
				order = 3,
				args = {
					combatEn = {
						name = "Enable in combat",
						type = "toggle",
						desc = "Enable hovering and actions during combat",
						get = function() return Social.settings.chat.combatEn end,
						set = function(_,val) Social.settings.chat.combatEn = val; end,
						order = 1
					},
					moveChatFrame = {
						name = "Anchor to the bar",
						type = "toggle",
						desc = "Moves the chat dopdown menu to the bar",
						get = function() return Social.settings.chat.anchorBar end,
						set = function(_,val) Social.settings.chat.anchorBar = val; end,
						order = 2
					}
				}
			}
		}
	},
	guild = {
		name = "Guild Button",
		type = "group",
		order = 3,
		args = {
			enable = {
				name = "Enable",
				type = "toggle",
				get = function() return Social.settings.guild.enable end,
				set = function(_,val) Social.settings.guild.enable = val; Social:Update("guild") end,
				order = 1
			},
			anchorFrame ={
				name = "Anchor",
				type = "select",
				values = XB.validAnchors,
				get = function() return Social.settings.guild.anchor end,
				set = function(_,val) Social.settings.guild.anchor = val; Social:Update("guild") end,
				order = 2
			},
			posX = {
				name = "X position",
				type = "range",
				min = 0,
				max = 1,
				step = 1,
				get = function() return Social.settings.guild.x end,
				set = function(_,val) Social.settings.guild.x = val; Social:Update("guild") end,
				order = 3
			},
			posY = {
				name = "Y position",
				type = "range",
				min = 0,
				max = 1,
				step = 1,
				get = function() return Social.settings.guild.y end,
				set = function(_,val) Social.settings.guild.y = val; Social:Update("guild") end,
				order = 4
			},
			width = {
				name = "Width",
				type = "range",
				min = 1,
				max = 2,
				step = 1,
				get = function() return Social.settings.guild.w end,
				set = function(_,val) Social.settings.guild.w = val; Social:Update("guild") end,
				order = 5
			},
			height = {
				name = "Height",
				type = "range",
				min = 1,
				max = 2,
				step = 1,
				get = function() return Social.settings.guild.h end,
				set = function(_,val) Social.settings.guild.h = val; Social:Update("guild") end,
				order = 6
			},
			color = {
				name = "Icon Color",
				type = "color",
				hasAlpha = true,
				get = function() return unpack(Social.settings.guild.color) end,
				set = function(_,r,g,b,a)
					if not Social.settings.guild.colorCC then
						Social.settings.guild.color = {r,g,b,a};
					else
						local cr,cg,cb = GetClassColor(XB.playerClass)
						Social.settings.guild.color = {cr,cg,cb,a}
					end
					Social:Update("guild")
				end,
				order = 7
			},
			colorCC = {
				name = "Class color ",
				type = "toggle",
				desc = "Only the alpha can be set with the color picker",
				get = function() return Social.settings.guild.colorCC end,
				set = function(_,val)
					Social.settings.guild.colorCC = val
					if val then
						local r,g,b = GetClassColor(XB.playerClass);
						Social.settings.guild.color = {r,g,b,Social.settings.guild.color[4]}
					end
					Social:Update("guild")
				end,
				order = 8
			},
			hover = {
				name = "Hover color",
				type = "color",
				hasAlpha = true,
				get = function() return unpack(Social.settings.guild.hover) end,
				set = function(_,r,g,b,a)
					if not Social.settings.guild.hoverCC then
						Social.settings.guild.hover = {r,g,b,a};
					else
						local cr,cg,cb = GetClassColor(XB.playerClass)
						Social.settings.guild.hover = {cr,cg,cb,a}
					end
					Social:Update("guild")
				end,
				order = 9
			},
			hoverCC = {
				name = "Class color",
				type = "toggle",
				desc = "Only the alpha can be set with the color picker",
				get = function() return Social.settings.guild.hoverCC end,
				set = function(_,val)
					Social.settings.guild.hoverCC = val
					if val then
						local r,g,b = GetClassColor(XB.playerClass);
						Social.settings.guild.hover = {r,g,b,Social.settings.guild.hover[4]}
					end
					Social:Update("guild")
				end,
				order = 10
			},
			combatEn = {
				name = "Enable in combat",
				type = "toggle",
				desc = "Enable hovering and actions during combat",
				get = function() return Social.settings.guild.combatEn end,
				set = function(_,val) Social.settings.guild.combatEn = val; Social:Update("guild") end,
				order = 11
			},
			tooltip = {
				name = "Enable tooltip",
				type = "toggle",
				get = function() return Social.settings.guild.tooltip end,
				set = function(_,val) Social.settings.guild.tooltip = val; end,
				order = 12
			},
			tooltipManagement = {
				name = "Tooltip options",
				type = "group",
				args = {
					title = {
						name = "|cff64b4ffElements to display",
						fontSize = "large",
						type = "description",
						order = 1
					},
					GMOTD = {
						name = "Show GMOTD",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.gmotd end,
						set = function(_,val) Social.settings.guild.tooltipOpt.gmotd = val end,
						order = 2
					},
					status = {
						name = "Show status",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.status end,
						set = function(_,val) Social.settings.guild.tooltipOpt.status = val end,
						order = 3
					},
					level = {
						name = "Show level",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.level end,
						set = function(_,val) Social.settings.guild.tooltipOpt.level = val end,
						order = 4
					},
					name = {
						name = "Show name",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.name end,
						set = function(_,val) Social.settings.guild.tooltipOpt.name = val end,
						order = 5
					},
					area = {
						name = "Show zone",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.zone end,
						set = function(_,val) Social.settings.guild.tooltipOpt.zone = val end,
						order = 6
					},
					note = {
						name = "Show note",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.note end,
						set = function(_,val) Social.settings.guild.tooltipOpt.note = val end,
						order = 7
					},
					officerNote = {
						name = "Show officer note",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.officerNote end,
						set = function(_,val) Social.settings.guild.tooltipOpt.officerNote = val end,
						order = 8
					},
					rank = {
						name = "Show rank",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.rank end,
						set = function(_,val) Social.settings.guild.tooltipOpt.rank = val end,
						order = 9
					},
					rankIndex = {
						name = "Show rank number",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.rankIndex end,
						set = function(_,val) Social.settings.guild.tooltipOpt.rankIndex = val end,
						order = 10
					},
					achievementPoints = {
						name = "Show achievement points",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.achievementPoints end,
						set = function(_,val) Social.settings.guild.tooltipOpt.achievementPoints = val end,
						order = 11
					},
					achievementRank = {
						name = "Show achievement rank",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.achievementRank end,
						set = function(_,val) Social.settings.guild.tooltipOpt.achievementRank = val end,
						order = 12
					},
					reputation = {
						name = "Show guild reputation",
						type = "toggle",
						get = function() return Social.settings.guild.tooltipOpt.reputation end,
						set = function(_,val) Social.settings.guild.tooltipOpt.reputation = val end,
						order = 13
					},
					GMOTDSplit = {
						name = "GMOTD Split",
						desc = "Number of caracter to display in one column of the tooltip",
						type = "range",
						min = 1,
						max = 255,
						get = function() return Social.settings.guild.tooltipOpt.splitThresh end,
						set = function(_,val) Social.settings.guild.tooltipOpt.splitThresh = val end,
						order = 14
					},
					whisp = {
						name = "Whisper click option",
						type = "group",
						args = {
							modifier = {
								name = "Modifier",
								type = "select",
								values = XB.modifiers,
								get = function() return Social.settings.guild.tooltipOpt.whispMod end,
								set = function(_,val) Social.settings.guild.tooltipOpt.whispMod = val end
							},
							click = {
								name = "Button Click",
								type = "select",
								values = XB.mouseButtons,
								get = function() return Social.settings.guild.tooltipOpt.whispClick end,
								set = function(_,val) Social.settings.guild.tooltipOpt.whispClick = val end
							}
						}
					},
					invite = {
						name = "Invite click option",
						type = "group",
						args = {
							modifier = {
								name = "Modifier",
								type = "select",
								values = XB.modifiers,
								get = function() return Social.settings.guild.tooltipOpt.invMod end,
								set = function(_,val) Social.settings.guild.tooltipOpt.invMod = val end
							},
							click = {
								name = "Button Click",
								type = "select",
								values = XB.mouseButtons,
								get = function() return Social.settings.guild.tooltipOpt.invClick end,
								set = function(_,val) Social.settings.guild.tooltipOpt.invClick = val end
							}
						}
					}
				}
			}
		}
	},
	--[[social = {
		name = "Social Button",
		type = "group",
		args = {
			enable = {
			},
			posX = {
			},
			posY = {
			},
			width = {
			},
			height = {
			},
			combatEn = {
			},
			tooltip = {
			},
			color = {
			},
			colorCC = {
			},
			hover = {
			},
			hoverCC {
			},
			tooltipManagement = {
				hideBNetApp = {
				},
				showOnlyWoW = {
				},
				--BNid, BNname, battleTag, _, toonname, toonid, client, online, lastonline, isafk, isdnd, broadcast, note
			}
		}
	} ]]
}

----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Social:OnInitialize()
	libTT = LibStub('LibQTip-1.0')
	self.db = XB.db:RegisterNamespace("Social", social_default)
    self.settings = self.db.profile
end

function Social:OnEnable()
	Social.settings.lock = Social.settings.lock or not Social.settings.lock --Locking frame if it was not locked on reload/relog
	refreshOptions()
	XB.Config:Register("Social",social_config)
	
	if self.settings.enable and not self:IsEnabled() then
		self:Enable()
	elseif not self.settings.enable and self:IsEnabled() then
		self:Disable()
	else
		self:CreateFrames()
	end
end

function Social:OnDisable()
	if groupFrame then
		groupFrame:Hide()
	end
end

function Social:Update(frameName)
	refreshOptions()
	XB.Config:Register("Social",social_config)
	
	if self.settings.enable and not self:IsEnabled() then
		self:Enable()
	elseif not self.settings.enable and self:IsEnabled() then
		self:Disable()
	else
		if frameName == "group" then
			self:CreateGroupFrame()
		elseif frameName == "chat" then
			self:CreateChatFrame()
		elseif frameName == "guild" then
			self:CreateGuildFrame()
		elseif frameName == "social" then
			self:CreateSocialFrame()
		else
			XB:Print("Uhm it's embarassing")
		end
	end
end

function Social:CreateFrames()
	self:CreateGroupFrame()
	self:CreateChatFrame()
	self:CreateGuildFrame()
	self:CreateSocialFrame()
end

function Social:CreateGroupFrame()
	if not self.settings.enable then
		if groupFrame and groupFrame:IsVisible() then
			groupFrame:Hide()
		end
		return
	end

	local x,y,w,h,a = Social.settings.x,Social.settings.y,Social.settings.w,Social.settings.h,Social.settings.anchor
	groupFrame = groupFrame or CreateFrame("Frame","SocialGroup",BarFrame)
	groupFrame:SetSize(w, h)
	groupFrame:SetPoint(a,x,y)
	groupFrame:SetMovable(true)
	groupFrame:SetClampedToScreen(true)
	groupFrame:Show()
	XB:AddOverlay(self,groupFrame,a)
	
	if not Social.settings.lock then
		groupFrame.overlay:Show()
		groupFrame.overlay.anchor:Show()
	else
		groupFrame.overlay:Hide()
		groupFrame.overlay.anchor:Hide()
	end
end

function Social:CreateChatFrame()
	if not self.settings.chat.enable then
		if chatFrame and chatFrame:IsVisible() then
			chatFrame:Hide()
		end
		return
	end
	
	local w,h,x,y,a,color,hover = self.settings.chat.w,self.settings.chat.h,self.settings.chat.x,self.settings.chat.y,self.settings.chat.anchor,self.settings.chat.color,self.settings.chat.hover
	
	chatFrame = chatFrame or CreateFrame("BUTTON","ChatButton",groupFrame)
	chatFrame:SetSize(w, h)
	chatFrame:SetPoint(a,x,y)
	chatFrame:EnableMouse(true)
	chatFrame:RegisterForClicks("AnyUp")
	chatFrame:Show()
	
	chatFrameIcon = chatFrameIcon or chatFrame:CreateTexture(nil,"OVERLAY",nil,7)
	chatFrameIcon:SetSize(w,h)
	chatFrameIcon:SetPoint("CENTER")
	chatFrameIcon:SetTexture(XB.menuIcons.chat)
	chatFrameIcon:SetVertexColor(unpack(color))
	 
	chatFrame:SetScript("OnEnter", function()
		if InCombatLockdown() and not self.settings.chat.combatEn then return end
		chatFrameIcon:SetVertexColor(unpack(hover))
	end)

	chatFrame:SetScript("OnLeave", function() chatFrameIcon:SetVertexColor(unpack(color)) end)

	chatFrame:SetScript("OnClick", chatClick)
end

function Social:CreateGuildFrame()
	if not self.settings.guild.enable then
		if guildFrame and guildFrame:IsVisible() then
			guildFrame:Hide()
		end
		return
	end

	local x,y,a,w,h,color,hover = self.settings.guild.x,self.settings.guild.y,self.settings.guild.anchor,self.settings.guild.w,self.settings.guild.h,self.settings.guild.color,self.settings.guild.hover

	guildFrame = guildFrame or CreateFrame("BUTTON","GuildButton", groupFrame)
	guildFrame:SetSize(w,h)
	guildFrame:SetPoint(a,x,y)

	guildFrame:EnableMouse(true)
	guildFrame:RegisterForClicks("AnyUp")
	if not guildFrame:IsEventRegistered("GUILD_ROSTER_UPDATE") then
		guildFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
		guildFrame:RegisterEvent("GUILD_MOTD")
		guildFrame:RegisterEvent("GUILD_NEWS_UPDATE")
		--guildFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
		--guildFrame:RegisterEvent("CHAT_MSG_GUILD")
	end

	guildIcon = guildIcon or guildFrame:CreateTexture(nil,"OVERLAY",nil,7)
	guildIcon:SetSize(w,h)
	guildIcon:SetPoint("CENTER")
	guildIcon:SetTexture(XB.menuIcons.guild)
	guildIcon:SetVertexColor(unpack(color))

	if IsInGuild() then
		guildText = guildText or guildFrame:CreateFontString(nil, "OVERLAY")
		guildText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf", 11) --Small fontSize
		guildText:SetPoint("CENTER", guildFrame, "TOP")
		if Bar.settings.anchor:find("TOP") then
			guildText:SetPoint("CENTER", guildFrame, "BOTTOM")
		end

		guildTextBG = guildTextBG or guildFrame:CreateTexture(nil,"OVERLAY",nil,7)
		guildTextBG:SetPoint("CENTER",guildText)
		guildTextBG:SetColorTexture(unpack(Bar.settings.color))

		local numOnline = select(3,GetNumGuildMembers())
		guildText:SetText(numOnline)
		guildTextBG:SetSize(guildText:GetWidth()+4,guildText:GetHeight()+2)
	end

	guildFrame:SetScript("OnEvent", function()
		GuildRoster()
		self:CreateGuildFrame()
	end)

	guildFrame:SetScript("OnEnter", function()
		if InCombatLockdown() and not self.settings.guild.combatEn then return end

		
		guildIcon:SetVertexColor(unpack(self.settings.guild.hover))
		
		if libTT:IsAcquired("SocialTooltip") then
			libTT:Release(libTT:Acquire("SocialTooltip"))
		end
		
		if not self.settings.guild.tooltip then return end
		guildTooltip()
	end)

	guildFrame:SetScript("OnLeave", function()
		guildIcon:SetVertexColor(unpack(self.settings.guild.color))
	end)

	guildFrame:SetScript("OnClick", function(self, button)
		if InCombatLockdown() and not Social.settings.guild.combatEn then return end

		if button == "LeftButton" then 
			if ( IsInGuild() ) then
				ToggleGuildFrame()
				GuildFrameTab2:Click()
			else
				ToggleGuildFrame()
			end
		end
	end)
end

function Social:CreateSocialFrame()





	if not self.settings.social.enable then
		if guildFrame and guildFrame:IsVisible() then
			guildFrame:Hide()
		end
		return
	end






	local x,y,a,w,h,color,hover = self.settings.social.x,self.settings.social.y,self.settings.social.anchor,self.settings.social.w,self.settings.social.h,self.settings.social.color,self.settings.social.hover

	socialFrame = socialFrame or CreateFrame("BUTTON",nil, groupFrame)
	socialFrame:SetSize(w, h)
	socialFrame:SetPoint(a,x,y)
	socialFrame:EnableMouse(true)
	socialFrame:RegisterForClicks("AnyUp")

	socialIcon = socialIcon or socialFrame:CreateTexture(nil,"OVERLAY",nil,7)
	socialIcon:SetSize(w,h)
	socialIcon:SetPoint("CENTER")
	socialIcon:SetTexture(XB.menuIcons.social)
	socialIcon:SetVertexColor(unpack(color))

	socialText = socialText or socialFrame:CreateFontString(nil, "OVERLAY")

	socialText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf", 11)
	socialText:SetPoint("CENTER", socialFrame, "TOP")

	if Bar.settings.anchor:find("TOP") then
		socialText:SetPoint("CENTER", friendFrame, "BOTTOM")
	end

	socialTextBG = socialTextBG or socialFrame:CreateTexture(nil,"OVERLAY",nil,7)
	socialTextBG:SetColorTexture(unpack(Bar.settings.color))


	socialFrame:SetScript("OnEnter", function()
		if InCombatLockdown() and not Social.settings.social.combatEn then return end































































		socialIcon:SetVertexColor(unpack(hover))
		

		if libTT:IsAcquired("GuildTooltip") then
			libTT:Release(libTT:Acquire("GuildTooltip"))
		end














		if not self.settings.social.tooltip then return end





		local totalBNet, numBNetOnline = BNGetNumFriends()
		if numBNetOnline then
			socialTooltip()
		end





	end)

	socialFrame:SetScript("OnLeave", function() socialIcon:SetVertexColor(unpack(color)) end)

	socialFrame:SetScript("OnClick", function(_, button)
		if InCombatLockdown() and not Social.settings.social.combatEn then return end
		if button == "LeftButton" then
			ToggleFriendsFrame()
		end
	end)
end

function Social:GetFrame()
end