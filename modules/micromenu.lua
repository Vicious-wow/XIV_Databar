local addOnName, XB = ...;

local Mm = XB:RegisterModule("MicroMenu")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT
local mm_config
local groupFrame, moduleFrames, moduleIcons
local Bar, BarFrame
local microMenuElements, microMenuElementsTexts, microMenuElementsFunctions

moduleFrames, moduleIcons = {}, {}
microMenuElements = {"character","spellbook","talents","achievements","quests","lfg","pvp","collections","adventure","shop","help"}
microMenuElementsTexts = {CHARACTER_BUTTON, SPELLBOOK_ABILITIES_BUTTON, TALENTS_BUTTON, ACHIEVEMENT_BUTTON, QUESTLOG_BUTTON, DUNGEONS_BUTTON, PVP, COLLECTIONS, ADVENTURE_JOURNAL, BLIZZARD_STORE, GAMEMENU_HELP}

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function refreshOptions()
    Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
end

local function tooltip(element)
    if libTT:IsAcquired("MicroMenuTip"..element) then
        libTT:Release(libTT:Acquire("MicroMenuTip"..element))
    end
    local tooltip = libTT:Acquire("MicroMenuTip"..element, 1, "LEFT")
    tooltip:SmartAnchorTo(moduleFrames[element])
	  tooltip:SetAutoHideDelay(.1, moduleFrames[element])
    local text = ""
    
	for index,val in ipairs(microMenuElements) do
		if val == element then
			text = microMenuElementsTexts[index]
			break;
		end
	end
	
	tooltip:AddHeader('[|cff6699FF'..text..'|r]')
    XB:SkinTooltip(tooltip,"MicroMenuTip"..element)
    tooltip:Show()
end

-- Because the following unit functions might change 
local function characterClick()
  ToggleFrame(CharacterFrame);
end

local function spellbookClick()
  ToggleFrame(SpellBookFrame);
end

local function talentsClick()
  ToggleTalentFrame(1);
end

local function achievementsClick()
  ToggleAchievementFrame();
end

local function adventureClick()
  ToggleEncounterJournal();
end

local function questsClick()
  ToggleQuestLog();
end

local function lfgClick()
  ToggleLFDParentFrame();
end

local function pvpClick()
  TogglePVPUI();
end

local function collectionsClick()
  ToggleCollectionsJournal(Mm.settings.collectionsTab)
end

local function storeClick()
  ToggleStoreUI();
end

local function helpClick()
  ToggleHelpFrame();
end

-- Have to move this initialization here, otherwhise functions not defined
microMenuElementsFunctions = {characterClick,spellbookClick,talentsClick,achievementsClick,questsClick,lfgClick,pvpClick,collectionsClick,adventureClick,storeClick,helpClick}

local function clickFunction(element) 
  local index = xb_tContains(microMenuElements,element);
  if index then
    microMenuElementsFunctions[index]();
  end
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local mm_default = {
    profile = {
        enable = {
            group = true,
            character = true,
            spellbook = true,
            talents = true,
            achievements = true,
            quests = true,
            lfg = true,
            pvp = true,
            collections = true,
            adventure = true,
            shop = true,
            help = true
        },
        lock = true,
        x = {
            group = 174,
            character = 0,
            spellbook = 36,
            talents = 72,
            achievements = 108,
            quests = 144,
            lfg = 180,
            pvp = 216,
            collections = 252,
            adventure = 288,
            shop = 324,
            help = 360
        },
        y = {
            group = 0,
            character = 0,
            spellbook = 0,
            talents = 0,
            achievements = 0,
            quests = 0,
            lfg = 0,
            pvp = 0,
            collections = 0,
            adventure = 0,
            shop = 0,
            help = 0
        },
        w = {
            group = 392,
            character = 32,
            spellbook = 32,
            talents = 32,
            achievements = 32,
            quests = 32,
            lfg = 32,
            pvp = 32,
            collections = 32,
            adventure = 32,
            shop = 32,
            help = 32
        },
        h = {
            group = 32,
            character = 32,
            spellbook = 32,
            talents = 32,
            achievements = 32,
            quests = 32,
            lfg = 32,
            pvp = 32,
            collections = 32,
            adventure = 32,
            shop = 32,
            help = 32
        },
        anchor = {
			group = "LEFT",
			character = "LEFT",
			spellbook = "LEFT",
			talents = "LEFT",
			achievements = "LEFT",
			quests = "LEFT",
			lfg = "LEFT",
			pvp = "LEFT",
			collections = "LEFT",
			adventure = "LEFT",
			shop = "LEFT",
			help = "LEFT"
		},
        combatEn = false,
        tooltip = {
            group = true,
            character = true,
            spellbook = true,
            talents = true,
            achievements = true,
            quests = true,
            lfg = true,
            pvp = true,
            collections = true,
            adventure = true,
            shop = true,
            help = true
        },
        color = {
            group = {1,1,1,.75},
            character = {1,1,1,.75},
            spellbook = {1,1,1,.75},
            talents = {1,1,1,.75},
            achievements = {1,1,1,.75},
            quests = {1,1,1,.75},
            lfg = {1,1,1,.75},
            pvp = {1,1,1,.75},
            collections = {1,1,1,.75},
            adventure = {1,1,1,.75},
            shop = {1,1,1,.75},
            help = {1,1,1,.75}
        },
        colorCC = false,
        hover = {
            group = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            character = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            spellbook = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            talents = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            achievements = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            quests = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            lfg = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            pvp = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            collections = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            adventure = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            shop = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
            help = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75}
        },
        hoverCC = not (XB.playerClass == "PRIEST"),
        collectionsTab = 1
    }
}

