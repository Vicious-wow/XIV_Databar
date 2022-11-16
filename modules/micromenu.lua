local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local MenuModule = xb:NewModule("MenuModule", 'AceEvent-3.0')

function MenuModule:GetName()
  return L['Micromenu'];
end

function MenuModule:OnInitialize()
  self.LTip=LibStub('LibQTip-1.0')
  self.mediaFolder = xb.constants.mediaPath..'microbar\\'
  self.icons = {}
  self.modifiers={SHIFT_KEY_TEXT,ALT_KEY_TEXT,CTRL_KEY_TEXT}
  self.frames = {}
  self.text = {}
  self.bgTexture = {}
  self.functions = {}
  self.menuWidth = 0
  self.iconSize = xb:GetHeight();
  self:CreateClickFunctions()
  self.socialIcons = {
    CLNT = {
      text = ''
    },
    BSAp = {
      text = BNET_CLIENT_APP
    },
    App = {
      text = BNET_CLIENT_APP
    },
    W3 = {
      text = 'Warcraft 3 Reforged'
    },
    WoW = {
      text = CINEMATIC_NAME_1
    },
    GRY = {
      text = 'Warcraft Arclight Rumble'
    },
    S1 = {
      text = 'Starcraft Remastered'
    },
    S2 = {
      text = 'Starcraft 2'
    },
    OSI = {
      text = 'Diablo II: Resurrected'
    },
    D3 = {
      text = 'Diablo 3'
    },
    ANBS = {
      text = 'Diablo Immortal'
    },
    WTCG = {
      text = 'Hearthstone'
    },
    Hero = {
      text = 'Heroes of the Storm'
    },
    Pro = {
      text = 'Overwatch'
    },
    DST2 = {
      text = 'Destiny 2'
    },
    VIPR = {
      text = 'Call of Duty: BO4'
    },
    ODIN = {
      text = 'Call of Duty: MW'
    },
    LAZR = {
      text = 'Call of Duty: MW2'
    },
    AUKS = {
      text = 'Call of Duty: MW2'
    },
    ZEUS = {
      text = 'Call of Duty: BOCW'
    },
    FORE = {
      text = 'Call of Duty: Vanguard'
    },
    RTRO = {
      text = 'Blizzard Arcade Collection'
    },
    WLBY = {
      text = 'Crash Bandicoot 4'
    },
  }
end

-- Skin Support for ElvUI/TukUI
-- Make sure to disable "Tooltip" in the Skins section of ElvUI together with 
-- unchecking "Use ElvUI for tooltips" in XIV options to not have ElvUI fuck with tooltips
function MenuModule:SkinFrame(frame, name)
	if xb.db.profile.general.useElvUI and (IsAddOnLoaded('ElvUI') or IsAddOnLoaded('Tukui')) then
		if frame.StripTextures then
			frame:StripTextures()
		end
		if frame.SetTemplate then
			frame:SetTemplate("Transparent")
		end

		local close = _G[name.."CloseButton"] or frame.CloseButton
		if close and close.SetAlpha then
			if ElvUI then
				ElvUI[1]:GetModule('Skins'):HandleCloseButton(close)
			end

			if Tukui and Tukui[1] and Tukui[1].SkinCloseButton then
				Tukui[1].SkinCloseButton(close)
			end
			close:SetAlpha(1)
		end
	end
end

function MenuModule:OnEnable()
  if not xb.db.profile.modules.microMenu.enabled then return; end
  if self.microMenuFrame == nil then
    self.microMenuFrame = CreateFrame("FRAME", L['Micromenu'], xb:GetFrame('bar'))
    xb:RegisterFrame('microMenuFrame', self.microMenuFrame)
  end

  self.microMenuFrame:Show()

  if not self.frames.menu then
	  self:CreateFrames()
	  self:RegisterFrameEvents()
	  self:CreateIcons()
  end
  xb:Refresh()
end

function MenuModule:OnDisable()
  self.microMenuFrame:Hide()
  self:UnregisterFrameEvents()
  xb:Refresh()
end

