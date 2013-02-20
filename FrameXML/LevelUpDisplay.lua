LEVEL_UP_TYPE_CHARACTER = "character";	--Name used in globalstring LEVEL_UP
LEVEL_UP_TYPE_GUILD = "guild";	--Name used in globalstring GUILD_LEVEL_UP
LEVEL_UP_TYPE_PET = "pet" -- Name used in globalstring PET_LEVEL_UP
LEVEL_UP_TYPE_SCENARIO = "scenario";
TOAST_QUEST_BOSS_EMOTE = "questbossemote";
TOAST_PET_BATTLE_WINNER = "petbattlewinner";
TOAST_PET_BATTLE_CAPTURE = "petbattlecapturetoast";
TOAST_PET_BATTLE_LEVELUP = "petbattleleveluptoast";
TOAST_PET_BATTLE_LOOT = "petbattleloot";
TOAST_CHALLENGE_MODE_RECORD = "challengemode";

LEVEL_UP_EVENTS = {
--  Level  = {unlock}
	[10] = {"SpecializationUnlocked", "BGsUnlocked"},
	[15] = {"TalentsUnlocked","LFDUnlocked"},
	[25] = {"Glyphs"},
	[30] = {"DualSpec"},
	[50] = {"GlyphSlots"},
	[70] = {"HeroicBurningCrusade"},
	[75] = {"GlyphSlots"},
	[80] = {"HeroicWrathOfTheLichKing"},
	[85] = {"HeroicCataclysm"},
	[90] = {"HeroicMistsOfPandaria"},
}

SUBICON_TEXCOOR_BOOK 	= {0.64257813, 0.72070313, 0.03710938, 0.11132813};
SUBICON_TEXCOOR_LOCK	= {0.64257813, 0.70117188, 0.11523438, 0.18359375};
SUBICON_TEXCOOR_ARROW 	= {0.72460938, 0.78320313, 0.03710938, 0.10351563};

local levelUpTexCoords = {
	[LEVEL_UP_TYPE_CHARACTER] = {
		dot = { 0.64257813, 0.68359375, 0.18750000, 0.23046875 },
		goldBG = { 0.56054688, 0.99609375, 0.24218750, 0.46679688 },
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		gLineDelay = 1.5,
	},
	[LEVEL_UP_TYPE_GUILD] = {
		dot = { 0.64257813, 0.68359375, 0.77734375, 0.8203125 },
		goldBG = { 0.56054688, 0.99609375, 0.486328125, 0.7109375 },
		gLine = { 0.00195313, 0.81835938, 0.96484375, 0.97851563 },
		textTint = {0.11765, 1, 0},
		gLineDelay = 1.5,
	},
	[LEVEL_UP_TYPE_PET] = {
		dot = { 0.64257813, 0.68359375, 0.18750000, 0.23046875 },
		goldBG = { 0.56054688, 0.99609375, 0.24218750, 0.46679688 },
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		tint = {1, 0.5, 0.25},
		textTint = {1, 0.7, 0.25},
		gLineDelay = 1.5,
	},
	[TOAST_PET_BATTLE_WINNER] = {
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		tint = {1, 0.5, 0.25},
		textTint = {1, 0.7, 0.25},
		gLineDelay = 1.5,
	},
	[TOAST_PET_BATTLE_CAPTURE] = {
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		tint = {1, 0.5, 0.25},
		textTint = {1, 0.7, 0.25},
		gLineDelay = 1.5,
	},
	[TOAST_PET_BATTLE_LEVELUP] = {
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		tint = {1, 0.5, 0.25},
		textTint = {1, 0.7, 0.25},
		gLineDelay = 1.5,
	},
	[TOAST_PET_BATTLE_LOOT] = {
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		tint = {1, 0.5, 0.25},
		textTint = {1, 0.7, 0.25},
		gLineDelay = 1.5,
	},
	[LEVEL_UP_TYPE_SCENARIO] = {
		gLine = { 0.00195313, 0.81835938, 0.00195313, 0.01562500 },
		tint = {1, 0.996, 0.745},
		gLineDelay = 0,
	},
	[TOAST_QUEST_BOSS_EMOTE] = {
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		tint = {1, 0.996, 0.745},
		textTint = {1, 0.7, 0.25},
		gLineDelay = 0,
	},
	[TOAST_CHALLENGE_MODE_RECORD] = {
		gLine = { 0.00195313, 0.81835938, 0.00195313, 0.01562500 },
		tint = {0.777, 0.698, 0.451},
		gLineDelay = 0,
	},	
}

