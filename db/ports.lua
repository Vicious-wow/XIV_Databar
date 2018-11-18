local addOnName, XB = ...;

XB.portOptions = {
	items = {
		6948,				-- Hearthstone
		93672,				-- Dark Portal
		54452,				-- Ethereal Portal
		28585,				-- Ruby Slippers
		64488,				-- The Innkeeper's Daughter	
		142298,				-- Astonishingly Scarlet Slippers
		142542,				-- Tome of Town Portal
		162973,				-- Greatfather Winter's Hearthstone
		163045,				-- Headless Horseman's Hearthstone
		95051,				-- The Brassiest Knuckle
		118907,				-- Pit Fighter's Punching Ring
		144391,				-- Pugilist's Powerful Punching Ring
		32757,				-- Blessed Medallion of Karabor
		151016, 			-- Fractured Necrolyte Skull
		37863,				-- Direbrew's Remote
		30544,				-- Ultrasafe Transporter - Toshley's Station
		118662, 			-- Bladespire Relic
		50287,				-- Boots of the Bay
		95050,				-- The Brassiest Knuckle
		118908,				-- Pit Fighter's Punching Ring
		144392,				-- Pugilist's Powerful Punching Ring
		144341, 			-- Rechargeable Reaves Battery
		138448,				-- Emblem of Margoss
		139599,				-- Empowered Ring of the Kirin Tor
		140192,				-- Dalaran Hearthstone
		40586,				-- Band of the Kirin Tor
		44934,				-- Loop of the Kirin Tor
		44935,				-- Ring of the Kirin Tor
		40585,				-- Signet of the Kirin Tor
		45688,				-- Inscribed Band of the Kirin Tor
		45689,				-- Inscribed Loop of the Kirin Tor
		45690,				-- Inscribed Ring of the Kirin Tor
		45691,				-- Inscribed Signet of the Kirin Tor
		48954,				-- Etched Band of the Kirin Tor
		48955,				-- Etched Loop of the Kirin Tor
		48956,				-- Etched Ring of the Kirin Tor
		48957,				-- Etched Signet of the Kirin Tor
		51560,				-- Runed Band of the Kirin Tor
		51558,				-- Runed Loop of the Kirin Tor
		51559,				-- Runed Ring of the Kirin Tor
		51557,				-- Runed Signet of the Kirin Tor
		52251,				-- Jaina's Locket
		112059,				-- Wormhole Centrifuge
		110560,				-- Garrison Hearthstone
		46874,				-- Argent Crusader's Tabard
		118663,				-- Relic of Karabor
		22589,				-- Atiesh, Greatstaff of the Guardian
		22630,				-- Atiesh, Greatstaff of the Guardian
		22631,				-- Atiesh, Greatstaff of the Guardian
		22632,				-- Atiesh, Greatstaff of the Guardian
		142469, 			-- Violet Seal of the Grand Magus
		21711,				-- Lunar Festival Invitation
		30542,				-- Dimensional Ripper - Area 52
		48933,				-- Wormhole Generator: Northrend
		63207,				-- Wrap of Unity
		63353,				-- Shroud of Cooperation
		65274,				-- Cloak of Coordination
		87215,				-- Wormhole Generator: Pandaria
		64457, 				-- The Last Relic of Argus
		139590,				-- Scroll of Teleport: Ravenholdt
		128353,				-- Admiral's Compass
		63206,				-- Wrap of Unity
		63352,				-- Shroud of Cooperation
		65360,				-- Cloak of Coordination
		140324,				-- Mobile Telemancy Beacon
		18986,				-- Ultrasafe Transporter - Gadgetzan
		103678,				-- Time-Lost Artifact
		63378,				-- Hellscream's Reach Tabard
		63379,				-- Baradin's Wardens Tabard
		18984,				-- Dimensional Ripper - Everlook
	},
	spells = {
		556,				-- Astral Recall
		281403,				-- Teleport: Boralus
		281400,				-- Portal: Boralus
		224871,				-- Portal: Dalaran - Broken Isles (UNTESTED)
		224869,				-- Teleport: Dalaran - Broken Isles	(UNTESTED)
		53140,				-- Teleport: Dalaran
		53142,				-- Portal: Dalaran
		120145,				-- Ancient Teleport: Dalaran
		120146,				-- Ancient Portal: Dalaran
		3565,				-- Teleport: Darnassus
		11419,				-- Portal: Darnassus
		281404,				-- Teleport: Dazar'alor
		281402,				-- Portal: Dazar'alor
		50977,				-- Death Gate
		193753, 			-- Dreamwalk
		32271,				-- Teleport: Exodar
		32266,				-- Portal: Exodar
		3562,				-- Teleport: Ironforge
		11416,				-- Portal: Ironforge
		265225,				-- Mole Machine
		18960,				-- Teleport: Moonglade
		3567,				-- Teleport: Orgrimmar
		11417,				-- Portal: Orgrimmar
		147420,				-- One With Nature
		33690,				-- Teleport: Shattrath (Alliance)
		33691,				-- Portal: Shattrath (Alliance)
		35715,				-- Teleport: Shattrath (Horde)
		35717,				-- Portal: Shattrath (Horde)
		32272,				-- Teleport: Silvermoon
		32267,				-- Portal: Silvermoon
		49358,				-- Teleport: Stonard
		49361,				-- Portal: Stonard
		3561,				-- Teleport: Stormwind
		10059,				-- Portal: Stormwind
		49359,				-- Teleport: Theramore
		49360,				-- Portal: Theramore
		3566,				-- Teleport: Thunder Bluff
		11420,				-- Portal: Thunder Bluff
		88342,				-- Teleport: Tol Barad (Alliance)
		88344,				-- Teleport: Tol Barad (Horde)
		88345,				-- Portal: Tol Barad (Alliance)
		88346,				-- Portal: Tol Barad (Horde)
		3563,				-- Teleport: Undercity
		11418,				-- Portal: Undercity
		132621,				-- Teleport: Vale of Eternal Blossoms
		132627,				-- Teleport: Vale of Eternal Blossoms
		132620,				-- Portal: Vale of Eternal Blossoms
		132622,				-- Portal: Vale of Eternal Blossoms
		132624,				-- Portal: Vale of Eternal Blossoms
		132626,				-- Portal: Vale of Eternal Blossoms
	}
}

