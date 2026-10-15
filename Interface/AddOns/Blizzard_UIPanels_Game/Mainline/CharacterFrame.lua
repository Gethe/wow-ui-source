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

CHARACTER_FRAME_TAB = {
	Character = 1,
	Reputation = 2,
	Currency = 3,
	PVP = 4,
	Skills = 5,
};

CharacterFrameMixin = {};

function CharacterFrameMixin:GetTab(tabID)
	if self.Tabs then
		return self.Tabs[tabID];
	end

	return _G["CharacterFrameTab"..tabID];
end

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
	"PORTRAITS_UPDATED",
	"CURRENCY_DISPLAY_UPDATE",
}

function CharacterFrameMixin:OnLoad()
	ButtonFrameTemplate_HideButtonBar(self);
	self:SetTitleMaxLinesAndHeight(1, 13);
	self.Tab = CHARACTER_FRAME_TAB;

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, NUM_CHARACTERFRAME_TABS);
	PanelTemplates_SetTab(self, 1);
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

function CharacterFrameMixin:ShouldShowCurrencyTab()
	return C_CurrencyInfo.GetCurrencyListSize() > 0;
end

function CharacterFrameMixin:UpdateCurrencyTabVisibility()
	local currencyTab = CharacterFrame_GetTab(CHARACTER_FRAME_TAB.Currency);
	currencyTab:SetShown(self:ShouldShowCurrencyTab());

	if self.UpdateTabLayout then
		self:UpdateTabLayout();
	end
	if self.UpdateTabBounds then
		self:UpdateTabBounds();
	end
end

function CharacterFrameMixin:OnEvent (event, ...)
	if ( not self:IsShown() ) then
		return;
	end

	local arg1 = ...;
	if ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		self:UpdateCurrencyTabVisibility();
		return;
	end

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
		if (factionData and C_Reputation.IsFactionParagonForCurrentPlayer(factionData.factionID) ) then
			return true;
		end
	end
	return false;
end

local function CompareFrameSize(frame1, frame2)
	return frame1:GetWidth() > frame2:GetWidth();
end

function CharacterFrameMixin:UpdateTabBounds()
	local currencyTab = CharacterFrame_GetTab(CHARACTER_FRAME_TAB.Currency);
	if currencyTab:IsShown() then
		local diff = (currencyTab:GetRight() or 0) - (self:GetRight() or 0);

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
	self:UpdateCurrencyTabVisibility();

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
		local reputationTab = CharacterFrame_GetTab(CHARACTER_FRAME_TAB.Reputation);
		HelpTip:Show(self, helpTipInfo, reputationTab);
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
	self:RefreshDisplay();
end

function CharacterFrameMixin:Expand()
	self.Expanded = true;
	characterFrameDisplayInfo["Default"].width = 540;
	if (PaperDollFrame:IsShown() and PaperDollFrame.currentSideBar) then
		PaperDollFrame.currentSideBar:Show();
	else
		self:GetStatsPane():Show();
	end
	PaperDollFrame_UpdateSidebarTabs();
	self.InsetRight:Show();
	PaperDollFrame_SetLevel();
	self:RefreshDisplay();
end

function CharacterFrameMixin:GetStatsPane()
	return CharacterStatsPane;
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

	local tabID = self:GetID();
	if ( tabID == CharacterFrame.Tab.Character ) then
		ToggleCharacter("PaperDollFrame");
	elseif ( tabID == CharacterFrame.Tab.Reputation ) then
		ToggleCharacter("ReputationFrame");
	elseif ( tabID == CharacterFrame.Tab.Currency ) then
		CharacterFrame:ToggleTokenFrame();
	elseif ( tabID == CharacterFrame.Tab.PVP ) then
		ToggleCharacter("PVPRankFrame");
	elseif ( tabID == CharacterFrame.Tab.Skills ) then
		ToggleCharacter("SkillsFrame");
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

CharacterStatFrameMixin = {};

function CharacterStatFrameMixin:OnLoad()
	if (STATFRAME_STATTEXT_FONT_OVERRIDE) then
		self.Value:SetFontObject(STATFRAME_STATTEXT_FONT_OVERRIDE);
	end
end


function CharacterStatFrameMixin:OnEnter()
	if ( self.onEnterFunc ) then
		self:onEnterFunc();
	else
		PaperDollStatTooltip(self);
	end
end

CharacterStatsPaneScrollBoxMixin = {};

function CharacterStatsPaneScrollBoxMixin:OnLoad()
	local function Initializer(button, elementData)
		button:Init(elementData);
	end

	local bottomPadding = 8;
	local view = CreateScrollBoxListLinearView(0, bottomPadding, 0, 0, 2);
	view:SetElementFactory(function(factory, elementData)
		if elementData.isHeader then
			factory("CharacterStatFrameCategoryScrollBoxElementTemplate", Initializer);
		elseif elementData.texture then
			factory("CharacterStatFrameScrollBoxIconElementTemplate", Initializer);
		else
			factory("CharacterStatFrameScrollBoxLabelElementTemplate", Initializer);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.elementData = {};
	self.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnUpdate, GenerateClosure(self.ScrollBoxOnUpdate, self));
