local addOnName, XB = ...;

local Vol = XB:RegisterModule("Volume")

----------------------------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------------------------
local ccR,ccG,ccB = GetClassColor(XB.playerClass)
local libTT
local volumeFrame,volumeIcon,volumeText
local Bar,BarFrame
local vol_config

----------------------------------------------------------------------------------------------------------
-- Private functions
----------------------------------------------------------------------------------------------------------
local function refreshOptions()
  Bar,BarFrame = XB:GetModule("Bar"),XB:GetModule("Bar"):GetFrame()
end

local function tooltip()
  if libTT:IsAcquired("VolumeTooltip") then
	libTT:Release(libTT:Acquire("VolumeTooltip"))
  end

  local tooltip = libTT:Acquire("VolumeTooltip", 2)
  tooltip:SmartAnchorTo(volumeFrame)
  tooltip:SetAutoHideDelay(.3, volumeFrame)
  tooltip:AddHeader("[|cff6699FF"..MASTER_VOLUME.."|r]")
  tooltip:AddLine("|cffffff00<Left-Click>|r", "|cffffffff"..BINDING_NAME_MASTERVOLUMEUP.."|r")
  tooltip:AddLine("|cffffff00<Right-Click>|r", "|cffffffff"..BINDING_NAME_MASTERVOLUMEDOWN.."|r")
  
  XB:SkinTooltip(tooltip,"VolumeTooltip")
  tooltip:Show();
end

local function masterVolume_Update_Value()
	local volume = tonumber(GetCVar("Sound_MasterVolume"));
	local volumePercent = (volume * 100);
	local volumePercentTrimed = tonumber(string.format("%."..Vol.settings.floatPrecision.."f", volumePercent));

	return volumePercentTrimed;
end

local function hooks()
	hooksecurefunc("Sound_MasterVolumeUp", masterVolume_Update_Value)
	hooksecurefunc("Sound_MasterVolumeDown", masterVolume_Update_Value)

	hooksecurefunc("SetCVar", function(cvar, value)
		if cvar == "Sound_MasterVolume" then
			masterVolume_Update_Value()
		end
	end)
end

----------------------------------------------------------------------------------------------------------
-- Options
----------------------------------------------------------------------------------------------------------
local vol_default = {
	profile = {
		enable = true,
		lock = true,
		x = 700,
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
		step = 0.1,
		floatPrecision = 1
	}
}

----------------------------------------------------------------------------------------------------------
-- Module functions
----------------------------------------------------------------------------------------------------------
function Vol:OnInitialize()
  libTT = LibStub('LibQTip-1.0')
  self.db = XB.db:RegisterNamespace("Volume", vol_default)
  self.settings = self.db.profile
end

function Vol:OnEnable()
  self.settings.lock = self.settings.lock or not self.settings.lock
  refreshOptions()
  XB.Config:Register("Volume",vol_config)
	if self.settings.enable then
		self:CreateFrames()
	else
		self:Disable()
	end

	masterVolume_Update_Value()
	hooks()
end

function Vol:OnDisable()
  
end

function Vol:CreateFrames()
	if not self.settings.enable then
	  if volumeFrame and volumeFrame:IsVisible() then
		volumeFrame:Hide()
	  end
	  return
	end

	local x,y,w,h,color,hover,anchor = self.settings.x,self.settings.y,self.settings.w,self.settings.h,self.settings.color,self.settings.hover,self.settings.anchor

	volumeFrame = volumeFrame or CreateFrame("Button","Volume",BarFrame)
	volumeFrame:ClearAllPoints()
	volumeFrame:SetPoint(anchor,x,y)
	volumeFrame:SetMovable(true)
	volumeFrame:SetClampedToScreen(true)
	volumeFrame:RegisterForClicks("AnyUp")
	volumeFrame:Show()

	if not volumeFrame:IsEventRegistered("PLAYER_ENTERING_WORLD") then
		volumeFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		volumeFrame:RegisterEvent("CVAR_UPDATE")
	end

	volumeIcon = volumeIcon or volumeFrame:CreateTexture(nil,"OVERLAY",nil,7)
	volumeIcon:ClearAllPoints()
	volumeIcon:SetPoint("LEFT")
	volumeIcon:SetSize(w,h)
	volumeIcon:SetTexture(XB.mediaFold.."datatexts\\sound")
	volumeIcon:SetVertexColor(unpack(color))

	volumeText = volumeText or volumeFrame:CreateFontString(nil, "OVERLAY")
	volumeText:SetPoint("RIGHT", volumeFrame,2,0)
	volumeText:SetFont(XB.mediaFold.."font\\homizio_bold.ttf", 12)
	volumeText:SetTextColor(unpack(color))

	volumeText:SetText(masterVolume_Update_Value().." %")
	volumeFrame:SetSize(volumeText:GetStringWidth()+2+w, h)

	XB:AddOverlay(self,volumeFrame,anchor)

	-- Event handling
	if not volumeFrame:GetScript("OnEvent") then
		volumeFrame:SetScript("OnEvent", function()
			masterVolume_Update_Value();
		end)

		volumeFrame:SetScript("OnEnter", function()
			if InCombatLockdown() and not self.settings.combatEn then return end
				volumeIcon:SetVertexColor(unpack(hover))
			if Vol.settings.tooltip then
				tooltip()
			end
		end)
		
		volumeFrame:SetScript("OnClick", function(_, button, down)
			local volume = tonumber(GetCVar("Sound_MasterVolume"));
			
			if button == "LeftButton" then
				SetCVar( "Sound_MasterVolume", volume + self.settings.step);
			elseif button == "RightButton" then
				SetCVar( "Sound_MasterVolume", volume - self.settings.step);
			end

			volume = tonumber(GetCVar("Sound_MasterVolume"));
			if volume <=0 then SetCVar( "Sound_MasterVolume", 0); end
			if volume >=1 then SetCVar( "Sound_MasterVolume", 1); end

			volumeText:SetText(masterVolume_Update_Value().." %")
			volumeFrame:SetSize(volumeText:GetStringWidth()+2+w, h)
		end)
		
		volumeFrame:SetScript("OnLeave", function()
			if libTT:IsAcquired("VolumeTooltip") then
				libTT:Release(libTT:Acquire("VolumeTooltip"))
			end
			volumeIcon:SetVertexColor(unpack(color))
		end)
	end

	if not self.settings.lock then
		volumeFrame.overlay:Show()
		volumeFrame.overlay.anchor:Show()
	else
		volumeFrame.overlay:Hide()
		volumeFrame.overlay.anchor:Hide()
	end
end