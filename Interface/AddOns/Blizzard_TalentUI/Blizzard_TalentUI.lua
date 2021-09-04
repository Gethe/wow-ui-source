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
local TALENT_FRAME_BASE_WIDTH = 646;
local TALENT_FRAME_EXPANSION_EXTRA_WIDTH = 137;

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
		if PlayerTalentFrame:IsShown() then
			if (suggestedTalentTab) then
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..suggestedTalentTab]);
			elseif (PlayerTalentFrame.lastSelectedTab) then
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..PlayerTalentFrame.lastSelectedTab]);
			elseif ( not GetSpecialization() ) then
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..SPECIALIZATION_TAB]);
			elseif ( GetNumUnspentTalents() > 0 ) then
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENTS_TAB]);
			elseif ( selectedTab ) then
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..selectedTab]);
			elseif ( AreTalentsLocked() ) then
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..SPECIALIZATION_TAB]);
			else
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENTS_TAB]);
			end
			MainMenuMicroButton_HideAlert(TalentMicroButton);
		end
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
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PET_SPECIALIZATION_CHANGED");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterEvent("PLAYER_LEARN_TALENT_FAILED");
	self.inspect = false;
	self.talentGroup = 1;
	self.hasBeenShown = false;
	self.selectedPlayerSpec = DEFAULT_TALENT_SPEC;
	self.onCloseCallback = PlayerTalentFrame_OnClickClose;
	self.basePanelWidth = 666;
	self.expandedPanelWidth = 797;
	self.superExpandedPanelWidth = 987;

	local _, playerClass = UnitClass("player");
	if (playerClass == "HUNTER") then
		PET_SPECIALIZATION_TAB = 3
		NUM_TALENT_FRAME_TABS = 3;
	end

	-- setup tabs
	PanelTemplates_SetNumTabs(self, NUM_TALENT_FRAME_TABS);

	-- setup portrait texture
	local _, class = UnitClass("player");
	self:SetPortraitTextureRaw("Interface\\TargetingFrame\\UI-Classes-Circles");
	self:SetPortraitTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]));

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

	self.learnButton:SetShown(not self.isPet);

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
	MainMenuMicroButton_HideAlert(TalentMicroButton);

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
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
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
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

function PlayerTalentFrame_SetExpanded(expanded)
	if (expanded) then
		PlayerTalentFrame:SetWidth(TALENT_FRAME_BASE_WIDTH + TALENT_FRAME_EXPANSION_EXTRA_WIDTH);
		PlayerTalentFrameTalentsTRCorner:SetPoint("TOPRIGHT", -140, -2);
		PlayerTalentFrameTalentsBRCorner:SetPoint("BOTTOMRIGHT", -140, 2);
		PlayerTalentFrameTalents.PvpTalentFrame:Show();
		if (PlayerTalentFrameTalents.PvpTalentFrame.TalentList:IsShown()) then
			SetUIPanelAttribute(PlayerTalentFrame, "width", PlayerTalentFrame.superExpandedPanelWidth);
		else
			SetUIPanelAttribute(PlayerTalentFrame, "width", PlayerTalentFrame.expandedPanelWidth);
		end
	else
		PlayerTalentFrame:SetWidth(TALENT_FRAME_BASE_WIDTH);
		PlayerTalentFrameTalentsTRCorner:SetPoint("TOPRIGHT", -3, -2);
		PlayerTalentFrameTalentsBRCorner:SetPoint("BOTTOMRIGHT", -3, 2);
		PlayerTalentFrameTalents.PvpTalentFrame:Hide();
		SetUIPanelAttribute(PlayerTalentFrame, "width", PlayerTalentFrame.basePanelWidth);
	end
	UpdateUIPanelPositions(PlayerTalentFrame);
end