LEVEL_UP_TYPES = {
	["TalentPoint"] 			=	{	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_ARROW,
										text=LEVEL_UP_TALENT_MAIN,
										subText=LEVEL_UP_TALENT_SUB,
										link=LEVEL_UP_TALENTPOINT_LINK;
									},
	
	["PetTalentPoint"] 			=	{	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_ARROW,
										text=PET_LEVEL_UP_TALENT_MAIN,
										subText=PET_LEVEL_UP_TALENT_SUB,
										link=PET_LEVEL_UP_TALENTPOINT_LINK;
									},
									
	["SpecializationUnlocked"] 	= 	{	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=SPECIALIZATION,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_SPECIALIZATION_LINK
									},
									
	["TalentsUnlocked"] 		= 	{	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=TALENT_POINTS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_TALENTS_LINK
									},
									
	["BGsUnlocked"] 			= 	{	icon="Interface\\Icons\\Ability_DualWield",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=BATTLEFIELDS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_BG_LINK
									},

	["LFDUnlocked"] 			= 	{	icon="Interface\\Icons\\LevelUpIcon-LFD",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=LOOKING_FOR_DUNGEON,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_LFD_LINK
									},

	["Glyphs"]					=	{	icon="Interface\\Icons\\Inv_inscription_tradeskill01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GLYPHS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_GLYPHSLOT_LINK
									},

	["GlyphSlots"]				= 	{	icon="Interface\\Icons\\Inv_inscription_tradeskill01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GLYPH_SLOTS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_GLYPHSLOT_LINK
									},

	["DualSpec"] 				=	{	icon="Interface\\Icons\\INV_Misc_Coin_01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=LEVEL_UP_DUALSPEC,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_DUAL_SPEC_LINK
									},

	["HeroicBurningCrusade"]	=	{	entryType = "heroicdungeon",
										tier = 2,
										icon="Interface\\Icons\\ExpansionIcon_BurningCrusade",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=EXPANSION_NAME1,
										subText=LEVEL_UP_HEROIC,
									},
									
	["HeroicWrathOfTheLichKing"]= 	{	entryType = "heroicdungeon",
										tier = 3,
										icon="Interface\\Icons\\ExpansionIcon_WrathoftheLichKing",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=EXPANSION_NAME2,
										subText=LEVEL_UP_HEROIC,
									},
									
	["HeroicCataclysm"]			=	{	entryType = "heroicdungeon",
										tier = 4,
										icon="Interface\\Icons\\ExpansionIcon_Cataclysm",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=EXPANSION_NAME3,
										subText=LEVEL_UP_HEROIC,
									},
									
	["HeroicMistsOfPandaria"]	= 	{ 	entryType = "heroicdungeon",
										tier = 5,
										icon="Interface\\Icons\\ExpansionIcon_MistsofPandaria",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=EXPANSION_NAME4,
										subText=LEVEL_UP_HEROIC
									},
									
------ HACKS BELOW		
 	["Teleports"] 			= {	spellID=109424	},
	["PortalsHorde"]		= {	spellID=109400	},
	["PortalsAlliance"]		= {	spellID=109401	},
									
 	["LockMount1"] 			= {	spellID=5784	},
 	["LockMount2"] 			= {	spellID=23161	},
 	["PaliMount1"] 			= {	spellID=34769	},
 	["PaliMount2"] 			= {	spellID=34767	},
 	["PaliMountTauren1"] 	= {	spellID=69820	},
 	["PaliMountTauren2"] 	= {	spellID=69826	},
 	["PaliMountDraenei1"] 	= {	spellID=73629	},
 	["PaliMountDraenei2"] 	= {	spellID=73630	},
 	
	["Plate"]	 			= {	spellID=750, feature=true},
	["Mail"] 				= {	spellID=8737, feature=true	},
	
	["TrackBeast"] 			= {	spellID=1494  },
	["TrackHumanoid"] 		= {	spellID=19883  },
	["TrackUndead"] 		= {	spellID=19884  },
	["TrackHidden"] 		= {	spellID=19885  },
	["TrackElemental"] 		= {	spellID=19880  },
	["TrackDemons"] 		= {	spellID=19878 },
	["TrackGiants"] 		= {	spellID=19882  },
	["TrackDragonkin"] 		= {	spellID=19879  },
------ END HACKS
}


LEVEL_UP_CLASS_HACKS = {
	
	["MAGEHorde"] 		= {
							--  Level  = {unlock}
								[24] = {"Teleports"},
								[42] = {"PortalsHorde"},
							},
	["MAGEAlliance"]	= {
							--  Level  = {unlock}
								[24] = {"Teleports"},
								[42] = {"PortalsAlliance"},
							},
	["WARLOCK"] 		= {
							--  Level  = {unlock}
								[20] = {"LockMount1"},
								[40] = {"LockMount2"},
							},
	["SHAMAN"] 		= {
							--  Level  = {unlock}
								[40] = {"Mail"},
							},
	["HUNTER"] 		= {
							--  Level  = {unlock}
								[4] = {"TrackBeast"},
								[12] = {"TrackHumanoid"},
								[18] = {"TrackUndead"},
								[26] = {"TrackHidden"},
								[34] = {"TrackElemental"},
								[36] = {"TrackDemons"},
								[40] = {"Mail"},
								[46] = {"TrackGiants"},
								[52] = {"TrackDragonkin"},
							},
	["WARRIOR"] 		= {
							--  Level  = {unlock}
								[40] = {"Plate"},
							},
	["PALADIN"] 		= {
							--  Level  = {unlock}
								[20] = {"PaliMount1"},
								[40] = {"PaliMount2", "Plate"},
							},
	["PALADINTauren"]	= {
							--  Level  = {unlock}
								[20] = {"PaliMountTauren1"},
								[40] = {"PaliMountTauren2", "Plate"},
							},	
	["PALADINDraenei"]	= {
							--  Level  = {unlock}
								[20] = {"PaliMountDraenei1"},
								[40] = {"PaliMountDraenei2", "Plate"},
							},	
}

LEVEL_UP_TRAP_LEVELS = {427, 77, 135}

function LevelUpDisplay_OnLoad(self)
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("UNIT_GUILD_LEVEL");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("SCENARIO_UPDATE");
	self:RegisterEvent("PET_BATTLE_FINAL_ROUND"); -- display winner, start listening for additional results
	self:RegisterEvent("PET_BATTLE_CLOSE");        -- stop listening for additional results
	self:RegisterEvent("QUEST_BOSS_EMOTE");
	self:RegisterEvent("CHALLENGE_MODE_NEW_RECORD");
	self:RegisterEvent("PET_JOURNAL_TRAP_LEVEL_SET");
	self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED");
	self:RegisterEvent("PET_BATTLE_CAPTURED");
	self:RegisterEvent("PET_BATTLE_LOOT_RECEIVED");
	self:RegisterEvent("LOADING_SCREEN_ENABLED");
	self:RegisterEvent("LOADING_SCREEN_DISABLED");
	self.currSpell = 0;
