local addOnName, XB = ...;

local Profession = XB:RegisterModule(TRADE_SKILLS)

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT
local profession_config
local Bar, BarFrame
local professionsGroupFrame
local professionFrames, professionFramesNames = {},{}
local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
local learnedProfs = {prof1,prof2,archaeology,fishing,cooking}-- firstAid is since BfA tailoring specific; value should always be nil
local profIcons = {
    [164] = 'blacksmithing',
    [165] = 'leatherworking',
    [171] = 'alchemy',
    [182] = 'herbalism',
    [186] = 'mining',
    [202] = 'engineering',
    [333] = 'enchanting',
    [755] = 'jewelcrafting',
    [773] = 'inscription',
    [197] = 'tailoring',
    [393] = 'skinning'
}

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function tooltip(hoveredFrame)
	if libTT:IsAcquired("ProfessionsTooltip") then
		libTT:Release(libTT:Acquire("ProfessionsTooltip"))
	end

	local tooltip = libTT:Acquire("ProfessionsTooltip", 2)
	tooltip:SmartAnchorTo(hoveredFrame)
	tooltip:SetAutoHideDelay(.5, hoveredFrame)
	tooltip:AddHeader("[|cff6699FF"..TRADE_SKILLS.."|r]")
	tooltip:AddLine(" ")
	for k,v in pairs(learnedProfs) do
		local profName, _, profRank, profMaxRank, _,  _, _, _, _, _, _ = GetProfessionInfo(v)
		if profRank < profMaxRank then
			tooltip:AddLine(string.format(TRADESKILL_NAME_RANK,profName,profRank,profMaxRank))
		end
	end

	tooltip:Show()
end

--Remember daily or weekly CD's
local function refreshOptions()
  Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local profession_default = {
  profile = {
    enable = true,
    combatEn = false,
    lock = true,
    x = {
        group = 110,
        firstProf = 0,
        secProf = 100
    },
    y = {
        group = 0,
        firstProf = 0,
        secProf = 0
    },
    w = {
        group = 16,
        firstProf = 16,
        secProf = 16
    },
    h = {
        group = 16,
        firstProf = 16,
        secProf = 16
    },
    anchor = {
        group = "CENTER",
        firstProf = "LEFT",
        secProf = "LEFT"
    },
    spaceBetween2Profs = 10,
    color = {
        group = {1,1,1,.75},
        firstProf = {1,1,1,.75},
        secProf = {1,1,1,.75}
    },
    hover = {
        group = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
        firstProf = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
        secProf = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75}
    },
    hoverCC = not (XB.playerClass == "PRIEST"),
    barProfs = {prof1,prof2} 
  }
}


----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Profession:OnInitialize()
	libTT = LibStub('LibQTip-1.0')
	self.db = XB.db:RegisterNamespace("Profession", profession_default)
    self.settings = self.db.profile
end

function Profession:OnEnable()
  Profession.settings.lock = Profession.settings.lock or not Profession.settings.lock --Locking frame if it was not locked on reload/relog
  refreshOptions()
  XB.Config:Register("Profession",profession_config)
  if self.settings.enable and not self:IsEnabled() then
    self:Enable()
  elseif not self.settings.enable and self:IsEnabled() then
    self:Disable()
  else
    self:CreateFrames()
  end
end

function Profession:OnDisable()
  
end


function Profession:CreateFrames()
	self:CreateGroupFrame()
	for i,v in ipairs(self.settings.barProfs) do
		self:CreateProfessionFrame(v,i)
	end
end