function PlayerTalentFrame_Refresh()
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	selectedSpec = PlayerTalentFrame.selectedPlayerSpec;
	PlayerTalentFrame.talentGroup = specs[selectedSpec].talentGroup;
	local name, count, texture, spellID;

	if (selectedTab == TALENTS_TAB) then
		ButtonFrameTemplate_ShowAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrameTalents.talentGroup = PlayerTalentFrame.talentGroup;
		TalentFrame_Update(PlayerTalentFrameTalents, "player");
		PlayerTalentFrame_ShowTalentTab();
		PlayerTalentFrame_HidePetSpecTab();
		PlayerTalentFrameTalentsPvpTalentButton:Update();
	elseif (selectedTab == SPECIALIZATION_TAB) then
		ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_ShowsSpecTab();
		PlayerTalentFrame_HidePetSpecTab();
		PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFrameSpecialization);
		PlayerTalentFrame_SetExpanded(false);
	elseif (selectedTab == PET_SPECIALIZATION_TAB) then
		ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrame_ShowsPetSpecTab();
		PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFramePetSpecialization);
		PlayerTalentFrame_SetExpanded(false);
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
				PlayerTalentFrame:SetTitle(spec.specNameActive);
			else
				PlayerTalentFrame:SetTitle(spec.specName);
			end
		else
			PlayerTalentFrame:SetTitle(SPECIALIZATION);
		end
	else
		if ( spec and hasMultipleTalentGroups ) then
			if (isActiveSpec and spec.nameActive) then
				PlayerTalentFrame:SetTitle(spec.nameActive);
			else
				PlayerTalentFrame:SetTitle(spec.name);
			end
		else
			PlayerTalentFrame:SetTitle(TALENTS);
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
		for i, button in ipairs(self.talents) do
			button.GlowFrame:Hide();
		end
	end
end

function PlayerTalentFrameRow_OnLeave(self)
	self.TopLine:Hide();
	self.BottomLine:Hide();
	TalentFrame_UpdateRowGlow(self);
end

function HandleGeneralTalentFrameChatLink(self, talentName, talentLink)
	if ( MacroFrameText and MacroFrameText:HasFocus() ) then
		local spellName = GetSpellInfo(talentName);
		if ( spellName and not IsPassiveSpell(spellName) ) then
			local subSpellName = GetSpellSubtext(talentName);
			if ( subSpellName ) then
				if ( subSpellName ~= "" ) then
					ChatEdit_InsertLink(spellName.."("..subSpellName..")");
				else
					ChatEdit_InsertLink(spellName);
				end
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

-- PlayerTalentFrameTalents
function PlayerTalentFrameTalent_OnClick(self, button)
	if ( selectedSpec and (activeSpec == selectedSpec)) then
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
	talentTabWidthCache[TALENTS_TAB] = 0;
	tab = _G["PlayerTalentFrameTab"..TALENTS_TAB];
	if ( tab ) then
		if ( C_SpecializationInfo.CanPlayerUseTalentUI() and not IsPlayerInitialSpec() ) then
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

	if (NUM_TALENT_FRAME_TABS == 3) then
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
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	HelpPlate_Hide();
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

	if self:GetID() == TALENTS_TAB then
		self:RegisterEvent("PLAYER_LEVEL_CHANGED");
		if C_SpecializationInfo.CanPlayerUseTalentUI() and (GetNumUnspentTalents() > 0) then
			SetButtonPulse(self, 60, 0.75);
		end
	end
end

function PlayerTalentTab_OnClick(self)
	PlayerTalentFrameTab_OnClick(self);
	SetButtonPulse(self, 0, 0);
end

function PlayerTalentTab_OnEvent(self, event, ...)
	if C_SpecializationInfo.CanPlayerUseTalentUI() and (GetNumUnspentTalents() > 0) and (PanelTemplates_GetSelectedTab(PlayerTalentFrame) ~= self:GetID()) then
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
    if (not id or not self.spellID or not GetSpellInfo(self.spellID)) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID, isPet, false, true);
	if ( self.extraTooltip ) then
		GameTooltip:AddLine(self.extraTooltip);
	end
	self.UpdateTooltip = self.OnEnter;
	GameTooltip:Show();
end

function PlayerSpecSpellTemplate_OnLeave(self)
	self.UpdateTooltip = nil;
	GameTooltip:Hide();
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent().spellsScroll.ScrollBar:SetValue(0);
	PlayerTalentFrame_UpdateSpecFrame(self:GetParent(), self:GetID());
	GameTooltip:Hide();
end

