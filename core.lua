local AddOnName, XIVBar = ...;
local _G = _G;
local pairs, unpack, select = pairs, unpack, select
LibStub("AceAddon-3.0"):NewAddon(XIVBar, AddOnName, "AceConsole-3.0", "AceEvent-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnName, true);
local ldb = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(AddOnName, {
    type = "launcher",
    icon = "Interface\\Icons\\Spell_Nature_StormReach",
    OnClick = function(clickedframe, button)
        XIVBar:ToggleConfig()
    end,
})

XIVBar.L = L

XIVBar.constants = {
    mediaPath = "Interface\\AddOns\\"..AddOnName.."\\media\\",
    playerName = UnitName("player"),
    playerClass = select(2, UnitClass("player")),
    playerLevel = UnitLevel("player"),
    playerFactionLocal = select(2, UnitFactionGroup("player")),
    playerRealm = GetRealmName(),
    popupPadding = 10,
}

XIVBar.defaults = {
    profile = {
        general = {
            barPosition = "BOTTOM",
            barPadding = 3,
            moduleSpacing = 30,
            barFullscreen = true,
            barWidth = GetScreenWidth(),
            barHoriz = 'CENTER',
			barCombatHide = false,
            barFlightHide = false,
            useElvUI = true,
        },
        color = {
            barColor = {
                r = 0.094,
                g = 0.094,
                b = 0.094,
                a = 0.75
            },
            normal = {
                r = 0.8,
                g = 0.8,
                b = 0.8,
                a = 0.75
            },
            inactive = {
                r = 1,
                g = 1,
                b = 1,
                a = 0.25
            },
            useCC = false,
			useTextCC = false,
            useHoverCC = true,
            hover = {
				r = RAID_CLASS_COLORS[XIVBar.constants.playerClass].r,
				g = RAID_CLASS_COLORS[XIVBar.constants.playerClass].g,
				b = RAID_CLASS_COLORS[XIVBar.constants.playerClass].b,
				a = RAID_CLASS_COLORS[XIVBar.constants.playerClass].a
			}
        },
        text = {
            fontSize = 12,
            smallFontSize = 11,
            font =  'Homizio Bold'
        },
        modules = {

        }
    }
};

XIVBar.LSM = LibStub('LibSharedMedia-3.0');

function XIVBar:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("XIVBarDB", self.defaults, true)
    self.LSM:Register(self.LSM.MediaType.FONT, 'Homizio Bold', self.constants.mediaPath.."homizio_bold.ttf")
    self.frames = {}

    self.fontFlags = {'', 'OUTLINE', 'THICKOUTLINE', 'MONOCHROME'}

    local options = {
        name = "XIV Bar",
        handler = XIVBar,
        type = 'group',
        args = {
            general = {
                name = GENERAL_LABEL,
                type = "group",
                args = {
                    general = self:GetGeneralOptions()
                }
            }, -- general
            modules = {
                name = L['Modules'],
                type = "group",
                args = {

                }
            } -- modules
        }
    }

    for name, module in self:IterateModules() do
        if module['GetConfig'] ~= nil then
            options.args.modules.args[name] = module:GetConfig()
        end
        if module['GetDefaultOptions'] ~= nil then
            local oName, oTable = module:GetDefaultOptions()
            self.defaults.profile.modules[oName] = oTable
        end
    end

    self.db:RegisterDefaults(self.defaults)

    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOnName, options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, "XIV Bar", nil, "general")

    --options.args.modules = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    self.modulesOptionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, L['Modules'], "XIV Bar", "modules")

    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    self.profilesOptionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, 'Profiles', "XIV Bar", "profiles")

    self.timerRefresh = false

    self:RegisterChatCommand('xivbar', 'ToggleConfig')
    self:RegisterChatCommand('xb', 'ToggleConfig')
end

function XIVBar:OnEnable()
    self:CreateMainBar()
    self:Refresh()

    self.db.RegisterCallback(self, 'OnProfileCopied', 'Refresh')
    self.db.RegisterCallback(self, 'OnProfileChanged', 'Refresh')
    self.db.RegisterCallback(self, 'OnProfileReset', 'Refresh')

    if not self.timerRefresh then
        C_Timer.After(5, function()
            self:Refresh()
            self.timerRefresh = true
        end)
    end
