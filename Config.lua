local addonName,XB = ...
local Config = XB:RegisterModule("Config")
local AceConfig = LibStub("AceConfig-3.0")
local configDialog = LibStub("AceConfigDialog-3.0")

local options = {
    type = "group",
    args = {
        About = {
            name = "About",
            order = 1,
            type = "group",
            inline = true,
            args = {
                title = {
                    type = "description",
                    name = "|cff64b4ffXIV_Databar",
                    fontSize = "large",
                    order = 0
                },
                desc = {
                    type = "description",
                    name = "XIV_Databar is a powerfull and beautiful information bar highly customizable",
                    fontSize = "medium",
                    order = 1
                },
                author = {
                    type = "description",
                    name = "\n|cffffd100Author: |r Mikeprod",
                    fontSize = "medium",
                    order = 2
                },
                version = {
                    type = "description",
                    name = "|cffffd100Version: |r" .. XB.releaseType ..XB.version,
                    fontSize = "medium",
                    order = 3
                }
            }
        }
    }
}

function ToggleConfig()
	-- TODO: category to open
	if InterfaceOptionsFrame:IsShown() then InterfaceOptionsFrame:Hide(); return end
    InterfaceOptionsFrame.selectedTab = 2;
	InterfaceOptionsFrame:Show()--weird hack ; options registration is wrong in some way
	InterfaceOptionsFrame_OpenToCategory(addonName)
end

function Config:OnInitialize()
    AceConfig:RegisterOptionsTable(addonName, options)
	configDialog:AddToBlizOptions(addonName,addonName)
	self:RegisterChatCommand("xb",ToggleConfig)
	self:RegisterChatCommand("xivb",ToggleConfig)
	self:RegisterChatCommand("xivbar",ToggleConfig)
	self:RegisterChatCommand("xivdatabar",ToggleConfig)
	self:RegisterChatCommand("xiv_databar",ToggleConfig)
end

function Config:OnEnable()
    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(XB.db)
end

function Config:Register(title, config, order)
    if order == nil then order = 10 end
    options.args[title] = {
        name = title,
        order = order,
        type = "group",
		childGroups = "tab",
        args = config
    }
end
