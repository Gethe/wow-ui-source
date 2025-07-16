StaticPopupDialogs["CONFIRM_REMOVE_TALENT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == C_SpecializationInfo.GetActiveSpecGroup() ) then
			RemoveTalent(self.data.id);
		end
	end,
	OnShow = function(self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		local _, name = GetTalentInfoByID(self.data.id, talentGroup);
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
		if ( talentGroup == C_SpecializationInfo.GetActiveSpecGroup() ) then
			RemoveTalent(self.data.oldID);
			PlayerTalentFrame_SelectTalent(self.data.tier, self.data.id);
		end
	end,
	OnShow = function(self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		local _, name = GetTalentInfoByID(self.data.id, talentGroup);
		local _, oldName = GetTalentInfoByID(self.data.oldID, talentGroup);
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

------------------------------------
-- Global Constants

SPECIALIZATION_TAB = 1;
TALENTS_TAB = 2;
GLYPH_TAB = 3;
PET_SPECIALIZATION_TAB = 4;
NUM_TALENT_FRAME_TABS = 3;

local lastTopLineHighlight = nil;
local lastBottomLineHighlight = nil;

------------------------------------
-- Local Data

TALENT_UI_SPECS = {
	["spec1"] = {
		name = SPECIALIZATION_PRIMARY,
		nameActive = TALENT_SPEC_PRIMARY_ACTIVE,
		glyphName = TALENT_SPEC_PRIMARY_GLYPH,
		glyphNameActive = TALENT_SPEC_PRIMARY_GLYPH_ACTIVE,
		specName = SPECIALIZATION_PRIMARY,
		specNameActive = SPECIALIZATION_PRIMARY_ACTIVE,
		talentGroup = 1,
		unit = "player",
		pet = false,
		tooltip = SPECIALIZATION_PRIMARY,
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
		hasGlyphs = true,
	},
	["spec2"] = {
		name = SPECIALIZATION_SECONDARY,
		nameActive = TALENT_SPEC_SECONDARY_ACTIVE,
		glyphName = TALENT_SPEC_SECONDARY_GLYPH,
		glyphNameActive = TALENT_SPEC_SECONDARY_GLYPH_ACTIVE,
		specName = SPECIALIZATION_SECONDARY,
		specNameActive = SPECIALIZATION_SECONDARY_ACTIVE,
		talentGroup = 2,
		unit = "player",
		pet = false,
		tooltip = SPECIALIZATION_SECONDARY,
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
		hasGlyphs = true,
	},
};

-- cache talent info so we can quickly display cool stuff like the number of points spent in each tab
local talentSpecInfoCache = {
	["spec1"]		= { },
	["spec2"]		= { },
};

-- Speed References
local next = next;
local ipairs = ipairs;

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
SPEC_SPELLS_DISPLAY[257] = { 34861,10, 81206,10, 2061,10, 126135,10, 64843,10 }; --Holy
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

------------------------------------
-- PlayerTalentFrame

function PlayerTalentFrame_Toggle(suggestedTalentGroup)
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if ( not PlayerTalentFrame:IsShown() ) then
		ShowUIPanel(PlayerTalentFrame);
		if ( not C_SpecializationInfo.GetSpecialization() ) then
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
	for index, spec in next, TALENT_UI_SPECS do
		if ( spec.pet == pet and spec.talentGroup == talentGroup ) then
			PlayerSpecTab_OnClick(TalentUIUtil.GetSpecTab(index));
			break;
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
	self.pet = false;
	self.talentGroup = 1;
	self.hasBeenShown = false;
	self.selectedPlayerSpec = DEFAULT_TALENT_SPEC;
	self.onCloseCallback = PlayerTalentFrame_OnClickClose;

	local _, playerClass = UnitClass("player");
	if (playerClass == "HUNTER") then
		NUM_TALENT_FRAME_TABS = 4;
	end

	-- setup tabs
	PanelTemplates_SetNumTabs(self, NUM_TALENT_FRAME_TABS);
	
	-- setup portrait texture
	local _, class = UnitClass("player");
	PlayerTalentFramePortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
	PlayerTalentFramePortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]));
	
	-- initialize active spec
	PlayerTalentFrame_UpdateActiveSpec(C_SpecializationInfo.GetActiveSpecGroup(false));
	TalentUIUtil.SelectActiveSpec();
