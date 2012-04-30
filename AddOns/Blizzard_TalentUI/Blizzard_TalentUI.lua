


StaticPopupDialogs["CONFIRM_LEARN_TALENT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == GetActiveSpecGroup() ) then
			LearnTalent(self.data.id);
		end
	end,
	OnShow = function(self)
		local name = GetTalentInfo(self.data.id);
		self.text:SetFormattedText(CONFIRM_LEARN_TALENT, GREEN_FONT_COLOR_CODE..name.."|r");
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_LEARN_TALENTS"] = {
	text = CONFIRM_LEARN_PREVIEW_TALENTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == GetActiveSpecGroup() ) then
			LearnTalents(PlayerTalentFrame_GetTalentSelections());
		end
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

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
		local resourceName, count, _, _, cost = GetGlyphClearInfo();
		if count >= cost then
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


StaticPopupDialogs["CONFIRM_LEARN_SPEC"] = {
	text = "Are you sure you want to learn this specialization?",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		SetSpecialization(self.data);
		PlayerTalentFrameSpecialization.playLearnAnim = true;
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}



UIPanelWindows["PlayerTalentFrame"] = { area = "doublewide", pushable = 6, whileDead = 1, width = 666, height = 488 };


-- global constants
TALENT_SPECIALIZATION_TAB = 1;
TALENTS_TAB = 2;
GLYPH_TALENT_TAB = 3;
NUM_TALENT_FRAME_TABS = 3;

local THREE_SPEC_LGBUTTON_HEIGHT = 95;
local SPEC_SCROLL_HEIGHT = 282;
local SPEC_SCROLL_PREVIEW_HEIGHT = 228;

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
		specName = SPECIALIZATION_PRIMARY,
		specNameActive = SPECIALIZATION_PRIMARY_ACTIVE,
		talentGroup = 1,
		tooltip = TALENT_SPEC_PRIMARY,
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
	},
	["spec2"] = {
		name = TALENT_SPEC_SECONDARY,
		nameActive = TALENT_SPEC_SECONDARY_ACTIVE,
		glyphName = TALENT_SPEC_SECONDARY_GLYPH,
		glyphNameActive = TALENT_SPEC_SECONDARY_GLYPH_ACTIVE,
		specName = SPECIALIZATION_SECONDARY,
		specNameActive = SPECIALIZATION_SECONDARY_ACTIVE,
		talentGroup = 2,
		tooltip = TALENT_SPEC_SECONDARY,
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


-- PlayerTalentFrame

function PlayerTalentFrame_Toggle(suggestedTalentGroup)
	local hidden;
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	if ( not PlayerTalentFrame:IsShown() ) then
		ShowUIPanel(PlayerTalentFrame);
		hidden = false;
		TalentMicroButtonAlert:Hide();
	else
		if ( selectedTab == TALENT_SPECIALIZATION_TAB) then
			-- if a talent tab is selected then toggle the frame off
			HideUIPanel(PlayerTalentFrame);
			hidden = true;
		elseif (selectedTab == TALENTS_TAB) then
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
					PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENT_SPECIALIZATION_TAB]);
				end
				break;
			end
		end
		
		-- Select specialization Talents tab
		if (selectedTab ~= TALENT_SPECIALIZATION_TAB) then
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENT_SPECIALIZATION_TAB]);
		end		
	end
end

function PlayerTalentFrame_Open(talentGroup)
	ShowUIPanel(PlayerTalentFrame);

	-- Show the talents tab
	PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..TALENT_SPECIALIZATION_TAB]);
	
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
		local hidden = false;
		if ( not PlayerTalentFrame:IsShown()) then
			ShowUIPanel(PlayerTalentFrame);
			hidden = false;
		elseif (PanelTemplates_GetSelectedTab(PlayerTalentFrame) == GLYPH_TALENT_TAB ) then
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
			if ( spec.talentGroup == talentGroup ) then
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
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterEvent("PREVIEW_TALENT_PRIMARY_TREE_CHANGED");
	self.inspect = false;
	self.talentGroup = 1;
	self.hasBeenShown = false;
	self.selectedPlayerSpec = DEFAULT_TALENT_SPEC;

	-- setup tabs
	PanelTemplates_SetNumTabs(self, NUM_TALENT_FRAME_TABS);
	
	-- setup portrait texture
	local _, class = UnitClass("player");
	PlayerTalentFramePortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
	PlayerTalentFramePortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]));
	
	-- initialize active spec
	PlayerTalentFrame_UpdateActiveSpec(GetActiveSpecGroup(false));

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

