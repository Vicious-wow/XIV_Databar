local addOnName, XB = ...;

local Mb = XB:RegisterModule("MenuButton")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local gameMenuFrame, gameMenuIcon
local libTT
local Bar,BarFrame
local mb_config

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function tooltip()
	if libTT:IsAcquired("GameMenuTip") then
		libTT:Release(libTT:Acquire("GameMenuTip"))
	end
	local tooltip = libTT:Acquire("GameMenuTip", 1, "LEFT")
	tooltip:SmartAnchorTo(gameMenuFrame)
	tooltip:AddHeader('[|cff6699FF'..MAINMENU_BUTTON..'|r]')
	tooltip:AddLine(' ',' ')
	tooltip:AddLine('|cffffff00<'..(Mb.settings.modMenu==1 and XB.mouseButtons[Mb.settings.clickMenu] or XB.modifiers[Mb.settings.modMenu].."+"..XB.mouseButtons[Mb.settings.clickMenu])..'> |cffffffff'..'Opens '..MAINMENU_BUTTON..'|r')
	tooltip:AddLine('|cffffff00<'..(Mb.settings.modReload==1 and XB.mouseButtons[Mb.settings.clickReload] or XB.modifiers[Mb.settings.modReload].."+"..XB.mouseButtons[Mb.settings.clickReload])..'> |cffffffff'..'Reloads the UI'..'|r')
	tooltip:AddLine('|cffffff00<'..(Mb.settings.modOpts==1 and XB.mouseButtons[Mb.settings.clickOpts] or XB.modifiers[Mb.settings.modOpts].."+"..XB.mouseButtons[Mb.settings.clickOpts])..'> |cffffffff'..'Opens the option panel'..'|r')
	tooltip:AddLine('|cffffff00<'..(Mb.settings.modAddonL==1 and XB.mouseButtons[Mb.settings.clickAddonL] or XB.modifiers[Mb.settings.modAddonL].."+"..XB.mouseButtons[Mb.settings.clickAddonL])..'> |cffffffff'..'Opens '..ADDON_LIST..'|r')
	XB:SkinTooltip(tooltip,"GameMenuTip")
	tooltip:Show()
end

local function refreshOptions()
	Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
	mb_config.general.args.posX.min = -round(BarFrame:GetWidth())
	mb_config.general.args.posX.max = round(BarFrame:GetWidth())
	mb_config.general.args.posY.min = -round(BarFrame:GetHeight())
	mb_config.general.args.posY.max = round(BarFrame:GetHeight())
	mb_config.general.args.width.max = round(BarFrame:GetWidth())
	mb_config.general.args.height.max = round(BarFrame:GetHeight())
end

