local addOnName, XB = ...;

local Mm = XB:RegisterModule("MicroMenu")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT
local mb_config
local groupFrame, moduleFrames, moduleIcons
local Bar, BarFrame
local microMenuElements, microMenuElementsTexts

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
----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local mm_default = {
    profile = {
        enable = {
            group = false,
            character = false,
            spellbook = false,
            talents = false,
            achievements = false,
            quests = false,
            lfg = false,
            pvp = false,
            collections = false,
            adventure = false,
            shop = false,
            help = false
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
	moduleFrames[element]:SetSize(w, h)
	moduleFrames[element]:SetPoint(a,x,y)
	moduleFrames[element]:Show()
	
	moduleIcons[element] = moduleIcons[element] or moduleFrames[element]:CreateTexture(nil,"OVERLAY",nil,7)
	moduleIcons[element]:SetSize(w,h)
	moduleIcons[element]:SetPoint("CENTER")
	moduleIcons[element]:SetTexture(XB.menuIcons[element])
	moduleIcons[element]:SetVertexColor(unpack(color))
	
	moduleFrames[element]:SetScript("OnEnter",function() 
		moduleIcons[element]:SetVertexColor(unpack(hover))
		if self.settings.tooltip[element] then
			tooltip(element);
		end
	end);
	moduleFrames[element]:SetScript("OnLeave",function() moduleIcons[element]:SetVertexColor(unpack(color)) end);
end


--[[function MenuModule:GetName()
  return L['Micromenu'];
end

function MenuModule:OnInitialize()
  self.LTip=LibStub('LibQTip-1.0')
  self.mediaFolder = xb.constants.mediaPath..'microbar\\'
  self.socialIconPath = "Interface\\FriendsFrame\\"
  self.icons = {}
  self.modifiers={SHIFT_KEY_TEXT,ALT_KEY_TEXT,CTRL_KEY_TEXT}
  self.frames = {}
  self.text = {}
  self.bgTexture = {}
  self.functions = {}
  self.menuWidth = 0
  self.iconSize = xb:GetHeight();
  self:CreateClickFunctions()
end

function MenuModule:OnEnable()
  if not xb.db.profile.modules.microMenu.enabled then return; end
  if self.microMenuFrame == nil then
    self.microMenuFrame = CreateFrame("FRAME", L['Micromenu'], xb:GetFrame('bar'))
    xb:RegisterFrame('microMenuFrame', self.microMenuFrame)
  end

  self.microMenuFrame:Show()

  if not self.frames.menu then
	self:CreateFrames()
	self:RegisterFrameEvents()
	self:CreateIcons()
  end
  xb:Refresh()
end

function MenuModule:OnDisable()
  self.microMenuFrame:Hide()
  self:UnregisterFrameEvents()
  xb:Refresh()
end

function MenuModule:Refresh()
  if not xb.db.profile.modules.microMenu.enabled then self:Disable(); return; end
  
  if self.frames.menu == nil then return; end

  if InCombatLockdown() then
    self:RegisterEvent('PLAYER_REGEN_ENABLED', function()
      self:Refresh()
      self:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end)
    return
  end

  self.modifier=self.modifiers[xb.db.profile.modules.microMenu.modifierTooltip];

  self.iconSize = xb:GetHeight();

  local colors = xb.db.profile.color
  local totalWidth = 0;
  for name, frame in pairs(self.frames) do
    self:IconDefaults(name)
    if name == 'menu' then
      frame:SetPoint("LEFT", xb.db.profile.modules.microMenu.iconSpacing, 0)
      totalWidth = totalWidth + frame:GetWidth() + xb.db.profile.modules.microMenu.iconSpacing
    elseif frame:GetParent():GetName() == 'menu' then
      frame:SetPoint("LEFT", frame:GetParent(), "RIGHT", xb.db.profile.modules.microMenu.mainMenuSpacing, 0)
      totalWidth = totalWidth + frame:GetWidth() + xb.db.profile.modules.microMenu.mainMenuSpacing
    else
      frame:SetPoint("LEFT", frame:GetParent(), "RIGHT", xb.db.profile.modules.microMenu.iconSpacing, 0)
      totalWidth = totalWidth + frame:GetWidth() + xb.db.profile.modules.microMenu.iconSpacing
    end
  end
  self.microMenuFrame:SetPoint("LEFT", xb.db.profile.general.barPadding, 0)
  self.microMenuFrame:SetSize(totalWidth, xb:GetHeight())

  for name, frame in pairs(self.text) do
    frame:SetFont(xb:GetFont(xb.db.profile.text.smallFontSize))
    frame:SetPoint('CENTER', self.frames[name], xb.miniTextPosition)
    self.bgTexture[name]:SetColorTexture(xb.db.profile.color.barColor.r, xb.db.profile.color.barColor.g, xb.db.profile.color.barColor.b, xb.db.profile.color.barColor.a)
    self.bgTexture[name]:SetPoint('CENTER', frame, 'CENTER')
    if xb.db.profile.modules.microMenu.hideSocialText then
      frame:Hide()
	else
	  frame:Show()
    end
  end

  self:UpdateFriendText()
  self:UpdateGuildText()
end

function MenuModule:UpdateMenu()
	for _,frame in pairs(self.frames) do
		frame:Hide()
	end
	self:UnregisterFrameEvents()
	self:CreateFrames()
	self:CreateIcons()
	self:RegisterFrameEvents()
end


function MenuModule:CreateClickFunctions()
  if self.functions.menu ~= nil then return; end

  self.functions.menu = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleFrame(GameMenuFrame)
    elseif button == "RightButton" then
      if IsShiftKeyDown() then
        ReloadUI()
      else
        ToggleFrame(AddonList)
      end
    end
  end; --menu

  self.functions.chat = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
      if ChatMenu:IsVisible() then
		ChatMenu:Hide()
	  else
	    ChatFrame_OpenMenu()
	  end
    end
  end; --chat

  self.functions.guild = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleGuildFrame()
      if IsInGuild() then
        GuildFrameTab2:Click()
      end
    end
  end; --guild

  self.functions.social = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleFriendsFrame()
    end
  end; --social

  self.functions.char = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleCharacter("PaperDollFrame")
    end
  end; --char

  self.functions.spell = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleFrame(SpellBookFrame)
  	end
  end; --spell

  self.functions.talent = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleTalentFrame()
  	end
  end; --talent

  self.functions.journal = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleEncounterJournal()
  	end
  end; --journal

  self.functions.lfg = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleLFDParentFrame()
  	end
  end; --lfg

  self.functions.pet = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleCollectionsJournal()
  	end
  end; --pet

  self.functions.ach = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleAchievementFrame()
  	end
  end; --ach

  self.functions.quest = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleQuestLog()
  	end
  end; --quest

  self.functions.pvp = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		TogglePVPUI()
  	end
  end; --pvp

  self.functions.shop = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleStoreUI()
  	end
  end; --shop

  self.functions.help = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleHelpFrame()
  	end
  end; --help
end

]]
