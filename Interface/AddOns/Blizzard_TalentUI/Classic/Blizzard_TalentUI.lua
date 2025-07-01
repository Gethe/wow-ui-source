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

UIPanelWindows["PlayerTalentFrame"] = { area = "left", pushable = 6, xoffset = -16, yoffset = 12, bottomClampOverride = 140+12, width = 353, height = 424, whileDead = 1 };

------------------------------------
-- Global Constants

GLYPH_TAB = 4;

TALENT_UI_SPECS = {
	["spec1"] = {
		name = TALENT_SPEC_PRIMARY,
		talentGroup = 1,
		unit = "player",
		pet = false,
		tooltip = TALENT_SPEC_PRIMARY,
		portraitUnit = "player",
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
		hasGlyphs = true,
		glyphName = TALENT_SPEC_PRIMARY_GLYPH,
	},
	["spec2"] = {
		name = TALENT_SPEC_SECONDARY,
		talentGroup = 2,
		unit = "player",
		pet = false,
		tooltip = TALENT_SPEC_SECONDARY,
		portraitUnit = "player",
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
		hasGlyphs = true,
		glyphName = TALENT_SPEC_SECONDARY_GLYPH,
	},
	["petspec1"] = {
		name = TALENT_SPEC_PET_PRIMARY,
		talentGroup = 1,
		unit = "pet",
		tooltip = TALENT_SPEC_PET_PRIMARY,
		pet = true,
		portraitUnit = "pet",
		defaultSpecTexture = nil,
		hasGlyphs = false,
		glyphName = nil,
	},
};

------------------------------------
-- Local Data

-- cache talent info so we can quickly display cool stuff like the number of points spent in each tab
local talentSpecInfoCache = {
	["spec1"]		= { },
	["spec2"]		= { },
	["petspec1"]	= { },
};

-- Speed References
local next = next;
local ipairs = ipairs;

------------------------------------
-- PlayerTalentFrame

function PlayerTalentFrame_Toggle(pet, suggestedTalentGroup)
	local hidden;
	local talentTabSelected = PanelTemplates_GetSelectedTab(PlayerTalentFrame) ~= GLYPH_TAB;
	if ( not PlayerTalentFrame:IsShown() ) then
		ShowUIPanel(PlayerTalentFrame);
		hidden = false;
	else
		local spec = TalentUIUtil.GetSelectedSpec();
		if ( spec and talentTabSelected ) then
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
		local selectedSpec = TalentUIUtil.GetSelectedSpec();
		if ( selectedSpec and (selectedSpec.pet == pet) ) then
			suggestedTalentGroup = selectedSpec.talentGroup;
		end
		for _, index in ipairs(TALENT_SORT_ORDER) do
			local spec = TALENT_UI_SPECS[index];
			if ( spec.pet == pet and spec.talentGroup == suggestedTalentGroup ) then
				PlayerSpecTab_OnClick(TalentUIUtil.GetSpecTab(index));
				if ( not talentTabSelected ) then
					PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..PlayerTalentTab_GetBestDefaultTab(index)]);
				end
				break;
			end
		end
	end
end

function PlayerTalentFrame_Open(pet, talentGroup)
	ShowUIPanel(PlayerTalentFrame);
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
		-- set the title text of the GlyphFrame
		local selectedSpec = TalentUIUtil.GetSelectedSpec();
		if ( selectedSpec and selectedSpec.glyphName and GetNumTalentGroups() > 1 ) then
			GlyphFrameTitleText:SetText(selectedSpec.glyphName);
		else
			GlyphFrameTitleText:SetText(GLYPHS);
		end
		-- show/update the glyph frame
		if ( GlyphFrame:IsShown() ) then
			GlyphFrame_Update();
		else
			GlyphFrame:Show();
		end
		-- don't forget to hide the scroll button overlay or it may show up on top of the GlyphFrame!
		UIFrameFlashStop(PlayerTalentFrameScrollButtonOverlay);
	end
end

