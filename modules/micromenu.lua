local AddOnName, Engine = ...;
local _G = _G;
local xb = Engine[1];
local L = Engine[2];
local P = {};

MenuModule = xb:NewModule("MenuModule")

function MenuModule:GetName()
  return L['Micromenu'];
end

function MenuModule:OnInitialize()
  P = xb.db.profile
  self.mediaFolder = xb.constants.mediaPath..'microbar\\'
  self.icons = {}
  self.frames = {}
end

function MenuModule:OnEnable()
  self.microMenuFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
  xb:RegisterFrame('microMenuFrame', self.microMenuFrame)

  self:CreateFrames()
  self:RegisterFrameEvents()
  self:CreateIcons()
  self:Refresh()
end

function MenuModule:OnDisable()
end

function MenuModule:Refresh()
  if self.frames.menu == nil then return; end

  self.iconSize = xb:GetHeight();

  local colors = P.color
  local totalWidth = 0;
  for name, frame in pairs(self.frames) do
    self:IconDefaults(name)
    totalWidth = totalWidth + frame:GetWidth() + 2
    if name == 'menu' then
      frame:SetPoint("LEFT", 2, 0)
    else
      frame:SetPoint("LEFT", frame:GetParent(), "RIGHT", 2, 0)
    end
  end
  self.microMenuFrame:SetPoint("LEFT")
  self.microMenuFrame:SetSize(totalWidth, xb:GetHeight())
end

function MenuModule:CreateFrames()
  self.frames.menu = CreateFrame("BUTTON", nil, xb:GetFrame('microMenuFrame'))

  self.frames.socialParent = CreateFrame("FRAME", nil, self.frames.menu)
  self.frames.chat = CreateFrame("BUTTON", nil, self.frames.socialParent)
  self.frames.guild = CreateFrame("BUTTON", nil, self.frames.chat)
  self.frames.social = CreateFrame("BUTTON", nil, self.frames.guild)

  self.frames.microbar = CreateFrame("FRAME", nil, self.frames.social)
  self.frames.char = CreateFrame("BUTTON", nil, self.frames.microbar)
  self.frames.spell = CreateFrame("BUTTON", nil, self.frames.char)
  self.frames.talent = CreateFrame("BUTTON", nil, self.frames.spell)
  self.frames.ach = CreateFrame("BUTTON", nil, self.frames.talent)
  self.frames.quest = CreateFrame("BUTTON", nil, self.frames.ach)
  self.frames.lfg = CreateFrame("BUTTON", nil, self.frames.quest)
  self.frames.journal = CreateFrame("BUTTON", nil, self.frames.lfg)
  self.frames.pvp = CreateFrame("BUTTON", nil, self.frames.journal)
  self.frames.pet = CreateFrame("BUTTON", nil, self.frames.pvp)
  self.frames.shop = CreateFrame("BUTTON", nil, self.frames.pet)
  self.frames.help = CreateFrame("BUTTON", nil, self.frames.shop)
end

function MenuModule:CreateIcons()
  for name, frame in pairs(self.frames) do
    if frame['Click'] ~= nil then --Odd way of checking if it's a button
      self.icons[name] = frame:CreateTexture(nil, "OVERLAY")
      self.icons[name]:SetTexture(self.mediaFolder..name)
    end
  end
end

function MenuModule:IconDefaults(name)
  local colors = P.color
  if self.frames[name] == nil then return; end
  if self.frames[name]['Click'] ~= nil then
    self.frames[name]:SetSize(self.iconSize, self.iconSize)
  else
    self.frames[name]:SetSize(floor(self.iconSize / 3), self.iconSize)
  end

  if self.icons[name] == nil then return; end
  self.icons[name]:SetPoint('CENTER')
  self.icons[name]:SetSize(self.iconSize, self.iconSize)
  self.icons[name]:SetVertexColor(colors.normal.r, colors.normal.g, colors.normal.b, colors.normal.a)
end

function MenuModule:RegisterFrameEvents()
  for name, frame in pairs(self.frames) do
    frame:EnableMouse(true)

    if frame['Click'] ~= nil then
      frame:RegisterForClicks("AnyUp")
    end
    frame:SetScript("OnEnter", self:DefaultHover(name))
    frame:SetScript("OnLeave", self:DefaultLeave(name))
  end
  self.frames.menu:SetScript('OnClick', self:MainMenuClick())
end

function MenuModule:DefaultHover(name)
  return function()
    if InCombatLockdown() then return; end
    if self.icons[name] ~= nil then
      self.icons[name]:SetVertexColor(unpack(xb:HoverColors()))
    end
  end
end

function MenuModule:DefaultLeave(name)
  return function()
    if InCombatLockdown() then return; end
    if self.icons[name] ~= nil then
      self.icons[name]:SetVertexColor(P.color.normal.r, P.color.normal.g, P.color.normal.b, P.color.normal.a)
    end
  end
end

function MenuModule:MainMenuClick()
  return function(self, button, down)
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
  end
end

function MenuModule:GetDefaultOptions()
  return 'microMenu', {
      enabled = true,
      showTooltips = true
    }
end

function MenuModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = L['Enabled'],
        order = 0,
        type = "toggle",
        get = function() return P.modules.microMenu.enabled; end,
        set = function(_, val) P.modules.microMenu.enabled = val; end
      },
      showTooltips = {
        name = L['Show Social Tooltips'],
        order = 0,
        type = "toggle",
        get = function() return P.modules.microMenu.showTooltips; end,
        set = function(_, val) P.modules.microMenu.showTooltips = val; end
      }
    }
  }
end
