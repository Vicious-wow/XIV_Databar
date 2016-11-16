local addon, xb = ...
local _G = _G;
local L = xb.L;

local VolumeModule = xb:NewModule("VolumeModule", 'AceEvent-3.0')

function VolumeModule:GetName()
  return "MasterVolume";
end

function VolumeModule:OnInitialize()
self.frame = nil
self.icon = nil
self.text = nil
end

function VolumeModule:OnEnable()
	if self.frame == nil then
		self:CreateModuleFrame()
		self:RegisterEvents()
		self:MasterVolume_Update_Value()
		self:Hooks()
	else
		self.frame:Show()
		self:RegisterEvents()
	end
end

function VolumeModule:OnDisable()
	if self.frame then
		self.frame:Hide()
		self.frame:UnregisterAllEvents()
	end
end

function VolumeModule:CreateModuleFrame()
	self.frame=CreateFrame("BUTTON","masterVolume", xb:GetFrame('bar'))
	xb:RegisterFrame('volumeFrame',self.frame)
	self.frame:EnableMouse(true)
	self.frame:RegisterForClicks("AnyDown")

	local relativeAnchorPoint = 'RIGHT'
	local xOffset = xb.db.profile.general.moduleSpacing
	local parentFrame = xb:GetFrame('armorFrame')
	if not xb.db.profile.modules.armor.enabled then
		parentFrame=xb:GetFrame('microMenuFrame')
		if not xb.db.profile.modules.microMenu.enabled then
			parentFrame=xb:GetFrame('bar')
			relativeAnchorPoint = 'LEFT'
			xOffset = 0
		end
	end

	self.frame:SetPoint('LEFT', parentFrame, relativeAnchorPoint, xOffset, 0)
	
	self.icon = self.frame:CreateTexture(nil,"OVERLAY",nil,7)
	self.icon:SetPoint("LEFT")
	self.icon:SetTexture(xb.constants.mediaPath.."datatexts\\sound")
	self.icon:SetVertexColor(xb:GetColor('normal'))
	
	self.text = self.frame:CreateFontString(nil, "OVERLAY")
	self.text:SetFont(xb:GetFont(xb.db.profile.text.fontSize))
	self.text:SetPoint("RIGHT", self.frame,2,0)
	self.text:SetTextColor(xb:GetColor('inactive'))
end

function VolumeModule:RegisterEvents()
	self.frame:SetScript("OnEnter", function()
		if InCombatLockdown() then return end
		self.icon:SetVertexColor(xb:GetColor('hover'))
		self.text:SetTextColor(xb:GetColor('hover'))

		GameTooltip:SetOwner(self.frame, "ANCHOR_BOTTOM")
		GameTooltip:AddLine("[|cff6699FF"..MASTER_VOLUME.."|r]")
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("<"..L['Left-Click']..">", "|cffffffff"..BINDING_NAME_MASTERVOLUMEUP.."|r")
		GameTooltip:AddDoubleLine("<"..L['Right-Click']..">", "|cffffffff"..BINDING_NAME_MASTERVOLUMEDOWN.."|r")
		GameTooltip:Show()
	end)
	
	self.frame:SetScript("OnClick", function(self, button, down)
		local volume = tonumber(GetCVar("Sound_MasterVolume"));
		
		if button == "LeftButton" then
		
		SetCVar( "Sound_MasterVolume", volume + xb.db.profile.modules.MasterVolume.step);

		elseif button == "RightButton" then
		SetCVar( "Sound_MasterVolume", volume - xb.db.profile.modules.MasterVolume.step);
		end
		volume = tonumber(GetCVar("Sound_MasterVolume"));
		if volume <=0 then SetCVar( "Sound_MasterVolume", 0); end
		if volume >=1 then SetCVar( "Sound_MasterVolume", 1); end
	end)
	
	self.frame:SetScript("OnLeave", function()
		self.icon:SetVertexColor(xb:GetColor('normal'))
		self.text:SetTextColor(xb:GetColor('inactive'))
		GameTooltip:Hide();
	end)
	
	self.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.frame:RegisterEvent("CVAR_UPDATE");
	self.frame:SetScript("OnEvent", function(self,event, ...)
		VolumeModule:MasterVolume_Update_Value();
	end)
end

function VolumeModule:Refresh()
	if not xb.db.profile.modules.MasterVolume.enabled then self:Disable(); return; end

	if not self.frame and xb.db.profile.modules.MasterVolume.enabled then
		self:Enable()
		return;
	end

	if self.frame then
		self.frame:Hide()
		local relativeAnchorPoint = 'RIGHT'
		local xOffset = xb.db.profile.general.moduleSpacing
		local parentFrame = xb:GetFrame('armorFrame')
		if not xb.db.profile.modules.armor.enabled then
			parentFrame=xb:GetFrame('microMenuFrame')
			if not xb.db.profile.modules.microMenu.enabled then
				parentFrame=xb:GetFrame('bar')
				relativeAnchorPoint = 'LEFT'
				xOffset = 0
			end
		end
		self.frame:SetPoint('LEFT', parentFrame, relativeAnchorPoint, xOffset, 0)
		self.frame:Show()
	end
end

function VolumeModule:MasterVolume_Update_Value()
	local volume = tonumber(GetCVar("Sound_MasterVolume"));
	local volumePercent = (volume * 100);
	local volumePercentTrimed = tonumber(string.format("%.1f", volumePercent));
	if self.text and self.frame then
		self.text:SetText(volumePercentTrimed.." %")
		self.frame:SetSize(self.text:GetStringWidth()+18, 16)
	end
end

function VolumeModule:Hooks()
	hooksecurefunc("Sound_MasterVolumeUp", VolumeModule.MasterVolume_Update_Value)
	hooksecurefunc("Sound_MasterVolumeDown", VolumeModule.MasterVolume_Update_Value)

	hooksecurefunc("SetCVar", function(cvar, value)
		if cvar == "Sound_MasterVolume" then
			VolumeModule:MasterVolume_Update_Value()
		end
	end)
end

function VolumeModule:GetDefaultOptions()
  return self:GetName(), {
      enabled = false,
      step = 0.1
    }
end

function VolumeModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.MasterVolume.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.MasterVolume.enabled = val
          if val then
            self:Enable();
          else
            self:Disable();
          end
        end,
        width = "full"
      },
	  step = {
		name = L["Volume step"],
		order = 1,
		type = "range",
		min = 1,
		max = 50,
		step = 1,
		get = function() return xb.db.profile.modules.MasterVolume.step*100; end,
		set = function(_,val) xb.db.profile.modules.MasterVolume.step = val/100.0; end
	  }
	  }
  }
 end