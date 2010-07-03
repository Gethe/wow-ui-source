
StaticPopupDialogs["CONFIRM_LEARN_PREVIEW_TALENTS"] = {
	text = CONFIRM_LEARN_PREVIEW_TALENTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		LearnPreviewTalents(PlayerTalentFrame.pet);
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

UIPanelWindows["PlayerTalentFrame"] = { area = "left", pushable = 6, whileDead = 1, xoffset = 16, width = 605, height = 580 };


-- global constants
TALENTS_TAB = 1;
PET_TALENTS_TAB = 2;
GLYPH_TALENT_TAB = 3;
NUM_TALENT_FRAME_TABS = 3;


-- speed references
local next = next;
local ipairs = ipairs;

-- local data
local specs = {
	["spec1"] = {
		name = TALENT_SPEC_PRIMARY,
		nameActive = TALENT_SPEC_PRIMARY_ACTIVE,
		glyphName = TALENT_SPEC_PRIMARY_GLYPH,
		glyphNameActive = TALENT_SPEC_PRIMARY_GLYPH_ACTIVE,
		talentGroup = 1,
		tooltip = TALENT_SPEC_PRIMARY,
		portraitUnit = "player",
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
		hasGlyphs = true,
	},
	["spec2"] = {
		name = TALENT_SPEC_SECONDARY,
		nameActive = TALENT_SPEC_SECONDARY_ACTIVE,
		glyphName = TALENT_SPEC_SECONDARY_GLYPH,
		glyphNameActive = TALENT_SPEC_SECONDARY_GLYPH_ACTIVE,
		talentGroup = 2,
		tooltip = TALENT_SPEC_SECONDARY,
		portraitUnit = "player",
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
		hasGlyphs = true,
	},
};

local masteryInfo = {
	["default"] = {
		[1] = {
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			color = {r=0.3, g=0.5, b=1.0},
		}
	},
	
	["DEATHKNIGHT"] = {
		[1] = {
			-- Blood
			spellId = 77513,
			color = {r=1.0, g=0.0, b=0.0},
		},
		[2] = {
			-- Frost
			spellId = 77514,
			color = {r=0.3, g=0.5, b=1.0},
		},
		[3] = {
			-- Unholy
			spellId = 77515,
			color = {r=0.8, g=0.0, b=1.0},
		}
	},
	
	["DRUID"] = {
		[1] = {
			-- Balance
			spellId = 77492;
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			-- Feral
			spellId = 77493, -- Cat
			spellId2 = 77494, -- Bear
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Restoration
			spellId = 77495,
			color = {r=0.3, g=0.5, b=1.0},
		}	
	},
	
	["HUNTER"] = {
		[1] = {
			-- Beast Mastery
			spellId = 76657,
			color = {r=0.3, g=0.0, b=1.0},
		},
		[2] = {
			-- Marksmanship
			spellId = 76659,
			color = {r=0.8, g=0.2, b=0.8},
		},
		[3] = {
			-- Survival
			spellId = 76658,
			color = {r=0.0, g=1.0, b=0.6},
		}
	},
	
	["MAGE"] = {
		[1] = {
			-- Arcane
			spellId = 76547,
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			-- Fire
			spellId = 76595,
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Frost
			spellId = 76613,
			color = {r=0.3, g=0.5, b=1.0},
		}
	},
	
	["PALADIN"] = {
		[1] = {
			-- Holy
			spellId = 76669,
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			-- Protection
			spellId = 76671,
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Retribution
			spellId = 76672,
			color = {r=0.3, g=0.5, b=1.0},
		}
	},
	
	["PRIEST"] = {
		[1] = {
			-- Discipline
			spellId = 77484,
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			-- Holy
			spellId = 77485,
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Shadow
			spellId = 77486,
			color = {r=0.3, g=0.5, b=1.0},
		}
	},
	
	["ROGUE"] = {
		[1] = {
			-- Assassination
			spellId = 76803,
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			-- Combat
			spellId = 76806,
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Subtlety
			spellId = 76808,
			color = {r=0.3, g=0.5, b=1.0},
		}
	},
	
	["SHAMAN"] = {
		[1] = {
			-- Elemental
			spellId = 77222,
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			-- Enhancement
			spellId = 77223,
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Restoration
			spellId = 77226,
			color = {r=0.3, g=0.5, b=1.0},
		}
	},
	
	["WARLOCK"] = {
		[1] = {
			-- Affliction
			spellId = 77215,
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			-- Demonology
			spellId = 77219,
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Destruction
			spellId = 77220,
			color = {r=0.3, g=0.5, b=1.0},
		}
	},
	
	["WARRIOR"] = {
		[1] = {
			-- Arms
			spellId = 76838,
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			-- Fury
			spellId = 76856,
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Protection
			spellId = 76857,
			color = {r=0.3, g=0.5, b=1.0},
		}
	},
	
	["PET_409"] = {
		-- Tenacity
		[1] = {
			color = {r=1.0, g=0.1, b=1.0},
		}
	},
	
	["PET_410"] = {
		-- Ferocity
		[1] = {
			color = {r=1.0, g=0.0, b=0.0},
		}
	},
	
	["PET_411"] = {
		-- Cunning
		[1] = {
			color = {r=0.0, g=0.6, b=1.0},
		}
	},
};

local specTabs = { };	-- filled in by PlayerSpecTab_OnLoad
local numSpecTabs = 0;
local selectedSpec = nil;
local activeSpec = nil;


-- cache talent info so we can quickly display cool stuff like the number of points spent in each tab
local talentSpecInfoCache = {
	["spec1"]		= { },
	["spec2"]		= { },
};
-- cache talent tab widths so we can resize tabs to fit for localization
local talentTabWidthCache = { };

-- ACTIVESPEC_DISPLAYTYPE values:
-- "BLUE", "GOLD_INSIDE", "GOLD_BACKGROUND"
local ACTIVESPEC_DISPLAYTYPE = nil;

-- SELECTEDSPEC_DISPLAYTYPE values:
-- "BLUE", "GOLD_INSIDE", "PUSHED_OUT", "PUSHED_OUT_CHECKED"
local SELECTEDSPEC_DISPLAYTYPE = "GOLD_INSIDE";
local SELECTEDSPEC_OFFSETX;
if ( SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT" or SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT_CHECKED" ) then
	SELECTEDSPEC_OFFSETX = 5;
else
	SELECTEDSPEC_OFFSETX = 0;
end


-- PlayerTalentFrame

function PlayerTalentFrame_Toggle(pet, suggestedTalentGroup)
	local hidden;
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if ( not PlayerTalentFrame:IsShown() ) then
		ShowUIPanel(PlayerTalentFrame);
		hidden = false;
	else
		local spec = selectedSpec and specs[selectedSpec];
		if ( spec and (selectedTab == TALENTS_TAB) and not pet ) then
			-- if a talent tab is selected then toggle the frame off
			HideUIPanel(PlayerTalentFrame);
			hidden = true;
		else
			hidden = false;
		end
	end
	if ( not hidden ) then
		-- open the spec with the requested talent group (or the current talent group if the selected
		-- spec has one)
		for _, index in ipairs(TALENT_SORT_ORDER) do
			local spec = specs[index];
			if (spec.talentGroup == suggestedTalentGroup ) then
				PlayerSpecTab_OnClick(specTabs[index]);
				if ( not talentTabSelected ) then
					PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENTS_TAB]);
				end
				break;
			end
		end
		
		-- Select either the Talents tab or the Pet Talents tab as appropriate
		if (pet and selectedTab ~= PET_TALENTS_TAB) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..PET_TALENTS_TAB]);
		elseif (not pet and selectedTab ~= TALENTS_TAB) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENTS_TAB]);
		end		
	end
