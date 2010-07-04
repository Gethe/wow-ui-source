
LEVEL_UP_EVENTS = {
--  Level  = {unlock}
	[10] = {"TalentsUnlocked", "BGsUnlocked"},
	[15] = {"LFDUnlocked", "GlyphMajor"},
	[20] = {"Riding75"},
	[30] = {"GlyphMajor"},
	[40] = {"Riding150", "DuelSpec"},
	[50] = {"GlyphMinor"},
	[60] = {"Riding225"},
	[70] = {"Riding300", "GlyphMinor"},
	[80] = {"GlyphMajor"},
}

SUBICON_TEXCOOR_BOOK 	= {0.64257813, 0.72070313, 0.03710938, 0.11132813};
SUBICON_TEXCOOR_LOCK		= {0.64257813, 0.70117188, 0.11523438, 0.18359375};
SUBICON_TEXCOOR_ARROW 	= {0.72460938, 0.78320313, 0.03710938, 0.10351563};

LEVEL_UP_TYPES = {
	["TalentPoint"] 		= {	icon="Interface\\Icons\\Ability_Marksmanship",
										subIcon=SUBICON_TEXCOOR_ARROW,
										text=LEVEL_UP_TALENT_MAIN,
										subText=LEVEL_UP_TALENT_SUB,
										link=LEVEL_UP_TALENTPOINT_LINK;
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


	["Riding75"] 				= {	icon="Interface\\Icons\\Spell_Nature_Swiftness",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GetSpellInfo(33388),
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..GetSpellLink(33388)
									},


	["Riding150"] 				= {	icon="Interface\\Icons\\Spell_Nature_Swiftness",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GetSpellInfo(33391),
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..GetSpellLink(33391)
									},


	["Riding225"] 				= {	icon="Interface\\Icons\\Ability_Rogue_Sprint",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GetSpellInfo(34090),
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..GetSpellLink(34090)
									},


	["Riding300"] 				= {	icon="Interface\\Icons\\Ability_Rogue_Sprint",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GetSpellInfo(34091),
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..GetSpellLink(34091)
									},


	["Riding375"] 				= {	icon="Interface\\Icons\\Spell_Frost_SummonWaterElemental",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=GetSpellInfo(33391),
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2.." "..GetSpellLink(33388)
									},

	["DuelSpec"] 			= {	icon="Interface\\Icons\\INV_Misc_Coin_01",
										subIcon=SUBICON_TEXCOOR_LOCK,
										text=LEVEL_UP_DUALSPEC,
										subText=LEVEL_UP_FEATURE,
										link=LEVEL_UP_FEATURE2..LEVEL_UP_DUAL_SPEC_LINK
									}
}



function LevelUpDisplay_Onload(self)	
	self:RegisterEvent("PLAYER_LEVEL_UP");
end



function LevelUpDisplay_OnEvent(self, event, ...)
	if event ==  "PLAYER_LEVEL_UP" then
		local level = ...
		self.player_level = level;
		self:Show();
		LevelUpDisplaySide:Hide();
	end
end

function LevelUpDisplay_BuildList(self)
	self.unlockList = {}
	if  self.player_level > 10 then	
		self.unlockList[#self.unlockList +1] = 	LEVEL_UP_TYPES["TalentPoint"]
	end
	
	local spells = {GetCurrentLevelSpells(self.player_level)};
	for _,spell in pairs(spells) do		
		local name, _, icon = GetSpellInfo(spell);
		self.unlockList[#self.unlockList +1] = { text = name, subText = LEVEL_UP_ABILITY, icon = icon, subIcon = SUBICON_TEXCOOR_BOOK,
																link=LEVEL_UP_ABILITY2.." "..GetSpellLink(spell)
															};
	end	
	
	
	if LEVEL_UP_EVENTS[self.player_level] then
		for _, unlockType in pairs(LEVEL_UP_EVENTS[self.player_level]) do
			self.unlockList[#self.unlockList +1] = LEVEL_UP_TYPES[unlockType];
		end
	end
	
	self.currSpell = 1;
end


function LevelUpDisplay_OnShow(self)
	LevelUpDisplay_BuildList(self);
	self.levelFrame.levelText:SetFormattedText(LEVEL_GAINED,self.player_level);
	self.levelFrame.levelUp:Play();
end


function LevelUpDisplay_AnimStep(self)
	if self.currSpell > #self.unlockList then
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

function LevelUpDisplay_ShowSideDisplay(level)
	if LevelUpDisplaySide.player_level and LevelUpDisplaySide.player_level == level then
		if LevelUpDisplaySide:IsVisible() then		
			LevelUpDisplaySide:Hide();	
		else	
			LevelUpDisplaySide:Show();
		end
	else
		LevelUpDisplaySide.player_level = level;	
		LevelUpDisplaySide:Hide();
		LevelUpDisplaySide:Show();
	end
end


function LevelUpDisplaySide_OnShow(self)
	LevelUpDisplay_BuildList(self);
	self.levelText:SetFormattedText(LEVEL_GAINED,self.player_level);
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
function LevelUpDisplay_ChatPrint(self, level)
	local info = ChatTypeInfo["SYSTEM"];
	local levelstring = format(LEVEL_UP, level, level);
	local chatLevelUP = {player_level = level};
	LevelUpDisplay_BuildList(chatLevelUP)
	self:AddMessage(levelstring, info.r, info.g, info.b, info.id);
	for _,skill in pairs(chatLevelUP.unlockList) do
		self:AddMessage(skill.link, info.r, info.g, info.b, info.id);
	end
	
	if level == 15 then
		self:AddMessage(LEVEL_UP_GLYPH2_LINK, info.r, info.g, info.b, info.id);
	end
end



