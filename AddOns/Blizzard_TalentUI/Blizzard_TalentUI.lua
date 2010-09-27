
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

UIPanelWindows["PlayerTalentFrame"] = { area = "doublewide", pushable = 6, whileDead = 1, width = 666, height = 488 };


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

local TALENT_INFO = {
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
			color = {r=1.0, g=0.0, b=0.0},
		},
		[2] = {
			-- Frost
			color = {r=0.3, g=0.5, b=1.0},
		},
		[3] = {
			-- Unholy
			color = {r=0.2, g=0.8, b=0.2},
		}
	},
	
	["DRUID"] = {
		[1] = {
			-- Balance
			color = {r=0.8, g=0.3, b=0.8},
		},
		[2] = {
			-- Feral
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Restoration
			color = {r=0.4, g=0.8, b=0.2},
		}	
	},
	
	["HUNTER"] = {
		[1] = {
			-- Beast Mastery
			color = {r=1.0, g=0.0, b=0.3},
		},
		[2] = {
			-- Marksmanship
			color = {r=0.3, g=0.6, b=1.0},
		},
		[3] = {
			-- Survival
			color = {r=1.0, g=0.6, b=0.0},
		}
	},
	
	["MAGE"] = {
		[1] = {
			-- Arcane
			color = {r=0.7, g=0.2, b=1.0},
		},
		[2] = {
			-- Fire
			color = {r=1.0, g=0.5, b=0.0},
		},
		[3] = {
			-- Frost
			color = {r=0.3, g=0.6, b=1.0},
		}
	},
	
	["PALADIN"] = {
		[1] = {
			-- Holy
			color = {r=1.0, g=0.5, b=0.0},
		},
		[2] = {
			-- Protection
			color = {r=0.3, g=0.5, b=1.0},
		},
		[3] = {
			-- Retribution
			color = {r=1.0, g=0.0, b=0.0},
		}
	},
	
	["PRIEST"] = {
		[1] = {
			-- Discipline
			color = {r=1.0, g=0.5, b=0.0},
		},
		[2] = {
			-- Holy
			color = {r=0.6, g=0.6, b=1.0},
		},
		[3] = {
			-- Shadow
			color = {r=0.7, g=0.4, b=0.8},
		}
	},
	
	["ROGUE"] = {
		[1] = {
			-- Assassination
			color = {r=0.5, g=0.8, b=0.5},
		},
		[2] = {
			-- Combat
			color = {r=1.0, g=0.5, b=0.0},
		},
		[3] = {
			-- Subtlety
			color = {r=0.3, g=0.5, b=1.0},
		}
	},
	
	["SHAMAN"] = {
		[1] = {
			-- Elemental
			color = {r=0.8, g=0.2, b=0.8},
		},
		[2] = {
			-- Enhancement
			color = {r=0.3, g=0.5, b=1.0},
		},
		[3] = {
			-- Restoration
			color = {r=0.2, g=0.8, b=0.4},
		}
	},
	
	["WARLOCK"] = {
		[1] = {
			-- Affliction
			color = {r=0.0, g=1.0, b=0.6},
		},
		[2] = {
			-- Demonology
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Destruction
			color = {r=1.0, g=0.5, b=0.0},
		}
	},
	
	["WARRIOR"] = {
		[1] = {
			-- Arms
			color = {r=1.0, g=0.72, b=0.1},
		},
		[2] = {
			-- Fury
			color = {r=1.0, g=0.0, b=0.0},
		},
		[3] = {
			-- Protection
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
		TalentMicroButtonAlert:Hide();
	else
		local spec = selectedSpec and specs[selectedSpec];
		if ( spec and (selectedTab == TALENTS_TAB) and not pet ) then
			-- if a talent tab is selected then toggle the frame off
			HideUIPanel(PlayerTalentFrame);
			hidden = true;
		elseif (selectedTab == PET_TALENTS_TAB and pet) then
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
			GlyphFrame_Update(GlyphFrame);
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
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PET_TALENT_UPDATE");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterEvent("PREVIEW_TALENT_PRIMARY_TREE_CHANGED");
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
	MicroButtonPulseStop(TalentMicroButton);

	PlaySound("igCharacterInfoOpen");
	UpdateMicroButtons();
	PlayerTalentFramePetModel:SetUnit("pet");
	
	PlayerTalentFrameTalents.summariesShownWhenNoPrimary = true;
	PlayerTalentFrameLearnButtonTutorial.hasBeenClosed = false;

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
	PlaySound("igCharacterInfoClose");
	-- clear caches
	for _, info in next, talentSpecInfoCache do
		wipe(info);
	end
	wipe(talentTabWidthCache);
	
	-- If the player has unsaved talent choices, display a warning
	local unsavedChanges = false;

	local numTalentGroups = GetNumTalentGroups(false, false);	
	for i = 1, numTalentGroups do
		if (GetPreviewPrimaryTalentTree(false, false, i) or GetGroupPreviewTalentPointsSpent(false, i) > 0) then
			unsavedChanges = true;
			break;
		end
	end
	
	-- Check pet as well
	if (not unsavedChanges) then
		numTalentGroups = GetNumTalentGroups(false, true);
		for i = 1, numTalentGroups do
			if (GetPreviewPrimaryTalentTree(false, true, i) or GetGroupPreviewTalentPointsSpent(true, i) > 0) then
				unsavedChanges = true;
				break;
			end
		end
	end
	
	if (unsavedChanges) then
		TalentMicroButtonAlertText:SetText(TALENT_MICRO_BUTTON_UNSAVED_CHANGES);
		TalentMicroButtonAlert:SetHeight(TalentMicroButtonAlertText:GetHeight()+42);
		TalentMicroButtonAlert:Show();
	end	
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
	elseif ( event == "PREVIEW_TALENT_PRIMARY_TREE_CHANGED" ) then
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
	elseif ( event == "UNIT_LEVEL") then
		if ( selectedSpec ) then
			local arg1 = ...;
			if (arg1 == "player") then
				PlayerTalentFrame_Update();
				PlayerTalentFramePanel_UpdateSummary(PlayerTalentFramePanel1);
				PlayerTalentFramePanel_UpdateSummary(PlayerTalentFramePanel2);
				PlayerTalentFramePanel_UpdateSummary(PlayerTalentFramePanel3);
			end
		end
	elseif (event == "LEARNED_SPELL_IN_TAB") then
		-- Must update the Mastery bonus if you just learned Mastery
		if (PlayerTalentFramePanel1Summary:IsVisible()) then
			PlayerTalentFramePanel_UpdateSummary(PlayerTalentFramePanel1);
		end
		if (PlayerTalentFramePanel2Summary:IsVisible()) then
			PlayerTalentFramePanel_UpdateSummary(PlayerTalentFramePanel2);
		end
		if (PlayerTalentFramePanel3Summary:IsVisible()) then
			PlayerTalentFramePanel_UpdateSummary(PlayerTalentFramePanel3);
		end
	elseif ( event == "ACTIVE_TALENT_GROUP_CHANGED" ) then
		MainMenuBar_ToPlayerArt(MainMenuBarArtFrame);
	end
end

function PlayerTalentFrame_ShowTalentTab()
	PlayerTalentFrameTalents:Show();
end

function PlayerTalentFrame_HideTalentTab()
	PlayerTalentFrameTalents:Hide();
end

function PlayerTalentFrame_ShowPetTalentTab()
	PlayerTalentFramePetTalents:Show();
end

function PlayerTalentFrame_HidePetTalentTab()
	PlayerTalentFramePetTalents:Hide();
end

function PlayerTalentFrame_Refresh()
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if ( selectedTab == GLYPH_TALENT_TAB ) then
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_HidePetTalentTab();
		PlayerTalentFrame.pet = false;
		PlayerTalentFrame_ShowGlyphFrame();
	elseif (selectedTab == PET_TALENTS_TAB) then
		PlayerTalentFrame_HideGlyphFrame();
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_ShowPetTalentTab();
		PlayerTalentFrame.pet = true;
	else
		PlayerTalentFrame_HideGlyphFrame();
		PlayerTalentFrame_HidePetTalentTab();
		PlayerTalentFrame_ShowTalentTab();
		PlayerTalentFrame.pet = false;
	end
	
	PlayerTalentFrame_Update();
	
	if (PlayerTalentFramePanel1:IsVisible()) then
		PlayerTalentFramePanel_Update(PlayerTalentFramePanel1);
	end
	if (PlayerTalentFramePanel2:IsVisible()) then
		PlayerTalentFramePanel_Update(PlayerTalentFramePanel2);
	end
	if (PlayerTalentFramePanel3:IsVisible()) then
		PlayerTalentFramePanel_Update(PlayerTalentFramePanel3);
	end
	if (PlayerTalentFramePetPanel:IsVisible()) then
		PlayerTalentFramePanel_Update(PlayerTalentFramePetPanel);
	end
end

function PlayerTalentFrame_Update(playerLevel)
	local activeTalentGroup, numTalentGroups = GetActiveTalentGroup(false, PlayerTalentFrame.pet), GetNumTalentGroups(false, PlayerTalentFrame.pet);
	PlayerTalentFrame.primaryTree = GetPreviewPrimaryTalentTree(PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup) 
			or GetPrimaryTalentTree(PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
	
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
	
	if (not PlayerTalentFrame.pet and selectedSpec == activeSpec and numTalentGroups > 1) then
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

function PlayerTalentFrame_ShowOrHideSummaries()
	local shouldShow;
	if (PlayerTalentFrame.primaryTree or GetNumTalentPoints() == 0) then
		shouldShow = PlayerTalentFrameTalents.summariesShownWhenPrimary;
	else
		shouldShow = PlayerTalentFrameTalents.summariesShownWhenNoPrimary;
	end
	
	if (shouldShow) then
		PlayerTalentFramePanel1Summary:Show();
		PlayerTalentFramePanel2Summary:Show();
		PlayerTalentFramePanel3Summary:Show();
		PlayerTalentFrameToggleSummariesButton:SetText(TALENTS_HIDE_SUMMARIES);
	else
		PlayerTalentFramePanel1Summary:Hide();
		PlayerTalentFramePanel2Summary:Hide();
		PlayerTalentFramePanel3Summary:Hide();
		PlayerTalentFrameToggleSummariesButton:SetText(TALENTS_SHOW_SUMMARIES);
	end
	PlayerTalentFramePanel_ShowOrHideHeaderIcon(PlayerTalentFramePanel1);
	PlayerTalentFramePanel_ShowOrHideHeaderIcon(PlayerTalentFramePanel2);
	PlayerTalentFramePanel_ShowOrHideHeaderIcon(PlayerTalentFramePanel3);
	return shouldShow;
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
	end
end

-- PlayerTalentFramePanel

function PlayerTalentFramePanel_OnLoad(self)
	self.inspect = false;
	self.talentGroup = 1;
	self.talentButtonSize = 30;
	self.initialOffsetX = 20;
	self.initialOffsetY = 52;
	self.buttonSpacingX = 46;
	self.buttonSpacingY = 46;
	self.arrowInsetX = 2;
	self.arrowInsetY = 2;
	
	TalentFrame_Load(self);
end

local function PlayerTalentFramePanel_UpdateBonusAbility(bonusFrame, spellId, spellId2, formatString, desaturated)
	local name, subname, icon = GetSpellInfo(spellId);
	if (spellId2) then
		local name2, _, _ = GetSpellInfo(spellId2);
		if (name2) then
			name = name .. "/"..name2;
		end
	end
	bonusFrame.Icon:SetTexture(icon);
	if (formatString) then
		bonusFrame.Label:SetFormattedText(formatString, name);
	else
		bonusFrame.Label:SetText(name);
	end
	bonusFrame.spellId = spellId;
	bonusFrame.spellId2 = spellId2;
	bonusFrame.extraTooltip = nil;
	bonusFrame.Icon:SetDesaturated(desaturated);
	bonusFrame.IconBorder:SetDesaturated(desaturated);
	if (desaturated) then
		bonusFrame.Label:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	else
		bonusFrame.Label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	bonusFrame:Show();
end

function PlayerTalentFramePanel_UpdateSummary(self)

	local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(self.talentTree, self.inspect, self.pet, self.talentGroup);
	local role1, role2 = GetTalentTreeRoles(self.talentTree, self.inspect, self.pet);
	
	if (self.Summary and icon) then
		local summary = self.Summary;
		SetPortraitToTexture(self.Summary.Icon, icon);
		if (PlayerTalentFrame.primaryTree or GetNumTalentPoints() == 0) then
			self.Summary.TitleText:SetText(name);
			self.Summary.TitleText:Show();
		else
			self.Summary.TitleText:Hide();
		end
		
		-- Update roles
		if ( role1 == "TANK" or role1 == "HEALER" or role1 == "DAMAGER") then
			summary.RoleIcon.Icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role1));
			summary.RoleIcon:Show();
			summary.RoleIcon.role = role1;
		else
			summary.RoleIcon:Hide();
		end
		
		if ( role2 == "TANK" or role2 == "HEALER" or role2 == "DAMAGER") then
			summary.RoleIcon2.Icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role2));
			summary.RoleIcon2:Show();
			summary.RoleIcon2.role = role2;
			summary.RoleIcon:SetPoint("BOTTOMRIGHT", summary.IconBorder, -9, -1);
		else
			summary.RoleIcon2:Hide();
			summary.RoleIcon:SetPoint("BOTTOMRIGHT", summary.IconBorder, -1, 3);
		end
		
		local desaturateBonuses = nil;
		if ((PlayerTalentFrame.primaryTree and self.talentTree ~= PlayerTalentFrame.primaryTree) or (selectedSpec ~= activeSpec) or GetNumTalentPoints() == 0) then
			desaturateBonuses = 1;
			if (selectedSpec ~= activeSpec) then
				summary.Border:SetVertexColor(0.8, 0.8, 0.8);
				summary.Icon:SetDesaturated(1);
				summary.IconBorder:SetDesaturated(1);
				summary.IconGlow:SetVertexColor(1, 1, 1);
				summary.RoleIcon.Icon:SetDesaturated(1);
				summary.RoleIcon2.Icon:SetDesaturated(1);
			else
				summary.Icon:SetDesaturated(0);
				summary.IconBorder:SetDesaturated(0);
				summary.RoleIcon.Icon:SetDesaturated(0);
				summary.RoleIcon2.Icon:SetDesaturated(0);
			end
		else
			summary.Icon:SetDesaturated(0);
			summary.IconBorder:SetDesaturated(0);
			summary.RoleIcon.Icon:SetDesaturated(0);
			summary.RoleIcon2.Icon:SetDesaturated(0);
		end
		
		-- Update border glow
		if (PlayerTalentFrame.primaryTree and self.talentTree == PlayerTalentFrame.primaryTree) then
			summary.GlowTopLeft:Show();
			summary.GlowTop:Show();
			summary.GlowTopRight:Show();
			summary.GlowRight:Show();
			summary.GlowBottomRight:Show();
			summary.GlowBottom:Show();
			summary.GlowBottomLeft:Show();
			summary.GlowLeft:Show();
			summary.Border:SetVertexColor(0, 0, 0);
			
			local desaturate = (selectedSpec ~= activeSpec);
			summary.GlowTopLeft:SetDesaturated(desaturate);
			summary.GlowTop:SetDesaturated(desaturate);
			summary.GlowTopRight:SetDesaturated(desaturate);
			summary.GlowRight:SetDesaturated(desaturate);
			summary.GlowBottomRight:SetDesaturated(desaturate);
			summary.GlowBottom:SetDesaturated(desaturate);
			summary.GlowBottomLeft:SetDesaturated(desaturate);
			summary.GlowLeft:SetDesaturated(desaturate);
		else
			summary.GlowTopLeft:Hide();
			summary.GlowTop:Hide();
			summary.GlowTopRight:Hide();
			summary.GlowRight:Hide();
			summary.GlowBottomRight:Hide();
			summary.GlowBottom:Hide();
			summary.GlowBottomLeft:Hide();
			summary.GlowLeft:Hide();
		end
		
		local bonuses;
		
		-- Update all Active bonuses
		bonuses =  {GetMajorTalentTreeBonuses(self.talentTree, self.inspect, self.pet)};
		for i=1, #bonuses do
			local bonusFrame = _G[self.Summary:GetName().."ActiveBonus"..i];
			if (bonusFrame) then
				PlayerTalentFramePanel_UpdateBonusAbility(bonusFrame, bonuses[i], nil, nil, desaturateBonuses);
			end
		end
		
		-- Hide unused bonus frames
		local i = #bonuses+1;
		local bonusFrame = _G[self.Summary:GetName().."ActiveBonus"..i];
		while (bonusFrame) do
			bonusFrame:Hide();
			i = i + 1;
			bonusFrame = _G[self.Summary:GetName().."ActiveBonus"..i];
		end
		
		-- Update all Passive bonuses
		bonuses = {GetMinorTalentTreeBonuses(self.talentTree, self.inspect, self.pet)};
		local numSmallBonuses = 0;
		for i=1, #bonuses do
			numSmallBonuses = numSmallBonuses+1;
			local bonusFrame = _G[self.Summary:GetName().."Bonus"..numSmallBonuses];
			if (bonusFrame) then
				PlayerTalentFramePanel_UpdateBonusAbility(bonusFrame, bonuses[i], nil, nil, desaturateBonuses);
			end
		end	
		
		bonuses = {GetTalentTreeEarlySpells(self.talentTree, self.inspect, self.pet)};
		for i=1, #bonuses do
			numSmallBonuses = numSmallBonuses+1;
			local bonusFrame = _G[self.Summary:GetName().."Bonus"..numSmallBonuses];
			if (bonusFrame) then
				PlayerTalentFramePanel_UpdateBonusAbility(bonusFrame, bonuses[i], nil, TALENT_EARLY_SPELLS_LABEL, desaturateBonuses);
			end
		end	
		
		-- Update mastery
		local masterySpell, masterySpell2 = GetTalentTreeMasterySpells(self.talentTree);
		if (UnitLevel("player") >= SHOW_MASTERY_LEVEL and masterySpell) then
			local _, class = UnitClass("player");
			local masteryKnown = IsSpellKnown(CLASS_MASTERY_SPELLS[class]);
			numSmallBonuses = numSmallBonuses+1;
			local bonusFrame = _G[self.Summary:GetName().."Bonus"..numSmallBonuses];
			if (bonusFrame) then
				PlayerTalentFramePanel_UpdateBonusAbility(bonusFrame, masterySpell, masterySpell2, TALENT_MASTERY_LABEL, desaturateBonuses or not masteryKnown);
				if (not masteryKnown) then
					bonusFrame.extraTooltip = GRAY_FONT_COLOR_CODE..TALENT_MASTERY_TOOLTIP_NOT_KNOWN..FONT_COLOR_CODE_CLOSE;
				end
				--Override icon to Mastery icon
				local _, _, masteryTexture = GetSpellInfo(CLASS_MASTERY_SPELLS[class]);
				bonusFrame.Icon:SetTexture(masteryTexture);
				bonusFrame.Icon:SetDesaturated(desaturateBonuses or not masteryKnown);
			end
		end
		
		-- Hide unused bonus frames
		local i = numSmallBonuses+1;
		local bonusFrame = _G[self.Summary:GetName().."Bonus"..i];
		while (bonusFrame) do
			bonusFrame:Hide();
			i = i + 1;
			bonusFrame = _G[self.Summary:GetName().."Bonus"..i];
		end
		
		local descriptionFrame = self.Summary.Description;
		
		-- Update description height
		if (numSmallBonuses > 4) then
			descriptionFrame:SetHeight(64);
			descriptionFrame:SetPoint("TOPLEFT", 10, -292);
		else
			descriptionFrame:SetHeight(88);
			descriptionFrame:SetPoint("TOPLEFT", 10, -268);
		end
		
		-- Update description text
		descriptionFrame:SetWidth(178);
		descriptionFrame.ScrollChild:SetWidth(descriptionFrame:GetWidth());
		descriptionFrame.ScrollChild:SetHeight(descriptionFrame:GetHeight());
		descriptionFrame.ScrollChild.Text:SetWidth(descriptionFrame:GetWidth());
		descriptionFrame.ScrollChild.Text:SetHeight(0);
		descriptionFrame.ScrollChild.Text:SetSpacing(4);
		descriptionFrame.ScrollChild.Text:SetText(description);
		if (descriptionFrame.ScrollChild.Text:GetHeight() > descriptionFrame.ScrollChild:GetHeight()) then
			descriptionFrame:SetWidth(156);
			descriptionFrame.ScrollChild:SetWidth(descriptionFrame:GetWidth());
			descriptionFrame.ScrollChild.Text:SetWidth(descriptionFrame:GetWidth());
			descriptionFrame.ScrollChild:SetHeight(descriptionFrame.ScrollChild.Text:GetHeight() + 20);
		else
			descriptionFrame.ScrollChild:SetHeight(descriptionFrame.ScrollChild.Text:GetHeight());
		end
		ScrollFrame_OnScrollRangeChanged(descriptionFrame);
	end