--[[CreateDestination(
	TeleporterHearthString,
	{
		CreateItem(93672),				-- Dark Portal
		CreateItem(54452),				-- Ethereal Portal
		CreateItem(6948 ),				-- Hearthstone
		CreateItem(28585),				-- Ruby Slippers
		CreateConsumable(37118),		-- Scroll of Recall
		CreateConsumable(44314),		-- Scroll of Recall II
		CreateConsumable(44315),		-- Scroll of Recall III
		CreateItem(64488),				-- The Innkeeper's Daughter	
		CreateItem(142298),				-- Astonishingly Scarlet Slippers
		CreateConsumable(142543),		-- Scroll of Town Portal
		CreateItem(142542),				-- Tome of Town Portal
		CreateItem(162973),				-- Greatfather Winter's Hearthstone
		CreateItem(163045)				-- Headless Horseman's Hearthstone
	})
	
CreateDestination(
	TeleporterRecallString,
	{
		CreateSpell(556)				-- Astral Recall
	})

CreateDestination(
	TeleporterFlightString,
	{ 
		CreateConditionalItem(141605, AllowWhistle) 	-- Flight Master's Whistle
	})
	

CreateDestination(
	LocZone("Azsuna", 630),
	{
		CreateConditionalItem(129276, AtZone(MapIDAzsuna)),	-- Beginner's Guide to Dimensional Rifting
		CreateConditionalConsumable(141016, AtContinent(ContinentIdBrokenIsles)),	-- Scroll of Town Portal: Faronaar
		CreateConditionalItem(140493, OnDayAtContinent(DayWednesday, ContinentIdBrokenIsles)),	-- Adept's Guide to Dimensional Rifting
	}, 630)

CreateDestination(
	LocArea("Bizmo's Brawlpub", 6618),
	{
		CreateItem(95051),				-- The Brassiest Knuckle
		CreateItem(118907),				-- Pit Fighter's Punching Ring
		CreateItem(144391),				-- Pugilist's Powerful Punching Ring
	})			
			
CreateDestination(			
	LocZone("Black Temple", 490),
	{			
		CreateItem(32757),				-- Blessed Medallion of Karabor
		CreateItem(151016), 			-- Fractured Necrolyte Skull
	})
				
CreateDestination(			
	LocZone("Blackrock Depths", 242),
	{			
		CreateItem(37863)				-- Direbrew's Remote
	})

CreateDestination(			
	LocZone("Blackrock Foundry", 596),
	{	
		CreateChallengeSpell(169771)	-- Teleport: Blackrock Foundry
	})

CreateDestination(			
	LocZone("Blade's Edge Mountains", 105),	
	{
		CreateItem(30544),				-- Ultrasafe Transporter - Toshley's Station
	})

CreateDestination(			
	LocArea("Bladespire Citadel", 6864),
	{
		CreateItem(118662), 			-- Bladespire Relic
	})

CreateDestination(			
	LocArea("Booty Bay", 35),	
	{
		CreateItem(50287),				-- Boots of the Bay
	})
	
CreateDestination(			
	LocZone("Boralus", 1161),
	{
		CreateSpell(281403),			-- Teleport: Boralus
		CreateSpell(281400),			-- Portal: Boralus
	})

CreateDestination(			
	LocZone("Brawl'gar Arena", 503),	
	{
		CreateItem(95050),				-- The Brassiest Knuckle
		CreateItem(118908),				-- Pit Fighter's Punching Ring
		CreateItem(144392),				-- Pugilist's Powerful Punching Ring
	}, 503)
	
CreateDestination(			
	LocZone("Broken Isles",	619),
	{
		CreateConsumable(132523), 		-- Reaves Battery (can't always teleport, don't currently check).	
		CreateItem(144341), 			-- Rechargeable Reaves Battery
	})

CreateDestination(			
	LocZone("Dalaran", 625) .. " (Legion)",	
	{
		CreateSpell(224871),		-- Portal: Dalaran - Broken Isles (UNTESTED)
		CreateSpell(224869),		-- Teleport: Dalaran - Broken Isles	(UNTESTED)
		CreateItem(138448),			-- Emblem of Margoss
		CreateItem(139599),			-- Empowered Ring of the Kirin Tor
		CreateItem(140192),			-- Dalaran Hearthstone
		CreateConditionalItem(43824, AtZone(MapIDDalaranLegion)),	-- The Schools of Arcane Magic - Mastery
	})

CreateDestination(			
	LocZone("Dalaran", 625) .. " (WotLK)",	
	{
		CreateSpell(53140),			-- Teleport: Dalaran
		CreateSpell(53142),			-- Portal: Dalaran
	-- ilvl 200 rings
		CreateItem(40586),			-- Band of the Kirin Tor
		CreateItem(44934),			-- Loop of the Kirin Tor
		CreateItem(44935),			-- Ring of the Kirin Tor
		CreateItem(40585),			-- Signet of the Kirin Tor
	-- ilvl 213 rings
		CreateItem(45688),			-- Inscribed Band of the Kirin Tor
		CreateItem(45689),			-- Inscribed Loop of the Kirin Tor
		CreateItem(45690),			-- Inscribed Ring of the Kirin Tor
		CreateItem(45691),			-- Inscribed Signet of the Kirin Tor
	-- ilvl 226 rings
		CreateItem(48954),			-- Etched Band of the Kirin Tor
		CreateItem(48955),			-- Etched Loop of the Kirin Tor
		CreateItem(48956),			-- Etched Ring of the Kirin Tor
		CreateItem(48957),			-- Etched Signet of the Kirin Tor
	-- ilvl 251 rings
		CreateItem(51560),			-- Runed Band of the Kirin Tor
		CreateItem(51558),			-- Runed Loop of the Kirin Tor
		CreateItem(51559),			-- Runed Ring of the Kirin Tor
		CreateItem(51557),			-- Runed Signet of the Kirin Tor

		CreateConditionalItem(43824, AtZone(MapIDDalaran)),	-- The Schools of Arcane Magic - Mastery
		CreateItem(52251),			-- Jaina's Locket
	})
	
CreateDestination(			
	LocArea("Dalaran Crater", 279),
	{
		CreateSpell(120145),		-- Ancient Teleport: Dalaran
		CreateSpell(120146),		-- Ancient Portal: Dalaran
	})

CreateDestination(			
	LocZone("Darnassus", 89),
	{
		CreateSpell(3565),			-- Teleport: Darnassus
		CreateSpell(11419),			-- Portal: Darnassus
	})
	
CreateDestination(			
	LocZone("Dazar'alor", 1163),
	{
		CreateSpell(281404),		-- Teleport: Dazar'alor
		CreateSpell(281402),		-- Portal: Dazar'alor
	})

CreateDestination(
	LocZone("Deepholm", 207),
	{
		CreateConsumable(58487),	-- Potion of Deepholm
	})

CreateDestination(
	LocZone("Draenor", 572),
	{
		CreateConditionalConsumable(117389, AtContinent(ContinentIdDraenor)), -- Draenor Archaeologist's Lodestone
		CreateItem(112059),			-- Wormhole Centrifuge
		CreateConditionalItem(129929, AtContinent(ContinentIdOutland)),	-- Ever-Shifting Mirror
	})
	
CreateDestination(
	"Draenor Dungeons",					-- No localization
	{
		CreateChallengeSpell(159897),	-- Teleport: Auchindoun
		CreateChallengeSpell(159895),	-- Teleport: Bloodmaul Slag Mines
		CreateChallengeSpell(159901),	-- Teleport: Overgrown Outpost
		CreateChallengeSpell(159900),	-- Teleport: Grimrail Depot
		CreateChallengeSpell(159896),	-- Teleport: Iron Docks
		CreateChallengeSpell(159899),	-- Teleport: Shadowmoon Burial Grounds
		CreateChallengeSpell(159898),	-- Teleport: Skyreach
		CreateChallengeSpell(159902),	-- Teleport: Upper Blackrock Spire
	})

CreateDestination(
	LocZone("Acherus: The Ebon Hold", 647),
	{
		CreateSpell(50977),			-- Death Gate
	})

CreateDestination(
	LocZone("Emerald Dreamway", 715),
	{
		CreateSpell(193753), 		-- Dreamwalk
	})

CreateDestination(
	LocZone("The Exodar", 103),
	{
		CreateSpell(32271),			-- Teleport: Exodar
		CreateSpell(32266),			-- Portal: Exodar
	})

CreateDestination(
	"Fishing Pool",					-- No localization.
	{	
		CreateConditionalSpell(201891, AtContinent(ContinentIdBrokenIsles)),		-- Undercurrent
		CreateConditionalConsumable(162515, InBFAZone),	-- Midnight Salmon
	})
	
CreateDestination(
	GARRISON_LOCATION_TOOLTIP,
	{
		CreateItem(110560),				-- Garrison Hearthstone
	})

	
CreateDestination(
	LocZone("Hall of the Guardian", 734),
	{
		CreateChallengeSpell(193759), 	-- Teleport: Hall of the Guardian
	})
--	
CreateDestination(
	LocZone("Highmountain", 869),
	{
		CreateConditionalConsumable(141017, AtContinent(ContinentIdBrokenIsles)),				-- Scroll of Town Portal: Lian'tril
		CreateConditionalItem(140493, OnDayAtContinent(DayThursday, ContinentIdBrokenIsles)),	-- Adept's Guide to Dimensional Rifting
	})

CreateDestination(
	LocZone("Icecrown", 118),
	{
		CreateItem(46874),				-- Argent Crusader's Tabard
	})

CreateDestination(
	LocZone("Ironforge", 87),
	{
		CreateSpell(3562),				-- Teleport: Ironforge
		CreateSpell(11416)				-- Portal: Ironforge
	})

CreateDestination(
	LocZone("Isle of Thunder", 504),
	{
		CreateConditionalItem(95567, AtZone(MapIDIsleOfThunder )),	-- Kirin Tor Beacon
		CreateConditionalItem(95568, AtZone(MapIDIsleOfThunder )),	-- Sunreaver Beacon
	})

CreateDestination(
	LocArea("Karabor", 6930),
	{
		CreateItem(118663),				-- Relic of Karabor
	})

CreateDestination(
	LocZone("Karazhan", 794),
	{
		CreateItem(22589),		-- Atiesh, Greatstaff of the Guardian
		CreateItem(22630),		-- Atiesh, Greatstaff of the Guardian
		CreateItem(22631),		-- Atiesh, Greatstaff of the Guardian
		CreateItem(22632),		-- Atiesh, Greatstaff of the Guardian
		CreateItem(142469), 	-- Violet Seal of the Grand Magus
	})

CreateDestination(
	LocZone("Kun-Lai Summit", 379),
	{
		CreateConditionalSpell(126892, function() return not HaveUpgradedZen() end ),	-- Zen Pilgrimage
	})
	
CreateDestination(
	"Mole Machine",					-- No localization.
	{
		CreateSpell(265225),		-- Mole Machine
	})

CreateDestination(
	LocZone("Moonglade", 80),
	{
		CreateSpell(18960),		-- Teleport: Moonglade
		CreateItem(21711),		-- Lunar Festival Invitation
	})

CreateDestination(
	LocZone("Netherstorm", 109),
	{
		CreateItem(30542),		-- Dimensional Ripper - Area 52
	})

CreateDestination(
	LocZone("Northrend", 113),
	{
		CreateItem(48933),		-- Wormhole Generator: Northrend
	})

CreateDestination(
	LocZone("Orgrimmar", 85),
	{
		CreateSpell(3567),		-- Teleport: Orgrimmar
		CreateSpell(11417),		-- Portal: Orgrimmar
		CreateItem(63207),		-- Wrap of Unity
		CreateItem(63353),		-- Shroud of Cooperation
		CreateItem(65274),		-- Cloak of Coordination
	})

CreateDestination(
	LocZone("Outland", 101),
	{
		CreateConditionalItem(129929, AtContinent(ContinentIdDraenor) ),	-- Ever-Shifting Mirror
	})

CreateDestination(
	LocZone("Pandaria", 424),
	{
		CreateConditionalConsumable(87548, AtContinent(ContinentIdPandaria)), 	-- Lorewalker's Lodestone
		CreateItem(87215),														-- Wormhole Generator: Pandaria
	})

CreateDestination(
	"Pandaria Dungeons",		-- No localization.
	{
		CreateChallengeSpell(131225),	-- Path of the Setting Sun	
		CreateChallengeSpell(131222),	-- Path of the Mogu King
		CreateChallengeSpell(131231),	-- Path of the Scarlet Blade	
		CreateChallengeSpell(131229),	-- Path of the Scarlet Mitre	
		CreateChallengeSpell(131232),	-- Path of the Necromancer
		CreateChallengeSpell(131206),	-- Path of the Shado-Pan
		CreateChallengeSpell(131228),	-- Path of the Black Ox
		CreateChallengeSpell(131205),	-- Path of the Stout Brew
		CreateChallengeSpell(131204),	-- Path of the Jade Serpent
	})

CreateDestination(
	"Random",		-- No localization.
	{
		CreateSpell(147420),								-- One With Nature
		CreateItem(64457), 									-- The Last Relic of Argus
		CreateConditionalItem(136849, IsClass("DRUID")),	-- Nature's Beacon
	})

CreateDestination(
	LocArea("Ravenholdt", 0),
	{
		CreateItem(139590),		-- Scroll of Teleport: Ravenholdt
	})

CreateDestination(
	LocZone("Shattrath City", 111),
	{
		CreateSpell(33690),		-- Teleport: Shattrath (Alliance)
		CreateSpell(33691),		-- Portal: Shattrath (Alliance)
		CreateSpell(35715),		-- Teleport: Shattrath (Horde)
		CreateSpell(35717),		-- Portal: Shattrath (Horde)
	})

CreateDestination(
	LocArea("Shipyard", 6668),
	{
		CreateItem(128353),		-- Admiral's Compass
	})

CreateDestination(
	LocZone("Silvermoon City", 110),
	{
		CreateSpell(32272),		-- Teleport: Silvermoon
		CreateSpell(32267),		-- Portal: Silvermoon
	})

CreateDestination(
	LocArea("Stonard", 75),
	{
		CreateSpell(49358),		-- Teleport: Stonard
		CreateSpell(49361),		-- Portal: Stonard
	})

CreateDestination(
	LocZone("Stormheim", 634),
	{
		CreateConditionalItem(140493, OnDayAtContinent(DayFriday, ContinentIdBrokenIsles)),	-- Adept's Guide to Dimensional Rifting
	})

CreateDestination(
	LocZone("Stormwind City", 84),
	{
		CreateSpell(3561),		-- Teleport: Stormwind
		CreateSpell(10059),		-- Portal: Stormwind
		CreateItem(63206),		-- Wrap of Unity
		CreateItem(63352),		-- Shroud of Cooperation
		CreateItem(65360),		-- Cloak of Coordination
	})

CreateDestination(
	LocZone("Suramar", 680),
	{
		CreateItem(140324),																		-- Mobile Telemancy Beacon
		CreateConditionalConsumable(141014, AtContinent(ContinentIdBrokenIsles)),				-- Scroll of Town Portal: Sashj'tar
		CreateConditionalItem(140493, OnDayAtContinent(DayTuesday, ContinentIdBrokenIsles)),	-- Adept's Guide to Dimensional Rifting
	})
		
CreateDestination(
	LocZone("Tanaan Jungle", 534),
	{
		CreateConditionalItem(128502, AtZone(MapIDTanaanJungle)),	-- Hunter's Seeking Crystal
		CreateConditionalItem(128503, AtZone(MapIDTanaanJungle)),	-- Master Hunter's Seeking Crystal
	})

CreateDestination(
	LocZone("Tanaris", 71),
	{
		CreateItem(18986),		-- Ultrasafe Transporter - Gadgetzan
	})

CreateDestination(
	LocArea("Temple of Five Dawns", 5820),
	{
		CreateConditionalSpell(126892, function() return HaveUpgradedZen() end ),	-- Zen Pilgrimage
	})

CreateDestination(
	LocArea("Theramore Isle", 513),
	{
		CreateSpell(49359),		-- Teleport: Theramore
		CreateSpell(49360),		-- Portal: Theramore
	})

CreateDestination(
	LocZone("Timeless Isle", 554),
	{
		CreateItem(103678),		-- Time-Lost Artifact
	})

CreateDestination(
	LocZone("Thunder Bluff", 88),
	{
		CreateSpell(3566),		-- Teleport: Thunder Bluff
		CreateSpell(11420),		-- Portal: Thunder Bluff
	})

CreateDestination(
	LocZone("Tol Barad", 773),
	{
		CreateItem(63378),		-- Hellscream's Reach Tabard
		CreateItem(63379),		-- Baradin's Wardens Tabard
		CreateSpell(88342),		-- Teleport: Tol Barad (Alliance)
		CreateSpell(88344),		-- Teleport: Tol Barad (Horde)
		CreateSpell(88345),		-- Portal: Tol Barad (Alliance)
		CreateSpell(88346),		-- Portal: Tol Barad (Horde)
	})

CreateDestination(
	LocZone("Undercity", 90),
	{
		CreateSpell(3563),		-- Teleport: Undercity
		CreateSpell(11418),		-- Portal: Undercity
	})

CreateDestination(
	LocZone("Val'sharah", 641),
	{
		CreateConditionalConsumable(141013, AtContinent(ContinentIdBrokenIsles)),			-- Scroll of Town Portal: Shala'nir
		CreateConditionalConsumable(141015, AtContinent(ContinentIdBrokenIsles)),			-- Scroll of Town Portal: Kal'delar	
		CreateConditionalItem(140493, OnDayAtContinent(DayMonday, ContinentIdBrokenIsles)),	-- Adept's Guide to Dimensional Rifting
	})

-- I don't know why there are so many of these, not sure which is right but it's now safe to
-- list them all.
CreateDestination(
	LocZone("Vale of Eternal Blossoms", 390),
	{
		CreateSpell(132621),	-- Teleport: Vale of Eternal Blossoms
		CreateSpell(132627),	-- Teleport: Vale of Eternal Blossoms
		CreateSpell(132620),	-- Portal: Vale of Eternal Blossoms
		CreateSpell(132622),	-- Portal: Vale of Eternal Blossoms
		CreateSpell(132624),	-- Portal: Vale of Eternal Blossoms
		CreateSpell(132626),	-- Portal: Vale of Eternal Blossoms
	})

CreateDestination(
	LocZone("Winterspring", 83),
	{
		CreateItem(18984),		-- Dimensional Ripper - Everlook
	})

CreateDestination(
	LocZone("Zuldazar", 862),
	{
		CreateConsumable(157542),	-- Portal Scroll of Specificity
		CreateConsumable(160218),	-- Portal Scroll of Specificity
	})
--]]