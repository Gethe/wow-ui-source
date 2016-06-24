StaticPopupDialogs["CONFIRM_LEARN_SPEC"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		SetSpecialization(self.data.previewSpec, self.data.isPet);
		self.data.playLearnAnim = true;
	end,
	OnCancel = function (self)
	end,
	OnShow = function(self)
		if (self.data.previewSpecCost and self.data.previewSpecCost > 0) then
			self.text:SetFormattedText(CONFIRM_LEARN_SPEC_COST, GetMoneyString(self.data.previewSpecCost));
		else
			self.text:SetText(CONFIRM_LEARN_SPEC);
		end
	end,
	hideOnEscape = 1,
	whileDead = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_EXIT_WITH_UNSPENT_TALENT_POINTS"] = {
	text = CONFIRM_EXIT_WITH_UNSPENT_TALENT_POINTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) HideUIPanel(self.data); end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	whileDead = 1,
	timeout = 0,
	exclusive = 0,
}


UIPanelWindows["PlayerTalentFrame"] = { area = "left", pushable = 1, whileDead = 1, width = 666, height = 488 };


-- global constants
local THREE_SPEC_LGBUTTON_HEIGHT = 95;
local SPEC_SCROLL_HEIGHT = 282;
local SPEC_SCROLL_PREVIEW_HEIGHT = 228;

-- speed references
local next = next;
local ipairs = ipairs;

-- local data
local specs = {
	["spec1"] = {
		name = SPECIALIZATION_PRIMARY,
		nameActive = TALENT_SPEC_PRIMARY_ACTIVE,
		specName = SPECIALIZATION_PRIMARY,
		specNameActive = SPECIALIZATION_PRIMARY_ACTIVE,
		talentGroup = 1,
		tooltip = SPECIALIZATION_PRIMARY,
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
	},
	["spec2"] = {
		name = SPECIALIZATION_SECONDARY,
		nameActive = TALENT_SPEC_SECONDARY_ACTIVE,
		specName = SPECIALIZATION_SECONDARY,
		specNameActive = SPECIALIZATION_SECONDARY_ACTIVE,
		talentGroup = 2,
		tooltip = SPECIALIZATION_SECONDARY,
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
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

-- Position offsets for header text (must be localized)
TALENT_HEADER_DEFAULT_Y = -36;
TALENT_HEADER_CHOOSE_SPEC_Y = -28;

-- Hardcoded spell id's for spec display
SPEC_SPELLS_DISPLAY = {}
SPEC_SPELLS_DISPLAY[62] = { 30451,10,	5143,10,	44425,10,	1449,10,	12051,10,	12042,10	}; --Arcane
SPEC_SPELLS_DISPLAY[63] = { 133,10,		11366,10,	195283,10,	108853,10,	190319,10,	2948,10		}; --Fire
SPEC_SPELLS_DISPLAY[64] = { 116,10,		31687,10,	30455,10,	112965,10,	44614,10,	190447,10	}; --Frost

SPEC_SPELLS_DISPLAY[65] = { 19750,10,	82326,10,	20473,10,	183998,10,	53563,10,	85222,10	}; --Holy
SPEC_SPELLS_DISPLAY[66] = { 31935,10,	53595,10,	53600,10,	184092,10,	26573,10,	31850,10	}; --Protection
SPEC_SPELLS_DISPLAY[70] = { 35395,10,	184575,10,	20271,10,	85256,10,	53385,10,	19750,10	}; --Retribution

SPEC_SPELLS_DISPLAY[71] = { 12294,10,	167105,10,	1464,10,	163201,10,	1680,10,	184783,10	}; --Arms
SPEC_SPELLS_DISPLAY[72] = { 23881,10,	184367,10,	85288,10,	100130,10,	190411,10,	184361,10	}; --Fury
SPEC_SPELLS_DISPLAY[73] = { 23922,10,	20243,10,	2565,10,	190456,10,	6572,10,	6343,10		}; --Protection

SPEC_SPELLS_DISPLAY[102] = { 190984,10,	194153,10,	78674,10,	8921,10,	93402,10,	191034,10	}; --Balance
SPEC_SPELLS_DISPLAY[103] = { 5221,10,	1822,10,	1079,10,	22568,10,	106832,10,	213764,10	}; --Feral
SPEC_SPELLS_DISPLAY[104] = { 33917,10,	213764,10,	192081,10,	22842,10,	106832,10,	22812,10	}; --Guardian
SPEC_SPELLS_DISPLAY[105] = { 774,10,	5185,10,	8936,10,	33763,10,	48438,10,	740,10		}; --Restoration

SPEC_SPELLS_DISPLAY[250] = { 206930,10,	49998,10,	195182,10,	43265,10,	50842,10,	49576,10	}; --Blood
SPEC_SPELLS_DISPLAY[251] = { 49020,10,	49143,10,	49184,10,	196770,10,	51128,10,	59057,10	}; --Frost
SPEC_SPELLS_DISPLAY[252] = { 85948,10,	55090,10,	77575,10,	47541,10,	43265,10,	46584,10	}; --Unholy

SPEC_SPELLS_DISPLAY[253] = { 193455,10,	120679,10,	34026,10,	2643,10,	19574,10,	193530,10	}; --Beastmaster
SPEC_SPELLS_DISPLAY[254] = { 185358,10,	19434,10,	185901,10,	2643,10,	186387,10,	185987,10	}; --Marksmanship
SPEC_SPELLS_DISPLAY[255] = { 190928,10, 202800,10,	185855,10,	186270,10,	187708,10,	191433,10	}; --Survival

SPEC_SPELLS_DISPLAY[256] = { 17,10,		186263,10,	81749,10,	47540,10,	585,10,		589,10		}; --Discipline
SPEC_SPELLS_DISPLAY[257] = { 2061,10,	2060,10,	139,10,		2050,10,	63733,10,	596,10		}; --Holy
SPEC_SPELLS_DISPLAY[258] = { 8092,10,	15407,10,	34914,10,	589,10,		228260,10,	228264,10	}; --Shadow

SPEC_SPELLS_DISPLAY[259] = { 703,10,	1329,10,	1943,10,	32645,10,	2823,10,	79134,10	}; --Assassination
SPEC_SPELLS_DISPLAY[260] = { 193315,10,	185763,10,	193316,10,	2098,10,	199804,10,	13877,10	}; --Outlaw
SPEC_SPELLS_DISPLAY[261] = { 185438,10,	53,10,		195452,10,	196819,10,	185313,10,	185314,10	}; --Subtlety

SPEC_SPELLS_DISPLAY[262] = { 188389,10,	51505,10,	188196,10,	8042,10,	188443,10,	77756,10	}; --Elemental
SPEC_SPELLS_DISPLAY[263] = { 193786,10,	193796,10,	17364,10,	60103,10,	201845,10,	187880,10	}; --Enhancement
SPEC_SPELLS_DISPLAY[264] = { 8004,10,	77472,10,	61295,10,	1064,10,	73920,10,	51564,10	}; --Restoration

SPEC_SPELLS_DISPLAY[265] = { 172,10,	980,10,		30108,10,	689,10,		27243,10,	691,10		}; --Affliction
SPEC_SPELLS_DISPLAY[266] = { 686,10,	603,10,		105174,10,	104316,10,	193396,10,	30146,10	}; --Demonology
SPEC_SPELLS_DISPLAY[267] = { 348,10,	17962,10,	116858,10,	29722,10,	80240,10,	688,10		}; --Destruction

SPEC_SPELLS_DISPLAY[268] = { 100780,10,	121253,10,	115181,10,	115069,10,	119582,10,	115308,10	}; --Brewmaster
SPEC_SPELLS_DISPLAY[269] = { 100780,10,	107428,10,	100784,10,	113656,10,	109132,10,	137639,10	}; --Windwalker
SPEC_SPELLS_DISPLAY[270] = { 116694,10,	115151,10,	124682,10,	116670,10,	191837,10,	193884,10	}; --Mistweaver

SPEC_SPELLS_DISPLAY[577] = { 162243,10,	162794,10,	198013,10,	188499,10,	195072,10,	191427,10	}; --Havoc
SPEC_SPELLS_DISPLAY[581] = { 203782,10,	203798,10,	203720,10,	204021,10,	178740,10,	187827,10	}; --Vengeance

-- Core Abilities text prefix for spec page
SPEC_CORE_ABILITY_TEXT = {}
SPEC_CORE_ABILITY_TEXT[250] = "DK_BLOOD";
SPEC_CORE_ABILITY_TEXT[251] = "DK_FROST";
SPEC_CORE_ABILITY_TEXT[252] = "DK_UNHOLY";

SPEC_CORE_ABILITY_TEXT[102] = "DRUID_BALANCE";
SPEC_CORE_ABILITY_TEXT[103] = "DRUID_FERAL";
SPEC_CORE_ABILITY_TEXT[104] = "DRUID_GUARDIAN";
SPEC_CORE_ABILITY_TEXT[105] = "DRUID_RESTO";

SPEC_CORE_ABILITY_TEXT[253] = "HUNTER_BM";
SPEC_CORE_ABILITY_TEXT[254] = "HUNTER_MM";
SPEC_CORE_ABILITY_TEXT[255] = "HUNTER_SV";

SPEC_CORE_ABILITY_TEXT[74] = "HUNTER_PET_FEROCITY";
SPEC_CORE_ABILITY_TEXT[79] = "HUNTER_PET_CUNNING";
SPEC_CORE_ABILITY_TEXT[81] = "HUNTER_PET_TENACITY";

SPEC_CORE_ABILITY_TEXT[62] = "MAGE_ARCANE";
SPEC_CORE_ABILITY_TEXT[63] = "MAGE_FIRE";
SPEC_CORE_ABILITY_TEXT[64] = "MAGE_FROST";

SPEC_CORE_ABILITY_TEXT[268] = "MONK_BREW";
SPEC_CORE_ABILITY_TEXT[270] = "MONK_MIST";
SPEC_CORE_ABILITY_TEXT[269] = "MONK_WIND";

SPEC_CORE_ABILITY_TEXT[65] = "PALADIN_HOLY";
SPEC_CORE_ABILITY_TEXT[66] = "PALADIN_PROT";
SPEC_CORE_ABILITY_TEXT[70] = "PALADIN_RET";

SPEC_CORE_ABILITY_TEXT[256] = "PRIEST_DISC";
SPEC_CORE_ABILITY_TEXT[257] = "PRIEST_HOLY";
SPEC_CORE_ABILITY_TEXT[258] = "PRIEST_SHADOW";

SPEC_CORE_ABILITY_TEXT[259] = "ROGUE_ASS";
SPEC_CORE_ABILITY_TEXT[260] = "ROGUE_COMBAT";
SPEC_CORE_ABILITY_TEXT[261] = "ROGUE_SUB";

SPEC_CORE_ABILITY_TEXT[262] = "SHAMAN_ELE";
SPEC_CORE_ABILITY_TEXT[263] = "SHAMAN_ENHANCE";
SPEC_CORE_ABILITY_TEXT[264] = "SHAMAN_RESTO";

SPEC_CORE_ABILITY_TEXT[265] = "WARLOCK_AFFLICTION";
SPEC_CORE_ABILITY_TEXT[266] = "WARLOCK_DEMO";
SPEC_CORE_ABILITY_TEXT[267] = "WARLOCK_DESTRO";

SPEC_CORE_ABILITY_TEXT[71] = "WARRIOR_ARMS";
SPEC_CORE_ABILITY_TEXT[72] = "WARRIOR_FURY";
SPEC_CORE_ABILITY_TEXT[73] = "WARRIOR_PROT";

SPEC_CORE_ABILITY_TEXT[577] = "DH_HAVOC";
SPEC_CORE_ABILITY_TEXT[581] = "DH_VENGEANCE";

-- Bonus stat to string
SPEC_STAT_STRINGS = {
	[LE_UNIT_STAT_STRENGTH] = SPEC_FRAME_PRIMARY_STAT_STRENGTH,
	[LE_UNIT_STAT_AGILITY] = SPEC_FRAME_PRIMARY_STAT_AGILITY,
	[LE_UNIT_STAT_INTELLECT] = SPEC_FRAME_PRIMARY_STAT_INTELLECT,
};

-- PlayerTalentFrame

function PlayerTalentFrame_Toggle(suggestedTalentTab)
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if ( not PlayerTalentFrame:IsShown() ) then
		ShowUIPanel(PlayerTalentFrame);
        if (suggestedTalentTab) then
            PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..suggestedTalentTab]);
		elseif (PlayerTalentFrame.lastSelectedTab) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..PlayerTalentFrame.lastSelectedTab]);
		elseif ( not GetSpecialization() ) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..SPECIALIZATION_TAB]);
		elseif ( GetNumUnspentTalents() > 0 ) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENTS_TAB]);
        elseif ( GetNumUnspectPvpTalents() > 0 ) then
            PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..PVP_TALENTS_TAB]);
		elseif ( selectedTab ) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..selectedTab]);
		elseif ( AreTalentsLocked() ) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..SPECIALIZATION_TAB]);
		else
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENTS_TAB]);
		end
		TalentMicroButtonAlert:Hide();
	else
		PlayerTalentFrame_Close();
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

