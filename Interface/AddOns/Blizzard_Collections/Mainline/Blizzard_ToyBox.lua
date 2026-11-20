local TOYS_PER_PAGE = 18;
local TOY_FANFARE_MODEL_SCENE = 253;

ToyBoxMixin = {}

function ToyBoxMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
end

function ToyBoxMixin:SetupGamepadFooter()
	local function ToySpellButtonClick()
		local button = SmartNavigation:GetCurrentButton();
		button:Click();
	end
	local function ToySpellButtonLabel()
		local button = SmartNavigation:GetCurrentButton();
		if ToySpellButton_HasFanFare(button) then
			return UNWRAP;
		end
		return USE;
	end

	local toyBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, "ToyBox_Use_PromptedBinding");
	toyBinding:AddFooterBinding({
		label = ToySpellButtonLabel,
		visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE,
		buttonContexts = "ButtonContext_ToySpellButton",
	});
	toyBinding:AddFooterFunction({
		bindingFunctions = ToySpellButtonClick,
	})

	local function PlayerHasToyForButton()
		local button = SmartNavigation:GetCurrentButton();
		return PlayerHasToy(button.itemID);
	end
	local function ToyCreateCtxMenu()
		local button = SmartNavigation:GetCurrentButton();
		ToySpellButton_CreateContextMenu(button, button.itemID);
	end

	local ctxMenuBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, "ToyBox_CtxMenu_PromptedBinding");
	ctxMenuBinding:AddFooterBinding({
		label = CONTEXT_ACTION_LABEL_MORE_ACTIONS,
		visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE,
		buttonContexts = "ButtonContext_ToySpellButton",
		conditions = { PlayerHasToyForButton, },
	});
	ctxMenuBinding:AddFooterFunction({
		bindingFunctions = ToyCreateCtxMenu,
	})

	local function BindToyToActionBar()
		local button = SmartNavigation:GetCurrentButton();
		GamepadActionBarEditFrame:BindItem(button.itemID);
	end

	local bindBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, "ToyBox_Bind_PromptedBinding");
	bindBinding:AddFooterBinding({
		label = CONTEXT_ACTION_LABEL_BIND_TO_GAMEPAD_ACTION_BAR,
		visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE,
		buttonContexts = "ButtonContext_ToySpellButton",
		conditions = { PlayerHasToyForButton, },
	});
	bindBinding:AddFooterFunction({
		bindingFunctions = BindToyToActionBar,
	})

	local function FocusSearchBox()
		local searchBox = ToyBox.searchBox;
		if searchBox.GamepadFocusIcon:IsShown() then
			SmartNavigation:SelectButton(searchBox);
			searchBox:SetFocus();
		end
	end
	local function ShouldShowFocusSearchBox()
		local button = SmartNavigation:GetCurrentButton();
		return button ~= ToyBox.searchBox;
	end

	local focusSearchBox = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, FocusSearchBox, nil);
	focusSearchBox:SetCustomPromptFrame(ToyBox.searchBox.GamepadFocusIcon);
	focusSearchBox:AddCondition(ShouldShowFocusSearchBox);
	focusSearchBox:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local toyBoxFooter = GamepadSharedUtility.CreatePromptedBindingFooter(CollectionsJournal, "Collections_ToyBox");
	toyBoxFooter:AddPromptedBinding(toyBinding);
	toyBoxFooter:AddPromptedBinding(ctxMenuBinding);
	toyBoxFooter:AddPromptedBinding(bindBinding);
	toyBoxFooter:AddPromptedBinding(focusSearchBox);
	toyBoxFooter:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
	toyBoxFooter:Finalize();

	return toyBoxFooter;
end

function ToyBoxMixin:SetupGamepad()
	self.footer = self:SetupGamepadFooter();

	for i = 1, TOYS_PER_PAGE do
		local button = ToyBox.iconsFrame["spellButton"..i];
		button.buttonContext = "ButtonContext_ToySpellButton";
	end
end