end

function XIVBar:ToggleConfig()
    InterfaceOptionsFrame.selectedTab = 2;
	InterfaceOptionsFrame:Show()--weird hack ; options registration is wrong in some way
	InterfaceOptionsFrame_OpenToCategory("XIV Bar")
end

function XIVBar:SetColor(name, r, g, b, a)
    self.db.profile.color[name].r = r
    self.db.profile.color[name].g = g
    self.db.profile.color[name].b = b
    self.db.profile.color[name].a = a

    self:Refresh()
end

function XIVBar:GetColor(name)
    local profile = self.db.profile.color
    local a = profile[name].a
    -- what a stupid hacky solution, the whole config part is kind of fucked and i dread having to come fix this eventually.
    -- feel like just burning it all down and writing something from scratch when seeing shit like this. terrible library.
    if name == 'normal' then
        -- use class color for normal color
        if profile.useTextCC then
            local r, g, b = self:GetClassColors()
            return r, g, b, a
        end
    end
    -- use self-picked color for normal color
    return profile[name].r, profile[name].g, profile[name].b, a
end

function XIVBar:HoverColors()
    local colors
    local profile = self.db.profile.color
    -- use self-picked color for hover color
    if not profile.useHoverCC then
        colors = { profile.hover.r, profile.hover.g, profile.hover.b, profile.hover.a }
    -- use class color for hover color
    else
        local r, g, b = self:GetClassColors()
        colors = { r, g, b, profile.hover.a }
    end
    return colors
end

function XIVBar:RegisterFrame(name, frame)
    frame:SetScript('OnHide', function()
        self:SendMessage('XIVBar_FrameHide', name)
    end)
    frame:SetScript('OnShow', function()
        self:SendMessage('XIVBar_FrameShow', name)
    end)
    self.frames[name] = frame
end

function XIVBar:GetFrame(name)
    return self.frames[name]
end

function XIVBar:CreateMainBar()
    if self.frames.bar == nil then
        self:RegisterFrame('bar', CreateFrame("FRAME", "XIV_Databar", UIParent))
        self.frames.bgTexture = self.frames.bgTexture or self.frames.bar:CreateTexture(nil, "BACKGROUND")
    end
end

function XIVBar:HideBarEvent()
	local bar = self:GetFrame("bar")
	local vehiculeIsFlight = false;

    bar:UnregisterAllEvents()
	bar.OnEvent = nil
	bar:RegisterEvent("PET_BATTLE_OPENING_START")
	bar:RegisterEvent("PET_BATTLE_CLOSE")
    bar:RegisterEvent("TAXIMAP_CLOSED")
    bar:RegisterEvent("VEHICLE_POWER_SHOW")

	bar:SetScript("OnEvent", function(_, event, ...)
        if self.db.profile.general.barFlightHide then
            if event == "VEHICLE_POWER_SHOW" then
                if not XIVBar:IsVisible() then
                    XIVBar:Show()
                end
                if vehiculeIsFlight and XIVBar:IsVisible() then
                    XIVBar:Hide()
                end
            end

            if event == "TAXIMAP_CLOSED" then
                vehiculeIsFlight = true
                C_Timer.After(1,function()
                    vehiculeIsFlight = false
                end)
            end
        end

		if event=="PET_BATTLE_OPENING_START" and XIVBar:IsVisible() then
			XIVBar:Hide()
		end
		if event=="PET_BATTLE_CLOSE" and not XIVBar:IsVisible() then
			XIVBar:Show()
		end
	end)

	if self.db.profile.general.barCombatHide then
		bar:RegisterEvent("PLAYER_REGEN_ENABLED")
		bar:RegisterEvent("PLAYER_REGEN_DISABLED")

		bar:HookScript("OnEvent", function(_, event, ...)
			if event=="PLAYER_REGEN_DISABLED" and XIVBar:IsVisible() then
				XIVBar:Hide()
			end
			if event=="PLAYER_REGEN_ENABLED" and not XIVBar:IsVisible() then
				XIVBar:Show()
			end
		end)
	else
		if bar:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			bar:UnregisterEvent("PLAYER_REGEN_ENABLED")
		elseif bar:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			bar:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
	end