function PlayerTalentFrame_Close()
--	if (GetNumUnspentTalents() > 0) then
--		local dialog = StaticPopup_Show("CONFIRM_EXIT_WITH_UNSPENT_TALENT_POINTS");
--		if ( dialog ) then
--			dialog.data = PlayerTalentFrame;
--		else
--			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
--		end
--	else
		HideUIPanel(PlayerTalentFrame);
--	end
end

function PlayerTalentFrame_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PET_SPECIALIZATION_CHANGED");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterEvent("PREVIEW_TALENT_PRIMARY_TREE_CHANGED");
	self:RegisterEvent("PLAYER_LEARN_TALENT_FAILED");
	self.inspect = false;
	self.talentGroup = 1;
	self.hasBeenShown = false;
	self.selectedPlayerSpec = DEFAULT_TALENT_SPEC;
	self.onCloseCallback = PlayerTalentFrame_OnClickClose;

	local _, playerClass = UnitClass("player");
	if (playerClass == "HUNTER") then
		PET_SPECIALIZATION_TAB = 4
		NUM_TALENT_FRAME_TABS = 4;
	end

	-- setup tabs
	PanelTemplates_SetNumTabs(self, NUM_TALENT_FRAME_TABS);

	-- setup portrait texture
	local _, class = UnitClass("player");
	PlayerTalentFramePortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
	PlayerTalentFramePortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]));

	-- initialize active spec
	PlayerTalentFrame_UpdateActiveSpec(GetActiveSpecGroup(false));
	selectedSpec = activeSpec;

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

function PlayerTalentFrame_PetSpec_OnLoad(self)
	self.isPet = true;
	PlayerTalentFrameSpec_OnLoad(self);
end

function PlayerTalentFrameSpec_OnLoad(self)
	local numSpecs = GetNumSpecializations(false, self.isPet);
	local sex = self.isPet and UnitSex("pet") or UnitSex("player");
	-- demon hunters have 2 specs, druids have 4
	if ( numSpecs == 1 ) then
		self.specButton1:SetPoint("TOPLEFT", 6, -161);
        self.specButton2:Hide()
		self.specButton3:Hide()
	elseif ( numSpecs == 2 ) then
		self.specButton1:SetPoint("TOPLEFT", 6, -131);
		self.specButton3:Hide();
	elseif ( numSpecs == 4 ) then
		self.specButton1:SetPoint("TOPLEFT", 6, -61);
		self.specButton4:Show();
	end

	for i = 1, numSpecs do
		local button = self["specButton"..i];
		local _, name, description, icon = GetSpecializationInfo(i, false, self.isPet, nil, sex);
		SetPortraitToTexture(button.specIcon, icon);
		button.specName:SetText(name);
		button.tooltip = description;
		local role = GetSpecializationRole(i, false, self.isPet);
		button.roleIcon:SetTexCoord(GetTexCoordsForRole(role));
		button.roleName:SetText(_G[role]);
	end