function MenuModule:Refresh()
  if not xb.db.profile.modules.microMenu.enabled then self:Disable(); return; end
  
  if self.frames.menu == nil then return; end

  if InCombatLockdown() then
    self:RegisterEvent('PLAYER_REGEN_ENABLED', function()
      self:Refresh()
      self:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end)
    return
  end

  -- get the user's designated modifier for the social and guild tooltip hover function
  self.modifier = self.modifiers[xb.db.profile.modules.microMenu.modifierTooltip]

  self.iconSize = xb:GetHeight()

  local colors = xb.db.profile.color
  local totalWidth = 0;
  for name, frame in pairs(self.frames) do
    self:IconDefaults(name)
    if name == 'menu' then
      frame:SetPoint("LEFT", xb.db.profile.modules.microMenu.iconSpacing, 0)
      totalWidth = totalWidth + frame:GetWidth() + xb.db.profile.modules.microMenu.iconSpacing
    elseif frame:GetParent():GetName() == 'menu' then
      frame:SetPoint("LEFT", frame:GetParent(), "RIGHT", xb.db.profile.modules.microMenu.mainMenuSpacing, 0)
      totalWidth = totalWidth + frame:GetWidth() + xb.db.profile.modules.microMenu.mainMenuSpacing
    else
      frame:SetPoint("LEFT", frame:GetParent(), "RIGHT", xb.db.profile.modules.microMenu.iconSpacing, 0)
      totalWidth = totalWidth + frame:GetWidth() + xb.db.profile.modules.microMenu.iconSpacing
    end
  end
  self.microMenuFrame:SetPoint("LEFT", xb.db.profile.general.barPadding, 0)
  self.microMenuFrame:SetSize(totalWidth, xb:GetHeight())

  for name, frame in pairs(self.text) do
    frame:SetFont(xb:GetFont(xb.db.profile.text.smallFontSize))
    frame:SetPoint('CENTER', self.frames[name], xb.miniTextPosition)
    self.bgTexture[name]:SetColorTexture(xb.db.profile.color.barColor.r, xb.db.profile.color.barColor.g, xb.db.profile.color.barColor.b, xb.db.profile.color.barColor.a)
    self.bgTexture[name]:SetPoint('CENTER', frame, 'CENTER')
    if xb.db.profile.modules.microMenu.hideSocialText then
      frame:Hide()
	else
	  frame:Show()
    end
  end

  self:UpdateFriendText()
  self:UpdateGuildText()
end

function MenuModule:UpdateMenu()
	for _,frame in pairs(self.frames) do
		frame:Hide()
	end
	self:UnregisterFrameEvents()
	self:CreateFrames()
	self:CreateIcons()
	self:RegisterFrameEvents()
end

function MenuModule:CreateFrames()
  parentFrame = xb:GetFrame('microMenuFrame')
  local mm = xb.db.profile.modules.microMenu

  if mm.menu then
    self.frames.menu = CreateFrame("BUTTON", "menu", parentFrame)
    parentFrame = self.frames.menu
  else
    if self.frames.menu then
      self.frames.menu = nil
    end
  end

  if mm.chat then
    self.frames.chat = CreateFrame("BUTTON", "chat", parentFrame)
    parentFrame = self.frames.chat
  else
    if self.frames.chat then
      self.frames.chat = nil
    end
  end

  if mm.guild then
    self.frames.guild = CreateFrame("BUTTON", "guild", parentFrame)
    parentFrame = self.frames.guild
	  self.text.guild = self.frames.guild:CreateFontString(nil, 'OVERLAY')
    self.bgTexture.guild = self.frames.guild:CreateTexture(nil, "OVERLAY")
  else
    if self.frames.guild then
      self.frames.guild = nil
      self.text.guild = nil
      self.bgTexture.guild = nil
    end
  end

  if mm.social then
    self.frames.social = CreateFrame("BUTTON", "social", parentFrame)
    parentFrame = self.frames.social
	  self.text.social = self.frames.social:CreateFontString(nil, 'OVERLAY')
    self.bgTexture.social = self.frames.social:CreateTexture(nil, "OVERLAY")
  else
    if self.frames.social then
      self.frames.social = nil
      self.text.social = nil
      self.bgTexture.social = nil
    end
  end

  if mm.char then
    self.frames.char = CreateFrame("BUTTON", "char", parentFrame)
    parentFrame = self.frames.char
  else
    if self.frames.char then
      self.frames.char = nil
    end
  end

  if mm.spell then
    self.frames.spell = CreateFrame("BUTTON", "spell", parentFrame)
    parentFrame = self.frames.spell
  else
    if self.frames.spell then
      self.frames.spell = nil
    end
  end

  if mm.talent then
    self.frames.talent = CreateFrame("BUTTON", "talent", parentFrame)
    parentFrame = self.frames.talent
  else
    if self.frames.talent then
      self.frames.talent = nil
    end
  end

  if mm.ach then
    self.frames.ach = CreateFrame("BUTTON", "ach", parentFrame)
    parentFrame = self.frames.ach
  else
    if self.frames.ach then
      self.frames.ach = nil
    end
  end

  if mm.quest then
    self.frames.quest = CreateFrame("BUTTON", "quest", parentFrame)
    parentFrame = self.frames.quest
  else
    if self.frames.quest then
      self.frames.quest = nil
    end
  end

  if mm.lfg then
    self.frames.lfg = CreateFrame("BUTTON", "lfg", parentFrame)
    parentFrame = self.frames.lfg
  else
    if self.frames.lfg then
      self.frames.lfg = nil
    end
  end

  if mm.journal then
    self.frames.journal = CreateFrame("BUTTON", "journal", parentFrame)
    parentFrame = self.frames.journal
  else
    if self.frames.journal then
      self.frames.journal = nil
    end
  end

  if mm.pvp then
    self.frames.pvp = CreateFrame("BUTTON", "pvp", parentFrame)
    parentFrame = self.frames.pvp
  else
    if self.frames.pvp then
      self.frames.pvp = nil
    end
  end

  if mm.pet then
    self.frames.pet = CreateFrame("BUTTON", "pet", parentFrame)
    parentFrame = self.frames.pet
  else
    if self.frames.pet then
      self.frames.pet = nil
    end
  end

  if mm.shop then
    self.frames.shop = CreateFrame("BUTTON", "shop", parentFrame)
    parentFrame = self.frames.shop
  else
	  if self.frames.shop then
		  self.frames.shop = nil
	  end
  end

  if mm.help then
    self.frames.help = CreateFrame("BUTTON", "help", parentFrame)
    parentFrame = self.frames.help
  else
	  if self.frames.help then
		  self.frames.help = nil
	  end
  end