function PlayerTalentFrame_UpdateSpecFrame(self, spec)
	if ( not C_SpecializationInfo.IsInitialized() ) then
		return;
	end

	local playerTalentSpec = GetSpecialization(nil, self.isPet, specs[selectedSpec].talentGroup);
	local shownSpec = spec or playerTalentSpec or 1;
	local numSpecs = GetNumSpecializations(nil, self.isPet);
	if ( shownSpec > numSpecs ) then 
		shownSpec = 1;
	end
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
	local specID, name, description, icon, _, primaryStat = GetSpecializationInfo(shownSpec, nil, self.isPet, nil, sex);
	local primarySpecID = GetPrimarySpecialization();
	self.previewSpecCost = (specID ~= primarySpecID) and GetSpecChangeCost() or nil;
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
	local disableLearnButton = not self.isPet and ( playerTalentSpec and shownSpec == playerTalentSpec );
    if(disableLearnButton or not C_SpecializationInfo.CanPlayerUseTalentSpecUI()) then
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
	local bonusesIncrement = 1;
	if ( self.isPet ) then
		bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet, true)};
		-- GetSpecializationSpells adds a spell level after each spell ID, but we only care about the spell ID
		bonusesIncrement = 2;
	else
		bonuses = C_SpecializationInfo.GetSpellsDisplay(specID);
	end
	if ( bonuses ) then
		for i=1,#bonuses,bonusesIncrement do
			local frame = scrollChild["abilityButton"..index];
			if not frame then
				frame = PlayerTalentFrame_CreateSpecSpellButton(self, index);
			end

			-- First ability already has anchor set
			if (index > 1) then
				if ( mod(index, 2) == 0 ) then
					frame:SetPoint("LEFT", scrollChild["abilityButton"..(index-1)], "RIGHT", 110, 0);
				else
					frame:SetPoint("TOP", scrollChild["abilityButton"..(index-2)], "BOTTOM", 0, 0);
				end
			end

			local _, icon = GetSpellTexture(bonuses[i]);
			SetPortraitToTexture(frame.icon, icon);
			frame.name:SetText(GetSpellInfo(bonuses[i]));
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
				local futureSpell = level and level > UnitLevel("player");
				if ( futureSpell ) then
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
					frame.disabled = futureSpell;
					if ( futureSpell ) then
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
	-- Setup table to support immediate UI updates when picking talents
	self.talentInfo = {};
end

function PlayerTalentFrameTalents_OnShow(self)
	local playerLevel = UnitLevel("player");
	if ( C_SpecializationInfo.CanPlayerUseTalentUI() and AreTalentsLocked() ) then
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

function PlayerTalentButton_OnLoad(self)
	self.icon:ClearAllPoints();
	self.name:ClearAllPoints();
	if (EXTEND_TALENT_FRAME_TALENT_DISPLAY) then
		self.icon:SetPoint("LEFT", 29, 0);
		self.name:SetSize(104, 35);
		self.name:SetPoint("LEFT", self.icon, "RIGHT", 8, 0);
	else
		self.icon:SetPoint("LEFT", 35, 0);
		self.name:SetSize(90, 35);
		self.name:SetPoint("LEFT", self.icon, "RIGHT", 10, 0);
	end

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterForDrag("LeftButton");
end

function PlayerTalentButton_OnClick(self, button)
	-- With 1-click talent selection, there is a significant amount of lag between clicking the talent and
	-- getting the server message back saying that your talents have been updated. To make the UI feel more
	-- responsive, we update the UI immediately as if we got the server response. Then we lock that row so
	-- that the user cannot try and update that talent row until we receive a response back from the server.

	if (IsModifiedClick("CHATLINK")) then
		HandleTalentFrameChatLink(self);
		return;
	end

	local talentRow = self:GetParent();
	local talentsFrame = talentRow:GetParent();
	if (talentsFrame.talentInfo[self.tier]) then
		-- We recently clicked on a talent and are waiting for the server response; don't let the user click again
		UIErrorsFrame:AddMessage(TALENT_CLICK_TOO_FAST, 1.0, 0.1, 0.1, 1.0);
		return;
	elseif (not self.disabled) then
		if (UnitAffectingCombat("player")) then
			-- Disallow selecting a talent while in combat
			UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0);
			return;
		end

		-- Pretend like we immediately got the talent by de-selecting the old talent and selecting the new one
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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