end

function PlayerTalentFrame_PetSpec_OnLoad(self)
	self.isPet = true;
	PlayerTalentFrameSpec_OnLoad(self);
end

function PlayerTalentFrameSpec_OnLoad(self)
	local numSpecs = GetNumSpecializations(false, self.isPet);
	
	-- These buttons typically get loaded during SpecializationInfo's initialization, resulting in numSpecs being 0.
	if numSpecs == 0 then
		self.needsInitialization = true;
		return;
	end

	-- 4th spec?
	if ( numSpecs > 3 ) then
		self.specButton1:SetPoint("TOPLEFT", 6, -61);
		self.specButton4:Show();
	end
	
	for i = 1, numSpecs do
		local button = self["specButton"..i];
		local _, name, description, icon = C_SpecializationInfo.GetSpecializationInfo(i, false, self.isPet);
		SetPortraitToTexture(button.specIcon, icon);
		button.specName:SetText(name);
		button.tooltip = description;
		local role = GetSpecializationRole(i, false, self.isPet);
		button.roleIcon:SetTexCoord(GetTexCoordsForRole(role));
		button.roleName:SetText(_G[role]);
	end

	self.needsInitialization = false;
end

function PlayerTalentFrameSpec_OnShow(self)
	if not self.needsInitialization then
		return;
	end

	PlayerTalentFrameSpec_OnLoad(self);
end

function PlayerTalentFrame_OnShow(self)
	-- Stop buttons from flashing after skill up
	MicroButtonPulseStop(TalentMicroButton);
	TalentMicroButtonAlert:Hide();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	UpdateMicroButtons();
	
	PlayerTalentFrameTalents.summariesShownWhenNoPrimary = true;

	if ( not self.hasBeenShown ) then
		-- The first time the frame is shown, select your active spec
		self.hasBeenShown = true;
		PlayerSpecTab_OnClick(TalentUIUtil.GetActiveSpecTab());
	end

	PlayerTalentFrame_Refresh();

	-- Set flag
	if ( not GetCVarBool("talentFrameShown") ) then
		SetCVar("talentFrameShown", 1);
	end
end

function PlayerTalentFrame_OnHide()
	HelpPlate.Hide();
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	-- clear caches
	for _, info in next, talentSpecInfoCache do
		wipe(info);
	end
	TalentUIUtil.WipeTalentTabWidthCache()
	
	local selection = PlayerTalentFrame_GetTalentSelections();
	if ( not C_SpecializationInfo.GetSpecialization() ) then
		TalentMicroButtonAlert.Text:SetText(TALENT_MICRO_BUTTON_NO_SPEC);
		TalentMicroButtonAlert:SetHeight(TalentMicroButtonAlert.Text:GetHeight()+42);
		TalentMicroButtonAlert:Show();
		StaticPopup_Hide("CONFIRM_LEARN_SPEC");
	elseif ( selection ) then
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		local _, name, iconTexture, tier, column, selected, available = GetTalentInfoByID(selection, talentGroup);
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
	if (self:IsShown()) then
		if ( event == "ADDON_LOADED" ) then
			PlayerTalentFrame_ClearTalentSelections();
		elseif ( event == "PET_SPECIALIZATION_CHANGED" or
				 event == "PREVIEW_TALENT_POINTS_CHANGED" or
				 event == "PREVIEW_TALENT_PRIMARY_TREE_CHANGED" or
				 event == "PLAYER_TALENT_UPDATE" ) then
			PlayerTalentFrame_Refresh();
		elseif ( event == "UNIT_LEVEL") then
			if ( TalentUIUtil.IsAnySpecSelected() ) then
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
	TalentUIUtil.SetSelectedSpec(PlayerTalentFrame.selectedPlayerSpec);
	PlayerTalentFrame.talentGroup = TALENT_UI_SPECS[PlayerTalentFrame.selectedPlayerSpec].talentGroup;

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
	local activeTalentGroup, numTalentGroups = C_SpecializationInfo.GetActiveSpecGroup(false), GetNumSpecGroups(false);
	PlayerTalentFrame.primaryTree = C_SpecializationInfo.GetSpecialization(PlayerTalentFrame.inspect, false, PlayerTalentFrame.talentGroup);
			
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
	
	if (TalentUIUtil.IsActiveSpecSelected() and numTalentGroups > 1) then
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