function ToyBoxMixin:InitializeGamepad()
	self.searchBox:HookScript("OnEditFocusGained", function()
		local button = SmartNavigation:GetCurrentButton();
		if not button or (button ~= self.searchBox) then
			SmartNavigation:SelectButton(self.searchBox);
		end
	end);
end

local function IsToySpellButtonForPagination()
	local button = SmartNavigation:GetCurrentButton();
	if not button then
		return false;
	end
	if not button.buttonContext then
		return false;
	end
	return button.buttonContext == "ButtonContext_ToySpellButton";
end

function ToyBoxMixin:TurnPageRight()
	if not IsToySpellButtonForPagination() then
		return;
	end
	self.PagingFrame.NextPageButton:Click();
end

function ToyBoxMixin:TurnPageLeft()
	if not IsToySpellButtonForPagination() then
		return;
	end
	self.PagingFrame.PrevPageButton:Click();
end

function ToyBoxMixin:SmartNavTabFocus()
	if SmartNavigation:IsActiveFrame(CollectionsJournal) then
		SmartNavigation:SelectFirstButton(true);
	end

	SmartNavigation:RegisterCallback("HitRightEdge", self.TurnPageRight, self);
	SmartNavigation:RegisterCallback("HitLeftEdge", self.TurnPageLeft, self);
end

function ToyBoxMixin:SmartNavTabUnfocus()
	SmartNavigation:UnregisterCallback("HitRightEdge", self);
	SmartNavigation:UnregisterCallback("HitLeftEdge", self);
end

function ToyBoxMixin:SmartNavUpdateTabFocus(show)
	if show then
		self:SmartNavTabFocus();
	else
		self:SmartNavTabUnfocus();
	end
end

function ToyBox_OnLoad(self)
	self.firstCollectedToyID = 0; -- used to track which toy gets the favorite helpbox
	self.autoPageToCollectedToyID = UIParent.autoPageToCollectedToyID or nil;
	self.newToys = UIParent.newToys or {};
	self.fanfareToys = {};

	self.fanfarePool = CreateFramePool("MODELSCENE", self, "NonInteractableWrappedModelSceneTemplate");

	ToyBox_UpdatePages();
	ToyBox_UpdateProgress(self);

	-- If there is only one filter setting available, hide filter
	if C_CVar.GetCVarBool("onlyShowCollectedItemsInJournal") then
		C_ToyBoxInfo.SetDefaultFilters();
		self.FilterDropdown:Hide();

		-- Move search bar over to previous filter position
		local point, relativeFrame, relativePoint, offsetX, offsetY = ToyBox.FilterDropdown:GetPoint();
		ToyBox.searchBox:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY);
	else
		ToyBox_InitFilterDropdown(self);
	end

	self:RegisterEvent("TOYS_UPDATED");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");

	self.OnPageChanged = function(userAction)
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		ToyBox_UpdateButtons();
		if userAction and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_MOUSEWHEEL_PAGING) then
			local helpTipInfo = {
				text = TOYBOX_MOUSEWHEEL_PAGING_HELP,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_TOYBOX_MOUSEWHEEL_PAGING,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				hideArrow = true,
				offsetX = 44,
			};
			HelpTip:Show(self, helpTipInfo, self.PagingFrame);
		end

		if InputUtil.IsGamepadUIEnabled() then
			if SmartNavigation:IsActiveFrame(CollectionsJournal) then
				SmartNavigation:SelectFirstButton(true);
			end
		end
	end

	self:RegisterForTransitions();
end

