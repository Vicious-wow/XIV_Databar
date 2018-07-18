local MAJOR, MINOR = "LibArtifactData-1.0", 21

assert(_G.LibStub, MAJOR .. " requires LibStub")
local lib = _G.LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.callbacks = lib.callbacks or _G.LibStub("CallbackHandler-1.0"):New(lib)

local Debug = function() end
if _G.AdiDebug then
	Debug = _G.AdiDebug:Embed({}, MAJOR)
end

local artifactPowerData = {
	multiplier = {
		[1] = 1,
		[2] = 1.25,
		[3] = 1.5,
		[4] = 1.9,
		[5] = 2.4,
		[6] = 3,
		[7] = 3.75,
		[8] = 4.75,
		[9] = 6,
		[10] = 7.5,
		[11] = 9.5,
		[12] = 12,
		[13] = 15,
		[14] = 18.75,
		[15] = 23.5,
		[16] = 29.5,
		[17] = 37,
		[18] = 46.5,
		[19] = 58,
		[20] = 73,
		[21] = 91,
		[22] = 114,
		[23] = 143,
		[24] = 179,
		[25] = 224,
		[26] = 250,
		[27] = 1001,
		[28] = 1301,
		[29] = 1701,
		[30] = 2201,
		[31] = 2901,
		[32] = 3801,
		[33] = 4901,
		[34] = 6401,
		[35] = 8301,
		[36] = 10801,
		[37] = 14001,
		[38] = 18201,
		[39] = 23701,
		[40] = 30801,
		[41] = 40001,
		[42] = 160001,
		[43] = 208001,
		[44] = 270401,
		[45] = 351501,
		[46] = 457001,
		[47] = 594001,
		[48] = 772501,
		[49] = 1004001,
		[50] = 1305001,
		[51] = 1696501,
		[52] = 2205501,
		[53] = 2867501,
		[54] = 3727501,
		[55] = 4846001,
		[56] = 6300001,
		[57] = 6300001,
		[58] = 6300001,
		[59] = 6300001,
		[60] = 6300001,
	},
	spells = {
		[179492] = 300, -- Libram of Divinity
		[179958] = 300, -- Artifact Power
		[179959] = 200, -- Artifact Quest Experience - Medium
		[179960] = 200, -- Drawn Power
		[181851] = 300, -- Artifact XP - Large Invasion
		[181852] = 200, -- Artifact XP - Small Invasion
		[181854] = 300, -- Artifact XP - Tomb Completion
		[187511] = 1000, -- XP
		[187536] = 300, -- Artifact Power
		[188542] = 7, -- Shard of Potentiation
		[188543] = 19, -- Crystal of Ensoulment
		[188627] = 19, -- Scroll of Enlightenment
		[188642] = 7, -- Treasured Coin
		[188656] = 79, -- Trembling Phylactery
		[190599] = 100, -- Artifact Power
		[192731] = 150, -- Scroll of Forgotten Knowledge
		[193823] = 250, -- Holy Prayer
		[196374] = 50, -- Artifact Shrine XP Boost
		[196461] = 5, -- Latent Power
		[196493] = 50, -- Channel Magic - Small Artifact XP
		[196499] = 75, -- Channel Magic - Medium Artifact XP
		[196500] = 100, -- Channel Magic - Large Artifact XP
		[199685] = 1000, -- Purified Ashbringer
		[201742] = 100, -- Artifact Power
		[204695] = 1000, -- Purple Hills of Mac'Aree
		[205057] = 1, -- Hidden Power
		[207600] = 300, -- Crystalline Demonic Eye
		[216876] = 10, -- Empowering
		[217024] = 400, -- Empowering
		[217026] = 25, -- Empowering
		[217045] = 75, -- Empowering
		[217055] = 100, -- Empowering
		[217299] = 35, -- Empowering
		[217300] = 35, -- Empowering
		[217301] = 100, -- Empowering
		[217355] = 100, -- Empowering
		[217511] = 50, -- Empowering
		[217512] = 60, -- Empowering
		[217670] = 200, -- Empowering
		[217671] = 400, -- Empowering
		[217689] = 150, -- Empowering
		[220547] = 100, -- Empowering
		[220548] = 235, -- Empowering
		[220549] = 480, -- Empowering
		[220550] = 450, -- Empowering
		[220551] = 530, -- Empowering
		[220553] = 550, -- Empowering
		[220784] = 200, -- Stolen Book of Artifact Lore
		[224139] = 25, -- Light of Elune
		[224544] = 25, -- Light of Elune
		[224583] = 25, -- Light of Elune
		[224585] = 25, -- Light of Elune
		[224593] = 25, -- Light of Elune
		[224595] = 25, -- Light of Elune
		[224608] = 25, -- Light of Elune
		[224610] = 25, -- Light of Elune
		[224633] = 25, -- Light of Elune
		[224635] = 25, -- Light of Elune
		[224641] = 25, -- Light of Elune
		[224643] = 25, -- Light of Elune
		[225897] = 100, -- Empowering
		[227531] = 200, -- Empowering
		[227535] = 300, -- Empowering
		[227886] = 545, -- Empowering
		[227889] = 210, -- Empowering
		[227904] = 35, -- Empowering
		[227905] = 55, -- Empowering
		[227907] = 200, -- Empowering
		[227941] = 150, -- Empowering
		[227942] = 200, -- Empowering
		[227943] = 465, -- Empowering
		[227944] = 520, -- Empowering
		[227945] = 165, -- Empowering
		[227946] = 190, -- Empowering
		[227947] = 210, -- Empowering
		[227948] = 230, -- Empowering
		[227949] = 475, -- Empowering
		[227950] = 515, -- Empowering
		[228067] = 400, -- Empowering
		[228069] = 100, -- Empowering
		[228078] = 500, -- Empowering
		[228079] = 600, -- Empowering
		[228080] = 250, -- Empowering
		[228106] = 490, -- Empowering
		[228107] = 250, -- Empowering
		[228108] = 210, -- Empowering
		[228109] = 170, -- Empowering
		[228110] = 205, -- Empowering
		[228111] = 245, -- Empowering
		[228112] = 160, -- Empowering
		[228130] = 125, -- Empowering
		[228131] = 400, -- Empowering
		[228135] = 250, -- Empowering
		[228220] = 150, -- Empowering
		[228310] = 50, -- Empowering
		[228352] = 500, -- Empowering
		[228422] = 175, -- Empowering
		[228423] = 350, -- Empowering
		[228436] = 170, -- Empowering
		[228437] = 220, -- Empowering
		[228438] = 195, -- Empowering
		[228439] = 185, -- Empowering
		[228440] = 190, -- Empowering
		[228442] = 215, -- Empowering
		[228443] = 180, -- Empowering
		[228444] = 750, -- Empowering
		[228647] = 400, -- Empowering
		[228921] = 500, -- Empowering
		[228955] = 25, -- Empowering
		[228956] = 50, -- Empowering
		[228957] = 35, -- Empowering
		[228959] = 45, -- Empowering
		[228960] = 20, -- Empowering
		[228961] = 25, -- Empowering
		[228962] = 40, -- Empowering
		[228963] = 80, -- Empowering
		[228964] = 150, -- Empowering
		[229746] = 100, -- Empowering
		[229747] = 200, -- Empowering
		[229776] = 1000, -- Empowering
		[229778] = 100, -- Empowering
		[229779] = 300, -- Empowering
		[229780] = 350, -- Empowering
		[229781] = 300, -- Empowering
		[229782] = 500, -- Empowering
		[229783] = 100, -- Empowering
		[229784] = 150, -- Empowering
		[229785] = 800, -- Empowering
		[229786] = 350, -- Empowering
		[229787] = 300, -- Empowering
		[229788] = 600, -- Empowering
		[229789] = 250, -- Empowering
		[229790] = 2000, -- Empowering
		[229791] = 1000, -- Empowering
		[229792] = 4000, -- Empowering
		[229793] = 900, -- Empowering
		[229794] = 1000, -- Empowering
		[229795] = 650, -- Empowering
		[229796] = 450, -- Empowering
		[229798] = 750, -- Empowering
		[229799] = 1200, -- Empowering
		[229803] = 500, -- Empowering
		[229804] = 875, -- Empowering
		[229805] = 1250, -- Empowering
		[229806] = 2500, -- Empowering
		[229807] = 20, -- Empowering
		[229857] = 100, -- Empowering
		[229858] = 100, -- Empowering
		[229859] = 1000, -- Empowering
		[231035] = 100, -- Empowering
		[231041] = 100, -- Empowering
		[231047] = 1000, -- Empowering
		[231048] = 500, -- Empowering
		[231337] = 600, -- Empowering
		[231362] = 200, -- Empowering
		[231453] = 500, -- Empowering
		[231512] = 500, -- Empowering
		[231538] = 250, -- Empowering
		[231543] = 500, -- Empowering
		[231544] = 100, -- Empowering
		[231556] = 500, -- Empowering
		[231581] = 250, -- Empowering
		[231647] = 500, -- Empowering
		[231669] = 500, -- Empowering
		[231709] = 500, -- Empowering
		[231727] = 800, -- Empowering
		[232755] = 90, -- Empowering
		[232832] = 95, -- Empowering
		[232890] = 400, -- Empowering
		[232994] = 100, -- Empowering
		[232995] = 120, -- Empowering
		[232996] = 180, -- Empowering
		[232997] = 800, -- Empowering
		[233030] = 150, -- Empowering
		[233031] = 100, -- Empowering
		[233204] = 500, -- Empowering
		[233209] = 500, -- Empowering
		[233211] = 800, -- Empowering
		[233242] = 300, -- Empowering
		[233243] = 1000, -- Empowering
		[233244] = 250, -- Empowering
		[233245] = 250, -- Empowering
		[233348] = 3000, -- Empowering
		[233816] = 250, -- Empowering
		[234045] = 250, -- Empowering
		[234047] = 400, -- Empowering
		[234048] = 500, -- Empowering
		[234049] = 600, -- Empowering
		[235245] = 175, -- Empowering
		[235246] = 195, -- Empowering
		[235247] = 220, -- Empowering
		[235248] = 240, -- Empowering
		[235256] = 250, -- Empowering
		[235257] = 155, -- Empowering
		[235266] = 500, -- Empowering
		[237344] = 320, -- Empowering
		[237345] = 380, -- Empowering
		[238029] = 85, -- Empowering
		[238030] = 115, -- Empowering
		[238031] = 300, -- Empowering
		[238032] = 400, -- Empowering
		[238033] = 750, -- Empowering
		[238252] = 85, -- Jar of Ashes
		[239094] = 600, -- Empowering
		[239095] = 650, -- Empowering
		[239096] = 270, -- Empowering
		[239097] = 225, -- Empowering
		[239098] = 285, -- Empowering
		[240331] = 200, -- Empowering
		[240332] = 125, -- Empowering
		[240333] = 600, -- Empowering
		[240335] = 240, -- Empowering
		[240337] = 360, -- Empowering
		[240339] = 1600, -- Empowering
		[240483] = 2500, -- Empowering
		[241156] = 175, -- Empowering
		[241157] = 290, -- Empowering
		[241158] = 325, -- Empowering
		[241159] = 465, -- Empowering
		[241160] = 300, -- Empowering
		[241161] = 475, -- Empowering
		[241162] = 540, -- Empowering
		[241163] = 775, -- Empowering
		[241164] = 375, -- Empowering
		[241165] = 600, -- Empowering
		[241166] = 675, -- Empowering
		[241167] = 1000, -- Empowering
		[241471] = 750, -- Empowering
		[241476] = 1000, -- Empowering
		[241752] = 800, -- Empowering
		[241753] = 255, -- Empowering
		[242062] = 500, -- Empowering
		[242116] = 3125, -- Empowering
		[242117] = 2150, -- Empowering
		[242118] = 1925, -- Empowering
		[242119] = 1250, -- Empowering
		[242564] = 1200, -- Empowering
		[242572] = 725, -- Empowering
		[242573] = 1500, -- Empowering
		[242575] = 5000, -- Empowering
		[242884] = 625, -- Empowering
		[242886] = 125, -- Empowering
		[242887] = 100, -- Empowering
		[242890] = 50, -- Empowering
		[242891] = 500, -- Empowering
		[242893] = 250, -- Empowering
		[242911] = 2000, -- Empowering
		[242912] = 400, -- Empowering
		[244814] = 600, -- Empowering
		[246165] = 500, -- Empowering
		[246166] = 525, -- Empowering
		[246167] = 625, -- Empowering
		[246168] = 275, -- Empowering
		[247040] = 750, -- Empowering
		[247075] = 250, -- Empowering
		[247316] = 450, -- Empowering
		[247319] = 125, -- Empowering
		[247631] = 300, -- Empowering
		[247633] = 700, -- Empowering
		[247634] = 1000, -- Empowering
		[248047] = 800, -- Empowering
		[248841] = 20, -- Empowering
		[248842] = 30, -- Empowering
		[248843] = 40, -- Empowering
		[248844] = 50, -- Empowering
		[248845] = 60, -- Empowering
		[248846] = 70, -- Empowering
		[248847] = 80, -- Empowering
		[248848] = 90, -- Empowering
		[248849] = 100, -- Empowering
		[250374] = 550, -- Empowering
		[250375] = 590, -- Empowering
		[250376] = 575, -- Empowering
		[250377] = 625, -- Empowering
		[250378] = 610, -- Empowering
		[250379] = 650, -- Empowering
		[251039] = 3500, -- Empowering
		[252078] = 200, -- Empowering
		[253833] = 400, -- Empowering
		[253834] = 600, -- Empowering
		[253902] = 1200, -- Empowering
		[253931] = 875, -- Empowering
		[254000] = 10000, -- Empowering
		[254387] = 500, -- Empowering
		[254593] = 200, -- Empowering
		[254603] = 570, -- Empowering
		[254608] = 630, -- Empowering
		[254609] = 565, -- Empowering
		[254610] = 635, -- Empowering
		[254656] = 645, -- Empowering
		[254657] = 745, -- Empowering
		[254658] = 550, -- Empowering
		[254659] = 650, -- Empowering
		[254660] = 640, -- Empowering
		[254661] = 560, -- Empowering
		[254662] = 625, -- Empowering
		[254663] = 575, -- Empowering
		[254699] = 50, -- Empowering
		[254761] = 750, -- Empowering
		[255161] = 650, -- Empowering
		[255162] = 550, -- Empowering
		[255163] = 750, -- Empowering
		[255165] = 800, -- Empowering
		[255166] = 600, -- Empowering
		[255167] = 900, -- Empowering
		[255168] = 1000, -- Empowering
		[255169] = 1250, -- Empowering
		[255170] = 1000, -- Empowering
		[255171] = 450, -- Empowering
		[255172] = 600, -- Empowering
		[255173] = 750, -- Empowering
		[255175] = 850, -- Empowering
		[255176] = 600, -- Empowering
		[255177] = 520, -- Empowering
		[255178] = 550, -- Empowering
		[255179] = 535, -- Empowering
		[255180] = 305, -- Empowering
		[255181] = 315, -- Empowering
		[255182] = 330, -- Empowering
		[255183] = 345, -- Empowering
		[255184] = 350, -- Empowering
		[255185] = 555, -- Empowering
		[255186] = 60, -- Empowering
		[255187] = 90, -- Empowering
		[255188] = 75, -- Empowering
	},
	items = {
		[127999] = 10, -- Shard of Potentiation
		[128000] = 25, -- Crystal of Ensoulment
		[128021] = 25, -- Scroll of Enlightenment
		[128022] = 10, -- Treasured Coin
		[128026] = 150, -- Trembling Phylactery
		[130144] = 50, -- Crystallized Fey Darter Egg
		[130149] = 100, -- Carved Smolderhide Figurines
		[130153] = 100, -- Godafoss Essence
		[130159] = 100, -- Ravencrest Shield
		[130160] = 100, -- Vial of Pure Moonrest Water
		[130165] = 75, -- Heathrow Keepsake
		[131728] = 75, -- Urn of Malgalor's Blood
		[131758] = 50, -- Oversized Acorn
		[131778] = 50, -- Woodcarved Rabbit
		[131784] = 50, -- Left Half of a Locket
		[131785] = 50, -- Right Half of a Locket
		[131789] = 75, -- Handmade Mobile
		[132361] = 50, -- Petrified Arkhana
		[132923] = 50, -- Hrydshal Etching
		[134118] = 150, -- Cluster of Potentiation
		[134133] = 150, -- Jewel of Brilliance
		[138726] = 10, -- Shard of Potentiation
	}
}

