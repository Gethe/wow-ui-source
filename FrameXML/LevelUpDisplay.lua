LEVEL_UP_TYPE_CHARACTER = "character";	--Name used in globalstring LEVEL_UP
LEVEL_UP_TYPE_GUILD = "guild";	--Name used in globalstring GUILD_LEVEL_UP
LEVEL_UP_TYPE_PET = "pet" -- Name used in globalstring PET_LEVEL_UP

LEVEL_UP_EVENTS = {
--  Level  = {unlock}
	[10] = {"TalentsUnlocked", "BGsUnlocked"},
	[15] = {"LFDUnlocked",},
	[25] = {"GlyphPrime"},--,"GlyphMajor", "GlyphMinor"},
	[40] = {"DuelSpec"},
	[50] = {"GlyphPrime"},--,"GlyphMajor", "GlyphMinor"},
	[75] = {"GlyphPrime"},--,"GlyphMajor", "GlyphMinor"},
}

SUBICON_TEXCOOR_BOOK 	= {0.64257813, 0.72070313, 0.03710938, 0.11132813};
SUBICON_TEXCOOR_LOCK		= {0.64257813, 0.70117188, 0.11523438, 0.18359375};
SUBICON_TEXCOOR_ARROW 	= {0.72460938, 0.78320313, 0.03710938, 0.10351563};

local levelUpTexCoords = {
	[LEVEL_UP_TYPE_CHARACTER] = {
		dot = { 0.64257813, 0.68359375, 0.18750000, 0.23046875 },
		goldBG = { 0.56054688, 0.99609375, 0.24218750, 0.46679688 },
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
	},
	[LEVEL_UP_TYPE_GUILD] = {
		dot = { 0.64257813, 0.68359375, 0.77734375, 0.8203125 },
		goldBG = { 0.56054688, 0.99609375, 0.486328125, 0.7109375 },
		gLine = { 0.00195313, 0.81835938, 0.96484375, 0.97851563 },
		textTint = {0.11765, 1, 0},
	},
	[LEVEL_UP_TYPE_PET] = {
		dot = { 0.64257813, 0.68359375, 0.18750000, 0.23046875 },
		goldBG = { 0.56054688, 0.99609375, 0.24218750, 0.46679688 },
		gLine = { 0.00195313, 0.81835938, 0.01953125, 0.03320313 },
		tint = {1, 0.5, 0.25},
		textTint = {1, 0.7, 0.25},
	},
}

LEVEL_UP_TYPES = {
	["TalentPoint"] 		= {	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_ARROW,
										text=LEVEL_UP_TALENT_MAIN,
										subText=LEVEL_UP_TALENT_SUB,
										link=LEVEL_UP_TALENTPOINT_LINK;
									},
	
	["PetTalentPoint"] 		= {	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_ARROW,
										text=PET_LEVEL_UP_TALENT_MAIN,
										subText=PET_LEVEL_UP_TALENT_SUB,
										link=PET_LEVEL_UP_TALENTPOINT_LINK;
									},
									
	["TalentsUnlocked"] 	= {	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=TALENT_POINTS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_TALENTS_LINK
									},
									
	["BGsUnlocked"] 		= {	icon="Interface\\Icons\\Ability_DualWield",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=BATTLEFIELDS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_BG_LINK
									},

	["LFDUnlocked"] 		= {	icon="Interface\\Icons\\LevelUpIcon-LFD",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=LOOKING_FOR_DUNGEON,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_LFD_LINK
									},

	["GlyphPrime"] 				= {	icon="Interface\\Icons\\Inv_inscription_tradeskill01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GLYPHS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_GLYPH3_LINK
									},

	["GlyphMajor"] 				= {	icon="Interface\\Icons\\Inv_inscription_tradeskill01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GLYPHS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_GLYPH1_LINK
									},

	["GlyphMinor"] 				= {	icon="Interface\\Icons\\Inv_inscription_tradeskill01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GLYPHS,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_GLYPH2_LINK
									},


	["DuelSpec"] 			= {	icon="Interface\\Icons\\INV_Misc_Coin_01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=LEVEL_UP_DUALSPEC,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_DUAL_SPEC_LINK
									},


------ HACKS BELOW		
 ------ HACKS BELOW		
 ------ HACKS BELOW
 
 	["Teleports"] 			= {	icon="Interface\\Icons\\INV_Misc_Coin_01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=LEVEL_UP_DUALSPEC,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_DUAL_SPEC_LINK
									},
									
 	["LockMount1"] 			= {	spellID=5784	},
 	["LockMount2"] 			= {	spellID=23161	},
 	["PaliMount1"] 			= {	spellID=34769	},
 	["PaliMount2"] 			= {	spellID=34767	},
 	["PaliMountTauren1"] 			= {	spellID=69820	},
 	["PaliMountTauren2"] 			= {	spellID=69826	},
 	["PaliMountDraenei1"] 			= {	spellID=73629	},
 	["PaliMountDraenei2"] 			= {	spellID=73630	},
 	
	
	
	["Plate"] 			= {	spellID=750, feature=true},
	["Mail"] 			= {	spellID=8737, feature=true	},
	
	
	
	
	
	["TrackBeast"] 			= {	spellID=1494  },
	["TrackHumanoid"] 			= {	spellID=19883  },
	["TrackUndead"] 			= {	spellID=19884  },
	["TrackHidden"] 			= {	spellID=19885  },
	["TrackElemental"] 			= {	spellID=19880  },
	["TrackDemons"] 			= {	spellID=19878 },
	["TrackGiants"] 			= {	spellID=19882  },
	["TrackDragonkin"] 			= {	spellID=19879  },
	
 

 ------ END HACKS
}




