local addOnName, XB = ...;

local Teleports = XB:RegisterModule("Teleports")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT
local teleports_config
local Bar, BarFrame
local teleportsGroupFrame, teleport_buttons, teleport_popup = nil, {}, nil
local usableItems, itemsOnCd = {}, {}

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function checkItem(itemId)
	local isItem = IsUsableItem(itemId)
	local isToy = PlayerHasToy(itemId)

	return isItem or isToy
end

local function tooltip()
  if libTT:IsAcquired("Tooltip") then
	libTT:Release(libTT:Acquire("Tooltip"))
  end

  Teleports:FindUsableTeleports()

  local tooltip = libTT:Acquire("Tooltip", 2)
  tooltip:SmartAnchorTo(teleport_buttons[1])
  tooltip:SetAutoHideDelay(.5, teleport_buttons[1])
  tooltip:AddHeader("[|cff6699FF".."Teleports CDs".."|r]")
  tooltip:AddLine(" ")
  if #itemsOnCd > 0 then
	  for i,v in ipairs(itemsOnCd) do
		local name = ""
		if checkItem(v[1]) then
			name = GetItemSpell(v[1])
		else
			name = GetSpellInfo(v[1])
		end
		tooltip:AddLine(name.." "..SecondsToTime(v[2]-GetTime()))
	  end
  else
  	tooltip:AddLine("No port under cooldown")
  end
  tooltip:Show()
end

local function refreshOptions()
  Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local teleports_default = {
  profile = {
	enable = true,
	combatEn = false,
	lock = true,
	x = {
		group =-4 ,
		firstTeleport = 0,
		--secTeleport = 100
	},
	y = {
		group = 0,
		firstTeleport = 0,
		--secTeleport = 0
	},
	w = {
		group = 16,
		firstTeleport = 16,
		--secTeleport = 16
	},
	h = {
		group = 16,
		firstTeleport = 16,
		--secTeleport = 16
	},
	anchor = {
		group = "RIGHT",
		firstTeleport = "RIGHT",
		--secTeleport = "LEFT"
	},
	spaceBetween2Teleports = 10,
	color = {
		group = {1,1,1,.75},
		firstTeleport = {1,1,1,.75},
		--secTeleport = {1,1,1,.75}
	},
	hover = {
		group = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
		firstTeleport = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75},
		--secTeleport = XB.playerClass == "PRIEST" and {.5,.5,0,.75} or {ccR,ccG,ccB,.75}
	},
	hoverCC = not (XB.playerClass == "PRIEST"),
	portsSelected = {XB.portOptions.items[1],140192}
  }
}


----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Teleports:OnInitialize()
  libTT = LibStub('LibQTip-1.0')
  self.db = XB.db:RegisterNamespace("Teleports", teleports_default)
	self.settings = self.db.profile
end

function Teleports:OnEnable()
  self.settings.lock = self.settings.lock or not self.settings.lock --Locking frame if it was not locked on reload/relog
  refreshOptions()
  XB.Config:Register("Teleports",teleports_config)
  if self.settings.enable and not self:IsEnabled() then
	self:Enable()
  elseif not self.settings.enable and self:IsEnabled() then
	self:Disable()
  else
	self:CreateFrames()
  end
end

function Teleports:OnDisable()
	if teleportsGroupFrame and teleportsGroupFrame:IsVisible() then
		teleportsGroupFrame:Hide()
	end
end


function Teleports:CreateFrames()
  self:CreateGroupFrame()
  self:CreatePopupFrame()
end

function Teleports:CreateGroupFrame()
	if not self.settings.enable then
		if teleportsGroupFrame and teleportsGroupFrame:IsVisible() then
			teleportsGroupFrame:Hide()
		end
		return
	end
	
	local w,h,x,y,a,color,hover = self.settings.w.group,self.settings.h.group,self.settings.x.group,self.settings.y.group,self.settings.anchor.group,self.settings.color.group,self.settings.hover.group
	
	teleportsGroupFrame = teleportsGroupFrame or CreateFrame("Frame","Teleports",BarFrame)
	teleportsGroupFrame:ClearAllPoints()
	teleportsGroupFrame:SetSize(w, h)
	teleportsGroupFrame:SetPoint(a,x,y)
	teleportsGroupFrame:EnableMouse(true)
	teleportsGroupFrame:SetMovable(true)
	teleportsGroupFrame:SetClampedToScreen(true)
	teleportsGroupFrame:Show()

	self:createTeleportFrame(1)
end