function ToyBox_InitFilterDropdown(self)
	self.FilterDropdown:SetWidth(90);

	self.FilterDropdown:SetUpdateCallback(function(description)
		ToyBox.firstCollectedToyID = 0;
		ToyBox_UpdatePages();
		ToyBox_UpdateButtons();
	end);

	self.FilterDropdown:SetIsDefaultCallback(function()
		return C_ToyBoxInfo.IsUsingDefaultFilters();
	end);
	
	self.FilterDropdown:SetDefaultCallback(function()
		C_ToyBoxInfo.SetDefaultFilters();
	end);

	-- Values are inverted because Usable is implemented in terms of the Unusable API.
	local function SetUsableOnlyShown(value)
		C_ToyBox.SetUnusableShown(not value);
		return MenuResponse.Refresh;
	end
	
	local function SetAllSourceTypeFilters(selected)
		C_ToyBox.SetAllSourceTypeFilters(selected);
		return MenuResponse.Refresh;
	end

	local function SetAllExpansionTypeFilters(selected)
		C_ToyBox.SetAllExpansionTypeFilters(selected);
		return MenuResponse.Refresh;
	end

	local function GetUsableOnlyShown()
		return not C_ToyBox.GetUnusableShown();
	end

	local function IsSourceChecked(filterIndex) 
		return C_ToyBox.IsSourceTypeFilterChecked(filterIndex)
	end

	local function SetSourceChecked(filterIndex) 
		C_ToyBox.SetSourceTypeFilter(filterIndex, not IsSourceChecked(filterIndex));
	end

	local function IsExpansionChecked(filterIndex) 
		return C_ToyBox.IsExpansionTypeFilterChecked(filterIndex)
	end

	local function SetExpansionChecked(filterIndex) 
		C_ToyBox.SetExpansionTypeFilter(filterIndex, not IsExpansionChecked(filterIndex));
	end
	
	local toySourceOrderPriorities = {
		[Enum.BattlePetSources.Drop] = 5,
		[Enum.BattlePetSources.Quest] = 5,
		[Enum.BattlePetSources.Vendor] = 5,
		[Enum.BattlePetSources.Profession] = 5,
		[Enum.BattlePetSources.WildPet] = 5,
		[Enum.BattlePetSources.Achievement] = 5,
		[Enum.BattlePetSources.WorldEvent] = 5,
		[Enum.BattlePetSources.Discovery] = 5,
		[Enum.BattlePetSources.TradingPost] = 4,
		[Enum.BattlePetSources.Promotion] = 3,
		[Enum.BattlePetSources.PetStore] = 2,
		[Enum.BattlePetSources.Tcg] = 1,
	};

	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_TOYBOX_FILTER");

		rootDescription:CreateCheckbox(COLLECTED, C_ToyBox.GetCollectedShown, function()
			C_ToyBox.SetCollectedShown(not C_ToyBox.GetCollectedShown());
		end);

		rootDescription:CreateCheckbox(NOT_COLLECTED, C_ToyBox.GetUncollectedShown, function()
			C_ToyBox.SetUncollectedShown(not C_ToyBox.GetUncollectedShown());
		end);
		
		rootDescription:CreateCheckbox(PET_JOURNAL_FILTER_USABLE_ONLY, GetUsableOnlyShown, function()
			SetUsableOnlyShown(not GetUsableOnlyShown());
		end);

		local sourceSubmenu = rootDescription:CreateButton(SOURCES);
		sourceSubmenu:CreateButton(CHECK_ALL, SetAllSourceTypeFilters, true);
		sourceSubmenu:CreateButton(UNCHECK_ALL, SetAllSourceTypeFilters, false);

		for filterIndex = 1, C_PetJournal.GetNumPetSources() do
			if C_ToyBoxInfo.IsToySourceValid(filterIndex) then
				sourceSubmenu:CreateCheckbox(_G["BATTLE_PET_SOURCE_"..filterIndex], IsSourceChecked, SetSourceChecked, filterIndex);
			end
		end

		local expansionSubmenu = rootDescription:CreateButton(EXPANSION_FILTER_TEXT);
		expansionSubmenu:CreateButton(CHECK_ALL, SetAllExpansionTypeFilters, true);
		expansionSubmenu:CreateButton(UNCHECK_ALL, SetAllExpansionTypeFilters, false);

		for filterIndex = 1, GetNumExpansions() do
			-- EXPANSION_NAME is indexed from 0
			local adjustedFilterIndex = (filterIndex - 1);
			expansionSubmenu:CreateCheckbox(_G["EXPANSION_NAME"..adjustedFilterIndex], IsExpansionChecked, SetExpansionChecked, filterIndex);
		end
	end);
