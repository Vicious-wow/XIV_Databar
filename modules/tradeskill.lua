local addon, ns = ...
local cfg = ns.cfg
local unpack = unpack
--------------------------------------------------------------
if not cfg.tradeSkill.show then return end

if not IsAddOnLoaded("Blizzard_TradeSkillUI") then
	TradeSkillFrame_LoadUI();
end

local proffessions = {
	['ALCHEMY'] = {"Alchemical Catalyst", "Secrets of Draenor Alchemy", "Northrend Alchemy Research"},
	['BLACKSMITHING'] = {"Truesteel Ignot", "Secrets of Draenor Blacksmithing"},
	['ENCHANTING'] = {"Temporal Crystal", "Secrets of Draenor Enchanting"},
	['ENGINEERING'] = {"Gearsoring Parts", "Secrets of Draenor Engineering"},
	['INSCRIPTION'] = {"War Paints", "Secrets of Draenor Inscription","Draenor Merchant Order"},
	['JEWELCRAFTING'] = {"Taladite Crystal", "Secrets of Draenor Jewelcrafting"},
	['LEATHERWORKING'] = {"Burnished Leather", "Secrets of Draenor Leatherworking"},
	['TAILORING'] = {"Hexweave Cloth", "Secrets of Draenor Tailoring"},
}

local profIcons = {
	[164] = 'blacksmithing',
	[165] = 'leatherworking',
	[171] = 'alchemy',
	[182] = 'herbalism',
	[186] = 'mining',
	[202] = 'engineering',
	[333] = 'enchanting',
	[755] = 'jewelcrafting',
	[773] = 'inscription',
	[197] = 'tailoring',
	[393] = 'skinning'
}

local prof1OnCooldown = false
local prof2OnCooldown = false

local tradeSkillFrame = CreateFrame("Frame",nil, cfg.SXframe)
tradeSkillFrame:SetPoint("LEFT", cfg.SXframe, "CENTER", 110,0)
tradeSkillFrame:SetSize(16, 16)
---------------------------------------------------------------------
local primaryTradeSkillFrame = CreateFrame("BUTTON",nil, tradeSkillFrame)
primaryTradeSkillFrame:SetSize(16, 16)
primaryTradeSkillFrame:SetPoint("LEFT")
primaryTradeSkillFrame:EnableMouse(true)
primaryTradeSkillFrame:RegisterForClicks("AnyUp")

local primaryTradeSkillIcon = primaryTradeSkillFrame:CreateTexture(nil,"OVERLAY",nil,7)
primaryTradeSkillIcon:SetSize(16, 16)
primaryTradeSkillIcon:SetPoint("LEFT")
primaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.normal))

local primaryTradeSkillText = primaryTradeSkillFrame:CreateFontString(nil, "OVERLAY")
primaryTradeSkillText:SetFont(cfg.text.font, cfg.text.normalFontSize)
primaryTradeSkillText:SetPoint("RIGHT",primaryTradeSkillFrame,2,0 )
primaryTradeSkillText:SetTextColor(unpack(cfg.color.normal))

local primaryTradeSkillStatusbar = CreateFrame("StatusBar", nil, primaryTradeSkillFrame)
primaryTradeSkillStatusbar:SetStatusBarTexture(1,1,1)
primaryTradeSkillStatusbar:SetStatusBarColor(unpack(cfg.color.normal))
primaryTradeSkillStatusbar:SetPoint("TOPLEFT", primaryTradeSkillText, "BOTTOMLEFT",0,-2)

local primaryTradeSkillStatusbarBG = primaryTradeSkillStatusbar:CreateTexture(nil,"BACKGROUND",nil,7)
primaryTradeSkillStatusbarBG:SetPoint("TOPLEFT", primaryTradeSkillText, "BOTTOMLEFT",0,-2)
primaryTradeSkillStatusbarBG:SetColorTexture(unpack(cfg.color.inactive))

primaryTradeSkillFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	primaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.hover))
	primaryTradeSkillStatusbar:SetStatusBarColor(unpack(cfg.color.hover))
	if not cfg.tradeSkill.showTooltip then return end
	GameTooltip:SetOwner(tradeSkillFrame, cfg.tooltipPos)
	addCooldownsToTooltip()
	GameTooltip:Show()
end)

primaryTradeSkillFrame:SetScript("OnLeave", function()
	if prof1OnCooldown then
		primaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.inactive))
		primaryTradeSkillText:SetTextColor(unpack(cfg.color.inactive))
	else
		primaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.normal))
		primaryTradeSkillText:SetTextColor(unpack(cfg.color.normal))
	end
	primaryTradeSkillStatusbar:SetStatusBarColor(unpack(cfg.color.normal))
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
end)

primaryTradeSkillFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		local prof1, prof2 = GetProfessions()
		if prof1 then
			if (GetProfessionInfo(prof1) == ('Herbalism')) then
				ToggleSpellBook(BOOKTYPE_PROFESSION)
			elseif(GetProfessionInfo(prof1) == ('Skinning')) then
				ToggleSpellBook(BOOKTYPE_PROFESSION)
			elseif(GetProfessionInfo(prof1) == ('Mining')) then
				CastSpellByName("Smelting")
			else
				CastSpellByName((GetProfessionInfo(prof1)))
			end
		end
	elseif button == "RightButton" then
		ToggleSpellBook(BOOKTYPE_PROFESSION)
	end
end)
---------------------------------------------------------------------
local secondaryTradeSkillFrame = CreateFrame("BUTTON",nil, tradeSkillFrame)
secondaryTradeSkillFrame:SetPoint("RIGHT")
secondaryTradeSkillFrame:SetSize(16, 16)
secondaryTradeSkillFrame:EnableMouse(true)
secondaryTradeSkillFrame:RegisterForClicks("AnyUp")

local secondaryTradeSkillIcon = secondaryTradeSkillFrame:CreateTexture(nil,"OVERLAY",nil,7)
secondaryTradeSkillIcon:SetSize(16, 16)
secondaryTradeSkillIcon:SetPoint("LEFT")
secondaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.normal))

local secondaryTradeSkillText = secondaryTradeSkillFrame:CreateFontString(nil, "OVERLAY")
secondaryTradeSkillText:SetFont(cfg.text.font, cfg.text.normalFontSize)
secondaryTradeSkillText:SetPoint("LEFT", secondaryTradeSkillIcon,"RIGHT",2,0)
secondaryTradeSkillText:SetTextColor(unpack(cfg.color.normal))

local secondaryTradeSkillStatusbar = CreateFrame("StatusBar", nil, secondaryTradeSkillFrame)
secondaryTradeSkillStatusbar:SetStatusBarTexture(1,1,1)
secondaryTradeSkillStatusbar:SetStatusBarColor(unpack(cfg.color.normal))
secondaryTradeSkillStatusbar:SetPoint("TOPLEFT", secondaryTradeSkillText, "BOTTOMLEFT",0,-2)

local secondaryTradeSkillStatusbarBG = secondaryTradeSkillStatusbar:CreateTexture(nil,"BACKGROUND",nil,7)
secondaryTradeSkillStatusbarBG:SetPoint("TOPLEFT", secondaryTradeSkillText, "BOTTOMLEFT",0,-2)
secondaryTradeSkillStatusbarBG:SetColorTexture(unpack(cfg.color.inactive))

secondaryTradeSkillFrame:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	secondaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.hover))
	secondaryTradeSkillStatusbar:SetStatusBarColor(unpack(cfg.color.hover))
	if not cfg.tradeSkill.showTooltip then return end
	GameTooltip:SetOwner(tradeSkillFrame, cfg.tooltipPos)
	addCooldownsToTooltip()
	GameTooltip:Show()
end)

secondaryTradeSkillFrame:SetScript("OnLeave", function()
	if prof2OnCooldown then
		secondaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.inactive))
		secondaryTradeSkillText:SetTextColor(unpack(cfg.color.inactive))
	else
		secondaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.normal))
		secondaryTradeSkillText:SetTextColor(unpack(cfg.color.normal))
	end
	secondaryTradeSkillStatusbar:SetStatusBarColor(unpack(cfg.color.normal))
	if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
end)

secondaryTradeSkillFrame:SetScript("OnClick", function(self, button, down)
	if InCombatLockdown() then return end
	if button == "LeftButton" then
		local prof1, prof2 = GetProfessions()
		if prof2 then
			if (GetProfessionInfo(prof2) == ('Herbalism')) then
				ToggleSpellBook(BOOKTYPE_PROFESSION)
			elseif(GetProfessionInfo(prof2) == ('Skinning')) then
				ToggleSpellBook(BOOKTYPE_PROFESSION)
			elseif(GetProfessionInfo(prof2) == ('Mining')) then
				CastSpellByName("Smelting")
			else
				CastSpellByName((GetProfessionInfo(prof2)))
			end
		end
	elseif button == "RightButton" then
		ToggleSpellBook(BOOKTYPE_PROFESSION)
	end
end)
---------------------------------------------------------------------

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("TRADE_SKILL_UPDATE")
eventframe:RegisterEvent("TRAINER_CLOSED")
eventframe:RegisterEvent("SPELLS_CHANGED")
eventframe:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")