end

function PlayerTalentFrame_OnShow(self)
	-- Stop buttons from flashing after skill up
	MicroButtonPulseStop(TalentMicroButton);
	TalentMicroButtonAlert:Hide();

	PlaySound("igCharacterInfoOpen");
	UpdateMicroButtons();

	PlayerTalentFrameTalents.summariesShownWhenNoPrimary = true;

	if ( not self.hasBeenShown ) then
		-- The first time the frame is shown, select your active spec
		self.hasBeenShown = true;
		PlayerSpecTab_OnClick(specTabs[activeSpec]);
	end

	PlayerTalentFrame_Refresh();

	-- Set flag
	if ( not GetCVarBool("talentFrameShown") ) then
		SetCVar("talentFrameShown", 1);
	end
end

function PlayerTalentFrame_OnHide()
	HelpPlate_Hide();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoClose");
	-- clear caches
	for _, info in next, talentSpecInfoCache do
		wipe(info);
	end
	wipe(talentTabWidthCache);

	StaticPopup_Hide("CONFIRM_LEARN_SPEC");
	TalentMicroButton:EvaluateAlertVisibility()
end

function PlayerTalentFrame_OnClickClose(self)
	PlayerTalentFrame_Close();
end

function PlayerTalentFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if (self:IsShown()) then
		if ( event == "ADDON_LOADED" ) then
			PlayerTalentFrame_ClearTalentSelections();
		elseif ( event == "PET_SPECIALIZATION_CHANGED" or
				 event == "PREVIEW_TALENT_POINTS_CHANGED" or
				 event == "PREVIEW_TALENT_PRIMARY_TREE_CHANGED" or
				 event == "PLAYER_TALENT_UPDATE" ) then
			PlayerTalentFrame_Refresh();
		elseif ( event == "UNIT_LEVEL") then
			if ( selectedSpec ) then
				local arg1 = ...;
				if (arg1 == "player") then
					PlayerTalentFrame_Update();
				end
			end
		elseif (event == "LEARNED_SPELL_IN_TAB") then
			-- Must update the Mastery bonus if you just learned Mastery
		end
	end
	if (event == "PLAYER_LEARN_TALENT_FAILED") then
		local talentFrame = PlayerTalentFrameTalents;

		local talentIds = GetFailedTalentIDs();
		for i = 1, #talentIds do
			local row, column = select(8, GetTalentInfoByID(talentIds[i], PlayerTalentFrame.talentGroup));
			if (talentFrame.talentInfo[row] == column) then
				talentFrame.talentInfo[row] = nil;
			end
		end
		TalentFrame_Update(talentFrame, "player");
		ClearFailedTalentIDs();
	end
end

function PlayerTalentFrame_ShowTalentTab()
	PlayerTalentFrameTalents:Show();
end

function PlayerTalentFrame_HideTalentTab()
	PlayerTalentFrameTalents:Hide();
end

function PlayerTalentFrame_ShowPVPTalentTab()
	PlayerTalentFramePVPTalents:Show();
	PlayerTalentFramePVPTalents_SetUp(PlayerTalentFramePVPTalents);
end

function PlayerTalentFrame_HidePVPTalentTab()
	PlayerTalentFramePVPTalents:Hide();
end

function PlayerTalentFrame_ShowsSpecTab()
	PlayerTalentFrameSpecialization:Show();
end

function PlayerTalentFrame_HideSpecsTab()
	PlayerTalentFrameSpecialization:Hide();
end

function PlayerTalentFrame_ShowsPetSpecTab()
	PlayerTalentFramePetSpecialization:Show();
end

function PlayerTalentFrame_HidePetSpecTab()
	PlayerTalentFramePetSpecialization:Hide();
end

function PlayerTalentFrame_GetTutorial()
	local tutorial;
	local helpPlate;
	local mainHelpButton;

	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if (selectedTab == TALENTS_TAB) then
		tutorial = LE_FRAME_TUTORIAL_TALENT;
		helpPlate = PlayerTalentFrame_HelpPlate;
		mainHelpButton = PlayerTalentFrameTalents.MainHelpButton;
	elseif (selectedTab == SPECIALIZATION_TAB) then
		tutorial = LE_FRAME_TUTORIAL_SPEC;
		helpPlate = PlayerSpecFrame_HelpPlate;
		mainHelpButton = PlayerTalentFrameSpecialization.MainHelpButton;
	elseif (selectedTab == PET_SPECIALIZATION_TAB) then
		tutorial = LE_FRAME_TUTORIAL_SPEC;
	end
	return tutorial, helpPlate, mainHelpButton;
end

function PlayerTalentFrame_Refresh()
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	selectedSpec = PlayerTalentFrame.selectedPlayerSpec;
	PlayerTalentFrame.talentGroup = specs[selectedSpec].talentGroup;
	PlayerTalentFramePVPTalents.talentGroup = specs[selectedSpec].talentGroup;
	local name, count, texture, spellID;

	if (selectedTab == TALENTS_TAB) then
		ButtonFrameTemplate_ShowAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrameTalents.talentGroup = PlayerTalentFrame.talentGroup;
		TalentFrame_Update(PlayerTalentFrameTalents, "player");
		PlayerTalentFrame_ShowTalentTab();
		PlayerTalentFrame_HidePVPTalentTab();
		PlayerTalentFrame_HidePetSpecTab();
	elseif (selectedTab == SPECIALIZATION_TAB) then
		ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_HidePVPTalentTab();
		PlayerTalentFrame_ShowsSpecTab();
		PlayerTalentFrame_HidePetSpecTab();
		PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFrameSpecialization);
	elseif (selectedTab == PVP_TALENTS_TAB) then
		ButtonFrameTemplate_ShowAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_ShowPVPTalentTab();
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrame_HidePetSpecTab();
		PVPTalentFrame_Update(PlayerTalentFramePVPTalents);
	elseif (selectedTab == PET_SPECIALIZATION_TAB) then
		ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_HidePVPTalentTab();
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrame_ShowsPetSpecTab();
		PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFramePetSpecialization);
	end

	PlayerTalentFrame.lastSelectedTab = selectedTab;
	PlayerTalentFrame_Update();
end

function PlayerTalentFrame_Update(playerLevel)
	local activeTalentGroup, numTalentGroups = GetActiveSpecGroup(false), GetNumSpecGroups(false);
	PlayerTalentFrame.primaryTree = GetSpecialization(PlayerTalentFrame.inspect, false, PlayerTalentFrame.talentGroup);

	-- update specs
	if ( not PlayerTalentFrame_UpdateSpecs(activeTalentGroup, numTalentGroups) ) then
		-- the current spec is not selectable any more, discontinue updates
		return false;
	end

	-- update tabs
	if ( not PlayerTalentFrame_UpdateTabs(playerLevel) ) then
		-- the current spec is not selectable any more, discontinue updates
		return false;
	end

	-- set the active spec
	PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup);

	-- update title text
	PlayerTalentFrame_UpdateTitleText(numTalentGroups);

	-- update talent controls
	PlayerTalentFrame_UpdateControls(activeTalentGroup, numTalentGroups);

	if (selectedSpec == activeSpec and numTalentGroups > 1) then
		PlayerTalentFrameTitleGlowLeft:Show();
		PlayerTalentFrameTitleGlowRight:Show();
		PlayerTalentFrameTitleGlowCenter:Show();
	else
		PlayerTalentFrameTitleGlowLeft:Hide();
		PlayerTalentFrameTitleGlowRight:Hide();
		PlayerTalentFrameTitleGlowCenter:Hide();
	end

	return true;
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
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);

	if ( selectedTab == SPECIALIZATION_TAB or selectedTab == PET_SPECIALIZATION_TAB ) then
		if ( spec and hasMultipleTalentGroups ) then
			if (isActiveSpec and spec.nameActive) then
				PlayerTalentFrameTitleText:SetText(spec.specNameActive);
			else
				PlayerTalentFrameTitleText:SetText(spec.specName);
			end
		else
			PlayerTalentFrameTitleText:SetText(SPECIALIZATION);
		end
	elseif ( selectedTab == PVP_TALENTS_TAB ) then
		local prestigeLevel = UnitPrestige("player");
		if (prestigeLevel > 0) then
			local text = PVP_TALENTS_PRESTIGE_RANK_TITLE:format(select(2, GetPrestigeInfo(prestigeLevel)));
			if ( spec and hasMultipleTalentGroups ) then
				if (isActiveSpec and spec.nameActive) then
					text = text .. " " .. spec.nameActive;
				else
					text = text .. " " .. spec.name;
				end
			end
			PlayerTalentFrameTitleText:SetText(text);
		else
			if ( spec and hasMultipleTalentGroups ) then
				if (isActiveSpec and spec.nameActive) then
					PlayerTalentFrameTitleText:SetText(spec.nameActive);
				else
					PlayerTalentFrameTitleText:SetText(spec.name);
				end
			else
				PlayerTalentFrameTitleText:SetText(PVP_TALENTS);
			end
		end
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

