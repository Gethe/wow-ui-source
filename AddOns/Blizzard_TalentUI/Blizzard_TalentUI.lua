

StaticPopupDialogs["CONFIRM_REMOVE_TALENT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == GetActiveSpecGroup() ) then
			RemoveTalent(self.data.id);
		end
	end,
	OnShow = function(self)
		local name = GetTalentInfo(self.data.id);
		local resourceName, count, _, _, cost = GetTalentClearInfo();
		if cost == 0 then
			self.text:SetFormattedText(CONFIRM_REMOVE_GLYPH_NO_COST, name);
		elseif count >= cost then
			self.text:SetFormattedText(CONFIRM_REMOVE_GLYPH, name, GREEN_FONT_COLOR_CODE, cost, resourceName);
		else
			self.text:SetFormattedText(CONFIRM_REMOVE_GLYPH, name, RED_FONT_COLOR_CODE, cost, resourceName);
			self.button1:Disable();
		end
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_UNLEARN_AND_SWITCH_TALENT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == GetActiveSpecGroup() ) then
			RemoveTalent(self.data.oldID);
			PlayerTalentFrame_SelectTalent(self.data.id);
		end
	end,
	OnShow = function(self)
		local name = GetTalentInfo(self.data.id);
		local oldName = GetTalentInfo(self.data.oldID);
		local resourceName, count, _, _, cost = GetTalentClearInfo();
		if cost == 0 then
			self.text:SetFormattedText(CONFIRM_UNLEARN_AND_SWITCH_TALENT_NO_COST, name, oldName);
		elseif count >= cost then
			self.text:SetFormattedText(CONFIRM_UNLEARN_AND_SWITCH_TALENT, name, oldName, GREEN_FONT_COLOR_CODE, cost, resourceName);
		else
			self.text:SetFormattedText(CONFIRM_UNLEARN_AND_SWITCH_TALENT, name, oldName, RED_FONT_COLOR_CODE, cost, resourceName);
			self.button1:Disable();
		end
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}


