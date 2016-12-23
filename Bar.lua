local AddOnName, XB = ...;

local Bar = XB:RegisterModule("Bar")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local barFrame, barTexture, overlay, overlayAnchor

local validStrata = {
	BACKGROUND = "BACKGROUND",
	LOW = "LOW",
	MEDIUM = "MEDIUM",
	HIGH = "HIGH",
	DIALOG = "DIALOG",
	FULLSCREEN = "FULLSCREEN",
	FULLSCREEN_DIALOG = "FULLSCREEN_DIALOG",
	TOOLTIP = "TOOLTIP"
}

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function round(number)
    local int = math.floor(number)
    return number-int <=0.5 and int or int+1
end

local function offsetUI()
	if not string.find(Bar.settings.anchor,"TOP") then return end -- Because there is no need to offet the top UI when the bar is not anchored on top

    local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0);

    local offset=Bar.settings.h;
    local buffsAreaTopOffset = offset;

    if (PlayerFrame and not PlayerFrame:IsUserPlaced() and not PlayerFrame_IsAnimatedOut(PlayerFrame)) then
        PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -19, -4 - offset)
    end

    if (TargetFrame and not TargetFrame:IsUserPlaced()) then
        TargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -4 - offset);
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
	if(not MinimapCluster:IsUserPlaced() and MinimapCluster:GetTop()-UIParent:GetHeight() < 1) then
		MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0 - buffsAreaTopOffset);
	end

    BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -205, 0 - buffsAreaTopOffset);
end

local function resetUI()
	UIParent_UpdateTopFramePositions()
	if not MinimapCluster:IsUserPlaced() then
		MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0);
	end
end

local function savePosition(self)
	Bar.settings.anchor,_,_,Bar.settings.x,Bar.settings.y = self:GetPoint()
end

local function barOnEnter(self)
	if not self:GetParent().isMoving then
		self:SetBackdropBorderColor(0.5, 0.5, 0, 1)
	end
end

local function barOnLeave(self)
	self:SetBackdropBorderColor(0, 0, 0, 0)
end

local function barOnDragStart(self)
	local parent = self:GetParent()
	parent:StartMoving()
	self:SetBackdropBorderColor(0, 0, 0, 0)
	parent.isMoving = true
end

local function barOnDragStop(self)
	local parent = self:GetParent()
	if parent.isMoving then
		parent:StopMovingOrSizing()
		savePosition(parent)
		parent.isMoving = nil
		overlayAnchor:ClearAllPoints()
		overlayAnchor:SetPoint(Bar.settings.anchor,overlay,Bar.settings.anchor)
	end
end

local function hideBarEvent()
	barFrame:UnregisterAllEvents()
	barFrame.OnEvent = nil
	barFrame:RegisterEvent("PET_BATTLE_OPENING_START")
	barFrame:RegisterEvent("PET_BATTLE_CLOSE")
	barFrame:SetScript("OnEvent", function(_, event, ...)
		if event=="PET_BATTLE_OPENING_START" and XIV_Databar:IsVisible() then
			XIV_Databar:Hide()
		end
		if event=="PET_BATTLE_CLOSE" and not XIV_Databar:IsVisible() then
			XIV_Databar:Show()
		end
	end)

	if Bar.settings.hideCombat then
		barFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		barFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

		barFrame:HookScript("OnEvent", function(_, event, ...)
			if event=="PLAYER_REGEN_DISABLED" and XIV_Databar:IsVisible() then
				XIV_Databar:Hide()
			end
			if event=="PLAYER_REGEN_ENABLED" and not XIV_Databar:IsVisible() then
				XIV_Databar:Show()
			end
		end)
	else
		if barFrame:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			barFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		elseif barFrame:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			barFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
	end
end

local function hookFunctions()
	hooksecurefunc("UIParent_UpdateTopFramePositions",function(self)
		if OrderHallCommandBar and OrderHallCommandBar:IsVisible() then
			if Bar.settings.ohHide then
				OrderHallCommandBar:Hide()
			end
		end
		if Bar.settings.offset then
			offsetUI()
		end
	end)
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local bar_defaut = {
    profile = {
        x = 0,
        y = 0,
        w = round(GetScreenWidth()),
        h = 35,
        fs = true,
        anchor = "BOTTOMLEFT",
		strata = "HIGH",
        lock = true,
        ohHide = false,
        hideCombat = false,
		offset = false,
        color = {.094,.094,.102,.45},
        useCC = false
    }
}