-- local store
local artifacts = {}
local equippedID, viewedID, activeID
artifacts.knowledgeLevel = 0
artifacts.knowledgeMultiplier = 1

-- constants
local _G                       = _G
local BACKPACK_CONTAINER       = _G.BACKPACK_CONTAINER
local BANK_CONTAINER           = _G.BANK_CONTAINER
local INVSLOT_MAINHAND         = _G.INVSLOT_MAINHAND
local LE_ITEM_CLASS_ARMOR      = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_WEAPON     = _G.LE_ITEM_CLASS_WEAPON
local LE_ITEM_QUALITY_ARTIFACT = _G.LE_ITEM_QUALITY_ARTIFACT
local NUM_BAG_SLOTS            = _G.NUM_BAG_SLOTS
local NUM_BANKBAGSLOTS         = _G.NUM_BANKBAGSLOTS

-- blizzard api
local aUI                              = _G.C_ArtifactUI
local Clear                            = aUI.Clear
local GetArtifactInfo                  = aUI.GetArtifactInfo
local GetArtifactKnowledgeLevel        = aUI.GetArtifactKnowledgeLevel or _G.nop
local GetArtifactKnowledgeMultiplier   = aUI.GetArtifactKnowledgeMultiplier or _G.nop
local GetContainerItemInfo             = _G.GetContainerItemInfo
local GetContainerNumSlots             = _G.GetContainerNumSlots
local GetCostForPointAtRank            = aUI.GetCostForPointAtRank
local GetEquippedArtifactInfo          = aUI.GetEquippedArtifactInfo
local GetInventoryItemEquippedUnusable = _G.GetInventoryItemEquippedUnusable
local GetItemInfo                      = _G.GetItemInfo
local GetItemSpell                     = _G.GetItemSpell
local GetNumObtainedArtifacts          = aUI.GetNumObtainedArtifacts
local GetNumPurchasableTraits          = _G.ArtifactBarGetNumArtifactTraitsPurchasableFromXP or _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local GetNumRelicSlots                 = aUI.GetNumRelicSlots
local GetPowerInfo                     = aUI.GetPowerInfo
local GetPowers                        = aUI.GetPowers
local GetRelicInfo                     = aUI.GetRelicInfo
local GetRelicLockedReason             = aUI.GetRelicLockedReason
local GetRelicSlotRankInfo             = aUI.GetRelicSlotRankInfo or _G.nop
local GetSpellInfo                     = _G.GetSpellInfo
local HasArtifactEquipped              = _G.HasArtifactEquipped
local IsArtifactPowerItem              = _G.IsArtifactPowerItem
local IsAtForge                        = aUI.IsAtForge
local IsViewedArtifactEquipped         = aUI.IsViewedArtifactEquipped
local SocketContainerItem              = _G.SocketContainerItem
local SocketInventoryItem              = _G.SocketInventoryItem