function PlayerTalentFrame_UpdateTitleText(numTalentGroups)
	local spec = TalentUIUtil.GetSelectedSpec();
	local hasMultipleTalentGroups = numTalentGroups > 1;
	local isActiveSpec = TalentUIUtil.IsActiveSpecSelected();
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
		
	if ( helpPlate and not HelpPlate.IsShowingHelpInfo(helpPlate) and PlayerTalentFrame:IsShown()) then
		HelpPlate.Show(helpPlate, PlayerTalentFrame, mainHelpButton);
		SetCVarBitfield( "closedInfoFrames", tutorial, true );
	else
		HelpPlate.Hide(true);
	end
end

------------------------------------
-- PlayerTalentFrameTalents

function PlayerTalentFrameTalent_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrameText and MacroFrameText:HasFocus() ) then
			local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
			local _, talentName = GetTalentInfoByID(self:GetID(), talentGroup);
			local spellName, subSpellName = GetSpellInfo(talentName);
			if ( spellName and not IsPassiveSpell(spellName) ) then
				if ( subSpellName and (strlen(subSpellName) > 0) ) then
					ChatEdit_InsertLink(spellName.."("..subSpellName..")");
				else
					ChatEdit_InsertLink(spellName);
				end
			end
		else
			local link = GetTalentLink(self:GetID(), PlayerTalentFrame.inspect, PlayerTalentFrame.talentGroup);
			if ( link ) then
				ChatEdit_InsertLink(link);
			end
		end
	elseif ( TalentUIUtil.IsActiveSpecSelected() ) then
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		local id, name, icon, selected, available, spellID, pvpTalentID, tier, column, isKnown, grantedByAura = GetTalentInfoByID(self:GetID(), talentGroup);
		if ( available ) then
			-- only allow functionality if an active spec is selected
			if ( button == "LeftButton" and not selected ) then
				PlayerTalentFrame_SelectTalent(tier, self:GetID());
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
				local tierAvailable, selectedTalentColumn, tierUnlockLevel = GetTalentTierInfo(self.tier, PlayerTalentFrame.talentGroup, PlayerTalentFrame.inspect, "player");
				if (selectedTalentColumn ~= 0) then
					local talentInfoQuery = {};
					talentInfoQuery.tier = tier;
					talentInfoQuery.column = selectedTalentColumn;
					talentInfoQuery.groupIndex = PlayerTalentFrame.talentGroup;
					talentInfoQuery.isInspect = PlayerTalentFrame.inspect;
					talentInfoQuery.target = "player";
					local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);
					if talentInfo then
						StaticPopup_Show("CONFIRM_UNLEARN_AND_SWITCH_TALENT", nil, nil, {tier = self.tier, oldID = talentInfo.talentID, id = self:GetID()});
					end
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
		GameTooltip:SetTalent(self:GetID(), PlayerTalentFrame.inspect, PlayerTalentFrame.talentGroup);
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
	GameTooltip:SetTalent(self:GetID(), PlayerTalentFrame.inspect, PlayerTalentFrame.talentGroup);
end

------------------------------------
-- Controls

function PlayerTalentFrame_UpdateControls(activeTalentGroup, numTalentGroups)
	local isActiveSpec = TalentUIUtil.IsActiveSpecSelected();
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if (not activeTalentGroup or not numTalentGroups) then
		activeTalentGroup, numTalentGroups = C_SpecializationInfo.GetActiveSpecGroup(false), GetNumSpecGroups(false);
	end
	
	-- show the activate button if this is not the active spec
	PlayerTalentFrameActivateButton_Update(numTalentGroups);
end

function PlayerTalentFrameActivateButton_OnShow(self)
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function PlayerTalentFrameActivateButton_OnEvent(self, event, ...)
	local numTalentGroups = GetNumSpecGroups(false);
	PlayerTalentFrameActivateButton_Update(numTalentGroups);
end