StaticPopupDialogs["CONFIRM_LEARN_SPEC"] = {
	text = CONFIRM_LEARN_SPEC,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		SetSpecialization(self.data.previewSpec, self.data.isPet);
		self.data.playLearnAnim = true;
	end,
	OnCancel = function (self)
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
SPECIALIZATION_TAB = 1;
TALENTS_TAB = 2;
GLYPH_TAB = 3;
NUM_TALENT_FRAME_TABS = 3;

local THREE_SPEC_LGBUTTON_HEIGHT = 95;
local SPEC_SCROLL_HEIGHT = 282;
local SPEC_SCROLL_PREVIEW_HEIGHT = 228;

local lastTopLineHighlight = nil;
local lastBottomLineHighlight = nil;

-- speed references
local next = next;
local ipairs = ipairs;

-- local data
local specs = {
	["spec1"] = {
		name = SPECIALIZATION_PRIMARY,
		nameActive = TALENT_SPEC_PRIMARY_ACTIVE,
		glyphName = TALENT_SPEC_PRIMARY_GLYPH,
		glyphNameActive = TALENT_SPEC_PRIMARY_GLYPH_ACTIVE,
		specName = SPECIALIZATION_PRIMARY,
		specNameActive = SPECIALIZATION_PRIMARY_ACTIVE,
		talentGroup = 1,
		tooltip = SPECIALIZATION_PRIMARY,
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
	},
	["spec2"] = {
		name = SPECIALIZATION_SECONDARY,
		nameActive = TALENT_SPEC_SECONDARY_ACTIVE,
		glyphName = TALENT_SPEC_SECONDARY_GLYPH,
		glyphNameActive = TALENT_SPEC_SECONDARY_GLYPH_ACTIVE,
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
SPEC_SPELLS_DISPLAY[62] = { 30451,10, 114664,10, 44425,10, 5143,10 }; --Arcane
SPEC_SPELLS_DISPLAY[63] = {  133,10, 11366,10, 108853,10, 11129,10 }; --Fire
SPEC_SPELLS_DISPLAY[64] = { 116,10, 31687,10, 112965,10, 30455,10 }; --Frost

SPEC_SPELLS_DISPLAY[65] = { 20473,10, 85673,10, 82327,10, 53563,10 }; --Holy
SPEC_SPELLS_DISPLAY[66] = { 35395,10, 20271,10, 31935,10, 53600,10 }; --Protection
SPEC_SPELLS_DISPLAY[70] = { 35395,10, 20271,10, 85256,10, 87138,10, 24275,10 }; --Retribution

SPEC_SPELLS_DISPLAY[71] = { 12294,10, 7384,10, 1464,10, 86346,10 }; --Arms
SPEC_SPELLS_DISPLAY[72] = { 23881,10, 23588,10, 100130,10, 85288,10 }; --Fury
SPEC_SPELLS_DISPLAY[73] = { 23922,10, 20243,10, 6572,10, 2565,10 }; --Protection

SPEC_SPELLS_DISPLAY[102] = { 5176,10, 2912,10, 78674,10, 8921,10, 79577,10 }; --Balance
SPEC_SPELLS_DISPLAY[103] = { 33917,10, 1822,10, 1079,10, 5221,10, 52610,10 }; --Feral
SPEC_SPELLS_DISPLAY[104] = { 33917,10, 33745,10, 62606,10, 22842,10 }; --Guardian
SPEC_SPELLS_DISPLAY[105] = { 774,10, 33763,10, 18562,10, 5185,10 }; --Restoration

SPEC_SPELLS_DISPLAY[250] = { 49998,10, 55050,10, 56815,10, 55233,10, 48982,10, 49028,10 }; --Blood
SPEC_SPELLS_DISPLAY[251] = { 49143,10, 49184,10, 49020,10, 51271,10 }; --Frost
SPEC_SPELLS_DISPLAY[252] = { 55090,10, 85948,10, 49572,10, 63560,10 }; --Unholy

SPEC_SPELLS_DISPLAY[253] = { 34026,10, 77767,10, 3044,10, 19574,10 }; --Beastmaster
SPEC_SPELLS_DISPLAY[254] = { 19434,10, 56641,10, 3044,10, 53209,10 }; --Marksmanship
SPEC_SPELLS_DISPLAY[255] = { 53301,10, 77767,10, 3674,10, 63458,10 }; --Survival

SPEC_SPELLS_DISPLAY[256] = { 17,10, 109964,10, 47540,10, 47515,10, 62618,10 }; --Discipline
SPEC_SPELLS_DISPLAY[257] = { 34861,10, 81206,10, 2061,10, 724,10, 64843,10 }; --Holy
SPEC_SPELLS_DISPLAY[258] = { 589,10, 15407,10, 8092,10, 34914,10, 2944,10, 95740,10 }; --Shadow

SPEC_SPELLS_DISPLAY[259] = { 1329,10, 32645,10, 79134,10, 79140,10 }; --Assassination
SPEC_SPELLS_DISPLAY[260] = { 13877,10, 84617,10, 35551,10, 51690,10 }; --Combat
SPEC_SPELLS_DISPLAY[261] = { 53,10, 16511,10, 91023,10, 51713,10 }; --Subtlety

SPEC_SPELLS_DISPLAY[262] = { 403,10, 51505,10, 88766,10, 61882,10 }; --Elemental
SPEC_SPELLS_DISPLAY[263] = { 86629,10, 17364,10, 51530,10, 60103,10, 51533,10 }; --Enhancement
SPEC_SPELLS_DISPLAY[264] = { 974,10, 61295,10, 77472,10, 98008,10 }; --Restoration

SPEC_SPELLS_DISPLAY[265] = { 172,10, 980,10, 30108,10, 103103,10, 1120,10, 48181,10 }; --Affliction
SPEC_SPELLS_DISPLAY[266] = { 103958,10, 104315,10, 105174,10,  30146,10, 122351,10, 114592,10 }; --Demonology
SPEC_SPELLS_DISPLAY[267] = { 348,10, 17962,10, 29722,10, 116858,10, 111546,10, 108647,10,  }; --Destruction

SPEC_SPELLS_DISPLAY[268] = { 100784,10, 115180,10, 115181,10, 115295,10 }; --Brewmaster
SPEC_SPELLS_DISPLAY[269] = { 100780,10, 100787,10, 100784,10, 113656,10  }; --Windwalker
SPEC_SPELLS_DISPLAY[270] = { 115175,10, 115151,10, 116694,10, 116670,10 }; --Mistweaver


-- PlayerTalentFrame

function PlayerTalentFrame_Toggle(suggestedTalentGroup)
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if ( not PlayerTalentFrame:IsShown() ) then
		ShowUIPanel(PlayerTalentFrame);
		if ( not GetSpecialization() ) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..SPECIALIZATION_TAB]);
		elseif ( GetNumUnspentTalents() > 0 ) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENTS_TAB]);
		elseif ( selectedTab ) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..selectedTab]);
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

