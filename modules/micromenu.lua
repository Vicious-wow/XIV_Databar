local AddOnName, Engine = ...;
local _G = _G;
local xb = Engine[1];
local L = Engine[2];
local P = {};

MenuModule = xb:NewModule("MenuModule", 'AceEvent-3.0')

function MenuModule:GetName()
  return L['Micromenu'];
end

function MenuModule:OnInitialize()
  P = xb.db.profile
  self.mediaFolder = xb.constants.mediaPath..'microbar\\'
  self.icons = {}
  self.frames = {}
  self.text = {}
  self.bgTexture = {}
end

function MenuModule:OnEnable()
  self.microMenuFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
  xb:RegisterFrame('microMenuFrame', self.microMenuFrame)

  self:CreateFrames()
  self:RegisterFrameEvents()
  self:CreateIcons()
  self:Refresh()
  self:UpdateGuildText()
end

function MenuModule:OnDisable()
end

function MenuModule:Refresh()
  if self.frames.menu == nil then return; end

  self.iconSize = xb:GetHeight();
  self.textPosition = "TOP"
  if P.general.barPosition == 'TOP' then
    self.textPosition = 'BOTTOM'
  end

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

  for name, frame in pairs(self.text) do
    frame:SetPoint('CENTER', self.frames[name], self.textPosition)
    self.bgTexture[name]:SetColorTexture(P.color.barColor.r, P.color.barColor.g, P.color.barColor.b, P.color.barColor.a)
    self.bgTexture[name]:SetPoint('CENTER', frame)
  end
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

  self.text.guild = self.frames.guild:CreateFontString(nil, 'OVERLAY')
  self.bgTexture.guild = self.frames.guild:CreateTexture(nil, "OVERLAY")

  self.text.social = self.frames.social:CreateFontString(nil, 'OVERLAY')
  self.bgTexture.social = self.frames.social:CreateTexture(nil, "OVERLAY")
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

  self.frames.chat:SetScript('OnClick', self:ChatClick())
  self.frames.guild:SetScript('OnClick', self:GuildClick())
  self:RegisterEvent('GUILD_ROSTER_UPDATE', 'UpdateGuildText')
  self.frames.social:SetScript('OnClick', self:SocialClick())
  self:RegisterEvent('BN_FRIEND_ACCOUNT_ONLINE', 'UpdateFriendText')
  self:RegisterEvent('BN_FRIEND_ACCOUNT_OFFLINE', 'UpdateFriendText')
  self:RegisterEvent('FRIENDLIST_UPDATE', 'UpdateFriendText')

  self.frames.char:SetScript('OnClick', self:CharacterClick())
end

function MenuModule:UpdateGuildText()
  if IsInGuild() then
    local _, onlineMembers = GetNumGuildMembers()
    self.text.guild:SetText(onlineMembers)
  else
    self.text.guild:Hide()
    self.bgTexture.guild:Hide()
  end
end

function MenuModule:UpdateFriendText()
  local _, bnOnlineMembers = BNGetNumFriends()
  local _, friendsOnline = GetNumFriends()
  local totalFriends = bnOnlineMembers + friendsOnline
  self.text.social:SetText(totalFriends)

  if IsInGuild() then
    local _, onlineMembers = GetNumGuildMembers()
    self.text.guild:SetText(onlineMembers)
  else
    self.text.guild:Hide()
    self.bgTexture.guild:Hide()
  end
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

function MenuModule:ChatClick()
  return function(self, button, down)
    if InCombatLockdown() then return; end
  	if button == "LeftButton" then
      ChatFrame_OpenMenu()
    end
  end
end

function MenuModule:GuildClick()
  return function(self, button, down)
  	if InCombatLockdown() then return end
  	--[[if button == "LeftButton" then
  		if ( IsInGuild() ) then
  			ToggleGuildFrame()
  			GuildFrameTab2:Click()
  		else
  			ToggleGuildFinder()
  		end
  	end]]--
    ToggleGuildFrame()
  end
end

function MenuModule:SocialClick()
  return function(self, button, down)
  end
end

function MenuModule:CharacterClick()
  return function(self, button, down)
  	if InCombatLockdown() then return end
  	if button == "LeftButton" then
  		ToggleCharacter("PaperDollFrame")
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
