local AddOnName, XB = ...;
local Bar = XB:RegisterModule("Bar")


local validAnchors = {
    CENTER = "CENTER",
    LEFT = "LEFT",
    RIGHT = "RIGHT",
    TOP = "TOP",
    TOPLEFT = "TOPLEFT",
    TOPRIGHT = "TOPRIGHT",
    BOTTOM = "BOTTOM",
    BOTTOMLEFT = "BOTTOMLEFT",
    BOTTOMRIGHT = "BOTTOMRIGHT",
}

local function round(number)
    local int = math.floor(number)
    return number-int <=0.5 and int or int+1
end

local bar_defaut = {
    profile = {
        x = 0,
        y = 0,
        w = round(GetScreenWidth()),
        h = 35,
        fs = true,
        anchor = "BOTTOMLEFT",
        lock = true,
        ohHide = false,
        hideCombat = false,
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
        set = function(_,val) Bar.settings.lock = not val; end,
        order = 2
    },
    fullScreen = {
        name = VIDEO_OPTIONS_FULLSCREEN,
        type = "toggle",
        get = function() return Bar.settings.fs; end,
        set = function(_,val) Bar.settings.fs = val; end,
        order = 3
    },
    posX = {
        type = "range",
        name = "X position",
        desc = "Sets the horizontal position of the bar",
        min = 0,
        max = math.floor(GetScreenWidth()),
        step = 1,
        get = function() return Bar.settings.x; end,
        set = function(_,val) Bar.settings.x = val; end,
        order = 4
    },
    posY = {
        type = "range",
        name = "Y position",
        desc = "Sets the vertical position of the bar",
        min = 0,
        max = math.floor(GetScreenHeight()),
        step = 1,
        get = function() return Bar.settings.y; end,
        set = function(_,val) Bar.settings.y = val; end,
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
        set = function(_,val) Bar.settings.w = val; end,
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
        set = function(_,val) Bar.settings.h = val; end,
        order = 7
    },
    anchor = {
        type = "select",
        name = "Where the bar should be anchored",
        values = validAnchors,
        get = function() return Bar.settings.anchor; end,
        set = function(_,val) Bar.settings.anchor = val; end,
        order = 12
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
                        Bar.settings.color = {r,g,b,Bar.settings.color.a}
                    end
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
                set = function(_,val) Bar.settings.hideCombat = val; end
            },
            hideOHBar = {
                name = 'Hide order hall bar',
                type = "toggle",
                get = function() return Bar.settings.ohHide end,
                set = function(_,val)
                    Bar.settings.ohHide = val;
                    if val then
                        LoadAddOn("Blizzard_OrderHallUI");
                        local b = OrderHallCommandBar;
                        b:Hide();
                    end
                end
            }
        }
    }
    --fontActive, ?
    --fontHover, ?
    --fontInactive ?
}

function Bar:OnInitialize()
    self.db = XB.db:RegisterNamespace("Bar", bar_defaut)
    self.settings = self.db.profile
    XB.Config:Register("Bar",bar_config)
end