-- lua api
local select   = _G.select
local strmatch = _G.string.match
local tonumber = _G.tonumber

local private = {} -- private space for the event handlers

lib.frame = lib.frame or _G.CreateFrame("Frame")
local frame = lib.frame
frame:UnregisterAllEvents() -- deactivate old versions
frame:SetScript("OnEvent", function(_, event, ...) private[event](event, ...) end)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function CopyTable(tbl)
	if not tbl then return {} end
	local copy = {};
	for k, v in pairs(tbl) do
		if ( type(v) == "table" ) then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

local function PrepareForScan()
	frame:UnregisterEvent("ARTIFACT_UPDATE")
	_G.UIParent:UnregisterEvent("ARTIFACT_UPDATE")

	local ArtifactFrame = _G.ArtifactFrame
	if ArtifactFrame and not ArtifactFrame:IsShown() then
		ArtifactFrame:UnregisterEvent("ARTIFACT_UPDATE")
		ArtifactFrame:UnregisterEvent("ARTIFACT_CLOSE")
		ArtifactFrame:UnregisterEvent("ARTIFACT_MAX_RANKS_UPDATE")
	end
end

local function RestoreStateAfterScan()
	frame:RegisterEvent("ARTIFACT_UPDATE")
	_G.UIParent:RegisterEvent("ARTIFACT_UPDATE")

	local ArtifactFrame = _G.ArtifactFrame
	if ArtifactFrame and not ArtifactFrame:IsShown() then
		Clear()
		ArtifactFrame:RegisterEvent("ARTIFACT_UPDATE")
		ArtifactFrame:RegisterEvent("ARTIFACT_CLOSE")
		ArtifactFrame:RegisterEvent("ARTIFACT_MAX_RANKS_UPDATE")
	end