function PlayerTalentFrame_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED");
	self:RegisterEvent("PREVIEW_PET_TALENT_POINTS_CHANGED");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PET_TALENT_UPDATE");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self.unit = "player";
	self.inspect = false;
	self.pet = false;
	self.talentGroup = 1;
	self.updateFunction = PlayerTalentFrame_Update;

	TalentFrame_Load(self);

	-- setup talent buttons
	--local button;
	for i = 1, MAX_NUM_TALENTS do
		local button = _G["PlayerTalentFrameTalent"..i];
		if ( button ) then
			button:SetScript("OnClick", PlayerTalentFrameTalent_OnClick);
			button:SetScript("OnEvent", PlayerTalentFrameTalent_OnEvent);
			button:SetScript("OnEnter", PlayerTalentFrameTalent_OnEnter);
		end
	end

	-- setup tabs
	PanelTemplates_SetNumTabs(self, MAX_TALENT_TABS + 1);	-- add one for the GLYPH_TAB

	-- initialize active spec as a fail safe
	local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup();
	local numTalentGroups = GetNumTalentGroups();
	PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup, numTalentGroups);
end

function PlayerTalentFrame_OnShow(self)
	-- Stop buttons from flashing after skill up
	SetButtonPulse(TalentMicroButton, 0, 1);

	PlaySound(SOUNDKIT.TALENT_SCREEN_OPEN);
	UpdateMicroButtons();

	if ( not TalentUIUtil.IsAnySpecSelected() ) then
		-- if no spec was selected, try to select the active one
		PlayerSpecTab_OnClick(TalentUIUtil.GetActiveSpecTab() or TalentUIUtil.GetSpecTab(DEFAULT_TALENT_SPEC));
	else
		PlayerTalentFrame_Refresh();
	end

	-- Set flag
	if ( not GetCVarBool("talentFrameShown") ) then
		SetCVar("talentFrameShown", 1);
		UIFrameFlash(PlayerTalentFrameScrollButtonOverlay, 0.5, 0.5, 60);
	end
end

function  PlayerTalentFrame_OnHide()
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.TALENT_SCREEN_CLOSE);
	UIFrameFlashStop(PlayerTalentFrameScrollButtonOverlay);
	-- clear caches
	for _, info in next, talentSpecInfoCache do
		wipe(info);
	end
	TalentUIUtil.WipeTalentTabWidthCache()
end

function PlayerTalentFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_TALENT_UPDATE" or event == "PET_TALENT_UPDATE" ) then
		PlayerTalentFrame_Refresh();
	elseif ( event == "PREVIEW_TALENT_POINTS_CHANGED" ) then
		--local talentIndex, tabIndex, groupIndex, points = ...;
		local selectedSpec = TalentUIUtil.GetSelectedSpec();
		if ( selectedSpec and not selectedSpec.pet ) then
			PlayerTalentFrame_Refresh();
		end
	elseif ( event == "PREVIEW_PET_TALENT_POINTS_CHANGED" ) then
		--local talentIndex, tabIndex, groupIndex, points = ...;
		local selectedSpec = TalentUIUtil.GetSelectedSpec();
		if ( selectedSpec and selectedSpec.pet ) then
			PlayerTalentFrame_Refresh();
		end
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		-- update the talent frame's portrait
		if ( unit == PlayerTalentFramePortrait.unit ) then
			SetPortraitTexture(PlayerTalentFramePortrait, unit);
		end
		-- update spec tabs' portraits
		local specTabs = TalentUIUtil.GetSpecTabs();
		for _, frame in next, specTabs do
			if ( frame.usingPortraitTexture ) then
				local spec = TALENT_UI_SPECS[frame.specIndex];
				if ( unit == spec.unit and spec.portraitUnit ) then
					SetPortraitTexture(frame:GetNormalTexture(), unit);
				end
			end
		end
	elseif ( event == "UNIT_PET" ) then
		local summoner = ...;
		if ( summoner == "player" ) then
			local selectedSpec = TalentUIUtil.GetSelectedSpec();
			if ( selectedSpec and selectedSpec.pet ) then
				-- if the selected spec is a pet spec...
				local numTalentGroups = GetNumTalentGroups(false, true);
				if ( numTalentGroups == 0 ) then
					--...and a pet spec is not available, select the default spec
					PlayerSpecTab_OnClick(TalentUIUtil.GetActiveSpecTab() or TalentUIUtil.GetSpecTab(DEFAULT_TALENT_SPEC));
					return;
				end
			end
			PlayerTalentFrame_Refresh();
		end
	elseif ( event == "PLAYER_LEVEL_UP" ) then
		local selectedSpec = TalentUIUtil.GetSelectedSpec();
		if ( selectedSpec and not selectedSpec.pet ) then
			local level = ...;
			PlayerTalentFrame_Update(level);
		end
	end