function PlayerTalentFrameActivateButton_Update(numTalentGroups)
	local spec = TalentUIUtil.GetSelectedSpec();
	if (numTalentGroups > 1) then
		if (C_Spell.IsCurrentSpell(TALENT_ACTIVATION_SPELLS[spec.talentGroup])) then
			PlayerTalentFrameActivateButton:Show();
			PlayerTalentFrameActivateButton:Disable();
		elseif (TalentUIUtil.IsActiveSpecSelected()) then
			PlayerTalentFrameActivateButton:Hide();
		else
			PlayerTalentFrameActivateButton:Show();
			PlayerTalentFrameActivateButton:Enable();
		end
	else
		PlayerTalentFrameActivateButton:Hide();
	end
end

------------------------------------
-- PlayerTalentFrameTab

function PlayerTalentFrame_UpdateTabs(playerLevel)
	local totalTabWidth = 0;
	local firstShownTab = _G["PlayerTalentFrameTab"..SPECIALIZATION_TAB];
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame) or SPECIALIZATION_TAB;
	local numVisibleTabs = 0;
	local tab;

	-- setup specialization tab
	TalentUIUtil.SetCachedWidthForTalentTab(SPECIALIZATION_TAB, 0);
	tab = _G["PlayerTalentFrameTab"..SPECIALIZATION_TAB];
	if ( tab ) then
		tab:Show();
		firstShownTab = firstShownTab or tab;
		PanelTemplates_TabResize(tab, 0);
		TalentUIUtil.SetCachedWidthForTalentTab(SPECIALIZATION_TAB, PanelTemplates_GetTabWidth(tab));
		totalTabWidth = totalTabWidth + TalentUIUtil.GetCachedTalentTabWidth(SPECIALIZATION_TAB);
		numVisibleTabs = numVisibleTabs+1;
	end
	
	-- setup talents talents tab
	TalentUIUtil.SetCachedWidthForTalentTab(TALENTS_TAB, 0);
	tab = _G["PlayerTalentFrameTab"..TALENTS_TAB];
	if ( tab ) then
		if ( C_SpecializationInfo.CanPlayerUseTalentUI() ) then
			tab:Show();
			firstShownTab = firstShownTab or tab;
			PanelTemplates_TabResize(tab, 0);
			TalentUIUtil.SetCachedWidthForTalentTab(TALENTS_TAB, PanelTemplates_GetTabWidth(tab));
			totalTabWidth = totalTabWidth + TalentUIUtil.GetCachedTalentTabWidth(TALENTS_TAB);
			numVisibleTabs = numVisibleTabs+1;
		else
			tab:Hide();
		end
	end
	
	local spec = TalentUIUtil.GetSelectedSpec();

	-- setup glyph tab
	playerLevel = playerLevel or UnitLevel("player");
	local meetsGlyphLevel = INSCRIPTION_AVAILABLE and (playerLevel >= SHOW_INSCRIPTION_LEVEL);
	tab = _G["PlayerTalentFrameTab"..GLYPH_TAB];
	if ( tab ) then
		if ( meetsGlyphLevel and spec.hasGlyphs ) then
			tab:Show();
			firstShownTab = firstShownTab or tab;
			PanelTemplates_TabResize(tab, 0);
			TalentUIUtil.SetCachedWidthForTalentTab(GLYPH_TAB, PanelTemplates_GetTabWidth(tab));
			totalTabWidth = totalTabWidth + TalentUIUtil.GetCachedTalentTabWidth(GLYPH_TAB);
			numVisibleTabs = numVisibleTabs+1;
		else
			tab:Hide();
			TalentUIUtil.SetCachedWidthForTalentTab(GLYPH_TAB, 0);
		end
	end

	if (NUM_TALENT_FRAME_TABS == 4) then
		-- setup pet specialization tab
		TalentUIUtil.SetCachedWidthForTalentTab(PET_SPECIALIZATION_TAB, 0);
		tab = _G["PlayerTalentFrameTab"..PET_SPECIALIZATION_TAB];
		if ( tab ) then
			tab:Show();
			firstShownTab = firstShownTab or tab;
			PanelTemplates_TabResize(tab, 0);
			TalentUIUtil.SetCachedWidthForTalentTab(PET_SPECIALIZATION_TAB, PanelTemplates_GetTabWidth(tab));
			totalTabWidth = totalTabWidth + TalentUIUtil.GetCachedTalentTabWidth(PET_SPECIALIZATION_TAB);
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
		for i = 2, TalentUIUtil.GetNumCachedTabWidths() do
			if ( TalentUIUtil.GetCachedTalentTabWidth(largestTab) < TalentUIUtil.GetCachedTalentTabWidth(i) ) then
				largestTab = i;
			end
		end
		-- shave the width
		TalentUIUtil.SetCachedWidthForTalentTab(largestTab, TalentUIUtil.GetCachedTalentTabWidth(largestTab) - 10);
		-- apply the shaved width
		tab = _G["PlayerTalentFrameTab"..largestTab];
		PanelTemplates_TabResize(tab, 0, TalentUIUtil.GetCachedTalentTabWidth(largestTab));
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
			x = x + TalentUIUtil.GetCachedTalentTabWidth(i) - 15;
		end
	end
	
	-- update the tabs
	PanelTemplates_UpdateTabs(PlayerTalentFrame);

	return true;