end

function ToyBox_OnEvent(self, event, itemID, new, fanfare)
	if ( event == "TOYS_UPDATED" ) then
		if (new) then
			self.autoPageToCollectedToyID = itemID;
			if ( not CollectionsJournal:IsShown() ) then
				CollectionsJournal_SetTab(CollectionsJournal, 3);
			end
		end

		if fanfare then
			self.fanfareToys[itemID] = true;
		end

		ToyBox_UpdatePages();
		ToyBox_UpdateProgress(self);
		ToyBox_UpdateButtons();

		if (new) then
			self.newToys[itemID] = true;
		end
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		ToyBox_UpdateButtons();
	end

end

function ToyBox_OnShow(self)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX, true);

	if(C_ToyBox.HasFavorites()) then
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE, true);
		HelpTip:Hide(self, TOYBOX_FAVORITE_HELP);
	end

	CollectionsJournal:SetPortraitToAsset("Interface\\Icons\\Trade_Archaeology_ChestofTinyGlassAnimals");
	C_ToyBox.ForceToyRefilter();

	ToyBox_UpdatePages();
	ToyBox_UpdateProgress(self);
	ToyBox_UpdateButtons();
end

function ToyBox_FindPageForToyID(toyID)
	for i = 1, C_ToyBox.GetNumFilteredToys() do
		if C_ToyBox.GetToyFromIndex(i) == toyID then
			return math.floor((i - 1) / TOYS_PER_PAGE) + 1;
		end
	end

	return nil;
end

function ToyBox_OnMouseWheel(self, value)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_MOUSEWHEEL_PAGING, true);
	HelpTip:Hide(self, TOYBOX_MOUSEWHEEL_PAGING_HELP);
	ToyBox.PagingFrame:OnMouseWheel(value);
end

function ToySpellButton_OnShow(self)
	self:RegisterEvent("TOYS_UPDATED");

	CollectionsSpellButton_OnShow(self);
end

function ToySpellButton_OnHide(self)
	CollectionsSpellButton_OnHide(self);

	self:UnregisterEvent("TOYS_UPDATED");
end

function ToySpellButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( GameTooltip:SetToyByItemID(self.itemID) ) then
		self.UpdateTooltip = ToySpellButton_OnEnter;
	else
		self.UpdateTooltip = nil;
	end

	local hasFanfare = ToyBox.fanfareToys[self.itemID] ~= nil;
	local isNew = ToyBox.newToys[self.itemID] ~= nil;
	if( isNew and not hasFanfare ) then
		ToyBox.newToys[self.itemID] = nil;
	end
	ToySpellButton_UpdateButton(self);
end

function ToySpellButton_HasFanFare(self)
	if ( (ToyBox.fanfareToys[self.itemID] ~= nil) and (ToyBox.fanfareToys[self.itemID] == true) ) then
		return true;
	end
	return false;
end

function ToySpellButton_Unwrap(self)
	ToyBox.fanfareToys[self.itemID] = false;
	ToyBox.newToys[self.itemID] = nil;

	if ( self.modelScene ) then
		local function OnFinishedCallback()
			C_ToyBoxInfo.ClearFanfare(self.itemID);
			ToySpellButton_UpdateButton(self);

			if ToyBox.footer then
				ToyBox.footer:Refresh();
			end
		end
		self.modelScene:StartUnwrapAnimation(OnFinishedCallback);

		ToySpellButton_FadeInIcon(self);
	end
end

function ToySpellButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		if (ToySpellButton_HasFanFare(self)) then
			ToySpellButton_Unwrap(self);
		else
			UseToy(self.itemID);
		end
	elseif ( button == "RightButton" ) then
		if (PlayerHasToy(self.itemID)) then
			ToySpellButton_CreateContextMenu(self, self.itemID);
		end
	end
end