function PlayerTalentFrameSpec_OnLoad(self)
	local numSpecs = GetNumSpecializations();
	-- 4th spec?
	if ( numSpecs > 3 ) then
		self.specButton1:SetPoint("TOPLEFT", 6, -61);
		self.specButton4:Show();
	end
	
	for i = 1, numSpecs do
		local button = self["specButton"..i];
		local _, name, _, icon = GetSpecializationInfo(i);
		SetPortraitToTexture(button.specIcon, icon);
		button.specName:SetText(name);
		local role = GetSpecializationRole(i);
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
		PlayerSpecTab_OnClick(activeSpec and specTabs[activeSpec] or specTabs[DEFAULT_TALENT_SPEC]);
		self.hasBeenShown = true;
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
	
	if ( PlayerTalentFrame_GetTalentSelections() ) then
		TalentMicroButtonAlertText:SetText(TALENT_MICRO_BUTTON_UNSAVED_CHANGES);
		TalentMicroButtonAlert:SetHeight(TalentMicroButtonAlertText:GetHeight()+42);
		TalentMicroButtonAlert:Show();
		StaticPopup_Hide("CONFIRM_LEARN_TALENTS");
	end
end

function PlayerTalentFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if (self:IsShown()) then
		if ( 	event == "PLAYER_TALENT_UPDATE" or 
				event == "PREVIEW_TALENT_POINTS_CHANGED" or
				event == "PREVIEW_TALENT_PRIMARY_TREE_CHANGED" ) then
			PlayerTalentFrame_ClearTalentSelections();
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

function PlayerTalentFrame_Refresh()
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	selectedSpec = PlayerTalentFrame.selectedPlayerSpec;
	PlayerTalentFrame.talentGroup = specs[selectedSpec].talentGroup;
	local tutorial;

	if ( selectedTab == GLYPH_TALENT_TAB ) then
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrame_ShowGlyphFrame();
		tutorial = LE_FRAME_TUTORIAL_GLYPH;
	elseif (selectedTab == TALENTS_TAB) then
		ButtonFrameTemplate_ShowAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideGlyphFrame();
		PlayerTalentFrame_HideSpecsTab();
		PlayerTalentFrameTalents.talentGroup = PlayerTalentFrame.talentGroup;
		TalentFrame_Update(PlayerTalentFrameTalents);
		PlayerTalentFrame_ShowTalentTab();
		tutorial = LE_FRAME_TUTORIAL_TALENT;
	else
		ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
		PlayerTalentFrame_HideGlyphFrame()
		PlayerTalentFrame_HideTalentTab();
		PlayerTalentFrame_ShowsSpecTab();
		tutorial = LE_FRAME_TUTORIAL_SPEC;
	end
	
	-- tutorial frame
	PlayerTalentFrame.tutorialFrame.tutorial = tutorial;
	if ( not tutorial or GetCVarBitfield("closedInfoFrames", tutorial) ) then
		PlayerTalentFrame.tutorialFrame:Hide();
	else
		PlayerTalentFrame_ToggleTutorial(true);
	end	

	PlayerTalentFrame_Update();
	local specFrame = PlayerTalentFrameSpecialization;
	PlayerTalentFrame_UpdateSpecFrame(specFrame);
	if ( specFrame.playLearnAnim ) then
		specFrame.playLearnAnim = false;
		if ( selectedSpec == activeSpec ) then
			local playerTalentSpec = GetSpecialization(nil, nil, specs[selectedSpec].talentGroup);
			if ( playerTalentSpec ) then
				specFrame["specButton"..playerTalentSpec].animLearn:Play();
			end
		end
	end

	local name, count, texture, spellID = GetGlyphClearInfo();
	if name then 
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
	
	if ( selectedTab == GLYPH_TALENT_TAB) then
		if ( spec and spec.glyphName and hasMultipleTalentGroups ) then
			if (isActiveSpec and spec.glyphNameActive) then
				PlayerTalentFrameTitleText:SetText(spec.glyphNameActive);
			else
				PlayerTalentFrameTitleText:SetText(spec.glyphName);
			end
		else
			PlayerTalentFrameTitleText:SetText(GLYPHS);
		end
	elseif ( selectedTab == TALENT_SPECIALIZATION_TAB ) then
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
	TalentFrame_Update(PlayerTalentFrameTalents);
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