function PlayerTalentFrame_ToggleGlyphFrame(suggestedTalentGroup)
	GlyphFrame_LoadUI();
	if ( GlyphFrame ) then
		local hidden = false;
		if ( not PlayerTalentFrame:IsShown()) then
			ShowUIPanel(PlayerTalentFrame);
			hidden = false;
		elseif (PanelTemplates_GetSelectedTab(PlayerTalentFrame) == GLYPH_TAB ) then
			-- if the glyph tab is selected then toggle the frame off
			HideUIPanel(PlayerTalentFrame);
			hidden = true;
		end
		if ( not hidden ) then
			-- open the spec with the requested talent group (or the current talent group if the selected
			-- spec has one)
			if ( selectedSpec ) then
				local spec = specs[selectedSpec];
				suggestedTalentGroup = spec.talentGroup;
			end
			for _, index in ipairs(TALENT_SORT_ORDER) do
				local spec = specs[index];
				if ( spec.talentGroup == suggestedTalentGroup ) then
					PlayerSpecTab_OnClick(specTabs[index]);
					PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..GLYPH_TAB]);
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
			if ( spec.talentGroup == talentGroup ) then
				PlayerSpecTab_OnClick(specTabs[index]);
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..GLYPH_TAB]);
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
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PET_SPECIALIZATION_CHANGED");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterEvent("PREVIEW_TALENT_PRIMARY_TREE_CHANGED");
	self:RegisterEvent("BAG_UPDATE_DELAYED");
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
	-- 4th spec?
	if ( numSpecs > 3 ) then
		self.specButton1:SetPoint("TOPLEFT", 6, -61);
		self.specButton4:Show();
	end
	
	for i = 1, numSpecs do
		local button = self["specButton"..i];
		local _, name, description, icon = GetSpecializationInfo(i, false, self.isPet);
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
	
	local selection = PlayerTalentFrame_GetTalentSelections();
	if ( not GetSpecialization() ) then
		TalentMicroButtonAlert.Text:SetText(TALENT_MICRO_BUTTON_NO_SPEC);
		TalentMicroButtonAlert:SetHeight(TalentMicroButtonAlert.Text:GetHeight()+42);
		TalentMicroButtonAlert:Show();
		StaticPopup_Hide("CONFIRM_LEARN_SPEC");
	elseif ( selection ) then
		local name, iconTexture, tier, column, selected, available = GetTalentInfo(selection);
		if (available) then
			TalentMicroButtonAlert.Text:SetText(TALENT_MICRO_BUTTON_UNSAVED_CHANGES);
			TalentMicroButtonAlert:SetHeight(TalentMicroButtonAlert.Text:GetHeight()+42);
			TalentMicroButtonAlert:Show();
		end
	elseif ( GetNumUnspentTalents() > 0 ) then
		TalentMicroButtonAlert.Text:SetText(TALENT_MICRO_BUTTON_UNSPENT_TALENTS);
		TalentMicroButtonAlert:SetHeight(TalentMicroButtonAlert.Text:GetHeight()+42);
		TalentMicroButtonAlert:Show();
	end
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
		elseif (event == "BAG_UPDATE_DELAYED") then
			PlayerTalentFrame_RefreshClearInfo();
		end
	end
	
	if ( event == "ACTIVE_TALENT_GROUP_CHANGED" ) then
		ActionBarController_ResetToDefault();
	end
end

function PlayerTalentFrame_ShowTalentTab()
	PlayerTalentFrameTalents:Show();
end