end

function PlayerTalentFrameTab_OnClick(self)
	local id = self:GetID();
	PanelTemplates_SetTab(PlayerTalentFrame, id);
	PlayerTalentFrameTalents.selectedTab = id;
	PlayerTalentFrame_Refresh();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	
	local tutorial, helpPlate, mainHelpButton = PlayerTalentFrame_GetTutorial();
	if ( helpPlate and not HelpPlate.IsShowingHelpInfo(helpPlate) ) then
		if ( tutorial and not GetCVarBitfield("closedInfoFrames", tutorial) 
			and GetCVarBool("showTutorials") and PlayerTalentFrame:IsShown()) then
			HelpPlate.Show(helpPlate, PlayerTalentFrame, mainHelpButton);
			SetCVarBitfield( "closedInfoFrames", tutorial, true );
		else
			HelpPlate.Hide();
		end
	else
		HelpPlate.Hide();
	end
end

------------------------------------
-- PlayerTalentTab

function PlayerTalentTab_OnLoad(self)
	PlayerTalentFrameTab_OnLoad(self);

	self:RegisterEvent("PLAYER_LEVEL_UP");
	if (C_SpecializationInfo.CanPlayerUseTalentUI() and (GetNumUnspentTalents() > 0) and (self:GetID() == TALENTS_TAB)) then
		SetButtonPulse(self, 60, 0.75);
	end
end

function PlayerTalentTab_OnClick(self)
	StaticPopup_Hide("CONFIRM_REMOVE_TALENT")
	PlayerTalentFrameTab_OnClick(self);
	SetButtonPulse(self, 0, 0);
end

------------------------------------
-- PlayerGlyphTab

function PlayerGlyphTab_OnLoad(self)
	PlayerTalentFrameTab_OnLoad(self);

	self:RegisterEvent("PLAYER_LEVEL_UP");
	GLYPH_TAB = self:GetID();
	-- we can record the text width for the glyph tab now since it never changes
	self.textWidth = self:GetTextWidth();
end

------------------------------------
-- Specs