end

function XIVBar:GetHeight()
    return (self.db.profile.text.fontSize * 2) + self.db.profile.general.barPadding
end

function XIVBar:Refresh()
    if self.frames.bar == nil then return; end
	
	self:HideBarEvent()
    self.miniTextPosition = "TOP"
    if self.db.profile.general.barPosition == 'TOP' then
		hooksecurefunc("UIParent_UpdateTopFramePositions", function(self)
			if(XIVBar.db.profile.general.barPosition == 'TOP') then
				OffsetUI()
			end
		end)
		OffsetUI()
        self.miniTextPosition = 'BOTTOM'
	else
		self:ResetUI();
    end

    local barColor = self.db.profile.color.barColor
    self.frames.bar:ClearAllPoints()
    self.frames.bar:SetPoint(self.db.profile.general.barPosition)
    if self.db.profile.general.barFullscreen then
        self.frames.bar:SetPoint("LEFT")
        self.frames.bar:SetPoint("RIGHT")
    else
        local relativePoint = self.db.profile.general.barHoriz
        if relativePoint == 'CENTER' then
            relativePoint = 'BOTTOM'
        end
        self.frames.bar:SetPoint(self.db.profile.general.barHoriz, self.frames.bar:GetParent(), relativePoint)
        self.frames.bar:SetWidth(self.db.profile.general.barWidth)
    end
    self.frames.bar:SetHeight(self:GetHeight())

	self.frames.bgTexture:SetColorTexture(self:GetColor('barColor'))
    self.frames.bgTexture:SetAllPoints()

    for name, module in self:IterateModules() do
        if module['Refresh'] == nil then return; end
        module:Refresh()
    end
end

function XIVBar:GetFont(size)
    return self.LSM:Fetch(self.LSM.MediaType.FONT, self.db.profile.text.font), size, self.fontFlags[self.db.profile.text.flags]
end

function XIVBar:GetClassColors()
    return RAID_CLASS_COLORS[self.constants.playerClass].r, RAID_CLASS_COLORS[self.constants.playerClass].g, RAID_CLASS_COLORS[self.constants.playerClass].b, self.db.profile.color.barColor.a
end

function XIVBar:RGBAToHex(r, g, b, a)
    a = a or 1
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    a = a <= 1 and a >= 0 and a or 1
    return string.format("%02x%02x%02x%02x", r*255, g*255, b*255, a*255)
end

function XIVBar:HexToRGBA(hex)
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    if not (rhex and ghex and bhex and ahex) then
        return 0, 0, 0, 0
    end
    return (tonumber(rhex, 16) / 255), (tonumber(ghex, 16) / 255), (tonumber(bhex, 16) / 255), (tonumber(ahex, 16) / 255)
end

function XIVBar:PrintTable(table, prefix)
    for k,v in pairs(table) do
        if type(v) == 'table' then
            self:PrintTable(v, prefix..'.'..k)
        else
            print(prefix..'.'..k..': '..tostring(v))
        end
    end
end

function OffsetUI()
    local offset=XIVBar.frames.bar:GetHeight();
    local buffsAreaTopOffset = offset;

    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
        if (PlayerFrame and not PlayerFrame:IsUserPlaced() and not PlayerFrame_IsAnimatedOut(PlayerFrame)) then
            PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -19, -4 - offset)
        end

        if (TargetFrame and not TargetFrame:IsUserPlaced()) then
            TargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -4 - offset);
        end
    end

    local ticketStatusFrameShown = TicketStatusFrame and TicketStatusFrame:IsShown();
    local gmChatStatusFrameShown = GMChatStatusFrame and GMChatStatusFrame:IsShown();
    if (ticketStatusFrameShown) then
        TicketStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -180, 0 - offset);
        buffsAreaTopOffset = buffsAreaTopOffset + TicketStatusFrame:GetHeight();
    end
    if (gmChatStatusFrameShown) then
        GMChatStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -170, -5 - offset);
        buffsAreaTopOffset = buffsAreaTopOffset + GMChatStatusFrame:GetHeight() + 5;
    end
    if (not ticketStatusFrameShown and not gmChatStatusFrameShown) then
        buffsAreaTopOffset = buffsAreaTopOffset + 13;
    end
		
    BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -205, 0 - buffsAreaTopOffset);
