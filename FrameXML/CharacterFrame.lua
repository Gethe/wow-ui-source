CHARACTERFRAME_SUBFRAMES = { "PaperDollFrame", "ReputationFrame", "TokenFrame" };
CHARACTERFRAME_EXPANDED_WIDTH = 540;

local NUM_CHARACTERFRAME_TABS = 3;
function ToggleCharacter (tab, onlyShow)
	local subFrame = _G[tab];
	if ( subFrame ) then
		if (not subFrame.hidden) then
			PanelTemplates_SetTab(CharacterFrame, subFrame:GetID());
			if ( CharacterFrame:IsShown() ) then
				if ( subFrame:IsShown() ) then
					if ( not onlyShow ) then
						HideUIPanel(CharacterFrame);
					end
				else
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
					CharacterFrame_ShowSubFrame(tab);
				end
			else
				CharacterFrame_ShowSubFrame(tab);
				ShowUIPanel(CharacterFrame);
			end
		end
	end
end

function CharacterFrame_ShowSubFrame (frameName)
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value ~= frameName ) then
			_G[value]:Hide();
		end
	end
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			_G[value]:Show()
		end
	end
end

function CharacterFrameTab_OnClick (self, button)
	local name = self:GetName();

	if ( name == "CharacterFrameTab1" ) then
		ToggleCharacter("PaperDollFrame");
	elseif ( name == "CharacterFrameTab2" ) then
		ToggleCharacter("ReputationFrame");
	elseif ( name == "CharacterFrameTab3" ) then
		ToggleCharacter("TokenFrame");
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function CharacterFrame_OnLoad (self)
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("PLAYER_PVP_RANK_CHANGED");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	ButtonFrameTemplate_HideButtonBar(self);
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", PANEL_DEFAULT_WIDTH + PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_OFFSET);
	self:SetTitleColor(HIGHLIGHT_FONT_COLOR);
	self:SetTitleMaxLinesAndHeight(1, 13);

	SetTextStatusBarTextPrefix(PlayerFrameHealthBar, HEALTH);
	SetTextStatusBarTextPrefix(PlayerFrameManaBar, MANA);
	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, NUM_CHARACTERFRAME_TABS);
	PanelTemplates_SetTab(self, 1);
end

function CharacterFrame_UpdatePortrait()
	local masteryIndex = GetSpecialization();
	if (masteryIndex == nil) then
		local _, class = UnitClass("player");
		CharacterFrame:SetPortraitToAsset("Interface\\TargetingFrame\\UI-Classes-Circles");
		CharacterFrame:SetPortraitTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
	else
		local _, _, _, icon = GetSpecializationInfo(masteryIndex);
		CharacterFrame:SetPortraitTexCoord(0, 1, 0, 1);
		CharacterFrame:SetPortraitToAsset(icon);
	end
end

function CharacterFrame_OnEvent (self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end

	local arg1 = ...;
	if ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == "player" ) then
			self:SetTitle(UnitPVPName("player"));
		end
		return;
	elseif ( event == "PLAYER_PVP_RANK_CHANGED" ) then
		self:SetTitle(UnitPVPName("player"));
	elseif ( event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" ) then
		CharacterFrame_UpdatePortrait();
	end
end

local function ShouldShowExaltedPlusHelpTip()
	if (GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_REPUTATION_EXALTED_PLUS)) then
		return false;
	end

	local numFactions = GetNumFactions();
	for i=1, numFactions do
		local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain = GetFactionInfo(i);
		if (factionID and C_Reputation.IsFactionParagon(factionID) ) then
			return true;
		end
	end
	return false;
end

