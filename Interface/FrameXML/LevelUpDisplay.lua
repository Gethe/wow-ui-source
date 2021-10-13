LEVEL_UP_TYPE_CHARACTER = "character";	--Name used in globalstring LEVEL_UP
LEVEL_UP_TYPE_SCENARIO = "scenario";
LEVEL_UP_TYPE_SPELL_BUCKET = "spellbucket";
TOAST_QUEST_BOSS_EMOTE = "questbossemote";
TOAST_PET_BATTLE_WINNER = "petbattlewinner";
TOAST_PET_BATTLE_CAPTURE = "petbattlecapturetoast";
TOAST_PET_BATTLE_LEVELUP = "petbattleleveluptoast";
TOAST_PET_BATTLE_LOOT = "petbattleloot";
TOAST_CHALLENGE_MODE_RECORD = "challengemode";
TOAST_GARRISON_ABILITY = "garrisonability";
TOAST_WORLD_QUESTS_UNLOCKED = "worldquestsunlocked";

LEVEL_UP_PLAYER_STATE_CHECKS = {
	[C_PlayerInfo.CanPlayerUseAreaLoot] = {unlockType = "AreaLootUnlocked", allowedInNPE = true},
	[C_LFGInfo.CanPlayerUseLFD] = {unlockType = "LFDUnlocked"},
	[C_LFGInfo.CanPlayerUsePVP] = {unlockType = "BGsUnlocked"},
	[C_SpecializationInfo.CanPlayerUseTalentSpecUI] = {unlockType = "SpecializationUnlocked"},
	[C_SpecializationInfo.CanPlayerUseTalentUI] = {unlockType = "TalentsUnlocked"},
	[C_SpecializationInfo.CanPlayerUsePVPTalentUI] = {unlockType = "PvpTalentsUnlocked"},
	[C_PlayerInfo.CanPlayerUseMountEquipment] = {unlockType = "MountEquipmentUnlocked"},
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
	[TOAST_GARRISON_ABILITY] = {
		dot = { 0.64257813, 0.68359375, 0.18750000, 0.23046875 },
		goldBG = { 0.56054688, 0.99609375, 0.24218750, 0.46679688 },
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		gLineDelay = 1.5,
	},
	[LEVEL_UP_TYPE_SPELL_BUCKET] = {
		dot = { 0.64257813, 0.68359375, 0.18750000, 0.23046875 },
		goldBG = { 0.56054688, 0.99609375, 0.24218750, 0.46679688 },
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		gLineDelay = 1.5,
	},
	[TOAST_WORLD_QUESTS_UNLOCKED] = {
		dot = { 0.64257813, 0.68359375, 0.18750000, 0.23046875 },
		goldBG = { 0.56054688, 0.99609375, 0.24218750, 0.46679688 },
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
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

	["SpecializationUnlocked"] 	= 	{	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=SPECIALIZATION,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..LEVEL_UP_SPECIALIZATION_LINK
									},

	["TalentsUnlocked"] 		= 	{	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=TALENT_POINTS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..LEVEL_UP_TALENTS_LINK
									},

	["MountEquipmentUnlocked"] 	= 	{	icon="Interface\\Icons\\inv_blacksmith_leystonehoofplates_orange",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=MOUNT_EQUIPMENT_LEVEL_UP_FEATURE,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..LEVEL_UP_MOUNT_EQUIPMENT_LINK
									},

	["BGsUnlocked"] 			= 	{	icon="Interface\\Icons\\Ability_DualWield",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=BATTLEFIELDS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..LEVEL_UP_BG_LINK
									},

	["LFDUnlocked"] 			= 	{	icon="Interface\\Icons\\LevelUpIcon-LFD",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=LOOKING_FOR_DUNGEON,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..LEVEL_UP_LFD_LINK
									},

	["PvpTalentsUnlocked"] 		= 	{	icon="Interface\\Icons\\Ability_DualWield",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=PVP_TALENTS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..LEVEL_UP_HONOR_LINK
									},

	["AreaLootUnlocked"] 		= 	{	icon="Interface\\Icons\\ability_priest_holybolts01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text= AREA_LOOTING_UNLOCKED,
										subText= LEVEL_UP_FEATURE,
										instructionalText = AREA_LOOTING_UNLOCKED_DESC,
										link=AREA_LOOTING_UNLOCKED_CHAT_DISPLAY
									},

------ HACKS BELOW
 	["Teleports"] 			= {	spellID=109424	},
	["PortalsHorde"]		= {	spellID=109400	},
	["PortalsAlliance"]		= {	spellID=109401	},

 	["LockMount1"] 			= {	spellID=5784	},
 	["LockMount2"] 			= {	spellID=23161	},
 	["PaliMountHorde1"] 	= {	spellID=34769	},
 	["PaliMountHorde2"] 	= {	spellID=34767	},
 	["PaliMountAlliance1"] 	= {	spellID=13819	},
 	["PaliMountAlliance2"] 	= {	spellID=23214	},
 	["PaliMountTauren1"] 	= {	spellID=69820	},
 	["PaliMountTauren2"] 	= {	spellID=69826	},
 	["PaliMountDraenei1"] 	= {	spellID=73629	},
 	["PaliMountDraenei2"] 	= {	spellID=73630	},
 	["PaliMountZandalariTroll1"] 	= {	spellID=290608	},
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

local LevelUpSpellsCache = {
	spells = { },
	spec = nil,
	Store = function(self, level)
		if not self.spells[level] then
			self.spells[level] = {GetCurrentLevelSpells(level)};
		end
	end,
	Get = function(self, level)
		return self.spells[level] or {GetCurrentLevelSpells(level)};
	end,
	CheckSpec = function(self)
		local spec = GetSpecialization();
		if spec ~= self.spec then
			self.spec = spec;
			self.spells = { };
			local level = UnitLevel("player") + 1;
			self:Store(level);
		end
	end,
};

GARRISON_ABILITY_HACKS = {
	[26] = {
		["Horde"] = 161332,
		["Alliance"] = 161676,
		["Subtext"] = GARRISON_ABILITY_BARRACKS_UNLOCKED,
	},
}

LEVEL_UP_TRAP_LEVELS = {427, 77, 135}

function LevelUpDisplay_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	--self:RegisterEvent("SCENARIO_UPDATE");	this is now handled from the ObjectiveTracker
	self:RegisterEvent("PET_BATTLE_FINAL_ROUND"); -- display winner, start listening for additional results
	self:RegisterEvent("PET_BATTLE_CLOSE");        -- stop listening for additional results
	self:RegisterEvent("QUEST_BOSS_EMOTE");
	self:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD");
	self:RegisterEvent("MYTHIC_PLUS_NEW_SEASON_RECORD");
	self:RegisterEvent("PET_JOURNAL_TRAP_LEVEL_SET");
	self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED");
	self:RegisterEvent("PET_BATTLE_CAPTURED");
	self:RegisterEvent("PET_BATTLE_LOOT_RECEIVED");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATED");
	self:RegisterEvent("CHARACTER_UPGRADE_SPELL_TIER_SET");
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("JAILERS_TOWER_LEVEL_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self.currSpell = 0;

	self.PlayBanner = function(self, data)
		self.type = data.type;
		LevelUpDisplay_StartDisplay(self, data.unlockList);
	end

	self.StopBanner = function(self)
		LevelUpDisplay_StopAllAnims(self);
		self:Hide();	--We'll restart this toast on PLAYER_ENTERING_WORLD
		self.currSpell = 0;
	end

	self.ResumeBanner = function(self, data)
		self.type = data.type;
		LevelUpDisplay_StartDisplay(self, data.unlockList);
	end
end

function LevelUpDisplay_OnEvent(self, event, ...)
	local arg1 = ...;
	if event == "PLAYER_ENTERING_WORLD" then
		LevelUpDisplay_InitPlayerStates(self);
		LevelUpDisplay_InitPlayerStates(LevelUpDisplaySide);
		LevelUpSpellsCache:CheckSpec();
	elseif event == "PLAYER_LEVEL_UP" then
		-- NOTE: PLAYER_LEVEL_UP happens BEFORE the client player's level is actually updated.
		-- Since LevelUpDisplaySide is not shown every time the player levels up, we need to initialize the player states here
		-- This is to avoid the player seeing toasts for several levels at a time if they click on the Level Up link after gaining several levels in one session
		LevelUpDisplay_InitPlayerStates(LevelUpDisplaySide);	
	elseif event == "PLAYER_LEVEL_CHANGED" then
		local oldLevel, newLevel, real = ...;
		if real and oldLevel ~= 0 and newLevel ~= 0 then
			LevelUpSpellsCache:Store(newLevel + 1);
			if newLevel > oldLevel then
				self.level = newLevel;
				self.type = LEVEL_UP_TYPE_CHARACTER;
				LevelUpDisplay_Show(self);
				LevelUpDisplaySide:Hide();
			elseif newLevel < oldLevel then
				LevelUpDisplay_InitPlayerStates(self)
				LevelUpDisplay_InitPlayerStates(LevelUpDisplaySide);
			end
		end
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
		if (activePlayer == Enum.BattlePetOwner.Ally) then
			LevelUpDisplay_AddBattlePetLevelUpEvent(self, activePlayer, activePetSlot, newLevel);
		end
	elseif ( event == "PET_BATTLE_CAPTURED" ) then
		local fromPlayer, activePetSlot = ...;
		if (fromPlayer == Enum.BattlePetOwner.Enemy) then
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
	elseif ( event == "MYTHIC_PLUS_NEW_WEEKLY_RECORD" ) then
		local mapID, recordTime, level = ...;
		self.type = TOAST_CHALLENGE_MODE_RECORD;
		self.mapID = mapID;
		self.recordTime = recordTime;
        self.level = level;
		LevelUpDisplay_Show(self);
		PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_NEW_RECORD);
	elseif ( event == "GARRISON_BUILDING_ACTIVATED" ) then
		local _, buildingID = ...;
		if (GARRISON_ABILITY_HACKS[buildingID]) then
			self.buildingID = buildingID;
			self:RegisterEvent("CINEMATIC_STOP");
		end
	elseif ( event == "CINEMATIC_STOP" ) then
		self.type = TOAST_GARRISON_ABILITY;
		LevelUpDisplay_Show(self);
		self:UnregisterEvent("CINEMATIC_STOP");
	elseif ( event == "CHARACTER_UPGRADE_SPELL_TIER_SET") then
		local tierIndex = ...;
		LevelUpDisplay_AddSpellBucketUnlockEvent(self, tierIndex);
	elseif ( event == "QUEST_TURNED_IN") then
		local questID, xp, money = ...;

		if questID == WORLD_QUESTS_AVAILABLE_QUEST_ID then
			self.type = TOAST_WORLD_QUESTS_UNLOCKED;
			LevelUpDisplay_Show(self);
		end
	elseif (event == "JAILERS_TOWER_LEVEL_UPDATE") then 
		self.type = LEVEL_UP_TYPE_SCENARIO;
		local level, type, textureKit = ...; 
		self.jailersTowerLevelUpdateInfo = { level = level, type = type, textureKit = textureKit };
		LevelUpDisplay_Show(self);
	elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then
		LevelUpSpellsCache:CheckSpec();
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
	self.levelFrame.immediateReveal:Stop();
end

function LevelUpDisplay_PlayScenario()
	LevelUpDisplay.type = LEVEL_UP_TYPE_SCENARIO;
	LevelUpDisplay.jailersTowerLevelUpdateInfo = nil;
	LevelUpDisplay_Show(LevelUpDisplay);
end

function LevelUpDisplay_InitPlayerStates(self)
	for func, stateInfo in pairs(LEVEL_UP_PLAYER_STATE_CHECKS) do
		stateInfo[self] = nil;
		if func() then
			stateInfo[self] = true;
		end
	end
end

function LevelUpDisplay_BuildCharacterList(self)
	local name, icon, spellLink = "",nil,nil;
	self.unlockList = {};

	for func, stateInfo in pairs(LEVEL_UP_PLAYER_STATE_CHECKS) do
		if func() then
			if not stateInfo[self] then
				if not C_PlayerInfo.IsPlayerNPERestricted() or stateInfo.allowedInNPE then
					self.unlockList[#self.unlockList +1] = LEVEL_UP_TYPES[stateInfo.unlockType];
				end
				stateInfo[self] = true;
			end
		end
	end

	self.currSpell = 1;

	if  C_PlayerInfo.IsPlayerNPERestricted() then
		return;
	end

	local spells = LevelUpSpellsCache:Get(self.level);
	for _,spell in pairs(spells) do
		name, _, icon = GetSpellInfo(spell);
		spellLink = GetSpellLink(spell);
		self.unlockList[#self.unlockList +1] = { entryType = "spell", text = name, subText = LEVEL_UP_ABILITY, icon = icon, subIcon = SUBICON_TEXCOOR_BOOK,
																link=LEVEL_UP_ABILITY2.." "..spellLink
															};
	end

	local dungeons = {GetLevelUpInstances(self.level, false)};
	for _,dungeon in pairs(dungeons) do
		name, icon, link = GetDungeonInfo(dungeon);
		if link then -- link can come back as nil if there's no Dungeon Journal entry
			self.unlockList[#self.unlockList +1] = { entryType = "dungeon", text = name, subText = LEVEL_UP_DUNGEON, icon = icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_DUNGEON2.." "..link
																	};
		else
			self.unlockList[#self.unlockList +1] = { entryType = "dungeon", text = name, subText = LEVEL_UP_DUNGEON, icon = icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_DUNGEON2.." "..name
																	};
		end
	end

	local raids = {GetLevelUpInstances(self.level, true)};
	for _,raid in pairs(raids) do
		name, icon, link = GetDungeonInfo(raid);
		if link then -- link can come back as nil if there's no Dungeon Journal entry
			self.unlockList[#self.unlockList +1] = { entryType = "dungeon", text = name, subText = LEVEL_UP_RAID, icon = icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_RAID2.." "..link
																	};
		else
			self.unlockList[#self.unlockList +1] = { entryType = "dungeon", text = name, subText = LEVEL_UP_RAID, icon = icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_RAID2.." "..name
																	};
		end
	end

	local levelUpBGs = C_PvP.GetLevelUpBattlegrounds(self.level);
	local normalBGs = "";
	local numNormalBGs = 0;
	local epicBGs = "";
	local numEpicBGs = 0;
	for _, battlegroundInfo in ipairs(levelUpBGs) do
		if battlegroundInfo.isEpic then
			self.unlockList[#self.unlockList +1] = { entryType = "battleground", text = battlegroundInfo.name, subText = LEVEL_UP_EPIC_BATTLEGROUND, icon = battlegroundInfo.icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_EPIC_BATTLEGROUND2.." "..LEVEL_UP_UNLOCKED_BG_LINK:format(battlegroundInfo.id, battlegroundInfo.name);
																	};			
		else
			self.unlockList[#self.unlockList +1] = { entryType = "battleground", text = battlegroundInfo.name, subText = LEVEL_UP_BATTLEGROUND, icon = battlegroundInfo.icon, subIcon = SUBICON_TEXCOOR_LOCK,
																		link = LEVEL_UP_BATTLEGROUND2.." "..LEVEL_UP_UNLOCKED_BG_LINK:format(battlegroundInfo.id, battlegroundInfo.name);
																	};		
		end
	end
end

function LevelUpDisplay_BuildSpellBucketList(self)
	local allUnlocked, spells, _, talentTier = GetSpellsForCharacterUpgradeTier(self.level);

	self.unlockList = {};
	if (not allUnlocked) then
		if (spells) then
			for i = 1, #spells do
				local name, _, icon = GetSpellInfo(spells[i]);
				self.unlockList[#self.unlockList+1] = { entryType = "bucketspell", text = name, icon = icon };
			end
		else
			for i = 1, NUM_TALENT_COLUMNS do
				local _, name, icon = GetTalentInfo(talentTier, i, GetActiveSpecGroup());
				self.unlockList[#self.unlockList+1] = { entryType = "bucketspell", text = name, icon = icon };
			end
		end
	end

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

function LevelUpDisplay_BuildGarrisonAbilityList(self)
	self.unlockList = {};

	local faction = UnitFactionGroup("player");
	local spellID = GARRISON_ABILITY_HACKS[self.buildingID][faction];
	local abilityText = GARRISON_ABILITY_HACKS[self.buildingID].Subtext;
	local name, _, texture = GetSpellInfo(spellID);
	local spellLink = GetSpellLink(spellID);
	tinsert(self.unlockList, { text = name, subText = abilityText, icon = texture, subIcon = SUBICON_TEXCOOR_BOOK, link = LEVEL_UP_ABILITY2.." "..spellLink});

	self.currSpell = 1;
end

function LevelUpDisplay_BuildPetBattleWinnerList(self)
	self.unlockList = {};
	self.winnerString = PET_BATTLE_RESULT_LOSE;
	if(C_PetBattles.IsWildBattle()) then
		self.winnerSoundKitID = 34090; --UI_PetBattle_PVE_Defeat
	elseif(C_PetBattles.IsPlayerNPC(Enum.BattlePetOwner.Enemy)) then
		self.winnerSoundKitID = 34094; --UI_PetBattle_Special_Defeat
	else
		self.winnerSoundKitID = 34092; --UI_PetBattle_PVP_Defeat
	end

	if ( self.winner == Enum.BattlePetOwner.Ally ) then
		self.winnerString = PET_BATTLE_RESULT_WIN;
		if(C_PetBattles.IsWildBattle()) then
			self.winnerSoundKitID = 34089; --UI_PetBattle_PVE_Victory
		elseif(C_PetBattles.IsPlayerNPC(Enum.BattlePetOwner.Enemy)) then
			self.winnerSoundKitID = 34093; --UI_PetBattle_Special_Victory
		else
			self.winnerSoundKitID = 34091; --UI_PetBattle_PVP_Victory
		end
	end;
	self.currSpell = 1;
end

function LevelUpDisplay_BuildWorldQuestBucketList(self)
	self.unlockList = {};
	table.insert(self.unlockList,
			{
				entryType = "worldquest",
				icon="Interface\\Icons\\icon_treasuremap",
				subIcon=SUBICON_TEXCOOR_LOCK,
				text=LEVEL_UP_WORLD_QUESTS,
				subText=LEVEL_UP_FEATURE,
				link=LEVEL_UP_FEATURE2.." "..LEVEL_UP_WORLD_QUEST_LINK,
				instructionalText = LEVEL_UP_WORLD_QUESTS_INSTRUCTIONS,
			}
	);
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
	if (activePlayer ~= Enum.BattlePetOwner.Ally) then
		return;
	end

	if (self.currSpell == 0) then
		self.type = TOAST_PET_BATTLE_LEVELUP;
		LevelUpDisplay_Show(self);
	end

	local petID = C_PetJournal.GetPetLoadOutInfo(activePetSlot - 1);
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

function LevelUpDisplay_AddSpellBucketUnlockEvent(self, tierIndex)
	if (tierIndex == 0) then
		return;
	end

	if (self.currSpell == 0) then
		self.type = LEVEL_UP_TYPE_SPELL_BUCKET;
		self.tierIndex = tierIndex;
		LevelUpDisplay_Show(self);
		return;
	end

	table.insert(self.unlockList,
		{
		entryType = "spellbucket",
		tierIndex = tierIndex,
		});
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
	if (fromPlayer ~= Enum.BattlePetOwner.Enemy) then
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
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink);
		local name = currencyInfo.name;
		local icon = currencyInfo.iconFileID;
		local rarity = currencyInfo.quality;
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

function LevelUpDisplay_IsExclusiveQueued( currBanner, queuedBanner )
	if( currBanner.frame ~= LevelUpDisplay or queuedBanner.frame ~= LevelUpDisplay ) then
		return false;
	end
	-- A banner of the same type is queued. Don't requeue.
	return currBanner.type == queuedBanner.type;
end

function LevelUpDisplay_Start(self, beginUnlockList)
	TopBannerManager_Show(LevelUpDisplay, {type = self.type, unlockList = beginUnlockList}
										,	LevelUpDisplay_IsExclusiveQueued);
end

local textureKitRegionFormatStrings = {
	["BG1"] = "%s-TitleBG",
	["BG2"] = "%s-TitleBG",
}

local defaultAtlases = {
	["BG1"] = "legioninvasion-title-bg",
	["BG2"] = "legioninvasion-title-bg",
}

function LevelUpDisplay_StartDisplay(self, beginUnlockList)
	if ( self:IsShown() ) then
		return;
	end

	self:SetHeight(72);
	self:Show();
	ZoneTextFrame:Hide();	--LevelUpDisplay is more important than zoning text
	SubZoneTextFrame:Hide();
	self.challengeModeBits.MedalFlare:Hide();
	self.challengeModeBits.MedalIcon:Hide();
	self.challengeModeBits.BottomFiligree:Hide();
	local playAnim;
	local scenarioType = 0;
	if self.currSpell == 0 then
		local unlockList = beginUnlockList;
		if ( not self.type ) then
			self.type = self.queuedType;
			unlockList = self.queuedItems;
			self.queuedType = nil;
			self.queuedItems = nil;
		end
		if ( self.type == LEVEL_UP_TYPE_SCENARIO and not self.jailersTowerLevelUpdateInfo) then
			local name, currentStage, numStages, flags, textureKit, _;
			name, currentStage, numStages, flags, _, _, _, _, _, scenarioType, _, textureKit = C_Scenario.GetInfo();
			if (not IsBoostTutorialScenario()) then
				if ( currentStage > 0 and currentStage <= numStages ) then
					local stageName, stageDescription = C_Scenario.GetStepInfo();

					self.scenarioFrame.level:ClearAllPoints();
					if( bit.band(flags, SCENARIO_FLAG_SUPRESS_STAGE_TEXT) == SCENARIO_FLAG_SUPRESS_STAGE_TEXT) then
						-- Bypass the Stage name portion...
						self.scenarioFrame.level:SetText(stageName);
						self.scenarioFrame.name:SetText("");
						self.scenarioFrame.level:SetPoint("TOP", self.scenarioFrame, "TOP", 0, -22);
					else
						self.scenarioFrame.level:SetPoint("TOP", self.scenarioFrame, "TOP", 0, -14);
						if ( currentStage == numStages ) then
							self.scenarioFrame.level:SetText(SCENARIO_STAGE_FINAL);
						else
							self.scenarioFrame.level:SetFormattedText(SCENARIO_STAGE, currentStage);
						end
						self.scenarioFrame.name:SetText(stageName);
					end

					if textureKit then
						playAnim = self.scenarioFrame.TextureKitNewStage;
						SetupTextureKitOnRegions(textureKit, self.scenarioFrame, textureKitRegionFormatStrings, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
					else
						if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
							playAnim = self.scenarioFrame.LegionInvasionNewStage;
						else
							playAnim = self.scenarioFrame.newStage;
						end

						SetupAtlasesOnRegions(self.scenarioFrame, defaultAtlases, true);
					end

					self.scenarioFrame.description:SetText(stageDescription);
					LevelUpDisplay:SetPoint("TOP", 0, -250);
				end
			end
		elseif ( self.type == TOAST_CHALLENGE_MODE_RECORD ) then
			self.challengeModeFrame.LevelCompleted:SetFormattedText(CHALLENGE_MODE_POWER_LEVEL, self.level);
			self.challengeModeFrame.RecordTime:SetFormattedText(CHALLENGE_MODE_NEW_BEST, SecondsToClock(self.recordTime / 1000, true));
			PlaySound(SOUNDKIT.UI_CHALLENGES_NEW_RECORD);
			LevelUpDisplay:SetPoint("TOP", 0, -190);
			playAnim = self.challengeModeFrame.challengeComplete;
		elseif ( self.type == LEVEL_UP_TYPE_SCENARIO and self.jailersTowerLevelUpdateInfo) then
			self.scenarioFrame.level:ClearAllPoints();
			self.scenarioFrame.level:SetPoint("TOP", self.scenarioFrame, "TOP", 0, -14);
			local typeString = C_ScenarioInfo.GetJailersTowerTypeString(self.jailersTowerLevelUpdateInfo.type);
			if(typeString) then	
				self.scenarioFrame.level:SetText(typeString); 
			end 

			self.scenarioFrame.name:SetText(JAILERS_TOWER_SCENARIO_FLOOR:format(self.jailersTowerLevelUpdateInfo.level));
			self.scenarioFrame.description:SetText("");
			playAnim = self.scenarioFrame.TextureKitNewStage;
			local textureKit = select(12, C_Scenario.GetInfo());
			if (textureKit) then 
				SetupTextureKitOnRegions(textureKit, self.scenarioFrame, textureKitRegionFormatStrings, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
			end 
			LevelUpDisplay:SetPoint("TOP", 0, -250);
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
			elseif ( self.type == TOAST_PET_BATTLE_WINNER ) then
				LevelUpDisplay_BuildPetBattleWinnerList(self);
				self.levelFrame.singleline:SetText(self.winnerString);
				PlaySound(self.winnerSoundKitID);
				playAnim = self.levelFrame.fastReveal;
			elseif (self.type == TOAST_QUEST_BOSS_EMOTE ) then
				LevelUpDisplay_BuildEmptyList(self);
				self.levelFrame.blockText:SetText(self.bossText);
				if (self.sound and self.sound == true) then
					PlaySound(SOUNDKIT.RAID_BOSS_EMOTE_WARNING);
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
			elseif ( self.type == LEVEL_UP_TYPE_SPELL_BUCKET ) then
				self.unlockList = unlockList or {};
				self.currSpell = 1;
				local tierIndex = self.tierIndex;
				if (tierIndex > 0) then
					local unlockAll, spells, tierName, talentTier = GetSpellsForCharacterUpgradeTier(tierIndex);
					if (unlockAll) then
						local icon = select(4, GetSpecializationInfo(GetSpecialization()));
						self.SpellBucketFrame.AllAbilitiesUnlocked.icon:SetTexture(icon);
						self.SpellBucketFrame.AllAbilitiesUnlocked.subIcon:SetTexCoord(unpack(SUBICON_TEXCOOR_BOOK));
						self.SpellBucketFrame.SpellBucketDisplay:Hide();
						self.SpellBucketFrame.AllAbilitiesUnlocked:Show();
						self:SetHeight(70);
					else
						local num, isTalents;
						if (spells and #spells > 0) then
							num = #spells;
						elseif (talentTier > 0) then
							num = NUM_TALENT_COLUMNS;
							isTalents = true;
						else
							return;
						end
						if (num > 5) then
							num = 5;
						end
						local index = #self.SpellBucketFrame.SpellBucketDisplay.BucketIcons + 1;
						local frameWidth, spacing = 56, 4;
						while (#self.SpellBucketFrame.SpellBucketDisplay.BucketIcons < num) do
							local frame = CreateFrame("Frame", nil, self.SpellBucketFrame.SpellBucketDisplay, "SpellBucketSpellTemplate");
							local prev = self.SpellBucketFrame.SpellBucketDisplay.BucketIcons[index - 1];
							frame:SetPoint("LEFT", prev, "RIGHT", spacing, 0);
							index = index + 1;
						end
						-- Figure out where to place the leftmost spell
						local frame = self.SpellBucketFrame.SpellBucketDisplay.BucketIcons[1];
						frame:ClearAllPoints();
						if (num % 2 == 1) then
							local x = (num - 1) / 2;
							frame:SetPoint("TOPLEFT", self.SpellBucketFrame.SpellBucketDisplay, "TOP", -((frameWidth / 2) + (frameWidth * x) + (spacing * x)), -42);
						else
							local x = num / 2;
							frame:SetPoint("TOPLEFT", self.SpellBucketFrame.SpellBucketDisplay, "TOP", -((frameWidth * x) + (spacing * (x - 1)) + (spacing / 2)), -42);
						end
						for i = 1, num do
							local name, icon, _;
							local spellframe = self.SpellBucketFrame.SpellBucketDisplay.BucketIcons[i];
							if (not isTalents) then
								local spellID = spells[i];
								name, _, icon = GetSpellInfo(spellID);
							else
								_, name, icon = GetTalentInfo(talentTier, i, GetActiveSpecGroup());
							end
							spellframe.name:SetText(name);
							spellframe.icon:SetTexture(icon);
							spellframe:Show();
						end
						for i = num+1, #self.SpellBucketFrame.SpellBucketDisplay.BucketIcons do
							self.SpellBucketFrame.SpellBucketDisplay.BucketIcons[i]:Hide();
						end
						self.SpellBucketFrame.SpellBucketDisplay.Name:SetText(tierName);
						self.SpellBucketFrame.AllAbilitiesUnlocked:Hide();
						self.SpellBucketFrame.SpellBucketDisplay:Show();
						self:SetHeight(112);
					end
					playAnim = self.SpellBucketFrame.bucketUnlocked;
				end
			elseif (self.type == TOAST_GARRISON_ABILITY ) then
				LevelUpDisplay_BuildGarrisonAbilityList(self);
			elseif (self.type == TOAST_WORLD_QUESTS_UNLOCKED ) then
				LevelUpDisplay_BuildWorldQuestBucketList(self);
				playAnim = self.levelFrame.immediateReveal;
			end
		end

		if ( playAnim and scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION) then
			playAnim:Play();
		elseif ( playAnim ) then
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

		self.spellFrame:Hide();
		self.spellFrame.name:SetText("");
		self.spellFrame.flavorText:SetText("");
		self.spellFrame.middleName:SetText("");
		self.spellFrame.upperwhite:SetText("");
		self.spellFrame.bottomGiant:SetText("");
		self.spellFrame.subIcon:Hide();
		self.spellFrame.subIconRight:Hide();
		self.spellFrame.iconBorder:Hide();
		self.spellFrame.rarityUpperwhite:SetText("");
		self.spellFrame.rarityMiddleHuge:SetText("");
		self.spellFrame.rarityIcon:Hide();
		self.spellFrame.rarityValue:SetText("");
		self.spellFrame.rarityValue:Hide();
		self.spellFrame.instructionalText:SetText("");

		if (not spellInfo.entryType or
			spellInfo.entryType == "spell" or
			spellInfo.entryType == "dungeon" or
			spellInfo.entryType == "heroicdungeon" or
			spellInfo.entryType == "worldquest" or
			spellInfo.entryType == "battleground"
			) then
			self.spellFrame.name:SetText(spellInfo.text);
			self.spellFrame.flavorText:SetText(spellInfo.subText);
			self.spellFrame.icon:Show();
			self.spellFrame.icon:SetTexture(spellInfo.icon);
			if (spellInfo.subIcon) then
				self.spellFrame.subIcon:Show();
				self.spellFrame.subIcon:SetTexCoord(unpack(spellInfo.subIcon));
			end
			if (spellInfo.instructionalText) then
				self.spellFrame.instructionalText:SetText(spellInfo.instructionalText);
			end
			self.spellFrame:Show();
			self.spellFrame.showAnim.anim2:SetStartDelay(spellInfo.entryType == "worldquest" and 5 or 1.8);
			self.spellFrame.showAnim:Play();
		elseif (spellInfo.entryType == "petlevelup") then
			if (spellInfo.subIcon) then
				self.spellFrame.subIconRight:Show();
				self.spellFrame.subIconRight:SetTexCoord(unpack(spellInfo.subIcon));
			end
			self.spellFrame.icon:Show();
			self.spellFrame.icon:SetTexture(spellInfo.icon);
			self.spellFrame.upperwhite:SetText(spellInfo.text);
			self.spellFrame.bottomGiant:SetText(spellInfo.subText);
			self.spellFrame:Show();
			self.spellFrame.showAnim:Play();
		elseif (spellInfo.entryType == "petcapture") then
			self.spellFrame.icon:Show();
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
			self.spellFrame:Show();
			self.spellFrame.showAnim:Play();
		elseif ( spellInfo.entryType == "petbattleloot" ) then
			self.spellFrame.icon:Show();
			self.spellFrame.flavorText:SetText(HIGHLIGHT_FONT_COLOR_CODE..spellInfo.text.."|r");
			self.spellFrame.icon:SetTexture(spellInfo.icon);
			local coloredText = ITEM_QUALITY_COLORS[spellInfo.quality].hex..spellInfo.subText.."|r";
			self.spellFrame.name:SetText(coloredText);
			self.spellFrame.iconBorder:Show();
			self.spellFrame.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[spellInfo.quality].r, ITEM_QUALITY_COLORS[spellInfo.quality].g, ITEM_QUALITY_COLORS[spellInfo.quality].b);
			self.spellFrame.subIconRight:Show();
			self.spellFrame.subIconRight:SetTexCoord(0.719, 0.779, 0.117, 0.178)
			self.spellFrame:Show();
			self.spellFrame.showAnim:Play();
		elseif ( spellInfo.entryType == "spellbucket" ) then
			local tierIndex = spellInfo.tierIndex;
			if (tierIndex > 0) then
				local unlockAll, spells, tierName, talentTier = GetSpellsForCharacterUpgradeTier(tierIndex);
				if (unlockAll) then
					local icon = select(4, GetSpecializationInfo(GetSpecialization()));
					self.SpellBucketFrame.AllAbilitiesUnlocked.icon:SetTexture(icon);
					self.SpellBucketFrame.AllAbilitiesUnlocked.subIcon:SetTexCoord(unpack(SUBICON_TEXCOOR_BOOK));
					self.SpellBucketFrame.SpellBucketDisplay:Hide();
					self.SpellBucketFrame.AllAbilitiesUnlocked:Show();
					self:SetHeight(70);
				else
					local num, isTalents;
					if (spells) then
						num = #spells;
					else
						num = NUM_TALENT_COLUMNS;
						isTalents = true;
					end
					if (num > 5) then
						num = 5;
					end
					local index = #self.SpellBucketFrame.SpellBucketDisplay.BucketIcons + 1;
					local frameWidth, spacing = 56, 4;
					while (#self.SpellBucketFrame.SpellBucketDisplay.BucketIcons < num) do
						local frame = CreateFrame("Frame", nil, self.SpellBucketFrame.SpellBucketDisplay, "SpellBucketSpellTemplate");
						local prev = self.SpellBucketFrame.SpellBucketDisplay.BucketIcons[index - 1];
						frame:SetPoint("LEFT", prev, "RIGHT", spacing, 0);
						index = index + 1;
					end
					-- Figure out where to place the leftmost spell
					local frame = self.SpellBucketFrame.SpellBucketDisplay.BucketIcons[1];
					frame:ClearAllPoints();
					if (num % 2 == 1) then
						local x = (num - 1) / 2;
						frame:SetPoint("TOPLEFT", self.SpellBucketFrame.SpellBucketDisplay, "TOP", -((frameWidth / 2) + (frameWidth * x) + (spacing * x)), -42);
					else
						local x = num / 2;
						frame:SetPoint("TOPLEFT", self.SpellBucketFrame.SpellBucketDisplay, "TOP", -((frameWidth * x) + (spacing * (x - 1)) + (spacing / 2)), -42);
					end
					for i = 1, num do
						local name, icon, _;
						local spellframe = self.SpellBucketFrame.SpellBucketDisplay.BucketIcons[i];
						if (not isTalents) then
							local spellID = spells[i];
							name, _, icon = GetSpellInfo(spellID);
						else
							_, name, icon = GetTalentInfo(talentTier, i, GetActiveSpecGroup());
						end
						spellframe.name:SetText(name);
						spellframe.icon:SetTexture(icon);
						spellframe:Show();
					end
					for i = num+1, #self.SpellBucketFrame.SpellBucketDisplay.BucketIcons do
						self.SpellBucketFrame.SpellBucketDisplay.BucketIcons[i]:Hide();
					end
					self.SpellBucketFrame.SpellBucketDisplay.Name:SetText(tierName);
					self.SpellBucketFrame.AllAbilitiesUnlocked:Hide();
					self:SetHeight(112);
				end
				self.SpellBucketFrame:Show();
				self.SpellBucketFrame.bucketUnlocked:Play();
			else
				LevelUpDisplay_AnimStep(self, fast);
			end
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

function LevelUpDisplay_AnimOutFinished()
	local parent = LevelUpDisplay;
	if ( parent.extraFrame ) then
		parent.extraFrame:Hide();
		parent.extraFrame = nil;
	end
	parent:Hide();
	--In case we had to queue something up while fading
	if ( parent.queuedType ) then
		LevelUpDisplay_Show(parent);
	else
		TopBannerManager_BannerFinished();
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
	self.abilitiesUnlocked:Hide();
	self.spellBucketName:Hide();
	self.reachedText:Show();
	self.levelText:Show();
	if ( self.type == LEVEL_UP_TYPE_CHARACTER ) then
		LevelUpDisplay_BuildCharacterList(self);
		self.reachedText:SetText(LEVEL_UP_YOU_REACHED);
		self.levelText:SetFormattedText(LEVEL_GAINED,self.level);
	elseif ( self.type == LEVEL_UP_TYPE_SPELL_BUCKET ) then
		LevelUpDisplay_BuildSpellBucketList(self);
		self.reachedText:Hide();
		self.levelText:Hide();
		local _, _, name = GetSpellsForCharacterUpgradeTier(self.level);
		self.spellBucketName:SetText(name);
		self.abilitiesUnlocked:Show();
		self.spellBucketName:Show();
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
		if (spellInfo.entryType and spellInfo.entryType == "bucketspell") then
			displayFrame.name:SetText("");
			displayFrame.flavorText:SetText("");
			displayFrame.middleName:SetText(spellInfo.text);
			displayFrame.icon:SetTexture(spellInfo.icon);
			displayFrame.subIcon:Hide();
		else
			displayFrame.name:SetText(spellInfo.text);
			displayFrame.flavorText:SetText(spellInfo.subText);
			displayFrame.icon:SetTexture(spellInfo.icon);
			displayFrame.subIcon:SetTexCoord(unpack(spellInfo.subIcon));
			displayFrame.subIcon:Show();
		end
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
	-- Certain situations don't display any level up text, set filters here.
	local shouldDisplayBucketUnlocks = not IsBoostTutorialScenario();

	local info;

	if not self.chatLevelUP then
		self.chatLevelUP = {};
	end

	self.chatLevelUP.level = level;
	self.chatLevelUP.type = levelUpType;
	self.chatLevelUP.unlockList = nil;

	local levelstring;
	if ( levelUpType == LEVEL_UP_TYPE_CHARACTER ) then
		LevelUpDisplay_BuildCharacterList(self.chatLevelUP);
		levelstring = format(LEVEL_UP, level, level);
		info = ChatTypeInfo["SYSTEM"];
	elseif ( shouldDisplayBucketUnlocks and levelUpType == LEVEL_UP_TYPE_SPELL_BUCKET ) then
		local allUnlocked, _, name = GetSpellsForCharacterUpgradeTier(level);
		if (allUnlocked) then
			local class = UnitClass("player");
			levelstring = format(SPELL_BUCKET_ALL_ABILITIES_UNLOCKED_MESSAGE, class);
		else
			LevelUpDisplay_BuildSpellBucketList(self.chatLevelUP);
			levelstring = format(SPELL_BUCKET_LEVEL_UP, level, name or "");
		end
		info = ChatTypeInfo["SYSTEM"];
	elseif ( levelUpType == TOAST_WORLD_QUESTS_UNLOCKED ) then
		LevelUpDisplay_BuildWorldQuestBucketList(self.chatLevelUP);
		info = ChatTypeInfo["SYSTEM"];
	end

	if (info and levelstring) then
		self:AddMessage(levelstring, info.r, info.g, info.b, info.id);
	end

	if (self.chatLevelUP.unlockList) then
		for _,skill in pairs(self.chatLevelUP.unlockList) do
			if skill.entryType == "heroicdungeon" then
				local name, link = EJ_GetTierInfo(skill.tier);
				self:AddMessage(LEVEL_UP_HEROIC2..link, info.r, info.g, info.b, info.id);
			elseif skill.entryType ~= "spell" and skill.entryType ~= "bucketspell" then
				self:AddMessage(skill.link, info.r, info.g, info.b, info.id);
			end
		end
	end
end

-- ************************************************************************************************************************************************************
-- **** BOSS BANNER *******************************************************************************************************************************************
-- ************************************************************************************************************************************************************

local BB_EXPAND_TIME = 0.25;		-- time to expand per item
local BB_EXPAND_HEIGHT = 50;		-- pixels to expand per item
local BB_MAX_LOOT = 7;

local BB_STATE_BANNER_IN = 1;		-- banner is animating in
local BB_STATE_KILL_HOLD = 2;		-- banner is holding with kill info
local BB_STATE_SWITCH = 3;			-- banner is switching from kill to loot look
local BB_STATE_LOOT_EXPAND = 4;		-- banner is expanding for loot items
local BB_STATE_LOOT_INSERT = 5;		-- loot item is being inserted. banner will hold for longer than insertion animation to catch more loot.
local BB_STATE_BANNER_OUT = 6;		-- banner is animating out

function BossBanner_AnimBannerIn(self, entry)
	self.lootShown = 0;		-- how many items the UI is displaying
	self.AnimIn:Play();
end

function BossBanner_AnimKillHold(self, entry)
	-- nothing here
end

function BossBanner_AnimSwitch(self, entry)
	if ( next(self.pendingLoot) ) then
		-- we have loot
		self.AnimSwitch:Play();
		PlaySound(SOUNDKIT.UI_PERSONAL_LOOT_BANNER);
		entry.duration = 0.5;
	else
		entry.duration = 0;
	end
end

function BossBanner_AnimLootExpand(self, entry)
	-- don't need to expand for first item
	if ( self.lootShown > 0 and self.lootShown < BB_MAX_LOOT and next(self.pendingLoot) ) then
		entry.duration = BB_EXPAND_TIME;
	else
		entry.duration = 0;
	end
end

function BossBanner_AnimLootInsert(self, entry)
	local key, data = next(self.pendingLoot);
	if ( key ) then
		-- we have an item, show it
		self.pendingLoot[key] = nil;
		self.lootShown = self.lootShown + 1;
		local lootFrame = self.LootFrames[self.lootShown];
		if ( not lootFrame ) then
			lootFrame = CreateFrame("FRAME", nil, self, "BossBannerLootFrameTemplate");
			lootFrame:SetPoint("TOP", self.LootFrames[self.lootShown - 1], "BOTTOM", 0, -6);
		end
		BossBanner_ConfigureLootFrame(lootFrame, data);
		lootFrame:Show();
		lootFrame.Anim:Play();
		-- loop back if more items
		if ( next(self.pendingLoot) and self.lootShown < BB_MAX_LOOT ) then
			BossBanner_SetAnimState(self, BB_STATE_LOOT_EXPAND);
			return true;
		end
	end
	if ( self.lootShown > 0 ) then
		entry.duration = 4;
	else
		entry.duration = 0;
	end
end

function BossBanner_ConfigureLootFrame(lootFrame, data)
	local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture, _, _, _, _, _, setID = GetItemInfo(data.itemLink);
	lootFrame.ItemName:SetText(itemName);
	local rarityColor = ITEM_QUALITY_COLORS[itemRarity];
	lootFrame.ItemName:SetTextColor(rarityColor.r, rarityColor.g, rarityColor.b);
	lootFrame.Background:SetVertexColor(rarityColor.r, rarityColor.g, rarityColor.b);
	lootFrame.Icon:SetTexture(itemTexture);

	SetItemButtonQuality(lootFrame.IconHitBox, itemRarity, data.itemLink);

	if ( data.quantity > 1 ) then
		lootFrame.Count:Show();
		lootFrame.Count:SetText(data.quantity);
	else
		lootFrame.Count:Hide();
	end

	if (setID) then
		local setName = GetItemSetInfo(setID);
		lootFrame.ItemName:ClearAllPoints();
		lootFrame.ItemName:SetPoint("TOPLEFT", 56, -2);
		lootFrame.SetName:SetText(BOSS_BANNER_LOOT_SET:format(setName));
		lootFrame.SetName:Show();
		lootFrame.PlayerName:ClearAllPoints();
		lootFrame.PlayerName:SetPoint("TOPLEFT", lootFrame.SetName, "BOTTOMLEFT", 0, 0);
	else
		lootFrame.ItemName:ClearAllPoints();
		lootFrame.ItemName:SetPoint("TOPLEFT", 56, -7);
		lootFrame.SetName:Hide();
		lootFrame.PlayerName:ClearAllPoints();
		lootFrame.PlayerName:SetPoint("TOPLEFT", lootFrame.ItemName, "BOTTOMLEFT", 0, 0);
	end

	lootFrame.PlayerName:SetText(data.playerName);
	local classColor = RAID_CLASS_COLORS[data.className];
	lootFrame.PlayerName:SetTextColor(classColor.r, classColor.g, classColor.b);
	lootFrame.itemLink = data.itemLink;
end

function BossBanner_AnimBannerOut(self, entry)
	self.AnimOut:Play();
end

local BB_ANIMATION_CONTROL = {
	[BB_STATE_BANNER_IN] =	{ duration = 1.85,	onStartFunc = BossBanner_AnimBannerIn },
	[BB_STATE_KILL_HOLD] =	{ duration = 2,		onStartFunc = BossBanner_AnimKillHold },
	[BB_STATE_SWITCH] =		{ duration = nil,	onStartFunc = BossBanner_AnimSwitch },
	[BB_STATE_LOOT_EXPAND] ={ duration = nil,	onStartFunc = BossBanner_AnimLootExpand },
	[BB_STATE_LOOT_INSERT] ={ duration = nil,	onStartFunc = BossBanner_AnimLootInsert },
	[BB_STATE_BANNER_OUT] =	{ duration = 0.5,	onStartFunc = BossBanner_AnimBannerOut },
};

function BossBanner_BeginAnims(self, animState)
	BossBanner_SetAnimState(self, animState or BB_STATE_BANNER_IN);
end

function BossBanner_SetAnimState(self, animState)
	local entry = BB_ANIMATION_CONTROL[animState];
	if ( entry ) then
		local redirected = entry.onStartFunc(self, entry);
		if ( not redirected ) then
			self.animState = animState;
			self.animTimeLeft = entry.duration;
		end
	else
		self.animState = nil;
		self.animTimeLeft = nil;
	end
end

function BossBanner_OnUpdate(self, elapsed)
	if ( not self.animState ) then
		return;
	end
	self.animTimeLeft = self.animTimeLeft - elapsed;
	if ( self.animState == BB_STATE_LOOT_EXPAND ) then
		local newHeight = self.baseHeight + (self.lootShown * BB_EXPAND_HEIGHT) - (max(self.animTimeLeft, 0) / BB_EXPAND_TIME * BB_EXPAND_HEIGHT);
		self:SetHeight(newHeight);
	elseif ( self.animState == BB_STATE_LOOT_INSERT and self.showingTooltip ) then
		-- keep it at 2 seconds left
		self.animTimeLeft = 2;
	end
	if ( self.animTimeLeft <= 0 ) then
		BossBanner_SetAnimState(self, self.animState + 1);
		if ( not self.animTimeLeft ) then
			self.animState = nil;
		end
	end
end

function BossBanner_OnLoad(self)
	RegisterCVar("PraiseTheSun");
	self.PlayBanner = BossBanner_Play;
	self.StopBanner = BossBanner_Stop;
	self:RegisterEvent("BOSS_KILL");
	self:RegisterEvent("ENCOUNTER_LOOT_RECEIVED");
	self.pendingLoot = { };
	self.baseHeight = self:GetHeight();
end

function BossBanner_OnEvent(self, event, ...)
	if ( event == "BOSS_KILL" ) then
		wipe(self.pendingLoot);
		local encounterID, name = ...;
		TopBannerManager_Show(self, { encounterID = encounterID, name = name, mode = "KILL" });
	elseif ( event == "ENCOUNTER_LOOT_RECEIVED" ) then
		local encounterID, itemID, itemLink, quantity, playerName, className = ...;
		local _, instanceType = GetInstanceInfo();
		if ( encounterID == self.encounterID and (instanceType == "party" or instanceType == "raid") ) then
			-- add loot to pending list
			local data = { itemID = itemID, quantity = quantity, playerName = playerName, className = className, itemLink = itemLink };
			tinsert(self.pendingLoot, data);
			-- check state
			if ( self.animState == BB_STATE_LOOT_INSERT and self.lootShown < BB_MAX_LOOT ) then
				-- show it now
				BossBanner_SetAnimState(self, BB_STATE_LOOT_EXPAND);
			elseif ( not self.animState and self.lootShown == 0 ) then
				-- banner is not displaying and have not done loot for this encounter yet
				-- TODO: animate in kill banner
				TopBannerManager_Show(self, { encounterID = encounterID, name = nil, mode = "LOOT" });
			end
		end
	end
end

function BossBanner_OnLootItemEnter(self)
	-- no tooltip when banner is animating out
	if ( BossBanner.animState ~= BB_STATE_BANNER_OUT ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetHyperlink(self:GetParent().itemLink);
		GameTooltip:Show();
		BossBanner.showingTooltip = true;
	end
end

function BossBanner_OnLootItemLeave(self)
	GameTooltip:Hide();
	BossBanner.showingTooltip = false;
end

function BossBanner_Play(self, data)
	if ( data ) then
		if ( data.mode == "KILL" ) then
			if ( GetCVarBool("PraiseTheSun") ) then
				self.Title:SetText(BOSS_YOU_DEFEATED);
				self.SubTitle:Hide();
			else
				self.Title:SetText(data.name);
				self.SubTitle:Show();
			end
			self.Title:Show();
			self:Show();
			self.encounterID = data.encounterID;
			BossBanner_BeginAnims(self);
			PlaySound(SOUNDKIT.UI_RAID_BOSS_DEFEATED);
		elseif ( data.mode == "LOOT" ) then
			if(C_Loot.IsLegacyLootModeEnabled()) then
				return
			end
			self.BannerTop:SetAlpha(1);
			self.BannerBottom:SetAlpha(1);
			self.BannerMiddle:SetAlpha(1);
			self.RightFillagree:SetAlpha(1);
			self.LeftFillagree:SetAlpha(1);
			self.BottomFillagree:SetAlpha(1);
			self.SkullSpikes:SetAlpha(1);
			self.SkullCircle:SetAlpha(0);
			self.LootCircle:SetAlpha(1);
			self.Title:Hide();
			self.SubTitle:Hide();
			self:Show();
			BossBanner_BeginAnims(self, BB_STATE_LOOT_EXPAND);
			PlaySound(SOUNDKIT.UI_PERSONAL_LOOT_BANNER);
		end
	end
end

function BossBanner_Stop(self)
	self.AnimIn:Stop();
	self.AnimSwitch:Stop();
	self.AnimOut:Stop();
	self:Hide();
end

function BossBanner_OnAnimOutFinished(self)
	local banner = self:GetParent();
	banner.animState = nil;
	banner:Hide();
	banner:SetHeight(banner.baseHeight);
	banner.BannerTop:SetAlpha(0);
	banner.BannerBottom:SetAlpha(0);
	banner.BannerMiddle:SetAlpha(0);
	banner.BottomFillagree:SetAlpha(0);
	banner.SkullSpikes:SetAlpha(0);
	banner.RightFillagree:SetAlpha(0);
	banner.LeftFillagree:SetAlpha(0);
	banner.Title:SetAlpha(0);
	banner.SubTitle:SetAlpha(0);
	banner.FlashBurst:SetAlpha(0);
	banner.FlashBurstLeft:SetAlpha(0);
	banner.FlashBurstCenter:SetAlpha(0);
	banner.RedFlash:SetAlpha(0);
	for i = 1, #banner.LootFrames do
		banner.LootFrames[i]:Hide();
	end
	TopBannerManager_BannerFinished();
end