end



function LevelUpDisplay_OnEvent(self, event, ...)
	local arg1 = ...;
	if event == "LOADING_SCREEN_ENABLED" then
		LevelUpDisplay_StopAllAnims(self);
		self:Hide();	--We'll restart this toast on PLAYER_ENTERING_WORLD
		self.currSpell = 0;
	elseif event == "LOADING_SCREEN_DISABLED" then
		if ( self.type ) then
			LevelUpDisplay_Start(self, self.unlockList);
		end
	elseif event ==  "PLAYER_LEVEL_UP" then
		local level = ...
		self.level = level;
		self.type = LEVEL_UP_TYPE_CHARACTER;
		LevelUpDisplay_Show(self);
		LevelUpDisplaySide:Hide();
	elseif event == "UNIT_GUILD_LEVEL" then
		local unit, level = ...;
		if ( unit == "player" ) then
			self.level = level;
			self.type = LEVEL_UP_TYPE_GUILD;
			LevelUpDisplay_Show(self);
			LevelUpDisplaySide:Hide();
		end
	elseif event == "UNIT_LEVEL" and arg1 == "pet" then
		if (UnitName("pet") ~= UNKNOWNOBJECT) then
			self.level = UnitLevel("pet");
			self.type = LEVEL_UP_TYPE_PET;
			LevelUpDisplay_Show(self);
			LevelUpDisplaySide:Hide();
		end
	elseif ( event == "SCENARIO_UPDATE" ) then
		if ( arg1 and not C_Scenario.IsChallengeMode() ) then
			self.type = LEVEL_UP_TYPE_SCENARIO;
			LevelUpDisplay_Show(self);
		end
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
		LevelUpDisplay_Show(self);
	elseif ( event == "PET_BATTLE_FINAL_ROUND" ) then
		self.type = TOAST_PET_BATTLE_WINNER;
		self.winner = arg1;
		LevelUpDisplay_Show(self);
	elseif ( event == "PET_JOURNAL_TRAP_LEVEL_SET" ) then
		local trapLevel = ...;
		if (trapLevel >= 1 and trapLevel <= #LEVEL_UP_TRAP_LEVELS) then
			LevelUpDisplay_AddBattlePetTrapUpgradeEvent(self, trapLevel);
		end
	elseif ( event == "PET_BATTLE_LEVEL_CHANGED" ) then
		local activePlayer, activePetSlot, newLevel = ...;
		if (activePlayer == LE_BATTLE_PET_ALLY) then
			LevelUpDisplay_AddBattlePetLevelUpEvent(self, activePlayer, activePetSlot, newLevel);
		end
	elseif ( event == "PET_BATTLE_CAPTURED" ) then
		local fromPlayer, activePetSlot = ...;
		if (fromPlayer == LE_BATTLE_PET_ENEMY) then
			LevelUpDisplay_AddBattlePetCaptureEvent(self, fromPlayer, activePetSlot);
		end
	elseif ( event == "PET_BATTLE_LOOT_RECEIVED" ) then
		local typeIdentifier, itemLink, quantity = ...;
		LevelUpDisplay_AddBattlePetLootReward(self, typeIdentifier, itemLink, quantity);
	elseif ( event == "QUEST_BOSS_EMOTE" ) then
		local str, name, displayTime, warningSound = ...;
		self.type = TOAST_QUEST_BOSS_EMOTE;
		self.bossText = format(str, name, name);
		self.time = displayTime;
		self.sound = warningSound;
		LevelUpDisplay_Show(self);
	elseif ( event == "CHALLENGE_MODE_NEW_RECORD" ) then
		local mapID, recordTime, medal = ...;
		self.type = TOAST_CHALLENGE_MODE_RECORD;
		self.mapID = mapID;
		self.recordTime = recordTime;
		self.medal = medal;
		LevelUpDisplay_Show(self);
		PlaySoundKitID(33338);
	end
end

function LevelUpDisplay_StopAllAnims(self)
	self.fastHideAnim:Stop();
	self.hideAnim:Stop();
	self.spellFrame.showAnim:Stop();
	self.scenarioFrame.newStage:Stop();
	self.challengeModeFrame.challengeComplete:Stop();
	self.levelFrame.levelUp:Stop();
	self.levelFrame.fastReveal:Stop();
end

function LevelUpDisplay_BuildCharacterList(self)
	local name, icon, link = "","",nil;
	self.unlockList = {};

	if LEVEL_UP_EVENTS[self.level] then
		for _, unlockType in pairs(LEVEL_UP_EVENTS[self.level]) do
			self.unlockList[#self.unlockList +1] = LEVEL_UP_TYPES[unlockType];
		end
	end
	
	local spells = {GetCurrentLevelSpells(self.level)};
	for _,spell in pairs(spells) do		
		name, _, icon = GetSpellInfo(spell);
		self.unlockList[#self.unlockList +1] = { entryType = "spell", text = name, subText = LEVEL_UP_ABILITY, icon = icon, subIcon = SUBICON_TEXCOOR_BOOK,
																link=LEVEL_UP_ABILITY2.." "..GetSpellLink(spell)
															};
	end	
	
	local GUILD_EVENT_TEXTURE_PATH = "Interface\\LFGFrame\\LFGIcon-";
	local dungeons = {GetLevelUpInstances(self.level, false)};
	for _,dungeon in pairs(dungeons) do
		name, icon, link = GetDungeonInfo(dungeon);
		if link then -- link can come back as nil if there's no Dungeon Journal entry
			self.unlockList[#self.unlockList +1] = { entryType = "dungeon", text = name, subText = LEVEL_UP_DUNGEON, icon = GUILD_EVENT_TEXTURE_PATH..icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_DUNGEON2.." "..link
																	};
		else
			self.unlockList[#self.unlockList +1] = { entryType = "dungeon", text = name, subText = LEVEL_UP_DUNGEON, icon = GUILD_EVENT_TEXTURE_PATH..icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_DUNGEON2.." "..name
																	};
		end
	end
	
	local raids = {GetLevelUpInstances(self.level, true)};
	for _,raid in pairs(raids) do
		name, icon, link = GetDungeonInfo(raid);
		if link then -- link can come back as nil if there's no Dungeon Journal entry
			self.unlockList[#self.unlockList +1] = { entryType = "dungeon", text = name, subText = LEVEL_UP_RAID, icon = GUILD_EVENT_TEXTURE_PATH..icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_RAID2.." "..link
																	};
		else
			self.unlockList[#self.unlockList +1] = { entryType = "dungeon", text = name, subText = LEVEL_UP_RAID, icon = GUILD_EVENT_TEXTURE_PATH..icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_RAID2.." "..name
																	};
		end
	end


	-- This loop is LEVEL_UP_CLASS_HACKS
	local race, raceFile = UnitRace("player");
	local _, class = UnitClass("player");
	local factionName = UnitFactionGroup("player");
	local hackTable = LEVEL_UP_CLASS_HACKS[class..raceFile] or LEVEL_UP_CLASS_HACKS[class..factionName] or LEVEL_UP_CLASS_HACKS[class];
	if  hackTable and hackTable[self.level] then
		hackTable = hackTable[self.level];
		for _,spelltype in pairs(hackTable) do
			if LEVEL_UP_TYPES[spelltype] and LEVEL_UP_TYPES[spelltype].spellID then 
				if LEVEL_UP_TYPES[spelltype].feature then
					name, _, icon = GetSpellInfo(LEVEL_UP_TYPES[spelltype].spellID);
					self.unlockList[#self.unlockList +1] = { text = name, subText = LEVEL_UP_FEATURE, icon = icon, subIcon = SUBICON_TEXCOOR_LOCK,
																			link=LEVEL_UP_FEATURE2.." "..GetSpellLink(LEVEL_UP_TYPES[spelltype].spellID)
																		};
				else
					name, _, icon = GetSpellInfo(LEVEL_UP_TYPES[spelltype].spellID);
					self.unlockList[#self.unlockList +1] = { text = name, subText = LEVEL_UP_ABILITY, icon = icon, subIcon = SUBICON_TEXCOOR_BOOK,
																			link=LEVEL_UP_ABILITY2.." "..GetSpellLink(LEVEL_UP_TYPES[spelltype].spellID)
																		};
				end
			end
		end	
	end
	
	
	local features = {GetCurrentLevelFeatures(self.level)};
	for _,feature in pairs(features) do		
		name, _, icon = GetSpellInfo(feature);
		self.unlockList[#self.unlockList +1] = { entryType = "spell", text = name, subText = LEVEL_UP_FEATURE, icon = icon, subIcon = SUBICON_TEXCOOR_LOCK,
																link=LEVEL_UP_FEATURE2.." "..GetSpellLink(feature)
															};
	end	
	
	self.currSpell = 1;
end

function LevelUpDisplay_BuildPetList(self)
	local name, icon = "","";
	self.unlockList = {};

	-- TODO: Pet Spells
	
	self.currSpell = 1;
end

function LevelUpDisplay_BuildBattlePetList(self)
	self.unlockList = {};
	
	-- TODO: Battle Pet spell slots & spells
	
	self.currSpell = 1;
end

function LevelUpDisplay_BuildEmptyList(self)
	self.unlockList = {};
	self.currSpell = 1;
end

function LevelUpDisplay_BuildGuildList(self)
	self.unlockList = {};
	
	for i=1, GetNumGuildPerks() do
		local name, spellID, iconTexture, level = GetGuildPerkInfo(i);
		if ( level == self.level ) then
			tinsert(self.unlockList, { text = name, subText = GUILD_LEVEL_UP_PERK, icon = iconTexture, subIcon = SUBICON_TEXCOOR_LOCK,
												link = GUILD_LEVEL_UP_PERK2.." "..GetSpellLink(spellID)
											});
		end
	end
	
	self.currSpell = 1;
end

function LevelUpDisplay_BuildPetBattleWinnerList(self)
	self.unlockList = {};
	self.winnerString = PET_BATTLE_RESULT_LOSE;
	if(C_PetBattles.IsWildBattle()) then
		self.winnerSoundKitID = 34090; --UI_PetBattle_PVE_Defeat
	elseif(C_PetBattles.IsPlayerNPC(LE_BATTLE_PET_ENEMY)) then
		self.winnerSoundKitID = 34094; --UI_PetBattle_Special_Defeat
	else
		self.winnerSoundKitID = 34092; --UI_PetBattle_PVP_Defeat
	end

	if ( self.winner == LE_BATTLE_PET_ALLY ) then
		self.winnerString = PET_BATTLE_RESULT_WIN;
		if(C_PetBattles.IsWildBattle()) then
			self.winnerSoundKitID = 34089; --UI_PetBattle_PVE_Victory
		elseif(C_PetBattles.IsPlayerNPC(LE_BATTLE_PET_ENEMY)) then
			self.winnerSoundKitID = 34093; --UI_PetBattle_Special_Victory
		else
			self.winnerSoundKitID = 34091; --UI_PetBattle_PVP_Victory
		end
	end;
	self.currSpell = 1;
end

function LevelUpDisplay_AddBattlePetTrapUpgradeEvent(self, trapLevel)
	if ( trapLevel < 1 or trapLevel > #LEVEL_UP_TRAP_LEVELS ) then
		return;
	end

	local name, icon, typeEnum = C_PetJournal.GetPetAbilityInfo(LEVEL_UP_TRAP_LEVELS[trapLevel]);

	if (name and self.unlockList) then
		table.insert(self.unlockList,
			{
			entryType = "spell",
			text = name,
			subText = PET_BATTLE_TRAP_UPGRADE,
			icon = icon,
			subIcon = nil
			});
	end
end

function LevelUpDisplay_AddBattlePetLevelUpEvent(self, activePlayer, activePetSlot, newLevel)
	if (activePlayer ~= LE_BATTLE_PET_ALLY) then
		return;
	end

	if (self.currSpell == 0) then
		self.type = TOAST_PET_BATTLE_LEVELUP;
		LevelUpDisplay_Show(self);
	end

	local petID = C_PetJournal.GetPetLoadOutInfo(activePetSlot);
	if (petID == nil) then
		return;
	end
	
	local speciesID, customName, petLevel, xp, maxXp, displayID, isFavorite, name, petIcon = C_PetJournal.GetPetInfoByPetID(petID);
	if (not speciesID) then
		return;
	end
	
	table.insert(self.unlockList, 
		{ 
		entryType = "petlevelup", 
		text = format(PET_LEVEL_UP_REACHED, customName or name), 
		subText = format(LEVEL_GAINED,newLevel), 
		icon = petIcon, 
		subIcon = SUBICON_TEXCOOR_ARROW,
		});
	local abilityID = PetBattleFrame_GetAbilityAtLevel(speciesID, newLevel);
	if (abilityID) then
		local abName, abIcon = C_PetJournal.GetPetAbilityInfo(abilityID);
		table.insert(self.unlockList,
			{
			entryType = "spell",
			text = abName,
			subText = LEVEL_UP_ABILITY,
			icon = abIcon,
			subIcon = nil,
			});
	end
end

function LevelUpDisplay_CreateOrAppendItem(self, createType, info)
	local unlockList = nil;
	if ( self.hideAnim:IsPlaying() or self.fastHideAnim:IsPlaying() ) then --If we're currently animating out
		self.queuedType = self.queuedType or createType;
		self.queuedItems = self.queuedItems or {};
		unlockList = self.queuedItems;
	elseif ( self.currSpell == 0 ) then --If we're currently hidden
		self.type = createType;
		LevelUpDisplay_Show(self);
		unlockList = self.unlockList;
	else --We're in the middle of showing something, just append it.
		unlockList = self.unlockList;
	end
	if ( unlockList ) then
		table.insert(unlockList, info)
	else
		GMError("No unlock list found.");
	end
end

function LevelUpDisplay_AddBattlePetCaptureEvent(self, fromPlayer, activePetSlot)
	if (fromPlayer ~= LE_BATTLE_PET_ENEMY) then
		return;
	end
	
	local petName = C_PetBattles.GetName(fromPlayer, activePetSlot);
	local petIcon = C_PetBattles.GetIcon(fromPlayer, activePetSlot);
	local quality = C_PetBattles.GetBreedQuality(fromPlayer, activePetSlot);
	
	local info = { 
		entryType = "petcapture", 
		text = BATTLE_PET_CAPTURED, 
		subText = petName, 
		icon = petIcon,
		quality = quality
	};
	LevelUpDisplay_CreateOrAppendItem(self, TOAST_PET_BATTLE_CAPTURE, info);
end

function LevelUpDisplay_AddBattlePetLootReward(self, typeIdentifier, itemLink, quantity)
	local info = nil;
	if ( typeIdentifier == "item" ) then
		local name, link, rarity, level, minLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
		info = {
			entryType = "petbattleloot", 
			text = BATTLE_PET_LOOT_RECEIVED, 
			subText = name, --Item name
			icon = itemTexture, --Item icon
			quality = rarity, --Item quality
		};
	elseif ( typeIdentifier == "currency" ) then
		local name, quantity, icon, earnedThisWeek, weeklyMax, maxQuantity, discovered, rarity = GetCurrencyInfo(itemLink);
		info = {
			entryType = "petbattleloot",
			text = BATTLE_PET_LOOT_RECEIVED,
			subText = name,
			icon = icon,
			quality = rarity,
		};
	end

	if ( info ) then
		LevelUpDisplay_CreateOrAppendItem(self, TOAST_PET_BATTLE_LOOT, info);
	end
end

function LevelUpDisplay_Show(self)
	LevelUpDisplay_Start(self, nil);
end

function LevelUpDisplay_Start(self, beginUnlockList)
	if ( self:IsShown() ) then
		return;
	end

	if ( not IsPlayerInWorld() ) then
		-- this is pretty much the zoning-into-a-scenario case
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
		return;
	end

	self:Show();
	ZoneTextFrame:Hide();	--LevelUpDisplay is more important than zoning text
	SubZoneTextFrame:Hide();
	
	local playAnim;
	if  self.currSpell == 0 then
		local unlockList = beginUnlockList;
		if ( not self.type ) then
			self.type = self.queuedType;
			unlockList = self.queuedItems;
			self.queuedType = nil;
			self.queuedItems = nil;
		end
		if ( self.type == LEVEL_UP_TYPE_SCENARIO ) then
			local name, currentStage, numStages = C_Scenario.GetInfo();
			if ( currentStage > 0 and currentStage <= numStages ) then
				local stageName, stageDescription = C_Scenario.GetStepInfo();
				if ( currentStage == numStages ) then
					self.scenarioFrame.level:SetText(SCENARIO_STAGE_FINAL);
				else
					self.scenarioFrame.level:SetFormattedText(SCENARIO_STAGE, currentStage);
				end
				self.scenarioFrame.name:SetText(stageName);
				self.scenarioFrame.description:SetText(stageDescription);
				LevelUpDisplay:SetPoint("TOP", 0, -250);
				playAnim = self.scenarioFrame.newStage;
			end
		elseif ( self.type == TOAST_CHALLENGE_MODE_RECORD ) then
			local medal = self.medal;
			if ( CHALLENGE_MEDAL_TEXTURES[medal] ) then
				self.challengeModeFrame.MedalEarned:SetText(_G["CHALLENGE_MODE_MEDALNAME"..medal]);
				self.challengeModeFrame.RecordTime:SetFormattedText(CHALLENGE_MODE_NEW_BEST, GetTimeStringFromSeconds(self.recordTime / 1000));
				self.challengeModeBits.MedalFlare:Show();
				self.challengeModeBits.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[medal]);
				self.challengeModeBits.MedalIcon:Show();
				self.challengeModeBits.BottomFiligree:Show();
			else
				-- no medal earned, still a record time for player
				self.challengeModeFrame.MedalEarned:SetText(CHALLENGE_MODE_NEW_RECORD);
				self.challengeModeFrame.RecordTime:SetText(GetTimeStringFromSeconds(self.recordTime / 1000));
				self.challengeModeBits.MedalFlare:Hide();
				self.challengeModeBits.MedalIcon:Hide();
				self.challengeModeBits.BottomFiligree:Hide();
			end
			PlaySound("UI_Challenges_NewRecord");
			LevelUpDisplay:SetPoint("TOP", 0, -190);
			playAnim = self.challengeModeFrame.challengeComplete;
		else
			LevelUpDisplay:SetPoint("TOP", 0, -190);
			playAnim = self.levelFrame.levelUp;
			self.levelFrame.reachedText:SetText("");
			self.levelFrame.levelText:SetText("");
			self.levelFrame.singleline:SetText("");
			self.levelFrame.blockText:SetText("");
			if ( self.type == LEVEL_UP_TYPE_CHARACTER ) then
				LevelUpDisplay_BuildCharacterList(self);
				self.levelFrame.reachedText:SetText(LEVEL_UP_YOU_REACHED)
				self.levelFrame.levelText:SetFormattedText(LEVEL_GAINED,self.level);
			elseif ( self.type == LEVEL_UP_TYPE_PET ) then
				LevelUpDisplay_BuildPetList(self);
				local petName = UnitName("pet");
				self.levelFrame.reachedText:SetFormattedText(PET_LEVEL_UP_REACHED, petName or "");
				self.levelFrame.levelText:SetFormattedText(LEVEL_GAINED,self.level);
			elseif ( self.type == LEVEL_UP_TYPE_GUILD ) then
				LevelUpDisplay_BuildGuildList(self);
				local guildName = GetGuildInfo("player");
				self.levelFrame.reachedText:SetFormattedText(GUILD_LEVEL_UP_YOU_REACHED, guildName);
				self.levelFrame.levelText:SetFormattedText(LEVEL_GAINED,self.level);
			elseif ( self.type == TOAST_PET_BATTLE_WINNER ) then
				LevelUpDisplay_BuildPetBattleWinnerList(self);
				self.levelFrame.singleline:SetText(self.winnerString);
				PlaySoundKitID(self.winnerSoundKitID);
				playAnim = self.levelFrame.fastReveal;
			elseif (self.type == TOAST_QUEST_BOSS_EMOTE ) then
				LevelUpDisplay_BuildEmptyList(self);
				self.levelFrame.blockText:SetText(self.bossText);
				if (self.sound and self.sound == true) then
					PlaySound("RaidBossEmoteWarning");
				end
				playAnim = self.levelFrame.fastReveal;
			elseif (self.type == TOAST_PET_BATTLE_CAPTURE ) then
				self.unlockList = unlockList or {};
				self.currSpell = 1;
				self.levelFrame.singleline:SetText(BATTLE_PET_CAPTURED);
				playAnim = self.levelFrame.fastReveal;
			elseif ( self.type == TOAST_PET_BATTLE_LOOT ) then
				self.unlockList = unlockList or {};
				self.currSpell = 1;
				self.levelFrame.singleline:SetText(BATTLE_PET_LOOT_RECEIVED);
				playAnim = self.levelFrame.fastReveal;
			elseif (self.type == TOAST_PET_BATTLE_LEVELUP ) then
				self.unlockList = unlockList or {};
				self.currSpell = 1;
				self.levelFrame.singleline:SetText(PLAYER_LEVEL_UP);
				playAnim = self.levelFrame.fastReveal;
			end
		end

		if ( playAnim ) then
			self.gLine:SetTexCoord(unpack(levelUpTexCoords[self.type].gLine));
			self.gLine2:SetTexCoord(unpack(levelUpTexCoords[self.type].gLine));
			if (levelUpTexCoords[self.type].tint) then
				self.gLine:SetVertexColor(unpack(levelUpTexCoords[self.type].tint));
				self.gLine2:SetVertexColor(unpack(levelUpTexCoords[self.type].tint));
			else
				self.gLine:SetVertexColor(1, 1, 1);
				self.gLine2:SetVertexColor(1, 1, 1);
			end
			if (levelUpTexCoords[self.type].textTint) then
				self.levelFrame.levelText:SetTextColor(unpack(levelUpTexCoords[self.type].textTint));
			else
				self.levelFrame.levelText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end
			self.gLine.grow.anim1:SetStartDelay(levelUpTexCoords[self.type].gLineDelay);
			self.gLine2.grow.anim1:SetStartDelay(levelUpTexCoords[self.type].gLineDelay);
			self.blackBg.grow.anim1:SetStartDelay(levelUpTexCoords[self.type].gLineDelay);
			playAnim:Play();
			if (levelUpTexCoords[self.type].subIcon) then
				self.battlePetLevelFrame.subIcon:SetTexCoord(unpack(levelUpTexCoords[self.type].subIcon));
			end
		else
			self:Hide();
		end
	end
end


function LevelUpDisplay_AnimStep(self, fast)
	if self.currSpell > #self.unlockList then
		LevelUpDisplay_AnimOut(self, fast);
	else
		local spellInfo = self.unlockList[self.currSpell];
		self.currSpell = self.currSpell+1;

		self.spellFrame.name:SetText("");
		self.spellFrame.flavorText:SetText("");
		self.spellFrame.upperwhite:SetText("");
		self.spellFrame.bottomGiant:SetText("");
		self.spellFrame.subIcon:Hide();
		self.spellFrame.subIconRight:Hide();
		self.spellFrame.rarityUpperwhite:SetText("");
		self.spellFrame.rarityMiddleHuge:SetText("");
		self.spellFrame.rarityIcon:Hide();
		self.spellFrame.rarityValue:SetText("");
		self.spellFrame.rarityValue:Hide();
		
		if (not spellInfo.entryType or
			spellInfo.entryType == "spell" or
			spellInfo.entryType == "dungeon" or
			spellInfo.entryType == "heroicdungeon") then
			self.spellFrame.name:SetText(spellInfo.text);
			self.spellFrame.flavorText:SetText(spellInfo.subText);
			self.spellFrame.icon:SetTexture(spellInfo.icon);
			if (spellInfo.subIcon) then
				self.spellFrame.subIcon:Show();
				self.spellFrame.subIcon:SetTexCoord(unpack(spellInfo.subIcon));
			end
			self.spellFrame.showAnim:Play();
		elseif (spellInfo.entryType == "petlevelup") then
			if (spellInfo.subIcon) then
				self.spellFrame.subIconRight:Show();
				self.spellFrame.subIconRight:SetTexCoord(unpack(spellInfo.subIcon));
			end
			self.spellFrame.icon:SetTexture(spellInfo.icon);
			self.spellFrame.upperwhite:SetText(spellInfo.text);
			self.spellFrame.bottomGiant:SetText(spellInfo.subText);
			self.spellFrame.showAnim:Play();
		elseif (spellInfo.entryType == "petcapture") then
			self.spellFrame.icon:SetTexture(spellInfo.icon);
			self.spellFrame.rarityUpperwhite:SetText(spellInfo.text);
			self.spellFrame.rarityMiddleHuge:SetText(spellInfo.subText);
			if (spellInfo.quality) then
				self.spellFrame.iconBorder:Show();
				self.spellFrame.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[spellInfo.quality-1].r, ITEM_QUALITY_COLORS[spellInfo.quality-1].g, ITEM_QUALITY_COLORS[spellInfo.quality-1].b);
				self.spellFrame.rarityIcon:Show();
				self.spellFrame.rarityValue:SetText(_G["BATTLE_PET_BREED_QUALITY"..spellInfo.quality]);
				self.spellFrame.rarityValue:SetTextColor(ITEM_QUALITY_COLORS[spellInfo.quality-1].r, ITEM_QUALITY_COLORS[spellInfo.quality-1].g, ITEM_QUALITY_COLORS[spellInfo.quality-1].b);
				self.spellFrame.rarityValue:Show();
			end
			self.spellFrame.showAnim:Play();
		elseif ( spellInfo.entryType == "petbattleloot" ) then
			self.spellFrame.flavorText:SetText(HIGHLIGHT_FONT_COLOR_CODE..spellInfo.text.."|r");
			self.spellFrame.icon:SetTexture(spellInfo.icon);
			local coloredText = ITEM_QUALITY_COLORS[spellInfo.quality].hex..spellInfo.subText.."|r";
			self.spellFrame.name:SetText(coloredText);
			self.spellFrame.iconBorder:Show();
			self.spellFrame.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[spellInfo.quality].r, ITEM_QUALITY_COLORS[spellInfo.quality].g, ITEM_QUALITY_COLORS[spellInfo.quality].b);
			self.spellFrame.subIconRight:Show();
			self.spellFrame.subIconRight:SetTexCoord(0.719, 0.779, 0.117, 0.178)
			self.spellFrame.showAnim:Play();
		end
	end