mm_config ={

}

----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Mm:OnInitialize()
    libTT = LibStub('LibQTip-1.0')
    self.db = XB.db:RegisterNamespace("MicroMenu", mm_default)
    self.settings = self.db.profile
end

function Mm:OnEnable()
    Mm.settings.lock = Mm.settings.lock or not Mm.settings.lock --Locking frame if it was not locked on reload/relog
    refreshOptions()
    XB.Config:Register("Micro Menu",mm_config)
    if self.settings.enable then
        self:CreateFrames()
    else
        self:Disable()
    end
end

function Mm:OnDisable()

end

function Mm:CreateFrames()
    self:CreateGroupFrame()
    for _,element in ipairs(microMenuElements) do
		self:CreateElementFrame(element)
	end
end

function Mm:CreateGroupFrame()
	if not self.settings.enable.group then
		if groupFrame and groupFrame:IsVisible() then
			groupFrame:Hide()
		end
		return
	end

	local x,y,w,h,a = self.settings.x.group,self.settings.y.group,self.settings.w.group,self.settings.h.group,self.settings.anchor.group
	groupFrame = groupFrame or CreateFrame("Frame","MicromenuGroup",BarFrame)
	groupFrame:SetSize(w, h)
	groupFrame:SetPoint(a,x,y)
	groupFrame:SetMovable(true)
	groupFrame:SetClampedToScreen(true)
	groupFrame:Show()
	XB:AddOverlay(self,groupFrame,a)
	
	if not self.settings.lock then
		groupFrame.overlay:Show()
		groupFrame.overlay.anchor:Show()
	else
		groupFrame.overlay:Hide()
		groupFrame.overlay.anchor:Hide()
	end
end

function Mm:CreateElementFrame(element)
	if not self.settings.enable[element] then
		if moduleFrames[element] and moduleFrames[element]:IsVisible() then
			moduleFrames[element]:Hide()
		end
		return
	end
	
	local x,y,w,h,a,color,hover = self.settings.x[element],self.settings.y[element],self.settings.w[element],self.settings.h[element],self.settings.anchor[element],self.settings.color[element],self.settings.hover[element]
	moduleFrames[element] = moduleFrames[element] or CreateFrame("Frame", element.."Frame",groupFrame)
  local frame = moduleFrames[element];
	frame:SetSize(w, h)
	frame:SetPoint(a,x,y)
	frame:EnableMouse(true)
	frame:Show()
	
	moduleIcons[element] = moduleIcons[element] or frame:CreateTexture(nil,"OVERLAY",nil,7)
  local icon = moduleIcons[element];
	icon:SetSize(w,h)
	icon:SetPoint("CENTER")
	icon:SetTexture(XB.menuIcons[element])
	icon:SetVertexColor(unpack(color))
	
	frame:SetScript("OnEnter",function() 
		icon:SetVertexColor(unpack(hover))
		if self.settings.tooltip[element] then
			tooltip(element);
		end
	end);
	frame:SetScript("OnLeave",function() icon:SetVertexColor(unpack(color)) end);

  if frame:HasScript("OnMouseUp") and frame:GetScript("OnMouseUp") == clickFunction then return; end
  
    frame:SetScript("OnMouseUp",function() clickFunction(element) end);
end