end

local function InformEquippedArtifactChanged(artifactID)
	if artifactID ~= equippedID then
		Debug("ARTIFACT_EQUIPPED_CHANGED", artifactID, equippedID)
		lib.callbacks:Fire("ARTIFACT_EQUIPPED_CHANGED", artifactID, equippedID)
		equippedID = artifactID
	end
end

local function InformActiveArtifactChanged(artifactID)
	local oldActiveID = activeID
	if artifactID and not GetInventoryItemEquippedUnusable("player", INVSLOT_MAINHAND) then
		activeID = artifactID
	else
		activeID = nil
	end
	if oldActiveID ~= activeID then
		Debug("ARTIFACT_ACTIVE_CHANGED", activeID, oldActiveID)
		lib.callbacks:Fire("ARTIFACT_ACTIVE_CHANGED", activeID, oldActiveID)
	end
end

local function InformTraitsChanged(artifactID)
	Debug("ARTIFACT_TRAITS_CHANGED", artifactID, artifacts[artifactID].traits)
	lib.callbacks:Fire("ARTIFACT_TRAITS_CHANGED", artifactID, CopyTable(artifacts[artifactID].traits))
end

local function StoreArtifact(itemID, altItemID, name, icon, unspentPower, numRanksPurchased, numRanksPurchasable,
	power, maxPower, tier)

	local current, isNewArtifact = artifacts[itemID], false
	if not current then
		isNewArtifact = true
		artifacts[itemID] = {
			altItemID = altItemID,
			name = name,
			icon = icon,
			unspentPower = unspentPower,
			numRanksPurchased = numRanksPurchased,
			numRanksPurchasable = numRanksPurchasable,
			power = power,
			maxPower = maxPower,
			powerForNextRank = maxPower - power,
			traits = {},
			relics = {},
			tier = tier,
		}
	else
		current.unspentPower = unspentPower
		current.numRanksPurchased = numRanksPurchased -- numRanksPurchased does not include bonus traits from relics
		current.numRanksPurchasable = numRanksPurchasable
		current.power = power
		current.maxPower = maxPower
		current.powerForNextRank = maxPower - power
		current.tier = tier
	end

	return isNewArtifact
