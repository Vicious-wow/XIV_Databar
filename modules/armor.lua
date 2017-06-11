local addOnName, XB = ...;

local Arm = XB:RegisterModule("Armor")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT
local armorFrame,armorIcon,armorText
local Bar,BarFrame
local arm_config
local avgDurability, overallilvl, equippedilvl

local durabilityList = {
	{ id = GetInventorySlotInfo("HeadSlot"), cur = 0, max = 0, text = HEADSLOT},
	{ id = GetInventorySlotInfo("ShoulderSlot"), cur = 0, max = 0, text = SHOULDERSLOT},
	{ id = GetInventorySlotInfo("ChestSlot"), cur = 0, max = 0, text = CHESTSLOT},
	{ id = GetInventorySlotInfo("WristSlot"), cur = 0, max = 0, text = WRISTSLOT},
	{ id = GetInventorySlotInfo("HandsSlot"), cur = 0, max = 0, text = HANDSSLOT},
	{ id = GetInventorySlotInfo("WaistSlot"), cur = 0, max = 0, text = WAISTSLOT},
	{ id = GetInventorySlotInfo("LegsSlot"), cur = 0, max = 0, text = LEGSSLOT},
	{ id = GetInventorySlotInfo("FeetSlot"), cur = 0, max = 0, text = FEETSLOT},
	{ id = GetInventorySlotInfo("MainHandSlot"), cur = 0, max = 0, text = MAINHANDSLOT},
	{ id = GetInventorySlotInfo("SecondaryHandSlot"), cur = 0, max = 0, text = SECONDARYHANDSLOT}
  }

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function refreshOptions()
  Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
end

local function CreateMoneyButtonNormalTexture (button, iconWidth)
  local texture = button:CreateTexture();
  texture:SetTexture("Interface\\MoneyFrame\\UI-MoneyGold");
  texture:SetWidth(iconWidth);
  texture:SetHeight(iconWidth);
  texture:SetPoint("RIGHT");
  button:SetTexture(texture);
  
  return texture;
end

local function repairCost()
  --Estimation
  local totalCost, repairCopper, repairSilver, repairGold = 0,0,0,0;
  
  for _, v in ipairs(durabilityList) do
	local scanTool = CreateFrame("GameTooltip")
	  scanTool:ClearLines()
	local repair = select(3, scanTool:SetInventoryItem("player", v.id))
	totalCost = totalCost + repair
  end
  --Cuz it does not not match the right amount
  --totalCost = totalCost * 1.659073

  totalCost, repairCopper = math.modf(totalCost/100.0)
  totalCost, repairSilver = math.modf(totalCost/100.0)

  return GetCoinTextureString(totalCost..""..(repairSilver*100)..""..(repairCopper*100));
end

local function tooltip()
  if libTT:IsAcquired("ArmorTooltip") then
	libTT:Release(libTT:Acquire("ArmorTooltip"))
  end

  local tooltip = libTT:Acquire("ArmorTooltip", 2)
  tooltip:SmartAnchorTo(armorFrame)
  tooltip:SetAutoHideDelay(.5, armorFrame)
  tooltip:AddHeader("[|cff6699FF"..AUCTION_CATEGORY_ARMOR.."|r]")
  tooltip:AddLine(" ")
  
  tooltip:AddLine("Estimated repair",repairCost())
  if Arm.settings.showIlvl then
	ilvlString = string.format("Item level %."..Arm.settings.floatPrecision.."f/%."..Arm.settings.floatPrecision.."f",equippedilvl,overallilvl)
	tooltip:AddLine(ilvlString)
  end
  tooltip:AddLine(" ")

	for _,v in pairs(durabilityList) do
	  if GetInventoryItemID("player", v.id) and v.max == 0 then
		tooltip:AddLine("|cffffff00"..v.text.."|r", "|cffffffff"..string.format('%d/%d (%d%%)', 1, 1, 100).."|r")
	  end

	  if v.max ~= nil and v.max > 0 then
		local perc = floor((v.cur / v.max)  * 100)
		tooltip:AddLine("|cffffff00"..v.text.."|r", "|cffffffff"..string.format('%d/%d (%d%%)', v.cur, v.max, perc).."|r")
	  end
	end

  XB:SkinTooltip(tooltip,"ArmorTooltip")
  tooltip:Show();
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local arm_default ={
  profile = {
	enable = true,
	lock = true,
	x = 590,
	y = 0,
	w = 16,
	h = 16,
	anchor = "LEFT",
	combatEn = false,
	tooltip = true,
	color = {1,1,1,.75},
	colorCC = false,
	hover = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
	hoverCC = not (XB.playerClass == "PRIEST"),
	thresh = 70,
	showIlvl = true,
	alwaysDurability = true,
	replaceDurWithIlvl = false,
	floatPrecision = 2
  }
}
----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Arm:OnInitialize()
  libTT = LibStub('LibQTip-1.0')
  self.db = XB.db:RegisterNamespace("Armor", arm_default)
  self.settings = self.db.profile
