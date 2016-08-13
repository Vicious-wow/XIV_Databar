local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local MenuModule = xb:NewModule("MenuModule", 'AceEvent-3.0')

function MenuModule:GetName()
  return L['Micromenu'];
end

function MenuModule:OnInitialize()
  self.mediaFolder = xb.constants.mediaPath..'microbar\\'
  self.icons = {}
  self.frames = {}
  self.text = {}
  self.bgTexture = {}
  self.functions = {}
  self:CreateClickFunctions()
end

function MenuModule:OnEnable()

  if self.microMenuFrame == nil then
    self.microMenuFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
    xb:RegisterFrame('microMenuFrame', self.microMenuFrame)
  end

  self.microMenuFrame:Show()

  if xb.db.profile.modules.microMenu.enabled then
    self:CreateFrames()
    self:RegisterFrameEvents()
    self:CreateIcons()
    self:Refresh()
    self:UpdateGuildText()
    self:UpdateFriendText()
  end
end

function MenuModule:OnDisable()
  for _, frame in pairs(self.frames) do
    frame:Hide()
  end
  self.microMenuFrame:Hide()
  self:Refresh()
  self:UnregisterFrameEvents()
end

function MenuModule:Refresh()
  if self.frames.menu == nil then return; end

  if not xb.db.profile.modules.microMenu.enabled then return; end

  self.iconSize = xb:GetHeight();
  self.textPosition = "TOP"
  if xb.db.profile.general.barPosition == 'TOP' then
    self.textPosition = 'BOTTOM'
  end

  local colors = xb.db.profile.color
  local totalWidth = 0;
  for name, frame in pairs(self.frames) do
    frame:Show()
    self:IconDefaults(name)
    if name == 'menu' then
      frame:SetPoint("LEFT", xb.db.profile.modules.microMenu.iconSpacing, 0)
      totalWidth = totalWidth + frame:GetWidth() + xb.db.profile.modules.microMenu.iconSpacing
    elseif name == 'chat' then
      frame:SetPoint("LEFT", frame:GetParent(), "RIGHT", xb.db.profile.modules.microMenu.mainMenuSpacing, 0)
      totalWidth = totalWidth + frame:GetWidth() + xb.db.profile.modules.microMenu.mainMenuSpacing
    else
      frame:SetPoint("LEFT", frame:GetParent(), "RIGHT", xb.db.profile.modules.microMenu.iconSpacing, 0)
      totalWidth = totalWidth + frame:GetWidth() + xb.db.profile.modules.microMenu.iconSpacing
    end
  end
  self.microMenuFrame:SetPoint("LEFT")
  self.microMenuFrame:SetSize(totalWidth, xb:GetHeight())

  for name, frame in pairs(self.text) do
    frame:SetFont(xb.LSM:Fetch(xb.LSM.MediaType.FONT, xb.db.profile.text.font), xb.db.profile.text.smallFontSize)
    frame:SetPoint('CENTER', self.frames[name], self.textPosition)
    self.bgTexture[name]:SetColorTexture(xb.db.profile.color.barColor.r, xb.db.profile.color.barColor.g, xb.db.profile.color.barColor.b, xb.db.profile.color.barColor.a)
    self.bgTexture[name]:SetPoint('CENTER', frame)
  end
end

function MenuModule:CreateFrames()
  self.frames.menu = self.frames.menu or CreateFrame("BUTTON", nil, xb:GetFrame('microMenuFrame'))

  --self.frames.socialParent = self.frames.socialParent or CreateFrame("FRAME", nil, self.frames.menu)
  self.frames.chat = self.frames.chat or CreateFrame("BUTTON", nil, self.frames.menu)
  self.frames.guild = self.frames.guild or CreateFrame("BUTTON", nil, self.frames.chat)
  self.frames.social = self.frames.social or CreateFrame("BUTTON", nil, self.frames.guild)

  --self.frames.microbar = self.frames.microbar or CreateFrame("FRAME", nil, self.frames.social)
  self.frames.char = self.frames.char or CreateFrame("BUTTON", nil, self.frames.social)
  self.frames.spell = self.frames.spell or CreateFrame("BUTTON", nil, self.frames.char)
  self.frames.talent = self.frames.talent or CreateFrame("BUTTON", nil, self.frames.spell)
  self.frames.ach = self.frames.ach or CreateFrame("BUTTON", nil, self.frames.talent)
  self.frames.quest = self.frames.quest or CreateFrame("BUTTON", nil, self.frames.ach)
  self.frames.lfg = self.frames.lfg or CreateFrame("BUTTON", nil, self.frames.quest)
  self.frames.journal = self.frames.journal or CreateFrame("BUTTON", nil, self.frames.lfg)
  self.frames.pvp = self.frames.pvp or CreateFrame("BUTTON", nil, self.frames.journal)
  self.frames.pet = self.frames.pet or CreateFrame("BUTTON", nil, self.frames.pvp)
  self.frames.shop = self.frames.shop or CreateFrame("BUTTON", nil, self.frames.pet)
  self.frames.help = self.frames.help or CreateFrame("BUTTON", nil, self.frames.shop)

  self.text.guild = self.text.guild or self.frames.guild:CreateFontString(nil, 'OVERLAY')
  self.bgTexture.guild = self.bgTexture.guild or self.frames.guild:CreateTexture(nil, "OVERLAY")

  self.text.social = self.text.social or self.frames.social:CreateFontString(nil, 'OVERLAY')
  self.bgTexture.social = self.bgTexture.social or self.frames.social:CreateTexture(nil, "OVERLAY")