end

function PlayerTalentFramePanel_ShowOrHideHeaderIcon(self)
	if (self.SelectTreeButton:IsShown() or self.Summary:IsShown()) then
		self.HeaderIcon:Hide();
	else
		self.HeaderIcon:Show();
	end
end

function PlayerTalentFramePanel_Update(self)
	local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(self.talentTree, self.inspect, self.pet, self.talentGroup);
	local primaryTree = PlayerTalentFrame.primaryTree;
	if (self.PointsSpent) then
		self.PointsSpent:SetText(pointsSpent+previewPointsSpent);
	end
	if (self.HeaderIcon) then
		self.HeaderIcon.Icon:SetTexture(icon);
		self.HeaderIcon.PointsSpent:SetText(pointsSpent+previewPointsSpent);
	end
	self.Name:SetText(name);
	if (self.NameLarge) then
		self.NameLarge:SetText(name);
	end
	
	local talentInfo;
	if (self.pet) then
		talentInfo = TALENT_INFO["PET_"..id];
	else
		local classDisplayName, class = UnitClass("player");
		talentInfo = TALENT_INFO[class] or TALENT_INFO["default"];
	end
	
	local color = talentInfo and talentInfo[self.talentTree] and talentInfo[self.talentTree].color;
	if (color) then
		self.HeaderBackground:SetVertexColor(color.r, color.g, color.b);
		if (self.Summary) then
			self.Summary.Border:SetVertexColor(color.r, color.g, color.b);
			self.Summary.IconGlow:SetVertexColor(color.r, color.g, color.b);
		end
	else
		self.HeaderBackground:SetVertexColor(1, 1, 1);
	end
	
	TalentFrame_Update(self);
	
	PlayerTalentFramePanel_UpdateSummary(self);
	
	if (self.SelectTreeButton) then
		if (not primaryTree and GetNumTalentPoints() > 0) then
			self.SelectTreeButton:Show();
			self.SelectTreeButton:SetText(name);
			if (selectedSpec and (activeSpec == selectedSpec)) then
				self.SelectTreeButton:Enable();
			else
				self.SelectTreeButton:Disable();
			end
		else
			self.SelectTreeButton:Hide();
		end
	end
	
	-- Update appearance of the Header icon and surrounding art
	if (self.HeaderIcon and not self.pet) then
		PlayerTalentFramePanel_ShowOrHideHeaderIcon(self);
		if (primaryTree == self.talentTree) then
			self.HeaderIcon.PointsSpent:Show();
			self.HeaderIcon.PrimaryBorder:Show();
			self.HeaderIcon.PointsSpentBgGold:Show();
			self.HeaderIcon.SecondaryBorder:Hide();
			self.HeaderIcon.PointsSpentBgSilver:Hide();
			self.HeaderIcon.LockIcon:Hide();
		elseif (isUnlocked or GetNumTalentPoints() == 0) then
			self.HeaderIcon.PointsSpent:Show();
			self.HeaderIcon.PrimaryBorder:Hide();
			self.HeaderIcon.PointsSpentBgGold:Hide();
			self.HeaderIcon.SecondaryBorder:Show();
			self.HeaderIcon.PointsSpentBgSilver:Show();
			self.HeaderIcon.LockIcon:Hide();
		else
			self.HeaderIcon.PointsSpent:Hide();
			self.HeaderIcon.PrimaryBorder:Hide();
			self.HeaderIcon.PointsSpentBgGold:Hide();
			self.HeaderIcon.SecondaryBorder:Show();
			self.HeaderIcon.PointsSpentBgSilver:Hide();
			self.HeaderIcon.LockIcon:Show();
		end	
	end
	
	if (self.RoleIcon) then
		local role1, role2 = GetTalentTreeRoles(self.talentTree, self.inspect, self.pet);
		
		-- swap roles to match order on the summary screen
		if (role2) then
			role1, role2 = role2, role1;
		end
		
		-- Update roles
		if ( role1 == "TANK" or role1 == "HEALER" or role1 == "DAMAGER") then
			self.RoleIcon.Icon:SetTexCoord(GetTexCoordsForRoleSmall(role1));
			self.RoleIcon:Show();
			self.RoleIcon.role = role1;
		else
			self.RoleIcon:Hide();
		end
		
		if ( role2 == "TANK" or role2 == "HEALER" or role2 == "DAMAGER") then
			self.RoleIcon2.Icon:SetTexCoord(GetTexCoordsForRoleSmall(role2));
			self.RoleIcon2:Show();
			self.RoleIcon2.role = role2;
		else
			self.RoleIcon2:Hide();
		end
	end
	
	-- Update the glow on your primary spec
	if (not self.pet and primaryTree and primaryTree == self.talentTree) then
		self.GlowTop:Show();
		self.GlowTopLeft:Show();
		self.GlowLeft:Show();
		self.GlowBottomLeft:Show();
		self.GlowBottom:Show();
		self.GlowBottomRight:Show();
		self.GlowRight:Show();
		self.GlowTopRight:Show();
	elseif (not self.pet) then
		self.GlowTop:Hide();
		self.GlowTopLeft:Hide();
		self.GlowLeft:Hide();
		self.GlowBottomLeft:Hide();
		self.GlowBottom:Hide();
		self.GlowBottomRight:Hide();
		self.GlowRight:Hide();
		self.GlowTopRight:Hide();
	end
	
	
	-- Set desaturation if the tree is not unlocked or the spec is not selected
	if (not self.pet and ((not isUnlocked and primaryTree) or not(selectedSpec == activeSpec))) then
		self.BgTopLeft:SetDesaturated(1);
		self.BgTopRight:SetDesaturated(1);
		self.BgBottomLeft:SetDesaturated(1);
		self.BgBottomRight:SetDesaturated(1);
		self.GlowTop:SetDesaturated(1);
		self.GlowTopLeft:SetDesaturated(1);
		self.GlowLeft:SetDesaturated(1);
		self.GlowBottomLeft:SetDesaturated(1);
		self.GlowBottom:SetDesaturated(1);
		self.GlowBottomRight:SetDesaturated(1);
		self.GlowRight:SetDesaturated(1);
		self.GlowTopRight:SetDesaturated(1);
		self.HeaderBackground:SetVertexColor(1, 1, 1);
		self.HeaderIcon.Icon:SetDesaturated(1);
		self.HeaderIcon.PrimaryBorder:SetDesaturated(1);
		self.HeaderIcon.PointsSpentBgGold:SetDesaturated(1);
		self.HeaderBorder:SetDesaturated(1);
		self.Name:SetFontObject(GameFontDisable);
		if (self.RoleIcon) then
			self.RoleIcon.Icon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
			self.RoleIcon2.Icon:SetTexture("Interface\\LFGFrame\\LFGRole_BW");
		end
	elseif (not self.pet) then
		self.GlowTop:SetDesaturated(0);
		self.GlowTopLeft:SetDesaturated(0);
		self.GlowLeft:SetDesaturated(0);
		self.GlowBottomLeft:SetDesaturated(0);
		self.GlowBottom:SetDesaturated(0);
		self.GlowBottomRight:SetDesaturated(0);
		self.GlowRight:SetDesaturated(0);
		self.GlowTopRight:SetDesaturated(0);
		self.HeaderIcon.Icon:SetDesaturated(0);
		self.HeaderIcon.PrimaryBorder:SetDesaturated(0);
		self.HeaderIcon.PointsSpentBgGold:SetDesaturated(0);
		self.HeaderBorder:SetDesaturated(0);
		self.Name:SetFontObject(GameFontNormal);
		if (self.RoleIcon) then
			self.RoleIcon.Icon:SetTexture("Interface\\LFGFrame\\LFGRole");
			self.RoleIcon2.Icon:SetTexture("Interface\\LFGFrame\\LFGRole");
		end
	end
	
	-- Update the shadow cover
	if (not self.pet) then
		if (not isUnlocked and primaryTree) then
			self.InactiveShadow:Show();
			self.InactiveShadow.Gradient:Hide();
			self.InactiveShadow.Cover:SetPoint("TOPLEFT", 0, 0);
			self.InactiveShadow:SetAlpha(0.7);
		elseif (primaryTree and primaryTree ~= self.talentTree) then
			self.InactiveShadow:Show();
			self.InactiveShadow.Gradient:Show();
			self.InactiveShadow.Cover:SetPoint("TOPLEFT", self.InactiveShadow.Gradient, "BOTTOMLEFT", 0, 0);
			self.InactiveShadow:SetAlpha(0.5);
		else
			self.InactiveShadow:Hide();
		end
	end