end

function MenuModule:CreateIcons()
  for name, frame in pairs(self.frames) do
    if frame['Click'] ~= nil then --Odd way of checking if it's a button
        self.icons[name] = frame:CreateTexture(nil, "OVERLAY")
        self.icons[name]:SetTexture(self.mediaFolder .. name)
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
  self.icons[name]:SetVertexColor(xb:GetColor('normal'))
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

    if name == 'guild' then
      local leaveFunc = self:DefaultLeave(name)
      frame:SetScript("OnEnter", self:GuildHover(self:DefaultHover(name)))
      frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
        leaveFunc()
      end)
    elseif name == 'social' then
      local leaveFunc = self:DefaultLeave(name)
      frame:SetScript("OnEnter", self:SocialHover(self:DefaultHover(name)))
      frame:SetScript("OnLeave", leaveFunc)
    else
      frame:SetScript("OnEnter", self:DefaultHover(name))
      frame:SetScript("OnLeave", self:DefaultLeave(name))
    end
  end

  self:RegisterEvent('GUILD_ROSTER_UPDATE', 'UpdateGuildText')
  self:RegisterEvent('CHAT_MSG_GUILD', 'UpdateGuildText')
  self:RegisterEvent('BN_FRIEND_ACCOUNT_ONLINE', 'UpdateFriendText')
  self:RegisterEvent('BN_FRIEND_ACCOUNT_OFFLINE', 'UpdateFriendText')
  self:RegisterEvent('FRIENDLIST_UPDATE', 'UpdateFriendText')
end

function MenuModule:UnregisterFrameEvents()
  self:UnregisterEvent('GUILD_ROSTER_UPDATE')
  self:UnregisterEvent('CHAT_MSG_GUILD')
  self:UnregisterEvent('BN_FRIEND_ACCOUNT_ONLINE')
  self:UnregisterEvent('BN_FRIEND_ACCOUNT_OFFLINE')
  self:UnregisterEvent('FRIENDLIST_UPDATE')
end

-- called on refresh, guild related events and profile changes to social text
function MenuModule:UpdateGuildText()
  local db = xb.db.profile.modules.microMenu --shortcut to access profile variables

  -- if the guild icon is disabled, don't do anything
  if not db.guild then return end

  -- if guild icon is enabled but player is not in a guild, hide everything related to guild text
  if not IsInGuild() then
    self.text.guild:Hide()
    self.bgTexture.guild:Hide()
    return
  end

  if db.hideSocialText or not db.guild then return end --don't do anything if social text or the guild icon are not displayed
  C_GuildInfo.GuildRoster() --requests an update to guild roster information from blizzbois

  -- get the number of online guild members and set social text to that number
  local _, onlineMembers = GetNumGuildMembers()
  self.text.guild:SetText(onlineMembers)

  local osTopBottom
  -- databar is at the bottom, take the social text offset
  if xb.db.profile.general.barPosition == 'BOTTOM' then 
    osTopBottom = db.osSocialText
  -- databar is at the top, inverse the social text offset
  elseif xb.db.profile.general.barPosition == 'TOP' then 
    osTopBottom = -db.osSocialText
  end

  -- apply social text position depending on whether the databar is at the top/bottom
  self.text.guild:SetPoint('CENTER', 0, osTopBottom)
  self.bgTexture.guild:SetPoint('CENTER', self.text.guild)
  -- player is in a guild, show everything related to guild text
  self.text.guild:Show()
  self.bgTexture.guild:Show()
end

-- called on refresh, friend related events and profile changes to social text
function MenuModule:UpdateFriendText()
  local db = xb.db.profile.modules.microMenu --shortcut to access profile variables
  if db.hideSocialText or not db.social then return end --don't do anything if social text or the social icon are not displayed

  -- get bnet and regular friends that are online, add them together and set social text to that number
  local _, bnOnlineMembers, _, _ = BNGetNumFriends()
  local friendsOnline = C_FriendList.GetNumOnlineFriends()
  local totalFriends = bnOnlineMembers + friendsOnline
  self.text.social:SetText(totalFriends)

  local osTopBottom
  -- databar is at the bottom, take the social text offset
  if xb.db.profile.general.barPosition == 'BOTTOM' then 
    osTopBottom = db.osSocialText
  -- databar is at the top, inverse the social text offset
  elseif xb.db.profile.general.barPosition == 'TOP' then 
    osTopBottom = -db.osSocialText
  end

  -- apply social text position depending on whether the databar is at the top/bottom
  self.text.social:SetPoint('CENTER', 0, osTopBottom)
  self.bgTexture.social:SetPoint('CENTER', self.text.social)
end

function MenuModule:DefaultHover(name)
  return function()
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if self.icons[name] ~= nil then
      self.icons[name]:SetVertexColor(unpack(xb:HoverColors()))
	    self.tipHover = (name == 'social')
	    self.gtipHover = (name == 'guild')
    end
  end
end

