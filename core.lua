local AddOnName, XIVBar = ...;
local _G = _G;
local pairs, unpack, select = pairs, unpack, select
LibStub("AceAddon-3.0"):NewAddon(XIVBar, AddOnName, "AceConsole-3.0", "AceEvent-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnName, true);

XIVBar.L = L

XIVBar.defaults = {
  profile = {
    general = {
      barPosition = "BOTTOM",
      barPadding = 3,
      moduleSpacing = 30,
      barFullscreen = true,
      barWidth = GetScreenWidth(),
      barHoriz = 'CENTER'
    },
    color = {
      barColor = {
        r = 0.094,
        g = 0.094,
        b = 0.094,
        a = 0.75
      },
      normal = {
        r = 0.8,
        g = 0.8,
        b = 0.8,
        a = 0.75
      },
      inactive = {
        r = 1,
        g = 1,
        b = 1,
        a = 0.25
      },
      useCC = false,
      useHoverCC = true,
      hover = {
        r = 1,
        g = 1,
        b = 1,
        a = 1
      }
    },
    text = {
      fontSize = 12,
      smallFontSize = 11,
      font =  'Homizio Bold'
    },
    modules = {

    }
  }
};

XIVBar.constants = {
  mediaPath = "Interface\\AddOns\\"..AddOnName.."\\media\\",
  playerName = UnitName("player"),
  playerClass = select(2, UnitClass("player")),
  playerLevel = UnitLevel("player"),
  playerFactionLocal = select(2, UnitFactionGroup("player")),
  playerRealm = GetRealmName(),
  popupPadding = 3
}

XIVBar.LSM = LibStub('LibSharedMedia-3.0');

function XIVBar:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("XIVBarDB", self.defaults)
  self.LSM:Register(self.LSM.MediaType.FONT, 'Homizio Bold', self.constants.mediaPath.."homizio_bold.ttf")
  self.frames = {}

  self.fontFlags = {'', 'OUTLINE', 'THICKOUTLINE', 'MONOCHROME'}

  local options = {
    name = "XIV Bar",
    handler = XIVBar,
    type = 'group',
    args = {
      general = {
        name = GENERAL_LABEL,
        type = "group",
        args = {
          general = self:GetGeneralOptions(),
          text = self:GetTextOptions(),
          textColors = self:GetTextColorOptions(), -- colors
          positionOptions = self:GetPositionOptions(),
        }
      }, -- general
      modules = {
        name = L['Modules'],
        type = "group",
        args = {

        }
      } -- modules
    }
  }

  for name, module in self:IterateModules() do
    if module['GetConfig'] ~= nil then
      options.args.modules.args[name] = module:GetConfig()
    end
    if module['GetDefaultOptions'] ~= nil then
      local oName, oTable = module:GetDefaultOptions()
      self.defaults.profile.modules[oName] = oTable
    end
  end

  self.db:RegisterDefaults(self.defaults)

  LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOnName, options)
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, "XIV Bar", nil, "general")

  --options.args.modules = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  self.modulesOptionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, L['Modules'], "XIV Bar", "modules")

  options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  self.profilesOptionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, 'Profiles', "XIV Bar", "profiles")

  self.timerRefresh = false

  self:RegisterChatCommand('xivbar', 'ToggleConfig')
end

function XIVBar:OnEnable()
  self:CreateMainBar()
  self:Refresh()

  self.db.RegisterCallback(self, 'OnProfileCopied', 'Refresh')
  self.db.RegisterCallback(self, 'OnProfileChanged', 'Refresh')
  self.db.RegisterCallback(self, 'OnProfileReset', 'Refresh')

  if not self.timerRefresh then
    C_Timer.After(5, function()
      self:Refresh()
      self.timerRefresh = true
    end)
  end
end

function XIVBar:ToggleConfig()
  InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function XIVBar:SetColor(name, r, g, b, a)
  self.db.profile.color[name].r = r
  self.db.profile.color[name].g = g
  self.db.profile.color[name].b = b
  self.db.profile.color[name].a = a

  self:Refresh()
end

function XIVBar:GetColor(name)
  d = self.db.profile.color[name]
  return d.r, d.g, d.b, d.a
end

function XIVBar:HoverColors()
  local colors = {
    self.db.profile.color.hover.r,
    self.db.profile.color.hover.g,
    self.db.profile.color.hover.b,
    self.db.profile.color.hover.a
  }
  if self.db.profile.color.useHoverCC then
    colors = {
      RAID_CLASS_COLORS[self.constants.playerClass].r,
      RAID_CLASS_COLORS[self.constants.playerClass].g,
      RAID_CLASS_COLORS[self.constants.playerClass].b,
      self.db.profile.color.hover.a
    }
  end
  return colors
end