function PlayerTalentFrame_SelectTalent(tier, id)
	local talentRow = PlayerTalentFrameTalents["tier"..tier];
	if ( talentRow.selectionId == id ) then
		talentRow.selectionId = nil;
	else
		talentRow.selectionId = id;
	end
	TalentFrame_Update(PlayerTalentFrameTalents, "player");
end

function PlayerTalentFrame_ClearTalentSelections()
	for tier = 1, MAX_TALENT_TIERS do
		local talentRow = PlayerTalentFrameTalents["tier"..tier];
		talentRow.selectionId = nil;
	end
end

function PlayerTalentFrame_GetTalentSelections()
	local talents = { };
	for tier = 1, MAX_TALENT_TIERS do
		local talentRow = PlayerTalentFrameTalents["tier"..tier];
		if ( talentRow.selectionId ) then
			tinsert(talents, talentRow.selectionId);
		end
	end
	return unpack(talents);
end

PlayerSpecFrame_HelpPlate = {
	FramePos = { x = 0,	y = -22 },
	FrameSize = { width = 645, height = 446	},
	[1] = { ButtonPos = { x = 88,	y = -22 }, HighLightBox = { x = 8, y = -30, width = 204, height = 382 },	ToolTipDir = "UP",		ToolTipText = SPEC_FRAME_HELP_1 },
	[2] = { ButtonPos = { x = 570,	y = -22 }, HighLightBox = { x = 224, y = -6, width = 414, height = 408 },	ToolTipDir = "RIGHT",	ToolTipText = SPEC_FRAME_HELP_2 },
	[3] = { ButtonPos = { x = 355,	y = -409}, HighLightBox = { x = 268, y = -418, width = 109, height = 26 },	ToolTipDir = "RIGHT",	ToolTipText = SPEC_FRAME_HELP_3 },
}

PlayerTalentFrame_HelpPlate = {
	FramePos = { x = 0,	y = -22 },
	FrameSize = { width = 645, height = 446	},
	[1] = { ButtonPos = { x = 300,	y = -27 }, HighLightBox = { x = 8, y = -48, width = 627, height = 55 },		ToolTipDir = "UP",		ToolTipText = TALENT_FRAME_HELP_1 },
	[2] = { ButtonPos = { x = 15,	y = -206 }, HighLightBox = { x = 8, y = -105, width = 627, height = 308 },	ToolTipDir = "RIGHT",	ToolTipText = TALENT_FRAME_HELP_2 },
}

function PlayerTalentFrame_ToggleTutorial()
	local tutorial, helpPlate, mainHelpButton = PlayerTalentFrame_GetTutorial();

	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) and PlayerTalentFrame:IsShown()) then
		HelpPlate_Show( helpPlate, PlayerTalentFrame, mainHelpButton );
		SetCVarBitfield( "closedInfoFrames", tutorial, true );
	else
		HelpPlate_Hide(true);
	end
end

-- PlayerTalentFrameRows

function PlayerTalentFrameRow_OnEnter(self)
	self.TopLine:Show();
	self.BottomLine:Show();
	if ( self.GlowFrame ) then
		self.GlowFrame:Hide();
	end
end

function PlayerTalentFrameRow_OnLeave(self)
	self.TopLine:Hide();
	self.BottomLine:Hide();
	if ( self.shouldGlow ) then
		self.GlowFrame:Show();
	end
end

local function HandleGeneralTalentFrameChatLink(self, talentName, talentLink)
	if ( MacroFrameText and MacroFrameText:HasFocus() ) then
		local spellName, subSpellName = GetSpellInfo(talentName);
		if ( spellName and not IsPassiveSpell(spellName) ) then
			if ( subSpellName and (strlen(subSpellName) > 0) ) then
				ChatEdit_InsertLink(spellName.."("..subSpellName..")");
			else
				ChatEdit_InsertLink(spellName);
			end
		end
	elseif ( talentLink ) then
		ChatEdit_InsertLink(talentLink);
	end
end

local function HandleTalentFrameChatLink(self)
	local _, name = GetTalentInfoByID(self:GetID(), specs[selectedSpec].talentGroup, false);
	local link = GetTalentLink(self:GetID());
	HandleGeneralTalentFrameChatLink(self, name, link);
end

local function HandlePVPTalentFrameChatLink(self)
	local _, name = GetPvpTalentInfoByID(self.pvpTalentID, specs[selectedSpec].talentGroup);
	local link = GetPvpTalentLink(self.pvpTalentID);
	HandleGeneralTalentFrameChatLink(self, name, link);
end

-- PlayerTalentFrameTalents
function PlayerTalentFrameTalent_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		HandleTalentFrameChatLink(self);
	elseif ( selectedSpec and (activeSpec == selectedSpec)) then
        local talentID = self:GetID()
		local _, _, _, _, available, _, _, _, _, known = GetTalentInfoByID(talentID, specs[selectedSpec].talentGroup, true);
		if ( available and not known and button == "LeftButton") then
            return LearnTalent(talentID);
		end
	end
	return false;
end

function PlayerTalentFrameTalent_OnDrag(self, button)
	PickupTalent(self:GetID());
end

function PlayerTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(self:GetID(),
		PlayerTalentFrame.inspect, PlayerTalentFrame.talentGroup);
	end
end

function PlayerTalentFrameTalent_OnEnter(self)
	PlayerTalentFrameRow_OnEnter(self:GetParent());
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetTalent(self:GetID(), PlayerTalentFrame.inspect, PlayerTalentFrame.talentGroup);
	self.UpdateTooltip = PlayerTalentFrameTalent_OnEnter;
end

function PlayerTalentFrameTalent_OnLeave(self)
	PlayerTalentFrameRow_OnLeave(self:GetParent());
	GameTooltip_Hide();
end

-- Controls

function PlayerTalentFrame_UpdateControls(activeTalentGroup, numTalentGroups)
	local spec = selectedSpec and specs[selectedSpec];
	local isActiveSpec = selectedSpec == activeSpec;
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if (not activeTalentGroup or not numTalentGroups) then
		activeTalentGroup, numTalentGroups = GetActiveSpecGroup(false), GetNumSpecGroups(false);
	end

	-- show the activate button if this is not the active spec
	PlayerTalentFrameActivateButton_Update(numTalentGroups);
end

function PlayerTalentFrameActivateButton_OnLoad(self)
	self:SetWidth(self:GetTextWidth() + 40);
end

function PlayerTalentFrameActivateButton_OnClick(self)
	if ( selectedSpec ) then
		local talentGroup = specs[selectedSpec].talentGroup;
		if ( talentGroup ) then
			--SetActiveSpecGroup(talentGroup);
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
	local numTalentGroups = GetNumSpecGroups(false);
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


-- PlayerTalentFrameTab