-- PlayerTalentFrame_UpdateSpecs is a helper function for PlayerTalentFrame_Update.
-- Returns true on a successful update, false otherwise. An update may fail if the currently
-- selected tab is no longer selectable. In this case, the first selectable tab will be selected.
function PlayerTalentFrame_UpdateSpecs(activeTalentGroup, numTalentGroups)
	-- update each of the spec tabs
	local firstShownTab, lastShownTab;
	local numShown = 0;
	local numSpecTabs = TalentUIUtil.GetNumSpecTabs()
	for i = 1, numSpecTabs do
		local frame = _G["PlayerSpecTab"..i];
		local specIndex = frame.specIndex;
		local spec = TALENT_UI_SPECS[specIndex];
		if ( PlayerSpecTab_Update(frame, activeTalentGroup, numTalentGroups) ) then
			firstShownTab = firstShownTab or frame;
			numShown = numShown + 1;
			frame:ClearAllPoints();
			if ( numShown == 1 ) then
				--...start the first tab off at a base location
				frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPRIGHT", 0, -36);
			else
				--...offset subsequent tabs from the previous one
				if ( spec.pet ~= TALENT_UI_SPECS[lastShownTab.specIndex].pet ) then
					frame:SetPoint("TOPLEFT", lastShownTab, "BOTTOMLEFT", 0, -39);
				else
					frame:SetPoint("TOPLEFT", lastShownTab, "BOTTOMLEFT", 0, -22);
				end
			end
			lastShownTab = frame;
		else
			-- if the selected tab is not shown then clear out the selected spec
			if ( TalentUIUtil.IsSpecSelected(specIndex) ) then
				TalentUIUtil.ClearSelectedSpec();
			end
		end
	end

	if ( not TalentUIUtil.IsAnySpecSelected() ) then
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
	local spec = TALENT_UI_SPECS[specIndex];

	-- determine whether or not we need to hide the tab
	local canShow;
	if ( spec.pet ) then
		canShow = spec.talentGroup <= numPetTalentGroups;
	else
		canShow = spec.talentGroup <= numTalentGroups;
	end
	if ( not canShow ) then
		self:Hide();
		return false;
	end

	local normalTexture = self:GetNormalTexture();

	-- set the background
	local name = self:GetName();
	local backgroundTexture = _G[name.."Background"];
	backgroundTexture:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab");
	backgroundTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 11);

	-- update the spec info cache
	TalentFrame_UpdateSpecInfoCache(talentSpecInfoCache[specIndex], false, false, spec.talentGroup);

	-- update spec tab icon
	local hasMultipleTalentGroups = numTalentGroups > 1;
	if ( hasMultipleTalentGroups ) then
		local primaryTree = C_SpecializationInfo.GetSpecialization(false, false, spec.talentGroup);
		
		local specInfoCache = talentSpecInfoCache[specIndex];
		if ( primaryTree and primaryTree > 0 and (not IsInitialSpec(primaryTree)) and specInfoCache) then
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
	TalentUIUtil.AddSpecTab(self, specIndex);

	-- set the checked texture
	local checkedTexture = self:GetCheckedTexture();
	checkedTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight");

	local activeTalentGroup, numTalentGroups = C_SpecializationInfo.GetActiveSpecGroup(false), GetNumSpecGroups(false);
	PlayerSpecTab_Update(self, activeTalentGroup, numTalentGroups);
end

function PlayerSpecTab_OnClick(self)
	-- set all specs as unchecked initially
	local specTabs = TalentUIUtil.GetSpecTabs();
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
		PlayerTalentFrameTalents.selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	end

	-- update the talent frame
	PlayerTalentFrame_Refresh();
end