LEVEL_UP_CLASS_HACKS = {
	
	["MAGE"] 		= {
							--  Level  = {unlock}
								[24] = {"Teleports"},
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
}


function LevelUpDisplay_Onload(self)	
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("UNIT_GUILD_LEVEL");
	self:RegisterEvent("UNIT_LEVEL");
	self.currSpell = 0;
end



function LevelUpDisplay_OnEvent(self, event, ...)
	local arg1 = ...;
	if event ==  "PLAYER_LEVEL_UP" then
		local level = ...
		self.level = level;
		self.type = LEVEL_UP_TYPE_CHARACTER;
		self:Show();
		LevelUpDisplaySide:Hide();
	elseif event == "UNIT_GUILD_LEVEL" then
		local unit, level = ...;
		if ( unit == "player" ) then
			self.level = level;
			self.type = LEVEL_UP_TYPE_GUILD;
			self:Show();
			LevelUpDisplaySide:Hide();
		end
	elseif event == "UNIT_LEVEL" and arg1 == "pet" then
		self.level = UnitLevel("pet");
		self.type = LEVEL_UP_TYPE_PET;
		self:Show();
		LevelUpDisplaySide:Hide();
	end
end

function LevelUpDisplay_BuildCharacterList(self)
	local name, icon = "","";
	self.unlockList = {};
	if  self.level == GetNextTalentLevel(self.level-1)  then
		self.unlockList[#self.unlockList +1] = 	LEVEL_UP_TYPES["TalentPoint"]
	end
	
	
	local spells = {GetCurrentLevelSpells(self.level)};
	for _,spell in pairs(spells) do		
		name, _, icon = GetSpellInfo(spell);
		self.unlockList[#self.unlockList +1] = { text = name, subText = LEVEL_UP_ABILITY, icon = icon, subIcon = SUBICON_TEXCOOR_BOOK,
																link=LEVEL_UP_ABILITY2.." "..GetSpellLink(spell)
															};
	end	
	
	
		-- This loop is LEVEL_UP_CLASS_HACKS
	local race, file = UnitRace("player");
	local _, class = UnitClass("player");
	local hackTable = LEVEL_UP_CLASS_HACKS[class..race] or LEVEL_UP_CLASS_HACKS[class];
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
		self.unlockList[#self.unlockList +1] = { text = name, subText = LEVEL_UP_FEATURE, icon = icon, subIcon = SUBICON_TEXCOOR_LOCK,
																link=LEVEL_UP_FEATURE2.." "..GetSpellLink(feature)
															};
	end	
	
	
	
	if LEVEL_UP_EVENTS[self.level] then
		for _, unlockType in pairs(LEVEL_UP_EVENTS[self.level]) do
			self.unlockList[#self.unlockList +1] = LEVEL_UP_TYPES[unlockType];
		end
	end
	
	self.currSpell = 1;
end

function LevelUpDisplay_BuildPetList(self)
	local name, icon = "","";
	self.unlockList = {};
	if  self.level == GetNextPetTalentLevel(self.level-1)  then
		self.unlockList[#self.unlockList +1] = 	LEVEL_UP_TYPES["PetTalentPoint"]
	end

	-- TODO: Pet Spells
	
	self.currSpell = 1;
end

function LevelUpDisplay_BuildGuildList(self)
	local name, icon = "", "";
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


function LevelUpDisplay_OnShow(self)
	if  self.currSpell == 0 then
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
		end
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
		
		self.levelFrame.levelUp:Play();
	end
end


function LevelUpDisplay_AnimStep(self)
	if self.currSpell > #self.unlockList then
		self.currSpell = 0;
		self.hideAnim:Play();
	else
		local spellInfo = self.unlockList[self.currSpell];
		self.currSpell = self.currSpell+1;
		self.spellFrame.name:SetText(spellInfo.text);
		self.spellFrame.flavorText:SetText(spellInfo.subText);
		self.spellFrame.icon:SetTexture(spellInfo.icon);
		self.spellFrame.subIcon:SetTexCoord(unpack(spellInfo.subIcon));
		self.spellFrame.showAnim:Play();
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
		displayFrame.sideAnimIn:Play();
		self.currSpell = self.currSpell+1;
		self:SetHeight(self:GetHeight()+45);
	end
end

function LevelUpDisplaySide_Remove()
	LevelUpDisplaySide.fadeOut:Play();
end


-- Chat print function 
function LevelUpDisplay_ChatPrint(self, level, levelUpType)
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
		self:AddMessage(skill.link, info.r, info.g, info.b, info.id);
	end
	
	if levelUpType == LEVEL_UP_TYPE_CHARACTER and (level == 25 or level == 50 or level == 75) then
		self:AddMessage(LEVEL_UP_GLYPH1_LINK, info.r, info.g, info.b, info.id);
		self:AddMessage(LEVEL_UP_GLYPH2_LINK, info.r, info.g, info.b, info.id);
	end
end