local bar_config = {
    title = {
        type = "description",
        name = "|cff64b4ffBar options",
        fontSize = "large",
        order = 0
    },
    desc = {
        type = "description",
        name = "Options for the display of the bar",
        fontSize = "medium",
        order = 1
    },
    unlock = {
        type = "toggle",
        name = "Unlock",
        desc = "Move the bar position with the mouse",
        get = function() return not Bar.settings.lock; end,
        set = function(_,val) Bar.settings.lock = not val; Bar:Update(); end,
        order = 2
    },
    fullScreen = {
        name = VIDEO_OPTIONS_FULLSCREEN,
        type = "toggle",
        get = function() return Bar.settings.fs; end,
        set = function(_,val)
			Bar.settings.fs = val
			if val then
				Bar.settings.w = round(GetScreenWidth())
			end
			Bar:Update()
		end,
        order = 3
    },
    posX = {
        type = "range",
        name = "X position",
        desc = "Sets the horizontal position of the bar",
        min = -math.floor(GetScreenWidth()),
        max = math.floor(GetScreenWidth()),
        step = 1,
        get = function() return Bar.settings.x; end,
        set = function(_,val) Bar.settings.x = val; Bar:Update(); end,
        order = 4
    },
    posY = {
        type = "range",
        name = "Y position",
        desc = "Sets the vertical position of the bar",
        min = -math.floor(GetScreenHeight()),
        max = math.floor(GetScreenHeight()),
        step = 1,
        get = function() return Bar.settings.y; end,
        set = function(_,val) Bar.settings.y = val; Bar:Update(); end,
        order = 5
    },
    width = {
        type = "range",
        name = "Width",
        desc = "Sets the width of the bar if not fullscreen",
        min = 1,
        max = round(GetScreenWidth()),
        step = 1,
        get = function() return Bar.settings.w; end,
        set = function(_,val) Bar.settings.w = val; Bar:Update(); end,
        disabled = function() return Bar.settings.fs; end,
        order = 6
    },
    height = {
        type = "range",
        name = "Height",
        desc = "Sets the height of the bar",
        min = 1,
        max = round(GetScreenHeight()),
        step = 1,
        get = function() return Bar.settings.h; end,
        set = function(_,val) Bar.settings.h = val; Bar:Update(); end,
        order = 7
    },
    anchor = {
        type = "select",
		name = "Anchor",
        desc = "Where the bar should be anchored",
        values = XB.validAnchors,
        get = function() return Bar.settings.anchor; end,
        set = function(_,val) Bar.settings.anchor = val; Bar:Update(); end,
        order = 12
    },
	strata = {
		type = "select",
		name = "Frame strata",
		values = validStrata,
		get = function() return Bar.settings.strata end,
		set = function(_,val) Bar.settings.strata = val; Bar:Update(); end,
		order = 13
	},
    color = {
        name = "Bar color",
        type = "group",
        args = {
            barColorPicker = {
                name = "Bar color",
                type = "color",
                hasAlpha = true,
                set = function(info, r, g, b, a)
                    if not Bar.settings.useCC then
                        Bar.settings.color = {r,g,b,a};
                    else
                        local cr,cg,cb = GetClassColor(XB.playerClass)
                        Bar.settings.color = {cr,cg,cb,a}
                    end
					Bar:Update()
                end,
                get = function() return unpack(Bar.settings.color) end,
            },
            barCC = {
                name = "Use class color",
                desc = "Only the alpha can be set with the color picker",
                type = "toggle",
                get = function() return Bar.settings.useCC; end,
                set = function(_,val)
                    Bar.settings.useCC = val;
                    if val then
                        local r,g,b = GetClassColor(XB.playerClass);
                        Bar.settings.color = {r,g,b,Bar.settings.color[4]}
                    end
					Bar:Update()
                end
            }
        }
    },
    misc = {
        name = "Miscellaneous",
        type = "group",
        args = {
            hideBarCombat = {
                name = "Hide bar in combat",
                type = "toggle",
                get = function() return Bar.settings.hideCombat end,
                set = function(_,val) Bar.settings.hideCombat = val; hideBarEvent() end
            },
            hideOHBar = {
                name = 'Hide order hall bar',
                type = "toggle",
                get = function() return Bar.settings.ohHide end,
                set = function(_,val)
                    Bar.settings.ohHide = val;
                    if val then
                        LoadAddOn("Blizzard_OrderHallUI");
                        OrderHallCommandBar:Hide();
                    end
                end
            },
			offsetUI = {
				name = "Offset UI",
				type = "toggle",
				desc = "Offset the top UI of the height of the bar",
				get = function() return Bar.settings.offset end,
				set = function(_,val)
					Bar.settings.offset = val;
					if val then
						offsetUI()
					else
						resetUI()
					end
				end
			}
        }
    }
    --fontActive, ?
    --fontHover, ?
    --fontInactive ?
}