end

function PlayerTalentFrame_Open(talentGroup)
	ShowUIPanel(PlayerTalentFrame);

	-- Show the talents tab
	PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENTS_TAB]);
	
	-- open the spec with the requested talent group
	for index, spec in next, specs do
		if ( spec.talentGroup == talentGroup ) then
			PlayerSpecTab_OnClick(specTabs[index]);
			break;
		end
	end
end

function PlayerTalentFrame_ToggleGlyphFrame(suggestedTalentGroup)
	GlyphFrame_LoadUI();
	if ( GlyphFrame ) then
		local hidden;
		if ( not PlayerTalentFrame:IsShown() ) then
			ShowUIPanel(PlayerTalentFrame);
			hidden = false;
		else
			local spec = selectedSpec and specs[selectedSpec];
			if ( spec and spec.hasGlyphs and
				 PanelTemplates_GetSelectedTab(PlayerTalentFrame) == GLYPH_TALENT_TAB ) then
				-- if the glyph tab is selected then toggle the frame off
				HideUIPanel(PlayerTalentFrame);
				hidden = true;
			else
				hidden = false;
			end
		end
		if ( not hidden ) then
			-- open the spec with the requested talent group (or the current talent group if the selected
			-- spec has one)
			if ( selectedSpec ) then
				local spec = specs[selectedSpec];
				if ( spec.hasGlyphs ) then
					suggestedTalentGroup = spec.talentGroup;
				end
			end
			for _, index in ipairs(TALENT_SORT_ORDER) do
				local spec = specs[index];
				if ( spec.hasGlyphs and spec.talentGroup == suggestedTalentGroup ) then
					PlayerSpecTab_OnClick(specTabs[index]);
					PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..GLYPH_TALENT_TAB]);
					break;
				end
			end
		end
	end
end

function PlayerTalentFrame_OpenGlyphFrame(talentGroup)
	GlyphFrame_LoadUI();
	if ( GlyphFrame ) then
		ShowUIPanel(PlayerTalentFrame);
		-- open the spec with the requested talent group
		for index, spec in next, specs do
			if ( spec.hasGlyphs and spec.talentGroup == talentGroup ) then
				PlayerSpecTab_OnClick(specTabs[index]);
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..GLYPH_TALENT_TAB]);
				break;
			end
		end
	end
end

function PlayerTalentFrame_ShowGlyphFrame()
	GlyphFrame_LoadUI();
	if ( GlyphFrame ) then
		-- show/update the glyph frame
		if ( GlyphFrame:IsShown() ) then
			GlyphFrame_Update();
		else
			GlyphFrame:Show();
		end
	end
end

function PlayerTalentFrame_HideGlyphFrame()
	if ( not GlyphFrame or not GlyphFrame:IsShown() ) then
		return;
	end

	GlyphFrame_LoadUI();
	if ( GlyphFrame ) then
		GlyphFrame:Hide();
	end
end

function PlayerTalentFrame_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED");
	self:RegisterEvent("PREVIEW_PET_TALENT_POINTS_CHANGED");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PET_TALENT_UPDATE");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterEvent("MASTERY_UPDATE");
	self.inspect = false;
	self.pet = false;
	self.talentGroup = 1;

	-- setup tabs
	PanelTemplates_SetNumTabs(self, NUM_TALENT_FRAME_TABS);
	
	-- setup portrait texture
	SetPortraitToTexture(PlayerTalentFramePortrait, "Interface\\Icons\\Ability_Marksmanship");
	
	-- initialize active spec
	PlayerTalentFrame_UpdateActiveSpec(GetActiveTalentGroup(false, false));

	-- setup active spec highlight
	if ( ACTIVESPEC_DISPLAYTYPE == "BLUE" ) then
		PlayerTalentFrameActiveSpecTabHighlight:SetDrawLayer("OVERLAY");
		PlayerTalentFrameActiveSpecTabHighlight:SetBlendMode("ADD");
		PlayerTalentFrameActiveSpecTabHighlight:SetTexture("Interface\\Buttons\\UI-Button-Outline");
	elseif ( ACTIVESPEC_DISPLAYTYPE == "GOLD_INSIDE" ) then
		PlayerTalentFrameActiveSpecTabHighlight:SetDrawLayer("OVERLAY");
		PlayerTalentFrameActiveSpecTabHighlight:SetBlendMode("ADD");
		PlayerTalentFrameActiveSpecTabHighlight:SetTexture("Interface\\Buttons\\CheckButtonHilight");
	elseif ( ACTIVESPEC_DISPLAYTYPE == "GOLD_BACKGROUND" ) then
		PlayerTalentFrameActiveSpecTabHighlight:SetDrawLayer("BACKGROUND");
		PlayerTalentFrameActiveSpecTabHighlight:SetWidth(74);
		PlayerTalentFrameActiveSpecTabHighlight:SetHeight(86);
		PlayerTalentFrameActiveSpecTabHighlight:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab-Glow");
	end
end

function PlayerTalentFrame_OnShow(self)
	-- Stop buttons from flashing after skill up
	SetButtonPulse(TalentMicroButton, 0, 1);

	PlaySound("TalentScreenOpen");
	UpdateMicroButtons();
	PlayerTalentFramePetModel:SetUnit("pet");

	if ( not selectedSpec ) then
		-- if no spec was selected, try to select the active one
		PlayerSpecTab_OnClick(activeSpec and specTabs[activeSpec] or specTabs[DEFAULT_TALENT_SPEC]);
	else
		PlayerTalentFrame_Refresh();
	end

	-- Set flag
	if ( not GetCVarBool("talentFrameShown") ) then
		SetCVar("talentFrameShown", 1);
	end
end

function PlayerTalentFrame_OnHide()
	UpdateMicroButtons();
	PlaySound("TalentScreenClose");
	-- clear caches
	for _, info in next, talentSpecInfoCache do
		wipe(info);
	end
	wipe(talentTabWidthCache);
end

function PlayerTalentFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "PLAYER_TALENT_UPDATE" or event == "PET_TALENT_UPDATE" ) then
		PlayerTalentFrame_Refresh();
	elseif ( event == "PREVIEW_TALENT_POINTS_CHANGED" ) then
		--local talentIndex, tabIndex, groupIndex, points = ...;
		PlayerTalentFrame_Refresh();
	elseif ( event == "PREVIEW_PET_TALENT_POINTS_CHANGED" ) then
		PlayerTalentFrame_Refresh();
	elseif ( (event == "UNIT_PET" and arg1 == "player") or (event == "UNIT_MODEL_CHANGED" and arg1 == "pet") ) then
		local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
		if ( selectedTab and selectedTab == PET_TALENTS_TAB ) then
			local numTalentGroups = GetNumTalentGroups(false, true);
			if ( numTalentGroups == 0 ) then
				-- If the player has the Pet Talents, and a pet spec is not available, select the default talents tab
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENTS_TAB]);
				return;
			end
		end
		PlayerTalentFramePetModel:SetUnit("pet");
		PlayerTalentFrame_Refresh();
	elseif ( event == "PLAYER_LEVEL_UP" ) then
		if ( selectedSpec ) then
			local level = ...;
			PlayerTalentFrame_Update(level);
		end
	elseif ( event == "ACTIVE_TALENT_GROUP_CHANGED" ) then
		MainMenuBar_ToPlayerArt(MainMenuBarArtFrame);
	elseif (event == "MASTERY_UPDATE") then
		PlayerTalentFrame_UpdateMastery(self);
	end