end

function LevelUpDisplay_AnimOut(self, fast)
	self = self or LevelUpDisplay;
	self.currSpell = 0;
	self.type = nil;
	if (fast) then
		self.fastHideAnim:Play();
	else
		self.hideAnim:Play();
	end
end

function LevelUpDisplay_AnimOutFinished(anim)
	local parent = LevelUpDisplay;
	if ( parent.extraFrame ) then
		parent.extraFrame:Hide();
		parent.extraFrame = nil;
	end
	parent:Hide();
	--In case we had to queue something up while fading
	if ( parent.queuedType ) then
		LevelUpDisplay_Show(parent);
	end
end

--Side display Functions

function LevelUpDisplay_ShowSideDisplay(level, levelUpType, arg1)
	if LevelUpDisplaySide.level and LevelUpDisplaySide.level == level and LevelUpDisplaySide.type == levelUpType and LevelUpDisplaySide.arg1 == arg1 then
		if LevelUpDisplaySide:IsVisible() then		
			LevelUpDisplaySide:Hide();	
		else	
			LevelUpDisplaySide:Show();
		end
	else
		LevelUpDisplaySide.level = level;
		LevelUpDisplaySide.type = levelUpType;
		LevelUpDisplaySide.arg1 = arg1;
		LevelUpDisplaySide:Hide();
		LevelUpDisplaySide:Show();
	end
