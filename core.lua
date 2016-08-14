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
    },
    color = {
      barColor = {
        r = 0.25,
        g = 0.25,
        b = 0.25,
        a = 1
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
  playerClass = select(2, UnitClass("player"))
}

XIVBar.LSM = LibStub('LibSharedMedia-3.0');

function XIVBar:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("XIVBarDB", self.defaults)
  self.LSM:Register(self.LSM.MediaType.FONT, 'Homizio Bold', self.constants.mediaPath.."homizio_bold.ttf")
  self.frames = {}

  --[[local options = {
    name = "XIV Bar",
    handler = XIVBar,
    type = 'group',
    args = {
      general = {
        name = L['General'],
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
          barColor = {
            name = L['Bar Color'],
            type = "color",
            order = 2,
            hasAlpha = true,
            set = function(info, r, g, b, a)
              XIVBar:SetColor('barColor', r, g, b, a)
            end,
            get = function() return XIVBar:GetColor('barColor') end
          },
        }
      }
    }
  }]]--

  local options = {
    name = "XIV Bar",
    handler = XIVBar,
    type = 'group',
    args = {
      general = {
        name = L['General'],
        type = "group",
        args = {
          general = self:GetGeneralOptions(),
          text = self:GetTextOptions(),
          textColors = self:GetTextColorOptions(), -- colors
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

  --LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOnName.."-Profiles", )




  self:RegisterChatCommand('xivbar', 'ToggleConfig')
end

function XIVBar:OnEnable()
  self:CreateMainBar()
  self:Refresh()
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
  return (self.db.profile.text.fontSize * 2) + 3
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
  self.frames.bar:SetPoint("LEFT")
  self.frames.bar:SetPoint("RIGHT")
  self.frames.bar:SetHeight(self:GetHeight())

  self.frames.bgTexture:SetAllPoints()
  if self.db.profile.color.useCC then
    self.frames.bgTexture:SetColorTexture(
      RAID_CLASS_COLORS[self.constants.playerClass].r,
      RAID_CLASS_COLORS[self.constants.playerClass].g,
      RAID_CLASS_COLORS[self.constants.playerClass].b,
      barColor.a
    )
  else
    self.frames.bgTexture:SetColorTexture(barColor.r, barColor.g, barColor.b, barColor.a)
  end

  for name, module in self:IterateModules() do
    if module['Refresh'] == nil then return; end
    module:Refresh()
  end
end

function XIVBar:RGBAToHex(r, g, b, a)
  a = a or 1
  r = r <= 1 and r >= 0 and r or 0
  g = g <= 1 and g >= 0 and g or 0
  b = b <= 1 and b >= 0 and b or 0
  a = a <= 1 and a >= 0 and a or 1
  return string.format("%02x%02x%02x%02x", r*255, g*255, b*255, a*255)
end



function XIVBar:GetGeneralOptions()
  return {
    name = L['General'],
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
    name = L['Text'],
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
        name = L['Font Size'],
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
