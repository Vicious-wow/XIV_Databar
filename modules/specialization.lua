local addOnName, XB = ...;

local Spec = XB:RegisterModule("Specialization")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT,libAD
local specFrame,specIcon,specText,specPopup,headerSpecPopup,popupSpecType,artifactBar,artifactBarBg
local Bar,BarFrame
local spec_config
local specId, lootSpecId = 0,0
local artifactId, azeriteItem = 0, nil
local textureCoordinates = {
	[1] = { 0.00, 0.25, 0, 1 },
    [2] = { 0.25, 0.50, 0, 1 },
    [3] = { 0.50, 0.75, 0, 1 },
    [4] = { 0.75, 1.00, 0, 1 }
}

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function refreshOptions()
	Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
end

local function tooltip(hide)
	if libTT:IsAcquired("SpecializationTooltip") then
		libTT:Release(libTT:Acquire("SpecializationTooltip"))
	end

	local tooltip = libTT:Acquire("SpecializationTooltip", 1)

	tooltip:SmartAnchorTo(specFrame)
	tooltip:SetAutoHideDelay(.2, specFrame)
	tooltip:AddHeader("[|cff6699FF"..SPECIALIZATION.."|r]")
  	azeriteItem = C_AzeriteItem.FindActiveAzeriteItem();

	if artifactId > 0 then
		tooltip:AddLine(" ")
		local _, artifactData = libAD:GetArtifactInfo(artifactId)
		tooltip:AddLine(ARTIFACT_POWER..':'..string.format('%d / %d (%d%%)', artifactData.power, artifactData.maxPower, floor((artifactData.power / artifactData.maxPower) * 100)), 1, 1, 0, 1, 1, 1)
		tooltip:AddLine('Remaining:'..string.format('%d (%d%%)', artifactData.powerForNextRank, floor((artifactData.powerForNextRank / artifactData.maxPower) * 100)), 1, 1, 0, 1, 1, 1)
	elseif azeriteItem then
		local azeriteItem_ = Item:CreateFromItemLocation(azeriteItem); 
		local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItem)
		local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItem); 
		local xpToNextLevel = totalLevelXP - xp; 
		tooltip:AddLine(" ")
		tooltip:AddLine(AZERITE_POWER_TOOLTIP_TITLE:format(currentLevel, xpToNextLevel))
		tooltip:AddLine(("%s "..string.gsub(AZERITE_POWER_BAR,"%%s","(%%s)")):format(xp,FormatPercentage(xp / totalLevelXP, true)))
		tooltip:AddLine(" ")
	end

	local lootSpecString = select(1,ERR_LOOT_SPEC_CHANGED_S:gsub("%%s",""))
	tooltip:AddLine("|cffffff00"..lootSpecString.."|cffffffff"..select(2,GetSpecializationInfoByID(lootSpecId)).."|r")--

	tooltip:AddLine(" ")
		tooltip:AddLine('|cffffff00<'..'Left-Click'..'>|r'.. ' Set Specialization')
	tooltip:AddLine('|cffffff00<'..SHIFT_KEY_TEXT.."+"..'Left-Click'..'>|r Set Loot Specialization')
	if artifactId > 0 then
		tooltip:AddLine('|cffffff00<'..'Right-Click'..'>|r Open Artifact')
	end

	XB:SkinTooltip(tooltip,"SpecializationTooltip")
	if hide then
		tooltip:Hide()
	else
		tooltip:Show();
	end
end

local function createArtifactBar(color,bg)
	artifactBar = artifactBar or CreateFrame('STATUSBAR', nil, specFrame)
  	artifactBarBg = artifactBarBg or artifactBar:CreateTexture(nil, 'BACKGROUND')

  	azeriteItem = C_AzeriteItem.FindActiveAzeriteItem();
  	if azeriteItem then 
		local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItem)

		artifactBar:SetStatusBarTexture(1, 1, 1)
		artifactBar:SetStatusBarColor(unpack(color))
		artifactBar:SetMinMaxValues(0, totalLevelXP)
		artifactBar:SetValue(xp)
	elseif artifactId > 0 then
		artifactBar:SetStatusBarTexture(1, 1, 1)
		artifactBar:SetStatusBarColor(unpack(color))
		--artifactBar:SetMinMaxValues(0, totalLevelXP)
		--artifactBar:SetValue(xp)
	else
		if artifactBar and artifactBar:IsVisible() then
			artifactBar:Hide()
		end
	end
	artifactBar:SetSize(specText:GetStringWidth(), 2)
	artifactBar:SetPoint('BOTTOMLEFT', specIcon, 'BOTTOMRIGHT', 5, 0)

	artifactBarBg:SetAllPoints()
	artifactBarBg:SetColorTexture(unpack(bg))
	artifactBar:Show()

end