PvpTalentExpandingButtonMixin = CreateFromMixins(UIExpandingButtonMixin);

function PvpTalentExpandingButtonMixin:OnLoad()
	local EXPANDED_BY_DEFAULT = true;
	self:SetUp(EXPANDED_BY_DEFAULT, "RIGHT");
	self:SetLabel(PVP_LABEL_PVP_TALENTS);
	self:RegisterCallback(function(self, currentlyExpanded) PlayerTalentFrame_SetExpanded(currentlyExpanded) end);
end

PvpTalentFrameMixin = {};

PVP_TALENT_LIST_BUTTON_HEIGHT = 40;
PVP_TALENT_LIST_BUTTON_OFFSET = 1;

local PvpTalentFrameEvents = {
	"PLAYER_PVP_TALENT_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_SPECIALIZATION_CHANGED",
	"WAR_MODE_STATUS_UPDATE",
	"UI_MODEL_SCENE_INFO_UPDATED",
};

TALENT_WAR_MODE_BUTTON = nil;

function PvpTalentFrameMixin:OnLoad()
	TALENT_WAR_MODE_BUTTON = self.InvisibleWarmodeButton;

	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
	for i, slot in ipairs(self.Slots) do
		slot:SetUp(i);
	end

	self.InvisibleWarmodeButton:SetUp();

	self.TalentList.ScrollFrame.update = function() self.TalentList:Update() end;
	self.TalentList.ScrollFrame.ScrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.TalentList.ScrollFrame, "PvpTalentButtonTemplate", 0, -1, "TOPLEFT", "TOPLEFT", 0, -PVP_TALENT_LIST_BUTTON_OFFSET, "TOP", "BOTTOM");
end

function PvpTalentFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_PVP_TALENT_UPDATE" then
		self:ClearPendingRemoval();
		self:Update();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:Update();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:Update();
	elseif event == "WAR_MODE_STATUS_UPDATE" then
		self:Update();
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local forceUpdate = true;
		self:UpdateModelScenes(forceUpdate);
	elseif event == "PLAYER_LEVEL_CHANGED" then
		self:Update();
	end
end

function PvpTalentFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, PvpTalentFrameEvents);

	self:Update();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function PvpTalentFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, PvpTalentFrameEvents);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

	self:UnselectSlot();
end

function PvpTalentFrameMixin:UpdateModelScene(scene, sceneID, fileID, forceUpdate)
	if (not scene) then
		return;
	end

	scene:Show();
	scene:SetFromModelSceneID(sceneID, forceUpdate);
	local effect = scene:GetActorByTag("effect");
	if (effect) then
		effect:SetModelByFileID(fileID);
	end
end

function PvpTalentFrameMixin:ClearPendingRemoval()
	for slotIndex = 1, #self.Slots do
		local slot = self.Slots[slotIndex];
		slot:SetPendingTalentRemoval(false);
		slot:Update();
	end
end

function PvpTalentFrameMixin:Update()
	if (not C_PvP.IsWarModeFeatureEnabled() or not C_SpecializationInfo.CanPlayerUsePVPTalentUI()) then
		self:Hide();
		PlayerTalentFrameTalentsPvpTalentButton:Hide();
		PlayerTalentFrame_SetExpanded(false);
		self.currentWarModeState = "hidden";
		return;
	else
		if (self.currentWarModeState == "hidden" or not self.currentWarModeState) then
			PlayerTalentFrame_SetExpanded(true);
			PlayerTalentFrameTalentsPvpTalentButton:Show();
		end
		self.currentWarModeState = "shown";
	end

	for _, slot in pairs(self.Slots) do
		slot:Update();
	end

	self.TalentList:Update();

	self:UpdateModelScenes();

	self.InvisibleWarmodeButton:Update();
	self.WarmodeIncentive:Update();
end

