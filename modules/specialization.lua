local addOnName, XB = ...;

local Spec = XB:RegisterModule("Specialization")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT,libAD
local specFrame,specIcon,specText,lootSpecPopup,lootSpecPopupTexture
local Bar,BarFrame
local spec_config
local specId, lootSpecId = 0,0
local artifactId = 0
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
	if not lootSpecId then
		Spec:InitVars()
	end
	if libTT:IsAcquired("SpecializationTooltip") then
		libTT:Release(libTT:Acquire("SpecializationTooltip"))
	end

	local tooltip = libTT:Acquire("SpecializationTooltip", 1)
	if hide then
		tooltip:Hide()
	end
	tooltip:SmartAnchorTo(specFrame)
	tooltip:SetAutoHideDelay(.3, specFrame)
	tooltip:AddHeader("[|cff6699FF"..SPECIALIZATION.."|r]")
	tooltip:AddLine(string.format(ERR_LOOT_SPEC_CHANGED_S,select(2,GetSpecializationInfoByID(lootSpecId))))

	XB:SkinTooltip(tooltip,"SpecializationTooltip")
	tooltip:Show();
end

local function createSpecPopup()
	if not lootSpecPopup then return; end
	local color,hover,anchor = Spec.settings.color,Spec.settings.hover,Spec.settings.anchor
	--[[local db = xb.db.profile]]
	local iconSize = 25 --db.text.fontSize + db.general.barPadding
	local lootSpecOptionString = lootSpecOptionString or lootSpecPopup:CreateFontString(nil, 'OVERLAY')
	lootSpecOptionString:SetFont("Fonts\\FRIZQT__.TTF",20)
	lootSpecOptionString:SetTextColor(unpack(color))
	lootSpecOptionString:SetText(SELECT_LOOT_SPECIALIZATION)
	lootSpecOptionString:SetPoint('TOP', 0, -(3))
	lootSpecOptionString:SetPoint('CENTER')

	local popupWidth = lootSpecPopup:GetWidth()
	local popupHeight = (GetNumSpecializations()+1)*20--xb.constants.popupPadding + db.text.fontSize + self.optionTextExtra
	local changedWidth = false
	local lootSpecButtons = {}
	for i = 0, GetNumSpecializations() do
		if lootSpecButtons[i] == nil then
			local localSpecId = i
			local name = ''
			if i == 0 then
				name = SPECIALIZATION;
				localSpecId = specId
			else
				_, name, _ = GetSpecializationInfo(i)
			end
			local button = CreateFrame('BUTTON', nil, lootSpecPopup)
			local buttonText = button:CreateFontString(nil, 'OVERLAY')
			local buttonIcon = button:CreateTexture(nil, 'OVERLAY')

			buttonIcon:SetTexture(specIcon)
			buttonIcon:SetTexCoord(unpack(textureCoordinates[specId]))
			buttonIcon:SetSize(iconSize, iconSize)
			buttonIcon:SetPoint('LEFT')
			buttonIcon:SetVertexColor(unpack(color))

			buttonText:SetFont("Fonts\\FRIZQT__.TTF",20)
			buttonText:SetTextColor(unpack(color))
			buttonText:SetText(name)
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
					SetLootSpecialization(id)
				end
				TalentModule.lootSpecPopup:Hide()
			end)

			lootSpecButtons[i] = button

			if textWidth > popupWidth then
				popupWidth = textWidth
				changedWidth = true
			end
		end -- if nil
	end -- for ipairs portOptions
	for portId, button in pairs(lootSpecButtons) do
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

	if popupWidth < (lootSpecOptionString:GetStringWidth()  + 5) then
		popupWidth = (lootSpecOptionString:GetStringWidth()  + 5)
	end
	lootSpecPopup:SetSize(popupWidth, popupHeight + 3)

	local popupPadding = 3
	if Bar.settings.anchor == 'TOP' then
		popupPadding = -(popupPadding)
	end

	lootSpecPopup:ClearAllPoints()
	lootSpecPopupTexture:ClearAllPoints()
	lootSpecPopup:SetPoint(Bar.settings.anchor, specFrame, 3, 0, popupPadding)
	lootSpecPopupTexture:SetColorTexture(unpack(Bar.settings.color))
	lootSpecPopupTexture:SetAllPoints()
	lootSpecPopup:Hide()
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
	specId, lootSpecId = GetSpecialization(), GetLootSpecialization()
	C_Timer.After(2,function() specId, lootSpecId = GetSpecialization(), GetLootSpecialization() end)
	libAD:ForceUpdate()
	artifactId = libAD:GetActiveArtifactID() or 0