function MenuModule:DefaultLeave(name)
  return function()
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if self.icons[name] ~= nil then
      self.icons[name]:SetVertexColor(xb:GetColor('normal'))
    end
  end
end

function MenuModule:SocialHover(hoverFunc)
  return function()
    -- get out of here if showTooltips in the options is set to false
    if not xb.db.profile.modules.microMenu.showTooltips then
      hoverFunc()
      return
    end

    -- determines whether SHIFT/ALT/CTRL has been pressed based on the user's designated modifier
	  local modifierFunc = IsShiftKeyDown
	  if self.modifier == "ALT" then modifierFunc = IsAltKeyDown
	  elseif self.modifier == "CONTROL" then modifierFunc = IsControlKeyDown end

    -- if the social tooltip already exists, deletus fetus it
	  if self.LTip:IsAcquired("SocialToolTip") then self.LTip:Release(self.LTip:Acquire("SocialToolTip")) end
    
    -- declare our LTip tooltip with 2 columns and mouse interaction when hovering/leaving/updating the tooltip
    local tooltip = self.LTip:Acquire("SocialToolTip", 2, "LEFT", "RIGHT")
	  tooltip:EnableMouse(true)
	  tooltip:SetScript("OnEnter", function() self.tipHover = true end)
	  tooltip:SetScript("OnLeave", function() self.tipHover = false end)
    tooltip:SetScript("OnUpdate", function() if not self.tipHover and not self.lineHover then tooltip:Release() end end)
    MenuModule:SkinFrame(tooltip, "SocialToolTip")

    -- get the amount of bnet and non-bnet online friends as well as the player's faction
    local _, totalBNOnlineFriends = BNGetNumFriends()
    local totalOnlineFriends = C_FriendList.GetNumOnlineFriends()
    local playerFaction = UnitFactionGroup("player")

    -- ties the 'Social' and '<Left-Click>' etc. in the tooltip to the addon's hovercolors
    local r, g, b = unpack(xb:HoverColors())

    -- if any friends are online add the [Social] section and an empty line to the tooltip
    if (totalOnlineFriends + totalBNOnlineFriends) > 0 then
      tooltip:SmartAnchorTo(MenuModule.frames.social)
      tooltip:AddHeader('|cFFFFFFFF[|r' .. SOCIAL_LABEL .. '|cFFFFFFFF]|r')
      tooltip:SetCellTextColor(1, 1, r, g, b, 1)
      tooltip:AddLine(' ',' ')
    end

    -- executes if there are any online bnet friends
    if totalBNOnlineFriends then
      -- iterate through every bnet friend - get their info and add the friend as an interactable line in the tooltip
      for i = 1, BNGetNumFriends() do
        local friendAccInfo = C_BattleNet.GetFriendAccountInfo(i)
        local gameAccount = friendAccInfo.gameAccountInfo

        -- executes if the friend is online
        if gameAccount.isOnline then
          -- if the friend has no battle tag, set it to 'No Tag'
          if not friendAccInfo.battleTag then
            friendAccInfo.battleTag = '[' .. L['No Tag'] .. ']'
          end
          
          local charName = gameAccount.characterName                     --gets the friend's character name
          local gameClient = gameAccount.clientProgram                   --the application that the friend is online with - can be any game or 'App'/'Mobile'
          local realmName = gameAccount.realmName                        --gets the realm name the friend's char is on
          local faction = gameAccount.factionName                        --gets the friend's currently logged in char's faction
          local zone = gameAccount.areaName                              --zone name to be displayed when the friend is playing retail WoW
          local richPresence = gameAccount.richPresence                  --rich presence is used here to determine whether a friend logged into WoW is playing classic
          local isWoW = false                                            --tracks whether the friend is playing WoW or not, default being that the friend isn't
          local isClassic = false                                        --tracks whether the friend is logged into classic or not, default being that the friend isn't
          local statusIcon = FRIENDS_TEXTURE_ONLINE                      --get icon for online friends, might later be changed to afk/dnd icons
          local socialIcon = BNet_GetClientEmbeddedAtlas(gameClient)     --get icon for the friend's application
          local gameName = MenuModule.socialIcons[gameClient].text       --name of the application the friend is currently using - can be any game or 'App'/'Mobile'
          local note = friendAccInfo.note                                --note of the friend, if there is no note it's an empty string
          local charNameFormat = ''                                      --format in which the friend's character is displayed - is '' if not playing WoW, 'Char - Realm' or 'FACTION - Char' if playing WoW

          -- if the friend is afk, set the icon left to the friend's name to afk
          if friendAccInfo.isAFK or gameAccount.isGameAFK then statusIcon = FRIENDS_TEXTURE_AFK end
          -- if the friend is set to 'do not disturb', set the icon left to the friend's name to dnd
          if friendAccInfo.isDND or gameAccount.isGameBusy then statusIcon = FRIENDS_TEXTURE_DND end
          -- if the friend has a note, color and display it
          if note ~= '' then note = "(|cffecd672" .. note .. "|r)" end

          -- if the friend is playing World of Warcraft - note that this is true for both retail and classic. yes, blizzard is retarded.
          if gameClient == BNET_CLIENT_WOW then
            isWoW = true
            -- checks if the friend is logged into classic or retail
            if richPresence:find(L['Classic']) then
              isClassic = true 
            -- friend is playing retail WoW and is of the same faction as the player, or faction is nil which for some reason happens sometimes
            elseif (not faction) or (faction == playerFaction) then
              charNameFormat = "(|cffecd672" .. (charName or L['No Info']) .. "-" .. (realmName or L['No Info']) .. "|r)"
            -- friend is playing retail WoW but is playing on the player's opposite faction
            else
              local factionColors = { ['Alliance'] = "ff008ee8", ['Horde'] = "ffc80000" }
              charNameFormat = "(|c" .. factionColors[faction] .. L[faction] .. "|r - |cffecd672" .. (charName or L['No Info']) .. "|r)"
            end
          end

          -- clientsList contains all game related clients a bnet friend can have - being on mobile or just in the app is excluded from this list
          local clientsList = { 
            BNET_CLIENT_WOW,
            BNET_CLIENT_SC2, 
            BNET_CLIENT_D3, 
            BNET_CLIENT_WTCG, 
            BNET_CLIENT_HEROES, 
            BNET_CLIENT_OVERWATCH, 
            BNET_CLIENT_SC, 
            BNET_CLIENT_DESTINY2, 
            BNET_CLIENT_COD, 
            BNET_CLIENT_COD_MW, 
            BNET_CLIENT_COD_MW2,
            BNET_CLIENT_COD_BOCW,
            BNET_CLIENT_WC3 
          }

          -- set up tooltip line for the friend unless he's not logged into a game and 'hide bnet app friends' is true
          if tContains(clientsList, gameClient) or not xb.db.profile.modules.microMenu.hideAppContact then
            -- lineLeft displays status icon, bnet name and the friend's note
            local lineLeft = string.format("|T%s:16|t|cff82c5ff %s|r %s", statusIcon, friendAccInfo.accountName, note)
            local lineRight = ''

            -- friend is not playing wow, format is "GameName [Icon]"
            if not isWoW then
              lineRight = string.format("%s |T%s:16|t", gameName, socialIcon)
            -- friend is playing classic WoW, format is "WoW Classic [Icon]"
            elseif isClassic then
              lineRight = string.format("%s |T%s:16|t", richPresence, socialIcon)
            -- friend is playing retail WoW, format is "(Name-Realm) Zone [Icon]"
            else
              lineRight = string.format("%s %s |T%s:16|t", charNameFormat, zone, socialIcon)
            end
            
            -- add left and right line to the tooltip
            tooltip:AddLine(lineLeft, lineRight)
            -- set up mouse events when the player hovers over/clicks on/leaves the friend's line in the tooltip
      		  tooltip:SetLineScript(tooltip:GetLineCount(), "OnEnter", function() self.lineHover = true end)
      		  tooltip:SetLineScript(tooltip:GetLineCount(), "OnLeave", function() self.lineHover = false end)
            tooltip:SetLineScript(tooltip:GetLineCount(), "OnMouseUp", function(self,_,button)
              -- player left clicks on the friend, checks whether a modifier was used or not after
              if button == "LeftButton" then
                -- player pressed SHIFT/ALT/CTRL when left clicking the friend
                if modifierFunc() then
                  -- invite to group / raid if possible
                  if CanGroupWithAccount(friendAccInfo.bnetAccountID) then
                    C_PartyInfo.InviteUnit(charName .. "-" .. realmName)
  						      --InviteToGroup(charName .. "-" .. realmName)
                  end
                -- player did not use a modifier when left clicking on the friend, send a bnet whisper
                else
                  ChatFrame_SendBNetTell(friendAccInfo.accountName)
                end

              -- player right clicked on the friend, send an ingame whisper if the player is not playing classic or of the opposite faction
  			      elseif button == "RightButton" then
                if (not isClassic and charName and faction == playerFaction ) then
                  ChatFrame_SendTell(charName .. "-" .. realmName)
  				      end
  			      end
  		      end)
          end --optApp
        end -- isOnline
      end -- for in BNGetNumFriends
    end -- totalBNOnlineFriends

    -- executes if there are any online non-bnet friends
    if totalOnlineFriends then
      -- iterate through every non-bnet friend - get their info and add the friend as an interactable line in the tooltip
      for i = 1, C_FriendList.GetNumFriends() do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)

        -- executes if the friend is online
        if friendInfo.connected then
          local name = friendInfo.name              --friend's character name as 'CharName - RealmName'
          local level = friendInfo.level            --level of the friend's character
          local statusIcon = FRIENDS_TEXTURE_ONLINE --get icon for online friends, might later be changed to afk/dnd icons

          -- if the friend is afk, set the icon left to the friend's name to afk
          if friendInfo.afk then statusIcon = FRIENDS_TEXTURE_AFK end
          -- if the friend is set to 'do not disturb', set the icon left to the friend's name to dnd
          if friendInfo.dnd then statusIcon = FRIENDS_TEXTURE_DND end

          -- lineLeft displays status icon, char name, char level, char class
          local lineLeft = string.format("|T%s:16|t %s, " .. LEVEL .. ":%s %s", statusIcon, name, level, friendInfo.className)
          -- lineRight displays the area the friend is currently in
          local lineRight = string.format("%s", friendInfo.area)

          -- add left and right line to the tooltip
          tooltip:AddLine(lineLeft, lineRight)
          -- set up mouse events when the player hovers over/clicks on/leaves the friend's line in the tooltip
		      tooltip:SetLineScript(tooltip:GetLineCount(),"OnEnter", function() self.lineHover = true end)
		      tooltip:SetLineScript(tooltip:GetLineCount(),"OnLeave", function() self.lineHover = false end)
          tooltip:SetLineScript(tooltip:GetLineCount(),"OnMouseUp", function(self, _, button)
            -- if there is no realm name in the friend's name, the friend is playing on the same realm as the player
		        if not name:find('%u%U*-%u%U') then
				      local homeRealm = GetRealmName()
				      homeRealm = homeRealm:gsub("%s+", "")
				      name = name .. "-" .. homeRealm
            end

            -- player right clicked on the friend, send an ingame whisper
		        if button == "RightButton" then
              ChatFrame_SendTell(name)
            -- player SHIFT/ALT/CTRL + left clicked on the friend, attempt to invite to group / raid
            elseif button == "LeftButton" and modifierFunc() then
              C_PartyInfo.InviteUnit(name)
			      end
		      end)
        end -- isOnline
      end -- for in GetNumFriends
    end -- totalOnlineFriends

    -- add section under the friends list for (modifiers) + left/right click and what each action does
	  tooltip:AddLine(' ',' ')
    tooltip:AddLine('<'..L['Left-Click']..'>', L['Whisper BNet'])
    tooltip:SetCellTextColor(tooltip:GetLineCount(), 1, r, g, b, 1)
    tooltip:AddLine('<'..self.modifier..'+'..L['Left-Click']..'>', CALENDAR_INVITELIST_INVITETORAID)
    tooltip:SetCellTextColor(tooltip:GetLineCount(), 1, r, g, b, 1)
    tooltip:AddLine('<'..L['Right-Click']..'>', L['Whisper Character'])
    tooltip:SetCellTextColor(tooltip:GetLineCount(), 1, r, g, b, 1)
    -- if any bnet or non-bnet friends are online, set the tooltip to show
    if (totalOnlineFriends + totalBNOnlineFriends) > 0 then tooltip:Show() end
    hoverFunc()
  end