function PlayerTalentFrame_ToggleTutorial(forceShow)
	local tutorialFrame = PlayerTalentFrame.tutorialFrame;
	local tutorial = tutorialFrame.tutorial;
	if ( forceShow or not tutorialFrame:IsShown() ) then
		local title, firstTimeText, description;
		local itemName = GetGlyphClearInfo();
		if ( tutorial == LE_FRAME_TUTORIAL_GLYPH ) then
			title = CHOOSE_GLYPHS;
			firstTimeText = CHOOSE_GLYPHS_NOW;
			description = format(CHOOSE_GLYPHS_HELP, itemName);
		elseif ( tutorial == LE_FRAME_TUTORIAL_TALENT ) then
			title = CHOOSE_TALENTS;
			firstTimeText = CHOOSE_TALENTS_NOW;
			description = format(CHOOSE_TALENTS_HELP, itemName);
		elseif ( tutorial == LE_FRAME_TUTORIAL_SPEC ) then
			title = CHOOSE_SPECIALIZATION;
			firstTimeText = CHOOSE_SPECIALIZATION_NOW;
			description = CHOOSE_SPECIALIZATION_HELP;
		end
		tutorialFrame.box.title:SetText(title);
		if ( GetCVarBitfield("closedInfoFrames", tutorial) ) then
			tutorialFrame.box.firstTimeText:SetText("");
		else
			tutorialFrame.box.firstTimeText:SetText(firstTimeText);
		end
		tutorialFrame.box.description:SetText(description);
		tutorialFrame:Show();
	else
		SetCVarBitfield("closedInfoFrames", tutorial, true);
		tutorialFrame:Hide();
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
				StaticPopup_Show("CONFIRM_REMOVE_TALENT", nil, nil, {id = self:GetID()});
			end
		end
	end
end

function PlayerTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(self:GetID(),
			PlayerTalentFrame.inspect, PlayerTalentFrame.talentGroup);
	end
end

function PlayerTalentFrameTalent_OnEnter(self)
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
	local firstShownTab = _G["PlayerTalentFrameTab"..TALENT_SPECIALIZATION_TAB];
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame) or TALENT_SPECIALIZATION_TAB;
	local numVisibleTabs = 0;
	local tab;

	-- setup specialization tab
	talentTabWidthCache[TALENT_SPECIALIZATION_TAB] = 0;
	tab = _G["PlayerTalentFrameTab"..TALENT_SPECIALIZATION_TAB];
	if ( tab ) then
		tab:Show();
		firstShownTab = firstShownTab or tab;
		PanelTemplates_TabResize(tab, 0);
		talentTabWidthCache[TALENT_SPECIALIZATION_TAB] = PanelTemplates_GetTabWidth(tab);
		totalTabWidth = totalTabWidth + talentTabWidthCache[TALENT_SPECIALIZATION_TAB];
		numVisibleTabs = numVisibleTabs+1;
	end
	
	-- setup talents talents tab
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

	-- setup glyph tab
	playerLevel = playerLevel or UnitLevel("player");
	local meetsGlyphLevel = playerLevel >= SHOW_INSCRIPTION_LEVEL;
	tab = _G["PlayerTalentFrameTab"..GLYPH_TALENT_TAB];
	if ( meetsGlyphLevel ) then
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
		PanelTemplates_SetTab(PlayerTalentFrame, TALENT_SPECIALIZATION_TAB);
	end

	-- update the talent frame
	PlayerTalentFrameSpecialization.spellsScroll.ScrollBar:SetValue(0);
	PlayerTalentFrame_Refresh();
end