end

function XIVBar:ResetUI()
	if topOffsetBlizz then
		UIParent_UpdateTopFramePositions = topOffsetBlizz
	end
	UIParent_UpdateTopFramePositions();
end

function XIVBar:GetGeneralOptions()
    return {
        name = GENERAL_LABEL,
        type = "group",
        inline = true,
        args = {
			positioning = {
				name = L["Positioning"],
				type = "group",
				order = 1,
				inline = true,
				args = {
					barLocation = {
						name = L['Bar Position'],
						type = "select",
						order = 2,
						width = "full",
						values = {TOP = L['Top'], BOTTOM = L['Bottom']},
						style = "dropdown",
						get = function() return self.db.profile.general.barPosition; end,
						set = function(info, value) self.db.profile.general.barPosition = value;
						self:Refresh(); end,
					},
                    flightHide = {
                        name = "Hide when in flight",
                        type = "toggle",
                        order = 1,
                        get = function() return self.db.profile.general.barFlightHide end,
                        set = function(_,val) self.db.profile.general.barFlightHide = val; self:Refresh(); end
                    },
					fullScreen = {
						name = VIDEO_OPTIONS_FULLSCREEN,
						type = "toggle",
						order = 4,
						get = function() return self.db.profile.general.barFullscreen; end,
						set = function(info, value) self.db.profile.general.barFullscreen = value; self:Refresh(); end,
					},
					barPosition = {
						name = L['Horizontal Position'],
						type = "select",
						hidden = function() return self.db.profile.general.barFullscreen; end,
						order = 5,
						values = {LEFT = L['Left'], CENTER = L['Center'], RIGHT = L['Right']},
						style = "dropdown",
						get = function() return self.db.profile.general.barHoriz; end,
						set = function(info, value) self.db.profile.general.barHoriz = value; self:Refresh(); end,
						disabled = function() return self.db.profile.general.barFullscreen; end
					},
					barWidth = {
						name = L['Bar Width'],
						type = 'range',
						order = 6,
						hidden = function() return self.db.profile.general.barFullscreen; end,
						min = 200,
						max = GetScreenWidth(),
						step = 1,
						get = function() return self.db.profile.general.barWidth; end,
						set = function(info, val) self.db.profile.general.barWidth = val; self:Refresh(); end,
						disabled = function() return self.db.profile.general.barFullscreen; end
					}
				}
			},
			text = self:GetTextOptions(),
			colors = {
				name = L["Colors"],
				type = "group",
				inline = true,
				order = 3,
				args = {
					barColor = {
						name = L['Bar Color'],
						type = "color",
						order = 1,
						hasAlpha = true,
						set = function(info, r, g, b, a)
							if not self.db.profile.color.useCC then
								self:SetColor('barColor', r, g, b, a)
							else
								local cr,cg,cb,_ = self:GetClassColors()
								self:SetColor('barColor',cr,cg,cb,a)
							end
						end,
						get = function() return XIVBar:GetColor('barColor') end,
					},
					barCC = {
						name = L['Use Class Color for Bar'],
						desc = L["Only the alpha can be set with the color picker"],
						type = "toggle",
						order = 2,
						set = function(info, val) XIVBar:SetColor('barColor',self:GetClassColors()); self.db.profile.color.useCC = val; self:Refresh(); end,
						get = function() return self.db.profile.color.useCC end
					},
					textColors = self:GetTextColorOptions()
				}
			},
			miscellanelous = {
				name = L["Miscellaneous"],
				type = "group",
				inline = true,
				order = 3,
				args = {
					barCombatHide = {
						name = L['Hide Bar in combat'],
						type = "toggle",
						order = 9,
						get = function() return self.db.profile.general.barCombatHide; end,
						set = function(_,val) self.db.profile.general.barCombatHide = val; self:Refresh(); end
                    },
					barPadding = {
						name = L['Bar Padding'],
						type = 'range',
						order = 10,
						min = 0,
						max = 10,
						step = 1,
						get = function() return self.db.profile.general.barPadding; end,
						set = function(info, val) self.db.profile.general.barPadding = val; self:Refresh(); end
					},
					moduleSpacing = {
						name = L['Module Spacing'],
						type = 'range',
						order = 11,
						min = 10,
						max = 80,
						step = 1,
						get = function() return self.db.profile.general.moduleSpacing; end,
						set = function(info, val) self.db.profile.general.moduleSpacing = val; self:Refresh(); end
                    },
                    useElvUI = {
                        name = L['Use ElvUI for tooltips'],
                        type = "toggle",
                        order = 12,
                        get = function() return self.db.profile.general.useElvUI; end,
                        set = function(_, val) self.db.profile.general.useElvUI = val; self:Refresh(); end
                    }
				}
			}
        }
    }