function ToySpellButton_CreateContextMenu(self, itemID)
	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_TOYBOX_FAVORITE");

		local isFavorite = C_ToyBox.GetIsFavorite(itemID);
		if isFavorite then
			rootDescription:CreateButton(BATTLE_PET_UNFAVORITE, function()
				C_ToyBox.SetIsFavorite(itemID, false);
			end);
		else
			rootDescription:CreateButton(BATTLE_PET_FAVORITE, function()
				C_ToyBox.SetIsFavorite(itemID, true);

				SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE, true);
				HelpTip:Hide(ToyBox, TOYBOX_FAVORITE_HELP);
			end);
		end
	end);
end

function ToySpellButton_FadeInIcon(self)
	self.iconTexture:SetAlpha(0.0);
	self.slotFrameCollected:SetAlpha(0.0);
	self.iconTexture:Show();
	self.slotFrameCollected:Show();

	local function ShowHighlightTexture()
		self.HighlightTexture:Show();
	end
	self.IconFadeIn:SetScript("OnFinished", ShowHighlightTexture);

	self.IconFadeIn:Play();
end

function ToySpellButton_OnModifiedClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local itemLink = C_ToyBox.GetToyLink(self.itemID);
		if ( itemLink ) then
			ChatFrameUtil.InsertLink(itemLink);
		end
	end
end

function ToySpellButton_OnDrag(self)
	C_ToyBox.PickupToyBoxItem(self.itemID);
end

function ToySpellButton_UpdateButton(self)
	local itemIndex = (ToyBox.PagingFrame:GetCurrentPage() - 1) * TOYS_PER_PAGE + self:GetID();
	self.itemID = C_ToyBox.GetToyFromIndex(itemIndex);

	local toyString = self.name;
	local toyNewString = self.new;
	local toyNewGlow = self.newGlow;
	local iconTexture = self.iconTexture;
	local iconTextureUncollected = self.iconTextureUncollected;
	local slotFrameCollected = self.slotFrameCollected;
	local slotFrameUncollected = self.slotFrameUncollected;
	local slotFrameUncollectedInnerGlow = self.slotFrameUncollectedInnerGlow;
	local iconFavoriteTexture = self.cooldownWrapper.slotFavorite;

	if (self.itemID == -1) then
		self:Hide();
		return;
	end

	self:Show();

	local itemID, toyName, icon, isFavorite, hasFanfare = C_ToyBox.GetToyInfo(self.itemID);
	if (itemID == nil) or (toyName == nil) then
		return;
	end

	if ToyBox.fanfareToys[itemID] == nil and hasFanfare then
		ToyBox.fanfareToys[itemID] = true;
		ToyBox.newToys[self.itemID] = true;-- if it has fanfare, we also want to treat it as new
	end

	if string.len(toyName) == 0 then
		toyName = itemID;
	end

	if not ToyBox.newToys[self.itemID] then
		toyNewString:Hide();
		toyNewGlow:Hide();
	else
		toyNewString:Show();
		toyNewGlow:Show();
	end

	iconTexture:SetTexture(icon);
	iconTextureUncollected:SetTexture(icon);
	iconTextureUncollected:SetDesaturated(true);

	if not ToyBox.fanfareToys[itemID] then
		if self.modelScene then
			ToyBox.fanfarePool:Release(self.modelScene);
			self.modelScene = nil;
		end

		if (PlayerHasToy(self.itemID)) then
			iconTexture:Show();
			iconTextureUncollected:Hide();
			toyString:SetTextColor(1, 0.82, 0, 1);
			toyString:SetShadowColor(0, 0, 0, 1);
			slotFrameCollected:Show();
			slotFrameUncollected:Hide();
			slotFrameUncollectedInnerGlow:Hide();

			if(ToyBox.firstCollectedToyID == 0) then
				ToyBox.firstCollectedToyID = self.itemID;
			end

			if (ToyBox.firstCollectedToyID == self.itemID and not HelpTip:IsShowing(ToyBox, TOYBOX_FAVORITE_HELP) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE)) then
				local helpTipInfo = {
					text = TOYBOX_FAVORITE_HELP,
					buttonStyle = HelpTip.ButtonStyle.Close,
					cvarBitfield = "closedInfoFrames",
					bitfieldFlag = LE_FRAME_TUTORIAL_TOYBOX_FAVORITE,
					targetPoint = HelpTip.Point.BottomEdgeCenter,
					alignment = HelpTip.Alignment.Left,
					offsetY = 0,
				};
				HelpTip:Show(ToyBox, helpTipInfo, self);
			end
		else
			iconTexture:Hide();
			iconTextureUncollected:Show();
			toyString:SetTextColor(0.33, 0.27, 0.20, 1);
			toyString:SetShadowColor(0, 0, 0, 0.33);
			slotFrameCollected:Hide();
			slotFrameUncollected:Show();
			slotFrameUncollectedInnerGlow:Show();
		end

		if (C_ToyBox.GetIsFavorite(itemID)) then
			iconFavoriteTexture:Show();
		else
			iconFavoriteTexture:Hide();
		end		
		CollectionsSpellButton_UpdateCooldown(self);
	else
		-- we are presenting fanfare
		if not self.modelScene then
			self.modelScene = ToyBox.fanfarePool:Acquire();
			self.modelScene:SetParent(self);
			self.modelScene:ClearAllPoints();
			self.modelScene:SetPoint("CENTER");
		end
		if self.modelScene then
			iconTexture:Hide();
			slotFrameCollected:Hide();
			slotFrameUncollected:Hide();
			iconTextureUncollected:Hide();
			toyString:SetTextColor(1, 0.82, 0, 1);
			self.cooldown:Hide();
			self.HighlightTexture:Hide();
			self.modelScene:TransitionToModelSceneID(TOY_FANFARE_MODEL_SCENE, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, true);
			self.modelScene:PrepareForFanfare(true);
			self.modelScene:Show();
		end
	end

	toyString:SetText(toyName);
	toyString:Show();