eventframe:SetScript("OnEvent", function(self,event, ...)
	local prof1, prof2 = GetProfessions()
	if prof1 then
		local prof1Name, _, prof1Rank, prof1MaxRank, _, _, prof1SkillLine = GetProfessionInfo(prof1)
		prof1Name = string.upper(prof1Name)
		primaryTradeSkillText:SetText(prof1Name)
		primaryTradeSkillIcon:SetTexture(cfg.mediaFolder.."profession\\"..profIcons[prof1SkillLine])
		if prof1Rank == prof1MaxRank then
			primaryTradeSkillStatusbar:Hide()
		else
			primaryTradeSkillStatusbar:Show()
		end
		primaryTradeSkillStatusbar:SetMinMaxValues(0, prof1MaxRank)
		primaryTradeSkillStatusbar:SetValue(prof1Rank)
		primaryTradeSkillFrame:SetSize(primaryTradeSkillText:GetStringWidth()+18, 16)
		primaryTradeSkillStatusbar:SetSize(primaryTradeSkillText:GetStringWidth(),3)
		primaryTradeSkillStatusbarBG:SetSize(primaryTradeSkillText:GetStringWidth(),3)
		primaryTradeSkillFrame:Show()
		primaryTradeSkillFrame:EnableMouse(true)

		primaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.normal))
		primaryTradeSkillText:SetTextColor(unpack(cfg.color.normal))

		--[[for i=1,GetNumTradeSkills() do
			local cooldown = GetTradeSkillCooldown(i)
			if cooldown then
				local name = GetTradeSkillInfo(i)
				for k, v in pairs(proffessions) do
					for u = 1, #v do
						if k == prof1Name then
							if v[u] == name then
								if not prof1OnCooldown then prof1OnCooldown = true end
								primaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.inactive))
								primaryTradeSkillText:SetTextColor(unpack(cfg.color.inactive))
								if not prof1OnCooldown then
									primaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.normal))
									primaryTradeSkillText:SetTextColor(unpack(cfg.color.normal))
								end
							end
						end
					end
				end
			end
		end]]--
	else
		primaryTradeSkillFrame:Hide()
		primaryTradeSkillFrame:EnableMouse(false)
	end

	if prof2 then
		local prof2Name, _, prof2rank, prof2maxRank, _, _, prof2SkillLine = GetProfessionInfo(prof2)
		prof2Name = string.upper(prof2Name)
		secondaryTradeSkillText:SetText(prof2Name)
		secondaryTradeSkillIcon:SetTexture(cfg.mediaFolder.."profession\\"..profIcons[prof2SkillLine])
		if prof2rank == prof2maxRank then
			secondaryTradeSkillStatusbar:Hide()
		else
			secondaryTradeSkillStatusbar:Show()
		end
		secondaryTradeSkillStatusbar:SetMinMaxValues(0, prof2maxRank)
		secondaryTradeSkillStatusbar:SetValue(prof2rank)
		secondaryTradeSkillFrame:SetSize(secondaryTradeSkillText:GetStringWidth()+18, 16)
		secondaryTradeSkillStatusbar:SetSize(secondaryTradeSkillText:GetStringWidth(),3)
		secondaryTradeSkillStatusbarBG:SetSize(secondaryTradeSkillText:GetStringWidth(),3)
		secondaryTradeSkillFrame:Show()
		secondaryTradeSkillFrame:EnableMouse(true)

		secondaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.normal))
		secondaryTradeSkillText:SetTextColor(unpack(cfg.color.normal))

		--[[for i=1,GetNumTradeSkills() do
			local cooldown = GetTradeSkillCooldown(i)
			if cooldown then
				local name = GetTradeSkillInfo(i)
				for k, v in pairs(proffessions) do
					for u = 1, #v do
						if k == prof2Name then
							if v[u] == name then
								if not prof2OnCooldown then prof2OnCooldown = true end
								secondaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.inactive))
								secondaryTradeSkillText:SetTextColor(unpack(cfg.color.inactive))
								if not prof2OnCooldown then
									secondaryTradeSkillIcon:SetVertexColor(unpack(cfg.color.normal))
									secondaryTradeSkillText:SetTextColor(unpack(cfg.color.normal))
								end
							end
						end
					end
				end
			end
		end]]--
	else
		secondaryTradeSkillFrame:Hide()
		secondaryTradeSkillFrame:EnableMouse(false)
	end
	tradeSkillFrame:SetSize((primaryTradeSkillFrame:GetWidth())+(secondaryTradeSkillFrame:GetWidth()+4), 16)
end)


function addCooldownsToTooltip()
	for i,v in pairs(C_TradeSkillUI.GetFilteredRecipeIDs()) do
	  local _, cooldown, secondsToCooldown, dunno = C_TradeSkillUI.GetRecipeCooldown(v)
	  if cooldown then
	    local name = C_TradeSkillUI.GetRecipeInfo(v).name
	    GameTooltip:AddDoubleLine(name, SecondsToTime(secondsToCooldown), 1, 1, 0, 1, 1, 1)
	  end
	end
end