function PlayerTalentFrame_UpdateTabs(playerLevel)
	local totalTabWidth = 0;
	local firstShownTab = _G["PlayerTalentFrameTab"..SPECIALIZATION_TAB];
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame) or SPECIALIZATION_TAB;
	local numVisibleTabs = 0;
	local tab;
	playerLevel = playerLevel or UnitLevel("player");

	-- setup specialization tab
	talentTabWidthCache[SPECIALIZATION_TAB] = 0;
	tab = _G["PlayerTalentFrameTab"..SPECIALIZATION_TAB];
	if ( tab ) then
		tab:Show();
		firstShownTab = firstShownTab or tab;
		PanelTemplates_TabResize(tab, 0);
		talentTabWidthCache[SPECIALIZATION_TAB] = PanelTemplates_GetTabWidth(tab);
		totalTabWidth = totalTabWidth + talentTabWidthCache[SPECIALIZATION_TAB];
		numVisibleTabs = numVisibleTabs+1;
	end

	-- setup talents talents tab
	local meetsTalentLevel = playerLevel >= SHOW_TALENT_LEVEL;
	talentTabWidthCache[TALENTS_TAB] = 0;
	tab = _G["PlayerTalentFrameTab"..TALENTS_TAB];
	if ( tab ) then
		if ( meetsTalentLevel ) then
			tab:Show();
			firstShownTab = firstShownTab or tab;
			PanelTemplates_TabResize(tab, 0);
			talentTabWidthCache[TALENTS_TAB] = PanelTemplates_GetTabWidth(tab);
			totalTabWidth = totalTabWidth + talentTabWidthCache[TALENTS_TAB];
			numVisibleTabs = numVisibleTabs+1;
		else
			tab:Hide();
		end
	end

	local meetsPvpTalentLevel = playerLevel >= SHOW_PVP_TALENT_LEVEL;
	talentTabWidthCache[PVP_TALENTS_TAB] = 0;
	tab = _G["PlayerTalentFrameTab"..PVP_TALENTS_TAB];
	if ( tab ) then
		if ( meetsPvpTalentLevel ) then
			tab:Show();
			firstShownTab = firstShownTab or tab;
			PanelTemplates_TabResize(tab, 0);
			talentTabWidthCache[PVP_TALENTS_TAB] = PanelTemplates_GetTabWidth(tab);
			totalTabWidth = totalTabWidth + talentTabWidthCache[PVP_TALENTS_TAB];
			numVisibleTabs = numVisibleTabs+1;
		else
			tab:Hide();
		end
	end

	if (NUM_TALENT_FRAME_TABS == 4) then
		-- setup pet specialization tab
		talentTabWidthCache[PET_SPECIALIZATION_TAB] = 0;
		tab = _G["PlayerTalentFrameTab"..PET_SPECIALIZATION_TAB];
		if ( tab ) then
			tab:Show();
			firstShownTab = firstShownTab or tab;
			PanelTemplates_TabResize(tab, 0);
			talentTabWidthCache[PET_SPECIALIZATION_TAB] = PanelTemplates_GetTabWidth(tab);
			totalTabWidth = totalTabWidth + talentTabWidthCache[PET_SPECIALIZATION_TAB];
			numVisibleTabs = numVisibleTabs+1;
		end
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

	HelpPlate_Hide();
	local tutorial, helpPlate, mainHelpButton = PlayerTalentFrame_GetTutorial();
	if ( helpPlate and tutorial and not GetCVarBitfield("closedInfoFrames", tutorial)
		and GetCVarBool("showTutorials") and PlayerTalentFrame:IsShown()) then
		HelpPlate_ShowTutorialPrompt( helpPlate, mainHelpButton );
		SetCVarBitfield( "closedInfoFrames", tutorial, true );
	end
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
	if (UnitLevel("player") == SHOW_TALENT_LEVEL and (GetNumUnspentTalents() > 0) and (self:GetID() == TALENTS_TAB)) then
		SetButtonPulse(self, 60, 0.75);
	end
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
	TalentFrame_UpdateSpecInfoCache(talentSpecInfoCache[specIndex], false, false, spec.talentGroup);

	-- update spec tab icon
	if ( hasMultipleTalentGroups ) then
		local primaryTree = GetSpecialization(false, false, spec.talentGroup);

		local specInfoCache = talentSpecInfoCache[specIndex];
		if ( primaryTree and primaryTree > 0 and specInfoCache) then
			-- the spec had a primary tab, set the icon to that tab's icon
			normalTexture:SetTexture(specInfoCache[primaryTree].icon);
		else
			if ( spec.defaultSpecTexture ) then
				-- the spec is probably untalented...set to the default spec texture if we have one
				normalTexture:SetTexture(spec.defaultSpecTexture);
			end
		end
	end

	self:Show();
	return true;
end

function PlayerSpecTab_Load(self, specIndex)
	self.specIndex = specIndex;
	specTabs[specIndex] = self;
	numSpecTabs = numSpecTabs + 1;

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

	local activeTalentGroup, numTalentGroups = GetActiveSpecGroup(false), GetNumSpecGroups(false);
	PlayerSpecTab_Update(self, activeTalentGroup, numTalentGroups);
end

function PlayerSpecTab_OnClick(self)
	-- set all specs as unchecked initially
	for _, frame in next, specTabs do
		frame:SetChecked(false);
	end

	-- check ourselves (before we wreck ourselves)
	self:SetChecked(true);

	-- update the selected to this spec
	PlayerTalentFrame.selectedPlayerSpec = self.specIndex;

	-- select a tab if one is not already selected
	if ( not PanelTemplates_GetSelectedTab(PlayerTalentFrame) ) then
		PanelTemplates_SetTab(PlayerTalentFrame, SPECIALIZATION_TAB);
	end

	-- update the talent frame
	PlayerTalentFrame_Refresh();
end