end


function LevelUpDisplaySide_OnShow(self)
	if ( self.type == LEVEL_UP_TYPE_CHARACTER ) then
		LevelUpDisplay_BuildCharacterList(self);
		self.reachedText:SetText(LEVEL_UP_YOU_REACHED);
		self.levelText:SetFormattedText(LEVEL_GAINED,self.level);
	elseif ( self.type == LEVEL_UP_TYPE_PET ) then
		LevelUpDisplay_BuildPetList(self);
		local petName = self.arg1;
		self.reachedText:SetFormattedText(PET_LEVEL_UP_REACHED, petName);
		self.levelText:SetFormattedText(LEVEL_GAINED,self.level);
	elseif ( self.type == LEVEL_UP_TYPE_GUILD ) then
		LevelUpDisplay_BuildGuildList(self);
		local guildName = GetGuildInfo("player");
		self.reachedText:SetFormattedText(GUILD_LEVEL_UP_YOU_REACHED, guildName);
		self.levelText:SetFormattedText(LEVEL_GAINED,self.level);
	end
	self.goldBG:SetTexCoord(unpack(levelUpTexCoords[self.type].goldBG));
	self.dot:SetTexCoord(unpack(levelUpTexCoords[self.type].dot));
	
	if (levelUpTexCoords[self.type].tint) then
		self.goldBG:SetVertexColor(unpack(levelUpTexCoords[self.type].tint));
		self.dot:SetVertexColor(unpack(levelUpTexCoords[self.type].tint));
	else
		self.goldBG:SetVertexColor(1, 1, 1);
		self.dot:SetVertexColor(1, 1, 1);
	end
	
	if (levelUpTexCoords[self.type].textTint) then
		self.levelText:SetTextColor(unpack(levelUpTexCoords[self.type].textTint));
	else
		self.levelText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	
	local i = 1;
	local displayFrame = _G["LevelUpDisplaySideUnlockFrame1"];
	while i <=  #self.unlockList do	
		if not displayFrame then -- make frames as needed
			displayFrame = CreateFrame("FRAME", "LevelUpDisplaySideUnlockFrame"..i, LevelUpDisplaySide, "LevelUpSkillTemplate");
			displayFrame:SetPoint("TOP",  _G["LevelUpDisplaySideUnlockFrame"..(i-1)], "BOTTOM", 0, -1);
			displayFrame:SetAlpha(0.0);
		end
		i = i+1;		
		displayFrame = _G["LevelUpDisplaySideUnlockFrame"..i];
	end
	self:SetHeight(65);
	self.fadeIn:Play();