function XIVBar:RegisterFrame(name, frame)
  frame:SetScript('OnHide', function()
    self:SendMessage('XIVBar_FrameHide', name)
  end)
  frame:SetScript('OnShow', function()
    self:SendMessage('XIVBar_FrameShow', name)
  end)
  self.frames[name] = frame
end

function XIVBar:GetFrame(name)
  return self.frames[name]
end

function XIVBar:CreateMainBar()
  if self.frames.bar == nil then
    self:RegisterFrame('bar', CreateFrame("FRAME", "XIV_Databar", UIParent))
    self.frames.bgTexture = self.frames.bgTexture or self.frames.bar:CreateTexture(nil, "BACKGROUND")
  end
end

function XIVBar:GetHeight()
  return (self.db.profile.text.fontSize * 2) + self.db.profile.general.barPadding
end

function XIVBar:Refresh()
  if self.frames.bar == nil then return; end

  self.miniTextPosition = "TOP"
  if self.db.profile.general.barPosition == 'TOP' then
    self.miniTextPosition = 'BOTTOM'
  end

  local barColor = self.db.profile.color.barColor
  self.frames.bar:ClearAllPoints()
  self.frames.bar:SetPoint(self.db.profile.general.barPosition)
  if self.db.profile.general.barFullscreen then
    self.frames.bar:SetPoint("LEFT")
    self.frames.bar:SetPoint("RIGHT")
  else
    local relativePoint = self.db.profile.general.barHoriz
    if relativePoint == 'CENTER' then
      relativePoint = 'BOTTOM'
    end
    self.frames.bar:SetPoint(self.db.profile.general.barHoriz, self.frames.bar:GetParent(), relativePoint)
    self.frames.bar:SetWidth(self.db.profile.general.barWidth)
  end
  self.frames.bar:SetHeight(self:GetHeight())

  self.frames.bgTexture:SetAllPoints()
  if self.db.profile.color.useCC then
    self.frames.bgTexture:SetColorTexture(self:GetClassColors())
  else
    self.frames.bgTexture:SetColorTexture(barColor.r, barColor.g, barColor.b, barColor.a)
  end

  for name, module in self:IterateModules() do
    if module['Refresh'] == nil then return; end
    module:Refresh()
  end
end

function XIVBar:GetFont(size)
  return self.LSM:Fetch(self.LSM.MediaType.FONT, self.db.profile.text.font), size, self.fontFlags[self.db.profile.text.flags]
end

function XIVBar:GetClassColors()
  return RAID_CLASS_COLORS[self.constants.playerClass].r, RAID_CLASS_COLORS[self.constants.playerClass].g, RAID_CLASS_COLORS[self.constants.playerClass].b, self.db.profile.color.barColor.a
end

function XIVBar:RGBAToHex(r, g, b, a)
  a = a or 1
  r = r <= 1 and r >= 0 and r or 0
  g = g <= 1 and g >= 0 and g or 0
  b = b <= 1 and b >= 0 and b or 0
  a = a <= 1 and a >= 0 and a or 1
  return string.format("%02x%02x%02x%02x", r*255, g*255, b*255, a*255)
end

function XIVBar:HexToRGBA(hex)
  local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
  if not (rhex and ghex and bhex and ahex) then
    return 0, 0, 0, 0
  end
  return (tonumber(rhex, 16) / 255), (tonumber(ghex, 16) / 255), (tonumber(bhex, 16) / 255), (tonumber(ahex, 16) / 255)
end

function XIVBar:PrintTable(table, prefix)
  for k,v in pairs(table) do
    if type(v) == 'table' then
      self:PrintTable(v, prefix..'.'..k)
    else
      print(prefix..'.'..k..': '..tostring(v))
    end
  end
end

function XIVBar:GetGeneralOptions()
  return {
    name = GENERAL_LABEL,
    type = "group",
    order = 3,
    inline = true,
    args = {
      barPosition = {
        name = L['Bar Position'],
        type = "select",
        order = 1,
        values = {TOP = L['Top'], BOTTOM = L['Bottom']},
        style = "dropdown",
        get = function() return self.db.profile.general.barPosition; end,
        set = function(info, value) self.db.profile.general.barPosition = value; self:Refresh(); end,
      },
      barCC = {
        name = L['Use Class Colors for Bar'],
        type = "toggle",
        order = 2,
        set = function(info, val) self.db.profile.color.useCC = val; self:Refresh(); end,
        get = function() return self.db.profile.color.useCC end
      }, -- normal
      barColor = {
        name = L['Bar Color'],
        type = "color",
        order = 3,
        hasAlpha = true,
        set = function(info, r, g, b, a)
          XIVBar:SetColor('barColor', r, g, b, a)
        end,
        get = function() return XIVBar:GetColor('barColor') end,
        disabled = function() return self.db.profile.color.useCC end
      },
      barPadding = {
        name = L['Bar Padding'],
        type = 'range',
        order = 4,
        min = 0,
        max = 10,
        step = 1,
        get = function() return self.db.profile.general.barPadding; end,
        set = function(info, val) self.db.profile.general.barPadding = val; self:Refresh(); end
      },
      moduleSpacing = {
        name = L['Module Spacing'],
        type = 'range',
        order = 5,
        min = 10,
        max = 50,
        step = 1,
        get = function() return self.db.profile.general.moduleSpacing; end,
        set = function(info, val) self.db.profile.general.moduleSpacing = val; self:Refresh(); end
      }
    }
  }