local function clickFunctions(self,button,down)
	if InCombatLockdown() and not Mb.settings.combatEn then return end

	-- ReloadUI function
	local modifierR = Mb.settings.modReload == 1 or (Mb.settings.modReload == 2 and IsShiftKeyDown or (Mb.settings.modReload == 3 and IsAltKeyDown or IsControlKeyDown))
	local clickR = Mb.settings.clickReload == 1 and "LeftButton" or "RightButton"
	if type(modifierR)=="function" then
		if modifierR() and button == clickR then
			ChatFrame_OpenChat("/reload"); return -- For now 7.2 does not allow ReloadUI() func call
		end
	else
		if not IsModifierKeyDown() and button == clickR then
			ChatFrame_OpenChat("/reload"); return
		end
	end

	-- GameMenu function
	local modifierM = Mb.settings.modMenu == 1 or (Mb.settings.modMenu == 2 and IsShiftKeyDown or (Mb.settings.modMenu == 3 and IsAltKeyDown or IsControlKeyDown))
	local clickM = Mb.settings.clickMenu == 1 and "LeftButton" or "RightButton"
	if type(modifierM)=="function" then
		if modifierM() and button == clickM then
			ToggleFrame(GameMenuFrame); return
		end
	else
		if not IsModifierKeyDown() and button == clickM then
			ToggleFrame(GameMenuFrame); return
		end
	end

	-- AddonList function
	local modifierA = Mb.settings.modAddonL == 1 and XB.modifiers[Mb.settings.modAddonL] or (Mb.settings.modAddonL == 2 and IsShiftKeyDown or (Mb.settings.modAddonL == 3 and IsAltKeyDown or IsControlKeyDown))
	local clickA = Mb.settings.clickAddonL == 1 and "LeftButton" or "RightButton"
	if type(modifierA)=="function" then
		if modifierA() and button == clickA then
			ToggleFrame(AddonList); return
		end
	else
		if not IsModifierKeyDown() and button == clickA then
			ToggleFrame(AddonList); return
		end
	end

	-- Options function
	local modifierO = Mb.settings.modOpts == 1 or (Mb.settings.modOpts == 2 and IsShiftKeyDown or (Mb.settings.modOpts == 3 and IsAltKeyDown or IsControlKeyDown))
	local clickO = Mb.settings.clickOpts == 1 and "LeftButton" or "RightButton" --ToggleConfig()
	if type(modifierO)=="function" then
		if modifierO() and button == clickO then
			ToggleConfig()
		end
	else
		if not IsModifierKeyDown() and button == clickO then
			ToggleConfig()
		end
	end
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local mb_default = {
	profile = {
		enable = true,
		lock = true,
		x = 2,
		y = 0,
		w = 32,
		h = 32,
		anchor = "LEFT",
		combatEn = false,
		tooltip = false,
		color = {1,1,1,.75},
		colorCC = false,
		hover = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
		hoverCC = not (XB.playerClass == "PRIEST"),
		modMenu = 1,
		clickMenu = 1,
		modReload = 2,
		clickReload = 2,
		modOpts = 3,
		clickOpts = 2,
		modAddonL = 1,
		clickAddonL = 2
	}
}