end

function CharacterStatsPaneScrollBoxMixin:ScrollBoxOnUpdate()
	self:HideElements();
end

function CharacterStatsPaneScrollBoxMixin:HideElements()
	local changed = false;
	for i = #self.elementData, 1, -1 do
		local elementData = self.elementData[i];

		if (elementData.shouldRemove) then
			changed = true;
			table.remove(self.elementData, i);
		end
	end

	if changed then
		self.ScrollBox:SetDataProvider(CreateDataProvider(self.elementData), ScrollBoxConstants.RetainScrollPosition);
	end
end

function CharacterStatsPaneScrollBoxMixin:UpdateStats()
	local spec, role;
	spec = C_SpecializationInfo.GetSpecialization();
	if spec then
		role = GetSpecializationRoleEnum(spec);
	end

	self.elementData = {};

	for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
		local skipCategory = false;

		if PAPERDOLL_STATCATEGORIES[catIndex].unit and PAPERDOLL_STATCATEGORIES[catIndex].unit ~= self:GetUnit() then
			skipCategory = true;
		end

		if not skipCategory then
			local catFrame = CharacterStatsPane[PAPERDOLL_STATCATEGORIES[catIndex].categoryFrame];
			local numStatInCat = 0;
			local statsForCategory = {};
			for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
				local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex];
				local showStat = true;
				if ( showStat and stat.primary and spec ) then
					local primaryStat = select(6, C_SpecializationInfo.GetSpecializationInfo(spec, false, false, nil, UnitSex("player")));
					if ( stat.primary ~= primaryStat ) then
						showStat = false;
					end
				end
				if ( showStat and stat.roles ) then
					local foundRole = false;
					for _, statRole in pairs(stat.roles) do
						if ( role == statRole ) then
							foundRole = true;
							break;
						end
					end
					showStat = foundRole;
				end
				if (showStat and stat.unit) then
					showStat = stat.unit == self:GetUnit();
				end

				if ( showStat and stat.showFunc ) then
					showStat = stat.showFunc();
				end
				if ( showStat ) then
						tinsert(statsForCategory, stat);
						numStatInCat = numStatInCat + 1;
				end
			end


			-- We need this to calculate stats
			local statFrame = CharacterStatsPane.statsFramePool:Acquire();

			if numStatInCat > 0 then
				local headerData = {};
				headerData.isHeader = true;
				headerData.name = PAPERDOLL_STATCATEGORIES[catIndex].categoryName;
				tinsert(self.elementData, headerData);
				local actualIndex = 1;
				for i, stat in ipairs(statsForCategory) do
					local statData = {
						isHeader = false;
						unit = self:GetUnit();
						name = stat.stat;
						id = stat.id;
						statIndex = actualIndex;
						texture = stat.texture;
						textureCoordL = stat.textureCoordL;
						textureCoordR = stat.textureCoordR;
						textureCoordT = stat.textureCoordT;
						textureCoordB = stat.textureCoordB;
						hideAt = stat.hideAt;
					};
					local numericValue = PAPERDOLL_STATINFO[statData.name].updateFunc(statFrame, statData.unit, statData.id);

					if numericValue ~= statData.hideAt then
						tinsert(self.elementData, statData);
						actualIndex = actualIndex + 1;
					end

				end
			end

			CharacterStatsPane.statsFramePool:Release(statFrame);

		end
	end
	
	self.ScrollBox:SetDataProvider(CreateDataProvider(self.elementData), ScrollBoxConstants.RetainScrollPosition);
end

function CharacterStatsPaneScrollBoxMixin:GetUnit()
	return "player";
end


CharacterStatFrameCategoryScrollBoxElementMixin = {};

function CharacterStatFrameCategoryScrollBoxElementMixin:Init(elementData)
	self.Title:SetText(elementData.name);
end

CharacterStatFrameScrollBoxBaseElementMixin = CreateFromMixins(CharacterStatFrameMixin);

function CharacterStatFrameScrollBoxBaseElementMixin:Init(elementData)
	self.onEnterFunc = nil;
	self.UpdateTooltip = nil;
	local numericValue = PAPERDOLL_STATINFO[elementData.name].updateFunc(self, elementData.unit, elementData.id);

	if elementData.hideAt and numericValue == elementData.hideAt then
		elementData.shouldRemove = true;
	end

	self.Background:SetShown((elementData.statIndex % 2) == 1);

	if elementData.texture then
		self.Icon:SetTexture(elementData.texture);
		if elementData.textureCoordL and elementData.textureCoordR and elementData.textureCoordT and elementData.textureCoordB then
			self.Icon:SetTexCoord(elementData.textureCoordL, elementData.textureCoordR, elementData.textureCoordT, elementData.textureCoordB);
		end

		self.Background:SetShown(false);
		self.Icon:Show();
	end
end

CharacterStatsPanePetScrollBoxMixin = CreateFromMixins(CharacterStatsPaneScrollBoxMixin);

function CharacterStatsPanePetScrollBoxMixin:GetUnit()
	return "pet";
end