function PlayerSpecTab_OnEnter(self)
	local specIndex = self.specIndex;
	local spec = TALENT_UI_SPECS[specIndex];
	if ( spec.specNameActive and spec.specName ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		-- name
		if ( GetNumSpecGroups(false) <= 1) then
			-- set the tooltip to be the unit's name
			GameTooltip:AddLine(UnitName(spec.unit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		else
			if ( TalentUIUtil.IsSpecActive(self.specIndex) ) then
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent().spellsScroll.ScrollBar:SetValue(0);
	PlayerTalentFrame_UpdateSpecFrame(self:GetParent(), self:GetID());
	GameTooltip:Hide();
end

function PlayerTalentFrame_UpdateSpecFrame(self, spec)
	local activeSpecializationIndex = nil;
	local selectedSpec = TalentUIUtil.GetSelectedSpec();
	local isActiveSpecSelected = TalentUIUtil.IsActiveSpecSelected();
	if not self.isPet or IsPetActive() then
		activeSpecializationIndex = C_SpecializationInfo.GetSpecialization(nil, self.isPet, selectedSpec.talentGroup);
	end

	-- Initial spec should be treated as "no spec" in the UI.
	if IsInitialSpec(activeSpecializationIndex) then
		activeSpecializationIndex = nil;
	end

	local shownSpec = spec or activeSpecializationIndex or 1;
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
		if ( i == activeSpecializationIndex and (not self.isPet or isActiveSpecSelected) ) then
			button.learnedTex:Show();
		else
			button.learnedTex:Hide();
		end
		if ( isActiveSpecSelected and ( not activeSpecializationIndex or i == activeSpecializationIndex ) ) then
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
			button.displayTrainerTooltip = not petNotActive;
		else
			button.displayTrainerTooltip = false;
		end
	end
	
	-- save viewed spec for Learn button
	self.previewSpec = shownSpec;

	-- display spec info in the scrollframe
	local scrollChild = self.spellsScroll.child;
	local id, name, description, icon = C_SpecializationInfo.GetSpecializationInfo(shownSpec, false, self.isPet);
	if (id == 0) then
		-- We can't get information about specializations before entering the world. In
		-- that case, just return, and we'll update things later.
		return;
	end
	SetPortraitToTexture(scrollChild.specIcon, icon);
	scrollChild.specName:SetText(name);
	scrollChild.description:SetText(description);
	local role1 = GetSpecializationRole(shownSpec, nil, self.isPet);
	scrollChild.roleName:SetText(_G[role1]);
	scrollChild.roleIcon:SetTexCoord(GetTexCoordsForRole(role1));
	-- disable stuff if not in active spec or have picked a specialization and not looking at it
	local disable = (not isActiveSpecSelected) or ( activeSpecializationIndex and shownSpec ~= activeSpecializationIndex ) or petNotActive;
	if ( disable and not self.disabled ) then
		self.disabled = true;
		self.bg:SetDesaturated(true);
		scrollChild.description:SetTextColor(0.75, 0.75, 0.75);
		scrollChild.roleName:SetTextColor(0.75, 0.75, 0.75);
		scrollChild.specIcon:SetDesaturated(true);
		scrollChild.roleIcon:SetDesaturated(true);
		scrollChild.ring:SetDesaturated(true);
		scrollChild.gradient:SetDesaturated(true);
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
		scrollChild.specIcon:SetDesaturated(false);
		scrollChild.roleIcon:SetDesaturated(false);
		scrollChild.ring:SetDesaturated(false);	
		scrollChild.gradient:SetDesaturated(false);
		scrollChild.Seperator:SetDesaturated(false);
		scrollChild.scrollwork_topleft:SetDesaturated(false);
		scrollChild.scrollwork_topright:SetDesaturated(false);
		scrollChild.scrollwork_bottomleft:SetDesaturated(false);
		scrollChild.scrollwork_bottomright:SetDesaturated(false);
	end
	-- disable Learn button
	if ( self.isPet and isActiveSpecSelected and (not petNotActive) and disable ) then
		self.learnButton:Enable();
		self.learnButton.Flash:Show();
		self.learnButton.FlashAnim:Play();
	elseif ( activeSpecializationIndex or disable or not C_SpecializationInfo.CanPlayerUseTalentSpecUI() ) then
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
	local bonuses;
	if ( self.isPet ) then
		bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet)};
	else
		bonuses = SPEC_SPELLS_DISPLAY[id];
	end
	if bonuses then
		for i=1,#bonuses,2 do
			local frame = scrollChild["abilityButton"..index];
			if not frame then
				frame = PlayerTalentFrame_CreateSpecSpellButton(self, index);
			end
			if ( mod(index, 2) == 0 ) then
				frame:SetPoint("LEFT", scrollChild["abilityButton"..(index-1)], "RIGHT", 110, 0);
			else
				if (index <= 2) then
					frame:SetPoint("TOP", scrollChild, "TOP");
				elseif ((#bonuses/2) > 4 ) then
					frame:SetPoint("TOP", scrollChild["abilityButton"..(index-2)], "BOTTOM", 0, 0);
				else
					frame:SetPoint("TOP", scrollChild["abilityButton"..(index-2)], "BOTTOM", 0, -20);
				end
			end

			local spellName, subname = GetSpellInfo(bonuses[i]);
			local _, spellIcon = GetSpellTexture(bonuses[i]);
			SetPortraitToTexture(frame.icon, spellIcon);
			frame.name:SetText(spellName);
			frame.spellID = bonuses[i];
			frame.extraTooltip = nil;
			frame.isPet = self.isPet;
			local level = C_Spell.GetSpellLevelLearned(bonuses[i]);
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