function PlayerSpecTab_OnEnter(self)
	local specIndex = self.specIndex;
	local spec = specs[specIndex];
	if ( spec.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		-- name
		if ( GetNumSpecGroups(false) <= 1) then
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
		GameTooltip:Show();
	end
end

function PlayerTalentFrame_CreateSpecSpellButton(index)
	local scrollChild = PlayerTalentFrameSpecialization.spellsScroll.child;
	local frame = CreateFrame("BUTTON", scrollChild:GetName().."Ability"..index, scrollChild, "PlayerSpecSpellTemplate");
	scrollChild["abilityButton"..index] = frame;
	if ( mod(index, 2) == 0 ) then
		frame:SetPoint("LEFT", scrollChild["abilityButton"..(index-1)], "RIGHT", 161, 0);
	else
		frame:SetPoint("TOP", scrollChild["abilityButton"..(index-2)], "BOTTOM", 0, -18);
	end
	return frame;
end

function PlayerTalentFrame_UpdateSpecFrame(self, spec)
	local playerTalentSpec = GetSpecialization(nil, nil, specs[selectedSpec].talentGroup);
	local shownSpec = spec or playerTalentSpec or 1;
	local numSpecs = GetNumSpecializations();

	-- do spec buttons
	for i = 1, numSpecs do
		local button = self["specButton"..i];
		local disable = false;
		if ( i == shownSpec ) then
			button.selectedTex:Show();
		else
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
	local id, name, description, icon, background = GetSpecializationInfo(shownSpec);
	SetPortraitToTexture(scrollChild.specIcon, icon);
	scrollChild.specName:SetText(name);
	scrollChild.description:SetText(description);
	local role1 = GetSpecializationRole(shownSpec);
	scrollChild.roleName:SetText(_G[role1]);
	scrollChild.roleIcon:SetTexCoord(GetTexCoordsForRole(role1));
	-- disable stuff if not in active spec or have picked a specialization and not looking at it
	local disable = (selectedSpec ~= activeSpec) or ( playerTalentSpec and shownSpec ~= playerTalentSpec );
	if ( disable and not self.disabled ) then
		self.disabled = true;
		self.bg:SetDesaturated(true);
		scrollChild.description:SetTextColor(0.75, 0.75, 0.75);
		scrollChild.roleName:SetTextColor(0.75, 0.75, 0.75);
		scrollChild.specIcon:SetDesaturated(true);
		scrollChild.roleIcon:SetDesaturated(true);
		scrollChild.ring:SetDesaturated(true);
	elseif ( not disable and self.disabled ) then
		self.disabled = false;
		self.bg:SetDesaturated(false);
		scrollChild.description:SetTextColor(0.25, 0.1484375, 0.02);
		scrollChild.roleName:SetTextColor(0.25, 0.1484375, 0.02);
		scrollChild.specIcon:SetDesaturated(false);
		scrollChild.roleIcon:SetDesaturated(false);
		scrollChild.ring:SetDesaturated(false);	
	end
	-- disable Learn button
	if ( playerTalentSpec or disable ) then
		PlayerTalentFrameSpecializationLearnButton:Disable();
	else
		PlayerTalentFrameSpecializationLearnButton:Enable();
	end	
	
	-- set up spells
	index = 1
	local bonuses =  {GetSpecializationSpells(shownSpec)};
	for i=1,#bonuses,2 do
		local frame = scrollChild["abilityButton"..index];
		if not frame then
			frame = PlayerTalentFrame_CreateSpecSpellButton(index);
		end
	
		local name, subname, icon = GetSpellInfo(bonuses[i]);
		frame.icon:SetTexture(icon);
		frame.name:SetText(name);
		frame.subText:SetFormattedText(SPELLBOOK_AVAILABLE_AT, bonuses[i+1]);
		frame.spellID = bonuses[i];
		frame.extraTooltip = nil;
		if ( disable ) then
			frame.icon:SetDesaturated(true);
			frame.subText:SetTextColor(0.75, 0.75, 0.75);
		else
			frame.icon:SetDesaturated(false);
			frame.subText:SetTextColor(0.25, 0.1484375, 0.02);
		end
		frame:Show();
		index = index + 1;
	end
	
	-- Update spell button for mastery
	local masterySpell = GetSpecializationMasterySpells(shownSpec);
	if (masterySpell) then
		local _, class = UnitClass("player");
		frame = scrollChild["abilityButton"..index];
		if ( not frame ) then
			frame = PlayerTalentFrame_CreateSpecSpellButton(index);
		end
		
		--Override icon to Mastery icon
		local name, subname, icon = GetSpellInfo(masterySpell);
		frame.icon:SetTexture(icon);
		frame.name:SetFormattedText(TALENT_MASTERY_LABEL, name);
		frame.spellID = masterySpell;
		frame.spellID2 = masterySpell2;
		if ( disable ) then
			frame.icon:SetDesaturated(true);
			frame.subText:SetTextColor(0.75, 0.75, 0.75);
		else
			frame.icon:SetDesaturated(false);
			frame.subText:SetTextColor(0.25, 0.1484375, 0.02);
		end
		frame:Show();
		index = index+1;
	end

	-- hide unused spell buttons
	frame = scrollChild["abilityButton"..index];
	while frame do
		frame:Hide();
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