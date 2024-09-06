CHARACTERFRAME_SUBFRAMES = { "PaperDollFrame", "ReputationFrame", "TokenFrame" };
CHARACTERFRAME_EXPANDED_WIDTH = 540;


local characterFrameDisplayInfo = {
	["Default"] = {
		title = UnitPVPName("player"),
		titleColor = HIGHLIGHT_FONT_COLOR,
		width = PANEL_DEFAULT_WIDTH, -- Dynamically updated by CharacterFrameMixin:Expand()/CharacterFrameMixin:Collapse();
	},
	["ReputationFrame"] = {
		title = REPUTATION,
		titleColor = NORMAL_FONT_COLOR,
		width = 400,
	},
	["TokenFrame"] = {
		title = CURRENCY,
		titleColor = NORMAL_FONT_COLOR,
		width = 400,
	},
};

local NUM_CHARACTERFRAME_TABS = 3;
function ToggleCharacter (tab, onlyShow)
	if C_GameRules.IsGameRuleActive(Enum.GameRule.CharacterPanelDisabled) then
		return;
	end

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
					CharacterFrame:ShowSubFrame(tab);
				end
			else
				CharacterFrame:ShowSubFrame(tab);
				ShowUIPanel(CharacterFrame);
			end
			CharacterFrame:RefreshDisplay();
		end
	end
end

function ShowCharacterFrameIfMatchesContext()
	if CharacterFrame:IsShown() then
		return;
	end

	local count = 0;
	for i = 1, NUM_INVSLOTS do
		if ItemButtonUtil.GetItemContextMatchResultForPaperDollFrame(i) == ItemButtonUtil.ItemContextMatchResult.Match then
			ToggleCharacter("PaperDollFrame");
			return;
		end
	end
end

CharacterFrameMixin = {};

function CharacterFrameMixin:ToggleTokenFrame()
	if C_CurrencyInfo.GetCurrencyListSize() <= 0 then
		return;
	end

	ToggleCharacter("TokenFrame");
end

function CharacterFrameMixin:ShowSubFrame(frameName)
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value ~= frameName ) then
			_G[value]:Hide();
		end
	end
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			_G[value]:Show()
			self.activeSubframe = frameName;
		end
	end
end

local CharacterFrameEvents = {
	"UNIT_NAME_UPDATE",
	"PLAYER_PVP_RANK_CHANGED",
	"PLAYER_TALENT_UPDATE",
	"ACTIVE_TALENT_GROUP_CHANGED",
	"UNIT_PORTRAIT_UPDATE",
	"PORTRAITS_UPDATED"
}

function CharacterFrameMixin:OnLoad()
	ButtonFrameTemplate_HideButtonBar(self);
	self:SetTitleMaxLinesAndHeight(1, 13);

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, NUM_CHARACTERFRAME_TABS);
	PanelTemplates_SetTab(self, 1);
end

function CharacterFrameMixin:SetPortraitToSpecIcon()
	local specialization = GetSpecialization();
	local icon = specialization ~= nil and select(4, GetSpecializationInfo(specialization));
	if not icon then
		local name, fileName, classID = UnitClass("player");
		self:SetPortraitToClassIcon(fileName);
		return;
	end

	self:SetPortraitTexCoord(0, 1, 0, 1);
	self:SetPortraitToAsset(icon);
end

function CharacterFrameMixin:UpdatePortrait()
	local useSpecIcon = self.activeSubframe == "PaperDollFrame";
	if useSpecIcon then
		self:SetPortraitToSpecIcon();
		return;
	end

	SetPortraitTexture(self:GetPortrait(), "player");
end

function CharacterFrameMixin:UpdateTitle()
	local displayInfo = characterFrameDisplayInfo[self.activeSubframe] or characterFrameDisplayInfo["Default"];
	self:SetTitleColor(displayInfo.titleColor);
	self:SetTitle(displayInfo.title);
end