end

function MenuModule:GuildHover(hoverFunc)
  return function()
    -- get out if player is not in a guild
    if not IsInGuild() then
      hoverFunc()
      return
    end
    -- get out if tooltips are disabled
    if not xb.db.profile.modules.microMenu.showTooltips then
      hoverFunc()
      return
    end

    -- determines whether SHIFT/ALT/CTRL has been pressed based on the user's designated modifier
	  local modifierFunc = IsShiftKeyDown
	  if self.modifier == "ALT" then modifierFunc = IsAltKeyDown
	  elseif self.modifier == "CONTROL" then modifierFunc = IsControlKeyDown end

    -- if the guild tooltip already exists, deletus fetus it
    if self.LTip:IsAcquired("GuildToolTip") then self.LTip:Release(self.LTip:Acquire("GuildToolTip")) end
    
    -- declare our LTip tooltip with 2 columns and mouse interaction when hovering/leaving/updating the tooltip
    local tooltip = self.LTip:Acquire("GuildToolTip", 2, "LEFT", "RIGHT")
	  tooltip:EnableMouse(true)
	  tooltip:SetScript("OnEnter", function() self.gtipHover = true end)
	  tooltip:SetScript("OnLeave", function() self.gtipHover = false end)
    tooltip:SetScript("OnUpdate", function() if not self.gtipHover and not self.glineHover then tooltip:Release() end end)
    MenuModule:SkinFrame(tooltip, "GuildToolTip")

    C_GuildInfo.GuildRoster() --requests an update to guild roster information from blizzbois
    tooltip:SmartAnchorTo(MenuModule.frames.guild)

    -- ties the 'Guild' and '<Left-Click>' etc. in the tooltip to the addon's hovercolors
    local r, g, b = unpack(xb:HoverColors())

    -- get guild info and create first tooltip line, left is [Guild], right is GuildName
    local gName = GetGuildInfo('player')
    tooltip:AddHeader('|cFFFFFFFF[|r' .. GUILD .. '|cFFFFFFFF]|r', '|cff00ff00' .. gName .. '|r')
    tooltip:SetCellTextColor(1, 1, r, g, b, 1)
    tooltip:SetCellTextColor(1, 2, r, g, b, 1)
    tooltip:AddLine(' ',' ')

    if xb.db.profile.modules.microMenu.showGMOTD then
      local motd = GetGuildRosterMOTD()
      if motd ~= '' then
        tooltip:AddLine('|cff00ff00' .. motd .. '|r', ' ') --REVISION LATER: shorten guild motd if too long
      end
    end

    local totalGuild, _ = GetNumGuildMembers()
    for i = 0, totalGuild do
      local name, _, _, level, _, zone, note, _, isOnline, status, class, _, _, isMobile, _ = GetGuildRosterInfo(i)
      if isOnline then
        local colorHex = RAID_CLASS_COLORS[class].colorStr

        -- determine afk/dnd/online status of guild members
        if status == 1 then status = DEFAULT_AFK_MESSAGE;
        elseif status == 2 then status = DEFAULT_DND_MESSAGE;
        else status = '' end

        -- name given by Blizzard is CharName-RealmName, truncate to CharName
        local charName = name:match('[^-]+')

        if note ~= '' then note = '|cffffffff(|r' .. note .. '|cffffffff)|r' end
        local lineLeft = string.format('%s |c%s%s|r %s |cffecd672%s|r', level, colorHex, charName or name or L['No Info'], status, note)
        local lineRight = string.format('%s|cffffffff %s', (isMobile and '|cffffffa0[M]|r ' or ''), zone or '')
        tooltip:AddLine(lineLeft, lineRight)
		    tooltip:SetLineScript(tooltip:GetLineCount(),'OnEnter', function() self.glineHover = true end)
		    tooltip:SetLineScript(tooltip:GetLineCount(),'OnLeave', function() self.glineHover = false end)
		    tooltip:SetLineScript(tooltip:GetLineCount(),'OnMouseUp', function(self, _, button)
		      if button == 'LeftButton' then
				    if modifierFunc() then C_PartyInfo.InviteUnit(name)
            else ChatFrame_OpenChat(SLASH_SMART_WHISPER1 .. ' ' .. name .. ' ') end
			    end
		    end)
      end
    end
    -- add section under member list for (modifiers) + left/right click and what each section does
    tooltip:AddLine(' ',' ')
    tooltip:AddLine('<' .. L['Left-Click'] .. '>', L['Whisper Character'])
    tooltip:SetCellTextColor(tooltip:GetLineCount(), 1, r, g, b, 1)
    tooltip:AddLine('<' .. self.modifier .. '+' .. L['Left-Click'] .. '>', CALENDAR_INVITELIST_INVITETORAID)
    tooltip:SetCellTextColor(tooltip:GetLineCount(), 1, r, g, b, 1)
    tooltip:Show()
    hoverFunc()
  end