function PlayerTalentFrame_HideTalentTab()
	PlayerTalentFrameTalents:Hide();
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
	if ( selectedTab == GLYPH_TAB ) then
		tutorial = LE_FRAME_TUTORIAL_GLYPH;
	elseif (selectedTab == TALENTS_TAB) then
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

	local name, count, texture, spellID;
	
	if ( selectedTab == GLYPH_TAB ) then
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrame_ShowGlyphFrame();
		PlayerTalentFrame_HidePetSpecTab();
		PlayerTalentFrame_RefreshClearInfo();
	elseif (selectedTab == TALENTS_TAB) then
		ButtonFrameTemplate_ShowAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideGlyphFrame();
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrameTalents.talentGroup = PlayerTalentFrame.talentGroup;
		TalentFrame_Update(PlayerTalentFrameTalents, "player");
		PlayerTalentFrame_ShowTalentTab();
		PlayerTalentFrame_HidePetSpecTab();
		PlayerTalentFrame_RefreshClearInfo();
	elseif (selectedTab == SPECIALIZATION_TAB) then
		ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideGlyphFrame()
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_ShowsSpecTab();
		PlayerTalentFrame_HidePetSpecTab();
		PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFrameSpecialization);
	elseif (selectedTab == PET_SPECIALIZATION_TAB) then
		ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideGlyphFrame()
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrame_ShowsPetSpecTab();
		PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFramePetSpecialization);
	end
	
	PlayerTalentFrame_Update();
end

function PlayerTalentFrame_RefreshClearInfo()
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	local name, count, texture, spellID;
	if (selectedTab == GLYPH_TAB) then
		name, count, texture, spellID = GetGlyphClearInfo();
		if (name) then
			GlyphFrame.clearInfo.name:SetText(name);
			GlyphFrame.clearInfo.count:SetText(count);
			GlyphFrame.clearInfo.icon:SetTexture(texture);
			GlyphFrame.clearInfo.spellID = spellID
		else
			GlyphFrame.clearInfo.name:SetText("");
			GlyphFrame.clearInfo.count:SetText("");
			GlyphFrame.clearInfo.icon:SetTexture("");
		end
	elseif (selectedTab == TALENTS_TAB) then
		name, count, texture, spellID = GetTalentClearInfo();
		if (name) then
			PlayerTalentFrameTalents.clearInfo.name:SetText(name);
			PlayerTalentFrameTalents.clearInfo.count:SetText(count);
			PlayerTalentFrameTalents.clearInfo.icon:SetTexture(texture);
			PlayerTalentFrameTalents.clearInfo.spellID = spellID
		else
			PlayerTalentFrameTalents.clearInfo.name:SetText("");
			PlayerTalentFrameTalents.clearInfo.count:SetText("");
			PlayerTalentFrameTalents.clearInfo.icon:SetTexture("");
		end
	end
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
	
	if ( selectedTab == GLYPH_TAB) then
		if ( spec and spec.glyphName and hasMultipleTalentGroups ) then
			if (isActiveSpec and spec.glyphNameActive) then
				PlayerTalentFrameTitleText:SetText(spec.glyphNameActive);
			else
				PlayerTalentFrameTitleText:SetText(spec.glyphName);
			end
		else
			PlayerTalentFrameTitleText:SetText(GLYPHS);
		end
	elseif ( selectedTab == SPECIALIZATION_TAB or selectedTab == PET_SPECIALIZATION_TAB ) then
		if ( spec and hasMultipleTalentGroups ) then
			if (isActiveSpec and spec.nameActive) then
				PlayerTalentFrameTitleText:SetText(spec.specNameActive);
			else
				PlayerTalentFrameTitleText:SetText(spec.specName);
			end
		else
			PlayerTalentFrameTitleText:SetText(SPECIALIZATION);
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

function PlayerTalentFrame_SelectTalent(id)
	local tier = floor((id - 1) / NUM_TALENT_COLUMNS) + 1;
	local talentRow = PlayerTalentFrameTalents["tier"..tier];
	if ( talentRow.selectionId == id ) then
		talentRow.selectionId = nil;
	else
		talentRow.selectionId = id;
	end
	TalentFrame_Update(PlayerTalentFrameTalents, "player");
end

function PlayerTalentFrame_ClearTalentSelections()
	for tier = 1, MAX_NUM_TALENT_TIERS do
		local talentRow = PlayerTalentFrameTalents["tier"..tier];
		talentRow.selectionId = nil;
	end
end