end

function XIVBar:GetTextOptions()
    return {
        name = LOCALE_TEXT_LABEL,
        type = "group",
        order = 2,
        inline = true,
        args = {
            font = {
                name = L['Font'],
                type = "select",
				dialogControl = 'LSM30_Font',
                order = 1,
				values = AceGUIWidgetLSMlists.font,
                style = "dropdown",
                get = function() return self.db.profile.text.font; end,
                set = function(info, val) self.db.profile.text.font = val; self:Refresh(); end
            },
            fontSize = {
                name = FONT_SIZE,
                type = 'range',
                order = 2,
                min = 10,
                max = 40,
                step = 1,
                get = function() return self.db.profile.text.fontSize; end,
                set = function(info, val) self.db.profile.text.fontSize = val; self:Refresh(); end
            },
            smallFontSize = {
                name = L['Small Font Size'],
                type = 'range',
                order = 2,
                min = 10,
                max = 20,
                step = 1,
                get = function() return self.db.profile.text.smallFontSize; end,
                set = function(info, val) self.db.profile.text.smallFontSize = val; self:Refresh(); end
            },
            textFlags = {
                name = L['Text Style'],
                type = 'select',
                style = 'dropdown',
                order = 3,
                values = self.fontFlags,
                get = function() return self.db.profile.text.flags; end,
                set = function(info, val) self.db.profile.text.flags = val; self:Refresh(); end
            },
        }
    }
end

function XIVBar:GetTextColorOptions()
    return {
        name = L['Text Colors'],
        type = "group",
        order = 3,
        inline = true,
        args = {
            normal = {
                name = L['Normal'],
                type = "color",
                order = 1,
                width = "double",
                hasAlpha = true,
                set = function(info, r, g, b, a)
					if self.db.profile.color.useTextCC then
						r,g,b,_=self:GetClassColors()
					end
                    XIVBar:SetColor('normal', r, g, b, a)
                end,
                get = function() return XIVBar:GetColor('normal') end
            },
			textCC = {
				name = L["Use Class Color for Text"],
				desc = L["Only the alpha can be set with the color picker"],
				type = "toggle",
				order = 2,
				set = function(_,val) 
					if val then
						XIVBar:SetColor("normal",self:GetClassColors())
					end 
					self.db.profile.color.useTextCC = val 
				end,
				get = function() return self.db.profile.color.useTextCC end
			},
			hover = {
                name = L['Hover'],
                type = "color",
                order = 3,
				width = "double",
                hasAlpha = true,
                set = function(info, r, g, b, a)
					if self.db.profile.color.useHoverCC then
						r,g,b,_=self:GetClassColors()
					end
                    XIVBar:SetColor('hover', r, g, b, a)
                end,
                get = function() return XIVBar:GetColor('hover') end,
            },
            hoverCC = {
                name = L['Use Class Colors for Hover'],
                type = "toggle",
                order = 4,
                set = function(_, val)
					if val then
						XIVBar:SetColor("hover",self:GetClassColors())
					end
				self.db.profile.color.useHoverCC = val; self:Refresh(); end,
                get = function() return self.db.profile.color.useHoverCC end
            },
            inactive = {
                name = L['Inactive'],
                type = "color",
                order = 5,
                hasAlpha = true,
                width = "double",
                set = function(info, r, g, b, a)
                    XIVBar:SetColor('inactive', r, g, b, a)
                end,
                get = function() return XIVBar:GetColor('inactive') end
            },
        }
    }
end