end

function MenuModule:CreateClickFunctions()
  if self.functions.menu ~= nil then return; end

  self.functions.menu = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
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
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
      if ChatMenu:IsVisible() then
		    ChatMenu:Hide()
  	  else
  	    ChatFrame_ToggleMenu()
  	  end
    end
  end; --chat

  self.functions.guild = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleGuildFrame()
    end
  end; --guild

  self.functions.social = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleFriendsFrame()
    end
  end; --social

  self.functions.char = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
      ToggleCharacter("PaperDollFrame")
    end
  end; --char

  self.functions.spell = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleFrame(SpellBookFrame)
  	end
  end; --spell

  self.functions.talent = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleTalentFrame()
  	end
  end; --talent

  self.functions.journal = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleEncounterJournal()
  	end
  end; --journal

  self.functions.lfg = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleLFDParentFrame()
  	end
  end; --lfg

  self.functions.pet = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleCollectionsJournal()
  	end
  end; --pet

  self.functions.ach = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleAchievementFrame()
  	end
  end; --ach

  self.functions.quest = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleQuestLog()
  	end
  end; --quest

  self.functions.pvp = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		TogglePVPUI()
  	end
  end; --pvp

  self.functions.shop = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleStoreUI()
  	end
  end; --shop

  self.functions.help = function(self, button, down)
    if (not xb.db.profile.modules.microMenu.combatEn) and InCombatLockdown() then return; end
    if button == "LeftButton" then
  		ToggleHelpFrame()
  	end
  end; --help