function PlayerTalentFrame_GetTalentSelections()
	local talents = { };
	for tier = 1, MAX_NUM_TALENT_TIERS do
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
	[1] = { ButtonPos = { x = 300,	y = -27 }, HighLightBox = { x = 8, y = -48, width = 627, height = 65 },		ToolTipDir = "UP",		ToolTipText = TALENT_FRAME_HELP_1 },
	[2] = { ButtonPos = { x = 15,	y = -206 }, HighLightBox = { x = 8, y = -115, width = 627, height = 298 },	ToolTipDir = "RIGHT",	ToolTipText = TALENT_FRAME_HELP_2 },
	[3] = { ButtonPos = { x = 355,	y = -409}, HighLightBox = { x = 268, y = -418, width = 109, height = 26 },	ToolTipDir = "RIGHT",	ToolTipText = TALENT_FRAME_HELP_3 },
}

function PlayerTalentFrame_ToggleTutorial()
	local tutorial, helpPlate, mainHelpButton = PlayerTalentFrame_GetTutorial();
		
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) and PlayerTalentFrame:IsShown()) then
		HelpPlate_Show( helpPlate, PlayerTalentFrame, mainHelpButton, true );
		SetCVarBitfield( "closedInfoFrames", tutorial, true );
	else
		HelpPlate_Hide(true);
	end
end

-- PlayerTalentFrameTalents
function PlayerTalentFrameTalent_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetTalentLink(self:GetID(), PlayerTalentFrame.inspect, PlayerTalentFrame.talentGroup);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	elseif ( selectedSpec and (activeSpec == selectedSpec)) then
		local _, _, _, _, selected, available = GetTalentInfo(self:GetID());
		if ( available ) then
			-- only allow functionality if an active spec is selected
			if ( button == "LeftButton" and not selected ) then
				PlayerTalentFrame_SelectTalent(self:GetID());
			elseif ( button == "RightButton" and selected ) then
				if ( UnitIsDeadOrGhost("player") ) then
					UIErrorsFrame:AddMessage(ERR_PLAYER_DEAD, 1.0, 0.1, 0.1, 1.0);
				else
					StaticPopup_Show("CONFIRM_REMOVE_TALENT", nil, nil, {id = self:GetID()});
				end
			end
		else
			-- if there is something else already learned for this tier, display a dialog about unlearning that one.
			if ( button == "LeftButton" and not selected ) then
				local tier = floor((self:GetID() - 1) / NUM_TALENT_COLUMNS) + 1;
				local isRowFree, prevSelected = GetTalentRowSelectionInfo(tier);
				if (not isRowFree) then					
					StaticPopup_Show("CONFIRM_UNLEARN_AND_SWITCH_TALENT", nil, nil, {oldID = prevSelected, id = self:GetID()});					
				end
			end
		end
	end
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
	
	-- Highlight the whole row to give the idea that you can only select one talent per row.
	if(lastTopLineHighlight ~= nil and lastTopLineHighlight ~= self:GetParent().TopLine) then
		lastTopLineHighlight:Hide();
	end
	if(lastBottomLineHighlight ~= nil and lastBottomLineHighlight ~= self:GetParent().BottomLine) then
		lastBottomLineHighlight:Hide();
	end
		
	self:GetParent().TopLine:Show();
	self:GetParent().BottomLine:Show();
	lastTopLineHighlight = self:GetParent().TopLine;
	lastBottomLineHighlight = self:GetParent().BottomLine;

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	
	GameTooltip:SetTalent(self:GetID(),
		PlayerTalentFrame.inspect, PlayerTalentFrame.talentGroup);
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
			SetActiveSpecGroup(talentGroup);
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

	-- setup glyph tab
	local meetsGlyphLevel = playerLevel >= SHOW_INSCRIPTION_LEVEL;
	tab = _G["PlayerTalentFrameTab"..GLYPH_TAB];
	if ( tab ) then
		if ( meetsGlyphLevel ) then
			tab:Show();
			firstShownTab = firstShownTab or tab;
			PanelTemplates_TabResize(tab, 0);
			talentTabWidthCache[GLYPH_TAB] = PanelTemplates_GetTabWidth(tab);
			totalTabWidth = totalTabWidth + talentTabWidthCache[GLYPH_TAB];
			numVisibleTabs = numVisibleTabs+1;
		else
			tab:Hide();
			talentTabWidthCache[GLYPH_TAB] = 0;
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
	
	local tutorial, helpPlate, mainHelpButton = PlayerTalentFrame_GetTutorial();
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		if ( tutorial and not GetCVarBitfield("closedInfoFrames", tutorial) 
			and GetCVarBool("showTutorials") and PlayerTalentFrame:IsShown()) then
			HelpPlate_Show( helpPlate, PlayerTalentFrame, mainHelpButton );
			SetCVarBitfield( "closedInfoFrames", tutorial, true );
		else
			HelpPlate_Hide();
		end
	else
		HelpPlate_Hide();
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
	StaticPopup_Hide("CONFIRM_REMOVE_TALENT")
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
	GLYPH_TAB = self:GetID();
	-- we can record the text width for the glyph tab now since it never changes
	self.textWidth = self:GetTextWidth();