end

function PlayerTalentFrame_Refresh()
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	EventRegistry:TriggerEvent("PlayerTalentFrame.TabShow", selectedTab);
	if ( selectedTab == GLYPH_TAB ) then
		PlayerTalentFrame_ShowGlyphFrame();
	else
		PlayerTalentFrame_HideGlyphFrame();
	end
	TalentFrame_Update(PlayerTalentFrame);
end

function PlayerTalentFrame_Update(playerLevel)
	local activeTalentGroup, numTalentGroups = C_SpecializationInfo.GetActiveSpecGroup(false, false), GetNumTalentGroups(false, false);
	local activePetTalentGroup, numPetTalentGroups = C_SpecializationInfo.GetActiveSpecGroup(false, true), GetNumTalentGroups(false, true);

	-- update specs
	if ( not PlayerTalentFrame_UpdateSpecs(activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups) ) then
		-- the current spec is not selectable any more, discontinue updates
		return;
	end

	-- update tabs
	if ( not PlayerTalentFrame_UpdateTabs(playerLevel) ) then
		-- the current spec is not selectable any more, discontinue updates
		return;
	end

	-- set the frame portrait
	SetPortraitTexture(PlayerTalentFramePortrait, PlayerTalentFrame.unit);

	-- update active talent group stuff
	PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup, numTalentGroups);

	-- update talent controls
	PlayerTalentFrame_UpdateControls(activeTalentGroup, numTalentGroups);
end

function PlayerTalentFrame_PostUpdateActiveSpec(numTalentGroups)
	-- Make UI adjustments.
	local spec = TalentUIUtil.GetSelectedSpec();
	local hasMultipleTalentGroups = numTalentGroups > 1;
	if ( spec and hasMultipleTalentGroups ) then
		PlayerTalentFrameTitleText:SetText(spec.name);
	else
		PlayerTalentFrameTitleText:SetText(TALENTS);
	end

	if ( TalentUIUtil.IsActiveSpecSelected() and hasMultipleTalentGroups ) then
		--PlayerTalentFrameActiveTalentGroupFrame:Show();
	else
		PlayerTalentFrameActiveTalentGroupFrame:Hide();
	end
end

------------------------------------
-- PlayerTalentFrameTalents