function CharacterFrameMixin:UpdateSize()
	local oldWidth = self:GetWidth();

	local displayInfo = characterFrameDisplayInfo[self.activeSubframe] or characterFrameDisplayInfo["Default"];
	self:SetWidth(displayInfo.width);

	local useStaticInsetSize = self.activeSubframe == "PaperDollFrame";
	if useStaticInsetSize then
		-- PaperDollFrame always wants the same sized inset regardless of the CharacterFrame width...
		self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", PANEL_DEFAULT_WIDTH + PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_OFFSET);
	else
		-- ...while other subframes want their inset to update based on the CharacterFrame width
		self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, PANEL_INSET_BOTTOM_OFFSET);
	end

	if oldWidth ~= displayInfo.width then
		UpdateUIPanelPositions(self);
	end
end

function CharacterFrameMixin:RefreshDisplay()
	CharacterFrame:UpdateSize();
	CharacterFrame:UpdateTabBounds();
	CharacterFrame:UpdatePortrait();
	CharacterFrame:UpdateTitle();
end

function CharacterFrameMixin:OnEvent (event, ...)
	if ( not self:IsShown() ) then
		return;
	end

	local arg1 = ...;
	if ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == "player" ) then
			characterFrameDisplayInfo["Default"].title = UnitPVPName("player");
			self:UpdateTitle();
		end
		return;
	elseif ( event == "PLAYER_PVP_RANK_CHANGED" ) then
		characterFrameDisplayInfo["Default"].title = UnitPVPName("player");
		self:UpdateTitle();
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( unit == "player" ) then
			self:UpdatePortrait();
		end
	elseif ( event == "PORTRAITS_UPDATED" or event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" ) then
		self:UpdatePortrait();
	end
end

local function ShouldShowExaltedPlusHelpTip()
	if (GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_REPUTATION_EXALTED_PLUS)) then
		return false;
	end

	local numFactions = C_Reputation.GetNumFactions();
	for i=1, numFactions do
		local factionData = C_Reputation.GetFactionDataByIndex(i);
		if (factionData and C_Reputation.IsFactionParagon(factionData.factionID) ) then
			return true;
		end
	end
	return false;
end

local function CompareFrameSize(frame1, frame2)
	return frame1:GetWidth() > frame2:GetWidth();
end

function CharacterFrameMixin:UpdateTabBounds()
	if CharacterFrameTab3:IsShown() then
		local diff = (CharacterFrameTab3:GetRight() or 0) - (self:GetRight() or 0);

		if diff > 0 then
			table.sort(self.Tabs, CompareFrameSize);

			for _, tab in ipairs(self.Tabs) do
				local change = min(10, diff);
				diff = diff - change;
				tab.Text:SetWidth(0);
				PanelTemplates_TabResize(tab, -change, nil, 36-change, 88);
				if diff <= 0 then
					break;
				end
			end
		end
	end
end

function CharacterFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CharacterFrameEvents);
	characterFrameDisplayInfo["Default"].title = UnitPVPName("player");

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	UpdateMicroButtons();

	local playerFrameHealthBar = PlayerFrame_GetHealthBar();
	local playerFrameManaBar = PlayerFrame_GetManaBar();
	local playerFrameAlternatePowerBar = PlayerFrame_GetAlternatePowerBar();
	playerFrameHealthBar.showNumeric = true;
	playerFrameManaBar.showNumeric = true;
	if playerFrameAlternatePowerBar then
		playerFrameAlternatePowerBar.showNumeric = true;
	end
	PetFrameHealthBar.showNumeric = true;
	PetFrameManaBar.showNumeric = true;
	playerFrameHealthBar:ShowStatusBarText();
	playerFrameManaBar:ShowStatusBarText();
	if playerFrameAlternatePowerBar then
		playerFrameAlternatePowerBar:ShowStatusBarText();
	end
	PetFrameHealthBar:ShowStatusBarText();
	PetFrameManaBar:ShowStatusBarText();
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

function CharacterFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CharacterFrameEvents);

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();

	local playerFrameHealthBar = PlayerFrame_GetHealthBar();
	local playerFrameManaBar = PlayerFrame_GetManaBar();
	local playerFrameAlternatePowerBar = PlayerFrame_GetAlternatePowerBar();
	playerFrameHealthBar.showNumeric = nil;
	playerFrameManaBar.showNumeric = nil;
	if playerFrameAlternatePowerBar then
		playerFrameAlternatePowerBar.showNumeric = nil;
	end
	PetFrameHealthBar.showNumeric = nil;
	PetFrameManaBar.showNumeric = nil;
	playerFrameHealthBar:HideStatusBarText();
	playerFrameManaBar:HideStatusBarText();
	if playerFrameAlternatePowerBar then
		playerFrameAlternatePowerBar:HideStatusBarText();
	end
	PetFrameHealthBar:HideStatusBarText();
	PetFrameManaBar:HideStatusBarText();
	StatusTrackingBarManager:SetTextLocked(false);
	PaperDollFrame.currentSideBar = nil;
	EventRegistry:TriggerEvent("CharacterFrame.Hide");
end

function CharacterFrameMixin:Collapse()
	self.Expanded = false;
	characterFrameDisplayInfo["Default"].width = PANEL_DEFAULT_WIDTH;
	for i = 1, #PAPERDOLL_SIDEBARS do
		GetPaperDollSideBarFrame(i):Hide();
	end
	self.InsetRight:Hide();
	PaperDollFrame_SetLevel();
end

function CharacterFrameMixin:Expand()
	self.Expanded = true;
	characterFrameDisplayInfo["Default"].width = CHARACTERFRAME_EXPANDED_WIDTH;
	if (PaperDollFrame:IsShown() and PaperDollFrame.currentSideBar) then
		PaperDollFrame.currentSideBar:Show();
	else
		CharacterStatsPane:Show();
	end
	PaperDollFrame_UpdateSidebarTabs();
	self.InsetRight:Show();
	PaperDollFrame_SetLevel();
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

CharacterFrameTabButtonMixin = {};

function CharacterFrameTabButtonMixin:OnClick(button)
	PanelTemplates_Tab_OnClick(self, CharacterFrame);
	
	local name = self:GetName();
	if ( name == "CharacterFrameTab1" ) then
		ToggleCharacter("PaperDollFrame");
	elseif ( name == "CharacterFrameTab2" ) then
		ToggleCharacter("ReputationFrame");
	elseif ( name == "CharacterFrameTab3" ) then
		CharacterFrame:ToggleTokenFrame();
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

GearEnchantAnimationMixin = {}

local GearEnchantAnimationEvents = {
	"ENCHANT_SPELL_COMPLETED",
};

function GearEnchantAnimationMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, GearEnchantAnimationEvents);

	local function GearEnchantFXAnimOnFinished()
		self.FrameFX:Hide();
	end
	self.FrameFX.FrameFXAnimGroup:SetScript("OnFinished", GearEnchantFXAnimOnFinished);

	local function GearEnchantTopFrameAnimOnFinished()
		self.TopFrame:Hide();
	end
	self.TopFrame.TopFrameAnimGroup:SetScript("OnFinished", GearEnchantTopFrameAnimOnFinished)
end

function GearEnchantAnimationMixin:OnEvent(event, ...)
	if event == "ENCHANT_SPELL_COMPLETED" then
		local successful, enchantedItem = ...;

		if successful and enchantedItem and enchantedItem:IsValid() and enchantedItem:IsEquipmentSlot() then
			self:PlayAndShow();
		end
	end
end

function GearEnchantAnimationMixin:PlayAndShow()
	self:Show();

	self.FrameFX:Show();
	self.FrameFX.FrameFXAnimGroup:Play();

	self.TopFrame:Show();
	self.TopFrame.TopFrameAnimGroup:Play();
end

function GearEnchantAnimationMixin:StopAndHide()
	self.FrameFX.FrameFXAnimGroup:Stop();
	self.TopFrame.TopFrameAnimGroup:Stop();

	self:Hide();
end