function PvpTalentFrameMixin:UpdateModelScenes(forceUpdate)
	if (self.InvisibleWarmodeButton:GetWarModeDesired() == self.lastKnownDesiredState) then
		return;
	end

	if (self.InvisibleWarmodeButton:GetWarModeDesired()) then
		self:UpdateModelScene(self.OrbModelScene, 108, 1102774, forceUpdate); -- 6AK_Arakkoa_Lamp_Orb_Fel.m2
		self:UpdateModelScene(self.FireModelScene, 109, 517202, forceUpdate); -- Firelands_Fire_2d.m2
	else
		self.OrbModelScene:Hide();
		self.FireModelScene:Hide();
	end
	self.lastKnownDesiredState = self.InvisibleWarmodeButton:GetWarModeDesired();
end

function PvpTalentFrameMixin:SelectSlot(slot)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (self.selectedSlotIndex) then
		local sameSelected = self.selectedSlotIndex == slot.slotIndex;
		self:UnselectSlot();
		if (sameSelected) then
			return;
		end
	end
	SetUIPanelAttribute(PlayerTalentFrame, "width", PlayerTalentFrame.superExpandedPanelWidth);
	UpdateUIPanelPositions(PlayerTalentFrame);
	self.selectedSlotIndex = slot.slotIndex;
	slot.Arrow:Show();
	HybridScrollFrame_SetOffset(self.TalentList.ScrollFrame, 0);
	self.TalentList.ScrollFrame.ScrollBar:SetValue(0);
	self.TalentList:Update();
	self.TalentList:Show();
end

function PvpTalentFrameMixin:UnselectSlot()
	if (not self.selectedSlotIndex) then
		return;
	end

	local slot = self.Slots[self.selectedSlotIndex];

	slot.Arrow:Hide();
	self.TalentList:Hide();
	self.selectedSlotIndex = nil;
	SetUIPanelAttribute(PlayerTalentFrame, "width", PlayerTalentFrame.expandedPanelWidth);
	UpdateUIPanelPositions(PlayerTalentFrame);
end

function PvpTalentFrameMixin:SelectTalentForSlot(talentID, slotIndex)
	local slot = self.Slots[slotIndex];

	if (not slot or slot:GetSelectedTalent() == talentID) then
		return;
	end

	for existingSlotIndex = 1, #self.Slots do
		local existingSlot = self.Slots[existingSlotIndex];
		if existingSlot:GetSelectedTalent() == talentID then
			existingSlot:SetPendingTalentRemoval(true);
			break;
		end
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	slot:SetSelectedTalent(talentID);
	self:UnselectSlot();
end

PvpTalentButtonMixin = {};

function PvpTalentButtonMixin:SetPvpTalent(talentID)
	self.talentID = talentID;
end

function PvpTalentButtonMixin:Update(selectedHere, selectedOther)
	local talentID, name, icon, selected, available, spellID, unlocked = GetPvpTalentInfoByID(self.talentID);

	self.New:Hide();
	self.NewGlow:Hide();

	if (not unlocked) then
		self.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.Icon:SetDesaturated(true);
		self.Selected:Hide();
		self.disallowNormalClicks = true;
	else
		if (C_SpecializationInfo.IsPvpTalentLocked(self.talentID)) then
			self.New:Show();
			self.NewGlow:Show();
		end
		self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.Icon:SetDesaturated(false);
		self.Selected:SetShown(selectedHere);
		self.disallowNormalClicks = false; 
	end

	self.SelectedOtherCheck:SetShown(selectedOther);
	self.SelectedOtherCheck:SetDesaturated(not unlocked);

	self.Name:SetText(name);
	self.Icon:SetTexture(icon);

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end
end

function PvpTalentButtonMixin:SetOwningFrame(frame)
	self.owner = frame;
end

function PvpTalentButtonMixin:OnClick()
	if (IsModifiedClick("CHATLINK")) then
		local _, name = GetPvpTalentInfoByID(self.talentID);
		local link = GetPvpTalentLink(self.talentID);
		HandleGeneralTalentFrameChatLink(self, name, link);
		return;
	end

	if (not self.owner) then
		return;
	end

	if(not self.disallowNormalClicks) then 
		self.owner:SelectTalentForSlot(self.talentID, self.owner.selectedSlotIndex);
	end
end