function Teleports:CreatePopupFrame()

	local w,h,x,y,a,color,hover = self.settings.w.group,self.settings.h.group,self.settings.x.group,self.settings.y.group,self.settings.anchor.group,self.settings.color.group,self.settings.hover.group
	
	if not teleport_popup then 
		teleport_popup = CreateFrame('FRAME', nil, teleportsGroupFrame)
		local specPopupTexture = teleport_popup:CreateTexture(nil, 'BACKGROUND')
		local headerTpPopup = teleport_popup:CreateFontString(nil, 'OVERLAY')

		headerTpPopup:SetFont(XB.mediaFold.."font\\homizio_bold.ttf",20)
		headerTpPopup:SetText("Teleports")
		headerTpPopup:SetTextColor(unpack(color))
		headerTpPopup:SetPoint('TOP', 0, -(3))
		headerTpPopup:SetPoint('CENTER')
		teleport_popup:SetSize(50,100)
	end
  	--[[for i,v in ipairs(usableItems) do
		local name = ""
		if checkItem(v) then
			name = GetItemSpell(v)
		else
			name = GetSpellInfo(v)
		end
  	tooltip:AddLine("|cff00eeff"..name.."|r")
  	end--]]
end

function Teleports:createTeleportFrame(index)
	local frameNumber = ""
	if index == 1 then frameNumber = "first" elseif index == 2 then frameNumber = "sec" end
	local w,h,x,y,a,color,hover = self.settings.w[frameNumber.."Teleport"],self.settings.h[frameNumber.."Teleport"],self.settings.x[frameNumber.."Teleport"],self.settings.y[frameNumber.."Teleport"],self.settings.anchor[frameNumber.."Teleport"],self.settings.color[frameNumber.."Teleport"],self.settings.hover[frameNumber.."Teleport"]
	local portId = self.settings.portsSelected[index]
	teleport_buttons[index] = teleport_buttons[index] or CreateFrame("BUTTON","hsButton", teleportsGroupFrame, "SecureActionButtonTemplate")
	local HSFrame = teleport_buttons[index]

	HSFrame:SetPoint(a)
	HSFrame:SetSize(w, h)
	HSFrame:EnableMouse(true)
	HSFrame:RegisterForClicks("AnyUp")
	HSFrame:SetAttribute("type", "macro")

	local HSText = HSFrame:CreateFontString(nil, "OVERLAY")
	HSText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf",12)
	HSText:SetPoint("RIGHT")
	HSText:SetTextColor(unpack(self.settings.color.group))

	local HSIcon = HSFrame:CreateTexture(nil,"OVERLAY",nil,7)
	HSIcon:SetSize(w, h)
	HSIcon:SetPoint("RIGHT", HSText,"LEFT",-2,0)
	HSIcon:SetTexture(XB.icons.hearth)
	HSIcon:SetVertexColor(unpack(self.settings.color.group))

	HSFrame:SetScript("PreClick",function(_, button)
		if button == "LeftButton" then
			local spellItem = GetItemSpell(portId)
			HSFrame:SetAttribute("macrotext", "/use "..spellItem)
		else if button == "RightButton" then
				if HSFrame:GetAttribute("macrotext") then
					HSFrame:SetAttribute("macrotext", "")
				end
				self:CreatePopupFrame()
			end
		end
	end)

	HSFrame:SetScript("OnEnter",function()
		tooltip()
	end)
	
	HSText:SetText(self:GetTeleportName(portId))
	HSFrame:SetWidth(HSText:GetStringWidth())
	if index == 1 then
		teleportsGroupFrame:SetWidth(HSText:GetStringWidth()+HSIcon:GetWidth())
	else
		teleportsGroupFrame:SetWidth(teleportsGroupFrame:GetWidth()+self.settings.spaceBetween2Teleports+HSText:GetStringWidth()+HSIcon:GetWidth())
	end
end

function Teleports:GetTeleportName(id)
	local text = ""
	if id == 6948 then
		text = GetBindLocation()
	else
		text = GetItemInfo(id)
	end
	return string.upper(text)
end

function Teleports:usableTeleport(teleportSet, tps, cds)
	local portSet = CopyTable(teleportSet)
	local firstPortId, criteria, cooldownCriteria = portSet[1], nil, nil

	if GetItemInfo(firstPortId) and GetItemInfoFromHyperlink(select(2,GetItemInfo(firstPortId))) then
		criteria = checkItem
		cooldownCriteria = GetItemCooldown
	else
		criteria = IsSpellKnown
		cooldownCriteria = GetSpellCooldown
	end

	for i,portId in pairs(portSet) do
		local  k,teleportId = FindInTableIf(portSet,criteria)
		if teleportId then
			local start, duration, _ =  cooldownCriteria(teleportId)
			
			if start == 0 and duration == 0 then	
				table.insert(tps,teleportId)
				tremove(portSet,k)
			else
				table.insert(cds,{teleportId, start+duration})
				tremove(portSet,k)
			end
		end
	end

	return tps,cds
end

function Teleports:FindUsableTeleports()
	local items = CopyTable(XB.portOptions.items)
	local spells = CopyTable(XB.portOptions.spells)

	usableItems, itemsOnCd = {}, {}

	usableItems, itemsOnCd = self:usableTeleport(items,usableItems,itemsOnCd)
	usableItems, itemsOnCd = self:usableTeleport(spells,usableItems, itemsOnCd)

	return usableItems
end
