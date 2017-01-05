local addOnName, XB = ...;

local Social = XB:RegisterModule("Social")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT
local social_config
local Bar,BarFrame
local groupFrame,chatFrame,chatFrameIcon,guildFrame,guildIcon,socialFrame

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function refreshOptions()
	Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
	social_config.posX.min = -round(BarFrame:GetWidth())
	social_config.posX.max = round(BarFrame:GetWidth())
	social_config.posY.min = -round(BarFrame:GetHeight())
	social_config.posY.max = round(BarFrame:GetHeight())
	social_config.width.max = round(BarFrame:GetWidth())
	social_config.height.max = round(BarFrame:GetHeight())
	
	social_config.chat.args.posX.min = -Social.settings.w + Social.settings.chat.w
	social_config.chat.args.posX.max = Social.settings.w - Social.settings.chat.w
	social_config.chat.args.posY.min = -Social.settings.h + Social.settings.chat.h
	social_config.chat.args.posY.max = Social.settings.h - Social.settings.chat.h
	social_config.chat.args.width.max = Social.settings.w
	social_config.chat.args.height.max = Social.settings.h
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
		order = 8
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
		order = 9
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
		order = 10
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
		order = 11
	},
	chat = {
		name = "Chat Button",
		type = "group",
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
				set = function(_,val) Social.settings.chat.h = val; end,
				order = 6
			},
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
				end,
				order = 10
			},
			miscellaneous = {
				name = "Miscellaneous",
				type = "group",
				inline = true,
				args = {
					combatEn = {
						name = "Hover in combat",
						type = "toggle",
						desc = "Enable hovering actions during combat",
						get = function() return Social.settings.chat.combatEn end,
						set = function(_,val) Social.settings.chat.combatEn = val; end,
						order = 1
					},
					moveChatFrame = {
						name = "Anchor to the bar",
						type = "toggle",
						desc = "Moves the chat dopdown menu to the bar",
						order = 2
					}
				}
			}
		}
	},
	--[[ guild = {
		name = "Guild Button",
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
				GMOTD = {
				},
				guildName = {
				},
				status = {
				},
				name = {
				},
				level = {
				},
				class = {
				},
				area = {
				},
				note = {
				},
				officerNote = {
				},
				rank = {
				},
				achivementPoints = {
				},
				achievementRank = {
				},
				mobile = {
				}
			}
		}
	},
	social = {
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
		end
	end
end

function Social:CreateFrames()
	self:CreateGroupFrame()
	self:CreateChatFrame()
	--self:CreateGuildFrame()
	--self:CreateSocialFrame()
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
	
	chatFrame = chatFrame or CreateFrame("BUTTON","ChatButton",groupFrame)
	chatFrame:SetSize(self.settings.chat.w, self.settings.chat.h)
	chatFrame:SetPoint(self.settings.chat.anchor,self.settings.chat.x,self.settings.chat.y)
	chatFrame:EnableMouse(true)
	chatFrame:RegisterForClicks("AnyUp")
	chatFrame:Show()
	
	chatFrameIcon = chatFrameIcon or chatFrame:CreateTexture(nil,"OVERLAY",nil,7)
	chatFrameIcon:SetSize(self.settings.chat.w,self.settings.chat.h)
	chatFrameIcon:SetPoint("CENTER")
	chatFrameIcon:SetTexture(XB.menuIcons.chat)
	chatFrameIcon:SetVertexColor(unpack(self.settings.chat.color))
	 
	chatFrame:SetScript("OnEnter", function()
		if InCombatLockdown() and not self.settings.chat.combatEn then return end
		chatFrameIcon:SetVertexColor(unpack(self.settings.chat.hover))
	end)

	chatFrame:SetScript("OnLeave", function() chatFrameIcon:SetVertexColor(unpack(self.settings.chat.color)) end)

	chatFrame:SetScript("OnClick", function(self, button, down)
		if InCombatLockdown() and not self.settings.chat.combatEn then return end
		if button == "LeftButton" then
			-- ChatMenu:ClearAllPoints() // BOTTOM ChatMenu:SetPoint("BOTTOMLEFT", chatFrame, "TOPLEFT") // TOP ChatMenu:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT")
			if ChatMenu:IsVisible() then
				ChatMenu:Hide()
			else
				ChatFrame_OpenMenu()
			end
		end
	end)
end

function Social:CreateGuildFrame()
	guildFrame = guildFrame or CreateFrame("BUTTON","GuildButton", groupFrame)
	guildFrame:SetSize(self.settings.guild.w, self.settings.guild.h)
	guildFrame:SetPoint(self.settings.guild.anchor,self.settings.guild.x,self.settings.guild.y)
	guildFrame:EnableMouse(true)
	guildFrame:RegisterForClicks("AnyUp")

	guildIcon = guildIcon or guildFrame:CreateTexture(nil,"OVERLAY",nil,7)
	guildIcon:SetPoint("CENTER")
	guildIcon:SetTexture(XB.menuIcons.guild)
	guildIcon:SetVertexColor(unpack(self.settings.guild.color))

	local guildText = guildText or guildFrame:CreateFontString(nil, "OVERLAY")
	guildText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf", 11) --Small fontSize
	guildText:SetPoint("CENTER", guildFrame, "TOP")
	if Bar.settings.anchor:find("TOP") then
		guildText:SetPoint("CENTER", guildFrame, "BOTTOM")
	end

	local guildTextBG = guildTextBG or guildFrame:CreateTexture(nil,"OVERLAY",nil,7)
	guildTextBG:SetPoint("CENTER",guildText)
	guildTextBG:SetColorTexture(unpack(Bar.settings.color))
	-- Temp
	guildText:SetText("0")
	guildTextBG:SetSize(guildText:GetWidth()+4,guildText:GetHeight()+2)

	guildFrame:SetScript("OnEnter", function()
		if InCombatLockdown() then return end
		guildIcon:SetVertexColor(unpack(self.settings.guild.hover))
		if not true then return end --Show tooltip opt
		if libTT:IsAcquired("GuildTooltip") then
			libTT:Release(libTT:Acquire("GuildTooltip"))
		end
		local tooltip = libTT:Acquire("GuildTooltip", 11)
		if ( IsInGuild() ) then
			tooltip:SmartAnchorTo(guildFrame)
			tooltip:AddLine("[|cff6699FF"..ACHIEVEMENTS_GUILD_TAB.."|r]")
			tooltip:AddLine(" ")
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
			tooltip:AddLine("No Guild")
		end
		tooltip:AddLine(" ")
		if ( IsInGuild() ) then tooltip:AddLine("|cffffff00<"..XB.mouseButtons[1]..">|r", "|cffffffffOpen Guild Page|r") end
		-----------------------
		tooltip:Show()
	end)

	guildFrame:SetScript("OnLeave", function() if libTT:IsAcquired("GuildTooltip") then print("release");libTT:Release(libTT:Acquire("GuildTooltip")) end guildIcon:SetVertexColor(unpack(self.settings.guild.color)) end)

	guildFrame:SetScript("OnClick", function(self, button, down)
		if InCombatLockdown() then return end
		if button == "LeftButton" then 
			if ( IsInGuild() ) then
				ToggleGuildFrame()
				GuildFrameTab2:Click()
			else
				XB:Print(ERR_GUILD_PLAYER_NOT_IN_GUILD)
			end
		end
	end)
end

function Social:CreateSocialFrame()
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
end

function Social:GetFrame()
end