end

function Arm:OnEnable()
  self.settings.lock = self.settings.lock or not self.settings.lock
  refreshOptions()
  XB.Config:Register("Armor",arm_config)
	if self.settings.enable then
		self:CreateFrames()
	else
		self:Disable()
	end
end

function Arm:OnDisable()
  armorFrame:Hide()
  armorText:Hide()
end

function Arm:CreateFrames()
  if not self.settings.enable then
	if armorFrame and armorFrame:IsVisible() then
	  armorFrame:Hide()
	end
	return
  end

  local x,y,w,h,color,hover,anchor = self.settings.x,self.settings.y,self.settings.w,self.settings.h,self.settings.color,self.settings.hover,self.settings.anchor

  armorFrame = armorFrame or CreateFrame("Frame","Armor",BarFrame)
  armorFrame:ClearAllPoints()
  armorFrame:SetPoint(anchor,x,y)
  armorFrame:SetMovable(true)
  armorFrame:SetClampedToScreen(true)
  armorFrame:Show()

  if not armorFrame:IsEventRegistered("PLAYER_ENTERING_WORLD") then
	armorFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	armorFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
  end

  armorIcon = armorIcon or armorFrame:CreateTexture(nil,"OVERLAY",nil,7)
  armorIcon:ClearAllPoints()
  armorIcon:SetPoint("LEFT")
  armorIcon:SetSize(w,h)
  armorIcon:SetTexture(XB.icons.repair)

  armorText = armorText or armorFrame:CreateFontString(nil, "OVERLAY")
  armorText:SetPoint("RIGHT", armorFrame,2,0)
  armorText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf", 12)
  armorText:SetTextColor(unpack(color))

  if self.settings.alwaysDurability then
	armorText:SetText("100%")
  elseif self.settings.replaceDurWithIlvl then
	armorText:SetText("1000")
  end
  armorFrame:SetSize(armorText:GetStringWidth()+2+w, h)

  XB:AddOverlay(self,armorFrame,anchor)
  
  if not armorFrame:GetScript("OnEnter") then
	armorFrame:SetScript("OnEnter", function()
	  if InCombatLockdown() and not Arm.settings.combatEn then return end
	  armorIcon:SetVertexColor(unpack(hover))
	  if Arm.settings.tooltip then
		tooltip()
	  end
	end)

	armorFrame:SetScript("OnLeave", function()
	  if avgDurability < self.settings.thresh then
		armorIcon:SetVertexColor(unpack(color))
	  else
		armorIcon:SetVertexColor(unpack({1,1,1,.25}))
	  end

	  if libTT:IsAcquired("ArmorTooltip") then
		libTT:Release(libTT:Acquire("ArmorTooltip"))
	  end
	end)

	armorFrame:SetScript("OnEvent",function()
	  local total, maxTotal,itemCountEquiped, percAll = 0,0,0,0
	  overallilvl, equippedilvl = GetAverageItemLevel()

	  for _,v in ipairs(durabilityList) do
		local curDur, maxDur = GetInventoryItemDurability(v.id)
		if curDur ~= nil and maxDur ~= nil then
		  total = total + curDur
		  maxTotal = maxTotal + maxDur

		  itemCountEquiped = itemCountEquiped +1

		  v.cur = curDur
		  v.max = maxDur

		  percAll = percAll + floor((v.cur / v.max)  * 100)
		end
	  end

	  avgDurability = percAll/itemCountEquiped

	  if avgDurability < self.settings.thresh then
		armorIcon:SetVertexColor(unpack(color))
	  else
		armorIcon:SetVertexColor(unpack({1,1,1,.25}))
	  end

	  if self.settings.alwaysDurability then
		armorText:SetText(string.format("%."..self.settings.floatPrecision.."f%%",avgDurability))
	  elseif self.settings.replaceDurWithIlvl then
		armorText:SetText(equippedilvl)
	  else
		armorText:SetText("")
	  end

	  armorFrame:SetSize(armorText:GetStringWidth()+2+w, h)
	end)
  end

  if not self.settings.lock then
	armorFrame.overlay:Show()
	armorFrame.overlay.anchor:Show()
  else
	armorFrame.overlay:Hide()
	armorFrame.overlay.anchor:Hide()
  end