end

function PlayerGlyphTab_OnClick(self)
	StaticPopup_Hide("CONFIRM_REMOVE_TALENT")
	PlayerTalentFrameTab_OnClick(self);
	SetButtonPulse(_G["PlayerTalentFrameTab"..GLYPH_TAB], 0, 0);
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
		frame:SetChecked(nil);
	end
	
	-- check ourselves (before we wreck ourselves)
	self:SetChecked(1);

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
		if ( self.displayTrainerTooltip and not self:GetParent().isPet ) then
			GameTooltip:AddLine(TALENT_SPEC_CHANGE_AT_CLASS_TRAINER, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		end
		GameTooltip:SetMinimumWidth(300, true);
		GameTooltip:Show();
	end
end

function SpecButton_OnLeave(self)
	GameTooltip:SetMinimumWidth(0, 0);
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
		
		if ( button.disabled ) then
			if ( petNotActive) then
				button.displayTrainerTooltip = false;
			else
				button.displayTrainerTooltip = true;
			end
		else
			button.displayTrainerTooltip = false;
		end
	end
	
	-- save viewed spec for Learn button
	self.previewSpec = shownSpec;

	-- display spec info in the scrollframe
	local scrollChild = self.spellsScroll.child;
	local id, name, description, icon, background = GetSpecializationInfo(shownSpec, nil, self.isPet);
	SetPortraitToTexture(scrollChild.specIcon, icon);
	scrollChild.specName:SetText(name);
	scrollChild.description:SetText(description);
	local role1 = GetSpecializationRole(shownSpec, nil, self.isPet);
	scrollChild.roleName:SetText(_G[role1]);
	scrollChild.roleIcon:SetTexCoord(GetTexCoordsForRole(role1));
	-- disable stuff if not in active spec or have picked a specialization and not looking at it
	local disable = (selectedSpec ~= activeSpec) or ( playerTalentSpec and shownSpec ~= playerTalentSpec ) or petNotActive;
	if ( disable and not self.disabled ) then
		self.disabled = true;
		self.bg:SetDesaturated(true);
		scrollChild.description:SetTextColor(0.75, 0.75, 0.75);
		scrollChild.roleName:SetTextColor(0.75, 0.75, 0.75);
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
	if ( self.isPet and disable ) then
		self.learnButton:Enable();
		self.learnButton.Flash:Show();
		self.learnButton.FlashAnim:Play();
	elseif ( playerTalentSpec or disable or UnitLevel("player") < SHOW_SPEC_LEVEL ) then
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
		bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet)};
	else
		bonuses = SPEC_SPELLS_DISPLAY[id];
	end
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
		local level = GetSpellLevelLearned(bonuses[i]);
		if ( level and level > UnitLevel("player") ) then
			frame.subText:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
		else
			frame.subText:SetText("");
		end
		if ( disable ) then
			frame.disabled = true;
			frame.icon:SetDesaturated(true);
			frame.ring:SetDesaturated(true);
			frame.subText:SetTextColor(0.75, 0.75, 0.75);
		else
			frame.disabled = false;
			frame.icon:SetDesaturated(false);
			frame.ring:SetDesaturated(false);
			frame.subText:SetTextColor(0.25, 0.1484375, 0.02);
		end
		frame:Show();
		index = index + 1;
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
	for i=1, MAX_NUM_TALENT_TIERS do
		self["tier"..i].level:SetText(talentLevels[i]);
	end
end