function PlayerTalentFrameTalent_OnClick(self, button)
	local selectedSpec = TalentUIUtil.GetSelectedSpec();
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetTalentLink(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID(),
			PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalentsOption"));
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	elseif ( selectedSpec and (TalentUIUtil.IsActiveSpecSelected() or selectedSpec.pet) ) then
		-- only allow functionality if an active spec is selected
		if ( button == "LeftButton" ) then
			if ( GetCVarBool("previewTalentsOption") ) then
				AddPreviewTalentPoints(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID(), 1, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			else
				LearnTalent(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID(), PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			end
		elseif ( button == "RightButton" ) then
			if ( GetCVarBool("previewTalentsOption") ) then
				AddPreviewTalentPoints(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID(), -1, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
			end
		end
	end
end

function PlayerTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		local talentInfoQuery = {};
		talentInfoQuery.specializationIndex = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
		talentInfoQuery.talentIndex = self:GetID();
		talentInfoQuery.isInspect = PlayerTalentFrame.inspect;
		talentInfoQuery.isPet = PlayerTalentFrame.pet;
		talentInfoQuery.groupIndex = PlayerTalentFrame.talentGroup;
		local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);
		if talentInfo then
			GameTooltip:SetTalent(talentInfo.talentID, PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
		end
	end
end

function PlayerTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local talentInfoQuery = {};
	talentInfoQuery.specializationIndex = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	talentInfoQuery.talentIndex = self:GetID();
	talentInfoQuery.isInspect = PlayerTalentFrame.inspect;
	talentInfoQuery.isPet = PlayerTalentFrame.pet;
	talentInfoQuery.groupIndex = PlayerTalentFrame.talentGroup;
	local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);
	if talentInfo then
		GameTooltip:SetTalent(talentInfo.talentID, PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
	end
	self.UpdateTooltip = PlayerTalentFrameTalent_OnEnter;
end

------------------------------------
-- Controls

function PlayerTalentFrame_UpdateControls(activeTalentGroup, numTalentGroups)
	local spec = TalentUIUtil.GetSelectedSpec();
	local isActiveSpec = TalentUIUtil.IsActiveSpecSelected();

	-- show the multi-spec status frame if this is not a pet spec or we have more than one talent group
	local showStatusFrame = not spec.pet and numTalentGroups > 1;
	-- show the activate button if we were going to show the status frame but this is not the active spec
	local showActivateButton = showStatusFrame and not isActiveSpec;
	if ( showActivateButton ) then
		PlayerTalentFrameActivateButton:Show();
		PlayerTalentFrameStatusFrame:Hide();
	else
		PlayerTalentFrameActivateButton:Hide();
		if ( showStatusFrame ) then
			PlayerTalentFrameStatusFrame:Show();
		else
			PlayerTalentFrameStatusFrame:Hide();
		end
	end

	local preview = GetCVarBool("previewTalentsOption");

	-- enable the control bar if this is the active spec, preview is enabled, and preview points were spent
	local talentPoints = GetUnspentTalentPoints(false, spec.pet, spec.talentGroup);
	if ( (spec.pet or isActiveSpec) and talentPoints > 0 and preview ) then
		PlayerTalentFramePreviewBar:Show();
		-- enable accept/cancel buttons if preview talent points were spent
		if ( GetGroupPreviewTalentPointsSpent(spec.pet, spec.talentGroup) > 0 ) then
			PlayerTalentFrameLearnButton:Enable();
			PlayerTalentFrameResetButton:Enable();
		else
			PlayerTalentFrameLearnButton:Disable();
			PlayerTalentFrameResetButton:Disable();
		end
		-- squish all frames to make room for this bar
		PlayerTalentFramePointsBar:SetPoint("BOTTOM", PlayerTalentFramePreviewBar, "TOP", 0, -4);
	else
		PlayerTalentFramePreviewBar:Hide();
		-- unsquish frames since the bar is now hidden
		PlayerTalentFramePointsBar:SetPoint("BOTTOM", PlayerTalentFrame, "BOTTOM", 0, 81);
	end
end

function PlayerTalentFrameActivateButton_OnShow(self)
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	PlayerTalentFrameActivateButton_Update();
end

function PlayerTalentFrameActivateButton_OnEvent(self, event, ...)
	PlayerTalentFrameActivateButton_Update();
end

function PlayerTalentFrameActivateButton_Update()
	local spec = TalentUIUtil.GetSelectedSpec();
	if ( spec and PlayerTalentFrameActivateButton:IsShown() ) then
		-- if the activation spell is being cast currently, disable the activate button
		if ( C_Spell.IsCurrentSpell(TALENT_ACTIVATION_SPELLS[spec.talentGroup]) ) then
			PlayerTalentFrameActivateButton:Disable();
		else
			PlayerTalentFrameActivateButton:Enable();
		end
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

------------------------------------
-- PlayerTalentFrameDownArrow

function PlayerTalentFrameDownArrow_OnClick(self, button)
	local parent = self:GetParent();
	parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2));
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	UIFrameFlashStop(PlayerTalentFrameScrollButtonOverlay);
end

------------------------------------
-- PlayerTalentFrameTab

function PlayerTalentFrame_UpdateTabs(playerLevel)
	local totalTabWidth = 0;

	local firstShownTab;

	-- setup talent tabs
	local maxPointsSpent = 0;
	local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
	local numTabs = GetNumTalentTabs(PlayerTalentFrame.inspect, PlayerTalentFrame.pet);
	local tab;

	for i = 1, MAX_TALENT_TABS do
		-- clear cached widths
		TalentUIUtil.SetCachedWidthForTalentTab(i, 0);
		tab = _G["PlayerTalentFrameTab"..i];
		if ( tab ) then
			if ( i <= numTabs ) then
				local _, name, _, icon, _, _, pointsSpent, background, previewPointsSpent = C_SpecializationInfo.GetSpecializationInfo(i, PlayerTalentFrame.inspect, PlayerTalentFrame.pet, nil, nil, PlayerTalentFrame.talentGroup);
				if ( i == selectedTab ) then
					-- If tab is the selected tab set the points spent info
					local displayPointsSpent = pointsSpent + previewPointsSpent;
					PlayerTalentFrameSpentPointsText:SetFormattedText(MASTERY_POINTS_SPENT, name, HIGHLIGHT_FONT_COLOR_CODE..displayPointsSpent..FONT_COLOR_CODE_CLOSE);
					PlayerTalentFrame.pointsSpent = pointsSpent;
					PlayerTalentFrame.previewPointsSpent = previewPointsSpent;
				end
				tab:SetText(name);
				PanelTemplates_TabResize(tab, 0);
				-- record the text width to see if we need to display a tooltip
				tab.textWidth = tab:GetTextWidth();
				-- record the tab widths for resizing later
				TalentUIUtil.SetCachedWidthForTalentTab(i, PanelTemplates_GetTabWidth(tab));
				totalTabWidth = totalTabWidth + TalentUIUtil.GetCachedTalentTabWidth(i);
				tab:Show();
				firstShownTab = firstShownTab or tab;
			else
				tab:Hide();
				tab.textWidth = 0;
			end
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
		else
			tab:Hide();
			TalentUIUtil.SetCachedWidthForTalentTab(GLYPH_TAB, 0);
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

	-- update the tabs
	local numGlyphTabs = 1;
	PanelTemplates_SetNumTabs(PlayerTalentFrame, numTabs + numGlyphTabs);
	PanelTemplates_UpdateTabs(PlayerTalentFrame);

	return true;
end

function PlayerTalentFrameTab_OnClick(self)
	local id = self:GetID();
	PanelTemplates_SetTab(PlayerTalentFrame, id);
	PlayerTalentFrame_Refresh();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

------------------------------------
-- PlayerTalentTab

function PlayerTalentTab_OnLoad(self)
	PlayerTalentFrameTab_OnLoad(self);

	self.selectedTextY = 4;
	self:RegisterEvent("PLAYER_LEVEL_UP");
end

function PlayerTalentTab_OnClick(self)
	PlayerTalentFrameTab_OnClick(self);
	for i=1, MAX_TALENT_TABS do
		SetButtonPulse(_G["PlayerTalentFrameTab"..i], 0, 0);
	end
end

function PlayerTalentTab_GetBestDefaultTab(specIndex)
	if ( not specIndex ) then
		return DEFAULT_TALENT_TAB;
	end

	local spec = TALENT_UI_SPECS[specIndex];
	if ( not spec ) then
		return DEFAULT_TALENT_TAB;
	end

	local specInfoCache = talentSpecInfoCache[specIndex];
	TalentFrame_UpdateSpecInfoCache(specInfoCache, false, spec.pet, spec.talentGroup);
	if ( specInfoCache.primaryTabIndex > 0 ) then
		return talentSpecInfoCache[specIndex].primaryTabIndex;
	else
		return DEFAULT_TALENT_TAB;
	end
end

------------------------------------
-- PlayerGlyphTab

function PlayerGlyphTab_OnLoad(self)
	PlayerTalentFrameTab_OnLoad(self);

	self:RegisterEvent("PLAYER_LEVEL_UP");
	GLYPH_TAB = self:GetID();
	-- we can record the text width for the glyph tab now since it never changes
	self.textWidth = self:GetTextWidth();
	self.selectedTextY = 4;
end

-- Specs

-- PlayerTalentFrame_UpdateSpecs is a helper function for PlayerTalentFrame_Update.
-- Returns true on a successful update, false otherwise. An update may fail if the currently
-- selected tab is no longer selectable. In this case, the first selectable tab will be selected.
function PlayerTalentFrame_UpdateSpecs(activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups)
	-- update each of the spec tabs
	local firstShownTab, lastShownTab;
	local numShown = 0;
	local numSpecTabs = TalentUIUtil.GetNumSpecTabs()
	for i = 1, numSpecTabs do
		local frame = _G["PlayerSpecTab"..i];
		local specIndex = frame.specIndex;
		local spec = TALENT_UI_SPECS[specIndex];
		if ( PlayerSpecTab_Update(frame, activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups) ) then
			firstShownTab = firstShownTab or frame;
			numShown = numShown + 1;
			frame:ClearAllPoints();
			if ( numShown == 1 ) then
				--...start the first tab off at a base location
				frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPRIGHT", -32, -65);
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

function PlayerSpecTab_Update(self, ...)
	local activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups = ...;

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

	-- set the background
	local name = self:GetName();
	local backgroundTexture = _G[name.."Background"];
	backgroundTexture:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab");
	backgroundTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 11);

	-- update the spec info cache
	TalentFrame_UpdateSpecInfoCache(talentSpecInfoCache[specIndex], false, spec.pet, spec.talentGroup);

	-- update spec tab icon
	local hasMultipleTalentGroups = numTalentGroups > 1;
	local normalTexture = self:GetNormalTexture();
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
	TalentUIUtil.AddSpecTab(self, specIndex);

	-- set the spec's portrait
	local spec = TALENT_UI_SPECS[self.specIndex];
	if ( spec.portraitUnit ) then
		SetPortraitTexture(self:GetNormalTexture(), spec.portraitUnit);
		self.usingPortraitTexture = true;
	else
		self.usingPortraitTexture = false;
	end

	-- set the checked texture
	local checkedTexture = self:GetCheckedTexture();
	checkedTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight");

	local activeTalentGroup, numTalentGroups = C_SpecializationInfo.GetActiveSpecGroup(false, false), GetNumTalentGroups(false, false);
	local activePetTalentGroup, numPetTalentGroups = C_SpecializationInfo.GetActiveSpecGroup(false, true), GetNumTalentGroups(false, true);
	PlayerSpecTab_Update(self, activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups);
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
	local specIndex = self.specIndex;
	TalentUIUtil.SetSelectedSpec(specIndex);

	-- set data on the talent frame
	local spec = TALENT_UI_SPECS[specIndex];
	PlayerTalentFrame.pet = spec.pet;
	PlayerTalentFrame.unit = spec.unit;
	PlayerTalentFrame.talentGroup = spec.talentGroup;

	-- select a tab if one is not already selected
	if ( not PanelTemplates_GetSelectedTab(PlayerTalentFrame) ) then
		PanelTemplates_SetTab(PlayerTalentFrame, PlayerTalentTab_GetBestDefaultTab(specIndex));
	end

	-- update the talent frame
	PlayerTalentFrame_Refresh();
end

function PlayerSpecTab_OnEnter(self)
	local specIndex = self.specIndex;
	local spec = TALENT_UI_SPECS[specIndex];
	if ( spec.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		-- name
		if ( GetNumTalentGroups(false, true) <= 1 and GetNumTalentGroups(false, false) <= 1 ) then
			-- set the tooltip to be the unit's name
			GameTooltip:AddLine(UnitName(spec.unit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		else
			-- set the tooltip to be the spec name
			GameTooltip:AddLine(spec.tooltip);
			if ( TalentUIUtil.IsSpecActive(self.specIndex) ) then
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