end

function MenuModule:CreateIcons()
  for name, frame in pairs(self.frames) do
    if frame['Click'] ~= nil then --Odd way of checking if it's a button
      if self.icons[name] == nil then
        self.icons[name] = frame:CreateTexture(nil, "OVERLAY")
        self.icons[name]:SetTexture(self.mediaFolder..name)
      end
    end
  end
end

function MenuModule:IconDefaults(name)
  local colors = xb.db.profile.color
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
      if self.functions[name] ~= nil then
        frame:SetScript('OnClick', self.functions[name])
      end
    end
    frame:SetScript("OnEnter", self:DefaultHover(name))
    frame:SetScript("OnLeave", self:DefaultLeave(name))
  end

  self:RegisterEvent('GUILD_ROSTER_UPDATE', 'UpdateGuildText')
  self:RegisterEvent('BN_FRIEND_ACCOUNT_ONLINE', 'UpdateFriendText')
  self:RegisterEvent('BN_FRIEND_ACCOUNT_OFFLINE', 'UpdateFriendText')
  self:RegisterEvent('FRIENDLIST_UPDATE', 'UpdateFriendText')
end

function MenuModule:UnregisterFrameEvents()
  self:UnregisterEvent('GUILD_ROSTER_UPDATE')
  self:UnregisterEvent('BN_FRIEND_ACCOUNT_ONLINE')
  self:UnregisterEvent('BN_FRIEND_ACCOUNT_OFFLINE')
  self:UnregisterEvent('FRIENDLIST_UPDATE')
end

function MenuModule:UpdateGuildText()
  if IsInGuild() then
    local _, onlineMembers = GetNumGuildMembers()
    self.text.guild:SetText(onlineMembers)
    self.bgTexture.guild:SetPoint('CENTER', self.text.guild)
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
  self.bgTexture.social:SetPoint('CENTER', self.text.social)
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
      self.icons[name]:SetVertexColor(xb.db.profile.color.normal.r, xb.db.profile.color.normal.g, xb.db.profile.color.normal.b, xb.db.profile.color.normal.a)
    end
  end
end

function MenuModule:CreateClickFunctions()
  if self.functions.menu ~= nil then return; end

  self.functions.menu = function(self, button, down)
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
  end; --menu

  self.functions.chat = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
      ChatFrame_OpenMenu()
    end
  end; --chat

  self.functions.guild = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleGuildFrame()
      if IsInGuild() then
        GuildFrameTab2:Click()
      end
    end
  end; --guild

  self.functions.social = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleFriendsFrame()
    end
  end; --social

  self.functions.char = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleCharacter("PaperDollFrame")
    end
  end; --char

  self.functions.spell = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleFrame(SpellBookFrame)
  	end
  end; --spell

  self.functions.talent = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleTalentFrame()
  	end
  end; --talent

  self.functions.journal = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleEncounterJournal()
  	end
  end; --journal

  self.functions.lfg = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleLFDParentFrame()
  	end
  end; --lfg

  self.functions.pet = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleCollectionsJournal()
  	end
  end; --pet

  self.functions.ach = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleAchievementFrame()
  	end
  end; --ach

  self.functions.quest = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleQuestLog()
  	end
  end; --quest

  self.functions.pvp = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		TogglePVPUI()
  	end
  end; --pvp

  self.functions.shop = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleStoreUI()
  	end
  end; --shop

  self.functions.help = function(self, button, down)
    if InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleHelpFrame()
  	end
  end; --help
end

function MenuModule:GetDefaultOptions()
  return 'microMenu', {
      enabled = true,
      showTooltips = true,
      mainMenuSpacing = 2,
      iconSpacing = 2
    }
end

function MenuModule:GetConfig()
  return {
    name = self:GetName(),
    type = "group",
    args = {
      enable = {
        name = ENABLE,
        order = 0,
        type = "toggle",
        get = function() return xb.db.profile.modules.microMenu.enabled; end,
        set = function(_, val)
          xb.db.profile.modules.microMenu.enabled = val
          if val then
            self:Enable()
          else
            self:Disable()
          end
        end
      },
      showTooltips = {
        name = L['Show Social Tooltips'],
        order = 1,
        type = "toggle",
        get = function() return xb.db.profile.modules.microMenu.showTooltips; end,
        set = function(_, val) xb.db.profile.modules.microMenu.showTooltips = val; self:Refresh(); end
      },
      mainMenuSpacing = {
        name = L['Main Menu Icon Right Spacing'],
        order = 2,
        type="range",
        min = 2,
        max = 20,
        step = 1,
        get = function() return xb.db.profile.modules.microMenu.mainMenuSpacing; end,
        set = function(_, val) xb.db.profile.modules.microMenu.mainMenuSpacing = val; self:Refresh(); end
      },
      iconSpacing = {
        name = L['Icon Spacing'],
        order = 2,
        type="range",
        min = 2,
        max = 20,
        step = 1,
        get = function() return xb.db.profile.modules.microMenu.iconSpacing; end,
        set = function(_, val) xb.db.profile.modules.microMenu.iconSpacing = val; self:Refresh(); end
      }
    }
  }
end
