local AddOnName, Engine = ...;
local _G = _G;
local pairs, unpack, select = pairs, unpack, select
local XIVBar = LibStub("AceAddon-3.0"):NewAddon(AddOnName);
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnName, false);

XIVBar.defaults = {
  profile = {
    color = {
      barColor = {
        r = 0.25,
        g = 0.25,
        b = 0.25,
        a = 1
      },
      normal = {
        r = 1,
        g = 1,
        b = 1,
        a = 0.75
      }
    }
  }
};

XIVBar.constants = {
  mediaPath = "Interface\\AddOns\\"..AddOnName.."\\media\\",
  playerName = UnitName("player"),
  playerClass = select(2, UnitClass("player"))
}

Engine[1] = XIVBar;
Engine[2] = L;
_G.XIVBar = Engine;

XIVBar.LSM = LibStub('LibSharedMedia-3.0');

_G[AddOnName] = Engine;

function XIVBar:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("XIVBarDB", self.defaults, "Default")
  local options = {
    name = "XIV Bar",
    handler = XIVBar,
    type = 'group',
    args = {
      general = {
        name = L['Test'],
        type = "group",
        args = {
          colors = {
            name = L['Text Colors'],
            type = "group",
            inline = true,
            args = {
              normal = {
                name = L['Normal'],
                type = "color",
                hasAlpha = true,
                set = function(info, r, g, b, a)
                  XIVBar:SetColor('normal', r, g, b, a)
                end,
                get = function() return XIVBar:GetColor('normal') end
              }, -- normal
              inactive = {
                name = L['Inactive'],
                type = "color",
                hasAlpha = true,
                set = function(info, r, g, b, a)
                  XIVBar:SetColor('normal', r, g, b, a)
                end,
                get = function() return XIVBar:GetColor('normal') end
              }, -- normal
              hoverCC = {
                name = L['Hover Class Colors'],
                type = "color",
                hasAlpha = true,
                set = function(info, r, g, b, a)
                  XIVBar:SetColor('normal', r, g, b, a)
                end,
                get = function() return XIVBar:GetColor('normal') end
              }, -- normal
              hover = {
                name = L['Normal'],
                type = "color",
                hasAlpha = true,
                set = function(info, r, g, b, a)
                  XIVBar:SetColor('normal', r, g, b, a)
                end,
                get = function() return XIVBar:GetColor('normal') end
              }, -- normal
            }
          }, -- colors
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
  LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOnName, options)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, "XIV Bar", nil, "general")

  --LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOnName.."-Profiles", )
  options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  self.profilesOptionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, L['Profiles'], "XIV Bar", "profiles")
end

function XIVBar:OnEnable()
  self.frames = {}
  self.frames.bar = CreateFrame("FRAME")
end

function XIVBar:SetColor(name, r, g, b, a)
  self.db.profile.color[name].r = r
  self.db.profile.color[name].g = g
  self.db.profile.color[name].b = b
  self.db.profile.color[name].a = a
end

function XIVBar:GetColor(name)
  d = self.db.profile.color[name]
  return d.r, d.g, d.b, d.a
end