function Profession:CreateGroupFrame()
    if not self.settings.enable then
    if professionsGroupFrame and professionsGroupFrame:IsVisible() then
      professionsGroupFrame:Hide()
    end
    return
  end
  
  local w,h,x,y,a,color,hover = self.settings.w.group,self.settings.h.group,self.settings.x.group,self.settings.y.group,self.settings.anchor.group,self.settings.color.group,self.settings.hover.group
  
  professionsGroupFrame = professionsGroupFrame or CreateFrame("Frame",TRADE_SKILLS,BarFrame)
  professionsGroupFrame:ClearAllPoints()
  professionsGroupFrame:SetSize(w, h)
  professionsGroupFrame:SetPoint(a,x,y)
  professionsGroupFrame:EnableMouse(true)
  professionsGroupFrame:SetMovable(true)
  professionsGroupFrame:SetClampedToScreen(true)
  professionsGroupFrame:Show()


  professionsGroupFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  professionsGroupFrame:RegisterEvent("SPELLS_CHANGED")
  --professionsGroupFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")

  professionsGroupFrame:SetScript("OnEvent",function(_,event,...)
  	prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
  	self.settings.barProfs = {prof1,prof2}
	for i,v in ipairs(self.settings.barProfs) do
		if not professionFrames["Profession"..v] then
			self:CreateProfessionFrame(v,i)
		end
	end
  end)

  XB:AddOverlay(self,professionsGroupFrame,a)

    if not self.settings.lock then
      professionsGroupFrame.overlay:Show()
        professionsGroupFrame.overlay.anchor:Show()
    else
        professionsGroupFrame.overlay:Hide()
        professionsGroupFrame.overlay.anchor:Hide()
    end
end

function Profession:CreateProfessionFrame(wowProfId,index)
	local frameSettingsName = index == 1 and "firstProf" or index == 2 and "secProf"
	if not frameSettingsName then return end --asserts the use of 2 frames per professionFrame
	local w,h,x,y,a,color,hover = self.settings.w[frameSettingsName],self.settings.h[frameSettingsName],self.settings.x[frameSettingsName],self.settings.y[frameSettingsName],self.settings.anchor[frameSettingsName],self.settings.color[frameSettingsName],self.settings.hover[frameSettingsName]

  local profName, _, profRank, profMaxRank, _,  spellOffset, skillLine, skillModifier, specIndex, specOffset, rankName = GetProfessionInfo(wowProfId)
  local spellName, subSpellName = GetSpellBookItemName(spellOffset + 1, BOOKTYPE_PROFESSION)
  profName = string.upper(profName)
  --local x, y = 90,0


  ----------------------------------------
  --BEWARE
  ----------------------------------------
  --if professionFrames["Profession"..index] then return end 
  ----------------------------------------
  --
  ----------------------------------------
  professionFrames["Profession"..wowProfId] = professionFrames["Profession"..wowProfId] or CreateFrame("BUTTON","Profession"..wowProfId, professionsGroupFrame,'SecureActionButtonTemplate')
  local profFrame = professionFrames["Profession"..wowProfId]
  profFrame:ClearAllPoints()
  profFrame:SetPoint("LEFT",professionsGroupFrame,"CENTER",(index-1)*x,y)
  profFrame:EnableMouse(true)
  profFrame:SetSize(16,16)
  profFrame:RegisterForClicks("AnyUp")
  profFrame:SetAttribute('*type1', 'spell')
  profFrame:SetAttribute('unit', 'player')
  profFrame:SetAttribute('spell', spellName)

  local profIcon = profFrame:CreateTexture(nil,"OVERLAY",nil,7)
  profIcon:SetSize(16, 16)
  profIcon:SetPoint("LEFT")
  profIcon:SetVertexColor(unpack(color))
  profIcon:SetTexture(XB.mediaFold..'profession\\'..profIcons[skillLine])

  local profText = profFrame:CreateFontString(nil, "OVERLAY")
  profText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf", 12)
  profText:SetPoint("RIGHT",profFrame,2,0)
  profText:SetTextColor(unpack(color))
  profText:SetText(profName)
  profFrame:SetSize(profText:GetStringWidth()+profIcon:GetWidth()+5,h)

  if profRank ~= profMaxRank then 
	local profStatusbar = CreateFrame("StatusBar", "Profession"..index.."Status", profFrame)
	profStatusbar:SetStatusBarTexture(1,1,1)
	profStatusbar:SetStatusBarColor(unpack(hover))
	profStatusbar:SetPoint("TOPLEFT", profText, "BOTTOMLEFT",0,-2)

	local profStatusbarBG = profStatusbar:CreateTexture(nil,"BACKGROUND",nil,7)
	profStatusbarBG:SetPoint("TOPLEFT", profText, "BOTTOMLEFT",0,-2)
	profStatusbarBG:SetColorTexture(unpack(color))

	profStatusbar:SetMinMaxValues(0, profMaxRank)
	profStatusbar:SetValue(profRank)
	profStatusbar:SetSize(profText:GetStringWidth(),3)
	profStatusbarBG:SetSize(profText:GetStringWidth(),3)
  end

  profFrame:SetScript("OnEnter", function()
    if InCombatLockdown() then return end
    tooltip(profFrame)
    profText:SetTextColor(unpack(hover))
    --profIcon:SetVertexColor(unpack(hover))
    --profStatusbar:SetStatusBarColor(unpack(hover))
  end)

  profFrame:SetScript("OnLeave", function() 
    profText:SetTextColor(unpack(color))
    --profStatusbar:SetStatusBarColor(unpack(color))
  end)