local function createPopupFrame(specType)
	popupSpecType = specType
	local color,hover,anchor = Spec.settings.color,Spec.settings.hover,Spec.settings.anchor,specPopupTexture

	if specPopup then
		headerSpecPopup:SetText(specType == "loot" and SELECT_LOOT_SPECIALIZATION or SPECIALIZATION)
		specPopup:SetSize(headerSpecPopup:GetWidth(),specPopup:GetHeight())
	else
		specPopup = CreateFrame('FRAME', nil, specFrame)
		specPopupTexture = specPopup:CreateTexture(nil, 'BACKGROUND')
		headerSpecPopup = specPopup:CreateFontString(nil, 'OVERLAY')

		headerSpecPopup:SetFont(XB.mediaFold.."font\\homizio_bold.ttf",20)
		headerSpecPopup:SetText(specType == "loot" and SELECT_LOOT_SPECIALIZATION or SPECIALIZATION)
		headerSpecPopup:SetTextColor(unpack(color))
		headerSpecPopup:SetPoint('TOP', 0, -(3))
		headerSpecPopup:SetPoint('CENTER')

		--[[local db = xb.db.profile]]
		local iconSize = 25 --db.text.fontSize + db.general.barPadding
		

		local popupWidth = specFrame:GetWidth()
		local popupHeight = (GetNumSpecializations()+1)*10--xb.constants.popupPadding + db.text.fontSize + self.optionTextExtra
		local changedWidth = false
		local lootSpecButtons = {}
		for i = 1, GetNumSpecializations() do
			if lootSpecButtons[i] == nil then
				local localSpecId = i
				local	_, name, _ = GetSpecializationInfo(i)

				local button = CreateFrame('BUTTON', nil, specPopup)
				local buttonText = button:CreateFontString(nil, 'OVERLAY')
				local buttonIcon = button:CreateTexture(nil, 'BACKGROUND')

				buttonIcon:SetTexture(XB.mediaFold.."spec\\"..XB.playerClass)
				buttonIcon:SetTexCoord(unpack(textureCoordinates[localSpecId]))
				buttonIcon:SetSize(iconSize, iconSize)
				buttonIcon:SetPoint('LEFT')
				buttonIcon:SetVertexColor(unpack(color))

				buttonText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf",15)
				buttonText:SetTextColor(unpack(color))
				buttonText:SetText(string.upper(name))
				buttonText:SetPoint('LEFT', buttonIcon, 'RIGHT', 5, 0)
				local textWidth = iconSize + 5 + buttonText:GetStringWidth()

				button:SetID(i)
				button:SetSize(textWidth, iconSize)
				button.isSettable = true
				button.text = buttonText
				button.icon = buttonIcon

				button:EnableMouse(true)
				button:RegisterForClicks('AnyUp')

				button:SetScript('OnEnter', function()
					buttonText:SetTextColor(unpack(color))
				end)

				button:SetScript('OnLeave', function()
					buttonText:SetTextColor(unpack(color))
				end)

				button:SetScript('OnClick', function(self, button)
					if InCombatLockdown() then return; end
					if button == 'LeftButton' then
						local id = 0
						local name = ''
						if self:GetID() ~= 0 then
							id, name = GetSpecializationInfo(self:GetID())
						else
							name = GetSpecializationInfo(GetSpecialization())
						end

						if popupSpecType == "loot" then
							SetLootSpecialization(id)
						else
							SetSpecialization(self:GetID())
						end
					end
					specPopup:Hide()
				end)

				lootSpecButtons[i] = button

				if textWidth > popupWidth then
					popupWidth = textWidth
					changedWidth = true
				end
			end 
		end 

		for _, button in pairs(lootSpecButtons) do
			if button.isSettable then
			  button:SetPoint('LEFT', 10, 0)
			  button:SetPoint('TOP', 0, -(popupHeight + 10))
			  button:SetPoint('RIGHT')
			  popupHeight = popupHeight + 10 + 20
			else
			  button:Hide()
			end
		end
		if changedWidth then
			popupWidth = popupWidth + 5
		end

		if popupWidth < specFrame:GetWidth() then
			popupWidth = specFrame:GetWidth()
		end

		if popupWidth < (headerSpecPopup:GetStringWidth()  + 5) then
			popupWidth = (headerSpecPopup:GetStringWidth()  + 5)
		end
		specPopup:SetSize(popupWidth, popupHeight + 3)
		--specPopupTexture:SetSize(popupWidth, popupHeight + 3)

		local popupPadding = Bar.settings.h+2
		if Bar.settings.anchor == 'TOP' then
			popupPadding = -(popupPadding)
		end

		specPopup:ClearAllPoints()
		specPopupTexture:ClearAllPoints()
		specPopup:SetPoint(Bar.settings.anchor, specFrame, Bar.settings.anchor, 0, popupPadding)
		specPopupTexture:SetColorTexture(unpack(Bar.settings.color))
		specPopupTexture:SetAllPoints()
		specPopup:Hide()
	end	
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local spec_default = {
	profile ={
		enable = true,
		lock = true,
		x = -110,
		y = 0,
		w = 16,
		h = 16,
		anchor = "CENTER",
		combatEn = false,
		tooltip = true,
		color = {1,1,1,.75},
		colorCC = false,
		hover = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
		hoverCC = not (XB.playerClass == "PRIEST"),
	}
}

