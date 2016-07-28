-----------------------------------------------------------------
-- CONFIGURATION FILE          DO NOT TOUCH ANYTHING BELLOW HERE
-----------------------------------------------------------------
local addon, ns = ...
local cfg = {}
ns.cfg = cfg


cfg.NAME = UnitName("player")
cfg.CLASS = select(2, UnitClass("player"))
cfg.cc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[cfg.CLASS] --CLASS COLOR

--media path
cfg.mediaFolder = "Interface\\AddOns\\"..addon.."\\media\\"

---------------------------------------------
-- DO NOT TOUCH ANYTHING ABOVE HERE
---------------------------------------------

cfg.color = {
	normal = {1,1,1,.75},						-- SETS THE SAME COLOR FOR THE TEXT
	inactive = {1,1,1,.25},						-- SET THE COLOR FOR THE INACTICE ICONS
	hover = {cfg.cc.r,cfg.cc.g,cfg.cc.b,.75},	-- DOES NOT CHANGE THE TEXTCOLOR
	barcolor = {.094,.094,.094,.75},			-- THE COLOR OF THE BAR
	--barcolor = {.05,.05,.05,0},			-- THE COLOR OF THE BAR
}
if cfg.CLASS == "PRIEST" then cfg.color.hover = {.5,.5,0,.75} end -- ADDED BEACUSE NORMALY THE PRIEST COLOR IS THE SAME AS THE NORMAL COLOR

cfg.text = {
	font = cfg.mediaFolder.."homizio_bold.ttf",	-- SETS THE FONT
	normalFontSize = 12,	-- SET THE SIZE OF THE TEXTS
	smallFontSize = 11,		-- SETS THE SIZE OF THE SMALLER TEXTS
}

cfg.core = {
	height = 35,
	position = "BOTTOM", 	-- THE POSITION OF THE BAR USE "BOTTOM" OR "TOP"
	scale = 0.83, 			-- SCALE BAR TO GET ROOM FOR ALL THE ICONS AND TEXT
	strata = "HIGH",		-- AT WHAT STRATA THE BAR SHOULD BE AT
}

cfg.micromenu = {
	show = true,			-- USES THIS MODULE
	showTooltip = true,		-- ADDS TOOLTIPS FOR THE SOSIAL FRAMES
}

cfg.armor = {
	show = true,			-- USES THIS MODULE
	minArmor = 20,			-- WHEN THE ANVIL GOES FROM INACTIVE TO ACTIVE
	maxArmor = 75,			-- AT WHAT % IT WILL SHOW ARMORTEXT INSTEAD OF ILVL
}

cfg.talent = {
	show = true,			-- USES THIS MODULE
}

cfg.clock = {
	show = true,			-- USES THIS MODULE
	showTooltip = true,		-- SHOWS SOME INFO AND REALMTIME OR LOCAL TIME
}

cfg.tradeSkill = {
	show = true,			-- USES THIS MODULE
	showTooltip = true,		-- SHOW WHAT TRADESKILLS THAT ARE ON COOLDOWN
}

cfg.currency = {
	show = true,			-- USES THIS MODULE
	showXPbar = true,		-- SHOW A XP-BAR ON YOUR CHARACTERS THAT HAS NOT REACHED MAX LVL
	showTooltip = true,		-- SHOWS YOUR RECOURCES ACCORING TO THE DESCRIPTION OR YOUR XP INFO
	textOnRight = true,
}

cfg.system = {
	show = true,			-- USES THIS MODULE
	showTooltip = true,		-- SHOWS A LIST OF ADDONS AND HOW MUCH SYSTEM THEY USE
	addonList = 10, 		-- SHOW HOW MANY ADDONS TO SHOW ON HOVER
	addonListShift = 25,	-- SHOW HOW MANY ADDONS TO SHOW ON HOVER WHILE SHIFT IS DOWN
	showWorldPing = true,
}

cfg.gold = {
	showTooltip = true,		-- SHOWS THE GOLD OF YOUR OTHER CHARACTERS ON THE SAME SERVER AND SAME SIDE
	show = true,			-- USES THIS MODULE
	firstWeekday = 2, 		-- 1 is Sunday, 2 is Monday, different countries have different first day of the week
	showFreeBagSpace = false,
}

cfg.heartstone = {
	show = true,			-- USES THIS MODULE
	showTooltip = true,		-- SHOWS THE COOLDOWN ON MOUSEOVER
}

cfg.useConfig = false		-- !! DO NOT TOUCH !!
---------------------------------------------
-- DO NOT TOUCH ANYTHING BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING !!
---------------------------------------------
-- CREATE THE CORE FRAME
---------------------------------------------

local unpack = unpack
local SX_bottombar = CreateFrame("Frame","SX_bottombar", UIParent)
SX_bottombar:SetSize(0, cfg.core.height)
SX_bottombar:SetScale(cfg.core.scale)
SX_bottombar:SetFrameStrata(cfg.core.strata)

SX_bottombar:SetPoint(cfg.core.position)
SX_bottombar:SetPoint("LEFT")
SX_bottombar:SetPoint("RIGHT")

cfg.SXframe = SX_bottombar

local coreTexture = SX_bottombar:CreateTexture(nil,"BACKGROUND",nil,-8)
coreTexture:SetAllPoints()
coreTexture:SetColorTexture(unpack(cfg.color.barcolor))

cfg.tooltipPos = "ANCHOR_TOP"
if cfg.core.position ~= "BOTTOM" then
	cfg.tooltipPos = "ANCHOR_BOTTOM",0,-20
end


local SX_databarConfig = CreateFrame("Frame",nil, UIParent)