end


-- PlayerTalentFrameTalents

function PlayerTalentFrameTalent_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetTalentLink(self:GetParent().talentTree, self:GetID(),
			PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalentsOption"));
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	elseif ( selectedSpec and (activeSpec == selectedSpec)) then
		-- only allow functionality if an active spec is selected
		if ( button == "LeftButton" ) then
			if ( GetCVarBool("previewTalentsOption") ) then
				AddPreviewTalentPoints(self:GetParent().talentTree, self:GetID(), 1, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			else
				LearnTalent(self:GetParent().talentTree, self:GetID(), PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			end
		elseif ( button == "RightButton" ) then
			if ( GetCVarBool("previewTalentsOption") ) then
				AddPreviewTalentPoints(self:GetParent().talentTree, self:GetID(), -1, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			end
		end
	end
end

function PlayerTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(self:GetParent().talentTree, self:GetID(),
			PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalentsOption"));
	end
end

function PlayerTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	
	GameTooltip:SetTalent(self:GetParent().talentTree, self:GetID(),
		PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalentsOption"));
end


-- Controls

function PlayerTalentFrame_UpdateControls(activeTalentGroup, numTalentGroups)
	local spec = selectedSpec and specs[selectedSpec];
	local isActiveSpec = selectedSpec == activeSpec;
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	local primaryTree = PlayerTalentFrame.primaryTree;
	if (not activeTalentGroup or not numTalentGroups) then
		activeTalentGroup, numTalentGroups = GetActiveTalentGroup(false, PlayerTalentFrame.pet), GetNumTalentGroups(false, PlayerTalentFrame.pet);
	end

	-- show the activate button if this is not the active spec
	PlayerTalentFrameActivateButton_Update(numTalentGroups);

	local preview = GetCVarBool("previewTalentsOption");
	
	-- Show/Hide panel summaries
	local summariesShown = PlayerTalentFrame_ShowOrHideSummaries();	

	-- enable the control bar if this is the active spec, preview is enabled, and preview points were spent
	local talentTabSelected = PanelTemplates_GetSelectedTab(PlayerTalentFrame) == TALENTS_TAB;
	local petTalentTabSelected = PanelTemplates_GetSelectedTab(PlayerTalentFrame) == PET_TALENTS_TAB;
	local talentPoints = GetUnspentTalentPoints(false, PlayerTalentFrame.pet, spec.talentGroup);
	local previewPrimaryTree = GetPreviewPrimaryTalentTree(PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
	if ( isActiveSpec and (talentPoints > 0 or previewPrimaryTree) and preview and ((talentTabSelected and primaryTree) or petTalentTabSelected)) then
		
		--ButtonFrameTemplate_ShowButtonBar(PlayerTalentFrame);
		PlayerTalentFrameLearnButton:Show();
		PlayerTalentFrameResetButton:Show();
		
		-- enable accept/cancel buttons if preview talent points were spent
		local previewPointsSpent = GetGroupPreviewTalentPointsSpent(PlayerTalentFrame.pet, spec.talentGroup);
		if (previewPointsSpent > 0 or previewPrimaryTree) then
			PlayerTalentFrameLearnButton:Enable();
			PlayerTalentFrameResetButton:Enable();
			if (previewPointsSpent > 0 and not PlayerTalentFrameLearnButtonTutorial.hasBeenClosed and not GetCVarBool("talentPointsSpent")) then
				PlayerTalentFrameLearnButtonTutorial:Show();
			else
				PlayerTalentFrameLearnButtonTutorial:Hide();
			end
			
			if (previewPointsSpent > 0) then
				UIFrameFlash(PlayerTalentFrameLearnButton.Flash, 0.75, 0.75, -1, nil);
			else
				UIFrameFlashStop(PlayerTalentFrameLearnButton.Flash);
				PlayerTalentFrameLearnButton.Flash:Hide();
			end
			
		else
			PlayerTalentFrameLearnButton:Disable();
			PlayerTalentFrameResetButton:Disable();
			PlayerTalentFrameLearnButtonTutorial:Hide();
			UIFrameFlashStop(PlayerTalentFrameLearnButton.Flash);
			PlayerTalentFrameLearnButton.Flash:Hide();
		end
		-- squish all frames to make room for this bar
		--PlayerTalentFramePointsBar:SetPoint("BOTTOM", PlayerTalentFramePreviewBar, "TOP", 0, -4);
	else
		--ButtonFrameTemplate_HideButtonBar(PlayerTalentFrame);
		PlayerTalentFrameLearnButton:Hide();
		PlayerTalentFrameResetButton:Hide();
		PlayerTalentFrameLearnButtonTutorial:Hide();
		UIFrameFlashStop(PlayerTalentFrameLearnButton.Flash);
		PlayerTalentFrameLearnButton.Flash:Hide();

		-- unsquish frames since the bar is now hidden
		--PlayerTalentFramePointsBar:SetPoint("BOTTOM", PlayerTalentFrame, "BOTTOM", 0, 81);
	end
	
	-- Update header elements for the player talents
	local headerY = -36;
	if (selectedTab == TALENTS_TAB) then
		if (not primaryTree and GetNumTalentPoints() > 0) then
			-- Player has not selected a primary tree yet
			PlayerTalentFrameHeaderText:SetFormattedText(TALENTS_CHOOSE_SPEC_HEADER, UnitClass("player"));
			PlayerTalentFrameHeaderText:SetFontObject("GameFontHighlightLarge");
			PlayerTalentFrameHeaderText:Show();
			PlayerTalentFrameHeaderSubText:SetText(TALENTS_CHOOSE_SPEC_SUBHEADER);
			PlayerTalentFrameHeaderSubText:Show();
			headerY = headerY + 2;
			PlayerTalentFrameHeaderHelpBox:Show();
			for i = 1, 3 do
				_G["PlayerTalentFrameHeaderHelpBoxArrow"..i]:Show();
			end
		elseif (talentPoints > 0) then
			local unspentPreviewPoints = talentPoints - GetGroupPreviewTalentPointsSpent(PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			PlayerTalentFrameHeaderText:SetFormattedText(PLAYER_UNSPENT_TALENT_POINTS, NORMAL_FONT_COLOR_CODE..unspentPreviewPoints..FONT_COLOR_CODE_CLOSE);
			PlayerTalentFrameHeaderText:SetFontObject("GameFontHighlight");
			PlayerTalentFrameHeaderText:Show();
			PlayerTalentFrameHeaderSubText:Hide();
			PlayerTalentFrameHeaderHelpBox:Show();
			for i = 1, 3 do
				local _, _, _, _, _, _, _, isUnlocked = GetTalentTabInfo(i, false, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
				if (isUnlocked) then
					_G["PlayerTalentFrameHeaderHelpBoxArrow"..i]:Show();
				else
					_G["PlayerTalentFrameHeaderHelpBoxArrow"..i]:Hide();
				end
			end
		elseif (GetNextTalentLevel()) then
			PlayerTalentFrameHeaderText:SetFormattedText(NEXT_TALENT_LEVEL, GetNextTalentLevel());
			PlayerTalentFrameHeaderText:SetFontObject("GameFontHighlight");
			PlayerTalentFrameHeaderText:Show();
			PlayerTalentFrameHeaderSubText:Hide();
			PlayerTalentFrameHeaderHelpBox:Hide();
		else
			PlayerTalentFrameHeaderText:Hide();
			PlayerTalentFrameHeaderSubText:Hide();
			PlayerTalentFrameHeaderHelpBox:Hide();
		end
	elseif (selectedTab == PET_TALENTS_TAB) then
		local nextPetTalentLevel = GetNextPetTalentLevel();
		if (talentPoints > 0) then
			local unspentPreviewPoints = talentPoints - GetGroupPreviewTalentPointsSpent(PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			PlayerTalentFrameHeaderText:SetFormattedText(PET_UNSPENT_TALENT_POINTS, NORMAL_FONT_COLOR_CODE..unspentPreviewPoints..FONT_COLOR_CODE_CLOSE);
			PlayerTalentFrameHeaderText:SetFontObject("GameFontHighlight");
			PlayerTalentFrameHeaderText:Show();
			PlayerTalentFrameHeaderSubText:Hide();
		elseif (nextPetTalentLevel and nextPetTalentLevel <= MAX_PLAYER_LEVEL) then
			PlayerTalentFrameHeaderText:SetFormattedText(NEXT_TALENT_LEVEL, nextPetTalentLevel);
			PlayerTalentFrameHeaderText:SetFontObject("GameFontHighlight");
			PlayerTalentFrameHeaderText:Show();
			PlayerTalentFrameHeaderSubText:Hide();
		else
			PlayerTalentFrameHeaderText:Hide();
			PlayerTalentFrameHeaderSubText:Hide();
		end
		PlayerTalentFrameHeaderHelpBox:Hide();
	else
		PlayerTalentFrameHeaderText:Hide();
		PlayerTalentFrameHeaderSubText:Hide();
		PlayerTalentFrameHeaderHelpBox:Hide();
	end
	
	if (not isActiveSpec) then
		PlayerTalentFrameHeaderHelpBox:Hide();
	end
	
	if (PlayerTalentFrameHeaderSubText:IsShown()) then
		headerY = headerY + 6;
		PlayerTalentFrameHeaderHelpBox:SetHeight(38);
	else
		PlayerTalentFrameHeaderHelpBox:SetHeight(28);
	end
	
	if (PlayerTalentFrameHeaderText:IsShown()) then
		PlayerTalentFrameHeaderText:SetPoint("TOP", 0, headerY);
	end
	
end

function PlayerTalentFrameActivateButton_OnLoad(self)
	self:SetWidth(self:GetTextWidth() + 40);
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
		if (IsCurrentSpell(TALENT_ACTIVATION_SPELLS[spec.talentGroup])) then
			PlayerTalentFrameActivateButton:Show();
			PlayerTalentFrameActivateButton:Disable();
		elseif (selectedSpec == activeSpec) then
			PlayerTalentFrameActivateButton:Hide();
		else
			PlayerTalentFrameActivateButton:Show();
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
	PlayerTalentFrameTalents.summariesShownWhenNoPrimary = true;
	PlayerTalentFrameTalents.summariesShownWhenPrimary = false;
	PlayerTalentFrameLearnButtonTutorial.hasBeenClosed = false;
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
				frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPRIGHT", offsetX, -36);
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
		local primaryTree = GetPreviewPrimaryTalentTree(false, false, spec.talentGroup) 
				or GetPrimaryTalentTree(false, false, spec.talentGroup);
		
		local specInfoCache = talentSpecInfoCache[specIndex];
		if ( primaryTree and primaryTree > 0 and specInfoCache) then
			-- the spec had a primary tab, set the icon to that tab's icon
			normalTexture:SetTexture(specInfoCache[primaryTree].icon);
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