function PvpTalentButtonMixin:OnEnter()
	if (C_SpecializationInfo.IsPvpTalentLocked(self.talentID) and select(7,GetPvpTalentInfoByID(self.talentID))) then
		C_SpecializationInfo.SetPvpTalentLocked(self.talentID, false);
		self.New:Hide();
		self.NewGlow:Hide();
	end

	if (not self.owner) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetPvpTalent(self.talentID, false, GetActiveSpecGroup(true), self.owner.selectedSlotIndex);
	GameTooltip:Show();
end

PvpTalentWarmodeButtonMixin = {};

function PvpTalentWarmodeButtonMixin:OnShow()
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PVP_WARMODE_UNLOCK)) then
		local helpTipInfo = {
			text = WAR_MODE_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_PVP_WARMODE_UNLOCK,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = -4,
		};
		local parent = self:GetParent();
		HelpTip:Show(parent, helpTipInfo, parent.InvisibleWarmodeButton);
	end
	self:Update();
end

function PvpTalentWarmodeButtonMixin:OnHide()
	self:UnregisterEvent("PLAYER_FLAGS_CHANGED");
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
	self:UnregisterEvent("ZONE_CHANGED");
end

function PvpTalentWarmodeButtonMixin:OnEvent(event, ...)
	if (event == "PLAYER_FLAGS_CHANGED") then
		local previousValue = self.predictedToggle:Get();
		self.predictedToggle:UpdateCurrentValue();
		self.predictedToggle:Clear();
		if (C_PvP.IsWarModeDesired() ~= previousValue) then
			self:Update();
		end
	elseif ((event == "ZONE_CHANGED") or (event == "ZONE_CHANGED_NEW_AREA")) then
		self:Update();
	end
end

function PvpTalentWarmodeButtonMixin:SetUp()
	self.predictedToggle = CreatePredictedToggle(
		{
			["toggleFunction"] = function()
				C_PvP.ToggleWarMode();
			end,
			["getFunction"] = function()
				return C_PvP.IsWarModeDesired();
			end,
		}
	);
end

function PvpTalentWarmodeButtonMixin:GetWarModeDesired()
	return self.predictedToggle:Get();
end

function PvpTalentWarmodeButtonMixin:Update()
	self:SetEnabled(not IsInInstance());
	local frame = self:GetParent();
	local isPvp = self.predictedToggle:Get();
	local disabledAdd = isPvp and "" or "-disabled";
	local swordsAtlas = "pvptalents-warmode-swords"..disabledAdd;
	local ringAtlas = "pvptalents-warmode-ring"..disabledAdd;
	frame.Swords:SetAtlas(swordsAtlas);
	frame.Ring:SetAtlas(ringAtlas);

	self:GetParent():UpdateModelScenes();

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end
end

function PvpTalentWarmodeButtonMixin:OnClick()
	if (C_PvP.CanToggleWarMode(not C_PvP.IsWarModeDesired())) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local warmodeEnabled = self.predictedToggle:Get();

		if (warmodeEnabled) then
			PlaySound(SOUNDKIT.UI_WARMODE_DECTIVATE);
		else
			PlaySound(SOUNDKIT.UI_WARMODE_ACTIVATE);
		end

		self.predictedToggle:Toggle();

		self:Update();

		HelpTip:Acknowledge(self:GetParent(), WAR_MODE_TUTORIAL);
	end
end

function PvpTalentWarmodeButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, PVP_LABEL_WAR_MODE);
	if C_PvP.IsWarModeActive() or self:GetWarModeDesired() then
		GameTooltip_AddInstructionLine(GameTooltip, PVP_WAR_MODE_ENABLED);
	end
	local wrap = true;
	local warModeRewardBonus = C_PvP.GetWarModeRewardBonus();
	GameTooltip_AddNormalLine(GameTooltip, PVP_WAR_MODE_DESCRIPTION_FORMAT:format(warModeRewardBonus), wrap);

	-- Determine if the player can toggle warmode on/off.
	local canToggleWarmode = C_PvP.CanToggleWarMode(true);
	local canToggleWarmodeOFF = C_PvP.CanToggleWarMode(false);

	-- Confirm there is a reason to show an error message
	if(not canToggleWarmode or not canToggleWarmodeOFF) then

		local warmodeErrorText;

		-- Outdoor world environment
		if(not C_PvP.CanToggleWarModeInArea()) then
			if(self:GetWarModeDesired()) then
				if(not canToggleWarmodeOFF and not IsResting()) then
					warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA or PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA;
				end
			else
				if(not canToggleWarmode) then
					warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE or PVP_WAR_MODE_NOT_NOW_ALLIANCE;
				end
			end
		end

		-- player is not allowed to toggle warmode in combat.
		if(warmodeErrorText) then
			GameTooltip_AddColoredLine(GameTooltip, warmodeErrorText, RED_FONT_COLOR, wrap);
		elseif (UnitAffectingCombat("player")) then
			GameTooltip_AddColoredLine(GameTooltip, SPELL_FAILED_AFFECTING_COMBAT, RED_FONT_COLOR, wrap);
		end
	end
		
	GameTooltip:Show();