function CharacterFrame_OnShow (self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	CharacterFrame_UpdatePortrait();
	UpdateMicroButtons();
	PlayerFrameHealthBar.showNumeric = true;
	PlayerFrameManaBar.showNumeric = true;
	PlayerFrameAlternateManaBar.showNumeric = true;
	MonkStaggerBar.showNumeric = true;
	PetFrameHealthBar.showNumeric = true;
	PetFrameManaBar.showNumeric = true;
	ShowTextStatusBarText(PlayerFrameHealthBar);
	ShowTextStatusBarText(PlayerFrameManaBar);
	ShowTextStatusBarText(PlayerFrameAlternateManaBar);
	ShowTextStatusBarText(MonkStaggerBar);
	ShowTextStatusBarText(PetFrameHealthBar);
	ShowTextStatusBarText(PetFrameManaBar);
	StatusTrackingBarManager:SetTextLocked(true);

	if ShouldShowExaltedPlusHelpTip() then
		local helpTipInfo = {
			text = REPUTATION_EXALTED_PLUS_HELP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_REPUTATION_EXALTED_PLUS,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			offsetY = 8,
		};
		HelpTip:Show(self, helpTipInfo, CharacterFrameTab2);
	end

	MicroButtonPulseStop(CharacterMicroButton);	--Stop the button pulse
	EventRegistry:TriggerEvent("CharacterFrame.Show");
end

function CharacterFrame_OnHide (self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();
	PlayerFrameHealthBar.showNumeric = nil;
	PlayerFrameManaBar.showNumeric = nil;
	PlayerFrameAlternateManaBar.showNumeric = nil;
	MonkStaggerBar.showNumeric = nil;
	PetFrameHealthBar.showNumeric = nil;
	PetFrameManaBar.showNumeric = nil;
	HideTextStatusBarText(PlayerFrameHealthBar);
	HideTextStatusBarText(PlayerFrameManaBar);
	HideTextStatusBarText(PlayerFrameAlternateManaBar);
	HideTextStatusBarText(MonkStaggerBar);
	HideTextStatusBarText(PetFrameHealthBar);
	HideTextStatusBarText(PetFrameManaBar);
	StatusTrackingBarManager:SetTextLocked(false);
	PaperDollFrame.currentSideBar = nil;
	EventRegistry:TriggerEvent("CharacterFrame.Hide");
end

function CharacterFrame_Collapse()
	CharacterFrame:SetWidth(PANEL_DEFAULT_WIDTH);
	CharacterFrame.Expanded = false;
	for i = 1, #PAPERDOLL_SIDEBARS do
		_G[PAPERDOLL_SIDEBARS[i].frame]:Hide();
	end
	CharacterFrame.InsetRight:Hide();
	UpdateUIPanelPositions(CharacterFrame);
	PaperDollFrame_SetLevel();
end

function CharacterFrame_Expand()
	CharacterFrame:SetWidth(CHARACTERFRAME_EXPANDED_WIDTH);
	CharacterFrame.Expanded = true;
	if (PaperDollFrame:IsShown() and PaperDollFrame.currentSideBar) then
		PaperDollFrame.currentSideBar:Show();
	else
		CharacterStatsPane:Show();
	end
	PaperDollFrame_UpdateSidebarTabs();
	CharacterFrame.InsetRight:Show();
	UpdateUIPanelPositions(CharacterFrame);
	PaperDollFrame_SetLevel();
end

local function CompareFrameSize(frame1, frame2)
	return frame1:GetWidth() > frame2:GetWidth();
end
local CharTabtable = {};
function CharacterFrame_TabBoundsCheck(self)
	if ( string.sub(self:GetName(), 1, 17) ~= "CharacterFrameTab" ) then
		return;
	end

	for i=1, NUM_CHARACTERFRAME_TABS do
		_G["CharacterFrameTab"..i.."Text"]:SetWidth(0);
		PanelTemplates_TabResize(_G["CharacterFrameTab"..i], 0, nil, 36, 88);
	end

	local diff = _G["CharacterFrameTab"..NUM_CHARACTERFRAME_TABS]:GetRight() - CharacterFrame:GetRight();

	if ( diff > 0 and CharacterFrameTab3:IsShown() ) then
		--Find the biggest tab
		for i=1, NUM_CHARACTERFRAME_TABS do
			CharTabtable[i]=_G["CharacterFrameTab"..i];
		end
		table.sort(CharTabtable, CompareFrameSize);

		local i=1;
		while ( diff > 0 and i <= NUM_CHARACTERFRAME_TABS) do
			local tabText = _G[CharTabtable[i]:GetName().."Text"]
			local change = min(10, diff);
			diff = diff - change;
			tabText:SetWidth(0);
			PanelTemplates_TabResize(CharTabtable[i], -change, nil, 36-change, 88);
			i = i+1;
		end
	end
end

function CharacterFrameCorruption_OnLoad(self)
	self:RegisterEvent("COMBAT_RATING_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("SPELL_TEXT_UPDATE");
end

function CharacterFrameCorruption_OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		GetNegativeCorruptionEffectInfo();		-- Request corruption info to get the spell info down to the client
		CharacterFrameCorruption_UpdateVisibility(self);
	elseif event == "COMBAT_RATING_UPDATE" then
		CharacterFrameCorruption_UpdateVisibility(self);
	elseif event == "SPELL_TEXT_UPDATE" then
		if self.tooltipShowing then
			CharacterFrameCorruption_OnEnter(self);
		end
	end
end

function CharacterFrameCorruption_UpdateVisibility(self)
	self:SetShown(GetCorruption() > 0);
end

local function SortCorruptionEffects(a, b)
	return a.minCorruption < b.minCorruption;
end

function CharacterFrameCorruption_OnEnter(self)
	self.tooltipShowing = true;
	self.Eye:SetAtlas("Nzoth-charactersheet-icon-glow", true);
	SharedTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_CORRUPTED_ITEM);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetMinimumWidth(250);

	local corruption = GetCorruption();
	local corruptionResistance = GetCorruptionResistance();
	local totalCorruption = math.max(corruption - corruptionResistance, 0);

	local noWrap = false;
	local wrap = true;
	local descriptionXOffset = 10;

	GameTooltip_AddColoredLine(GameTooltip, CORRUPTION_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddColoredLine(GameTooltip, CORRUPTION_DESCRIPTION, NORMAL_FONT_COLOR);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddColoredDoubleLine(GameTooltip, CORRUPTION_TOOLTIP_LINE, corruption, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR, noWrap);
	GameTooltip_AddColoredDoubleLine(GameTooltip, CORRUPTION_RESISTANCE_TOOLTIP_LINE, corruptionResistance, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR, noWrap);
	GameTooltip_AddColoredDoubleLine(GameTooltip, TOTAL_CORRUPTION_TOOLTIP_LINE, totalCorruption, CORRUPTION_COLOR, CORRUPTION_COLOR, noWrap);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	local corruptionEffects = GetNegativeCorruptionEffectInfo();
	table.sort(corruptionEffects, SortCorruptionEffects);

	for i = 1, #corruptionEffects do
		local corruptionInfo = corruptionEffects[i];

		if i > 1 then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
		end

		-- We only show 1 effect above the player's current corruption.
		local lastEffect = (corruptionInfo.minCorruption > totalCorruption);

		GameTooltip_AddColoredLine(GameTooltip, CORRUPTION_EFFECT_HEADER:format(corruptionInfo.name, corruptionInfo.minCorruption), lastEffect and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR, noWrap);
		GameTooltip_AddColoredLine(GameTooltip, corruptionInfo.description, lastEffect and GRAY_FONT_COLOR or CORRUPTION_COLOR, wrap, descriptionXOffset);

		if lastEffect then
			break;
		end
	end

	GameTooltip:Show();
	PaperDollFrame_UpdateCorruptedItemGlows(true);
	PlaySound(SOUNDKIT.NZOTH_EYE_SQUISH);
end

function CharacterFrameCorruption_OnLeave(self)
	self.tooltipShowing = false;
	self.Eye:SetAtlas("Nzoth-charactersheet-icon", true);
	GameTooltip_Hide();
	PaperDollFrame_UpdateCorruptedItemGlows(false);
end