end

local function ScanTraits(artifactID)
	local traits = {}
	local powers = GetPowers()

	for i = 1, #powers do
		local traitID = powers[i]
		local info = GetPowerInfo(traitID)
		local spellID = info.spellID
		if (info.currentRank) > 0 then
			local name, _, icon = GetSpellInfo(spellID)
			traits[#traits + 1] = {
				traitID = traitID,
				spellID = spellID,
				name = name,
				icon = icon,
				currentRank = info.currentRank,
				maxRank = info.maxRank,
				bonusRanks = info.bonusRanks,
				isGold = info.isGoldMedal,
				isStart = info.isStart,
				isFinal = info.isFinal,
				maxRanksFromTier = info.numMaxRankBonusFromTier,
				tier = info.tier,
			}
		end
	end

	if artifactID then
		artifacts[artifactID].traits = traits
	end

	return traits
end

local function ScanRelics(artifactID, doNotInform)
	local relics = artifactID and artifacts[artifactID] and artifacts[artifactID].relics or {}
	local changedSlots = {}
	local numRelicSlots = GetNumRelicSlots()

	for i = 1, numRelicSlots do
		local isLocked, name, icon, slotType, link, itemID, rank, canAddTalent = GetRelicLockedReason(i) and true or false
		if not isLocked then
			name, icon, slotType, link = GetRelicInfo(i)
			rank, canAddTalent = GetRelicSlotRankInfo(i)
			if link then
				itemID = strmatch(link, "item:(%d+):")
			end
		end

		local current = relics[i]
		if current then
			if current.itemID ~= itemID or current.isLocked ~= isLocked or
			   current.rank ~= rank or current.canAddTalent ~= canAddTalent then
				changedSlots[#changedSlots + 1] = i

				if current.itemID ~= itemID then
					current.name = name
					current.icon = icon
					current.itemID = itemID
					current.link = link
					current.talents = {}
				end
				current.isLocked = isLocked
				current.rank = rank
				current.canAddTalent = canAddTalent
			end
		else
			changedSlots[#changedSlots + 1] = i
			relics[i] = {
				type = slotType, isLocked = isLocked, name = name, icon = icon,
				itemID = itemID, link = link, rank = rank, canAddTalent = canAddTalent, talents = {},
			}
		end
	end

	if not doNotInform then
		for i = 1, #changedSlots do
			local slot = changedSlots[i]
			Debug("ARTIFACT_RELIC_CHANGED", viewedID, slot, relics[slot])
			lib.callbacks:Fire("ARTIFACT_RELIC_CHANGED", viewedID, slot, CopyTable(relics[slot]))
		end
	end

	if #changedSlots > 0 or numRelicSlots == 0 then
		ScanTraits(viewedID)
		if not doNotInform then
			InformTraitsChanged(viewedID)
		end
	end

	return relics
end

local function GetArtifactKnowledge()
	if viewedID == 133755 then return end -- exclude Underlight Angler
	local lvl = GetArtifactKnowledgeLevel()
	local mult = GetArtifactKnowledgeMultiplier()
	if artifacts.knowledgeMultiplier ~= mult or artifacts.knowledgeLevel ~= lvl then
		artifacts.knowledgeLevel = lvl
		artifacts.knowledgeMultiplier = mult
		Debug("ARTIFACT_KNOWLEDGE_CHANGED", lvl, mult)
		lib.callbacks:Fire("ARTIFACT_KNOWLEDGE_CHANGED", lvl, mult)
	end
end

local function GetViewedArtifactData()
	local itemID, altItemID, name, icon, unspentPower, numRanksPurchased, _, _, _, _, _, _, tier = GetArtifactInfo()
	if not itemID then
		Debug("|cffff0000ERROR:|r", "GetArtifactInfo() returned nil.")
		return
	end

	viewedID = itemID
	Debug("GetViewedArtifactData", name, itemID)
	local numRanksPurchasable, power, maxPower = GetNumPurchasableTraits(numRanksPurchased, unspentPower, tier)

	local isNewArtifact = StoreArtifact(
		itemID, altItemID, name, icon, unspentPower, numRanksPurchased,
		numRanksPurchasable, power, maxPower, tier
	)
	ScanRelics(viewedID, isNewArtifact)

	if isNewArtifact then
		Debug("ARTIFACT_ADDED", itemID, name)
		lib.callbacks:Fire("ARTIFACT_ADDED", itemID)
	end

	if IsViewedArtifactEquipped() then
		InformEquippedArtifactChanged(itemID)
		InformActiveArtifactChanged(itemID)
	end

	GetArtifactKnowledge()
end

local function ScanEquipped()
	if HasArtifactEquipped() then
		PrepareForScan()
		SocketInventoryItem(INVSLOT_MAINHAND)
		GetViewedArtifactData()
		Clear()
		RestoreStateAfterScan()
		frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	end
end

local function ScanContainer(container, numObtained)
	for slot = 1, GetContainerNumSlots(container) do
		local _, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(container, slot)
		if quality == LE_ITEM_QUALITY_ARTIFACT then
			local classID = select(12, GetItemInfo(itemID))
			if classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR then
				Debug("ARTIFACT_FOUND", "in", container, slot)
				SocketContainerItem(container, slot)
				GetViewedArtifactData()
				Clear()
				if numObtained <= lib:GetNumObtainedArtifacts() then break end
			end
		end
	end
end

local function IterateContainers(from, to, numObtained)
	PrepareForScan()
	for container = from, to do
		ScanContainer(container, numObtained)
		if numObtained <= lib:GetNumObtainedArtifacts() then break end
	end
	RestoreStateAfterScan()
end

local function ScanBank(numObtained)
	if numObtained > lib:GetNumObtainedArtifacts() then
		PrepareForScan()
		ScanContainer(BANK_CONTAINER, numObtained)
		RestoreStateAfterScan()
	end
	if numObtained > lib:GetNumObtainedArtifacts() then
		IterateContainers(NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS, numObtained)
	end
end

function private.PLAYER_ENTERING_WORLD(event)
	frame:UnregisterEvent(event)
	frame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
	frame:RegisterEvent("BAG_UPDATE_DELAYED")
	frame:RegisterEvent("BANKFRAME_OPENED")
	frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	frame:RegisterEvent("ARTIFACT_CLOSE")
	frame:RegisterEvent("ARTIFACT_XP_UPDATE")
	frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	if _G.UnitLevel("player") < 110 then
		frame:RegisterEvent("PLAYER_LEVEL_UP")
	end
end

-- bagged artifact data becomes obtainable
function private.BAG_UPDATE_DELAYED(event)
	local numObtained = GetNumObtainedArtifacts()
	if numObtained <= 0 then return end

	-- prevent double-scanning if UNIT_INVENTORY_CHANGED fired first
	-- UNIT_INVENTORY_CHANGED does not fire after /reload
	if not equippedID and HasArtifactEquipped() then
		ScanEquipped()
	end

	if numObtained > lib:GetNumObtainedArtifacts() then
		IterateContainers(BACKPACK_CONTAINER, NUM_BAG_SLOTS, numObtained)
	end

	frame:UnregisterEvent(event)
end

-- equipped artifact data becomes obtainable
function private.UNIT_INVENTORY_CHANGED(event)
	ScanEquipped(event)
end

function private.ARTIFACT_CLOSE()
	viewedID = nil
end

function private.ARTIFACT_UPDATE(event, newItem)
	Debug(event, newItem)
	if newItem then
		GetViewedArtifactData()
	else
		if not GetNumRelicSlots() then
			Debug("|cffff0000ERROR:|r", "artifact data unobtainable.")
			return
		end
		ScanRelics(viewedID)
	end
end

function private.ARTIFACT_XP_UPDATE(event)
	-- at the forge the player can purchase traits even for unequipped artifacts
	local GetInfo = IsAtForge() and GetArtifactInfo or GetEquippedArtifactInfo
	local itemID, _, _, _, unspentPower, numRanksPurchased, _, _, _, _, _, _, tier = GetInfo()
	local numRanksPurchasable, power, maxPower = GetNumPurchasableTraits(numRanksPurchased, unspentPower, tier)

	local artifact = artifacts[itemID]
	if not artifact then
		return lib.ForceUpdate()
	end

	local diff = unspentPower - artifact.unspentPower

	if numRanksPurchased ~= artifact.numRanksPurchased then
		-- both learning traits and artifact respec trigger ARTIFACT_XP_UPDATE
		-- however respec has a positive diff and learning traits has a negative one
		ScanTraits(itemID)
		InformTraitsChanged(itemID)
	end

	if diff ~= 0 then
		artifact.unspentPower = unspentPower
		artifact.power = power
		artifact.maxPower = maxPower
		artifact.numRanksPurchased = numRanksPurchased
		artifact.numRanksPurchasable = numRanksPurchasable
		artifact.powerForNextRank = maxPower - power
		Debug(event, itemID, diff, unspentPower, power, maxPower, maxPower - power, numRanksPurchasable)
		lib.callbacks:Fire("ARTIFACT_POWER_CHANGED", itemID, diff, unspentPower, power, maxPower, maxPower - power, numRanksPurchasable)
	end
end

function private.BANKFRAME_OPENED()
	local numObtained = GetNumObtainedArtifacts()
	if numObtained > lib:GetNumObtainedArtifacts() then
		ScanBank(numObtained)
	end
end

function private.PLAYER_LEVEL_UP(event, level)
	if level < 110 then return end

	ScanEquipped()
	frame:UnregisterEvent(event)
end

function private.PLAYER_EQUIPMENT_CHANGED(event, slot)
	if slot == INVSLOT_MAINHAND then
		local itemID = GetEquippedArtifactInfo()

		if itemID and not artifacts[itemID] then
			ScanEquipped(event)
		end

		InformEquippedArtifactChanged(itemID)
		InformActiveArtifactChanged(itemID)
	end
end

-- needed in case the game fails to switch artifacts
function private.PLAYER_SPECIALIZATION_CHANGED(event)
	local itemID = GetEquippedArtifactInfo()
	Debug(event, itemID)
	InformActiveArtifactChanged(itemID)
end

function lib.GetActiveArtifactID()
	return activeID
end

function lib.GetArtifactInfo(_, artifactID)
	artifactID = tonumber(artifactID) or equippedID
	return artifactID, CopyTable(artifacts[artifactID])
end

function lib.GetAllArtifactsInfo()
	return CopyTable(artifacts)
end

function lib.GetNumObtainedArtifacts()
	local numArtifacts = 0
	for artifact in pairs(artifacts) do
		if tonumber(artifact) then
			numArtifacts = numArtifacts + 1
		end
	end

	return numArtifacts
end

function lib.GetArtifactTraitInfo(_, id, artifactID)
	artifactID = artifactID or equippedID
	local artifact = artifacts[artifactID]
	if id and artifact then
		local traits = artifact.traits
		for i = 1, #traits do
			local info = traits[i]
			if id == info.traitID or id == info.spellID then
				return CopyTable(info)
			end
		end
	end
end

function lib.GetArtifactTraits(_, artifactID)
	artifactID = tonumber(artifactID) or equippedID
	local artifact = artifacts[artifactID]
	if not artifact then return end
	return artifactID, CopyTable(artifact.traits)
end

function lib.GetArtifactRelics(_, artifactID)
	artifactID = tonumber(artifactID) or equippedID
	local artifact = artifacts[artifactID]
	if not artifact then return end
	return artifactID, CopyTable(artifact.relics)
end

function lib.GetArtifactPower(_, artifactID)
	artifactID = tonumber(artifactID) or equippedID
	local artifact = artifacts[artifactID]
	if not artifact then return end
	return artifactID, artifact.unspentPower, artifact.power, artifact.maxPower,
	       artifact.powerForNextRank, artifact.numRanksPurchased, artifact.numRanksPurchasable
end

function lib.GetArtifactKnowledge()
	return artifacts.knowledgeLevel, artifacts.knowledgeMultiplier
end

function lib.GetAcquiredArtifactPower(_, artifactID)
	local total = 0

	if artifactID then
		local data = artifacts[artifactID]
		total = total + data.unspentPower
		local rank = 1
		while rank < data.numRanksPurchased do
			total = total + GetCostForPointAtRank(rank, data.tier)
			rank = rank + 1
		end

		return total
	end

	for itemID, data in pairs(artifacts) do
		if tonumber(itemID) then
			total = total + data.unspentPower
			local rank = 1
			while rank < data.numRanksPurchased do
				total = total + GetCostForPointAtRank(rank, data.tier)
				rank = rank + 1
			end
		end
	end

	return total
end

function lib.GetArtifactPowerFromItem(_, item)
	local itemID, knowledgeLevel = tonumber(item), 1
	if not itemID then
		itemID, knowledgeLevel = item:match("item:(%d+).-(%d*):::|h")
		if not itemID then return end
		knowledgeLevel = tonumber(knowledgeLevel) or 1
	end

	if IsArtifactPowerItem(itemID) then
		local _, _, spellID = GetItemSpell(itemID)
		return artifactPowerData.multiplier[knowledgeLevel] * (artifactPowerData.spells[spellID] or 0)
	elseif artifactPowerData.items[itemID] then
		return artifactPowerData.multiplier[knowledgeLevel] * artifactPowerData.items[itemID]
	end
end

function lib.ForceUpdate()
	if _G.ArtifactFrame and _G.ArtifactFrame:IsShown() then
		Debug("ForceUpdate", "aborted because ArtifactFrame is open.")
		return
	end
	local numObtained = GetNumObtainedArtifacts()
	if numObtained > 0 then
		ScanEquipped("FORCE_UPDATE")
		IterateContainers(BACKPACK_CONTAINER, NUM_BAG_SLOTS, numObtained)
	end
end

local function TraitsIterator(traits, index)
	index = index and index + 1 or 1
	local trait = traits[index]
	if trait then
		return index, trait.traitID, trait.spellID, trait.name, trait.icon, trait.currentRank, trait.maxRank,
		       trait.bonusRanks, trait.isGold, trait.isStart, trait.isFinal
	end
end

function lib.IterateTraits(_, artifactID)
	artifactID = tonumber(artifactID) or equippedID
	local artifact = artifacts[artifactID]
	if not artifact then return function() return end end

	return TraitsIterator, artifact.traits
end