end

WarmodeIncentiveMixin = {};

function WarmodeIncentiveMixin:OnEnter()
	local base, current, bonus = self:GetPercentages();

	if bonus > 0 then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, WAR_MODE_CALL_TO_ARMS);
		GameTooltip_AddNormalLine(GameTooltip, WAR_MODE_BONUS_INCENTIVE_TOOLTIP:format(bonus, current));
		GameTooltip:Show();
	end
end

function WarmodeIncentiveMixin:GetPercentages()
	local basePercentage = C_PvP.GetWarModeRewardBonusDefault();
	local currentPercentage = C_PvP.GetWarModeRewardBonus();
	return basePercentage, currentPercentage, currentPercentage - basePercentage;
end

function WarmodeIncentiveMixin:Update()
	local base, current, bonus = self:GetPercentages();
	self:SetShown(bonus > 0);
end

PvpTalentListMixin = {};

function PvpTalentListMixin:OnLoad()
	ButtonFrameTemplate_ShowButtonBar(self);
	FrameTemplate_SetAtticHeight(self, 8);
end

function PvpTalentListMixin:Update()
	local slotIndex = self:GetParent().selectedSlotIndex;

	if (slotIndex) then
		local scrollFrame = self.ScrollFrame;
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		local buttons = scrollFrame.buttons;
		local numButtons = #buttons;
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slotIndex);
		if not slotInfo then
			return;
		end
		local numTalents = #slotInfo.availableTalentIDs;
		local selectedPvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs();
		local availableTalentIDs = slotInfo.availableTalentIDs;

		table.sort(availableTalentIDs, function(a, b)
			local unlockedA = select(7,GetPvpTalentInfoByID(a));
			local unlockedB = select(7,GetPvpTalentInfoByID(b));

			if (unlockedA ~= unlockedB) then
				return unlockedA;
			end

			if (not unlockedA) then
				local reqLevelA = C_SpecializationInfo.GetPvpTalentUnlockLevel(a);
				local reqLevelB = C_SpecializationInfo.GetPvpTalentUnlockLevel(b);

				if (reqLevelA ~= reqLevelB) then
					return reqLevelA < reqLevelB;
				end
			end

			local selectedOtherA = tContains(selectedPvpTalents, a) and slotInfo.selectedTalentID ~= a;
			local selectedOtherB = tContains(selectedPvpTalents, b) and slotInfo.selectedTalentID ~= b;

			if (selectedOtherA ~= selectedOtherB) then
				return selectedOtherB;
			end

			return a < b;
		end);
		local selectedTalentID = slotInfo.selectedTalentID;

		for i = 1, numButtons do
			local button = buttons[i];
			local index = offset + i;
			if (index <= numTalents) then
				local talentID = availableTalentIDs[index];
				local selectedHere = selectedTalentID == talentID;
				local selectedOther = tContains(selectedPvpTalents, talentID) and not selectedHere;
				button:SetHeight(PVP_TALENT_LIST_BUTTON_HEIGHT);
				button:SetOwningFrame(self:GetParent());
				button:SetPvpTalent(talentID);
				button:Update(selectedHere, selectedOther);
				button:Show();
			else
				button:Hide();
			end
		end

		local totalHeight = numTalents * PVP_TALENT_LIST_BUTTON_HEIGHT;
		HybridScrollFrame_Update(scrollFrame, totalHeight + 10, 338);
	end
end