end

function LevelUpDisplaySide_OnHide(self)
	local displayFrame = _G["LevelUpDisplaySideUnlockFrame1"];
	local i = 1;
	while displayFrame do 	
		if displayFrame.sideAnimIn:IsPlaying() then
			displayFrame.sideAnimIn:Stop();
		end				
		displayFrame:SetAlpha(0.0);
		i = i+1;
		displayFrame = _G["LevelUpDisplaySideUnlockFrame"..i];
	end	
end


function LevelUpDisplaySide_AnimStep(self)

	if self.currSpell > 1 then
		_G["LevelUpDisplaySideUnlockFrame"..(self.currSpell-1)]:SetAlpha(1.0);
	end	

	if self.currSpell <= #self.unlockList then
		local spellInfo = self.unlockList[self.currSpell];
		local displayFrame = _G["LevelUpDisplaySideUnlockFrame"..self.currSpell];
		displayFrame.name:SetText(spellInfo.text);
		displayFrame.flavorText:SetText(spellInfo.subText);
		displayFrame.icon:SetTexture(spellInfo.icon);
		displayFrame.subIcon:SetTexCoord(unpack(spellInfo.subIcon));
		displayFrame.subIconRight:Hide();
		displayFrame.sideAnimIn:Play();
		self.currSpell = self.currSpell+1;
		self:SetHeight(self:GetHeight()+45);
	end
