------------------------------------
-- Global Constants

DEFAULT_TALENT_SPEC = "spec1";

------------------------------------
-- Local Data

local specTabs = { }; -- Filled in by PlayerSpecTab_OnLoad.
local numSpecTabs = 0;
local activeSpec = nil; -- Should be a key of TALENT_UI_SPECS.
local selectedSpec = nil; -- Should be a key of TALENT_UI_SPECS.

-- Cache talent tab widths so we can resize tabs to fit for localization.
local talentTabWidthCache = { };

------------------------------------
-- TalentUIUtil

TalentUIUtil = {};

-- specTab: A frame inherting from PlayerSpecTabTemplate.
-- specId: A string uniquely identifying the spec.
function TalentUIUtil.AddSpecTab(specTab, specId)
	specTabs[specId] = specTab;
end

function TalentUIUtil.GetNumSpecTabs()
	return CountTable(specTabs);
end

-- specId: A string uniquely identifying the spec.
function TalentUIUtil.GetSpecTab(specId)
	return specTabs[specId];
end

function TalentUIUtil.GetSpecTabs()
	return specTabs;
end

function TalentUIUtil.SelectActiveSpec()
	TalentUIUtil.SetSelectedSpec(activeSpec);
end

function TalentUIUtil.GetActiveSpecTab()
	return activeSpec and specTabs[activeSpec];
end

function TalentUIUtil.IsActiveSpecSelected()
	return selectedSpec and (selectedSpec == activeSpec);
end

-- specId: A string uniquely identifying the spec.
function TalentUIUtil.IsSpecActive(specId)
	return activeSpec and (activeSpec == specId);
end

-- specId: A string uniquely identifying the spec.
function TalentUIUtil.SetSelectedSpec(specId)
	selectedSpec = specId;
end

function TalentUIUtil.ClearSelectedSpec()
	selectedSpec = nil;
end

-- Returns: An entry of TALENT_UI_SPECS, if one is selected.
function TalentUIUtil.GetSelectedSpec()
	if not selectedSpec then
		return nil;
	end

	return TALENT_UI_SPECS[selectedSpec];
end

-- specId: A string uniquely identifying the spec.
function TalentUIUtil.IsSpecSelected(specId)
	return selectedSpec and (selectedSpec == specId);
end

function TalentUIUtil.IsAnySpecSelected()
	return selectedSpec ~= nil;
end

-- tabIndex: The index of a Spec/Talents Frame tab.
-- width: The cached width of the tab.
function TalentUIUtil.SetCachedWidthForTalentTab(tabIndex, width)
	talentTabWidthCache[tabIndex] = width;
end

function TalentUIUtil.GetNumCachedTabWidths()
	return #talentTabWidthCache;
end

-- tabIndex: The index of a Spec/Talents Frame tab.
function TalentUIUtil.GetCachedTalentTabWidth(tabIndex)
	return talentTabWidthCache[tabIndex];
end

function TalentUIUtil.WipeTalentTabWidthCache()
	wipe(talentTabWidthCache);
end

------------------------------------
-- PlayerTalentFrame

function PlayerTalentFrame_Close()
	HideUIPanel(PlayerTalentFrame);
end

function PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup, numTalentGroups)
	activeSpec = DEFAULT_TALENT_SPEC;
	for index, spec in next, TALENT_UI_SPECS do
		if ( not spec.pet and spec.talentGroup == activeTalentGroup ) then
			activeSpec = index;
			break;
		end
	end

	if PlayerTalentFrame_PostUpdateActiveSpec then
		PlayerTalentFrame_PostUpdateActiveSpec(numTalentGroups);
	end
end

function PlayerTalentFrame_ToggleGlyphFrame(suggestedTalentGroup)
	GlyphFrame_LoadUI();
	if ( GlyphFrame ) then
		local hidden = false;
		if (not PlayerTalentFrame:IsShown()) then
			ShowUIPanel(PlayerTalentFrame);
			hidden = false;
		else
			local spec = selectedSpec and TALENT_UI_SPECS[selectedSpec];
			if ( spec and spec.hasGlyphs and
				 PanelTemplates_GetSelectedTab(PlayerTalentFrame) == GLYPH_TAB ) then
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
				local spec = TALENT_UI_SPECS[selectedSpec];
				if ( spec.hasGlyphs ) then
					suggestedTalentGroup = spec.talentGroup;
				end
			end
			for _, index in ipairs(TALENT_SORT_ORDER) do
				local spec = TALENT_UI_SPECS[index];
				if ( spec.hasGlyphs and spec.talentGroup == suggestedTalentGroup ) then
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
		for index, spec in next, TALENT_UI_SPECS do
			if ( spec.hasGlyphs and spec.talentGroup == talentGroup ) then
				PlayerSpecTab_OnClick(specTabs[index]);
				PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab"..GLYPH_TAB]);
				break;
			end
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

------------------------------------
-- PlayerTalentTab

function PlayerTalentTab_OnEvent(self, event, ...)
	if ( C_SpecializationInfo.CanPlayerUseTalentUI() and PanelTemplates_GetSelectedTab(PlayerTalentFrame) ~= self:GetID() ) then
		SetButtonPulse(self, 60, 0.75);
	end
end

------------------------------------
-- PlayerTalentFrameTab

function PlayerTalentFrameTab_OnEnter(self)
	if ( self.textWidth and self.textWidth > self:GetFontString():GetWidth() ) then	--We're ellipsizing.
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
		GameTooltip:SetText(self:GetText());
	end
end

function PlayerTalentFrameTab_OnLoad(self)
	self:SetFrameLevel(self:GetFrameLevel() + 2);
end

------------------------------------
-- PlayerTalentFrameActivateButton

function PlayerTalentFrameActivateButton_OnLoad(self)
	self:SetWidth(self:GetTextWidth() + 40);
end

function PlayerTalentFrameActivateButton_OnHide(self)
	self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function PlayerTalentFrameActivateButton_OnClick(self)
	if ( selectedSpec ) then
		local talentGroup = TALENT_UI_SPECS[selectedSpec].talentGroup;
		if ( talentGroup ) then
			C_SpecializationInfo.SetActiveSpecGroup(talentGroup);
		end
	end
end

------------------------------------
-- PlayerGlyphTab

function PlayerGlyphTab_OnClick(self)
	StaticPopup_Hide("CONFIRM_REMOVE_TALENT")
	PlayerTalentFrameTab_OnClick(self);
	SetButtonPulse(_G["PlayerTalentFrameTab"..GLYPH_TAB], 0, 0);
end

function PlayerGlyphTab_OnEvent(self, event, ...)
	if INSCRIPTION_AVAILABLE then
		if ( UnitLevel("player") == (SHOW_INSCRIPTION_LEVEL - 1) and PanelTemplates_GetSelectedTab(PlayerTalentFrame) ~= self:GetID() ) then
			SetButtonPulse(self, 60, 0.75);
		end
	end
end