end

function Spec:OnEnable()
  self.settings.lock = self.settings.lock or not self.settings.lock
  refreshOptions()
  XB.Config:Register("Specialization",spec_config)

	if self.settings.enable then
		--self:InitVars()
		self:CreateFrames()
	else
		self:Disable()
	end
end

function Spec:OnDisable()
  specFrame:UnregisterAllEvents()
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
	specId, lootSpecId = GetSpecialization(), GetLootSpecialization()

	specFrame = specFrame or CreateFrame("Button","Specialization",BarFrame)
	specFrame:ClearAllPoints()
	specFrame:SetPoint(anchor,x,y)
	specFrame:SetMovable(true)
	specFrame:SetClampedToScreen(true)
	specFrame:RegisterForClicks("AnyUp")
	specFrame:Show()

	if not specFrame:IsEventRegistered("PLAYER_ENTERING_WORLD") then
		specFrame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
		specFrame:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		specFrame:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
		specFrame:RegisterEvent('ARTIFACT_CLOSE')
		-- specFrame:RegisterEvent('UNIT_INVENTORY_CHANGED')
		-- specFrame:RegisterEvent('INSPECT_READY')
		libAD:RegisterCallback('ARTIFACT_EQUIPPED_CHANGED',Spec.CreateFrames)--has to cchange
		libAD:RegisterCallback('ARTIFACT_KNOWLEDGE_CHANGED',Spec.CreateFrames)--has to cchange
		libAD:RegisterCallback('ARTIFACT_POWER_CHANGED', function()
		Spec:UpdateArtifactBar(artifactId)
		end)
	end

	specIcon = specIcon or specFrame:CreateTexture(nil,"OVERLAY",nil,7)
	specIcon:ClearAllPoints()
	specIcon:SetPoint("LEFT")
	specIcon:SetSize(w,h)
	specIcon:SetTexture(XB.mediaFold.."spec\\"..XB.playerClass)
	specIcon:SetTexCoord(unpack(textureCoordinates[specId]))
	specIcon:SetVertexColor(unpack(color))

	specText = specText or specFrame:CreateFontString(nil, "OVERLAY")
	specText:SetPoint("RIGHT", specFrame,2,0)
	specText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf", 12)
	specText:SetTextColor(unpack(color))

	local currentSpecName = select(2,GetSpecializationInfo(specId))
	if not currentSpecName then
		C_Timer.After(2,function()
			currentSpecName = select(2,GetSpecializationInfo(specId))
		end)
	else
		specText:SetText(string.upper(currentSpecName))
		specFrame:SetSize(specText:GetStringWidth()+2+w, h)
	end

	--For the specPopup
	lootSpecPopup = lootSpecPopup or CreateFrame('BUTTON', nil, specFrame)
	lootSpecPopupTexture = lootSpecPopupTexture or lootSpecPopup:CreateTexture(nil, 'BACKGROUND')

	XB:AddOverlay(Spec,specFrame,anchor)

	if not specFrame:GetScript("OnEvent") then
		specFrame:SetScript("OnEvent",Spec.CreateFrames)
		specFrame:SetScript("OnEnter",function()
			specIcon:SetVertexColor(unpack(hover))
			if Spec.settings.tooltip then
				tooltip()
			end
		end)
		specFrame:SetScript("OnLeave",function()
			specIcon:SetVertexColor(unpack(color))
		end)
		specFrame:SetScript("OnClick",function()
			--[[tooltip("hide")
			if button == 'LeftButton' then
			  if not InCombatLockdown() then
				if IsShiftKeyDown() then
					if lootSpecPopup:IsVisible() then
					  lootSpecPopup:Hide()
					  if Spec.settings.tooltip then
						tooltip();
					  end
					else
					  specPopup:Hide()
					  createSpecPopup()
					  lootSpecPopup:Show()
					end
				else
					if specPopup:IsVisible() then
					  specPopup:Hide()
					  if Spec.settings.tooltip then
						tooltip();
					  end
					else
					  lootSpecPopup:Hide()
					  CreateSpecPopup()
					  specPopup:Show()
					end
				end
			  end
			end

			if button == 'RightButton' then
			  if not InCombatLockdown() then
				if self.curArtifactId > 0 then
					SocketInventoryItem(16)
				end
			  end
			end]]
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
--[[

function TalentModule:OnInitialize()
  self.extraPadding = (xb.constants.popupPadding * 3)
  self.optionTextExtra = 4
  self.specButtons = {}
  self.lootSpecButtons = {}
  self.curArtifactId = 0
end

function TalentModule:Refresh()
  if InCombatLockdown() then return; end

  local db = xb.db.profile
  if self.talentFrame == nil then return; end
  if not db.modules.talent.enabled then self:Disable(); return; end

  local artifactId = self.LAD:GetActiveArtifactID() or 0
  self.curArtifactId = artifactId
  self.currentSpecID = GetSpecialization()
  self.currentLootSpecID = GetLootSpecialization()

  local iconSize = db.text.fontSize + db.general.barPadding
  local _, name, _ = GetSpecializationInfo(self.currentSpecID)

  local textHeight = db.text.fontSize
  if artifactId > 0 then
	textHeight = floor((xb:GetHeight() - 4) / 2)
  end
  self.specIcon:SetTexture(self.classIcon)
  self.specIcon:SetTexCoord(unpack(self.specCoords[self.currentSpecID]))

  self.specIcon:SetSize(iconSize, iconSize)
  self.specIcon:SetPoint('LEFT')
  self.specIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

  self.specText:SetFont(xb:GetFont(textHeight))
  self.specText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
  self.specText:SetText(string.upper(name or ""))

  if artifactId > 0 then
	self.specText:SetPoint('TOPLEFT', self.specIcon, 'TOPRIGHT', 5, 0)
  else
	self.specText:SetPoint('LEFT', self.specIcon, 'RIGHT', 5, 0)
  end

  self.lootSpecButtons[0].icon:SetTexture(self.classIcon)
  self.lootSpecButtons[0].icon:SetTexCoord(unpack(self.specCoords[self.currentSpecID]))

  if artifactId > 0 then
	self.specBar:SetStatusBarTexture(1, 1, 1)
	if db.modules.tradeskill.barCC then
	  self.specBar:SetStatusBarColor(xb:GetClassColors())
	else
	  self.specBar:SetStatusBarColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
	end
	local barHeight = iconSize - textHeight - 2
	if barHeight < 2 then 
	  barHeight = 2
	end
	self.specBar:SetSize(self.specText:GetStringWidth(), barHeight)
	self.specBar:SetPoint('BOTTOMLEFT', self.specIcon, 'BOTTOMRIGHT', 5, 0)

	self.specBarBg:SetAllPoints()
	self.specBarBg:SetColorTexture(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
	self:UpdateArtifactBar(artifactId)
	self.specBar:Show()
  else
	if self.specBar and self.specBar:IsVisible() then
		self.specBar:Hide()
	end
  end
  if self.specBar:IsVisible() then
	self.specFrame:SetSize(iconSize + self.specBar:GetWidth() + 5, xb:GetHeight())
  else
	self.specFrame:SetSize(iconSize + self.specText:GetWidth() + 5, xb:GetHeight())
  end
  self.specFrame:SetPoint('LEFT')

  if self.specFrame:GetWidth() < db.modules.talent.minWidth then
	self.specFrame:SetWidth(db.modules.talent.minWidth)
  end

  if self.specBar:GetWidth() < db.modules.talent.minWidth then
	self.specBar:SetWidth(db.modules.talent.minWidth)
  end

  self.talentFrame:SetSize(self.specFrame:GetWidth(), xb:GetHeight())
  local relativeAnchorPoint = 'LEFT'
  local xOffset = db.general.moduleSpacing
  local anchorFrame = xb:GetFrame('clockFrame')
  if not anchorFrame:IsVisible() and not db.modules.clock.enabled then
	if xb:GetFrame('tradeskillFrame'):IsVisible() then
	  anchorFrame = xb:GetFrame('tradeskillFrame')
	elseif xb:GetFrame('currencyFrame'):IsVisible() then
	  anchorFrame = xb:GetFrame('currencyFrame')
	else
	  relativeAnchorPoint = 'RIGHT'
	  xOffset = 0
	end
  end
  self.talentFrame:SetPoint('RIGHT', anchorFrame, relativeAnchorPoint, -(xOffset), 0)
  self:CreateSpecPopup()
  self:CreateLootSpecPopup()
end

function TalentModule:UpdateArtifactBar(artifactId)
  local _, artifactData = self.LAD:GetArtifactInfo(artifactId)
  self.specBar:SetMinMaxValues(0, artifactData.maxPower)
  self.specBar:SetValue(artifactData.power)
end

function TalentModule:CreateFrames()
  self.specFrame = self.specFrame or CreateFrame("BUTTON", nil, self.talentFrame, 'SecureActionButtonTemplate')
  self.specIcon = self.specIcon or self.specFrame:CreateTexture(nil, 'OVERLAY')
  self.specText = self.specText or self.specFrame:CreateFontString(nil, 'OVERLAY')
  self.specBar = self.specBar or CreateFrame('STATUSBAR', nil, self.specFrame)
  self.specBarBg = self.specBarBg or self.specBar:CreateTexture(nil, 'BACKGROUND')

  self.specPopup = self.specPopup or CreateFrame('BUTTON', nil, self.specFrame)
  self.specPopupTexture = self.specPopupTexture or self.specPopup:CreateTexture(nil, 'BACKGROUND')
  self.lootSpecPopup = self.lootSpecPopup or CreateFrame('BUTTON', nil, self.specFrame)
  self.lootSpecPopupTexture = self.lootSpecPopupTexture or self.lootSpecPopup:CreateTexture(nil, 'BACKGROUND')
  self:CreateSpecPopup()
  self:CreateLootSpecPopup()
end

function TalentModule:RegisterFrameEvents()

  self.specFrame:EnableMouse(true)
  self.specFrame:RegisterForClicks('AnyUp')

  self.specFrame:SetScript('OnEnter', function()
	if InCombatLockdown() then return; end
	self.specText:SetTextColor(unpack(xb:HoverColors()))
	if xb.db.profile.modules.tradeskill.showTooltip then
	  if ((not self.specPopup:IsVisible()) or (not self.lootSpecPopup:IsVisible())) then
		self:ShowTooltip()
	  end
	end
  end)
  self.specFrame:SetScript('OnLeave', function()
	if InCombatLockdown() then return; end
	local db = xb.db.profile
	self.specText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
	if xb.db.profile.modules.tradeskill.showTooltip then
	  GameTooltip:Hide()
	end
  end)
  self.specFrame:SetScript('OnClick', function(_, button)
	GameTooltip:Hide()
	if button == 'LeftButton' then
	  if not InCombatLockdown() then
		if IsShiftKeyDown() then
			if self.lootSpecPopup:IsVisible() then
			  self.lootSpecPopup:Hide()
			  if xb.db.profile.modules.tradeskill.showTooltip then
				self:ShowTooltip()
			  end
			else
			  self.specPopup:Hide()
			  self:CreateLootSpecPopup()
			  self.lootSpecPopup:Show()
			end
		else
			if self.specPopup:IsVisible() then
			  self.specPopup:Hide()
			  if xb.db.profile.modules.tradeskill.showTooltip then
				self:ShowTooltip()
			  end
			else
			  self.lootSpecPopup:Hide()
			  self:CreateSpecPopup()
			  self.specPopup:Show()
			end
		end
	  end
	end

	if button == 'RightButton' then
	  if not InCombatLockdown() then
		if self.curArtifactId > 0 then
			SocketInventoryItem(16)
		end
	  end
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

function TalentModule:CreateSpecPopup()
  if not self.specPopup then return; end

  local db = xb.db.profile
  local iconSize = db.text.fontSize + db.general.barPadding
  self.specOptionString = self.specOptionString or self.specPopup:CreateFontString(nil, 'OVERLAY')
  self.specOptionString:SetFont(xb:GetFont(db.text.fontSize + self.optionTextExtra))
  self.specOptionString:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
  self.specOptionString:SetText(L['Set Specialization'])
  self.specOptionString:SetPoint('TOP', 0, -(xb.constants.popupPadding))
  self.specOptionString:SetPoint('CENTER')

  local popupWidth = self.specPopup:GetWidth()
  local popupHeight = xb.constants.popupPadding + db.text.fontSize + self.optionTextExtra
  local changedWidth = false
  for i = 1, GetNumSpecializations() do
	if self.specButtons[i] == nil then

	  local _, name, _ = GetSpecializationInfo(i)
	  local button = CreateFrame('BUTTON', nil, self.specPopup)
	  local buttonText = button:CreateFontString(nil, 'OVERLAY')
	  local buttonIcon = button:CreateTexture(nil, 'OVERLAY')

	  buttonIcon:SetTexture(self.classIcon)
	  buttonIcon:SetTexCoord(unpack(self.specCoords[i]))
	  buttonIcon:SetSize(iconSize, iconSize)
	  buttonIcon:SetPoint('LEFT')
	  buttonIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

	  buttonText:SetFont(xb:GetFont(db.text.fontSize))
	  buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
	  buttonText:SetText(name)
	  buttonText:SetPoint('LEFT', buttonIcon, 'RIGHT', 5, 0)
	  local textWidth = iconSize + 5 + buttonText:GetStringWidth()

	  button:SetID(i)
	  button:SetSize(textWidth, iconSize)
	  button.isSettable = true

	  button:EnableMouse(true)
	  button:RegisterForClicks('AnyUp')

	  button:SetScript('OnEnter', function()
		buttonText:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
	  end)

	  button:SetScript('OnLeave', function()
		buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
	  end)

	  button:SetScript('OnClick', function(self, button)
		if InCombatLockdown() then return; end
		if button == 'LeftButton' then
		  SetSpecialization(self:GetID())
		end
		TalentModule.specPopup:Hide()
	  end)

	  self.specButtons[i] = button

	  if textWidth > popupWidth then
		popupWidth = textWidth
		changedWidth = true
	  end
	end -- if nil
  end -- for ipairs portOptions
  for portId, button in pairs(self.specButtons) do
	if button.isSettable then
	  button:SetPoint('LEFT', xb.constants.popupPadding, 0)
	  button:SetPoint('TOP', 0, -(popupHeight + xb.constants.popupPadding))
	  button:SetPoint('RIGHT')
	  popupHeight = popupHeight + xb.constants.popupPadding + db.text.fontSize
	else
	  button:Hide()
	end
  end -- for id/button in portButtons
  if changedWidth then
	popupWidth = popupWidth + self.extraPadding
  end

  if popupWidth < self.specFrame:GetWidth() then
	popupWidth = self.specFrame:GetWidth()
  end

  if popupWidth < (self.specOptionString:GetStringWidth()  + self.extraPadding) then
	popupWidth = (self.specOptionString:GetStringWidth()  + self.extraPadding)
  end
  self.specPopup:SetSize(popupWidth, popupHeight + xb.constants.popupPadding)

  local popupPadding = xb.constants.popupPadding
  if db.general.barPosition == 'TOP' then
	popupPadding = -(popupPadding)
  end

  self.specPopup:ClearAllPoints()
  self.specPopupTexture:ClearAllPoints()
  self.specPopup:SetPoint(db.general.barPosition, self.specFrame, xb.miniTextPosition, 0, popupPadding)
  self.specPopupTexture:SetColorTexture(db.color.barColor.r, db.color.barColor.g, db.color.barColor.b, db.color.barColor.a)
  self.specPopupTexture:SetAllPoints()
  self.specPopup:Hide()
end

function TalentModule:CreateLootSpecPopup()
  if not self.lootSpecPopup then return; end

  local db = xb.db.profile
  local iconSize = db.text.fontSize + db.general.barPadding
  self.lootSpecOptionString = self.lootSpecOptionString or self.lootSpecPopup:CreateFontString(nil, 'OVERLAY')
  self.lootSpecOptionString:SetFont(xb:GetFont(db.text.fontSize + self.optionTextExtra))
  self.lootSpecOptionString:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
  self.lootSpecOptionString:SetText(L['Set Loot Specialization'])
  self.lootSpecOptionString:SetPoint('TOP', 0, -(xb.constants.popupPadding))
  self.lootSpecOptionString:SetPoint('CENTER')

  local popupWidth = self.lootSpecPopup:GetWidth()
  local popupHeight = xb.constants.popupPadding + db.text.fontSize + self.optionTextExtra
  local changedWidth = false
  for i = 0, GetNumSpecializations() do
	if self.lootSpecButtons[i] == nil then
	  local specId = i
	  local name = ''
	  if i == 0 then
		name = L['Current Specialization'];
		specId = self.currentSpecID
	  else
		_, name, _ = GetSpecializationInfo(i)
	  end
	  local button = CreateFrame('BUTTON', nil, self.lootSpecPopup)
	  local buttonText = button:CreateFontString(nil, 'OVERLAY')
	  local buttonIcon = button:CreateTexture(nil, 'OVERLAY')

	  buttonIcon:SetTexture(self.classIcon)
	  buttonIcon:SetTexCoord(unpack(self.specCoords[specId]))
	  buttonIcon:SetSize(iconSize, iconSize)
	  buttonIcon:SetPoint('LEFT')
	  buttonIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)

	  buttonText:SetFont(xb:GetFont(db.text.fontSize))
	  buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
	  buttonText:SetText(name)
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
		buttonText:SetTextColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
	  end)

	  button:SetScript('OnLeave', function()
		buttonText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
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
		  SetLootSpecialization(id)
		end
		TalentModule.lootSpecPopup:Hide()
	  end)

	  self.lootSpecButtons[i] = button

	  if textWidth > popupWidth then
		popupWidth = textWidth
		changedWidth = true
	  end
	end -- if nil
  end -- for ipairs portOptions
  for portId, button in pairs(self.lootSpecButtons) do
	if button.isSettable then
	  button:SetPoint('LEFT', xb.constants.popupPadding, 0)
	  button:SetPoint('TOP', 0, -(popupHeight + xb.constants.popupPadding))
	  button:SetPoint('RIGHT')
	  popupHeight = popupHeight + xb.constants.popupPadding + db.text.fontSize
	else
	  button:Hide()
	end
  end -- for id/button in portButtons
  if changedWidth then
	popupWidth = popupWidth + self.extraPadding
  end

  if popupWidth < self.specFrame:GetWidth() then
	popupWidth = self.specFrame:GetWidth()
  end

  if popupWidth < (self.lootSpecOptionString:GetStringWidth()  + self.extraPadding) then
	popupWidth = (self.lootSpecOptionString:GetStringWidth()  + self.extraPadding)
  end
  self.lootSpecPopup:SetSize(popupWidth, popupHeight + xb.constants.popupPadding)

  local popupPadding = xb.constants.popupPadding
  if db.general.barPosition == 'TOP' then
	popupPadding = -(popupPadding)
  end

  self.lootSpecPopup:ClearAllPoints()
  self.lootSpecPopupTexture:ClearAllPoints()
  self.lootSpecPopup:SetPoint(db.general.barPosition, self.specFrame, xb.miniTextPosition, 0, popupPadding)
  self.lootSpecPopupTexture:SetColorTexture(db.color.barColor.r, db.color.barColor.g, db.color.barColor.b, db.color.barColor.a)
  self.lootSpecPopupTexture:SetAllPoints()
  self.lootSpecPopup:Hide()
end

function TalentModule:ShowTooltip()
  GameTooltip:SetOwner(self.talentFrame, 'ANCHOR_'..xb.miniTextPosition)
  GameTooltip:AddLine("[|cff6699FF"..SPECIALIZATION.."|r]")
  GameTooltip:AddLine(" ")

  local name = ''
  if self.currentLootSpecID == 0 then
	_, name, _ = GetSpecializationInfo(self.currentSpecID)
  else
	_, name, _ = GetSpecializationInfoByID(self.currentLootSpecID)
  end
  GameTooltip:AddDoubleLine(L['Current Loot Specialization'], name, 1, 1, 0, 1, 1, 1)

  if self.curArtifactId > 0 then
	GameTooltip:AddLine(" ")
	local _, artifactData = self.LAD:GetArtifactInfo(self.curArtifactId)
	local knowLevel, knowMult = self.LAD:GetArtifactKnowledge()
	if knowLevel and knowLevel > 0 then
	  GameTooltip:AddDoubleLine(L['Artifact Knowledge']..':', string.format('%d (x%d)', knowLevel, ((knowMult) - 1 * 100)), 1, 1, 0, 1, 1, 1)
	  GameTooltip:AddLine(" ")
	end
	GameTooltip:AddDoubleLine(ARTIFACT_POWER..':', string.format('%d / %d (%d%%)', artifactData.power, artifactData.maxPower, floor((artifactData.power / artifactData.maxPower) * 100)), 1, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine(L['Remaining']..':', string.format('%d (%d%%)', artifactData.powerForNextRank, floor((artifactData.powerForNextRank / artifactData.maxPower) * 100)), 1, 1, 0, 1, 1, 1)
	if artifactData.numRanksPurchasable > 0 then
	  GameTooltip:AddDoubleLine(L['Available Ranks']..':', string.format('%d', artifactData.numRanksPurchasable), 1, 1, 0, 1, 1, 1)
	end
  end

  GameTooltip:AddLine(" ")
  GameTooltip:AddDoubleLine('<'..L['Left-Click']..'>', L['Set Specialization'], 1, 1, 0, 1, 1, 1)
  GameTooltip:AddDoubleLine('<'..SHIFT_KEY_TEXT.."+"..L['Left-Click']..'>', L['Set Loot Specialization'], 1, 1, 0, 1, 1, 1)
  if self.curArtifactId > 0 then
	GameTooltip:AddDoubleLine('<'..L['Right-Click']..'>', L['Open Artifact'], 1, 1, 0, 1, 1, 1)
  end
  GameTooltip:Show()
end

function TalentModule:GetDefaultOptions()
  return 'talent', {
	  enabled = true,
	  barCC = false,
	  showTooltip = true,
	  minWidth = 50
	}
end

function TalentModule:GetConfig()
  return {
	name = self:GetName(),
	type = "group",
	args = {
	  enable = {
		name = ENABLE,
		order = 0,
		type = "toggle",
		get = function() return xb.db.profile.modules.talent.enabled; end,
		set = function(_, val)
		  xb.db.profile.modules.talent.enabled = val
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
		get = function() return xb.db.profile.modules.talent.barCC; end,
		set = function(_, val) xb.db.profile.modules.talent.barCC = val; self:Refresh(); end
	  },
	  showTooltip = {
		name = L['Show Tooltips'],
		order = 3,
		type = "toggle",
		get = function() return xb.db.profile.modules.talent.showTooltip; end,
		set = function(_, val) xb.db.profile.modules.talent.showTooltip = val; self:Refresh(); end
	  },
	  minWidth = {
		name = L['Talent Minimum Width'],
		type = 'range',
		order = 4,
		min = 10,
		max = 200,
		step = 10,
		get = function() return xb.db.profile.modules.talent.minWidth; end,
		set = function(info, val) xb.db.profile.modules.talent.minWidth = val; self:Refresh(); end
	  }
	}
  }
end
]]