end

function XIVBar:GetPositionOptions()
  return {
    name = L['Positioning Options'],
    type = "group",
    order = 4,
    inline = true,
    args = {
      fullScreen = {
        name = VIDEO_OPTIONS_FULLSCREEN,
        type = 'toggle',
        order = 0,
        get = function() return self.db.profile.general.barFullscreen; end,
        set = function(info, value) self.db.profile.general.barFullscreen = value; self:Refresh(); end,
      },
      barPosition = {
        name = L['Horizontal Position'],
        type = "select",
        order = 1,
        values = {LEFT = L['Left'], CENTER = L['Center'], RIGHT = L['Right']},
        style = "dropdown",
        get = function() return self.db.profile.general.barHoriz; end,
        set = function(info, value) self.db.profile.general.barHoriz = value; self:Refresh(); end,
        disabled = function() return self.db.profile.general.barFullscreen; end
      },
      barWidth = {
        name = L['Bar Width'],
        type = 'range',
        order = 2,
        min = 200,
        max = GetScreenWidth(),
        step = 1,
        get = function() return self.db.profile.general.barWidth; end,
        set = function(info, val) self.db.profile.general.barWidth = val; self:Refresh(); end,
        disabled = function() return self.db.profile.general.barFullscreen; end
      }
    }
  }
end

function XIVBar:GetTextOptions()
  local t = self.LSM:List(self.LSM.MediaType.FONT);
  local fontList = {};
  for k,v in pairs(t) do
    fontList[v] = v;
  end
  return {
    name = LOCALE_TEXT_LABEL,
    type = "group",
    order = 3,
    inline = true,
    args = {
      font = {
        name = L['Font'],
        type = "select",
        order = 1,
        values = fontList,
        style = "dropdown",
        get = function() return self.db.profile.text.font; end,
        set = function(info, val) self.db.profile.text.font = val; self:Refresh(); end
      },
      fontSize = {
        name = FONT_SIZE,
        type = 'range',
        order = 2,
        min = 10,
        max = 20,
        step = 1,
        get = function() return self.db.profile.text.fontSize; end,
        set = function(info, val) self.db.profile.text.fontSize = val; self:Refresh(); end
      },
      smallFontSize = {
        name = L['Small Font Size'],
        type = 'range',
        order = 2,
        min = 10,
        max = 20,
        step = 1,
        get = function() return self.db.profile.text.smallFontSize; end,
        set = function(info, val) self.db.profile.text.smallFontSize = val; self:Refresh(); end
      },
      textFlags = {
        name = L['Text Style'],
        type = 'select',
        style = 'dropdown',
        order = 3,
        values = self.fontFlags,
        get = function() return self.db.profile.text.flags; end,
        set = function(info, val) self.db.profile.text.flags = val; self:Refresh(); end
      },
    }
  }
end

function XIVBar:GetTextColorOptions()
  return {
    name = L['Text Colors'],
    type = "group",
    order = 3,
    inline = true,
    args = {
      normal = {
        name = L['Normal'],
        type = "color",
        order = 1,
        width = "double",
        hasAlpha = true,
        set = function(info, r, g, b, a)
          XIVBar:SetColor('normal', r, g, b, a)
        end,
        get = function() return XIVBar:GetColor('normal') end
      }, -- normal
      hoverCC = {
        name = L['Use Class Colors for Hover'],
        type = "toggle",
        order = 2,
        set = function(info, val) self.db.profile.color.useHoverCC = val; self:Refresh(); end,
        get = function() return self.db.profile.color.useHoverCC end
      }, -- normal
      inactive = {
        name = L['Inactive'],
        type = "color",
        order = 3,
        hasAlpha = true,
        width = "double",
        set = function(info, r, g, b, a)
          XIVBar:SetColor('inactive', r, g, b, a)
        end,
        get = function() return XIVBar:GetColor('inactive') end
      }, -- normal
      hover = {
        name = L['Hover'],
        type = "color",
        order = 4,
        hasAlpha = true,
        set = function(info, r, g, b, a)
          XIVBar:SetColor('hover', r, g, b, a)
        end,
        get = function() return XIVBar:GetColor('hover') end,
        disabled = function() return self.db.profile.color.useHoverCC end
      }, -- normal
    }
  }
end