SX_databarConfig:SetPoint("CENTER")
--SX_databarConfig:Hide()

cfg.SXconfigFrame = nil
if cfg.useConfig then
	cfg.SXconfigFrame = SX_databarConfig
end

local eventframe = CreateFrame("Frame",nil, UIParent)
eventframe:RegisterEvent("PET_BATTLE_OPENING_START")
eventframe:RegisterEvent("PET_BATTLE_CLOSE")
eventframe:SetScript("OnEvent", function(self,event, ...)
	if (event == "PET_BATTLE_OPENING_START") then
		SX_bottombar:Hide()
	elseif (event == "PET_BATTLE_CLOSE") then
		SX_bottombar:Show()
	end
end)
---------------------------------------------
-- SAVED VARIABLES TABLE
---------------------------------------------

-- copies missing fields from source table
function CopyTable(src, dest)
    if type(dest) ~= "table" then
        dest = {}
    end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = CopyTable(v, dest[k])
        elseif type(v) ~= type(dest[k]) then
            dest[k] = v
        end
    end

    return dest
end

-- removes everything that is present in source table from another table
function DiffTable(src, dest)
    if type(dest) ~= "table" then
        return {}
    end

    if type(src) ~= "table" then
        return dest
    end

    for k, v in pairs(dest) do
        if type(v) == "table" then
            if not next(DiffTable(src[k], v)) then
                dest[k] = nil
            end
        elseif v == src[k] then
            dest[k] = nil
        end
    end

    return dest
end

local function ConvertDateToNumber(month, day, year)
    month = gsub(month, "(%d)(%d?)", function(d1, d2) return d2 == "" and "0"..d1 or d1..d2 end) -- converts M to MM
    day = gsub(day, "(%d)(%d?)", function(d1, d2) return d2 == "" and "0"..d1 or d1..d2 end) -- converts D to DD

    return tonumber(year..month..day)
end

--------------
-- DEFAULTS --
--------------

local D = {
    ["money_related_stuff"] = {}
}

-----------
-- STUFF --
-----------

local function Controller_OnEvent(self, event, arg)
    if event == "ADDON_LOADED" and arg == addon then -- "test" is addon name
local CONFIG = CopyTable(D, TEST_CONFIG)
ns.CONFIG = CONFIG -- makes this table available throughout addon

local playerName, playerFaction, playerRealm = UnitName("player"), UnitFactionGroup("player"), GetRealmName()

if not CONFIG["money_related_stuff"][playerRealm] then
    CONFIG["money_related_stuff"][playerRealm] = {} -- creates a table if it doesn't exist
end

local realmData = CONFIG["money_related_stuff"][playerRealm] -- just an alias
ns.realmData = realmData

if not realmData[playerFaction] then
    realmData[playerFaction] = {} -- creates a table if it doesn't exist
end

local factionData = realmData[playerFaction]
ns.factionData = factionData

if not factionData[playerName] then
    factionData[playerName] = {} -- creates a table if it doesn't exist
end

ns.playerData = factionData[playerName]

self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        local playerData = ns.playerData

		if not playerData["CLASS"] then
			playerData["CLASS"] = cfg.CLASS
		end

        local weekday, month, day, year = CalendarGetDate()
        local today = ConvertDateToNumber(month, day, year)
        local updateData

        if playerData.lastLoginDate then
            if playerData.lastLoginDate < today then -- is true, if last time player logged in was the day before or even earlier
                playerData.lastLoginDate = today
                updateData = true
            end
        else
            playerData.lastLoginDate = today
            updateData = true
        end

        if updateData then -- daily updates
            if playerData["money_on_first_weekday"] then
                if weekday == cfg.gold.firstWeekday then -- 1 is Sunday, 2 is Monday, different countries have different first day of the week
                    playerData["money_on_first_weekday"] = GetMoney()
                end
            else
                playerData["money_on_first_weekday"] = GetMoney()
            end

            playerData["money_on_first_login_today"] = GetMoney()
        end

        playerData["money_on_session_start"] = GetMoney() -- this one resets on every single login or UI reload

        self:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "PLAYER_LOGOUT" then
        TEST_CONFIG = DiffTable(D, ns.CONFIG) -- writes data into TEST_CONFIG table
    end
end

local Controller = CreateFrame("Frame")
Controller:RegisterEvent("ADDON_LOADED")
Controller:RegisterEvent("PLAYER_LOGIN")
Controller:RegisterEvent("PLAYER_LOGOUT")
Controller:SetScript("OnEvent", Controller_OnEvent)

---------------------------------------------
-- SHORTENER FUNCTIONS
---------------------------------------------
cfg.specCoords = {
--	 index	 left	right	top		bottom
	[ 1] = { 0.00,	0.25,	0.00,	1 },
	[ 2] = { 0.25,	0.50,	0.00,	1 },
	[ 3] = { 0.50,	0.75,	0.00,	1 },
	[ 4] = { 0.75,	1.00,	0.00,	1 },
}

cfg.SVal = function(val)
	if val > 1E10 then
		return (floor(val/1E9)).."b"
	elseif val > 1E9 then
		return (floor((val/1E9)*10)/10).."b"
	elseif val > 1E7 then
		return (floor(val/1E6)).."m"
	elseif val > 1E6 then
		return (floor((val/1E6)*10)/10).."m"
	elseif val > 1E4 then
		return (floor(val/1E3)).."k"
	elseif val >= 1E3 then
		return (floor(val/1E3)) .. (" %03d"):format(val % 1E3)
	else
		return val
	end
end

function cfg.hex(r, g, b)
	if r then
		if (type(r) == "table") then
			if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	end
end