end

function LevelUpDisplaySide_Remove()
	LevelUpDisplaySide.fadeOut:Play();
end


-- Chat print function 
function LevelUpDisplay_ChatPrint(self, level, levelUpType, ...)
	local info;
	local chatLevelUP = {level = level, type = levelUpType};
	local levelstring;
	if ( levelUpType == LEVEL_UP_TYPE_CHARACTER ) then
		LevelUpDisplay_BuildCharacterList(chatLevelUP);
		levelstring = format(LEVEL_UP, level, level);
		info = ChatTypeInfo["SYSTEM"];
	elseif ( levelUpType == LEVEL_UP_TYPE_PET ) then
		LevelUpDisplay_BuildPetList(chatLevelUP);
		local petName = UnitName("pet");
		if (petName) then
			levelstring = format(PET_LEVEL_UP, petName, level, petName, level);
		else
			levelstring = "";
		end
		info = ChatTypeInfo["SYSTEM"];
	elseif ( levelUpType == LEVEL_UP_TYPE_GUILD ) then
		LevelUpDisplay_BuildGuildList(chatLevelUP);
		local guildName = GetGuildInfo("player");
		levelstring = format(GUILD_LEVEL_UP, guildName, level, level);
		info = ChatTypeInfo["GUILD"];
	end
	self:AddMessage(levelstring, info.r, info.g, info.b, info.id);
	for _,skill in pairs(chatLevelUP.unlockList) do
		if skill.entryType == "heroicdungeon" then
			local name, link = EJ_GetTierInfo(skill.tier);
			self:AddMessage(LEVEL_UP_HEROIC2..link, info.r, info.g, info.b, info.id);
		elseif skill.entryType ~= "spell" then
			self:AddMessage(skill.link, info.r, info.g, info.b, info.id);
		end
	end
end