end

function PlayerTalentFrame_CalculateMasteryTree(self)
	local id1, name1, icon1, pointsSpent1, background1, previewPointsSpent1 = GetTalentTabInfo(1, self.inspect, self.pet, self.talentGroup);
	local id2, name2, icon2, pointsSpent2, background2, previewPointsSpent2 = GetTalentTabInfo(2, self.inspect, self.pet, self.talentGroup);
	local id3, name3, icon3, pointsSpent3, background3, previewPointsSpent3 = GetTalentTabInfo(3, self.inspect, self.pet, self.talentGroup);
	
	local masteryTree = 1;
	local pointsSpent = pointsSpent1 + previewPointsSpent1;
	if (pointsSpent2+previewPointsSpent2 > pointsSpent) then
		pointsSpent = pointsSpent2+previewPointsSpent2;
		masteryTree = 2;
	end
	
	if (pointsSpent3+previewPointsSpent3 > pointsSpent) then
		pointsSpent = pointsSpent3+previewPointsSpent3;
		masteryTree = 3;
	end
	
	if (pointsSpent > 0) then
		return masteryTree;	
	end
end

function PlayerTalentFrame_CalculateMasteryBonuses(spellId, pointsSpent)
	if (spellId) then
		local MAX_TALENT_POINTS_TOWARDS_MASTERY = 51;
		local spellAuraDesc = GetSpellAuraDescription(spellId);
		local pointsPerLevel1, pointsPerLevel2, pointsPerLevel3 = GetSpellEffectPointsPerLevel(spellId);
		local pointsPerMastery1, pointsPerMastery2, pointsPerMastery3 = GetSpellEffectBonusCoefficient(spellId);
		local masteryStat = GetMastery();
		pointsSpent = min(pointsSpent, MAX_TALENT_POINTS_TOWARDS_MASTERY);

		-- Parse out the mastery names
		local masteryName1, space, masteryName2, space2, masteryName3;		
		if (spellAuraDesc) then
			masteryName1, space, masteryName2, space2, masteryName3 = strsplit("\r\n", spellAuraDesc);
		end
		
		-- Calculate the final value for each mastery
		local value1, value2, value3;
		if (pointsPerLevel1) then
			value1 = pointsSpent * pointsPerLevel1 + masteryStat * pointsPerMastery1;
		end
		if (pointsPerLevel2) then
			value2 = pointsSpent * pointsPerLevel2 + masteryStat * pointsPerMastery2;
		end
		if (pointsPerLevel3) then
			value3 = pointsSpent * pointsPerLevel3 + masteryStat * pointsPerMastery3;
		end
		
		return masteryName1, value1, masteryName2, value2, masteryName3, value3;
	end
end

function PlayerTalentFrame_UpdateMastery(self)
	local classDisplayName, class = UnitClass("player");
	local masteryTree = PlayerTalentFrame_CalculateMasteryTree(self);
	local mastery;
	
	if (not self.pet) then
		mastery = masteryInfo[class] or masteryInfo["default"];
	end
	
	if (mastery and masteryTree and mastery[masteryTree]) then
		local id, name, icon, pointsSpent, background, previewPointsSpent = GetTalentTabInfo(masteryTree, self.inspect, self.pet, self.talentGroup);
		local masteryName = {};
		local masteryValue = {};
		
		-- Calculate all mastery names/values
		masteryName[1], masteryValue[1], masteryName[2], masteryValue[2], masteryName[3], masteryValue[3] = PlayerTalentFrame_CalculateMasteryBonuses(mastery[masteryTree].spellId, pointsSpent+previewPointsSpent);
		if (mastery[masteryTree].spellId2) then
			masteryName[4], masteryValue[4], masteryName[5], masteryValue[5], masteryName[6], masteryValue[6] = PlayerTalentFrame_CalculateMasteryBonuses(mastery[masteryTree].spellId2, pointsSpent+previewPointsSpent);
		end
		
		-- Show the mastery icon
		if (icon) then
			PlayerTalentFrameMasteryIcon:Show();
			PlayerTalentFrameMasteryIcon:SetTexture(icon);
		else
			PlayerTalentFrameMasteryIcon:Hide();
		end
		
		-- Show Mastery backgrounds
		PlayerTalentFrameMastery1Bg:Show();
		PlayerTalentFrameMastery2Bg:Show();
		PlayerTalentFrameMastery3Bg:Show();
		
		-- Show all Mastery text
		for i=1,6 do
			local masteryText = _G["PlayerTalentFrameMastery"..i];
			if (masteryName[i] and masteryValue[i]) then
				masteryText:Show();
				masteryText.Text:SetFormattedText("%s\: %s%.2f%s", masteryName[i], HIGHLIGHT_FONT_COLOR_CODE, masteryValue[i], FONT_COLOR_CODE_CLOSE);
			else
				masteryText:Hide();
			end
			
			-- Make the mastery text show the correct tooltip
			if (i <= 3) then
				masteryText.spellId = mastery[masteryTree].spellId;
			else
				masteryText.spellId = mastery[masteryTree].spellId2;
			end
			
			-- If this is part of the second row of mastery bonuses (e.g. Feral druids), shift the first row up
			if (i > 3) then
				if (masteryName[i] and masteryValue[i]) then
					_G["PlayerTalentFrameMastery"..(i-3)]:SetPoint("TOPLEFT", "PlayerTalentFrameMastery"..(i-3).."Bg", "TOPLEFT", 4, -3);
				else
					_G["PlayerTalentFrameMastery"..(i-3)]:SetPoint("TOPLEFT", "PlayerTalentFrameMastery"..(i-3).."Bg", "TOPLEFT", 4, -9);
				end
			end
		end
		
		-- Set the background color	
		if (mastery and mastery[masteryTree] and mastery[masteryTree].color) then
			PlayerTalentFrameMasteryPaneBackground:SetVertexColor(mastery[masteryTree].color.r, mastery[masteryTree].color.g, mastery[masteryTree].color.b);
		else
			PlayerTalentFrameMasteryPaneBackground:SetVertexColor(1, 1, 1);
		end
		
		-- Change the appearance to link the borders with the tree that has mastery
		_G["PlayerTalentFramePanel"..masteryTree]:LinkWithMasteryPane();

	else
		-- No mastery
		PlayerTalentFrameMastery1:Hide();
		PlayerTalentFrameMastery2:Hide();
		PlayerTalentFrameMastery3:Hide();
		PlayerTalentFrameMastery4:Hide();
		PlayerTalentFrameMastery5:Hide();
		PlayerTalentFrameMastery6:Hide();
		PlayerTalentFrameMastery1Bg:Hide();
		PlayerTalentFrameMastery2Bg:Hide();
		PlayerTalentFrameMastery3Bg:Hide();
		PlayerTalentFrameMasteryIcon:Hide();
		PlayerTalentFramePanel1:UnlinkWithMasteryPane();
		PlayerTalentFramePanel2:UnlinkWithMasteryPane();
		PlayerTalentFramePanel3:UnlinkWithMasteryPane();
		PlayerTalentFrameMasteryPaneBackground:SetVertexColor(0, 0, 0);
	end
end