function PlayerSpecTab_OnEnter(self)
	local specIndex = self.specIndex;
	local spec = specs[specIndex];
	if ( spec.specNameActive and spec.specName ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		-- name
		if ( GetNumSpecGroups(false) <= 1) then
			-- set the tooltip to be the unit's name
			GameTooltip:AddLine(UnitName("player"), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		else
			if ( self.specIndex == activeSpec ) then
				GameTooltip:AddLine(spec.specNameActive);
			else
				GameTooltip:AddLine(spec.specName);
			end
		end
		GameTooltip:Show();
	end
end

function PlayerSpecSpellTemplate_OnEnter(self)
    local specFrame = self:GetParent():GetParent():GetParent();
	local shownSpec = specFrame.previewSpec;
	local isPet = specFrame.isPet;
	local sex = isPet and UnitSex("pet") or UnitSex("player");
	local id = GetSpecializationInfo(shownSpec, nil, isPet, nil, sex);
    if (not id or not self.spellID) then
		return;
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if (id and SPEC_CORE_ABILITY_TEXT[id]) then
		local spellName = GetSpellInfo(self.spellID);
		GameTooltip:SetText(spellName, HIGHLIGHT_FONT_COLOR:GetRGB());
		local r, g, b = NORMAL_FONT_COLOR:GetRGB();
        GameTooltip:AddLine(_G[SPEC_CORE_ABILITY_TEXT[id].."_CORE_ABILITY_"..self.index], r, g, b, true);
	else
		GameTooltip:SetSpellByID(self.spellID, false, false, true);
		if ( self.extraTooltip ) then
			GameTooltip:AddLine(self.extraTooltip);
		end
	end
	GameTooltip:Show();
end

function PlayerTalentFrame_CreateSpecSpellButton(self, index)
	local scrollChild = self.spellsScroll.child;
	local frame = CreateFrame("BUTTON", scrollChild:GetName().."Ability"..index, scrollChild, "PlayerSpecSpellTemplate");
	scrollChild["abilityButton"..index] = frame;
	return frame;
end

function SpecButton_OnEnter(self)
	if ( not self.selected ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:AddLine(self.tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:SetMinimumWidth(300, true);
		GameTooltip:Show();
	end
end

function SpecButton_OnLeave(self)
	GameTooltip:SetMinimumWidth(0, false);
	GameTooltip:Hide();
end

function SpecButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	self:GetParent().spellsScroll.ScrollBar:SetValue(0);
	PlayerTalentFrame_UpdateSpecFrame(self:GetParent(), self:GetID());
	GameTooltip:Hide();
end

function PlayerTalentFrame_UpdateSpecFrame(self, spec)
	local playerTalentSpec = GetSpecialization(nil, self.isPet, specs[selectedSpec].talentGroup);
	local shownSpec = spec or playerTalentSpec or 1;
	local numSpecs = GetNumSpecializations(nil, self.isPet);
	local petNotActive = self.isPet and not IsPetActive();
	local sex = self.isPet and UnitSex("pet") or UnitSex("player");
	-- do spec buttons
	for i = 1, numSpecs do
		local button = self["specButton"..i];
		local disable = false;
		if ( i == shownSpec ) then
			button.selected = true;
			button.selectedTex:Show();
		else
			button.selected = false;
			button.selectedTex:Hide();
		end
		if ( i == playerTalentSpec ) then
			button.learnedTex:Show();
		else
			button.learnedTex:Hide();
		end
		if ( selectedSpec == activeSpec and ( not playerTalentSpec or i == playerTalentSpec ) ) then
			button.bg:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
		else
			button.bg:SetTexCoord(0.00390625, 0.87890625, 0.67187500, 0.75000000);
			disable = true;
		end

		if ( petNotActive ) then
			disable = true;
		end

		if ( disable and not button.disabled ) then
			button.disabled = true;
			SetDesaturation(button.specIcon, true);
			SetDesaturation(button.roleIcon, true);
			SetDesaturation(button.ring, true);
			button.specName:SetFontObject("GameFontDisable");
		elseif ( not disable and button.disabled ) then
			button.disabled = false;
			SetDesaturation(button.specIcon, false);
			SetDesaturation(button.roleIcon, false);
			SetDesaturation(button.ring, false);
			button.specName:SetFontObject("GameFontNormal");
		end
	end

	-- save viewed spec for Learn button
	self.previewSpec = shownSpec;

	-- display spec info in the scrollframe
	local scrollChild = self.spellsScroll.child;
	local id, name, description, icon, background, _, primaryStat = GetSpecializationInfo(shownSpec, nil, self.isPet, nil, sex);
	local primarySpecID = GetPrimarySpecialization();
	self.previewSpecCost = (id ~= primarySpecID) and GetSpecChangeCost() or nil;
	SetPortraitToTexture(scrollChild.specIcon, icon);
	scrollChild.specName:SetText(name);
	scrollChild.description:SetText(description);
	local role1 = GetSpecializationRole(shownSpec, nil, self.isPet);
	if ( role1 ) then
		scrollChild.roleName:SetText(_G[role1]);
		scrollChild.roleIcon:SetTexCoord(GetTexCoordsForRole(role1));
	end

	-- update spec button names
	for i = 1, numSpecs do
		local button = self["specButton"..i];
		local id, name, description, icon = GetSpecializationInfo(i, false, self.isPet, nil, sex);
		button.specName:SetText(name);
	end

	if ( not self.isPet and primaryStat and primaryStat ~= 0 ) then
		scrollChild.roleName:ClearAllPoints();
		scrollChild.roleName:SetPoint("BOTTOMLEFT", "$parentRoleIcon", "RIGHT", 3, 2);
		scrollChild.primaryStat:SetText(SPEC_FRAME_PRIMARY_STAT:format(SPEC_STAT_STRINGS[primaryStat]));
	else
		scrollChild.roleName:ClearAllPoints();
		scrollChild.roleName:SetPoint("BOTTOMLEFT", "$parentRoleIcon", "RIGHT", 3, -9);
		scrollChild.primaryStat:SetText(nil);
	end

	-- disable stuff if not in active spec or have picked a specialization and not looking at it
	local disable = ( playerTalentSpec and shownSpec ~= playerTalentSpec ) or petNotActive;
	if ( disable and not self.disabled ) then
		self.disabled = true;
		self.bg:SetDesaturated(true);
		scrollChild.description:SetTextColor(0.75, 0.75, 0.75);
		scrollChild.roleName:SetTextColor(0.75, 0.75, 0.75);
		scrollChild.primaryStat:SetTextColor(0.75, 0.75, 0.75);
--		scrollChild.coreabilities:SetTextColor(0.75, 0.75, 0.75);
		scrollChild.specIcon:SetDesaturated(true);
		scrollChild.roleIcon:SetDesaturated(true);
		scrollChild.ring:SetDesaturated(true);
		scrollChild.gradient:SetDesaturated(true);
--		scrollChild.scrollwork_left:SetDesaturated(true);
--		scrollChild.scrollwork_right:SetDesaturated(true);
		scrollChild.Seperator:SetDesaturated(true);
		scrollChild.scrollwork_topleft:SetDesaturated(true);
		scrollChild.scrollwork_topright:SetDesaturated(true);
		scrollChild.scrollwork_bottomleft:SetDesaturated(true);
		scrollChild.scrollwork_bottomright:SetDesaturated(true);
	elseif ( not disable and self.disabled ) then
		self.disabled = false;
		self.bg:SetDesaturated(false);
		scrollChild.description:SetTextColor(1.0, 1.0, 1.0);
		scrollChild.roleName:SetTextColor(1.0, 1.0, 1.0);
		scrollChild.primaryStat:SetTextColor(1.0, 1.0, 1.0);
--		scrollChild.coreabilities:SetTextColor(0.878, 0.714, 0.314);
		scrollChild.specIcon:SetDesaturated(false);
		scrollChild.roleIcon:SetDesaturated(false);
		scrollChild.ring:SetDesaturated(false);
		scrollChild.gradient:SetDesaturated(false);
--		scrollChild.scrollwork_left:SetDesaturated(false);
--		scrollChild.scrollwork_right:SetDesaturated(false);
		scrollChild.Seperator:SetDesaturated(false);
		scrollChild.scrollwork_topleft:SetDesaturated(false);
		scrollChild.scrollwork_topright:SetDesaturated(false);
		scrollChild.scrollwork_bottomleft:SetDesaturated(false);
		scrollChild.scrollwork_bottomright:SetDesaturated(false);
	end

	-- disable Learn button
	local disableLearnButton = ( playerTalentSpec and shownSpec == playerTalentSpec ) or petNotActive;
	if ( self.isPet and disableLearnButton ) then
		self.learnButton:Disable();
		self.learnButton.Flash:Hide();
		self.learnButton.FlashAnim:Stop();
	--elseif ( playerTalentSpec or disable or UnitLevel("player") < SHOW_SPEC_LEVEL ) then
    elseif(disableLearnButton or UnitLevel("player") < SHOW_SPEC_LEVEL or IsKioskModeEnabled()) then
		self.learnButton:Disable();
		self.learnButton.Flash:Hide();
		self.learnButton.FlashAnim:Stop();
	else
		self.learnButton:Enable();
		self.learnButton.Flash:Show();
		self.learnButton.FlashAnim:Play();
	end

	if ( self.playLearnAnim ) then
		self.playLearnAnim = false;
		self["specButton"..shownSpec].animLearn:Play();
	end

	-- set up spells
	local index = 1;
	local bonuses
	if ( self.isPet ) then
		bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet, true)};
	else
		bonuses = SPEC_SPELLS_DISPLAY[id];
	end
	if ( bonuses ) then
		for i=1,#bonuses,2 do
			local frame = scrollChild["abilityButton"..index];
			if not frame then
				frame = PlayerTalentFrame_CreateSpecSpellButton(self, index);
			end
			if ( mod(index, 2) == 0 ) then
				frame:SetPoint("LEFT", scrollChild["abilityButton"..(index-1)], "RIGHT", 110, 0);
			else
				if ((#bonuses/2) > 4 ) then
					frame:SetPoint("TOP", scrollChild["abilityButton"..(index-2)], "BOTTOM", 0, 0);
				else
					frame:SetPoint("TOP", scrollChild["abilityButton"..(index-2)], "BOTTOM", 0, -20);
				end
			end

			local name, subname = GetSpellInfo(bonuses[i]);
			local _, icon = GetSpellTexture(bonuses[i]);
			SetPortraitToTexture(frame.icon, icon);
			frame.name:SetText(name);
			frame.spellID = bonuses[i];
			frame.extraTooltip = nil;
			frame.isPet = self.isPet;
			frame.index = index;

			local isKnown = IsSpellKnownOrOverridesKnown(bonuses[i]);
			if ( not isKnown and IsCharacterNewlyBoosted() and not disable ) then
				frame.disabled = false;
				frame.icon:SetDesaturated(true);
				frame.icon:SetAlpha(0.5);
				frame.ring:SetDesaturated(false);
				frame.subText:SetTextColor(0.25, 0.1484375, 0.02);
				frame.subText:SetText(BOOSTED_CHAR_SPELL_TEMPLOCK);
			else
				frame.icon:SetAlpha(1);
				local level = GetSpellLevelLearned(bonuses[i]);
				local spellLocked = level and level > UnitLevel("player");
				if ( spellLocked ) then
					frame.subText:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
				else
					frame.subText:SetText("");
				end
				if ( disable ) then
					frame.disabled = true;
					frame.icon:SetDesaturated(true);
					frame.icon:SetAlpha(1);
					frame.ring:SetDesaturated(true);
					frame.subText:SetTextColor(0.75, 0.75, 0.75);
				else
					frame.disabled = false;
					if ( spellLocked ) then
						frame.icon:SetDesaturated(true);
						frame.icon:SetAlpha(0.5);
					else
						frame.icon:SetDesaturated(false);
						frame.icon:SetAlpha(1);
					end
					frame.ring:SetDesaturated(false);
					frame.subText:SetTextColor(0.25, 0.1484375, 0.02);
				end
			end
			frame:Show();
			index = index + 1;
		end
	end

	-- hide unused spell buttons
	local frame = scrollChild["abilityButton"..index];
	while frame do
		frame:Hide();
		frame.spellID = nil;
		index = index + 1;
		frame = scrollChild["abilityButton"..index];
	end
end

function PlayerTalentFrameTalents_OnLoad(self)
	local _, class = UnitClass("player");
	local talentLevels = CLASS_TALENT_LEVELS[class] or CLASS_TALENT_LEVELS["DEFAULT"];
	for i=1, MAX_TALENT_TIERS do
		self["tier"..i].level:SetText(talentLevels[i]);
	end

	-- Setup table to support immediate UI updates when picking talents
	self.talentInfo = {};
end

function PlayerTalentFrameTalents_OnShow(self)
	local playerLevel = UnitLevel("player");
	if ( playerLevel >= SHOW_TALENT_LEVEL and AreTalentsLocked() ) then
		PlayerTalentFrameLockInfo:Show();
		PlayerTalentFrameLockInfo.Title:SetText(TALENTS_FRAME_TALENT_LOCK_TITLE);
		PlayerTalentFrameLockInfo.Text:SetText(TALENTS_FRAME_TALENT_LOCK_DESC)
		PlayerTalentFrameTalentsTutorialButton:Hide();
	else
		PlayerTalentFrameLockInfo:Hide();
		PlayerTalentFrameTalentsTutorialButton:Show();
	end
end

function PlayerTalentFrameTalents_OnHide(self)
	PlayerTalentFrameLockInfo:Hide();
end


PVP_TALENT_TUTORIAL_INFO = {};
function PlayerTalentFramePVPTalents_SetUpTutorialInfo(self)
    PVP_TALENT_TUTORIAL_INFO[LE_FRAME_TUTORIAL_HONOR_TALENT_FIRST_TALENT] = {
        anchor = self.Talents.Tier1.Talent1,
        anchorPoint = "LEFT",
        relativePoint = "RIGHT",
        xoffset = 20,
        text = HONOR_TALENT_FIRST_TALENT,
        direction = "left",
        clearOnClose = false,
    };
    PVP_TALENT_TUTORIAL_INFO[LE_FRAME_TUTORIAL_HONOR_TALENT_HONOR_LEVELS] = {
        anchor = self.XPBar,
        anchorPoint = "BOTTOM",
        relativePoint = "TOP",
        xoffset = 14,
        yoffset = 16,
        text = HONOR_TALENT_HONOR_LEVELS,
        direction = "down",
        clearOnClose = true,
    };
    PVP_TALENT_TUTORIAL_INFO[LE_FRAME_TUTORIAL_HONOR_TALENT_PRESTIGE] = {
        anchor = self.XPBar.PrestigeReward.Accept,
        anchorPoint = "LEFT",
        relativePoint = "RIGHT",
        xoffset = 20,
        text = HONOR_TALENT_CAN_NOW_PRESTIGE,
        direction = "left",
        clearOnClose = true,
    };
end

function PlayerTalentFramePVPTalents_OnLoad(self)
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	self:RegisterEvent("HONOR_PRESTIGE_UPDATE");
	self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE");
	self:RegisterEvent("PLAYER_LEARN_PVP_TALENT_FAILED");
	self:RegisterEvent("PRESTIGE_AND_HONOR_INVOLUNTARILY_CHANGED");

	self.talentInfo = {};

    PlayerTalentFramePVPTalents_SetUpTutorialInfo(self);
end

function PlayerTalentFramePVPTalents_OnShow(self)
	PVPTalentFrame_Update(self);
end

function PlayerTalentFramePVPTalents_SetUp(self)
	local parent = self:GetParent();
	local factionGroup = UnitFactionGroup("player");
	local prestigeLevel = UnitPrestige("player");
	local numTalentGroups = GetNumSpecGroups(false);

	parent.Inset:SetPoint("TOPLEFT", 4, -110);
	PlayerTalentFrame_UpdateTitleText(numTalentGroups);

	if (prestigeLevel > 0) then
		self.PortraitBackground:SetAtlas("honorsystem-prestige-laurel-bg-"..factionGroup, false);
		self.PortraitBackground:Show();
		parent.portrait:SetSize(57,57);
		parent.portrait:ClearAllPoints();
		parent.portrait:SetPoint("CENTER", self.PortraitBackground, "CENTER", 0, 0);
		parent.portrait:SetTexture(GetPrestigeInfo(UnitPrestige("player")));
		parent.portrait:SetTexCoord(0, 1, 0, 1);
	end
	self.SmallWreath:SetShown(prestigeLevel > 0);
end

function PlayerTalentFramePVPTalents_OnHide(self)
	local parent = self:GetParent();
	local _, class = UnitClass("player");
	self.PortraitBackground:Hide();
	parent.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
	parent.portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]));
	parent.portrait:SetSize(61, 61);
	parent.portrait:ClearAllPoints();
	parent.portrait:SetPoint("TOPLEFT", -6, 8);
end

function PlayerTalentFramePVPTalents_OnEvent(self, event)
	if (event == "HONOR_XP_UPDATE" or event == "HONOR_PRESTIGE_UPDATE" or event == "HONOR_LEVEL_UPDATE" or event == "PRESTIGE_AND_HONOR_INVOLUNTARILY_CHANGED") then
		PVPTalentFrame_Update(self);
	elseif (event == "PLAYER_PVP_TALENT_UPDATE") then
		PVPTalentFrame_Update(self);
	elseif (event == "PLAYER_LEARN_PVP_TALENT_FAILED") then
		local failedTalents = GetFailedPVPTalentIDs();

		for i = 1, #failedTalents do
			local talentID = failedTalents[i];
			local row = select(8, GetPvpTalentInfoByID(talentID, PlayerTalentFrame.talentGroup));
			if (self.talentInfo[row] == talentID) then
				self.talentInfo[row] = nil;
			end
		end
		PVPTalentFrame_Update(self);
		ClearFailedPVPTalentIDs();
	end
end

function PlayerTalentFramePVPTalents_LockButton(button)
	button.Icon:SetDesaturated(true);
	button.knownSelection:Hide();
	button.disabled = true;
	button.Cover:Show();
end

function PlayerTalentFramePVPTalents_UnlockButton(button, isActiveTalentGroup)
	button.Icon:SetDesaturated(not isActiveTalentGroup);
	button.Cover:Hide();
	button.disabled = not isActiveTalentGroup;
end

function PlayerTalentFramePVPTalentsTalent_OnEnter(self)
	PlayerTalentFrameRow_OnEnter(self:GetParent());
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetPvpTalent(self.pvpTalentID, PlayerTalentFrame.inspect, GetActiveSpecGroup());
	GameTooltip:Show();
end

function PlayerTalentFramePVPTalentsTalent_OnLeave(self)
	PlayerTalentFrameRow_OnLeave(self:GetParent());
	GameTooltip:Hide();
end

function PlayerTalentFramePVPTalentsTalent_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		HandlePVPTalentFrameChatLink(self);
	elseif ( selectedSpec and (activeSpec == selectedSpec)) then
		local id, _, _, selected, available, _, _, _, _, known = GetPvpTalentInfoByID(self.pvpTalentID);
		if ( button == "LeftButton" and not selected ) then
			local talentsFrame = PlayerTalentFramePVPTalents;
			local row = self:GetParent().rowIndex;
			if (talentsFrame.talentInfo[row]) then
				-- We recently clicked on a talent and are waiting for the server response; don't let the user click again
				UIErrorsFrame:AddMessage(TALENT_CLICK_TOO_FAST, 1.0, 0.1, 0.1, 1.0);
				return;
			elseif (UnitAffectingCombat("player")) then
				-- Disallow selecting a talent while in combat
				UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0);
				return;
			end

			-- Pretend like we immediately got the talent by de-selecting the old talent and selecting the new one
			PlaySound("igMainMenuOptionCheckBoxOn");

			if (not known) then
				talentsFrame.talentInfo[row] = id;

				local isRowFree, prevSelected = GetPvpTalentRowSelectionInfo(row);
				if (not isRowFree) then
					RemovePvpTalent(prevSelected);
				end
				if (not LearnPvpTalent(id)) then
					talentsFrame.talentInfo[row] = nil;
				end
				PVPTalentFrame_Update(PlayerTalentFramePVPTalents);
			end
		end
	end