end

function MenuModule:GetDefaultOptions()
  return 'microMenu', {
      enabled = true,
      showTooltips = true,
      combatEn = false,
      mainMenuSpacing = 2,
      iconSpacing = 2,
	    modifierTooltip = 1,
      showGMOTD = false,
      hideSocialText = false,
      osSocialText = 12,
	    menu = true,
      chat = true,
      guild = true,
      social = true,
      char = true,
      spell = true,
      talent = true,
      ach = true,
      quest = true,
      lfg = true,
      journal = true,
      pvp = true,
      pet = true,
      shop = true,
      help = true,
      hideAppContact = false
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

      appFriendsHide = {
        name = L["Hide BNet App Friends"],
        type = "toggle",
        order = 2,
        get = function() return xb.db.profile.modules.microMenu.hideAppContact end,
        set = function(_,val) xb.db.profile.modules.microMenu.hideAppContact = val; self:Refresh(); end
      },

      combatEn = {
        name = 'Enable in combat',
        order = 3,
        type = "toggle",
        get = function() return xb.db.profile.modules.microMenu.combatEn; end,
        set = function(_, val) xb.db.profile.modules.microMenu.combatEn = val; self:Refresh(); end
      },

      mainMenuSpacing = {
        name = L['Main Menu Icon Right Spacing'],
        order = 4,
        type="range",
        min = 2,
        max = 20,
        step = 1,
        get = function() return xb.db.profile.modules.microMenu.mainMenuSpacing; end,
        set = function(_, val) xb.db.profile.modules.microMenu.mainMenuSpacing = val; self:Refresh(); end
      },

      iconSpacing = {
        name = L['Icon Spacing'],
        order = 5,
        type="range",
        min = 2,
        max = 20,
        step = 1,
        get = function() return xb.db.profile.modules.microMenu.iconSpacing; end,
        set = function(_, val) xb.db.profile.modules.microMenu.iconSpacing = val; self:Refresh(); end
      },

	    showGMOTD = {
		    name = L["GMOTD in Tooltip"],
		    type = "toggle",
		    order = 6,
		    get = function() return xb.db.profile.modules.microMenu.showGMOTD end,
		    set = function(_,val) xb.db.profile.modules.microMenu.showGMOTD = val; self:Refresh(); end
      },
      
	    modifierTooltip = {
		    name = L["Modifier for friend invite"],
		    order = 7,
		    type = "select",
		    values = { SHIFT_KEY_TEXT, ALT_KEY_TEXT, CTRL_KEY_TEXT },
		    style = "dropdown",
		    get = function() return xb.db.profile.modules.microMenu.modifierTooltip; end,
		    set = function(info, val) xb.db.profile.modules.microMenu.modifierTooltip = val; self:Refresh(); end,
		    disabled = function() return not xb.db.profile.modules.microMenu.guild and not xb.db.profile.modules.microMenu.social end
      },

      hideSocialText = {
        name = L['Hide Social Text'],
        order = 8,
        type = "toggle",
        get = function() return xb.db.profile.modules.microMenu.hideSocialText; end,
        set = function(_, val) xb.db.profile.modules.microMenu.hideSocialText = val; self:Refresh(); end
      },

      osSocialText = {
        name = L['Social Text Offset'],
        order = 9,
        type = "range",
        min = 0,
        max = 20,
        step = 1,
        get = function() return xb.db.profile.modules.microMenu.osSocialText end,
        set = function(_, val) xb.db.profile.modules.microMenu.osSocialText = val; self:UpdateFriendText(); end
      },

      buttons = {
        type = 'group',
        name = L['Show/Hide Buttons'],
        order = 10,
        inline = true,
        args = {
          menu = {
            name = L['Show Menu Button'],
            disabled = true,
            order = 1,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.menu; end,
            set = function(_, val) xb.db.profile.modules.microMenu.menu = val; self:Refresh(); end
          },
          chat = {
            name = L['Show Chat Button'],
            order = 2,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.chat; end,
            set = function(_, val) xb.db.profile.modules.microMenu.chat = val; self:UpdateMenu(); self:Refresh(); end
          },
          guild = {
            name = L['Show Guild Button'],
            order = 3,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.guild; end,
            set = function(_, val) xb.db.profile.modules.microMenu.guild = val; self:UpdateMenu(); self:Refresh(); end
          },
          social = {
            name = L['Show Social Button'],
            order = 4,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.social; end,
            set = function(_, val) xb.db.profile.modules.microMenu.social = val; self:UpdateMenu(); self:Refresh(); end
          },
          char = {
            name = L['Show Character Button'],
            order = 5,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.char; end,
            set = function(_, val) xb.db.profile.modules.microMenu.char = val; self:UpdateMenu(); self:Refresh(); end
          },
          spell = {
            name = L['Show Spellbook Button'],
            order = 6,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.spell; end,
            set = function(_, val) xb.db.profile.modules.microMenu.spell = val; self:UpdateMenu(); self:Refresh(); end
          },
          talent = {
            name = L['Show Talents Button'],
            order = 7,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.talent; end,
            set = function(_, val) xb.db.profile.modules.microMenu.talent = val; self:UpdateMenu(); self:Refresh(); end
          },
          ach = {
            name = L['Show Achievements Button'],
            order = 8,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.ach; end,
            set = function(_, val) xb.db.profile.modules.microMenu.ach = val; self:UpdateMenu(); self:Refresh(); end
          },
          quest = {
            name = L['Show Quests Button'],
            order = 9,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.quest; end,
            set = function(_, val) xb.db.profile.modules.microMenu.quest = val; self:UpdateMenu(); self:Refresh(); end
          },
          lfg = {
            name = L['Show LFG Button'],
            order = 10,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.lfg; end,
            set = function(_, val) xb.db.profile.modules.microMenu.lfg = val; self:UpdateMenu(); self:Refresh(); end
          },
          journal = {
            name = L['Show Journal Button'],
            order = 11,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.journal; end,
            set = function(_, val) xb.db.profile.modules.microMenu.journal = val; self:UpdateMenu(); self:Refresh(); end
          },
          pvp = {
            name = L['Show PVP Button'],
            order = 12,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.pvp; end,
            set = function(_, val) xb.db.profile.modules.microMenu.pvp = val; self:UpdateMenu(); self:Refresh(); end
          },
          pet = {
            name = L['Show Pets Button'],
            order = 13,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.pet; end,
            set = function(_, val) xb.db.profile.modules.microMenu.pet = val; self:UpdateMenu(); self:Refresh(); end
          },
          shop = {
            name = L['Show Shop Button'],
            order = 14,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.shop; end,
            set = function(_, val) xb.db.profile.modules.microMenu.shop = val; self:UpdateMenu(); self:Refresh(); end
          },
          help = {
            name = L['Show Help Button'],
            order = 15,
            type = "toggle",
            get = function() return xb.db.profile.modules.microMenu.help; end,
            set = function(_, val) xb.db.profile.modules.microMenu.help = val; self:UpdateMenu(); self:Refresh(); end
          }
        }
      }
    }
  }
end