end

function ToyBox_UpdateButtons()
	HelpTip:Hide(ToyBox, TOYBOX_FAVORITE_HELP);
	for i = 1, TOYS_PER_PAGE do
	    local button = ToyBox.iconsFrame["spellButton"..i];
		ToySpellButton_UpdateButton(button);
	end

	if ToyBox.footer then
		ToyBox.footer:Refresh();
	end
end

function ToyBox_UpdatePages()
	local maxPages = 1 + math.floor( math.max((C_ToyBox.GetNumFilteredToys() - 1), 0) / TOYS_PER_PAGE);
	ToyBox.PagingFrame:SetMaxPages(maxPages)
	if ToyBox.autoPageToCollectedToyID then
		local toyPage = ToyBox_FindPageForToyID(ToyBox.autoPageToCollectedToyID);
		if toyPage then
			ToyBox.PagingFrame:SetCurrentPage(toyPage);
		end
		ToyBox.autoPageToCollectedToyID = nil;
	end
end

function ToyBox_UpdateProgress(self)
	local maxProgress = C_ToyBox.GetNumTotalDisplayedToys();
	local currentProgress = C_ToyBox.GetNumLearnedDisplayedToys();

	if self.ProgressTracker.isBar then
		self.ProgressTracker:SetMinMaxValues(0, maxProgress);
		self.ProgressTracker:SetValue(currentProgress);
		self.ProgressTracker.text:SetFormattedText(TOY_PROGRESS_FORMAT, currentProgress, maxProgress);
	end

	if self.ProgressTracker.isCount then
		self.ProgressTracker.Count:SetText(currentProgress);
	end
end

function ToyBox_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	local oldText = ToyBox.searchString;
	ToyBox.searchString = self:GetText();

	if ( oldText ~= ToyBox.searchString ) then
		ToyBox.firstCollectedToyID = 0;
		C_ToyBox.SetFilterString(ToyBox.searchString);
		ToyBox_UpdatePages();
		ToyBox_UpdateButtons();
	end
end