end

function PlayerTalentFramePVPTalentsPortraitMouseOverFrame_OnEnter(self)
	local prestige = UnitPrestige("player");
	if (prestige > 0) then
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("LEFT", self, "RIGHT", 4, 0);
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:SetText(select(2, GetPrestigeInfo(prestige)), 1, 1, 1, nil, true);
		GameTooltip:AddLine(" ");
		for i = 1, GetMaxPrestigeLevel() do
			local color;
			if (prestige == i) then
				color = GREEN_FONT_COLOR;
			else
				color = NORMAL_FONT_COLOR;
			end
            local texture, name = GetPrestigeInfo(i);
			GameTooltip:AddLine(PRESTIGE_RANK_TOOLTIP_LINE:format(texture, name), color.r, color.g, color.b);
		end
		GameTooltip:Show();
	end
end

function PlayerTalentFramePVPTalentsTalent_OnDrag(self, button)
	PickupPvpTalent(self.pvpTalentID);
end

local function InitializePVPTalentsXPBarDropDown(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.text = SHOW_FACTION_ON_MAINSCREEN;
	info.checked = IsWatchingHonorAsXP();
	info.func = function(_, _, _, value)
		if ( value ) then
			PlaySound("igMainMenuOptionCheckBoxOff");
			SetWatchingHonorAsXP(false);
		else
			PlaySound("igMainMenuOptionCheckBoxOn");
			SetWatchingHonorAsXP(true);
			SetWatchedFactionIndex(0);
		end

		MainMenuBar_UpdateExperienceBars();
	end

	UIDropDownMenu_AddButton(info, level);

	info.notCheckable = true;
	info.checked = false;
	info.text = CANCEL;

	UIDropDownMenu_AddButton(info, level);
end

function PlayerTalentFramePVPTalentsXPBar_OnClick(self, button)
	if (button == "RightButton") then
		UIDropDownMenu_Initialize(self.DropDown, InitializePVPTalentsXPBarDropDown, "MENU");
		ToggleDropDownMenu(1, nil, self.DropDown, self, 310, 12);
	end
end

function PlayerTalentFramePVPTalents_ShowTutorial(tutorial)
    local tutorialInfo = PVP_TALENT_TUTORIAL_INFO[tutorial];

    if (not tutorialInfo) then
        return;
    end

    local self = PlayerTalentFramePVPTalents;

    if not self.TutorialBox:IsShown() and not GetCVarBitfield("closedInfoFrames", tutorial) then
        self.TutorialBox.activeTutorial = tutorialInfo.clearOnClose and tutorial or nil;

        self.TutorialBox.Text:SetText(tutorialInfo.text);

        local orientation, offset, point, relativePoint;
        if ( tutorialInfo.direction == "left" ) then
            orientation = 90;
            xoffset = 3;
            yoffset = 0;
            point = "RIGHT";
            relativePoint = "LEFT";
        elseif ( tutorialInfo.direction == "right" ) then
            orientation = 270;
            xoffset = -3;
            yoffset = 0;
            point = "LEFT";
            relativePoint = "RIGHT";
        elseif ( tutorialInfo.direction == "down" ) then
            orientation = 0;
            xoffset = 0;
            yoffset = 3;
            point = "TOP";
            relativePoint = "BOTTOM";
        end

        SetClampedTextureRotation(self.TutorialBox.Arrow.Arrow, orientation);
        SetClampedTextureRotation(self.TutorialBox.Arrow.Glow, orientation);
        self.TutorialBox.Arrow.Arrow:ClearAllPoints()
        self.TutorialBox.Arrow.Glow:ClearAllPoints()
        self.TutorialBox.Arrow.Arrow:SetPoint(point, self.TutorialBox, relativePoint, xoffset, yoffset);
        self.TutorialBox.Arrow.Glow:SetPoint(point, self.TutorialBox, relativePoint, xoffset, yoffset);

        self.TutorialBox:ClearAllPoints();
        self.TutorialBox:SetPoint(tutorialInfo.anchorPoint, tutorialInfo.anchor, tutorialInfo.relativePoint, tutorialInfo.xoffset or 0, tutorialInfo.yoffset or 0);

        self.TutorialBox:Show();
    end
end

function PlayerTalentButton_OnClick(self, button)
	-- With 1-click talent selection, there is a significant amount of lag between clicking the talent and
	-- getting the server message back saying that your talents have been updated. To make the UI feel more
	-- responsive, we update the UI immediately as if we got the server response. Then we lock that row so
	-- that the user cannot try and update that talent row until we receive a response back from the server.

	local talentRow = self:GetParent();
	local talentsFrame = talentRow:GetParent();
	if (talentsFrame.talentInfo[self.tier]) then
		-- We recently clicked on a talent and are waiting for the server response; don't let the user click again
		UIErrorsFrame:AddMessage(TALENT_CLICK_TOO_FAST, 1.0, 0.1, 0.1, 1.0);
		return;
	elseif (self.disabled and IsModifiedClick("CHATLINK")) then
		HandleTalentFrameChatLink(self);
	elseif (not self.disabled) then
		if (UnitAffectingCombat("player")) then
			-- Disallow selecting a talent while in combat
			UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0);
			return;
		end

		-- Pretend like we immediately got the talent by de-selecting the old talent and selecting the new one
		PlaySound("igMainMenuOptionCheckBoxOn");
		local learn = PlayerTalentFrameTalent_OnClick(self, button);

		if (learn) then
			talentsFrame.talentInfo[self.tier] = self.column;

			-- Highlight this talent
			self.knownSelection:Show();
			self.icon:SetDesaturated(false);

			-- Deselect the other talents in this row and grey out the level text
			for i = 1, #talentRow.talents do
				if (i ~= self.column) then
					local oldTalentButton = talentRow.talents[i];
					oldTalentButton.knownSelection:Hide();
					oldTalentButton.icon:SetDesaturated(true);
				end
			end
			if(talentRow.level ~= nil) then
				talentRow.level:SetTextColor(0.5, 0.5, 0.5);
			end
		end
	end
end

function PlayerPVPTalentButton_OnClick(self, button)
	if (self.disabled and IsModifiedClick("CHATLINK")) then
		HandlePVPTalentFrameChatLink(self);
	elseif (not self.disabled) then
		PlayerTalentFramePVPTalentsTalent_OnClick(self, button);
	end
end