end

--[[

function TradeskillModule:OnEnable()
  if self.tradeskillFrame == nil then
    self.tradeskillFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
    xb:RegisterFrame('tradeskillFrame', self.tradeskillFrame)
  end

  self.tradeskillFrame:Show()

  local prof1, prof2, _ = GetProfessions()
  self.prof1 = prof1
  self.prof2 = prof2

  self:CreateFrames()
  self:RegisterFrameEvents()
  self:Refresh()
end

function TradeskillModule:OnDisable()
  self.tradeskillFrame:Hide()
  self:UnregisterEvent('TRADE_SKILL_UPDATE')
  self:UnregisterEvent('SPELLS_CHANGED')
  self:UnregisterEvent('UNIT_SPELLCAST_STOP')
end

function TradeskillModule:UpdateProfValues()
  if self.prof1 then
    local _, _, skill, cap, _ = GetProfessionInfo(self.prof1)
    self.firstProfBar:SetMinMaxValues(1, cap)
    self.firstProfBar:SetValue(skill)
  end

  if self.prof2 then
    local _, _, skill, cap, _ = GetProfessionInfo(self.prof2)
    self.secondProfBar:SetMinMaxValues(1, cap)
    self.secondProfBar:SetValue(skill)
  end
end

function TradeskillModule:Refresh()
  if InCombatLockdown() then
    self:UpdateProfValues()
    return
  end
  local db = xb.db.profile
  if self.tradeskillFrame == nil then return; end
  if not db.modules.tradeskill.enabled then self:Disable(); return; end
  local iconSize = db.text.fontSize + db.general.barPadding

  local totalWidth = 0

  if self.prof1 then
    self:StyleTradeskillFrame('firstProf', self.prof1)
    totalWidth = totalWidth + self.firstProfFrame:GetWidth()
    self.firstProfFrame:SetPoint('LEFT')
  end

  if self.prof2 then
    self:StyleTradeskillFrame('secondProf', self.prof2)
    totalWidth = totalWidth + self.secondProfFrame:GetWidth()
    self.secondProfFrame:SetPoint('LEFT', self.firstProfFrame, 'RIGHT', 5, 0)
  end

  if self.prof1 or self.prof2 then

    self:UpdateProfValues()

    self.tradeskillFrame:SetSize(totalWidth, xb:GetHeight())

    --self.tradeskillFrame:SetSize(self.goldButton:GetSize())

    local relativeAnchorPoint = 'RIGHT'
    local xOffset = db.general.moduleSpacing
    if not xb:GetFrame('clockFrame'):IsVisible() then
      relativeAnchorPoint = 'LEFT'
      xOffset = 0
    end
    self.tradeskillFrame:SetPoint('LEFT', xb:GetFrame('clockFrame'), relativeAnchorPoint, xOffset, 0)
  else
    self.tradeskillFrame:Hide()
  end
end

function TradeskillModule:StyleTradeskillFrame(framePrefix, profIndex)
  local db = xb.db.profile
  local iconSize = db.text.fontSize + db.general.barPadding
  local name, _, skill, cap, _, spellOffset, skillLine, _ = GetProfessionInfo(profIndex)
  local icon = xb.constants.mediaPath..'profession\\'..self.profIcons[skillLine]

  local textHeight = floor((xb:GetHeight() - 4) / 2)
  if skill == cap then
    textHeight = db.text.fontSize
  end

  local barHeight = (iconSize - textHeight - 2)
  if barHeight < 2 then
    barHeight = 2
  end

  self[framePrefix..'Icon']:SetTexture(icon)
  self[framePrefix..'Icon']:SetSize(iconSize, iconSize)
  self[framePrefix..'Icon']:SetPoint('LEFT')
  self[framePrefix..'Icon']:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

  self[framePrefix..'Text']:SetFont(xb:GetFont(textHeight))
  self[framePrefix..'Text']:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  self[framePrefix..'Text']:SetText(string.upper(name))

  if skill == cap then
    self[framePrefix..'Text']:SetPoint('LEFT', self[framePrefix..'Icon'], 'RIGHT', 5, 0)
  else
    self[framePrefix..'Text']:SetPoint('TOPLEFT', self[framePrefix..'Icon'], 'TOPRIGHT', 5, 0)
    self[framePrefix..'Bar']:SetStatusBarTexture(1, 1, 1)
    if db.modules.tradeskill.barCC then
      self[framePrefix..'Bar']:SetStatusBarColor(xb:GetClassColors())
    else
      self[framePrefix..'Bar']:SetStatusBarColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
    end
    self[framePrefix..'Bar']:SetSize(self[framePrefix..'Text']:GetStringWidth(), barHeight)
    self[framePrefix..'Bar']:SetPoint('BOTTOMLEFT', self[framePrefix..'Icon'], 'BOTTOMRIGHT', 5, 0)

    self[framePrefix..'BarBg']:SetAllPoints()
    self[framePrefix..'BarBg']:SetColorTexture(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  end
  self[framePrefix..'Frame']:SetSize(iconSize + self[framePrefix..'Text']:GetStringWidth() + 5, xb:GetHeight())

  local spellName, subSpellName = GetSpellBookItemName(spellOffset + 1, BOOKTYPE_PROFESSION)
  self[framePrefix..'Frame']:SetAttribute('spell', spellName) --- While this is usually the type of thing I'd put into RegisterFrameEvents(), I need it to update
end

function TradeskillModule:CreateFrames()
  self.firstProfFrame = self.firstProfFrame or CreateFrame("BUTTON", nil, self.tradeskillFrame, 'SecureActionButtonTemplate')
  self.firstProfIcon = self.firstProfIcon or self.firstProfFrame:CreateTexture(nil, 'OVERLAY')
  self.firstProfText = self.firstProfText or self.firstProfFrame:CreateFontString(nil, 'OVERLAY')
  self.firstProfBar = self.firstProfBar or CreateFrame('STATUSBAR', nil, self.firstProfFrame)
  self.firstProfBarBg = self.firstProfBarBg or self.firstProfBar:CreateTexture(nil, 'BACKGROUND')

  self.secondProfFrame = self.secondProfFrame or CreateFrame("BUTTON", nil, self.tradeskillFrame, 'SecureActionButtonTemplate')
  self.secondProfIcon = self.secondProfIcon or self.secondProfFrame:CreateTexture(nil, 'OVERLAY')
  self.secondProfText = self.secondProfText or self.secondProfFrame:CreateFontString(nil, 'OVERLAY')
  self.secondProfBar = self.secondProfBar or CreateFrame('STATUSBAR', nil, self.secondProfFrame)
  self.secondProfBarBg = self.secondProfBarBg or self.secondProfBar:CreateTexture(nil, 'BACKGROUND')
end

function TradeskillModule:RegisterFrameEvents()

  self:RegisterEvent('TRADE_SKILL_UPDATE', 'Refresh')
  self:RegisterEvent('SPELLS_CHANGED', 'Refresh')
  self.tradeskillFrame:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
  self.tradeskillFrame:SetScript('OnEvent', function(_, event)
    if event == 'UNIT_SPELLCAST_STOP' then
      self:Refresh()
    end
  end)

  self.firstProfFrame:EnableMouse(true)
  self.firstProfFrame:RegisterForClicks('AnyUp')

  self.firstProfFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    self.firstProfText:SetTextColor(unpack(xb:HoverColors()))
    if xb.db.profile.modules.tradeskill.showTooltip then
      self:ShowTooltip()
    end
  end)
  self.firstProfFrame:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    local db = xb.db.profile
    self.firstProfText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    if xb.db.profile.modules.tradeskill.showTooltip then
      GameTooltip:Hide()
    end
  end)
  self.firstProfFrame:SetAttribute('*type1', 'spell')
  self.firstProfFrame:SetAttribute('unit', 'player')

  self.secondProfFrame:EnableMouse(true)
  self.secondProfFrame:RegisterForClicks('AnyUp')

  self.secondProfFrame:SetScript('OnEnter', function()
    if InCombatLockdown() then return; end
    self.secondProfText:SetTextColor(unpack(xb:HoverColors()))
    if xb.db.profile.modules.tradeskill.showTooltip then
      self:ShowTooltip()
    end
  end)
  self.secondProfFrame:SetScript('OnLeave', function()
    if InCombatLockdown() then return; end
    local db = xb.db.profile
    self.secondProfText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
    if xb.db.profile.modules.tradeskill.showTooltip then
      GameTooltip:Hide()
    end
  end)
  self.secondProfFrame:SetAttribute('*type1', 'spell')
  self.secondProfFrame:SetAttribute('unit', 'player')

  self.tradeskillFrame:EnableMouse(true)
  self.tradeskillFrame:SetScript('OnEnter', function()
    if xb.db.profile.modules.tradeskill.showTooltip then
      self:ShowTooltip()
    end
  end)
  self.tradeskillFrame:SetScript('OnLeave', function()
    if xb.db.profile.modules.tradeskill.showTooltip then
      GameTooltip:Hide()
    end
  end)

  self:RegisterMessage('XIVBar_FrameHide', function(_, name)
    if name == 'clockFrame' then
      self:Refresh()
    end
  end)

  self:RegisterMessage('XIVBar_FrameShow', function(_, name)
    if name == 'clockFrame' then
      self:Refresh()
    end
  end)
end

function TradeskillModule:ShowTooltip()
  return
  GameTooltip:SetOwner(self.tradeskillFrame, 'ANCHOR_'..xb.miniTextPosition)
  GameTooltip:AddLine("[|cff6699FF"..L['Cooldowns'].."|r]")
  GameTooltip:AddLine(" ")

  local recipeIds = C_TradeSkillUI.GetAllRecipeIDs()

  GameTooltip:AddLine(" ")
  GameTooltip:AddDoubleLine('<'..L['Left-Click']..'>', BINDING_NAME_TOGGLECURRENCY, 1, 1, 0, 1, 1, 1)
  GameTooltip:Show()
end

function TradeskillModule:GetDefaultOptions()
  return 'tradeskill', {
      enabled = true,
      barCC = false,
      showTooltip = true
    }
end

function TradeskillModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.tradeskill.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.tradeskill.enabled = val
          if val then
            self:Enable()
          else
            self:Disable()
          end
        end,
        width = "full"
      },
      barCC = {
        name = L['Use Class Colors'],
        order = 2,
        type = "toggle",
        get = function() return xb.db.profile.modules.tradeskill.barCC; end,
        set = function(_, val) xb.db.profile.modules.tradeskill.barCC = val; self:Refresh(); end
      },
      showTooltip = {
        name = L['Show Tooltips'],
        order = 3,
        type = "toggle",
        get = function() return xb.db.profile.modules.tradeskill.showTooltip; end,
        set = function(_, val) xb.db.profile.modules.tradeskill.showTooltip = val; self:Refresh(); end
      }
    }
  }
end
--]]