----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Spec:OnInitialize()
  libTT = LibStub('LibQTip-1.0')
  libAD = LibStub('LibArtifactData-1.0')
  self.db = XB.db:RegisterNamespace("Specialization", spec_default)
  self.settings = self.db.profile
end

function Spec:InitVars()
	specId, lootSpecId = GetSpecializationInfo(GetSpecialization()), GetLootSpecialization() == 0 and GetSpecializationInfo(GetSpecialization()) or GetLootSpecialization()
	libAD:ForceUpdate()
	artifactId = libAD:GetActiveArtifactID() or 0
	--[[if not specId or lootSpecId then
		C_Timer.After(.3,Spec.InitVars)
	end--]]
end

function Spec:OnEnable()
  self.settings.lock = self.settings.lock or not self.settings.lock
  refreshOptions()
  XB.Config:Register("Specialization",spec_config)

	if self.settings.enable then
		self:InitVars()
		self:CreateFrames()
	else
		self:Disable()
	end
end

function Spec:OnDisable()
  specFrame:UnregisterAllEvents()
end

function Spec:Refresh()
	--Azerite neck
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem(); 
	local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
	artifactBar:SetMinMaxValues(0, totalLevelXP)
	artifactBar:SetValue(xp)
end

function Spec:CreateFrames()
	--dissocier la frame principale sur la barre et les frames de changement de spec
	if not Spec.settings.enable then
	  if specFrame and specFrame:IsVisible() then
		specFrame:Hide()
	  end
	  return
	end

	local x,y,w,h,color,hover,anchor = Spec.settings.x,Spec.settings.y,Spec.settings.w,Spec.settings.h,Spec.settings.color,Spec.settings.hover,Spec.settings.anchor
	local currentSpecIndex = GetSpecialization()
	Spec:InitVars()

	specFrame = specFrame or CreateFrame("Button","Specialization",BarFrame)
	specFrame:ClearAllPoints()
	specFrame:SetPoint(anchor,x,y)
	specFrame:SetMovable(true)
	specFrame:SetClampedToScreen(true)
	specFrame:RegisterForClicks("AnyUp")
	specFrame:Show()

	if not specFrame:IsEventRegistered("PLAYER_ENTERING_WORLD") then
		specFrame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
		--specFrame:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		specFrame:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
		specFrame:RegisterEvent('AZERITE_ITEM_EXPERIENCE_CHANGED')
		-- specFrame:RegisterEvent('INSPECT_READY')
		specFrame:RegisterEvent('LFG_UPDATE')
		libAD:RegisterCallback('ARTIFACT_EQUIPPED_CHANGED',Spec.CreateFrames)--has to change
		libAD:RegisterCallback('ARTIFACT_KNOWLEDGE_CHANGED',Spec.CreateFrames)--has to change
		libAD:RegisterCallback('ARTIFACT_POWER_CHANGED', function()
		Spec:UpdateArtifactBar(artifactId)
		end)
	end

	specIcon = specIcon or specFrame:CreateTexture(nil,"OVERLAY",nil,7)
	specIcon:ClearAllPoints()
	specIcon:SetPoint("LEFT")
	specIcon:SetSize(w,h)
	specIcon:SetTexture(XB.mediaFold.."spec\\"..XB.playerClass)
	specIcon:SetTexCoord(unpack(textureCoordinates[currentSpecIndex]))
	specIcon:SetVertexColor(unpack(color))

	specText = specText or specFrame:CreateFontString(nil, "OVERLAY")
	specText:SetPoint("RIGHT", specFrame,2,0)
	specText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf", 12)
	specText:SetTextColor(unpack(color))

	local currentSpecName = specId and select(2,GetSpecializationInfoByID(specId)) or ""
	specText:SetText(string.upper(currentSpecName))
	specFrame:SetSize(specText:GetStringWidth()+2+w, h)

	createPopupFrame()
	createArtifactBar(hover,color)

	XB:AddOverlay(Spec,specFrame,anchor)

	if not specFrame:GetScript("OnEvent") then
		specFrame:SetScript("OnEvent",function(self,event,...)
			if event == "AZERITE_ITEM_EXPERIENCE_CHANGED" then
				Spec.Refresh()
			else
				Spec.CreateFrames()
			end
		end)
		specFrame:SetScript("OnEnter",function()
			specIcon:SetVertexColor(unpack(hover))
			if self.settings.tooltip then
				tooltip()
			end
		end)
		specFrame:SetScript("OnLeave",function()
			specIcon:SetVertexColor(unpack(color))
		end)
		specFrame:SetScript("OnMouseUp",function(_,button)
			
			if button == 'LeftButton' then
				tooltip("hide")
				if IsShiftKeyDown() then 
					createPopupFrame("loot")
				else
					createPopupFrame()
				end
				if specPopup:IsShown() then
					specPopup:Hide()
				else
					specPopup:Show()
				end
			elseif button == 'RightButton' and artifactId > 0 then
				SocketInventoryItem(16)
			end
		end)
	end

	if not Spec.settings.lock then
		specFrame.overlay:Show()
		specFrame.overlay.anchor:Show()
	else
		specFrame.overlay:Hide()
		specFrame.overlay.anchor:Hide()
	end
end