function PlayerTalentFrame_ShowTalentTab()
	PlayerTalentFramePanel1:Show();
	PlayerTalentFramePanel2:Show();
	PlayerTalentFramePanel3:Show();
	PlayerTalentFrameMasteryPane:Show();
end

function PlayerTalentFrame_HideTalentTab()
	PlayerTalentFramePanel1:Hide();
	PlayerTalentFramePanel2:Hide();
	PlayerTalentFramePanel3:Hide();
	PlayerTalentFrameMasteryPane:Hide();
end

function PlayerTalentFrame_ShowPetTalentTab()
	PlayerTalentFramePetModel:Show();
	PlayerTalentFramePetInfo:Show();
	PlayerTalentFramePetModelBg:Show();
	PlayerTalentFramePetPanel:Show();
end

function PlayerTalentFrame_HidePetTalentTab()
	PlayerTalentFramePetModel:Hide();
	PlayerTalentFramePetInfo:Hide();
	PlayerTalentFramePetModelBg:Hide();
	PlayerTalentFramePetPanel:Hide();
end

function PlayerTalentFrame_Refresh()
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if ( selectedTab == GLYPH_TALENT_TAB ) then
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_HidePetTalentTab();
		PlayerTalentFrame_ShowGlyphFrame();
		PlayerTalentFrameUnspentPoints:Hide();
		PlayerTalentFrameUnspentPointsLabel:Hide();
		PlayerTalentFrameUnspentPointsBg:Hide();
		PlayerTalentFrame.pet = false;
	elseif (selectedTab == PET_TALENTS_TAB) then
		PlayerTalentFrame_HideGlyphFrame();
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_ShowPetTalentTab();
		PlayerTalentFrameUnspentPoints:Show();
		PlayerTalentFrameUnspentPointsLabel:Show();
		PlayerTalentFrameUnspentPointsBg:Show();
		PlayerTalentFrame.pet = true;
	else
		PlayerTalentFrame_HideGlyphFrame();
		PlayerTalentFrame_HidePetTalentTab();
		PlayerTalentFrame_ShowTalentTab();
		PlayerTalentFrameUnspentPoints:Show();
		PlayerTalentFrameUnspentPointsLabel:Show();
		PlayerTalentFrameUnspentPointsBg:Show();
		PlayerTalentFrame.pet = false;
	end
	
	PlayerTalentFrame_UpdateMastery(PlayerTalentFrame);
	PlayerTalentFrame_Update();
	
	local talentPoints = GetUnspentTalentPoints(false, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
	local unspentPoints = talentPoints - GetGroupPreviewTalentPointsSpent(PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
	PlayerTalentFrameUnspentPointsLabel:SetText(PLAYER_UNSPENT_TALENT_POINTS);
	PlayerTalentFrameUnspentPoints:SetText(unspentPoints);
	
	if (PlayerTalentFramePanel1:IsShown()) then
		PlayerTalentFramePanel_Update(PlayerTalentFramePanel1);
	end
	if (PlayerTalentFramePanel2:IsShown()) then
		PlayerTalentFramePanel_Update(PlayerTalentFramePanel2);
	end
	if (PlayerTalentFramePanel3:IsShown()) then
		PlayerTalentFramePanel_Update(PlayerTalentFramePanel3);
	end
	if (PlayerTalentFramePetPanel:IsShown()) then
		PlayerTalentFramePanel_Update(PlayerTalentFramePetPanel);
	end
end

function PlayerTalentFrame_Update(playerLevel)
	local activeTalentGroup, numTalentGroups = GetActiveTalentGroup(false, PlayerTalentFrame.pet), GetNumTalentGroups(false, PlayerTalentFrame.pet);
	
	-- update specs
	if ( not PlayerTalentFrame_UpdateSpecs(activeTalentGroup, numTalentGroups) ) then
		-- the current spec is not selectable any more, discontinue updates
		return;
	end

	-- update tabs
	if ( not PlayerTalentFrame_UpdateTabs(playerLevel) ) then
		-- the current spec is not selectable any more, discontinue updates
		return;
	end
	
	-- set the active spec
	PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup);

	-- update title text
	PlayerTalentFrame_UpdateTitleText(numTalentGroups);

	-- update talent controls
	PlayerTalentFrame_UpdateControls(activeTalentGroup, numTalentGroups);
	
	-- update pet info
	if (PlayerTalentFrame.pet) then
		PlayerTalentFrame_UpdatePetInfo(PlayerTalentFrame);
	end
	
	if (selectedSpec == activeSpec) then
		PlayerTalentFrameTitleGlowLeft:Show();
		PlayerTalentFrameTitleGlowRight:Show();
		PlayerTalentFrameTitleGlowCenter:Show();
	else
		PlayerTalentFrameTitleGlowLeft:Hide();
		PlayerTalentFrameTitleGlowRight:Hide();
		PlayerTalentFrameTitleGlowCenter:Hide();
	end
end

function PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup)
	activeSpec = DEFAULT_TALENT_SPEC;
	for index, spec in next, specs do
		if (spec.talentGroup == activeTalentGroup ) then
			activeSpec = index;
			break;
		end
	end
end

function PlayerTalentFrame_UpdateTitleText(numTalentGroups)

	local spec = selectedSpec and specs[selectedSpec];
	local hasMultipleTalentGroups = numTalentGroups > 1;
	local isActiveSpec = (selectedSpec == activeSpec);
	
	if (PanelTemplates_GetSelectedTab(PlayerTalentFrame) == GLYPH_TALENT_TAB) then
		if ( spec and spec.glyphName and hasMultipleTalentGroups ) then
			if (isActiveSpec and spec.glyphNameActive) then
				PlayerTalentFrameTitleText:SetText(spec.glyphNameActive);
			else
				PlayerTalentFrameTitleText:SetText(spec.glyphName);
			end
		else
			PlayerTalentFrameTitleText:SetText(GLYPHS);
		end
	elseif (PanelTemplates_GetSelectedTab(PlayerTalentFrame) == PET_TALENTS_TAB) then
		PlayerTalentFrameTitleText:SetText(TALENT_SPEC_PET_PRIMARY);
	else	
		if ( spec and hasMultipleTalentGroups ) then
			if (isActiveSpec and spec.nameActive) then
				PlayerTalentFrameTitleText:SetText(spec.nameActive);
			else
				PlayerTalentFrameTitleText:SetText(spec.name);
			end
		else
			PlayerTalentFrameTitleText:SetText(TALENTS);
		end
	end
	
end

function PlayerTalentFrame_UpdatePetInfo(self)
	if (self.pet) then
		if ( UnitCreatureFamily("pet") ) then
			PlayerTalentFramePetTypeText:SetText(UnitCreatureFamily("pet"));
		else
			PlayerTalentFramePetTypeText:SetText("");
		end
		
		if (UnitLevel("pet")) then
			PlayerTalentFramePetLevelText:SetFormattedText(UNIT_LEVEL_TEMPLATE, UnitLevel("pet"));
		else
			PlayerTalentFramePetLevelText:SetText("");
		end
		
		if ( UnitName("pet") ) then
			PlayerTalentFramePetNameText:SetText(UnitName("pet"));
		else
			PlayerTalentFramePetNameText:SetText("");
		end
		
		PlayerTalentFramePetIcon:SetTexture(GetPetIcon());
		
		local happiness, damagePercentage = GetPetHappiness();
		if ( happiness ) then
			PlayerTalentFramePetHappiness:Show();
			if ( happiness == 1 ) then
				PlayerTalentFramePetHappinessTexture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
			elseif ( happiness == 2 ) then
				PlayerTalentFramePetHappinessTexture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
			elseif ( happiness == 3 ) then
				PlayerTalentFramePetHappinessTexture:SetTexCoord(0, 0.1875, 0, 0.359375);
			end
			PlayerTalentFramePetHappiness.tooltip = _G["PET_HAPPINESS"..happiness];
			PlayerTalentFramePetHappiness.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage);
		else
			PlayerTalentFramePetHappiness:Hide();
		end
		
		local nextPetTalentLevel = GetNextPetTalentLevel();
		if (nextPetTalentLevel and nextPetTalentLevel <= MAX_PLAYER_LEVEL) then
			PlayerTalentFrameNextPetTalentString:SetFormattedText(PET_NEXT_TALENT_LEVEL, nextPetTalentLevel);
			PlayerTalentFrameNextPetTalentString:Show();
		else
			PlayerTalentFrameNextPetTalentString:Hide();
		end
	end