----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Bar:OnInitialize()
    self.db = XB.db:RegisterNamespace("Bar", bar_defaut)
    self.settings = self.db.profile
    XB.Config:Register("Bar",bar_config)
end

function Bar:OnEnable()
	Bar.settings.lock = Bar.settings.lock or not Bar.settings.lock --Locking bar if it was not locked on reload/relog
	self:CreateBar()
	hideBarEvent()
	hookFunctions()
	if Bar.settings.offset then
		C_Timer.After(1,offsetUI)
	end
end

function Bar:OnDisable()
	if barFrame then
		barFrame:UnregisterAllEvents()
		barFrame:Hide()
	end
end

function Bar:Update()
	self:CreateBar()
end

function Bar:CreateBar()
	local x,y,w,h,color,strata,anchor = Bar.settings.x,Bar.settings.y,Bar.settings.w,Bar.settings.h,Bar.settings.color,Bar.settings.strata,Bar.settings.anchor

	barFrame = barFrame or CreateFrame("Frame",AddOnName, UIParent)
	barFrame:SetSize(w, h)
	barFrame:SetFrameStrata(strata)
	barFrame:ClearAllPoints()
	barFrame:SetPoint(anchor,x,y)
	barFrame:SetMovable(true)
	barFrame:SetClampedToScreen(true)

	barTexture = barTexture or barFrame:CreateTexture(nil,"BACKGROUND",nil,-8) -- BORDER Addition needed for Issue #55 ?
	barTexture:SetAllPoints()
	barTexture:SetColorTexture(unpack(color))
	barFrame:Show()

	--Overlay for uloncked bar for user positionning
	overlay = overlay or CreateFrame("Button", "Overlay", barFrame)
	overlay:EnableMouse(true)
	overlay:RegisterForDrag("LeftButton")
	overlay:RegisterForClicks("LeftButtonUp")
	overlay:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = true,
		tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = {left = 5, right = 3, top = 3, bottom = 5}
	})
	overlay:SetBackdropColor(0, 1, 0, 0.5)
	overlay:SetBackdropBorderColor(0.5, 0.5, 0, 0)

	overlay:SetScript("OnEnter", barOnEnter)
	overlay:SetScript("OnLeave", barOnLeave)
	overlay:SetScript("OnDragStart", barOnDragStart)
	overlay:SetScript("OnDragStop", barOnDragStop)

	overlay:SetFrameLevel(barFrame:GetFrameLevel() + 10)
	overlay:ClearAllPoints()
	overlay:SetPoint(anchor,barFrame,anchor)
	overlay:SetSize(w, h)

	overlayAnchor = overlayAnchor or overlay:CreateTexture(nil,"ARTWORK")
	overlayAnchor:SetSize(13,13)
	overlayAnchor:SetTexture(XB.icons.anchor)
	overlayAnchor:ClearAllPoints()
	overlayAnchor:SetPoint(anchor,overlay,anchor)

	if not Bar.settings.lock then
		overlay:Show()
		overlayAnchor:Show()
	else
		overlay:Hide()
		overlayAnchor:Hide()
	end
end

function Bar:GetFrame()
	return barFrame
end