end

--[[local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local ArmorModule = xb:NewModule("ArmorModule", 'AceEvent-3.0')

function ArmorModule:GetName()
  return AUCTION_CATEGORY_ARMOR;
end

function ArmorModule:OnInitialize()
  self.iconPath = xb.constants.mediaPath..'datatexts\\repair'
  self.durabilityAverage = 0
  self.durabilityList = {
	[INVSLOT_HEAD] = { cur = 0, max = 0, text = HEADSLOT},
	[INVSLOT_SHOULDER] =  { cur = 0, max = 0, text = SHOULDERSLOT},
	[INVSLOT_CHEST] =  { cur = 0, max = 0, text = CHESTSLOT},
	[INVSLOT_WAIST] =  { cur = 0, max = 0, text = WAISTSLOT},
	[INVSLOT_LEGS] =  { cur = 0, max = 0, text = LEGSSLOT},
	[INVSLOT_FEET] =  { cur = 0, max = 0, text = FEETSLOT},
	[INVSLOT_WRIST] =  { cur = 0, max = 0, text = WRISTSLOT},
	[INVSLOT_HAND] =  { cur = 0, max = 0, text = HANDSSLOT},
	[INVSLOT_MAINHAND] =  { cur = 0, max = 0, text = MAINHANDSLOT},
	[INVSLOT_OFFHAND] =  { cur = 0, max = 0, text = SECONDARYHANDSLOT}
  }
end

function ArmorModule:OnEnable()
  if self.armorFrame == nil then
	self.armorFrame = CreateFrame("FRAME", AUCTION_CATEGORY_ARMOR, xb:GetFrame('bar'))
	xb:RegisterFrame('armorFrame', self.armorFrame)
  end
  self.armorFrame:Show()
  self:CreateFrames()
  self:RegisterFrameEvents()
  xb:Refresh()
end

function ArmorModule:OnDisable()
  self:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')
  self.armorFrame:Hide()
end

function ArmorModule:CreateFrames()
  self.armorButton = self.armorButton or CreateFrame('BUTTON', nil, self.armorFrame)
  self.armorIcon = self.armorIcon or self.armorButton:CreateTexture(nil, 'OVERLAY')
  self.armorText = self.armorText or self.armorButton:CreateFontString(nil, 'OVERLAY')
end

function ArmorModule:RegisterFrameEvents()
  self.armorButton:EnableMouse(true)
  self.armorButton:RegisterUnitEvent('UNIT_INVENTORY_CHANGED', 'player')

  self.armorButton:SetScript('OnEnter', function()
	if not InCombatLockdown() then
		ArmorModule:SetArmorColor()
		GameTooltip:SetOwner(ArmorModule.armorFrame, 'ANCHOR_'..xb.miniTextPosition)
		GameTooltip:AddLine("[|cff6699FF"..AUCTION_CATEGORY_ARMOR.."|r]")
		GameTooltip:AddLine(" ")
		for i,v in pairs(ArmorModule.durabilityList) do
		  if v.max ~= nil and v.max > 0 then
			local perc = floor((v.cur / v.max)  * 100)
			GameTooltip:AddDoubleLine(v.text, string.format('%d/%d (%d%%)', v.cur, v.max, perc), 1, 1, 0, 1, 1, 1)
		  end
		end
		GameTooltip:Show()
	end
  end)

  self.armorButton:SetScript('OnLeave', function()
	if not InCombatLockdown() then
		self:SetArmorColor()
		GameTooltip:Hide()
	end
  end)

  self.armorButton:SetScript('OnEvent', function(_, event)
	if event == 'UNIT_INVENTORY_CHANGED' then
	  self:Refresh()
	end
  end)

  self:RegisterMessage('XIVBar_FrameHide', function(_, name)
	if name == 'microMenuFrame' then
	  self:Refresh()
	end
  end)

  self:RegisterMessage('XIVBar_FrameShow', function(_, name)
	if name == 'microMenuFrame' then
	  self:Refresh()
	end
  end)

  self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
end

function ArmorModule:SetArmorColor()
  local db = xb.db.profile
  if self.armorButton:IsMouseOver() then
	self.armorText:SetTextColor(unpack(xb:HoverColors()))
  else
	self.armorText:SetTextColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
	if self.durabilityAverage >= db.modules.armor.durabilityMin then
	  self.armorIcon:SetVertexColor(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b, db.color.inactive.a)
	else
	  self.armorIcon:SetVertexColor(db.color.normal.r, db.color.normal.g, db.color.normal.b, db.color.normal.a)
	end
  end
end

function ArmorModule:Refresh()
  if self.armorFrame == nil then return; end
  if not xb.db.profile.modules.armor.enabled then self:Disable(); return; end

  if InCombatLockdown() then
	self:UpdateDurabilityText()
	return
  end

  local iconSize = xb:GetHeight()
  self.armorIcon:SetTexture(self.iconPath)
  --self.armorIcon:SetSize(iconSize, iconSize)
  self.armorIcon:SetPoint('LEFT')

  self.armorText:SetFont(xb:GetFont(xb.db.profile.text.fontSize))
  self:UpdateDurabilityText()
  self.armorText:SetPoint('LEFT', self.armorIcon, 'RIGHT', 5, 0)

  self.armorFrame:SetSize(5 + iconSize + self.armorText:GetStringWidth(), xb:GetHeight())

  self.armorButton:SetAllPoints()

  local relativeAnchorPoint = 'RIGHT'
  local xOffset = xb.db.profile.general.moduleSpacing

  local parentFrame = xb:GetFrame('microMenuFrame');
  if not xb.db.profile.modules.microMenu.enabled then
	parentFrame = self.armorFrame:GetParent()
	relativeAnchorPoint = 'LEFT'
	xOffset = 0
  end

  self.armorFrame:ClearAllPoints()
  self.armorFrame:SetPoint('LEFT', parentFrame, relativeAnchorPoint, xOffset, 0)
  self:SetArmorColor()
end

function ArmorModule:UPDATE_INVENTORY_DURABILITY()
  self:Refresh()
end

function ArmorModule:UpdateDurabilityText()
  local total = 0
  local maxTotal = 0
  local db =  xb.db.profile.modules.armor
  local text = ''

  for i,v in pairs(self.durabilityList) do
	local curDur, maxDur = GetInventoryItemDurability(i)
	if curDur ~= nil and maxDur ~= nil then
	  total = total + curDur
	  maxTotal = maxTotal + maxDur
	  v.cur = curDur
	  v.max = maxDur
	end
  end
  self.durabilityAverage = floor((total / maxTotal) * 100)

  if (self.durabilityAverage >= db.durabilityMax) or db.alwaysShowIlvl then
	local _, equippedIlvl = GetAverageItemLevel()
	text = floor(equippedIlvl)..' ilvl'
  end

  if self.durabilityAverage <= db.durabilityMax then
	text = text..' '..self.durabilityAverage..'%'
  end



  self.armorText:SetText(text)
end

function ArmorModule:GetDefaultOptions()
  return 'armor', {
	  enabled = true,
	  durabilityMin = 20,
	  durabilityMax = 75,
	  alwaysShowIlvl = true
	}
end

function ArmorModule:GetConfig()
  return {
	name = self:GetName(),
	type = "group",
	args = {
	  enable = {
		name = ENABLE,
		order = 0,
		type = "toggle",
		get = function() return xb.db.profile.modules.armor.enabled; end,
		set = function(_, val)
		  xb.db.profile.modules.armor.enabled = val
		  if val then
			self:Enable()
		  else
			self:Disable()
			xb:Refresh()
		  end
		end
	  },
	  ilvlAlways = {
		name = L['Always Show Item Level'],
		order = 1,
		type = "toggle",
		get = function() return xb.db.profile.modules.armor.alwaysShowIlvl; end,
		set = function(_, val) xb.db.profile.modules.armor.alwaysShowIlvl = val; self:Refresh(); end
	  },
	  duraMin = {
		name = L['Minimum Durability to Become Active'],
		type = 'range',
		order = 2,
		min = 0,
		max = 100,
		step = 5,
		get = function() return xb.db.profile.modules.armor.durabilityMin; end,
		set = function(info, val) xb.db.profile.modules.armor.durabilityMin = val; self:Refresh(); end
	  },
	  duraMax = {
		name = L['Maximum Durability to Show Item Level'],
		type = 'range',
		order = 3,
		min = 0,
		max = 100,
		step = 5,
		get = function() return xb.db.profile.modules.armor.durabilityMax; end,
		set = function(info, val) xb.db.profile.modules.armor.durabilityMax = val; self:Refresh(); end,
		disabled = function() return xb.db.profile.modules.armor.alwaysShowIlvl; end
	  }
	}
  }
end ]]