end

-- PlayerTalentFramePanel

function PlayerTalentFramePanel_OnLoad(self)
	self.inspect = false;
	self.talentGroup = 1;
	self.talentButtonSize = 30;
	self.initialOffsetX = 17;
	self.initialOffsetY = 36;
	self.buttonSpacingX = 39;
	self.buttonSpacingY = 35;
	self.arrowInsetX = 2;
	self.arrowInsetY = 2;
	self.LinkWithMasteryPane = PlayerTalentFramePanel_LinkWithMasteryPane;
	self.UnlinkWithMasteryPane = PlayerTalentFramePanel_UnlinkWithMasteryPane;

	TalentFrame_Load(self);
end

function PlayerTalentFramePanel_Update(self)
	local id, name, icon, pointsSpent, background, previewPointsSpent = GetTalentTabInfo(self.talentTree, self.inspect, self.pet, self.talentGroup);
	self.PointsSpent:SetText(pointsSpent+previewPointsSpent);
	if (self.PointsSpentLarge) then
		self.PointsSpentLarge:SetText(pointsSpent+previewPointsSpent);
	end
	self.Name:SetText(name);
	if (self.NameLarge) then
		self.NameLarge:SetText(name);
	end
	
	local mastery;
	if (self.pet) then
		mastery = masteryInfo["PET_"..id];
	else
		local classDisplayName, class = UnitClass("player");
		mastery = masteryInfo[class] or masteryInfo["default"];
	end
	
	local color = mastery and mastery[self.talentTree] and mastery[self.talentTree].color;
	if (color) then
		self.HeaderBackgroundSmall:SetVertexColor(color.r, color.g, color.b);
		if (self.HeaderBackgroundLarge) then
			self.HeaderBackgroundLarge:SetVertexColor(color.r, color.g, color.b);
		end
	else
		self.HeaderBackgroundSmall:SetVertexColor(1, 1, 1);
		if (self.HeaderBackgroundLarge) then
			self.HeaderBackgroundLarge:SetVertexColor(1, 1, 1);
		end
	end
	
	TalentFrame_Update(self);
end

function PlayerTalentFramePanel_LinkWithMasteryPane(self)
	-- If this tree is already linked, do nothing
	if (PlayerTalentFrameMasteryPane.linkedTree == self.talentTree) then
		return;
	end	
	
	-- Unlink currently linked pane
	if (PlayerTalentFrameMasteryPane.linkedTree) then
		_G["PlayerTalentFramePanel"..PlayerTalentFrameMasteryPane.linkedTree]:UnlinkWithMasteryPane();
	end
	
	PlayerTalentFrameMasteryPane.linkedTree = self.talentTree;
	self.HeaderBackgroundLarge:Show();
	self.HeaderBorderLarge:Show();
	self.HeaderBackgroundSmall:Hide();
	self.HeaderBorderSmall:Hide();
	self.BorderTopLeft:Hide();
	self.BorderTopRight:Hide();
	self.BorderTop:Hide();
	self.Name:Hide();
	self.NameLarge:Show();
	self.PointsSpent:Hide();
	self.PointsSpentLarge:Show();
	if (self.position == "LEFT") then
		self.ConnectorR:Show();
		self.BorderLeft:SetPoint("TOPLEFT", PlayerTalentFrameMasteryPane.BorderTopLeft, "BOTTOMLEFT");
		self.BorderRight:SetPoint("TOPRIGHT", self.ConnectorR, "BOTTOMRIGHT", -9, 0);
		PlayerTalentFrameMasteryPane.BorderBottomLeft:Hide();
		PlayerTalentFrameMasteryPane.BorderLeft:Hide();
		PlayerTalentFrameMasteryPane.BorderBottom:Hide();
		PlayerTalentFrameMasteryPane.BorderBottom2:Show();
		PlayerTalentFrameMasteryPane.BorderBottom2:SetPoint("BOTTOMLEFT", self.ConnectorR, "BOTTOMRIGHT", 0, 8);
	elseif (self.position == "MIDDLE") then
		self.ConnectorL:Show();
		self.ConnectorR:Show();
		self.BorderLeft:SetPoint("TOPLEFT", self.ConnectorL, "BOTTOMLEFT", 9, 0);
		self.BorderRight:SetPoint("TOPRIGHT", self.ConnectorR, "BOTTOMRIGHT", -9, 0);
		PlayerTalentFrameMasteryPane.BorderBottom:SetPoint("BOTTOMRIGHT", self.ConnectorL, "BOTTOMLEFT");
		PlayerTalentFrameMasteryPane.BorderBottom2:Show();
		PlayerTalentFrameMasteryPane.BorderBottom2:SetPoint("BOTTOMLEFT", self.ConnectorR, "BOTTOMRIGHT", 0, 8);
	elseif (self.position == "RIGHT") then
		self.ConnectorL:Show();
		self.BorderLeft:SetPoint("TOPLEFT", self.ConnectorL, "BOTTOMLEFT", 9, 0);
		self.BorderRight:SetPoint("TOPRIGHT", PlayerTalentFrameMasteryPane.BorderTopRight, "BOTTOMRIGHT");
		PlayerTalentFrameMasteryPane.BorderBottomRight:Hide();
		PlayerTalentFrameMasteryPane.BorderRight:Hide();
		PlayerTalentFrameMasteryPane.BorderBottom:SetPoint("BOTTOMRIGHT", self.ConnectorL, "BOTTOMLEFT");
	end
end

function PlayerTalentFramePanel_UnlinkWithMasteryPane(self)
	if (PlayerTalentFrameMasteryPane.linkedTree == self.talentTree) then
		self.Name:Show();
		self.NameLarge:Hide();
		self.PointsSpent:Show();
		self.PointsSpentLarge:Hide();
		self.ConnectorL:Hide();
		self.ConnectorR:Hide();
		self.HeaderBackgroundLarge:Hide();
		self.HeaderBorderLarge:Hide();
		self.HeaderBackgroundSmall:Show();
		self.HeaderBorderSmall:Show();
		self.BorderTopLeft:Show();
		self.BorderTopRight:Show();
		self.BorderTop:Show();
		self.BorderLeft:SetPoint("TOPLEFT", self.BorderTopLeft, "BOTTOMLEFT");
		self.BorderRight:SetPoint("TOPRIGHT", self.BorderTopRight, "BOTTOMRIGHT");
		PlayerTalentFrameMasteryPane.linkedTree = nil;
		PlayerTalentFrameMasteryPane.BorderBottomLeft:Show();
		PlayerTalentFrameMasteryPane.BorderLeft:Show();
		PlayerTalentFrameMasteryPane.BorderBottomRight:Show();
		PlayerTalentFrameMasteryPane.BorderRight:Show();
		PlayerTalentFrameMasteryPane.BorderBottom:Show();
		PlayerTalentFrameMasteryPane.BorderBottom:SetPoint("BOTTOMRIGHT", PlayerTalentFrameMasteryPane.BorderBottomRight, "BOTTOMLEFT");
		PlayerTalentFrameMasteryPane.BorderBottom2:Hide();
	end
