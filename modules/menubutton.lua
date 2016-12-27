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

local function round(number)
    local int = math.floor(number)
    return number-int <=0.5 and int or int+1
end

local function refreshOptions()
	Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
	mb_config.posX.min = -round(BarFrame:GetWidth())
	mb_config.posX.max = round(BarFrame:GetWidth())
	mb_config.posY.min = -round(BarFrame:GetHeight())
	mb_config.posY.max = round(BarFrame:GetHeight())
	mb_config.width.max = round(BarFrame:GetWidth()*2)
	mb_config.height.max = round(BarFrame:GetHeight()*2)
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local mb_default = {
	profile = {
		enable = true,
		lock = true,
		x = 0,
		y = 0,
		w = 32,
		h = 32,
		scale = 0.83,
		anchor = "LEFT",
		combatEn = false,
		tooltip = false,
		color = {1,1,1,.75},
		hover = XB.playerClass == "PRIEST" and {.5,.5,.5,.75} or {ccR,ccG,ccB,.75},
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
		min = BarFrame and -BarFrame:GetWidth() or 0,
		max = BarFrame and BarFrame:GetWidth() or 1,
		step = 1,
		get = function() return Mb.settings.x end,
		set = function(_,val) Mb.settings.x = val; Mb:Update() end,
		order = 3
	},
	posY = {
		name = "Y position",
		type = "range",
		min = BarFrame and -BarFrame:GetHeight() or 0,
		max = BarFrame and BarFrame:GetHeight() or 1,
		step = 1,
		get = function() return Mb.settings.y end,
		set = function(_,val) Mb.settings.y = val; Mb:Update() end,
		order = 4
	},
	width = {
		name = "Width",
		type = "range",
		min = 1,
		max = BarFrame and BarFrame:GetWidth() or 2,
		step = 1,
		get = function() return Mb.settings.w end,
		set = function(_,val) Mb.settings.w = val; Mb:Update() end,
		order = 5
	},
	height = {
		name = "Height",
		type = "range",
		min = 1,
		max = BarFrame and BarFrame:GetHeight() or 2,
		step = 1,
		get = function() return Mb.settings.h end,
		set = function(_,val) Mb.settings.h = val; Mb:Update() end,
		order = 6
	},
	scale = {
		name = "Scale",
		type = "range",
		min = 0.1,
		max = 2,
		get = function() return Mb.settings.scale end,
		set = function(_,val) Mb.settings.scale = val; Mb:Update() end,
		order = 8
		
	},
	anchor = {
		name = "Anchor",
		type = "select",
		values = XB.validAnchors,
		get = function() return Mb.settings.anchor end,
		set = function(_,val) Mb.settings.anchor = val; Mb:Update() end,
		order = 7
	},
	color = {
		name = "Icon Color",
		type = "group",
		args = {
			normal = {
				name = "Icon Color",
				type = "color",
				get = function() return unpack(Mb.settings.color) end,
				set = function(_,r,g,b,a)
				end
			},
			normalCC = {
				name = "Class color ",
				type = "toggle",
				get = function() return end,
				set = function(_,val) end
			},
			hover = {
				name = "Hover color",
				type = "color",
				get = function() return unpack(Mb.settings.hover) end,
				set = function(_,r,g,b,a)
				end
			},
			hoverCC = {
				name = "Class color",
				type = "toggle",
				get = function() return end,
				set = function(_,val) end
			},
		}
	},
	misc = {
		name = "Miscellaneous",
		type = "group",
		args = {
			inCombatEnable = {
				name = "Hover in combat",
				type = "toggle",
				desc = "Enable hovering actions during combat",
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
			gameMenu = {
				name = MAINMENU_BUTTON,
				type = "group",
				inline = true,
				order = 3,
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
				inline = true,
				order = 4,
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
				inline = true,
				order = 5,
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
				inline = true,
				order = 6,
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
	XB.Config:Register("MenuButton",mb_config)
	self:CreateButton()
end

function Mb:OnDisable()
	if gameMenuFrame then
		gameMenuFrame:Hide()
	end
end

function Mb:Update()
	refreshOptions()
	XB.Config:Register("MenuButton",mb_config)
	self:CreateButton()
end

function Mb:CreateButton()
	local x,y,w,h,s,color,hover,anchor = Mb.settings.x,Mb.settings.y,Mb.settings.w,Mb.settings.h,Mb.settings.scale,Mb.settings.color,Mb.settings.hover,Mb.settings.anchor

	gameMenuFrame = gameMenuFrame or CreateFrame("BUTTON","GameMenu",BarFrame)
	gameMenuFrame:ClearAllPoints()
	gameMenuFrame:SetPoint(anchor,x,y)
	gameMenuFrame:SetSize(w, h)
	gameMenuFrame:SetScale(s)
	gameMenuFrame:SetMovable(true)
	gameMenuFrame:SetClampedToScreen(true)
	gameMenuFrame:EnableMouse(true)
	gameMenuFrame:RegisterForClicks("AnyUp")
	gameMenuFrame:Show()

	gameMenuIcon = gameMenuIcon or gameMenuFrame:CreateTexture(nil,"OVERLAY",nil,7)
	gameMenuIcon:ClearAllPoints()
	gameMenuIcon:SetPoint("CENTER")
	gameMenuIcon:SetSize(w,h)
	gameMenuIcon:SetTexture("Interface\\AddOns\\"..addOnName.."\\media\\microbar\\menu")
	gameMenuIcon:SetVertexColor(unpack(color))

	gameMenuFrame:SetScript("OnEnter", function()
		if InCombatLockdown() and not Mb.settings.combatEn then return end
		gameMenuIcon:SetVertexColor(unpack(hover))
		if Mb.settings.tooltip then
			if libTT:IsAcquired("GameMenuTip") then
				libTT:Release(libTT:Acquire("GameMenuTip"))
			end
			local tooltip = libTT:Acquire("GameMenuTip", 1, "LEFT")
			tooltip:SmartAnchorTo(gameMenuFrame)
			tooltip:AddHeader('[|cff6699FF'..MAINMENU_BUTTON..'|r]')
			tooltip:AddLine(' ',' ')
			tooltip:AddLine('|cffffff00<'..(self.settings.modMenu==1 and XB.mouseButtons[self.settings.clickMenu] or XB.modifiers[self.settings.modMenu].."+"..XB.mouseButtons[self.settings.clickMenu])..'> |cffffffff'..'Opens '..MAINMENU_BUTTON..'|r')
			tooltip:AddLine('|cffffff00<'..(self.settings.modReload==1 and XB.mouseButtons[self.settings.clickReload] or XB.modifiers[self.settings.modReload].."+"..XB.mouseButtons[self.settings.clickReload])..'> |cffffffff'..'Reloads the UI'..'|r')
			tooltip:AddLine('|cffffff00<'..(self.settings.modOpts==1 and XB.mouseButtons[self.settings.clickOpts] or XB.modifiers[self.settings.modOpts].."+"..XB.mouseButtons[self.settings.clickOpts])..'> |cffffffff'..'Opens the option panel'..'|r')
			tooltip:AddLine('|cffffff00<'..(self.settings.modAddonL==1 and XB.mouseButtons[self.settings.clickAddonL] or XB.modifiers[self.settings.modAddonL].."+"..XB.mouseButtons[self.settings.clickAddonL])..'> |cffffffff'..'Opens '..ADDON_LIST..'|r')
			tooltip:Show()
		end
	end)

	gameMenuFrame:SetScript("OnLeave", function() 
		gameMenuIcon:SetVertexColor(unpack(color))
		if libTT:IsAcquired("GameMenuTip") then
			libTT:Release(libTT:Acquire("GameMenuTip"))
		end
	end)

	gameMenuFrame:SetScript("OnClick", function(self, button, down)
		if InCombatLockdown() and not Mb.settings.combatEn then return end
		
		-- ReloadUI function
		local modifierR = Mb.settings.modReload == 1 or (Mb.settings.modReload == 2 and IsShiftKeyDown or (Mb.settings.modReload == 3 and IsAltKeyDown or IsControlKeyDown))
		local clickR = Mb.settings.clickReload == 1 and "LeftButton" or "RightButton"
		if type(modifierR)=="function" then
			if modifierR() and button == clickR then
				ReloadUI(); return
			end
		else 
			if not IsModifierKeyDown() and button == clickR then
				ReloadUI(); return
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
	end)

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