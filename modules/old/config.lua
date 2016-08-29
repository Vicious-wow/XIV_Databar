local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------

if not cfg.useConfig then return end

local configFrame = CreateFrame("Frame",nil,cfg.SXconfigFrame,"ButtonFrameTemplate")
configFrame:SetSize(350,400)
configFrame:ClearAllPoints()
configFrame:SetPoint("TOPLEFT",UIparent,20,-75)
--configFrame:SetScale(1.5)
configFrame:SetClampedToScreen(true)
configFrame:EnableMouse(true)
configFrame:SetMovable(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart",configFrame.StartMoving)
configFrame:SetScript("OnDragStop",configFrame.StopMovingOrSizing)

local icon = configFrame:CreateTexture("$parentIcon", "OVERLAY", nil, -8)
icon:SetSize(60,60)
icon:SetPoint("TOPLEFT",-5,7)
icon:SetTexture("Interface\\FriendsFrame\\Battlenet-Portrait")
--SetPortraitTexture(icon, "Interface\\FriendsFrame\\Battlenet-Portrait")
--icon:SetTexCoord(0,1,0,1)

local configFrameText = configFrame:CreateFontString(nil, "OVERLAY")
configFrameText:SetFont(STANDARD_TEXT_FONT, cfg.text.normalFontSize, "OUTLINE")
configFrameText:SetPoint("TOP",0,-6)
configFrameText:SetText(addon.." Configuration")

local globalCheckButton = CreateFrame("CheckButton", "globalCheckButton", configFrame, "UICheckButtonTemplate")
globalCheckButton:ClearAllPoints()
globalCheckButton:SetPoint("TOPLEFT",60,-25)
_G[globalCheckButton:GetName() .. "Text"]:SetText("Use Module Coloring")
globalCheckButton:SetScript("OnClick", function(self,event,arg1) 
	if self:GetChecked() then
		UIDropDownMenu_EnableDropDown(globalModuleDropdown)
		globalActiveModuleText:SetTextColor(1,1,1,1)	
	else
		UIDropDownMenu_DisableDropDown(globalModuleDropdown)
		UIDropDownMenu_SetText(dropDown, "Select Module")
		globalActiveModuleText:SetTextColor(1,1,1,0.4)
	end
end)


local resetButton = CreateFrame("Button", "MyButton", configFrame, "UIPanelButtonTemplate")
resetButton:SetSize(80 ,22) -- width, height
resetButton:SetText("Reset Color")
resetButton:SetPoint("TOPRIGHT",-10,-30)
resetButton:SetScript("OnClick", function()
	if IsShiftKeyDown() then
	cfg.color = {
		normal = {1,1,1,.75},
		inactive = {1,1,1,.25},
		hover = {cfg.cc.r,cfg.cc.g,cfg.cc.b,.75},
		barcolor = {.094,.094,.102,.45},
	}
	print"The colors have been set to default."
	else
	print"Hold <Shift> if you want to set the colors to default."
	end
end)


local activeModuleText = configFrame:CreateFontString(nil, "OVERLAY")
activeModuleText:SetFont(STANDARD_TEXT_FONT, cfg.text.normalFontSize, "OUTLINE")
activeModuleText:SetPoint("TOPRIGHT",configFrame,"TOP",-20,-75)
activeModuleText:SetText("Active Module:")
globalActiveModuleText = activeModuleText

local dropDown = CreateFrame("frame", "selectModuleDropDown", configFrame, "UIDropDownMenuTemplate")
dropDown:SetPoint("LEFT",activeModuleText, "RIGHT", -10,-5)
UIDropDownMenu_SetText(dropDown, "Select Module")
UIDropDownMenu_JustifyText(dropDown, "LEFT") 

globalModuleDropdown = dropDown

local modules = {
	"None",
	"Micromenu",
	"Armor",
	"Talent",
	"Clock",
	"Trade Skill",
	"Currency",
	"System",
	"Gold",
	"Heartstone",
}
 
local function OnClick(self)
	UIDropDownMenu_SetSelectedID(dropDown, self:GetID())
	if self:GetID() == 1 then
	
	elseif self:GetID() == 2 then
	
	elseif self:GetID() == 3 then
	
	elseif self:GetID() == 4 then
	 	
	elseif self:GetID() == 5 then
	 	
	elseif self:GetID() == 6 then
	 	
	elseif self:GetID() == 7 then
	 	
	elseif self:GetID() == 8 then
	 	
	elseif self:GetID() == 9 then
	 	
	elseif self:GetID() == 10 then
	 
	end
end
 
local function initialize(self, level)
   local info = UIDropDownMenu_CreateInfo()
   for k,v in pairs(modules) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v
      info.value = v
      info.func = OnClick
      UIDropDownMenu_AddButton(info, level)
   end
end

UIDropDownMenu_Initialize(dropDown, initialize)
UIDropDownMenu_SetWidth(dropDown, 100);
UIDropDownMenu_SetButtonWidth(dropDown, 75)


local function showColorPicker(r,g,b,a,callback)
	ColorPickerFrame:SetColorRGB(r,g,b)
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a
	ColorPickerFrame.previousValues = {r,g,b,a}
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = callback, callback, callback
	ColorPickerFrame:Hide() -- Need to run the OnShow handler.
	ColorPickerFrame:Show()
end

local barColorFrame = CreateFrame("FRAME",nil,configFrame)
barColorFrame:SetSize(18,18)
barColorFrame:SetPoint("TOPLEFT",configFrame,15,-100)
--text
barColorFrame.text = barColorFrame:CreateFontString(nil, "OVERLAY")
barColorFrame.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
barColorFrame.text:SetPoint("CENTER")
barColorFrame.text:SetText("Bar Color")
barColorFrame.text:SetTextColor(1,1,1,.75)
barColorFrame:SetWidth(barColorFrame.text:GetStringWidth())

local normalColor = CreateFrame("FRAME",nil,configFrame)
normalColor:SetSize(100,20)
normalColor:SetPoint("TOPLEFT",barColorFrame,0,-40)
--text
normalColor.text = normalColor:CreateFontString(nil, "OVERLAY")
normalColor.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
normalColor.text:SetPoint("CENTER")
normalColor.text:SetText("Normal Color")
normalColor.text:SetTextColor(1,1,1,.75)
normalColor:SetWidth(normalColor.text:GetStringWidth())

local inactiveColor = CreateFrame("FRAME",nil,configFrame)
inactiveColor:SetSize(100,20)
inactiveColor:SetPoint("TOPLEFT",normalColor,0,-40)
--text
inactiveColor.text = inactiveColor:CreateFontString(nil, "OVERLAY")
inactiveColor.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
inactiveColor.text:SetPoint("CENTER")
inactiveColor.text:SetText("Inactive Color")
inactiveColor.text:SetTextColor(1,1,1,.25)
inactiveColor:SetWidth(normalColor.text:GetStringWidth())

local hoverColorFrame = CreateFrame("FRAME",nil,configFrame)
hoverColorFrame:SetSize(18,18)
hoverColorFrame:SetPoint("TOPLEFT",inactiveColor,0,-40)
--text
hoverColorFrame.text = hoverColorFrame:CreateFontString(nil, "OVERLAY")
hoverColorFrame.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
hoverColorFrame.text:SetPoint("CENTER")
hoverColorFrame.text:SetText("Hover Color")
hoverColorFrame.text:SetTextColor(cfg.cc.r,cfg.cc.g,cfg.cc.b,.75)
hoverColorFrame:SetWidth(hoverColorFrame.text:GetStringWidth())

--recolor callback function
normalColor.recolorTexture = function(color)
	local r,g,b,a
	if color then
		r,g,b,a = unpack(color)
	else
		r,g,b = ColorPickerFrame:GetColorRGB()
		a = OpacitySliderFrame:GetValue()
	end
	normalColor.text:SetTextColor(r,g,b,a)
	cfg.color.normal = {r,g,b,a}
	globalNormColSlider:SetValue(a*100)
	globalNormColEditBox:SetNumber(a*100)
end
normalColor:EnableMouse(true)
normalColor:SetScript("OnMouseDown", function(self,button,...)
	if button == "LeftButton" then
		local r,g,b,a = self.text:GetTextColor()
		showColorPicker(r,g,b,a,self.recolorTexture)
	end
end)

local normalClassColorCheckButton = CreateFrame("CheckButton", "classColorNormalCheckButton", normalColor, "UIRadioButtonTemplate")
normalClassColorCheckButton:ClearAllPoints()
normalClassColorCheckButton:SetPoint("RIGHT",50,0)
_G[normalClassColorCheckButton:GetName() .. "Text"]:SetText("Class color")
normalClassColorCheckButton:SetScript("OnClick", function(self,event,arg1) 
	if self:GetChecked() then		
		normalColor.text:SetTextColor(cfg.cc.r,cfg.cc.g,cfg.cc.b)
		normalColor:EnableMouse(false)
		globalNormColEditBox:Enable()
		globalNormColSlider:Enable()
		globalNormColSlider:SetAlpha(1)
	else
		normalColor.text:SetTextColor(1,1,1,.75)
		normalColor:EnableMouse(true)
		globalNormColEditBox:Disable()
		globalNormColSlider:Disable()
		globalNormColSlider:SetAlpha(.4)
	end
end)

local slider = CreateFrame("Slider","MyExampleSlider",normalClassColorCheckButton,"OptionsSliderTemplate") --frameType, frameName, frameParent, frameTemplate 
slider:SetPoint("TOPLEFT",0,-30)
slider.textLow = _G["MyExampleSlider".."Low"]
slider.textHigh = _G["MyExampleSlider".."High"]
slider.text = _G["MyExampleSlider".."Text"]
slider:SetMinMaxValues(0, 100)
slider.minValue, slider.maxValue = slider:GetMinMaxValues() 
slider.textLow:SetText(slider.minValue)
slider.textHigh:SetText(slider.maxValue)
slider.text:SetText("Class Color Alpha:")
slider:SetValue(100)
slider:SetValueStep(1)
slider:Disable()
slider:SetAlpha(.4)
slider:SetScript("OnValueChanged", function(self,event,arg1)
	normalColor.text:SetAlpha(event/100)
	globalNormColEditBox:SetNumber(event)
end)
globalNormColSlider = slider

local EditBox = CreateFrame("EditBox",nil,slider)
EditBox:SetWidth(32)
EditBox:SetHeight(16)
EditBox:SetPoint("LEFT",slider.text,"RIGHT",2,0)
EditBox:SetFontObject(GameFontNormal)
EditBox:SetAutoFocus(false)
EditBox:SetMaxLetters(3)
EditBox:SetNumeric()
EditBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
	globalNormColSlider:SetValue(EditBox:GetNumber())
end)

globalNormColEditBox = EditBox

--[
UIDropDownMenu_DisableDropDown(globalModuleDropdown)
globalActiveModuleText:SetTextColor(1,1,1,0.4)
globalNormColEditBox:Disable()
--]]