end

-- PlayerTalentFrameTalents

function PlayerTalentFrameTalent_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetTalentLink(self:GetParent().talentTree, self:GetID(),
			PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalents"));
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	elseif ( selectedSpec and (activeSpec == selectedSpec) ) then
		-- only allow functionality if an active spec is selected
		if ( button == "LeftButton" ) then
			if ( GetCVarBool("previewTalents") ) then
				AddPreviewTalentPoints(self:GetParent().talentTree, self:GetID(), 1, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			else
				LearnTalent(self:GetParent().talentTree, self:GetID(), PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			end
		elseif ( button == "RightButton" ) then
			if ( GetCVarBool("previewTalents") ) then
				AddPreviewTalentPoints(self:GetParent().talentTree, self:GetID(), -1, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			end
		end
	end
end

function PlayerTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(self:GetParent().talentTree, self:GetID(),
			PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalents"));
	end
end

function PlayerTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	
	GameTooltip:SetTalent(self:GetParent().talentTree, self:GetID(),
		PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalents"));
end


-- Controls

function PlayerTalentFrame_UpdateControls(activeTalentGroup, numTalentGroups)
	local spec = selectedSpec and specs[selectedSpec];

	local isActiveSpec = selectedSpec == activeSpec;

	-- show the activate button if this is not the active spec
	PlayerTalentFrameActivateButton_Update(numTalentGroups);

	local preview = GetCVarBool("previewTalents");

	-- enable the control bar if this is the active spec, preview is enabled, and preview points were spent
	local talentTabSelected = PanelTemplates_GetSelectedTab(PlayerTalentFrame) == TALENTS_TAB;
	local petTalentTabSelected = PanelTemplates_GetSelectedTab(PlayerTalentFrame) == PET_TALENTS_TAB;
	local talentPoints = GetUnspentTalentPoints(false, PlayerTalentFrame.pet, spec.talentGroup);
	if ( isActiveSpec and talentPoints > 0 and preview and (talentTabSelected or petTalentTabSelected) ) then
		
		--ButtonFrameTemplate_ShowButtonBar(PlayerTalentFrame);
		PlayerTalentFrameLearnButton:Show();
		PlayerTalentFrameResetButton:Show();
		
		-- enable accept/cancel buttons if preview talent points were spent
		if ( GetGroupPreviewTalentPointsSpent(PlayerTalentFrame.pet, spec.talentGroup) > 0 ) then
			PlayerTalentFrameLearnButton:Enable();
			PlayerTalentFrameResetButton:Enable();
		else
			PlayerTalentFrameLearnButton:Disable();
			PlayerTalentFrameResetButton:Disable();
		end
		-- squish all frames to make room for this bar
		--PlayerTalentFramePointsBar:SetPoint("BOTTOM", PlayerTalentFramePreviewBar, "TOP", 0, -4);
	else
		--ButtonFrameTemplate_HideButtonBar(PlayerTalentFrame);
		PlayerTalentFrameLearnButton:Hide();
		PlayerTalentFrameResetButton:Hide();
		-- unsquish frames since the bar is now hidden
		--PlayerTalentFramePointsBar:SetPoint("BOTTOM", PlayerTalentFrame, "BOTTOM", 0, 81);
	end
end

function PlayerTalentFrameActivateButton_OnLoad(self)
	self:SetWidth(self:GetTextWidth() + 40);
	MagicButton_OnLoad(self);
end

function PlayerTalentFrameActivateButton_OnClick(self)
	if ( selectedSpec ) then
		local talentGroup = specs[selectedSpec].talentGroup;
		if ( talentGroup ) then
			SetActiveTalentGroup(talentGroup);
		end
	end
end

function PlayerTalentFrameActivateButton_OnShow(self)
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function PlayerTalentFrameActivateButton_OnHide(self)
	self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function PlayerTalentFrameActivateButton_OnEvent(self, event, ...)
	local numTalentGroups = GetNumTalentGroups(false, PlayerTalentFrame.pet);
	PlayerTalentFrameActivateButton_Update(numTalentGroups);
end

function PlayerTalentFrameActivateButton_Update(numTalentGroups)
	local spec = selectedSpec and specs[selectedSpec];
	if (numTalentGroups > 1) then
		PlayerTalentFrameActivateButton:Show();
		if ((selectedSpec == activeSpec) or IsCurrentSpell(TALENT_ACTIVATION_SPELLS[spec.talentGroup])) then
			PlayerTalentFrameActivateButton:Disable();
		else
			PlayerTalentFrameActivateButton:Enable();
		end
	else
		PlayerTalentFrameActivateButton:Hide();
	end
end

function PlayerTalentFrameResetButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(TALENT_TOOLTIP_RESETTALENTGROUP);
end

function PlayerTalentFrameResetButton_OnClick(self)
	ResetGroupPreviewTalentPoints(PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
end

function PlayerTalentFrameLearnButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(TALENT_TOOLTIP_LEARNTALENTGROUP);
end

function PlayerTalentFrameLearnButton_OnClick(self)
	StaticPopup_Show("CONFIRM_LEARN_PREVIEW_TALENTS");
end


-- PlayerTalentFrameTab

function PlayerTalentFrame_UpdateTabs(playerLevel)
	local totalTabWidth = 0;
	local firstShownTab = _G["PlayerTalentFrameTab"..TALENTS_TAB];
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	local numVisibleTabs = 0;

	-- setup talent tab
	talentTabWidthCache[TALENTS_TAB] = 0;
	tab = _G["PlayerTalentFrameTab"..TALENTS_TAB];
	if ( tab ) then
		tab:Show();
		firstShownTab = firstShownTab or tab;
		PanelTemplates_TabResize(tab, 0);
		talentTabWidthCache[TALENTS_TAB] = PanelTemplates_GetTabWidth(tab);
		totalTabWidth = totalTabWidth + talentTabWidthCache[TALENTS_TAB];
		numVisibleTabs = numVisibleTabs+1;
	end
	
	-- setup pet talents tab
	talentTabWidthCache[PET_TALENTS_TAB] = 0;
	tab = _G["PlayerTalentFrameTab"..PET_TALENTS_TAB];
	local petTalentGroups = GetNumTalentGroups(false, true);
	if ( tab and petTalentGroups > 0 and HasPetUI()) then
		tab:Show();
		firstShownTab = firstShownTab or tab;
		PanelTemplates_TabResize(tab, 0);
		talentTabWidthCache[PET_TALENTS_TAB] = PanelTemplates_GetTabWidth(tab);
		totalTabWidth = totalTabWidth + talentTabWidthCache[PET_TALENTS_TAB];
		numVisibleTabs = numVisibleTabs+1;
	else
		tab:Hide();
		talentTabWidthCache[PET_TALENTS_TAB] = 0;
	end

	-- setup glyph tab
	local spec = specs[selectedSpec];
	playerLevel = playerLevel or UnitLevel("player");
	local meetsGlyphLevel = playerLevel >= SHOW_INSCRIPTION_LEVEL;
	tab = _G["PlayerTalentFrameTab"..GLYPH_TALENT_TAB];
	if ( meetsGlyphLevel and spec.hasGlyphs ) then
		tab:Show();
		firstShownTab = firstShownTab or tab;
		PanelTemplates_TabResize(tab, 0);
		talentTabWidthCache[GLYPH_TALENT_TAB] = PanelTemplates_GetTabWidth(tab);
		totalTabWidth = totalTabWidth + talentTabWidthCache[GLYPH_TALENT_TAB];
		numVisibleTabs = numVisibleTabs+1;
	else
		tab:Hide();
		talentTabWidthCache[GLYPH_TALENT_TAB] = 0;
	end

	-- select the first shown tab if the selected tab does not exist for the selected spec
	tab = _G["PlayerTalentFrameTab"..selectedTab];
	if ( tab and not tab:IsShown() ) then
		if ( firstShownTab ) then
			PlayerTalentFrameTab_OnClick(firstShownTab);
		end
		return false;
	end

	-- readjust tab sizes to fit
	local maxTotalTabWidth = PlayerTalentFrame:GetWidth();
	while ( totalTabWidth >= maxTotalTabWidth ) do
		-- progressively shave 10 pixels off of the largest tab until they all fit within the max width
		local largestTab = 1;
		for i = 2, #talentTabWidthCache do
			if ( talentTabWidthCache[largestTab] < talentTabWidthCache[i] ) then
				largestTab = i;
			end
		end
		-- shave the width
		talentTabWidthCache[largestTab] = talentTabWidthCache[largestTab] - 10;
		-- apply the shaved width
		tab = _G["PlayerTalentFrameTab"..largestTab];
		PanelTemplates_TabResize(tab, 0, talentTabWidthCache[largestTab]);
		-- now update the total width
		totalTabWidth = totalTabWidth - 10;
	end
	
	-- Reposition the visible tabs
	local x = 15;
	for i=1, NUM_TALENT_FRAME_TABS do
		tab = _G["PlayerTalentFrameTab"..i];
		if (tab:IsShown()) then
			tab:ClearAllPoints();
			tab:SetPoint("TOPLEFT", PlayerTalentFrame, "BOTTOMLEFT", x, 1);
			x = x+talentTabWidthCache[i]-15;
		end
	end
	
	-- update the tabs
	PanelTemplates_UpdateTabs(PlayerTalentFrame);

	return true;
end

function PlayerTalentFrameTab_OnLoad(self)
	self:SetFrameLevel(self:GetFrameLevel() + 2);
end

function PlayerTalentFrameTab_OnClick(self)
	local id = self:GetID();
	PanelTemplates_SetTab(PlayerTalentFrame, id);
	PlayerTalentFrame_Refresh();
	PlaySound("igCharacterInfoTab");
end

function PlayerTalentFrameTab_OnEnter(self)
	if ( self.textWidth and self.textWidth > self:GetFontString():GetWidth() ) then	--We're ellipsizing.
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
		GameTooltip:SetText(self:GetText());
	end
end


-- PlayerTalentTab

function PlayerTalentTab_OnLoad(self)
	PlayerTalentFrameTab_OnLoad(self);

	self:RegisterEvent("PLAYER_LEVEL_UP");
end

function PlayerTalentTab_OnClick(self)
	PlayerTalentFrameTab_OnClick(self);
	SetButtonPulse(self, 0, 0);
end

function PlayerTalentTab_OnEvent(self, event, ...)
	if ( UnitLevel("player") == (SHOW_TALENT_LEVEL - 1) and PanelTemplates_GetSelectedTab(PlayerTalentFrame) ~= self:GetID() ) then
		SetButtonPulse(self, 60, 0.75);
	end
end

-- PlayerGlyphTab

function PlayerGlyphTab_OnLoad(self)
	PlayerTalentFrameTab_OnLoad(self);

	self:RegisterEvent("PLAYER_LEVEL_UP");
	GLYPH_TALENT_TAB = self:GetID();
	-- we can record the text width for the glyph tab now since it never changes
	self.textWidth = self:GetTextWidth();
end

function PlayerGlyphTab_OnClick(self)
	PlayerTalentFrameTab_OnClick(self);
	SetButtonPulse(_G["PlayerTalentFrameTab"..GLYPH_TALENT_TAB], 0, 0);
end

function PlayerGlyphTab_OnEvent(self, event, ...)
	if ( UnitLevel("player") == (SHOW_INSCRIPTION_LEVEL - 1) and PanelTemplates_GetSelectedTab(PlayerTalentFrame) ~= self:GetID() ) then
		SetButtonPulse(self, 60, 0.75);
	end
end


-- Specs

-- PlayerTalentFrame_UpdateSpecs is a helper function for PlayerTalentFrame_Update.
-- Returns true on a successful update, false otherwise. An update may fail if the currently
-- selected tab is no longer selectable. In this case, the first selectable tab will be selected.
function PlayerTalentFrame_UpdateSpecs(activeTalentGroup, numTalentGroups)
	-- set the active spec highlight to be hidden initially, if a spec is the active one then it will
	-- be shown in PlayerSpecTab_Update
	PlayerTalentFrameActiveSpecTabHighlight:Hide();

	-- update each of the spec tabs
	local firstShownTab, lastShownTab;
	local numShown = 0;
	local offsetX = 0;
	for i = 1, numSpecTabs do
		local frame = _G["PlayerSpecTab"..i];
		local specIndex = frame.specIndex;
		local spec = specs[specIndex];
		if ( PlayerSpecTab_Update(frame, activeTalentGroup, numTalentGroups) ) then
			firstShownTab = firstShownTab or frame;
			numShown = numShown + 1;
			frame:ClearAllPoints();
			-- set an offsetX fudge if we're the selected tab, otherwise use the previous offsetX
			offsetX = specIndex == selectedSpec and SELECTEDSPEC_OFFSETX or offsetX;
			if ( numShown == 1 ) then
				--...start the first tab off at a base location
				frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPRIGHT", offsetX, -65);
				-- we'll need to negate the offsetX after the first tab so all subsequent tabs offset
				-- to their default positions
				offsetX = -offsetX;
			else
				--...offset subsequent tabs from the previous one
				frame:SetPoint("TOPLEFT", lastShownTab, "BOTTOMLEFT", 0 + offsetX, -22);
			end
			lastShownTab = frame;
		else
			-- if the selected tab is not shown then clear out the selected spec
			if ( specIndex == selectedSpec ) then
				selectedSpec = nil;
			end
		end
	end

	if ( not selectedSpec ) then
		if ( firstShownTab ) then
			PlayerSpecTab_OnClick(firstShownTab);
		end
		return false;
	end

	if ( numShown == 1 and lastShownTab ) then
		-- if we're only showing one tab, we might as well hide it since it doesn't need to be there
		lastShownTab:Hide();
	end

	return true;
end

function PlayerSpecTab_Update(self, activeTalentGroup, numTalentGroups)
	local specIndex = self.specIndex;
	local spec = specs[specIndex];

	-- determine whether or not we need to hide the tab
	local canShow = spec.talentGroup <= numTalentGroups;

	if ( not canShow ) then
		self:Hide();
		return false;
	end

	local isSelectedSpec = specIndex == selectedSpec;
	local isActiveSpec = spec.talentGroup == activeTalentGroup;
	local normalTexture = self:GetNormalTexture();

	-- set the background based on whether or not we're selected
	if ( isSelectedSpec and (SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT" or SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT_CHECKED") ) then
		local name = self:GetName();
		local backgroundTexture = _G[name.."Background"];
		backgroundTexture:SetTexture("Interface\\TalentFrame\\UI-TalentFrame-SpecTab");
		backgroundTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -13, 11);
		if ( SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT_CHECKED" ) then
			self:GetCheckedTexture():Show();
		else
			self:GetCheckedTexture():Hide();
		end
	else
		local name = self:GetName();
		local backgroundTexture = _G[name.."Background"];
		backgroundTexture:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab");
		backgroundTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 11);
	end

	-- update the active spec info
	local hasMultipleTalentGroups = numTalentGroups > 1;
	if ( isActiveSpec and hasMultipleTalentGroups ) then
		PlayerTalentFrameActiveSpecTabHighlight:ClearAllPoints();
		if ( ACTIVESPEC_DISPLAYTYPE == "BLUE" ) then
			PlayerTalentFrameActiveSpecTabHighlight:SetParent(self);
			PlayerTalentFrameActiveSpecTabHighlight:SetPoint("TOPLEFT", self, "TOPLEFT", -13, 14);
			PlayerTalentFrameActiveSpecTabHighlight:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 15, -14);
			PlayerTalentFrameActiveSpecTabHighlight:Show();
		elseif ( ACTIVESPEC_DISPLAYTYPE == "GOLD_INSIDE" ) then
			PlayerTalentFrameActiveSpecTabHighlight:SetParent(self);
			PlayerTalentFrameActiveSpecTabHighlight:SetAllPoints(self);
			PlayerTalentFrameActiveSpecTabHighlight:Show();
		elseif ( ACTIVESPEC_DISPLAYTYPE == "GOLD_BACKGROUND" ) then
			PlayerTalentFrameActiveSpecTabHighlight:SetParent(self);
			PlayerTalentFrameActiveSpecTabHighlight:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 20);
			PlayerTalentFrameActiveSpecTabHighlight:Show();
		else
			PlayerTalentFrameActiveSpecTabHighlight:Hide();
		end
	end

	-- update the spec info cache
	TalentFrame_UpdateSpecInfoCache(talentSpecInfoCache[specIndex], false, PlayerTalentFrame.pet, spec.talentGroup);

	-- update spec tab icon
	self.usingPortraitTexture = false;
	if ( hasMultipleTalentGroups ) then
		local specInfoCache = talentSpecInfoCache[specIndex];
		local primaryTabIndex = specInfoCache.primaryTabIndex;
		if ( primaryTabIndex > 0 ) then
			-- the spec had a primary tab, set the icon to that tab's icon
			normalTexture:SetTexture(specInfoCache[primaryTabIndex].icon);
		else
			if ( specInfoCache.numTabs > 1 and specInfoCache.totalPointsSpent > 0 ) then
				-- the spec is only considered a hybrid if the spec had more than one tab and at least
				-- one point was spent in one of the tabs
				normalTexture:SetTexture(TALENT_HYBRID_ICON);
			else
				if ( spec.defaultSpecTexture ) then
					-- the spec is probably untalented...set to the default spec texture if we have one
					normalTexture:SetTexture(spec.defaultSpecTexture);
				elseif ( spec.portraitUnit ) then
					-- last check...if there is no default spec texture, try the portrait unit
					SetPortraitTexture(normalTexture, spec.portraitUnit);
					self.usingPortraitTexture = true;
				end
			end
		end
	else
		if ( spec.portraitUnit ) then
			-- set to the portrait texture if we only have one talent group
			SetPortraitTexture(normalTexture, spec.portraitUnit);
			self.usingPortraitTexture = true;
		end
	end

	self:Show();
	return true;
end

function PlayerSpecTab_Load(self, specIndex)
	self.specIndex = specIndex;
	specTabs[specIndex] = self;
	numSpecTabs = numSpecTabs + 1;

	-- set the spec's portrait
	local spec = specs[self.specIndex];
	if ( spec.portraitUnit ) then
		SetPortraitTexture(self:GetNormalTexture(), spec.portraitUnit);
		self.usingPortraitTexture = true;
	else
		self.usingPortraitTexture = false;
	end

	-- set the checked texture
	if ( SELECTEDSPEC_DISPLAYTYPE == "BLUE" ) then
		local checkedTexture = self:GetCheckedTexture();
		checkedTexture:SetTexture("Interface\\Buttons\\UI-Button-Outline");
		checkedTexture:SetWidth(64);
		checkedTexture:SetHeight(64);
		checkedTexture:ClearAllPoints();
		checkedTexture:SetPoint("CENTER", self, "CENTER", 0, 0);
	elseif ( SELECTEDSPEC_DISPLAYTYPE == "GOLD_INSIDE" ) then
		local checkedTexture = self:GetCheckedTexture();
		checkedTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight");
	end

	local activeTalentGroup, numTalentGroups = GetActiveTalentGroup(false, false), GetNumTalentGroups(false, false);
	PlayerSpecTab_Update(self, activeTalentGroup, numTalentGroups);
end

function PlayerSpecTab_OnClick(self)
	-- set all specs as unchecked initially
	for _, frame in next, specTabs do
		frame:SetChecked(nil);
	end

	-- check ourselves (before we wreck ourselves)
	self:SetChecked(1);

	-- update the selected to this spec
	local specIndex = self.specIndex;
	selectedSpec = specIndex;

	-- set data on the talent frame
	local spec = specs[specIndex];
	PlayerTalentFrame.talentGroup = spec.talentGroup;
	PlayerTalentFramePanel1.talentGroup = spec.talentGroup;
	PlayerTalentFramePanel2.talentGroup = spec.talentGroup;
	PlayerTalentFramePanel3.talentGroup = spec.talentGroup;

	-- select a tab if one is not already selected
	if ( not PanelTemplates_GetSelectedTab(PlayerTalentFrame) ) then
		PanelTemplates_SetTab(PlayerTalentFrame, TALENTS_TAB);
	end

	-- update the talent frame
	PlayerTalentFrame_Refresh();
end

function PlayerSpecTab_OnEnter(self)
	local specIndex = self.specIndex;
	local spec = specs[specIndex];
	if ( spec.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		-- name
		if ( GetNumTalentGroups(false, true) <= 1 and GetNumTalentGroups(false, false) <= 1 ) then
			-- set the tooltip to be the unit's name
			GameTooltip:AddLine(UnitName("player"), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		else
			-- set the tooltip to be the spec name
			GameTooltip:AddLine(spec.tooltip);
			if ( self.specIndex == activeSpec ) then
				-- add text to indicate that this spec is active
				GameTooltip:AddLine(TALENT_ACTIVE_SPEC_STATUS, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
			end
		end
		-- points spent
		local pointsColor;
		for index, info in ipairs(talentSpecInfoCache[specIndex]) do
			if ( info.name ) then
				-- assign a special color to a tab that surpasses the max points spent threshold
				if ( talentSpecInfoCache[specIndex].primaryTabIndex == index ) then
					pointsColor = GREEN_FONT_COLOR;
				else
					pointsColor = HIGHLIGHT_FONT_COLOR;
				end
				GameTooltip:AddDoubleLine(
					info.name,
					info.pointsSpent,
					HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
					pointsColor.r, pointsColor.g, pointsColor.b,
					1
				);
			end
		end
		GameTooltip:Show();
	end
end