mb_config = {
	title = {
		type = "description",
		name = "|cff64b4ffGame menu module",
		fontSize = "large",
		order = 0
	},
	desc = {
		type = "description",
		name = "Options for the game menu module",
		fontSize = "medium",
		order = 1
	},
	general = {
		name = "General",
		type = "group",
		args = {
			enable = {
				name = "Enable",
				type = "toggle",
				desc = "Enable the Game Menu Button",
				get = function() return Mb.settings.enable end,
				set = function(_,val) Mb.settings.enable = val; Mb:Update() end,
				order = 1
			},
			lock = {
				name = "Unlock",
				type = "toggle",
				desc = "(Un)locks the frame in order to position it by moving it with your mouse",
				get = function() return Mb.settings.lock end,
				set = function(_,val) Mb.settings.lock = val; Mb:Update() end,
				order = 2
			},
			posX = {
				name = "X position",
				type = "range",
				min = 0,
				max = 1,
				step = 1,
				get = function() return Mb.settings.x end,
				set = function(_,val) Mb.settings.x = val; Mb:Update() end,
				order = 3
			},
			posY = {
				name = "Y position",
				type = "range",
				min = 0,
				max = 1,
				step = 1,
				get = function() return Mb.settings.y end,
				set = function(_,val) Mb.settings.y = val; Mb:Update() end,
				order = 4
			},
			width = {
				name = "Width",
				type = "range",
				min = 1,
				max = 2,
				step = 1,
				get = function() return Mb.settings.w end,
				set = function(_,val) Mb.settings.w = val; Mb:Update() end,
				order = 5
			},
			height = {
				name = "Height",
				type = "range",
				min = 1,
				max = 2,
				step = 1,
				get = function() return Mb.settings.h end,
				set = function(_,val) Mb.settings.h = val; Mb:Update() end,
				order = 6
			},
			anchor = {
				name = "Anchor",
				type = "select",
				values = XB.validAnchors,
				get = function() return Mb.settings.anchor end,
				set = function(_,val) Mb.settings.anchor = val; Mb:Update() end,
				order = 7
			}
		}
	},
	color = {
		name = "Icon Color",
		type = "group",
		args = {
			normal = {
				name = "Icon Color",
				type = "color",
				hasAlpha = true,
				get = function() return unpack(Mb.settings.color) end,
				set = function(_,r,g,b,a)
					if not Mb.settings.colorCC then
                        Mb.settings.color = {r,g,b,a};
                    else
                        local cr,cg,cb = GetClassColor(XB.playerClass)
                        Mb.settings.color = {cr,cg,cb,a}
                    end
					Mb:Update()
				end,
				order = 1
			},
			normalCC = {
				name = "Class color ",
				type = "toggle",
				desc = "Only the alpha can be set with the color picker",
				get = function() return Mb.settings.colorCC end,
				set = function(_,val)
					Mb.settings.colorCC = val
					if val then
                        local r,g,b = GetClassColor(XB.playerClass);
                        Mb.settings.color = {r,g,b,Mb.settings.color[4]}
                    end
					Mb:Update()
				end,
				order = 2
			},
			hover = {
				name = "Hover color",
				type = "color",
				hasAlpha = true,
				get = function() return unpack(Mb.settings.hover) end,
				set = function(_,r,g,b,a)
					if not Mb.settings.hoverCC then
                        Mb.settings.hover = {r,g,b,a};
                    else
                        local cr,cg,cb = GetClassColor(XB.playerClass)
                        Mb.settings.hover = {cr,cg,cb,a}
                    end
					Mb:Update()
				end,
				order = 3
			},
			hoverCC = {
				name = "Class color",
				type = "toggle",
				desc = "Only the alpha can be set with the color picker",
				get = function() return Mb.settings.hoverCC end,
				set = function(_,val)
					Mb.settings.hoverCC = val
					if val then
                        local r,g,b = GetClassColor(XB.playerClass);
                        Mb.settings.hover = {r,g,b,Mb.settings.hover[4]}
                    end
					Mb:Update()
				end,
				order = 4
			},
		}
	},
	misc = {
		name = "Miscellaneous",
		type = "group",
		args = {
			inCombatEnable = {
				name = "Enable in combat",
				type = "toggle",
				desc = "Enable hovering and actions during combat",
				get = function() return Mb.settings.combatEn end,
				set = function(_,val) Mb.settings.combatEn = val; Mb:Update() end,
				order = 1
			},
			showTooltip = {
				name = "Show tooltip",
				type = "toggle",
				desc = "Enable descriptive tooltip",
				get = function() return Mb.settings.tooltip end,
				set = function(_,val) Mb.settings.tooltip = val; Mb:Update() end,
				order = 2
			},
			functionsDesc = {
				name = "|cff64b4ffClick functions",
				type = "description",
				fontSize = "large",
				order = 3
			},
			gameMenu = {
				name = MAINMENU_BUTTON,
				type = "group",
				order = 4,
				args = {
					modifier = {
						name = "Modifier",
						type = "select",
						values = XB.modifiers,
						get = function() return Mb.settings.modMenu end,
						set = function(_,val) Mb.settings.modMenu = val; Mb:Update() end
					},
					click = {
						name = "Button Click",
						type = "select",
						values = XB.mouseButtons,
						get = function() return Mb.settings.clickMenu end,
						set = function(_,val) Mb.settings.clickMenu = val; Mb:Update() end
					}
				}
			},
			reload = {
				name = "Reload UI",
				type = "group",
				order = 5,
				args = {
					modifier = {
						name = "Modifier",
						type = "select",
						values = XB.modifiers,
						get = function() return Mb.settings.modReload end,
						set = function(_,val) Mb.settings.modReload = val; Mb:Update() end
					},
					click = {
						name = "Button Click",
						type = "select",
						values = XB.mouseButtons,
						get = function() return Mb.settings.clickReload end,
						set = function(_,val) Mb.settings.clickReload = val; Mb:Update() end
					}
				}
			},
			options = {
				name = "Options panel",
				type = "group",
				order = 6,
				args = {
					modifier = {
						name = "Modifier",
						type = "select",
						values = XB.modifiers,
						get = function() return Mb.settings.modOpts end,
						set = function(_,val) Mb.settings.modOpts = val; Mb:Update() end
					},
					click = {
						name = "Button Click",
						type = "select",
						values = XB.mouseButtons,
						get = function() return Mb.settings.clickOpts end,
						set = function(_,val) Mb.settings.clickOpts = val; Mb:Update() end
					}
				}
			},
			addonsL = {
				name = ADDON_LIST,
				type = "group",
				order = 7,
				args = {
					modifier = {
						name = "Modifier",
						type = "select",
						values = XB.modifiers,
						get = function() return Mb.settings.modAddonL end,
						set = function(_,val) Mb.settings.modAddonL = val; Mb:Update() end
					},
					click = {
						name = "Button Click",
						type = "select",
						values = XB.mouseButtons,
						get = function() return Mb.settings.clickAddonL end,
						set = function(_,val) Mb.settings.clickAddonL = val; Mb:Update() end
					}
				}
			}
		}
	}
}

----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Mb:OnInitialize()
	libTT = LibStub('LibQTip-1.0')
	self.db = XB.db:RegisterNamespace("MenuButton", mb_default)
    self.settings = self.db.profile
end

function Mb:OnEnable()
	Mb.settings.lock = Mb.settings.lock or not Mb.settings.lock --Locking frame if it was not locked on reload/relog
	refreshOptions()
	XB.Config:Register("Game menu",mb_config)
	if self.settings.enable then
		self:CreateButton()
	else
		self:Disable()
	end
end

function Mb:OnDisable()
	if gameMenuFrame then
		gameMenuFrame:Hide()
	end
end

function Mb:Update()
	refreshOptions()
	XB.Config:Register("MenuButton",mb_config)

	if self.settings.enable and not self:IsEnabled() then
		self:Enable()
	elseif not self.settings.enable and self:IsEnabled() then
		self:Disable()
	else
		self:CreateButton()
	end
end

function Mb:CreateButton()
	if not self.settings.enable then
		if gameMenuFrame and gameMenuFrame:IsVisible() then
			gameMenuFrame:Hide()
		end
		return
	end

	local x,y,w,h,color,hover,anchor = Mb.settings.x,Mb.settings.y,Mb.settings.w,Mb.settings.h,Mb.settings.color,Mb.settings.hover,Mb.settings.anchor

	gameMenuFrame = gameMenuFrame or CreateFrame("BUTTON","GameMenu",BarFrame)
	gameMenuFrame:ClearAllPoints()
	gameMenuFrame:SetPoint(anchor,x,y)
	gameMenuFrame:SetSize(w, h)
	gameMenuFrame:SetMovable(true)
	gameMenuFrame:SetClampedToScreen(true)
	gameMenuFrame:EnableMouse(true)
	gameMenuFrame:RegisterForClicks("AnyUp")
	gameMenuFrame:Show()

	gameMenuIcon = gameMenuIcon or gameMenuFrame:CreateTexture(nil,"OVERLAY",nil,7)
	gameMenuIcon:ClearAllPoints()
	gameMenuIcon:SetPoint("CENTER")
	gameMenuIcon:SetSize(w,h)
	gameMenuIcon:SetTexture(XB.menuIcons.menu)
	gameMenuIcon:SetVertexColor(unpack(color))

	if not gameMenuFrame:GetScript("OnEnter") then
		gameMenuFrame:SetScript("OnEnter", function()
			if InCombatLockdown() and not Mb.settings.combatEn then return end
			gameMenuIcon:SetVertexColor(unpack(hover))
			if Mb.settings.tooltip then
				tooltip()
			end
		end)

		gameMenuFrame:SetScript("OnLeave", function()
			gameMenuIcon:SetVertexColor(unpack(color))
			if libTT:IsAcquired("GameMenuTip") then
				libTT:Release(libTT:Acquire("GameMenuTip"))
			end
		end)

		gameMenuFrame:SetScript("OnClick", clickFunctions)
	end

	XB:AddOverlay(self,gameMenuFrame,anchor)
	
	if not Mb.settings.lock then
		gameMenuFrame.overlay:Show()
		gameMenuFrame.overlay.anchor:Show()
	else
		gameMenuFrame.overlay:Hide()
		gameMenuFrame.overlay.anchor:Hide()
	end
	
end

function Mb:GetFrame()
	return gameMenuFrame
end